#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TUNE_BIN="${ROOT_DIR}/bin/cursor-tune"

if [[ ! -f "${TUNE_BIN}" ]]; then
  echo "[smoke:tune] missing ${TUNE_BIN}"
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "[smoke:tune] ripgrep (rg) is required."
  exit 1
fi

assert_file() {
  local path="$1"
  [[ -f "${path}" ]] || {
    echo "[smoke:tune] expected file not found: ${path}"
    exit 1
  }
}

assert_contains() {
  local file="$1"
  local text="$2"
  rg -n -F -- "${text}" "${file}" >/dev/null 2>&1 || {
    echo "[smoke:tune] expected text not found in ${file}: ${text}"
    exit 1
  }
}

run_case() {
  local workdir
  workdir="$(mktemp -d)"
  trap 'rm -rf "${workdir}"' RETURN

  local project_dir="${workdir}/ehs-clnt-hazard-parent-runenv"
  mkdir -p "${project_dir}/module-a/src/main/java/com/acme/controller" "${project_dir}/doc/sql" "${project_dir}/.cursor/hooks/gates"
  printf "<project/>" > "${project_dir}/pom.xml"
  printf "<project/>" > "${project_dir}/module-a/pom.xml"
  printf "class UserController {}" > "${project_dir}/module-a/src/main/java/com/acme/controller/UserController.java"
  printf "create table t(id bigint);" > "${project_dir}/doc/sql/V1__init.sql"
  printf "<settings/>" > "${project_dir}/settings-custom.xml"
  cat > "${project_dir}/.cursor/hooks/hooks.json" <<'EOF'
{
  "version": 1,
  "hooks": [
    {
      "name": "backend:unit-test",
      "when": "pre_commit",
      "run": "mvn -q test"
    }
  ]
}
EOF

  bash "${TUNE_BIN}" --target-dir "${project_dir}" --dry-run >/dev/null
  assert_file "${project_dir}/_cursor_init/tune-report.md"
  assert_file "${project_dir}/_cursor_init/tune.diff"
  assert_file "${project_dir}/_cursor_init/project-inventory.md"
  assert_contains "${project_dir}/_cursor_init/tune-report.md" "dry_run: yes"
  assert_contains "${project_dir}/_cursor_init/tune-report.md" "modules_detected:"
  assert_contains "${project_dir}/_cursor_init/project-inventory.md" "API Candidate Files"
  assert_contains "${project_dir}/_cursor_init/tune.diff" "x-generated-by: cursor-tune"
  assert_contains "${project_dir}/.cursor/hooks/hooks.json" "\"run\": \"mvn -q test\""

  bash "${TUNE_BIN}" --target-dir "${project_dir}" --mode aggressive >/dev/null
  assert_contains "${project_dir}/.cursor/hooks/hooks.json" "-s settings-custom.xml"
  assert_contains "${project_dir}/.cursor/hooks/gates/config.sh" "doc/sql/"
  assert_contains "${project_dir}/spec_center/capability-registry.md" "OwnerType 定义（必须）"
  assert_contains "${project_dir}/spec_center/capability-registry.md" "internal-self"
  assert_contains "${project_dir}/spec_center/capability-registry.md" "/api-search 推荐检索顺序（必须）"
  assert_contains "${project_dir}/spec_center/capability-registry.md" "source="
  assert_file "${project_dir}/bin/cursor-tune"
  assert_file "${project_dir}/bin/cursor-bootstrap"
  assert_file "${project_dir}/bin/cursor-cleanup"
  assert_file "${project_dir}/.cursor/rules/98-repo-scan-index.mdc"
  assert_contains "${project_dir}/.cursor/rules/00-core.mdc" "scan-derived-priority"
  assert_contains "${project_dir}/.cursor/commands/api-search.md" "scan-derived-search"
  assert_contains "${project_dir}/.cursor/commands/bridge-implement.md" "scan-derived-bridge"
  assert_contains "${project_dir}/.cursor/commands/init-scan.md" "scan-derived-init-scan"
  assert_contains "${project_dir}/spec_center/ehs-clnt-hazard-parent-runenv/contracts/openapi.yaml" "x-inventory:"
  assert_contains "${project_dir}/spec_center/ehs-clnt-hazard-parent-runenv/contracts/openapi.yaml" "x-capability-links:"
  assert_contains "${project_dir}/spec_center/ehs-clnt-hazard-parent-runenv/contracts/openapi.yaml" "operationId:"
  assert_file "${project_dir}/spec_center/ehs-clnt-hazard-parent-runenv/spec.md"
  assert_contains "${project_dir}/spec_center/ehs-clnt-hazard-parent-runenv/spec.md" "Capability 联动映射（关键）"
  assert_contains "${project_dir}/spec_center/ehs-clnt-hazard-parent-runenv/spec.md" "openapi.yaml"
  if [[ -d "${project_dir}/spec_center/ehs-clnt-hazard-parent-runenv-" ]]; then
    echo "[smoke:tune] unexpected trailing-hyphen service directory"
    exit 1
  fi
  assert_file "${project_dir}/_cursor_init/tune-report.md"
  assert_file "${project_dir}/_cursor_init/tune.diff"
}

run_frontend_case() {
  local workdir
  workdir="$(mktemp -d)"
  trap 'rm -rf "${workdir}"' RETURN

  local project_dir="${workdir}/ehs-fe-portal"
  mkdir -p "${project_dir}/src/api" "${project_dir}/src/pages/hazard" "${project_dir}/src/routes" "${project_dir}/.cursor/hooks/gates"
  cat > "${project_dir}/package.json" <<'EOF'
{
  "name": "ehs-fe-portal",
  "scripts": {
    "lint": "echo lint"
  }
}
EOF
  printf "export async function listHazards(){}" > "${project_dir}/src/api/hazard.ts"
  printf "export default function HazardPage(){}" > "${project_dir}/src/pages/hazard/index.tsx"
  printf "export const routes = []" > "${project_dir}/src/routes/router.ts"

  bash "${TUNE_BIN}" --target-dir "${project_dir}" --mode aggressive >/dev/null
  assert_contains "${project_dir}/_cursor_init/tune-report.md" "scan_stack: frontend"
  assert_contains "${project_dir}/spec_center/capability-registry.md" "/page/"
  assert_contains "${project_dir}/spec_center/ehs-fe-portal/contracts/openapi.yaml" "x-capability-links:"
  assert_contains "${project_dir}/.cursor/hooks/hooks.json" "frontend:lint"
  assert_contains "${project_dir}/.cursor/rules/98-repo-scan-index.mdc" "frontend_api_candidates_detected:"
  assert_file "${project_dir}/bin/cursor-tune"
  assert_file "${project_dir}/spec_center/ehs-fe-portal/spec.md"
}

run_case
run_frontend_case

echo "[smoke:tune] PASS"
