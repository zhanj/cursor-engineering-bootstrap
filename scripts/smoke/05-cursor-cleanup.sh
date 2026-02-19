#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BOOTSTRAP_BIN="${ROOT_DIR}/bin/cursor-bootstrap"
CLEANUP_BIN="${ROOT_DIR}/bin/cursor-cleanup"

if [[ ! -f "${BOOTSTRAP_BIN}" ]]; then
  echo "[smoke:cleanup] missing ${BOOTSTRAP_BIN}"
  exit 1
fi
if [[ ! -f "${CLEANUP_BIN}" ]]; then
  echo "[smoke:cleanup] missing ${CLEANUP_BIN}"
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "[smoke:cleanup] ripgrep (rg) is required."
  exit 1
fi

assert_exists() {
  local path="$1"
  [[ -e "${path}" ]] || {
    echo "[smoke:cleanup] expected path missing: ${path}"
    exit 1
  }
}

assert_not_exists() {
  local path="$1"
  [[ ! -e "${path}" ]] || {
    echo "[smoke:cleanup] expected path to be removed: ${path}"
    exit 1
  }
}

run_case() {
  local workdir
  workdir="$(mktemp -d)"
  trap 'rm -rf "${workdir}"' RETURN

  bash "${BOOTSTRAP_BIN}" \
    --target-dir "${workdir}" \
    --enrich-spec-center \
    --init-scan-overwrite on >/dev/null

  assert_exists "${workdir}/_cursor_init"
  assert_exists "${workdir}/spec_center/capability-registry.md"
  assert_exists "${workdir}/spec_center/_raw_contracts/README.md"

  # Dry-run should keep files.
  bash "${CLEANUP_BIN}" \
    --target-dir "${workdir}" \
    --include-spec-center-placeholders >/dev/null

  assert_exists "${workdir}/_cursor_init"
  assert_exists "${workdir}/spec_center/capability-registry.md"

  # Apply should remove generated artifacts.
  bash "${CLEANUP_BIN}" \
    --target-dir "${workdir}" \
    --include-spec-center-placeholders \
    --apply >/dev/null

  assert_not_exists "${workdir}/_cursor_init"
  assert_not_exists "${workdir}/spec_center/capability-registry.md"
  assert_not_exists "${workdir}/spec_center/_raw_contracts/README.md"
}

run_case

echo "[smoke:cleanup] PASS"
