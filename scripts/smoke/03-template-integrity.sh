#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

assert_file() {
  local path="$1"
  [[ -f "${path}" ]] || {
    echo "[smoke:templates] missing required file: ${path}"
    exit 1
  }
}

assert_contains() {
  local file="$1"
  local text="$2"
  rg -n -F "${text}" "${file}" >/dev/null 2>&1 || {
    echo "[smoke:templates] expected text not found in ${file}: ${text}"
    exit 1
  }
}

# Core template existence
assert_file "${ROOT_DIR}/templates/backend/PR_TEMPLATE.md"
assert_file "${ROOT_DIR}/templates/frontend/PR_TEMPLATE.md"
assert_file "${ROOT_DIR}/templates/backend/APPLY.md"
assert_file "${ROOT_DIR}/templates/frontend/APPLY.md"
assert_file "${ROOT_DIR}/templates/spec_center/APPLY.md"

assert_file "${ROOT_DIR}/templates/backend/.cursor/commands/api-search.md"
assert_file "${ROOT_DIR}/templates/backend/.cursor/commands/implement-task.md"
assert_file "${ROOT_DIR}/templates/backend/.cursor/commands/bridge-implement.md"
assert_file "${ROOT_DIR}/templates/backend/.cursor/commands/init-scan.md"
assert_file "${ROOT_DIR}/templates/backend/.cursor/commands/tune-project.md"
assert_file "${ROOT_DIR}/templates/backend/.cursor/commands/cleanup-project.md"
assert_file "${ROOT_DIR}/templates/frontend/.cursor/commands/api-search.md"
assert_file "${ROOT_DIR}/templates/frontend/.cursor/commands/implement-task.md"
assert_file "${ROOT_DIR}/templates/frontend/.cursor/commands/bridge-implement.md"
assert_file "${ROOT_DIR}/templates/frontend/.cursor/commands/init-scan.md"
assert_file "${ROOT_DIR}/templates/frontend/.cursor/commands/tune-project.md"
assert_file "${ROOT_DIR}/templates/frontend/.cursor/commands/cleanup-project.md"
assert_file "${ROOT_DIR}/templates/backend/.cursor/rules/00-core.mdc"
assert_file "${ROOT_DIR}/templates/frontend/.cursor/rules/00-core.mdc"
assert_file "${ROOT_DIR}/templates/backend/.cursor/hooks/gates/pr-dev-path-check.sh"

# PR template required sections
for f in \
  "${ROOT_DIR}/templates/backend/PR_TEMPLATE.md" \
  "${ROOT_DIR}/templates/frontend/PR_TEMPLATE.md"; do
  assert_contains "${f}" "1) 复用依据（必填）"
  assert_contains "${f}" "2) 变更范围（必填）"
  assert_contains "${f}" "3) 契约影响（必填）"
  assert_contains "${f}" "4) 验证证据（必填）"
  assert_contains "${f}" "5) 风险与回滚（必填）"
done

# root PR template required sections
assert_contains "${ROOT_DIR}/PR_TEMPLATE.md" "开发路径（必填）"
assert_contains "${ROOT_DIR}/PR_TEMPLATE.md" "主流程（Spec-kit 驱动"
assert_contains "${ROOT_DIR}/PR_TEMPLATE.md" "快速路径（小改动"
assert_contains "${ROOT_DIR}/PR_TEMPLATE.md" "已明确开发路径并勾选（主流程 / 快速路径 二选一）"

# template PR path field alignment
for f in \
  "${ROOT_DIR}/templates/backend/PR_TEMPLATE.md" \
  "${ROOT_DIR}/templates/frontend/PR_TEMPLATE.md"; do
  assert_contains "${f}" "开发路径（必填）"
  assert_contains "${f}" "主流程（Spec-kit 驱动"
  assert_contains "${f}" "快速路径（小改动"
  assert_contains "${f}" "已明确开发路径并勾选（主流程 / 快速路径 二选一）"
done

# commands <-> PR field alignment
assert_contains "${ROOT_DIR}/templates/backend/.cursor/commands/api-search.md" "1) 复用依据（必填）"
assert_contains "${ROOT_DIR}/templates/frontend/.cursor/commands/api-search.md" "1) 复用依据（必填）"
assert_contains "${ROOT_DIR}/templates/backend/.cursor/commands/implement-task.md" "2)~5)"
assert_contains "${ROOT_DIR}/templates/frontend/.cursor/commands/implement-task.md" "2)~5)"
assert_contains "${ROOT_DIR}/templates/backend/.cursor/commands/bridge-implement.md" "开发路径（必填）"
assert_contains "${ROOT_DIR}/templates/frontend/.cursor/commands/bridge-implement.md" "开发路径（必填）"
assert_contains "${ROOT_DIR}/templates/backend/.cursor/commands/init-scan.md" "needs_manual_confirm"
assert_contains "${ROOT_DIR}/templates/backend/.cursor/commands/init-scan.md" "constitution_quality=ready|placeholder|unknown"
assert_contains "${ROOT_DIR}/templates/frontend/.cursor/commands/init-scan.md" "constitution_quality=ready|placeholder|unknown"
assert_contains "${ROOT_DIR}/templates/backend/.cursor/commands/tune-project.md" "bin/cursor-tune --use-current-dir --dry-run"
assert_contains "${ROOT_DIR}/templates/frontend/.cursor/commands/tune-project.md" "bin/cursor-tune --use-current-dir --dry-run"
assert_contains "${ROOT_DIR}/templates/backend/.cursor/commands/tune-project.md" "# /tune-project 执行结果"
assert_contains "${ROOT_DIR}/templates/frontend/.cursor/commands/tune-project.md" "# /tune-project 执行结果"
assert_contains "${ROOT_DIR}/templates/backend/.cursor/commands/tune-project.md" "| 操作 | 路径 |"
assert_contains "${ROOT_DIR}/templates/frontend/.cursor/commands/tune-project.md" "| 操作 | 路径 |"
assert_contains "${ROOT_DIR}/templates/backend/.cursor/commands/tune-project.md" "cursor-bootstrap|cursor-cleanup"
assert_contains "${ROOT_DIR}/templates/frontend/.cursor/commands/tune-project.md" "cursor-bootstrap|cursor-cleanup"
assert_contains "${ROOT_DIR}/templates/backend/.cursor/commands/cleanup-project.md" "bin/cursor-cleanup --use-current-dir"
assert_contains "${ROOT_DIR}/templates/frontend/.cursor/commands/cleanup-project.md" "bin/cursor-cleanup --use-current-dir"
assert_contains "${ROOT_DIR}/templates/backend/.cursor/commands/api-search.md" "capability-registry.md"
assert_contains "${ROOT_DIR}/templates/frontend/.cursor/commands/api-search.md" "capability-registry.md"
assert_contains "${ROOT_DIR}/templates/backend/.cursor/commands/api-search.md" "internal-self"
assert_contains "${ROOT_DIR}/templates/backend/.cursor/commands/api-search.md" "_raw_contracts/**"
assert_contains "${ROOT_DIR}/templates/frontend/.cursor/commands/api-search.md" "internal-self"
assert_contains "${ROOT_DIR}/templates/frontend/.cursor/commands/api-search.md" "_raw_contracts/**"

# core rules should enforce api-search order
assert_contains "${ROOT_DIR}/templates/backend/.cursor/rules/00-core.mdc" "capability-registry.md"
assert_contains "${ROOT_DIR}/templates/backend/.cursor/rules/00-core.mdc" "openapi.yaml"
assert_contains "${ROOT_DIR}/templates/backend/.cursor/rules/00-core.mdc" "_raw_contracts/**"
assert_contains "${ROOT_DIR}/templates/frontend/.cursor/rules/00-core.mdc" "capability-registry.md"
assert_contains "${ROOT_DIR}/templates/frontend/.cursor/rules/00-core.mdc" "openapi.yaml"
assert_contains "${ROOT_DIR}/templates/frontend/.cursor/rules/00-core.mdc" "_raw_contracts/**"

# APPLY docs should include decision tree
assert_contains "${ROOT_DIR}/templates/backend/APPLY.md" "接入方案决策树（默认 A）"
assert_contains "${ROOT_DIR}/templates/frontend/APPLY.md" "接入方案决策树（默认 A）"
assert_contains "${ROOT_DIR}/templates/spec_center/APPLY.md" "接入方案决策树（默认 A）"

# dev-path gate config and docs
assert_contains "${ROOT_DIR}/templates/backend/.cursor/hooks/gates/config.sh" "CURSOR_DEV_PATH_GATE_MODE"
assert_contains "${ROOT_DIR}/templates/backend/.cursor/hooks/gates/config.sh" "CURSOR_DEV_PATH_GATE_STAGE"
assert_contains "${ROOT_DIR}/templates/backend/.cursor/hooks/gates/README.md" "pr-dev-path-check.sh"

echo "[smoke:templates] PASS"
