#!/usr/bin/env bash
#
# .metis/scripts/review-task-preflight.sh <task-id>
#
# Resolves a task id to its file path, reads frontmatter, and checks
# whether the working tree or branch has changes for /metis:review-task.
#
# Output: key=value lines on stdout when the task is found and git
# is available. Exits non-zero on missing/malformed id, unresolved id
# (with nearest-match guidance), or non-git working dir.
#
# Fields emitted:
#   TASK_PATH       path to the task file
#   STATUS          the task's status frontmatter value
#   EPIC            parent epic name (blank for flat layout)
#   DIFF_PRESENT    yes | no (uncommitted changes or commits ahead of baseline)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PWD}"

# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

TASK_ID="${1:-}"

metis_validate_task_id "$TASK_ID" || exit 1

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  printf 'error: not in a git repository — /metis:review-task needs git to scope the review.\n' >&2
  exit 1
fi

metis_resolve_task_path "$TASK_ID" || exit 1
metis_parse_task_frontmatter "$TASK_PATH"

# -- check diff presence -----------------------------------------------------

DIFF_PRESENT=no
if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
  DIFF_PRESENT=yes
else
  for baseline in main master origin/main origin/master; do
    if git rev-parse --verify --quiet "$baseline" >/dev/null 2>&1; then
      head_commits=$(git rev-list --count "${baseline}..HEAD" 2>/dev/null || echo 0)
      [[ "$head_commits" -gt 0 ]] && DIFF_PRESENT=yes
      break
    fi
  done
fi

cat <<EOF
TASK_PATH=$TASK_PATH
STATUS=$STATUS
EPIC=$EPIC
DIFF_PRESENT=$DIFF_PRESENT
EOF
