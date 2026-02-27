# Cursor Engineering Bootstrap Constitution

## Purpose
Standardize AI-assisted engineering workflows with reproducible, auditable, and low-risk project onboarding.

## Principles

1. Reproducibility first: every generated change must be reproducible from commands and documented inputs.
2. Safety by default: prefer dry-run and non-overwrite merge paths unless explicit overwrite is requested.
3. Evidence-based delivery: PR outputs must include validation evidence and rollback notes.
4. Minimal disruption: preserve existing project files and conventions whenever possible.
5. Incremental evolution: prioritize small, testable improvements over large rewrites.

## Delivery Rules

- All scaffolding changes must keep backward compatibility for existing `bin/*` usage unless explicitly version-bumped.
- Installation and onboarding flows must support macOS, Linux, and Windows (WSL2-first).
- Documentation and smoke checks are part of done criteria for workflow changes.
