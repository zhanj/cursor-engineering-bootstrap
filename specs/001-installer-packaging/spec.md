# Spec: Cross-platform Installer Packaging and Version Consistency

## Why
The current onboarding requires each developer to copy the bootstrap repository locally, which causes version drift and inconsistent usage. We need a standardized installation path with explicit version visibility and reproducible upgrade/rollback guidance.

## Scope
- Build an installer layer for macOS/Linux and Windows (WSL2-first).
- Keep existing `bin/cursor-init|cursor-bootstrap|cursor-tune|cursor-cleanup` behavior compatible.
- Add version-consistency capabilities and installation verification guidance.

## Functional Requirements

### FR-1 Cross-platform installation entrypoints
- Provide an installer for macOS/Linux (`install.sh`) and Windows (`install.ps1`).
- Installers must make command entrypoints available from PATH.

### FR-2 Stable command entrypoints
- After install, users can run `cursor-init`, `cursor-bootstrap`, `cursor-tune`, `cursor-cleanup` without copying the whole repo manually.

### FR-3 Version visibility
- Installed tooling must expose version/source information (`--version` or equivalent).
- Version output must be sufficient for support triage.

### FR-4 Upgrade/rollback path
- Provide documented and executable upgrade and rollback steps.
- Keep previous known-good version recoverable.

### FR-5 Compatibility with current workflows
- Existing training flows and command semantics remain valid.
- No breaking change to current target-repo outputs.

### FR-6 Verification
- Provide a post-install self-check command set for environment and command availability.

## Non-goals
- No private pack system in this phase.
- No full rewrite into a new implementation language in this phase.
- No cloud-hosted control plane.

## Acceptance Criteria
- A developer on macOS/Linux can complete install and run the four commands.
- A developer on Windows (WSL2-first) can complete install and run the four commands.
- `--version` (or equivalent) returns expected release information.
- Smoke/E2E continue to pass with installer layer introduced.
