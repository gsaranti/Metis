#!/usr/bin/env bash
#
# .metis/scripts/generate-tasks-preflight.sh [<epic-name>]
#
# Validator and shape-resolver for /metis:generate-tasks.
#
# Behavior:
#   - With <epic-name>: requires an epic-layout project; resolves
#     TARGET to epics/<name>/tasks.
#   - Without argument: requires a flat-layout project (no epics/ with
#     EPIC.md files); resolves TARGET to tasks.
#
# Output: key=value lines on stdout when preconditions are met.
# Exits non-zero with a specific stderr error otherwise.
#
# Fields emitted on success:
#   STATUS         ready
#   TARGET         tasks  |  epics/<name>/tasks
#   SPEC_VERSION   project spec_version from .metis/config.yaml (default: 1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "$PROJECT_ROOT"

# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

EPIC_ARG="${1:-}"

metis_detect_layout

# Build epic name list when in epic layout, for error messages.
epics_list=""
if [[ $EPIC_CONTENT -eq 1 ]]; then
  while IFS= read -r d; do
    name="${d%/EPIC.md}"
    name="${name#epics/}"
    epics_list+="$name "
  done < <(find epics -maxdepth 2 -name "EPIC.md" 2>/dev/null | sort)
fi

if [[ $FLAT_CONTENT -eq 1 && $EPIC_CONTENT -eq 1 ]]; then
  printf 'error: ambiguous layout — both tasks/ has content and epics/ has EPIC.md files. Resolve manually before running this command.\n' >&2
  exit 1
fi

# -- resolve TARGET against the layout ---------------------------------------

if [[ -n "$EPIC_ARG" ]]; then
  if [[ $EPIC_CONTENT -eq 0 ]]; then
    printf 'error: epic name "%s" supplied, but this project has no epics/ directory. Run /metis:epic-breakdown to create epics, or /metis:generate-tasks (no argument) to generate into a flat tasks/ directory.\n' "$EPIC_ARG" >&2
    exit 1
  fi
  if [[ ! -f "epics/${EPIC_ARG}/EPIC.md" ]]; then
    printf 'error: epics/%s/EPIC.md does not exist. Existing epics: %s\n' "$EPIC_ARG" "${epics_list% }" >&2
    exit 1
  fi
  TARGET="epics/${EPIC_ARG}/tasks"
else
  if [[ $EPIC_CONTENT -eq 1 ]]; then
    printf 'error: this project has an epics/ directory; /metis:generate-tasks requires an epic name. Existing epics: %s\n' "${epics_list% }" >&2
    exit 1
  fi
  if [[ ! -f "BUILD.md" ]]; then
    printf 'error: BUILD.md not found — run /metis:build-spec first.\n' >&2
    exit 1
  fi
  TARGET="tasks"
fi

# -- regeneration check -------------------------------------------------------

if [[ -d "$TARGET" ]]; then
  count=$(find "$TARGET" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  if [[ $count -gt 0 ]]; then
    printf 'error: %s already contains %s task file(s). For BUILD.md drift, run /metis:sync. For new mid-stream features, run /metis:feature.\n' "$TARGET" "$count" >&2
    exit 1
  fi
fi

metis_read_spec_version

cat <<EOF
STATUS=ready
TARGET=$TARGET
SPEC_VERSION=$SPEC_VERSION
EOF
