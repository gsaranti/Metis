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
PROJECT_ROOT="${PWD}"

# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if [[ ! -f "BUILD.md" ]]; then
  printf 'error: BUILD.md not found — run /metis:init or /metis:build-spec first.\n' >&2
  exit 1
fi

metis_detect_layout

if [[ $FLAT_CONTENT -eq 0 ]]; then
  cat >&2 <<'ERR'
error: /metis:promote-to-epics graduates a flat tasks/ layout into epics.
This project has no flat tasks/ directory with content.

If you want an epic-layout project from scratch, run:
  /metis:epic-breakdown
ERR
  exit 1
fi

if [[ $EPIC_CONTENT -eq 1 ]]; then
  epic_count=$(find epics -maxdepth 2 -name "EPIC.md" 2>/dev/null | wc -l | tr -d ' ')
  cat >&2 <<ERR
error: This project already has an epics/ directory with content (${epic_count} epic(s)).
/metis:promote-to-epics only applies to flat-layout projects.

To add a new epic to an existing epic-layout project, run:
  /metis:feature "<description>"
ERR
  exit 1
fi

# Recount tasks now that flat layout is confirmed.
TASK_COUNT=$(find tasks -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

metis_read_spec_version

cat <<EOF
TASK_COUNT=$TASK_COUNT
SPEC_VERSION=$SPEC_VERSION
EOF
