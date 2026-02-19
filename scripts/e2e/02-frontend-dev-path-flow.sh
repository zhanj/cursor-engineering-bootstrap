#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BIN_PATH="${ROOT_DIR}/bin/cursor-init"
GATE_DIR="${ROOT_DIR}/templates/backend/.cursor/hooks/gates"

if [[ ! -f "${BIN_PATH}" ]]; then
  echo "[e2e] missing ${BIN_PATH}"
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "[e2e] ripgrep (rg) is required."
  exit 1
fi

if ! command -v specify >/dev/null 2>&1; then
  echo "[e2e] specify CLI is required for this E2E. Install with:"
  echo "      uv tool install specify-cli"
  exit 1
fi

assert_file() {
  local path="$1"
  [[ -f "${path}" ]] || {
    echo "[e2e] expected file not found: ${path}"
    exit 1
  }
}

assert_dir() {
  local path="$1"
  [[ -d "${path}" ]] || {
    echo "[e2e] expected directory not found: ${path}"
    exit 1
  }
}

assert_contains() {
  local file="$1"
  local text="$2"
  rg -n -F "${text}" "${file}" >/dev/null 2>&1 || {
    echo "[e2e] expected text not found in ${file}: ${text}"
    exit 1
  }
}

expect_success() {
  local label="$1"
  shift
  if "$@"; then
    echo "[e2e] PASS: ${label}"
    return 0
  fi
  echo "[e2e] FAIL: ${label}"
  exit 1
}

expect_failure() {
  local label="$1"
  shift
  if "$@"; then
    echo "[e2e] FAIL: ${label} (expected failure but got success)"
    exit 1
  fi
  echo "[e2e] PASS: ${label} (failed as expected)"
}

workdir="$(mktemp -d "${TMPDIR:-/tmp}/cursor-e2e-fe-dev-path.XXXXXX")"
project_dir="${workdir}/demo-frontend"

cleanup() {
  if [[ "${E2E_KEEP_WORKDIR:-0}" == "1" ]]; then
    echo "[e2e] keep workdir: ${workdir}"
    return
  fi
  rm -rf "${workdir}"
}
trap cleanup EXIT

mkdir -p "${project_dir}"
cat >"${project_dir}/README.md" <<'EOF'
# demo-frontend
Brownfield sample project for cursor-engineering-bootstrap frontend E2E.
EOF

echo "[e2e] step 1/7: initialize frontend sample (dry-run + bundle + spec-kit init)"
bash "${BIN_PATH}" dry-run \
  --mode frontend \
  --target-dir "${project_dir}" \
  --with-spec-kit \
  --execute-spec-kit \
  --spec-kit-yes >/dev/null

bash "${BIN_PATH}" bundle \
  --mode frontend \
  --target-dir "${project_dir}" >/dev/null

assert_file "${project_dir}/_cursor_init/report.md"
assert_file "${project_dir}/_cursor_init/specify-init.log"
assert_dir "${project_dir}/_cursor_init/patch_bundle/frontend"
assert_dir "${project_dir}/.specify"

echo "[e2e] step 2/7: apply frontend patch bundle"
rsync -a "${project_dir}/_cursor_init/patch_bundle/frontend/" "${project_dir}/"
assert_file "${project_dir}/PR_TEMPLATE.md"
assert_file "${project_dir}/.cursor/commands/bridge-implement.md"
assert_contains "${project_dir}/PR_TEMPLATE.md" "开发路径（必填）"

# Frontend template currently does not include gates; copy shared dev-path gate for E2E verification.
mkdir -p "${project_dir}/.cursor/hooks/gates"
cp "${GATE_DIR}/pr-dev-path-check.sh" "${project_dir}/.cursor/hooks/gates/pr-dev-path-check.sh"
cp "${GATE_DIR}/config.sh" "${project_dir}/.cursor/hooks/gates/config.sh"

echo "[e2e] step 3/7: simulate main path PR body"
cat >"${project_dir}/.cursor/pr-main.md" <<'EOF'
## 开发路径（必填）
- [x] 主流程（Spec-kit 驱动：`/speckit.specify -> /speckit.plan -> /speckit.tasks -> /bridge-implement`）
- [ ] 快速路径（小改动：`/api-search -> /implement-task`）

证据：
- /speckit.specify
- /speckit.plan
- /speckit.tasks
- /bridge-implement
EOF

expect_success "frontend main path stage1 block" \
  bash -lc "cd \"${project_dir}\" && CURSOR_DEV_PATH_GATE_MODE=block CURSOR_DEV_PATH_GATE_STAGE=1 bash .cursor/hooks/gates/pr-dev-path-check.sh .cursor/pr-main.md >/dev/null"

expect_success "frontend main path stage2 block" \
  bash -lc "cd \"${project_dir}\" && CURSOR_DEV_PATH_GATE_MODE=block CURSOR_DEV_PATH_GATE_STAGE=2 bash .cursor/hooks/gates/pr-dev-path-check.sh .cursor/pr-main.md >/dev/null"

echo "[e2e] step 4/7: simulate fast path PR body (valid)"
cat >"${project_dir}/.cursor/pr-fast-ok.md" <<'EOF'
## 开发路径（必填）
- [ ] 主流程（Spec-kit 驱动：`/speckit.specify -> /speckit.plan -> /speckit.tasks -> /bridge-implement`）
- [x] 快速路径（小改动：`/api-search -> /implement-task`）

证据：
- /api-search 检索结果已落在 1) 复用依据
- /implement-task 输出已落在 2)~5)
EOF

expect_success "frontend fast path stage1 block" \
  bash -lc "cd \"${project_dir}\" && CURSOR_DEV_PATH_GATE_MODE=block CURSOR_DEV_PATH_GATE_STAGE=1 bash .cursor/hooks/gates/pr-dev-path-check.sh .cursor/pr-fast-ok.md >/dev/null"

expect_success "frontend fast path stage2 block" \
  bash -lc "cd \"${project_dir}\" && CURSOR_DEV_PATH_GATE_MODE=block CURSOR_DEV_PATH_GATE_STAGE=2 bash .cursor/hooks/gates/pr-dev-path-check.sh .cursor/pr-fast-ok.md >/dev/null"

echo "[e2e] step 5/7: negative checks for stage1"
cat >"${project_dir}/.cursor/pr-none.md" <<'EOF'
## 开发路径（必填）
- [ ] 主流程（Spec-kit 驱动：`/speckit.specify -> /speckit.plan -> /speckit.tasks -> /bridge-implement`）
- [ ] 快速路径（小改动：`/api-search -> /implement-task`）
EOF

cat >"${project_dir}/.cursor/pr-both.md" <<'EOF'
## 开发路径（必填）
- [x] 主流程（Spec-kit 驱动：`/speckit.specify -> /speckit.plan -> /speckit.tasks -> /bridge-implement`）
- [x] 快速路径（小改动：`/api-search -> /implement-task`）
EOF

expect_failure "frontend stage1 block rejects none selected" \
  bash -lc "cd \"${project_dir}\" && CURSOR_DEV_PATH_GATE_MODE=block CURSOR_DEV_PATH_GATE_STAGE=1 bash .cursor/hooks/gates/pr-dev-path-check.sh .cursor/pr-none.md >/dev/null 2>&1"

expect_failure "frontend stage1 block rejects both selected" \
  bash -lc "cd \"${project_dir}\" && CURSOR_DEV_PATH_GATE_MODE=block CURSOR_DEV_PATH_GATE_STAGE=1 bash .cursor/hooks/gates/pr-dev-path-check.sh .cursor/pr-both.md >/dev/null 2>&1"

echo "[e2e] step 6/7: negative checks for stage2 evidence"
cat >"${project_dir}/.cursor/pr-fast-missing-evidence.md" <<'EOF'
## 开发路径（必填）
- [ ] 主流程（Spec-kit 驱动：`/speckit.specify -> /speckit.plan -> /speckit.tasks -> /bridge-implement`）
- [x] 快速路径（小改动：`/api-search -> /implement-task`）

证据：
- /api-search 检索完成
EOF

expect_failure "frontend stage2 block rejects fast path without implement evidence" \
  bash -lc "cd \"${project_dir}\" && CURSOR_DEV_PATH_GATE_MODE=block CURSOR_DEV_PATH_GATE_STAGE=2 bash .cursor/hooks/gates/pr-dev-path-check.sh .cursor/pr-fast-missing-evidence.md >/dev/null 2>&1"

echo "[e2e] step 7/7: verify warn mode does not block"
expect_success "frontend stage2 warn allows missing evidence with warning" \
  bash -lc "cd \"${project_dir}\" && CURSOR_DEV_PATH_GATE_MODE=warn CURSOR_DEV_PATH_GATE_STAGE=2 bash .cursor/hooks/gates/pr-dev-path-check.sh .cursor/pr-fast-missing-evidence.md >/dev/null"

echo "[e2e] PASS: frontend dev-path flow end-to-end"
