#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Contract consistency gate (v2.2)
# - Uses gates/config.sh for your repo-specific tuning
# - Triggers ONLY when changed files match whitelist directories
# - Blocks when API-facing code changed but OpenAPI not updated
# ------------------------------------------------------------

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
if [[ ! -f "${DIR}/config.sh" ]]; then
  echo "[contract-gate] missing config: ${DIR}/config.sh"
  exit 2
fi
source "${DIR}/config.sh"

MODE="${CURSOR_CONTRACT_GATE_MODE:-warn}"

if ! command -v git >/dev/null 2>&1; then
  echo "[contract-gate] git not found; skip."
  exit 0
fi

CHANGED="$(git diff --cached --name-only 2>/dev/null || true)"
if [[ -z "${CHANGED}" ]]; then
  CHANGED="$(git diff --name-only 2>/dev/null || true)"
fi

if [[ -z "${CHANGED}" ]]; then
  echo "[contract-gate] no changes detected."
  exit 0
fi

API_DIR_WHITELIST_RE="${CURSOR_API_DIR_WHITELIST_RE:-}"
API_FILE_RE="${CURSOR_API_FILE_RE:-\.(java|kt)$}"
OPENAPI_RE="${CURSOR_OPENAPI_FILE_RE:-(^|/)(contracts/)?openapi\.(ya?ml)$}"

api_code_changed=0
openapi_changed=0

while IFS= read -r f; do
  [[ -z "$f" ]] && continue

  if echo "$f" | grep -Eiq "${OPENAPI_RE}"; then
    openapi_changed=1
  fi

  # Only trigger if hits whitelisted dirs (if whitelist set)
  if [[ -n "${API_DIR_WHITELIST_RE}" ]]; then
    if ! echo "$f" | grep -Eiq "${API_DIR_WHITELIST_RE}"; then
      continue
    fi
  fi

  if echo "$f" | grep -Eiq "${API_FILE_RE}"; then
    api_code_changed=1
  fi
done <<< "${CHANGED}"

if [[ $api_code_changed -eq 1 && $openapi_changed -eq 0 ]]; then
  msg=$'[contract-gate] 命中 API 目录白名单的代码发生变更，但未更新 OpenAPI 契约(openapi.yaml)。
'$'  处理方式：
'$'  1) 若影响接口（路径/参数/返回/鉴权/错误码），请同步更新 contracts/openapi.yaml（或 Spec Center 契约）
'$'  2) 若为新增/调整接口，请同步更新 spec_center/capability-registry.md 能力条目
'$'  3) 若不影响接口，请在 PR 描述中明确“接口不变”的依据，并建议补充测试/截图
'$'  配置位置：.cursor/hooks/gates/config.sh（只改一处，全队生效）
'$'  如需强制阻断，可设置 CURSOR_CONTRACT_GATE_MODE=block'
  if [[ "${MODE}" == "warn" ]]; then
    echo "${msg}"
    exit 0
  else
    echo "${msg}"
    exit 2
  fi
fi

exit 0
