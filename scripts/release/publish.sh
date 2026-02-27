#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash scripts/release/publish.sh --tag <vX.Y.Z> [options]

Options:
  --tag <name>           Release tag (required)
  --archive <path>       Archive path (default: /tmp/cursor-bootstrap-pkg/bootstrap-package.tgz)
  --sha-file <path>      Optional sha file (default: <archive>.sha256 if exists)
  --title <text>         Release title (default: tag value)
  --notes <text>         Release notes (default: "Installer package release")
  --repo <owner/name>    Override GitHub repo for gh CLI
  --draft                Create/view draft release
  -h, --help             Show help
EOF
}

TAG=""
ARCHIVE="/tmp/cursor-bootstrap-pkg/bootstrap-package.tgz"
SHA_FILE=""
TITLE=""
NOTES="Installer package release"
REPO=""
DRAFT=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag)
      TAG="${2:-}"
      shift 2
      ;;
    --archive)
      ARCHIVE="${2:-}"
      shift 2
      ;;
    --sha-file)
      SHA_FILE="${2:-}"
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
    --repo)
      REPO="${2:-}"
      shift 2
      ;;
    --draft)
      DRAFT=1
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
if [[ ! -f "${ARCHIVE}" ]]; then
  echo "Archive not found: ${ARCHIVE}"
  exit 1
fi
if [[ -z "${SHA_FILE}" && -f "${ARCHIVE}.sha256" ]]; then
  SHA_FILE="${ARCHIVE}.sha256"
fi
if [[ -n "${SHA_FILE}" && ! -f "${SHA_FILE}" ]]; then
  echo "SHA file not found: ${SHA_FILE}"
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI is required. Install it first (e.g. brew install gh)."
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "gh CLI is not authenticated. Run: gh auth login"
  exit 1
fi

if [[ -z "${TITLE}" ]]; then
  TITLE="${TAG}"
fi

declare -a GH_BASE=()
if [[ -n "${REPO}" ]]; then
  GH_BASE+=(--repo "${REPO}")
fi

if gh "${GH_BASE[@]}" release view "${TAG}" >/dev/null 2>&1; then
  echo "[publish] release exists: ${TAG}"
else
  declare -a CREATE_CMD=(gh "${GH_BASE[@]}" release create "${TAG}" "${ARCHIVE}" --title "${TITLE}" --notes "${NOTES}")
  if [[ "${DRAFT}" == "1" ]]; then
    CREATE_CMD+=(--draft)
  fi
  "${CREATE_CMD[@]}"
  # If archive was attached at create, skip re-upload path below.
  if [[ -n "${SHA_FILE}" ]]; then
    gh "${GH_BASE[@]}" release upload "${TAG}" "${SHA_FILE}" --clobber
  fi
  echo "[publish] created release and uploaded assets"
  exit 0
fi

gh "${GH_BASE[@]}" release upload "${TAG}" "${ARCHIVE}" --clobber
if [[ -n "${SHA_FILE}" ]]; then
  gh "${GH_BASE[@]}" release upload "${TAG}" "${SHA_FILE}" --clobber
fi

echo "[publish] uploaded assets to existing release: ${TAG}"
