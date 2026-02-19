#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck disable=SC1091
source "${ROOT_DIR}/hooks/gates/config.sh"

MODE="${CURSOR_DEV_PATH_GATE_MODE:-warn}"
STAGE="${CURSOR_DEV_PATH_GATE_STAGE:-1}"

main_checked_re='-[[:space:]]*\[[xX]\][[:space:]]*主流程'
fast_checked_re='-[[:space:]]*\[[xX]\][[:space:]]*快速路径'

msg_warn() {
  echo "[dev-path-gate][WARN] $*" >&2
}

msg_block() {
  echo "[dev-path-gate][BLOCK] $*" >&2
}

fail_or_warn() {
  local message="$1"
  if [[ "${MODE}" == "block" ]]; then
    msg_block "${message}"
    return 1
  fi
  msg_warn "${message}"
  return 0
}

read_body() {
  local file_arg="${1:-}"
  if [[ -n "${file_arg}" ]]; then
    if [[ -f "${file_arg}" ]]; then
      ReadFile_content="$(<"${file_arg}")"
      printf "%s" "${ReadFile_content}"
      return 0
    fi
    fail_or_warn "PR body file not found: ${file_arg}" || return 1
    printf ""
    return 0
  fi

  if [[ -n "${CURSOR_PR_BODY:-}" ]]; then
    printf "%s" "${CURSOR_PR_BODY}"
    return 0
  fi

  if [[ ! -t 0 ]]; then
    cat
    return 0
  fi

  fail_or_warn "No PR body input. Pass a file path, stdin, or CURSOR_PR_BODY." || return 1
  printf ""
}

body="$(read_body "${1:-}")"

if [[ -z "${body}" ]]; then
  fail_or_warn "PR body is empty; cannot verify development path selection." || exit 1
  exit 0
fi

main_checked=0
fast_checked=0
echo "${body}" | rg -q "${main_checked_re}" && main_checked=1 || true
echo "${body}" | rg -q "${fast_checked_re}" && fast_checked=1 || true

if [[ "${main_checked}" -eq 0 && "${fast_checked}" -eq 0 ]]; then
  fail_or_warn "Missing development path selection. Check exactly one of: 主流程 / 快速路径." || exit 1
  exit 0
fi

if [[ "${main_checked}" -eq 1 && "${fast_checked}" -eq 1 ]]; then
  fail_or_warn "Both development paths are selected. Keep exactly one: 主流程 or 快速路径." || exit 1
  exit 0
fi

if [[ "${STAGE}" -lt 2 ]]; then
  echo "[dev-path-gate] PASS (stage=${STAGE}, mode=${MODE})"
  exit 0
fi

if [[ "${main_checked}" -eq 1 ]]; then
  echo "${body}" | rg -q "/bridge-implement|/speckit\.specify|/speckit\.plan|/speckit\.tasks" || {
    fail_or_warn "Main path selected but spec-kit/bridge evidence is missing." || exit 1
    exit 0
  }
fi

if [[ "${fast_checked}" -eq 1 ]]; then
  echo "${body}" | rg -q "/api-search" || {
    fail_or_warn "Fast path selected but /api-search evidence is missing." || exit 1
    exit 0
  }
  echo "${body}" | rg -q "/implement-task" || {
    fail_or_warn "Fast path selected but /implement-task evidence is missing." || exit 1
    exit 0
  }
fi

echo "[dev-path-gate] PASS (stage=${STAGE}, mode=${MODE})"
