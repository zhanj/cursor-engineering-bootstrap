#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash install/uninstall.sh [options]

Options:
  --install-root <path>  Install root (default: $HOME/.cursor-bootstrap)
  --bin-dir <path>       Command shim dir (default: $HOME/.local/bin)
  --remove-all           Remove all installed versions and current link
  -h, --help             Show help
EOF
}

INSTALL_ROOT="${HOME}/.cursor-bootstrap"
BIN_DIR="${HOME}/.local/bin"
REMOVE_ALL=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --install-root)
      INSTALL_ROOT="${2:-}"
      shift 2
      ;;
    --bin-dir)
      BIN_DIR="${2:-}"
      shift 2
      ;;
    --remove-all)
      REMOVE_ALL=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

for cmd in cursor-init cursor-bootstrap cursor-tune cursor-cleanup cursor-tools; do
  rm -f "${BIN_DIR}/${cmd}"
done

if [[ "${REMOVE_ALL}" == "1" ]]; then
  rm -rf "${INSTALL_ROOT}"
else
  rm -f "${INSTALL_ROOT}/current"
fi

echo "[uninstall] done"
echo "[uninstall] removed shims from: ${BIN_DIR}"
if [[ "${REMOVE_ALL}" == "1" ]]; then
  echo "[uninstall] removed install root: ${INSTALL_ROOT}"
else
  echo "[uninstall] removed current link only: ${INSTALL_ROOT}/current"
fi
