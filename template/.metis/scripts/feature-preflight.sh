#!/usr/bin/env bash
#
# .metis/scripts/feature-preflight.sh
#
# Validator for /metis:feature. Confirms BUILD.md exists and resolves
# the output shape (flat vs epic) from the on-disk layout.
#
# Output: key=value lines on stdout.
# Exits non-zero with a specific stderr error if BUILD.md is missing
# or the layout is ambiguous (both tasks/ and epics/ populated).
#
# Fields emitted on success:
#   MODE           flat | epic
#   SPEC_VERSION   project spec_version from .metis/config.yaml (default: 1)
#
# An empty project (neither tasks/ nor epics/ populated) reports
# MODE=flat per the feature convention: flat is the default layout.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "$PROJECT_ROOT"

if [[ ! -f "BUILD.md" ]]; then
  printf 'error: BUILD.md not found — run /metis:build-spec first, including this feature in the seed.\n' >&2
  exit 1
fi

# -- detect layout state -----------------------------------------------------

flat_content=0
if [[ -d "tasks" ]]; then
  count=$(find tasks -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  [[ $count -gt 0 ]] && flat_content=1
fi

epic_content=0
if [[ -d "epics" ]]; then
  count=$(find epics -maxdepth 2 -name "EPIC.md" 2>/dev/null | wc -l | tr -d ' ')
  [[ $count -gt 0 ]] && epic_content=1
fi

if [[ $flat_content -eq 1 && $epic_content -eq 1 ]]; then
  printf 'error: ambiguous layout — both tasks/ and epics/ contain content. Resolve manually before running this command.\n' >&2
  exit 1
fi

MODE=flat
[[ $epic_content -eq 1 ]] && MODE=epic

# -- read spec_version -------------------------------------------------------

SPEC_VERSION="1"
if [[ -f ".metis/config.yaml" ]]; then
  v=$(awk -F': *' '/^spec_version:/{print $2; exit}' .metis/config.yaml | tr -d '[:space:]')
  [[ -n "$v" ]] && SPEC_VERSION="$v"
fi

cat <<EOF
MODE=$MODE
SPEC_VERSION=$SPEC_VERSION
EOF
