#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEST_HOME="$(mktemp -d)"
cleanup() {
  rm -rf "${TEST_HOME}"
}
trap cleanup EXIT

echo "[smoke:installers] test home: ${TEST_HOME}"

# shell scripts should parse
bash -n "${ROOT_DIR}/install/install.sh"
bash -n "${ROOT_DIR}/install/uninstall.sh"

# install in isolated HOME
HOME="${TEST_HOME}" bash "${ROOT_DIR}/install/install.sh" \
  --repo "${ROOT_DIR}" \
  --version "smoke-installer" \
  --force >/dev/null

# verify shims exist
for cmd in cursor-init cursor-bootstrap cursor-tune cursor-cleanup cursor-tools; do
  [[ -x "${TEST_HOME}/.local/bin/${cmd}" ]] || {
    echo "[smoke:installers] missing shim: ${cmd}"
    exit 1
  }
done

# verify version and self-check
HOME="${TEST_HOME}" "${TEST_HOME}/.local/bin/cursor-tools" --version >/dev/null
HOME="${TEST_HOME}" "${TEST_HOME}/.local/bin/cursor-tools" self-check >/dev/null
HOME="${TEST_HOME}" "${TEST_HOME}/.local/bin/cursor-bootstrap" --version >/dev/null

# uninstall and verify cleanup
HOME="${TEST_HOME}" bash "${ROOT_DIR}/install/uninstall.sh" --remove-all >/dev/null
[[ ! -e "${TEST_HOME}/.cursor-bootstrap" ]] || {
  echo "[smoke:installers] install root still exists after uninstall"
  exit 1
}

# package-url mode
PKG_DIR="$(mktemp -d)"
PKG_FILE="${PKG_DIR}/bootstrap-package.tgz"
tar -czf "${PKG_FILE}" -C "${ROOT_DIR}" \
  bin templates docs scripts scanner install README.md PR_TEMPLATE.md Makefile .gitignore
HOME="${TEST_HOME}" bash "${ROOT_DIR}/install/install.sh" \
  --package-url "file://${PKG_FILE}" \
  --version "smoke-package" \
  --force >/dev/null
HOME="${TEST_HOME}" "${TEST_HOME}/.local/bin/cursor-tools" self-check >/dev/null
HOME="${TEST_HOME}" bash "${ROOT_DIR}/install/uninstall.sh" --remove-all >/dev/null
rm -rf "${PKG_DIR}"

# WSL-first windows wrappers should exist and include wsl call
[[ -f "${ROOT_DIR}/install/install.ps1" ]] || exit 1
[[ -f "${ROOT_DIR}/install/uninstall.ps1" ]] || exit 1
rg -q "wsl bash -lc" "${ROOT_DIR}/install/install.ps1"
rg -q "wsl bash -lc" "${ROOT_DIR}/install/uninstall.ps1"

echo "[smoke:installers] PASS"
