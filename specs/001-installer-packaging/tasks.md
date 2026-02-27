# Tasks: Cross-platform Installer Packaging

## Phase 1 - Installer foundation
- [x] Create `install/install.sh` for macOS/Linux install flow.
- [x] Create `install/install.ps1` for Windows install flow (WSL2-first guidance).
- [x] Create uninstall scripts for both platforms.
- [x] Implement install directory layout and current-version pointer.

## Phase 2 - Command entrypoints and versioning
- [x] Add command shims for `cursor-init`, `cursor-bootstrap`, `cursor-tune`, `cursor-cleanup`.
- [x] Add version reporting output for installed tooling.
- [x] Add install self-check command (PATH + command availability).

## Phase 3 - Documentation and validation
- [x] Update `README.md` with platform-specific install instructions.
- [x] Document upgrade and rollback runbook.
- [x] Add/install smoke checks for installer outputs.
- [x] Run existing smoke/e2e and verify no regression.

## Done criteria
- [x] Cross-platform install docs are complete and tested.
- [x] Users can run all four commands after installation.
- [x] Version info is visible and support-ready.
- [x] Existing bootstrap/tune flows remain compatible.
