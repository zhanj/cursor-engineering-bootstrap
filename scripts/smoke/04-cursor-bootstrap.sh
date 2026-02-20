#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BIN_PATH="${ROOT_DIR}/bin/cursor-bootstrap"

if [[ ! -f "${BIN_PATH}" ]]; then
  echo "[smoke:bootstrap] missing ${BIN_PATH}"
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "[smoke:bootstrap] ripgrep (rg) is required."
  exit 1
fi

assert_file() {
  local path="$1"
  [[ -f "${path}" ]] || {
    echo "[smoke:bootstrap] expected file not found: ${path}"
    exit 1
  }
}

assert_contains() {
  local file="$1"
  local text="$2"
  rg -n -F "${text}" "${file}" >/dev/null 2>&1 || {
    echo "[smoke:bootstrap] expected text not found in ${file}: ${text}"
    exit 1
  }
}

run_merge_case() {
  local workdir
  workdir="$(mktemp -d)"
  trap 'rm -rf "${workdir}"' RETURN

  mkdir -p "${workdir}/.cursor/hooks"
  cat > "${workdir}/.cursor/hooks/hooks.json" <<'EOF'
{"name":"custom-hooks-preserve"}
EOF

  bash "${BIN_PATH}" \
    --target-dir "${workdir}" \
    --apply-to-root-cursor \
    --apply-mode merge >/dev/null

  assert_file "${workdir}/_cursor_init/bootstrap-report.md"
  assert_file "${workdir}/_cursor_init/init-scan-mirror.md"
  assert_file "${workdir}/.cursor/commands/init-scan.md"
  assert_file "${workdir}/.cursor/rules/00-core.mdc"
  assert_file "${workdir}/.cursor/hooks/gates/config.sh"
  assert_contains "${workdir}/.cursor/hooks/hooks.json" "custom-hooks-preserve"
}

run_overwrite_case() {
  local workdir
  workdir="$(mktemp -d)"
  trap 'rm -rf "${workdir}"' RETURN

  mkdir -p "${workdir}/.cursor/hooks"
  cat > "${workdir}/.cursor/hooks/hooks.json" <<'EOF'
{"name":"custom-hooks-will-be-overwritten"}
EOF

  bash "${BIN_PATH}" \
    --target-dir "${workdir}" \
    --apply-to-root-cursor \
    --apply-mode overwrite \
    --overwrite >/dev/null

  assert_contains "${workdir}/.cursor/hooks/hooks.json" "backend:unit-test"
  assert_contains "${workdir}/_cursor_init/init-scan-mirror.md" "action_summary=overwritten"
}

run_frontend_case() {
  local workdir
  workdir="$(mktemp -d)"
  trap 'rm -rf "${workdir}"' RETURN

  bash "${BIN_PATH}" \
    --mode frontend \
    --target-dir "${workdir}" \
    --apply-to-root-cursor \
    --apply-mode merge >/dev/null

  assert_file "${workdir}/_cursor_init/bootstrap-report.md"
  assert_file "${workdir}/_cursor_init/init-scan-mirror.md"
  assert_file "${workdir}/.cursor/commands/init-scan.md"
  assert_file "${workdir}/.cursor/hooks/hooks.json"
  assert_contains "${workdir}/.cursor/hooks/hooks.json" "frontend:lint"
  assert_contains "${workdir}/_cursor_init/bootstrap-report.md" "mode=frontend"
}

run_init_scan_overwrite_and_enrich_case() {
  local workdir
  workdir="$(mktemp -d)"
  trap 'rm -rf "${workdir}"' RETURN

  bash "${BIN_PATH}" \
    --target-dir "${workdir}" \
    --init-scan-overwrite on \
    --enrich-spec-center >/dev/null

  assert_file "${workdir}/spec_center/capability-registry.md"
  assert_file "${workdir}/spec_center/_raw_contracts/README.md"
  assert_contains "${workdir}/spec_center/capability-registry.md" "Auto-generated minimal skeleton"
  assert_contains "${workdir}/spec_center/_raw_contracts/README.md" "待导入原始契约"
  assert_contains "${workdir}/_cursor_init/init-scan-mirror.md" "init_scan_overwrite=on"
  assert_contains "${workdir}/_cursor_init/init-scan-mirror.md" "enrich_spec_center=on"
}

run_merge_case
run_overwrite_case
run_frontend_case
run_init_scan_overwrite_and_enrich_case

echo "[smoke:bootstrap] PASS"
