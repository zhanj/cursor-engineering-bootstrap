#!/usr/bin/env bash
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

declare -a STEPS=(
  "01-cursor-init-outputs.sh|cursor-init outputs"
  "02-gates-behavior.sh|gates behavior"
  "03-template-integrity.sh|template integrity"
  "04-cursor-bootstrap.sh|cursor-bootstrap flow"
)

echo "[smoke] start"
for entry in "${STEPS[@]}"; do
  script="${entry%%|*}"
  label="${entry##*|}"
  script_path="${ROOT_DIR}/scripts/smoke/${script}"

  echo "[smoke] running: ${label}"
  bash "${script_path}"
  rc=$?
  if [[ "${rc}" -ne 0 ]]; then
    echo
    echo "[smoke] FAIL"
    echo "- failed step: ${label}"
    echo "- script: ${script_path}"
    echo "- exit code: ${rc}"
    echo "- rerun this step: bash \"${script_path}\""
    echo "- rerun all: bash \"${ROOT_DIR}/scripts/smoke/run-all.sh\""
    exit "${rc}"
  fi
done

echo "[smoke] all checks passed"
