#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash install/install.sh [options]

Options:
  --repo <path>          Bootstrap repository path (default: parent of this script)
  --package-url <url>    Package archive URL (.tar.gz) to install from
  --package-sha256 <hex> Optional sha256 checksum for package verification
  --version <name>       Install version label (default: git tag/sha or timestamp)
  --install-root <path>  Install root (default: $HOME/.cursor-bootstrap)
  --bin-dir <path>       Command shim dir (default: $HOME/.local/bin)
  --force                Overwrite existing version directory
  -h, --help             Show help
EOF
}

REPO_PATH=""
PACKAGE_URL=""
PACKAGE_SHA256=""
VERSION=""
INSTALL_ROOT="${HOME}/.cursor-bootstrap"
BIN_DIR="${HOME}/.local/bin"
FORCE=0
PACKAGE_WORKDIR=""

cleanup() {
  if [[ -n "${PACKAGE_WORKDIR}" && -d "${PACKAGE_WORKDIR}" ]]; then
    rm -rf "${PACKAGE_WORKDIR}"
  fi
}
trap cleanup EXIT

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO_PATH="${2:-}"
      shift 2
      ;;
    --package-url)
      PACKAGE_URL="${2:-}"
      shift 2
      ;;
    --package-sha256)
      PACKAGE_SHA256="${2:-}"
      shift 2
      ;;
    --version)
      VERSION="${2:-}"
      shift 2
      ;;
    --install-root)
      INSTALL_ROOT="${2:-}"
      shift 2
      ;;
    --bin-dir)
      BIN_DIR="${2:-}"
      shift 2
      ;;
    --force)
      FORCE=1
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -n "${REPO_PATH}" && -n "${PACKAGE_URL}" ]]; then
  echo "Use either --repo or --package-url, not both."
  exit 1
fi

is_repo_root() {
  local path="$1"
  [[ -d "${path}/bin" && -d "${path}/templates" && -d "${path}/scripts" ]]
}

resolve_repo_from_package() {
  local workdir archive unpack
  workdir="$(mktemp -d)"
  PACKAGE_WORKDIR="${workdir}"
  archive="${workdir}/package.tgz"
  unpack="${workdir}/unpack"
  mkdir -p "${unpack}"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "${PACKAGE_URL}" -o "${archive}"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "${archive}" "${PACKAGE_URL}"
  else
    echo "Either curl or wget is required to download package archives."
    exit 1
  fi

  if [[ -n "${PACKAGE_SHA256}" ]]; then
    local actual
    if command -v shasum >/dev/null 2>&1; then
      actual="$(shasum -a 256 "${archive}" | awk '{print $1}')"
    elif command -v sha256sum >/dev/null 2>&1; then
      actual="$(sha256sum "${archive}" | awk '{print $1}')"
    else
      echo "No sha256 tool found (shasum/sha256sum)."
      exit 1
    fi
    if [[ "${actual}" != "${PACKAGE_SHA256}" ]]; then
      echo "Package checksum mismatch."
      echo "expected=${PACKAGE_SHA256}"
      echo "actual=${actual}"
      exit 1
    fi
  fi

  tar -xzf "${archive}" -C "${unpack}"

  if is_repo_root "${unpack}"; then
    REPO_PATH="${unpack}"
    return 0
  fi

  local first_dir
  first_dir="$(find "${unpack}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
  if [[ -n "${first_dir}" ]] && is_repo_root "${first_dir}"; then
    REPO_PATH="${first_dir}"
    return 0
  fi

  echo "Package does not contain a valid bootstrap repository layout."
  exit 1
}

if [[ -n "${PACKAGE_URL}" ]]; then
  resolve_repo_from_package
elif [[ -z "${REPO_PATH}" ]]; then
  REPO_PATH="$(cd "${SCRIPT_DIR}/.." && pwd)"
fi
REPO_PATH="$(cd "${REPO_PATH}" && pwd)"

if [[ ! -d "${REPO_PATH}/bin" ]]; then
  echo "Invalid repo path (bin directory missing): ${REPO_PATH}"
  exit 1
fi

if [[ -z "${VERSION}" ]]; then
  if command -v git >/dev/null 2>&1 && git -C "${REPO_PATH}" rev-parse --git-dir >/dev/null 2>&1; then
    VERSION="$(git -C "${REPO_PATH}" describe --tags --always 2>/dev/null || true)"
    if [[ -z "${VERSION}" ]]; then
      VERSION="$(git -C "${REPO_PATH}" rev-parse --short HEAD 2>/dev/null || true)"
    fi
  fi
  if [[ -z "${VERSION}" ]]; then
    VERSION="snapshot-$(date +%Y%m%d%H%M%S)"
  fi
fi

VERSION_DIR="${INSTALL_ROOT}/${VERSION}"
CURRENT_LINK="${INSTALL_ROOT}/current"

if [[ -e "${VERSION_DIR}" ]]; then
  if [[ "${FORCE}" != "1" ]]; then
    echo "Install target already exists: ${VERSION_DIR}"
    echo "Re-run with --force to overwrite."
    exit 1
  fi
  rm -rf "${VERSION_DIR}"
fi

mkdir -p "${VERSION_DIR}" "${BIN_DIR}" "${INSTALL_ROOT}"

# Keep payload minimal but enough for existing bin/* runtime.
cp -R "${REPO_PATH}/bin" "${VERSION_DIR}/"
cp -R "${REPO_PATH}/templates" "${VERSION_DIR}/"
cp -R "${REPO_PATH}/docs" "${VERSION_DIR}/"
cp -R "${REPO_PATH}/scripts" "${VERSION_DIR}/"
cp -R "${REPO_PATH}/scanner" "${VERSION_DIR}/"
for f in README.md PR_TEMPLATE.md Makefile .gitignore; do
  if [[ -f "${REPO_PATH}/${f}" ]]; then
    cp "${REPO_PATH}/${f}" "${VERSION_DIR}/${f}"
  fi
done

cat > "${VERSION_DIR}/VERSION" <<EOF
version=${VERSION}
installed_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
source_repo=${REPO_PATH}
EOF

ln -sfn "${VERSION_DIR}" "${CURRENT_LINK}"

create_shim() {
  local cmd="$1"
  local target="${BIN_DIR}/${cmd}"
  cat > "${target}" <<EOF
#!/usr/bin/env bash
set -euo pipefail
ROOT="${CURRENT_LINK}"
TARGET="\${ROOT}/bin/${cmd}"
VERSION_FILE="\${ROOT}/VERSION"

print_version() {
  echo "cursor-bootstrap command: ${cmd}"
  if [[ -f "\${VERSION_FILE}" ]]; then
    sed 's/^/  /' "\${VERSION_FILE}"
  else
    echo "  version=unknown"
    echo "  source_repo=unknown"
  fi
  echo "  shim_path=${target}"
}

run_self_check() {
  echo "[self-check] command=${cmd}"
  echo "[self-check] root=\${ROOT}"
  echo "[self-check] target=\${TARGET}"
  if [[ ! -f "\${TARGET}" ]]; then
    echo "[self-check] FAIL: missing target script"
    exit 1
  fi
  local missing=0
  for dep in bash rg; do
    if ! command -v "\${dep}" >/dev/null 2>&1; then
      echo "[self-check] WARN: missing dependency '\${dep}'"
      missing=1
    fi
  done
  if [[ "\${missing}" == "1" ]]; then
    echo "[self-check] completed with warnings"
  else
    echo "[self-check] PASS"
  fi
}

if [[ "\${1:-}" == "--version" ]]; then
  print_version
  exit 0
fi

if [[ "\${1:-}" == "--self-check" ]]; then
  run_self_check
  exit 0
fi

if [[ ! -f "\${TARGET}" ]]; then
  echo "[cursor-bootstrap installer] missing target: \${TARGET}"
  exit 1
fi
exec bash "\${TARGET}" "\$@"
EOF
  chmod +x "${target}"
}

create_tools_shim() {
  local target="${BIN_DIR}/cursor-tools"
  cat > "${target}" <<EOF
#!/usr/bin/env bash
set -euo pipefail
ROOT="${CURRENT_LINK}"
VERSION_FILE="\${ROOT}/VERSION"
BIN_DIR="${BIN_DIR}"

cmd="\${1:-}"
case "\${cmd}" in
  --version|version)
    echo "cursor-tools"
    if [[ -f "\${VERSION_FILE}" ]]; then
      sed 's/^/  /' "\${VERSION_FILE}"
    else
      echo "  version=unknown"
      echo "  source_repo=unknown"
    fi
    echo "  bin_dir=\${BIN_DIR}"
    ;;
  self-check|--self-check)
    echo "[self-check] root=\${ROOT}"
    [[ -f "\${ROOT}/bin/cursor-init" ]] || { echo "[self-check] FAIL: missing cursor-init"; exit 1; }
    [[ -f "\${ROOT}/bin/cursor-bootstrap" ]] || { echo "[self-check] FAIL: missing cursor-bootstrap"; exit 1; }
    [[ -f "\${ROOT}/bin/cursor-tune" ]] || { echo "[self-check] FAIL: missing cursor-tune"; exit 1; }
    [[ -f "\${ROOT}/bin/cursor-cleanup" ]] || { echo "[self-check] FAIL: missing cursor-cleanup"; exit 1; }
    for c in cursor-init cursor-bootstrap cursor-tune cursor-cleanup; do
      if [[ ! -x "\${BIN_DIR}/\${c}" ]]; then
        echo "[self-check] FAIL: missing shim \${BIN_DIR}/\${c}"
        exit 1
      fi
    done
    for dep in bash rg; do
      if ! command -v "\${dep}" >/dev/null 2>&1; then
        echo "[self-check] WARN: missing dependency '\${dep}'"
      fi
    done
    echo "[self-check] PASS"
    ;;
  *)
    cat <<'USAGE'
Usage:
  cursor-tools version|--version
  cursor-tools self-check|--self-check
USAGE
    exit 1
    ;;
esac
EOF
  chmod +x "${target}"
}

create_shim "cursor-init"
create_shim "cursor-bootstrap"
create_shim "cursor-tune"
create_shim "cursor-cleanup"
create_tools_shim

echo "[install] done"
echo "[install] version: ${VERSION}"
echo "[install] root: ${INSTALL_ROOT}"
echo "[install] current -> ${VERSION_DIR}"
echo "[install] shims in: ${BIN_DIR}"
echo "[install] extra command: cursor-tools (version/self-check)"
echo "[install] if commands are not found, add to PATH:"
echo "  export PATH=\"${BIN_DIR}:\$PATH\""
