#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BIN_PATH="${ROOT_DIR}/bin/cursor-init"

if [[ ! -f "${BIN_PATH}" ]]; then
  echo "[e2e:init-scan] missing ${BIN_PATH}"
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "[e2e:init-scan] ripgrep (rg) is required."
  exit 1
fi

assert_file() {
  local path="$1"
  [[ -f "${path}" ]] || {
    echo "[e2e:init-scan] expected file not found: ${path}"
    exit 1
  }
}

assert_contains() {
  local file="$1"
  local text="$2"
  rg -n -F "${text}" "${file}" >/dev/null 2>&1 || {
    echo "[e2e:init-scan] expected text not found in ${file}: ${text}"
    exit 1
  }
}

workdir="$(mktemp -d "${TMPDIR:-/tmp}/cursor-e2e-init-scan.XXXXXX")"
project_dir="${workdir}/demo-init-scan-backend"

cleanup() {
  if [[ "${E2E_KEEP_WORKDIR:-0}" == "1" ]]; then
    echo "[e2e:init-scan] keep workdir: ${workdir}"
    return
  fi
  rm -rf "${workdir}"
}
trap cleanup EXIT

mkdir -p "${project_dir}"
cat >"${project_dir}/README.md" <<'EOF'
# demo-init-scan-backend
Brownfield sample project for init-scan E2E.
EOF

echo "[e2e:init-scan] step 1/5: bootstrap backend sample"
bash "${BIN_PATH}" dry-run --mode backend --target-dir "${project_dir}" >/dev/null
bash "${BIN_PATH}" bundle --mode backend --target-dir "${project_dir}" >/dev/null
rsync -a "${project_dir}/_cursor_init/patch_bundle/backend/" "${project_dir}/"

init_scan_file="${project_dir}/.cursor/commands/init-scan.md"
assert_file "${init_scan_file}"

echo "[e2e:init-scan] step 2/5: validate init-scan command contract"
assert_contains "${init_scan_file}" "校准模型（三层）"
assert_contains "${init_scan_file}" "Spec 资产状态"
assert_contains "${init_scan_file}" "Constitution 状态"
assert_contains "${init_scan_file}" "覆盖开关状态"
assert_contains "${init_scan_file}" "overwrite=off"
assert_contains "${init_scan_file}" "overwrite=on"
assert_contains "${init_scan_file}" "exists"
assert_contains "${init_scan_file}" "missing"

status_report="${project_dir}/_cursor_init/init-scan-e2e-status.md"

scan_init_state() {
  local overwrite="$1"
  local spec_registry_path="${project_dir}/spec_center/capability-registry.md"
  local openapi_path="${project_dir}/spec_center/demo/contracts/openapi.yaml"
  local constitution_path="${project_dir}/.specify/memory/constitution.md"

  local capability_state="missing"
  local openapi_state="missing"
  local constitution_state="missing"
  local spec_action="created"
  local constitution_action="created"

  [[ -f "${spec_registry_path}" ]] && capability_state="exists"
  [[ -f "${openapi_path}" ]] && openapi_state="exists"
  [[ -f "${constitution_path}" ]] && constitution_state="exists"

  if [[ "${overwrite}" == "off" ]]; then
    [[ "${capability_state}" == "exists" && "${openapi_state}" == "exists" ]] && spec_action="skipped"
    [[ "${constitution_state}" == "exists" ]] && constitution_action="skipped"
  else
    [[ "${capability_state}" == "exists" || "${openapi_state}" == "exists" ]] && spec_action="overwritten"
    [[ "${constitution_state}" == "exists" ]] && constitution_action="overwritten"
  fi

  {
    echo "overwrite=${overwrite}"
    echo "capability-registry=${capability_state}"
    echo "openapi=${openapi_state}"
    echo "constitution=${constitution_state}"
    echo "spec_action=${spec_action}"
    echo "constitution_action=${constitution_action}"
  } >"${status_report}"
}

echo "[e2e:init-scan] step 3/5: missing assets + overwrite=off => created"
rm -rf "${project_dir}/spec_center" "${project_dir}/.specify"
scan_init_state off
assert_contains "${status_report}" "overwrite=off"
assert_contains "${status_report}" "capability-registry=missing"
assert_contains "${status_report}" "openapi=missing"
assert_contains "${status_report}" "constitution=missing"
assert_contains "${status_report}" "spec_action=created"
assert_contains "${status_report}" "constitution_action=created"

echo "[e2e:init-scan] step 4/5: existing assets + overwrite=off => skipped"
mkdir -p "${project_dir}/spec_center/demo/contracts" "${project_dir}/.specify/memory"
cat >"${project_dir}/spec_center/capability-registry.md" <<'EOF'
# capability registry placeholder
EOF
cat >"${project_dir}/spec_center/demo/contracts/openapi.yaml" <<'EOF'
openapi: 3.0.0
info:
  title: demo
  version: 0.0.1
paths: {}
EOF
cat >"${project_dir}/.specify/memory/constitution.md" <<'EOF'
# constitution placeholder
EOF

scan_init_state off
assert_contains "${status_report}" "capability-registry=exists"
assert_contains "${status_report}" "openapi=exists"
assert_contains "${status_report}" "constitution=exists"
assert_contains "${status_report}" "spec_action=skipped"
assert_contains "${status_report}" "constitution_action=skipped"

echo "[e2e:init-scan] step 5/5: existing assets + overwrite=on => overwritten"
scan_init_state on
assert_contains "${status_report}" "overwrite=on"
assert_contains "${status_report}" "spec_action=overwritten"
assert_contains "${status_report}" "constitution_action=overwritten"

echo "[e2e:init-scan] PASS: init-scan mirror flow end-to-end"
