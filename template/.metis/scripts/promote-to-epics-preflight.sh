#!/usr/bin/env bash
#
# .metis/scripts/promote-to-epics-preflight.sh
#
# Validator for /metis:promote-to-epics. Confirms a flat tasks/
# layout with content, no existing epics/ content, and BUILD.md.
#
# Output: key=value lines on stdout.
# Exits non-zero with a specific stderr error if any precondition fails.
#
# Fields emitted on success:
#   TASK_COUNT     number of task files in the flat tasks/ directory
#   SPEC_VERSION   project spec_version from .metis/config.yaml (default: 1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "$PROJECT_ROOT"

# -- BUILD.md ---------------------------------------------------------------

if [[ ! -f "BUILD.md" ]]; then
  printf 'error: BUILD.md not found — run /metis:init or /metis:build-spec first.\n' >&2
  exit 1
fi

# -- flat tasks/ check -------------------------------------------------------

flat_count=0
if [[ -d "tasks" ]]; then
  flat_count=$(find tasks -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
fi

if [[ $flat_count -eq 0 ]]; then
  cat >&2 <<'ERR'
error: /metis:promote-to-epics graduates a flat tasks/ layout into epics.
This project has no flat tasks/ directory with content.

If you want an epic-layout project from scratch, run:
  /metis:epic-breakdown
ERR
  exit 1
fi

# -- epics/ check ------------------------------------------------------------

epic_count=0
if [[ -d "epics" ]]; then
  epic_count=$(find epics -maxdepth 2 -name "EPIC.md" 2>/dev/null | wc -l | tr -d ' ')
fi

if [[ $epic_count -gt 0 ]]; then
  cat >&2 <<ERR
error: This project already has an epics/ directory with content (${epic_count} epic(s)).
/metis:promote-to-epics only applies to flat-layout projects.

To add a new epic to an existing epic-layout project, run:
  /metis:feature "<description>"
ERR
  exit 1
fi

# -- spec_version -----------------------------------------------------------

SPEC_VERSION="1"
if [[ -f ".metis/config.yaml" ]]; then
  v=$(awk -F': *' '/^spec_version:/{print $2; exit}' .metis/config.yaml | tr -d '[:space:]')
  [[ -n "$v" ]] && SPEC_VERSION="$v"
fi

cat <<EOF
TASK_COUNT=$flat_count
SPEC_VERSION=$SPEC_VERSION
EOF
