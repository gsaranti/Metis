#!/usr/bin/env bash
#
# .metis/scripts/plan-task-preflight.sh <task-id>
#
# Resolves a task id to its file path and reads its frontmatter for
# /metis:plan-task. Errors with a nearest-match list when the id can't
# be resolved.
#
# Output: key=value lines on stdout when the task is found.
# Exits non-zero on missing id, malformed id, or unresolved id.
#
# Fields emitted:
#   TASK_PATH       path to the task file
#   STATUS          the task's status frontmatter value
#   EPIC            parent epic name (blank for flat layout)
#   DEPS_PENDING    count of depends_on tasks whose status isn't 'done'

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "$PROJECT_ROOT"

# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

TASK_ID="${1:-}"

metis_validate_task_id "$TASK_ID" || exit 1
metis_resolve_task_path "$TASK_ID" || exit 1
metis_parse_task_frontmatter "$TASK_PATH"
metis_count_pending_deps "$DEPS_LINE"

cat <<EOF
TASK_PATH=$TASK_PATH
STATUS=$STATUS
EPIC=$EPIC
DEPS_PENDING=$DEPS_PENDING
EOF
