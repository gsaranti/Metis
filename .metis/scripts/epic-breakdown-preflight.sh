#!/usr/bin/env bash
#
# .metis/scripts/epic-breakdown-preflight.sh
#
# Validator for /metis:epic-breakdown preconditions:
#   - BUILD.md exists
#   - no flat tasks/ with content
#   - no existing epics/ with EPIC.md files
#
# Exits 0 silently on success. Exits non-zero with a specific stderr
# message when a precondition fails, naming the recovery command.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "$PROJECT_ROOT"

# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if [[ ! -f "BUILD.md" ]]; then
  printf 'error: BUILD.md not found at %s/BUILD.md — run /metis:build-spec first.\n' "$(pwd)" >&2
  exit 1
fi

metis_detect_layout

if [[ $FLAT_CONTENT -eq 1 ]]; then
  task_count=$(find tasks -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  printf 'error: flat tasks/ exists with %s task file(s) — /metis:epic-breakdown would create an ambiguous layout. Run /metis:promote-to-epics to graduate the existing tasks into an epic layout, or /metis:generate-tasks to stay flat.\n' "$task_count" >&2
  exit 1
fi

if [[ $EPIC_CONTENT -eq 1 ]]; then
  epic_count=$(find epics -maxdepth 2 -name "EPIC.md" 2>/dev/null | wc -l | tr -d ' ')
  printf 'error: epics/ already contains %s EPIC.md file(s). For mid-stream additions, run /metis:feature. For deliberate re-decomposition, remove epics/ manually first.\n' "$epic_count" >&2
  exit 1
fi
