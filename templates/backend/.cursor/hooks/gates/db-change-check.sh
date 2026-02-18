#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# DB change consistency gate (v2.4)
# - Uses gates/config.sh for Flyway/Liquibase dirs + MyBatis XML dirs
# - Heuristic:
#   A) migration changed AND no persistence changes => warn/block + show schema hints + suggest file locations
#   B) persistence changed AND no migration/schema evidence => warn/block
# ------------------------------------------------------------

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
if [[ ! -f "${DIR}/config.sh" ]]; then
  echo "[db-gate] missing config: ${DIR}/config.sh"
  exit 2
fi
source "${DIR}/config.sh"

MODE="${CURSOR_DB_GATE_MODE:-warn}"
EXIT_CODE=0

if ! command -v git >/dev/null 2>&1; then
  echo "[db-gate] git not found; skip."
  exit 0
fi

CHANGED="$(git diff --cached --name-only 2>/dev/null || true)"
if [[ -z "${CHANGED}" ]]; then
  CHANGED="$(git diff --name-only 2>/dev/null || true)"
fi

if [[ -z "${CHANGED}" ]]; then
  echo "[db-gate] no changes detected."
  exit 0
fi

FLYWAY_RE="${CURSOR_FLYWAY_DIR_RE:-(^|/)(src/main/resources/)?db/migration/}"
LIQUIBASE_RE="${CURSOR_LIQUIBASE_DIR_RE:-(^|/)(src/main/resources/)?db/changelog/}"
EXTRA_RE="${CURSOR_MIGRATION_DIR_EXTRA_RE:-(^|/)(migration|migrations)/}"
MYBATIS_XML_RE="${CURSOR_MYBATIS_XML_DIR_RE:-(^|/)(src/main/resources/)?(mapper|mappers|mybatis)/}"
PERSIST_HINT_RE="${CURSOR_PERSIST_HINT_RE:-(mapper|repository|dao|entity|model|persistence|infra|mybatis)}"
PERSIST_FILE_RE="${CURSOR_PERSIST_FILE_RE:-\.(java|kt|xml|sql)$}"

SUGGEST_FILES="${CURSOR_DB_GATE_SUGGEST_FILES:-1}"
FIND_MAXDEPTH="${CURSOR_DB_GATE_FIND_MAXDEPTH:-8}"
MAX_TABLES_HINT="${CURSOR_DB_GATE_MAX_TABLES_HINT:-5}"
SRC_JAVA="${CURSOR_SRC_MAIN_JAVA:-src/main/java}"
SRC_RES="${CURSOR_SRC_MAIN_RESOURCES:-src/main/resources}"

mig_changed=0
persist_changed=0
migration_files=()

is_migration_file() {
  local f="$1"
  echo "$f" | grep -Eiq "${FLYWAY_RE}|${LIQUIBASE_RE}|${EXTRA_RE}"
}

is_persist_file() {
  local f="$1"
  if echo "$f" | grep -Eiq "${MYBATIS_XML_RE}"; then
    return 0
  fi
  if echo "$f" | grep -Eiq "${PERSIST_FILE_RE}" && echo "$f" | grep -Eiq "${PERSIST_HINT_RE}"; then
    return 0
  fi
  return 1
}

while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  if is_migration_file "$f"; then
    mig_changed=1
    migration_files+=("$f")
  fi
  if is_persist_file "$f"; then
    persist_changed=1
  fi
done <<< "${CHANGED}"

emit() {
  local m="$1"
  if [[ "${MODE}" == "block" ]]; then
    echo "${m}"
    EXIT_CODE=2
  else
    echo "${m}"
    EXIT_CODE=0
  fi
}

to_camel() {
  # snake_case -> CamelCase (best-effort)
  local s="$1"
  s="$(echo "$s" | sed -E 's/[^A-Za-z0-9_]/_/g')"
  echo "$s" | awk -F'_' '{for(i=1;i<=NF;i++){ if(length($i)>0){ printf toupper(substr($i,1,1)) substr($i,2) } } printf "\n"}'
}

# Extract (best-effort) table/column hints from SQL lines
extract_schema_hints() {
  local file="$1"
  [[ -f "$file" ]] || return 0

  local line
  while IFS= read -r line; do
    local raw="$line"
    raw="${raw%%--*}"
    raw="${raw%%#*}"
    [[ -z "$(echo "$raw" | tr -d '[:space:]')" ]] && continue

    local raw_lc
    raw_lc="$(echo "$raw" | tr '[:upper:]' '[:lower:]')"

    if echo "$raw_lc" | grep -Eq '^[[:space:]]*alter[[:space:]]+table[[:space:]]+'; then
      local tbl
      tbl="$(echo "$raw_lc" | sed -E 's/^[[:space:]]*alter[[:space:]]+table[[:space:]]+[`"]?([a-z0-9_.]+)[`"]?.*/\1/')"
      [[ -n "$tbl" ]] && echo "TABLE|$tbl|ALTER"
      if echo "$raw_lc" | grep -Eq 'add[[:space:]]+column'; then
        local col
        col="$(echo "$raw_lc" | sed -E 's/.*add[[:space:]]+column[[:space:]]+[`"]?([a-z0-9_]+)[`"]?.*/\1/')"
        [[ -n "$col" ]] && echo "COLUMN|$tbl|$col|ADD"
      fi
      continue
    fi

    if echo "$raw_lc" | grep -Eq '^[[:space:]]*create[[:space:]]+table[[:space:]]+'; then
      local tbl
      tbl="$(echo "$raw_lc" | sed -E 's/^[[:space:]]*create[[:space:]]+table[[:space:]]+(if[[:space:]]+not[[:space:]]+exists[[:space:]]+)?[`"]?([a-z0-9_.]+)[`"]?.*/\2/')"
      [[ -n "$tbl" ]] && echo "TABLE|$tbl|CREATE"
      continue
    fi

    if echo "$raw_lc" | grep -Eq '^[[:space:]]*(rename|drop)[[:space:]]+table[[:space:]]+'; then
      local tbl
      tbl="$(echo "$raw_lc" | sed -E 's/^[[:space:]]*(rename|drop)[[:space:]]+table[[:space:]]+[`"]?([a-z0-9_.]+)[`"]?.*/\2/')"
      [[ -n "$tbl" ]] && echo "TABLE|$tbl|RENAME_DROP"
      continue
    fi
  done < "$file"
}

# Collect unique table names (best-effort) from migration files
collect_tables() {
  local tables=()
  local seen="|"
  local f
  for f in "${migration_files[@]}"; do
    [[ -f "$f" ]] || continue
    while IFS= read -r rec; do
      [[ -z "$rec" ]] && continue
      if echo "$rec" | grep -q '^TABLE|'; then
        local t
        t="$(echo "$rec" | cut -d'|' -f2)"
        if [[ "$seen" != *"|$t|"* ]]; then
          tables+=("$t")
          seen="${seen}${t}|"
        fi
      fi
    done < <(extract_schema_hints "$f" || true)
  done

  # print
  local i=0
  for t in "${tables[@]}"; do
    echo "$t"
    i=$((i+1))
    if [[ $i -ge "$MAX_TABLES_HINT" ]]; then
      break
    fi
  done
}

suggest_file_locations() {
  [[ "$SUGGEST_FILES" == "1" ]] || return 0

  if [[ ! -d "$SRC_JAVA" && ! -d "$SRC_RES" ]]; then
    return 0
  fi

  local t
  local i=0
  while IFS= read -r t; do
    [[ -z "$t" ]] && continue
    i=$((i+1))
    local camel
    camel="$(to_camel "$t")"

    echo "[db-gate] 建议改动落点（候选文件，best-effort）for table: $t (Camel: $camel)"
    if [[ -d "$SRC_JAVA" ]]; then
      # entity/model candidates
      find "$SRC_JAVA" -maxdepth "$FIND_MAXDEPTH" -type f \( -iname "*${camel}*.java" -o -iname "*${camel}*.kt" \) 2>/dev/null | head -n 20 | sed 's/^/  - java: /' || true
    fi

    # MyBatis XML candidates
    # Prefer configured MyBatis XML dir, else look under resources
    if [[ -d "$SRC_RES" ]]; then
      find "$SRC_RES" -maxdepth "$FIND_MAXDEPTH" -type f -iname "*${camel}*Mapper.xml" 2>/dev/null | head -n 20 | sed 's/^/  - xml:  /' || true
      find "$SRC_RES" -maxdepth "$FIND_MAXDEPTH" -type f -iname "*mapper*.xml" 2>/dev/null | grep -i "$camel" | head -n 20 | sed 's/^/  - xml:  /' || true
    fi
    echo "[db-gate] 若未命中候选文件：建议用 Cursor /api-search + /be-gen-dao 并提供迁移 SQL 与目标表名。"
    if [[ $i -ge "$MAX_TABLES_HINT" ]]; then
      break
    fi
  done < <(collect_tables || true)
}

schema_hint_block() {
  [[ ${#migration_files[@]} -eq 0 ]] && return 0

  echo "[db-gate] 迁移文件变更涉及的“疑似表/字段”（best-effort，供 Cursor/Review 参考）："
  for f in "${migration_files[@]}"; do
    if [[ -f "$f" ]]; then
      echo " - from: $f"
      while IFS= read -r rec; do
        [[ -z "$rec" ]] && continue
        if echo "$rec" | grep -q '^TABLE|'; then
          echo "  - table: $(echo "$rec" | cut -d'|' -f2) ($(echo "$rec" | cut -d'|' -f3))"
        elif echo "$rec" | grep -q '^COLUMN|'; then
          tbl="$(echo "$rec" | cut -d'|' -f2)"
          col="$(echo "$rec" | cut -d'|' -f3)"
          echo "    - column: ${col} (table: ${tbl})"
        fi
      done < <(extract_schema_hints "$f" || true)
    else
      echo " - from: $f (file not found in working tree; maybe deleted/renamed)"
    fi
  done
  echo "[db-gate] 提示：若这些表/字段与本次改动相关，通常需要同步更新：Entity/DTO/Mapper(XML)/DAO/Repository 及相关测试。"
}

if [[ $mig_changed -eq 1 && $persist_changed -eq 0 ]]; then
  schema_hint_block
  suggest_file_locations
  emit $'[db-gate] 检测到迁移（Flyway/Liquibase）变更，但未发现 DAO/Entity/Mapper/MyBatis XML 等持久层同步变更。\n'\
$'  建议：\n'\
$'  - 若迁移影响字段/索引，请同步更新持久层代码与 MyBatis XML\n'\
$'  - 补充最小验证：mvn test（或集成测试）\n'\
$'  - 若无需同步变更，请在 PR 说明原因\n'\
$'  配置位置：.cursor/hooks/gates/config.sh（只改一处，全队生效）'
fi

if [[ $mig_changed -eq 0 && $persist_changed -eq 1 ]]; then
  emit $'[db-gate] 检测到持久层变更，但未检测到迁移/表结构证据（Flyway/Liquibase）。\n'\
$'  建议：\n'\
$'  - 若新增字段/索引，请补充 migration 或提供 schema 依据（SHOW CREATE TABLE 等）\n'\
$'  - 若只是代码重构，请标注“不涉及表结构变化”并确保回归通过\n'\
$'  配置位置：.cursor/hooks/gates/config.sh（只改一处，全队生效）'
fi

exit ${EXIT_CODE}
