#!/usr/bin/env bash
#
# .metis/scripts/implement-task-preflight.sh <task-id>
#
# Resolves a task id to its file path and reads frontmatter for
# /metis:implement-task. Also reports whether an approved plan exists
# at scratch/plans/<id>.md.
#
# Output: key=value lines on stdout when the task is found.
# Exits non-zero on missing/malformed id or unresolved id (with
# nearest-match guidance).
#
# Fields emitted:
#   TASK_PATH       path to the task file
#   STATUS          the task's status frontmatter value
#   EPIC            parent epic name (blank for flat layout)
#   DEPS_PENDING    count of depends_on tasks whose status isn't 'done'
#   PLAN_EXISTS     yes | no (does scratch/plans/<id>.md exist?)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PWD}"

# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

TASK_ID="${1:-}"

metis_validate_task_id "$TASK_ID" || exit 1
metis_resolve_task_path "$TASK_ID" || exit 1
metis_parse_task_frontmatter "$TASK_PATH"
metis_count_pending_deps "$DEPS_LINE"

PLAN_EXISTS=no
[[ -f "scratch/plans/${TASK_ID}.md" ]] && PLAN_EXISTS=yes

cat <<EOF
TASK_PATH=$TASK_PATH
STATUS=$STATUS
EPIC=$EPIC
DEPS_PENDING=$DEPS_PENDING
PLAN_EXISTS=$PLAN_EXISTS
EOF
