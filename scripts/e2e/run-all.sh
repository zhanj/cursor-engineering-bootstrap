#!/usr/bin/env bash
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

declare -a STEPS=(
  "01-dev-path-flow.sh|backend dev-path flow"
)

echo "[e2e] start"
for entry in "${STEPS[@]}"; do
  script="${entry%%|*}"
  label="${entry##*|}"
  script_path="${ROOT_DIR}/scripts/e2e/${script}"

  echo "[e2e] running: ${label}"
  bash "${script_path}"
  rc=$?
  if [[ "${rc}" -ne 0 ]]; then
    echo
    echo "[e2e] FAIL"
    echo "- failed step: ${label}"
    echo "- script: ${script_path}"
    echo "- exit code: ${rc}"
    echo "- rerun this step: bash \"${script_path}\""
    echo "- rerun all: bash \"${ROOT_DIR}/scripts/e2e/run-all.sh\""
    exit "${rc}"
  fi
done

echo "[e2e] all checks passed"
