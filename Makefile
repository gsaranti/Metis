# Metis dev Makefile
# Common tasks for working on the Metis framework itself.

.PHONY: help install lint validate test version

help:
	@echo "Metis dev tasks:"
	@echo "  make install PROJECT=<path>   Stamp Metis into a target project"
	@echo "  make lint                     Lint command files"
	@echo "  make validate                 Validate skill files have SKILL.md + examples/"
	@echo "  make test                     Run integration checklist (manual)"
	@echo "  make version                  Print current Metis version"

install:
	@if [ -z "$(PROJECT)" ]; then \
		echo "Usage: make install PROJECT=<path-to-target-project>"; \
		exit 1; \
	fi
	./install/install.sh "$(PROJECT)"

lint:
	python3 scripts/lint-commands.py

validate:
	python3 scripts/validate-skills.py

test:
	@echo "Manual integration checklist: tests/integration/first-slice.md"

version:
	@cat VERSION
