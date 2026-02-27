#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash scripts/release/package.sh [options]

Options:
  --output-dir <path>   Output directory (default: /tmp/cursor-bootstrap-pkg)
  --filename <name>     Archive filename (default: bootstrap-package.tgz)
  --version <label>     Optional version label written to metadata file
  -h, --help            Show help
EOF
}

OUTPUT_DIR="/tmp/cursor-bootstrap-pkg"
FILENAME="bootstrap-package.tgz"
VERSION_LABEL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-dir)
      OUTPUT_DIR="${2:-}"
      shift 2
      ;;
    --filename)
      FILENAME="${2:-}"
      shift 2
      ;;
    --version)
      VERSION_LABEL="${2:-}"
      shift 2
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

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ARCHIVE_PATH="${OUTPUT_DIR}/${FILENAME}"
SHA_PATH="${ARCHIVE_PATH}.sha256"
META_PATH="${OUTPUT_DIR}/package-metadata.txt"

mkdir -p "${OUTPUT_DIR}"

tar -czf "${ARCHIVE_PATH}" -C "${ROOT_DIR}" \
  bin templates docs scripts scanner install README.md PR_TEMPLATE.md Makefile .gitignore

if command -v shasum >/dev/null 2>&1; then
  shasum -a 256 "${ARCHIVE_PATH}" | awk '{print $1}' > "${SHA_PATH}"
elif command -v sha256sum >/dev/null 2>&1; then
  sha256sum "${ARCHIVE_PATH}" | awk '{print $1}' > "${SHA_PATH}"
else
  echo "No sha256 tool found (shasum/sha256sum)."
  exit 1
fi

if [[ -z "${VERSION_LABEL}" ]]; then
  if command -v git >/dev/null 2>&1 && git -C "${ROOT_DIR}" rev-parse --git-dir >/dev/null 2>&1; then
    VERSION_LABEL="$(git -C "${ROOT_DIR}" describe --tags --always 2>/dev/null || git -C "${ROOT_DIR}" rev-parse --short HEAD)"
  else
    VERSION_LABEL="snapshot-$(date +%Y%m%d%H%M%S)"
  fi
fi

cat > "${META_PATH}" <<EOF
version=${VERSION_LABEL}
archive=${ARCHIVE_PATH}
sha256_file=${SHA_PATH}
created_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF

echo "[package] done"
echo "[package] archive: ${ARCHIVE_PATH}"
echo "[package] sha256: $(<"${SHA_PATH}")"
echo "[package] metadata: ${META_PATH}"
