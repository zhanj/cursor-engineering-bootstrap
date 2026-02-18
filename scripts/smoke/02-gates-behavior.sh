#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GATES_SRC="${ROOT_DIR}/templates/backend/.cursor/hooks/gates"

if [[ ! -d "${GATES_SRC}" ]]; then
  echo "[smoke:gates] missing gates source: ${GATES_SRC}"
  exit 1
fi

assert_exit_eq() {
  local got="$1"
  local want="$2"
  local name="$3"
  [[ "${got}" == "${want}" ]] || {
    echo "[smoke:gates] ${name} expected exit ${want}, got ${got}"
    exit 1
  }
}

run_contract_case() {
  local mode="$1"
  local with_openapi="$2"
  local expected="$3"
  local name="contract:${mode}:openapi=${with_openapi}"
  local workdir
  workdir="$(mktemp -d)"
  trap 'rm -rf "${workdir}"' RETURN

  mkdir -p "${workdir}/.cursor/hooks"
  cp -R "${GATES_SRC}" "${workdir}/.cursor/hooks/"

  (
    cd "${workdir}"
    git init -q
    git config user.email "smoke@example.com"
    git config user.name "smoke"

    mkdir -p src/main/java/com/acme/controller
    printf "class DemoController {}\n" > src/main/java/com/acme/controller/DemoController.java
    git add src/main/java/com/acme/controller/DemoController.java

    if [[ "${with_openapi}" == "yes" ]]; then
      mkdir -p contracts
      printf "openapi: 3.0.0\ninfo:\n  title: test\n  version: '1.0.0'\npaths: {}\n" > contracts/openapi.yaml
      git add contracts/openapi.yaml
    fi

    set +e
    CURSOR_CONTRACT_GATE_MODE="${mode}" bash .cursor/hooks/gates/contract-check.sh >/dev/null 2>&1
    rc=$?
    set -e
    assert_exit_eq "${rc}" "${expected}" "${name}"
  )
}

run_db_case() {
  local mode="$1"
  local change_type="$2"
  local expected="$3"
  local name="db:${mode}:${change_type}"
  local workdir
  workdir="$(mktemp -d)"
  trap 'rm -rf "${workdir}"' RETURN

  mkdir -p "${workdir}/.cursor/hooks"
  cp -R "${GATES_SRC}" "${workdir}/.cursor/hooks/"

  (
    cd "${workdir}"
    git init -q
    git config user.email "smoke@example.com"
    git config user.name "smoke"

    case "${change_type}" in
      migration_only)
        mkdir -p src/main/resources/db/migration
        printf "ALTER TABLE user_account ADD COLUMN nickname varchar(50);\n" > src/main/resources/db/migration/V1__add_nickname.sql
        git add src/main/resources/db/migration/V1__add_nickname.sql
        ;;
      persist_only)
        mkdir -p src/main/java/com/acme/repository
        printf "interface UserRepository {}\n" > src/main/java/com/acme/repository/UserRepository.java
        git add src/main/java/com/acme/repository/UserRepository.java
        ;;
      *)
        echo "[smoke:gates] unknown db case: ${change_type}"
        exit 1
        ;;
    esac

    set +e
    CURSOR_DB_GATE_MODE="${mode}" bash .cursor/hooks/gates/db-change-check.sh >/dev/null 2>&1
    rc=$?
    set -e
    assert_exit_eq "${rc}" "${expected}" "${name}"
  )
}

run_no_change_case() {
  local workdir
  workdir="$(mktemp -d)"
  trap 'rm -rf "${workdir}"' RETURN

  mkdir -p "${workdir}/.cursor/hooks"
  cp -R "${GATES_SRC}" "${workdir}/.cursor/hooks/"

  (
    cd "${workdir}"
    git init -q
    git config user.email "smoke@example.com"
    git config user.name "smoke"

    set +e
    CURSOR_CONTRACT_GATE_MODE=block bash .cursor/hooks/gates/contract-check.sh >/dev/null 2>&1
    rc1=$?
    CURSOR_DB_GATE_MODE=block bash .cursor/hooks/gates/db-change-check.sh >/dev/null 2>&1
    rc2=$?
    set -e

    assert_exit_eq "${rc1}" "0" "contract:no_changes"
    assert_exit_eq "${rc2}" "0" "db:no_changes"
  )
}

run_contract_case block no 2
run_contract_case warn no 0
run_contract_case block yes 0

run_db_case block migration_only 2
run_db_case warn migration_only 0
run_db_case block persist_only 2

run_no_change_case

echo "[smoke:gates] PASS"
