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
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "$PROJECT_ROOT"

TASK_ID="${1:-}"

if [[ -z "$TASK_ID" ]]; then
  printf 'error: task id required (e.g., %s 0007)\n' "$0" >&2
  exit 1
fi

if ! [[ "$TASK_ID" =~ ^[0-9]{4}$ ]]; then
  printf 'error: task id must be a zero-padded 4-digit string (got "%s")\n' "$TASK_ID" >&2
  exit 1
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  printf 'error: not in a git repository — /metis:review-task needs git to scope the review.\n' >&2
  exit 1
fi

# -- resolve TASK_PATH -------------------------------------------------------

TASK_PATH=""
for candidate in tasks/"$TASK_ID"-*.md epics/*/tasks/"$TASK_ID"-*.md; do
  [[ -f "$candidate" ]] && { TASK_PATH="$candidate"; break; }
done

if [[ -z "$TASK_PATH" ]]; then
  all_ids=$( { find tasks epics -type f -name "*.md" 2>/dev/null \
    | sed -E 's|.*/([0-9]{4})-.*|\1|' \
    | grep -E '^[0-9]{4}$' \
    | sort -u; } || true )

  if [[ -n "$all_ids" ]]; then
    target=$((10#$TASK_ID))
    nearest=$(while IFS= read -r id; do
      n=$((10#$id))
      d=$(( n - target ))
      [[ $d -lt 0 ]] && d=$(( -d ))
      printf '%d %s\n' "$d" "$id"
    done <<< "$all_ids" | sort -n | head -5 | awk '{print $2}' | paste -sd, - | sed 's/,/, /g')
    printf 'error: no task file found for id "%s". Nearest ids on disk: %s\n' "$TASK_ID" "$nearest" >&2
  else
    printf 'error: no task files found in tasks/ or epics/*/tasks/.\n' >&2
  fi
  exit 1
fi

# -- parse frontmatter -------------------------------------------------------

STATUS=""
EPIC=""
in_fm=0
while IFS= read -r line; do
  if [[ "$line" == "---" ]]; then
    in_fm=$(( 1 - in_fm ))
    continue
  fi
  [[ $in_fm -eq 0 ]] && continue
  case "$line" in
    "status:"*)
      STATUS="${line#status:}"; STATUS="${STATUS# }"
      STATUS="${STATUS//\"/}"; STATUS="${STATUS//\'/}"
      ;;
    "epic:"*)
      EPIC="${line#epic:}"; EPIC="${EPIC# }"
      EPIC="${EPIC//\"/}"; EPIC="${EPIC//\'/}"
      ;;
  esac
done < "$TASK_PATH"

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
