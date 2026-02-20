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

  mkdir -p "${workdir}/module-a/src/main/java/com/acme/controller" "${workdir}/doc/sql" "${workdir}/.cursor/hooks/gates"
  printf "<project/>" > "${workdir}/pom.xml"
  printf "<project/>" > "${workdir}/module-a/pom.xml"
  printf "<settings/>" > "${workdir}/settings-custom.xml"
  cat > "${workdir}/.cursor/hooks/hooks.json" <<'EOF'
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

  bash "${TUNE_BIN}" --target-dir "${workdir}" --dry-run >/dev/null
  assert_file "${workdir}/_cursor_init/tune-report.md"
  assert_file "${workdir}/_cursor_init/tune.diff"
  assert_contains "${workdir}/_cursor_init/tune-report.md" "dry_run: yes"
  assert_contains "${workdir}/_cursor_init/tune.diff" "x-generated-by: cursor-tune"
  assert_contains "${workdir}/.cursor/hooks/hooks.json" "\"run\": \"mvn -q test\""

  bash "${TUNE_BIN}" --target-dir "${workdir}" --mode aggressive >/dev/null
  assert_contains "${workdir}/.cursor/hooks/hooks.json" "-s settings-custom.xml"
  assert_contains "${workdir}/.cursor/hooks/gates/config.sh" "doc/sql/"
  assert_file "${workdir}/_cursor_init/tune-report.md"
  assert_file "${workdir}/_cursor_init/tune.diff"
}

run_case

echo "[smoke:tune] PASS"
