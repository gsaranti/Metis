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
DEPS_LINE=""
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
    "depends_on:"*)
      DEPS_LINE="${line#depends_on:}"
      ;;
  esac
done < "$TASK_PATH"

# -- count pending dependencies ---------------------------------------------

DEPS_PENDING=0
if [[ -n "$DEPS_LINE" ]]; then
  while IFS= read -r dep_id; do
    [[ -z "$dep_id" ]] && continue
    dep_status=""
    for dep_candidate in tasks/"$dep_id"-*.md epics/*/tasks/"$dep_id"-*.md; do
      if [[ -f "$dep_candidate" ]]; then
        dep_status=$(awk -F': *' '/^status:/{gsub(/["\x27 ]/, "", $2); print $2; exit}' "$dep_candidate")
        break
      fi
    done
    if [[ "$dep_status" != "done" ]]; then
      DEPS_PENDING=$(( DEPS_PENDING + 1 ))
    fi
  done < <(printf '%s' "$DEPS_LINE" | grep -oE '[0-9]{4}')
fi

# -- check for an approved plan ---------------------------------------------

PLAN_EXISTS=no
[[ -f "scratch/plans/${TASK_ID}.md" ]] && PLAN_EXISTS=yes

cat <<EOF
TASK_PATH=$TASK_PATH
STATUS=$STATUS
EPIC=$EPIC
DEPS_PENDING=$DEPS_PENDING
PLAN_EXISTS=$PLAN_EXISTS
EOF
