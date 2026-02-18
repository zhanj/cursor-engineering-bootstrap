SHELL := /usr/bin/env bash

.PHONY: help ci ci-quick ci-full smoke smoke-init smoke-gates smoke-templates

help:
	@echo "Available targets:"
	@echo "  make ci              CI entrypoint (currently same as smoke)"
	@echo "  make ci-quick        Fast local checks (init + templates)"
	@echo "  make ci-full         Full checks (same as make ci)"
	@echo "  make smoke           Run all smoke checks"
	@echo "  make smoke-init      Run cursor-init output smoke"
	@echo "  make smoke-gates     Run gates behavior smoke"
	@echo "  make smoke-templates Run template integrity smoke"

ci: smoke

ci-quick: smoke-init smoke-templates

ci-full: ci

smoke:
	@bash scripts/smoke/run-all.sh

smoke-init:
	@bash scripts/smoke/01-cursor-init-outputs.sh

smoke-gates:
	@bash scripts/smoke/02-gates-behavior.sh

smoke-templates:
	@bash scripts/smoke/03-template-integrity.sh
