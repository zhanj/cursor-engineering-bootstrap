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
assert_file "${ROOT_DIR}/templates/frontend/.cursor/commands/api-search.md"
assert_file "${ROOT_DIR}/templates/frontend/.cursor/commands/implement-task.md"
assert_file "${ROOT_DIR}/templates/backend/.cursor/rules/00-core.mdc"
assert_file "${ROOT_DIR}/templates/frontend/.cursor/rules/00-core.mdc"

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

# commands <-> PR field alignment
assert_contains "${ROOT_DIR}/templates/backend/.cursor/commands/api-search.md" "1) 复用依据（必填）"
assert_contains "${ROOT_DIR}/templates/frontend/.cursor/commands/api-search.md" "1) 复用依据（必填）"
assert_contains "${ROOT_DIR}/templates/backend/.cursor/commands/implement-task.md" "2)~5)"
assert_contains "${ROOT_DIR}/templates/frontend/.cursor/commands/implement-task.md" "2)~5)"
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

echo "[smoke:templates] PASS"
