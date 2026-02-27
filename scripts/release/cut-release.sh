#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash scripts/release/cut-release.sh --tag <vX.Y.Z> [options]

Options:
  --tag <name>           Release tag (required)
  --repo <owner/name>    GitHub repo slug (auto-detect from git remote if omitted)
  --output-dir <path>    Output directory (default: /tmp/cursor-bootstrap-pkg)
  --filename <name>      Archive filename (default: bootstrap-package.tgz)
  --title <text>         Release title (default: tag value)
  --notes <text>         Release notes (default: "Installer package release")
  --draft                Create as draft release
  --skip-publish         Only package, do not upload to GitHub Release
  -h, --help             Show help
EOF
}

TAG=""
REPO_SLUG=""
OUTPUT_DIR="/tmp/cursor-bootstrap-pkg"
FILENAME="bootstrap-package.tgz"
TITLE=""
NOTES="Installer package release"
DRAFT=0
SKIP_PUBLISH=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag)
      TAG="${2:-}"
      shift 2
      ;;
    --repo)
      REPO_SLUG="${2:-}"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="${2:-}"
      shift 2
      ;;
    --filename)
      FILENAME="${2:-}"
      shift 2
      ;;
    --title)
      TITLE="${2:-}"
      shift 2
      ;;
    --notes)
      NOTES="${2:-}"
      shift 2
      ;;
    --draft)
      DRAFT=1
      shift
      ;;
    --skip-publish)
      SKIP_PUBLISH=1
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

if [[ -z "${TAG}" ]]; then
  echo "--tag is required"
  usage
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ARCHIVE_PATH="${OUTPUT_DIR}/${FILENAME}"
SHA_PATH="${ARCHIVE_PATH}.sha256"

infer_repo_slug() {
  local remote_url
  remote_url="$(git -C "${ROOT_DIR}" remote get-url origin 2>/dev/null || true)"
  if [[ -z "${remote_url}" ]]; then
    return 1
  fi

  # git@github.com:owner/repo.git
  if [[ "${remote_url}" =~ ^git@github\.com:([^/]+)/([^/]+)(\.git)?$ ]]; then
    echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]%.git}"
    return 0
  fi

  # https://github.com/owner/repo.git
  if [[ "${remote_url}" =~ ^https://github\.com/([^/]+)/([^/]+)(\.git)?$ ]]; then
    echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]%.git}"
    return 0
  fi

  return 1
}

if [[ -z "${REPO_SLUG}" ]]; then
  REPO_SLUG="$(infer_repo_slug || true)"
fi

echo "[cut-release] packaging ${TAG} ..."
bash "${ROOT_DIR}/scripts/release/package.sh" \
  --output-dir "${OUTPUT_DIR}" \
  --filename "${FILENAME}" \
  --version "${TAG}"

if [[ "${SKIP_PUBLISH}" == "0" ]]; then
  echo "[cut-release] publishing ${TAG} ..."
  declare -a PUBLISH_CMD=(bash "${ROOT_DIR}/scripts/release/publish.sh" --tag "${TAG}" --archive "${ARCHIVE_PATH}" --notes "${NOTES}")
  if [[ -n "${TITLE}" ]]; then
    PUBLISH_CMD+=(--title "${TITLE}")
  fi
  if [[ -n "${REPO_SLUG}" ]]; then
    PUBLISH_CMD+=(--repo "${REPO_SLUG}")
  fi
  if [[ "${DRAFT}" == "1" ]]; then
    PUBLISH_CMD+=(--draft)
  fi
  "${PUBLISH_CMD[@]}"
fi

if [[ -n "${REPO_SLUG}" ]]; then
  PACKAGE_URL="https://github.com/${REPO_SLUG}/releases/download/${TAG}/${FILENAME}"
else
  PACKAGE_URL="https://github.com/<owner>/<repo>/releases/download/${TAG}/${FILENAME}"
fi

echo
echo "=== Release Outputs ==="
echo "Tag: ${TAG}"
echo "Archive: ${ARCHIVE_PATH}"
echo "SHA256 file: ${SHA_PATH}"
echo "SHA256: $(<"${SHA_PATH}")"
echo "Package URL: ${PACKAGE_URL}"
echo
echo "Install command (macOS/Linux):"
echo "bash install/install.sh --package-url \"${PACKAGE_URL}\""
echo
echo "Install command (WSL):"
echo "bash install/install.sh --package-url \"${PACKAGE_URL}\""
