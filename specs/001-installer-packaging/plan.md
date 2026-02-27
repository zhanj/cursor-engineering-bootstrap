# Plan: Cross-platform Installer Packaging

## Approach
Add a thin installation layer on top of the existing repository structure. Do not rewrite core scripts. Focus on packaging, command entrypoint wiring, and version traceability.

## Design

1. Installer assets
   - `install/install.sh` for macOS/Linux
   - `install/install.ps1` for Windows (WSL2-first guidance)
   - `install/uninstall.sh` and `install/uninstall.ps1`

2. Installation layout
   - Install root: `$HOME/.cursor-bootstrap/<version>/`
   - Current symlink/pointer: `$HOME/.cursor-bootstrap/current`
   - Command shims in user bin path (`~/.local/bin` or platform equivalent)

3. Command shims
   - `cursor-init`, `cursor-bootstrap`, `cursor-tune`, `cursor-cleanup`
   - Each shim resolves `current` install path and executes `bin/*`.

4. Version consistency
   - Add `--version` support to command shims (or helper script) with:
     - release version
     - install root
     - source commit/tag

5. Documentation
   - README installation section for macOS/Linux/Windows
   - Post-install validation commands
   - Upgrade and rollback procedure

## Risks
- PATH differences across shells and Windows profiles.
- WSL2 vs native PowerShell behavior divergence.
- Symlink permissions on Windows environments.

## Mitigations
- Provide explicit PATH checks and next-step hints in installers.
- Treat WSL2 as primary Windows path in v1.
- Include self-check and fallback instructions in docs.
