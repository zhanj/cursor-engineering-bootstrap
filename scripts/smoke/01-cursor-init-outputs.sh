#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BIN_PATH="${ROOT_DIR}/bin/cursor-init"

if [[ ! -f "${BIN_PATH}" ]]; then
  echo "[smoke:init] missing ${BIN_PATH}"
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "[smoke:init] ripgrep (rg) is required."
  exit 1
fi

assert_file() {
  local path="$1"
  [[ -f "${path}" ]] || {
    echo "[smoke:init] expected file not found: ${path}"
    exit 1
  }
}

assert_dir() {
  local path="$1"
  [[ -d "${path}" ]] || {
    echo "[smoke:init] expected directory not found: ${path}"
    exit 1
  }
}

assert_contains() {
  local file="$1"
  local pattern="$2"
  rg -n "${pattern}" "${file}" >/dev/null 2>&1 || {
    echo "[smoke:init] pattern not found in ${file}: ${pattern}"
    exit 1
  }
}

run_mode() {
  local mode="$1"
  local workdir
  workdir="$(mktemp -d)"
  trap 'rm -rf "${workdir}"' RETURN

  echo "[smoke:init] running dry-run for mode=${mode}"
  (
    cd "${workdir}"
    bash "${BIN_PATH}" dry-run --mode "${mode}" --use-current-dir >/dev/null
  )

  assert_file "${workdir}/_cursor_init/report.md"
  assert_file "${workdir}/_cursor_init/proposed_tree.md"
  assert_file "${workdir}/_cursor_init/apply_plan.md"
  assert_file "${workdir}/_cursor_init/hooks.suggested.json"
  assert_file "${workdir}/_cursor_init/cursor-bootstrap-readme.md"
  assert_file "${workdir}/bin/cursor-tune"
  assert_file "${workdir}/bin/cursor-bootstrap"
  assert_file "${workdir}/bin/cursor-cleanup"
  assert_contains "${workdir}/bin/cursor-tune" "managed-by: cursor-bootstrap-wrapper"
  assert_contains "${workdir}/bin/cursor-tune" "CURSOR_BOOTSTRAP_REPO"

  assert_contains "${workdir}/_cursor_init/report.md" "项目识别"

  python3 -m json.tool "${workdir}/_cursor_init/hooks.suggested.json" >/dev/null

  echo "[smoke:init] running bundle for mode=${mode}"
  (
    cd "${workdir}"
    bash "${BIN_PATH}" bundle --mode "${mode}" --use-current-dir >/dev/null
  )

  assert_dir "${workdir}/_cursor_init/patch_bundle/${mode}"
  assert_file "${workdir}/_cursor_init/patch_bundle/${mode}/docs/speckit-constitution-prompt.md"
  assert_file "${workdir}/_cursor_init/patch_bundle/${mode}/docs/cursor-bootstrap-readme.md"
}

run_mode backend
run_mode frontend
run_mode spec_center

echo "[smoke:init] PASS"
