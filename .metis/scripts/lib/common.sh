#!/usr/bin/env bash
#
# .metis/scripts/lib/common.sh
#
# Shared helpers sourced by preflight scripts. Source after `cd` to PROJECT_ROOT.
# All helpers operate on relative paths from the repo root.

# metis_count_status <file> <value>
#   Print count of "^Status: <value>" lines in <file>. Prints 0 if file absent.
metis_count_status() {
  local file="$1" value="$2" n
  [[ -f "$file" ]] || { printf '0'; return; }
  n=$(grep -c "^Status: ${value}" "$file" 2>/dev/null) || n=0
  printf '%d' "$n"
}

# metis_read_spec_version
#   Set SPEC_VERSION from .metis/config.yaml; default "1".
metis_read_spec_version() {
  SPEC_VERSION="1"
  if [[ -f ".metis/config.yaml" ]]; then
    local v
    v=$(awk -F': *' '/^spec_version:/{print $2; exit}' .metis/config.yaml | tr -d '[:space:]"'"'"'')
    [[ -n "$v" ]] && SPEC_VERSION="$v"
  fi
}

# metis_detect_layout
#   Set FLAT_CONTENT (0/1) from tasks/*.md presence at the top level.
#   Set EPIC_CONTENT (0/1) from epics/*/EPIC.md presence.
metis_detect_layout() {
  FLAT_CONTENT=0
  if [[ -d "tasks" ]]; then
    local count
    count=$(find tasks -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    [[ $count -gt 0 ]] && FLAT_CONTENT=1
  fi

  EPIC_CONTENT=0
  if [[ -d "epics" ]]; then
    local count
    count=$(find epics -maxdepth 2 -name "EPIC.md" 2>/dev/null | wc -l | tr -d ' ')
    [[ $count -gt 0 ]] && EPIC_CONTENT=1
  fi
}

# metis_validate_task_id <id>
#   Validate that <id> is a 4-digit zero-padded string. Print error and
#   return 1 on failure.
metis_validate_task_id() {
  local id="$1"
  if [[ -z "$id" ]]; then
    printf 'error: task id required\n' >&2
    return 1
  fi
  if ! [[ "$id" =~ ^[0-9]{4}$ ]]; then
    printf 'error: task id must be a zero-padded 4-digit string (got "%s")\n' "$id" >&2
    return 1
  fi
}

# metis_resolve_task_path <id>
#   Set TASK_PATH to the resolved task file. On failure, print a
#   nearest-match error to stderr and return 1.
metis_resolve_task_path() {
  local id="$1"
  TASK_PATH=""
  for candidate in tasks/"$id"-*.md epics/*/tasks/"$id"-*.md; do
    [[ -f "$candidate" ]] && { TASK_PATH="$candidate"; return 0; }
  done

  local all_ids
  all_ids=$( { find tasks epics -type f -name "*.md" 2>/dev/null \
    | sed -E 's|.*/([0-9]{4})-.*|\1|' \
    | grep -E '^[0-9]{4}$' \
    | sort -u; } || true )

  if [[ -n "$all_ids" ]]; then
    local target nearest
    target=$((10#$id))
    nearest=$(while IFS= read -r found_id; do
      local n d
      n=$((10#$found_id))
      d=$(( n - target ))
      [[ $d -lt 0 ]] && d=$(( -d ))
      printf '%d %s\n' "$d" "$found_id"
    done <<< "$all_ids" | sort -n | head -5 | awk '{print $2}' | paste -sd, - | sed 's/,/, /g')
    printf 'error: no task file found for id "%s". Nearest ids on disk: %s\n' "$id" "$nearest" >&2
  else
    printf 'error: no task files found in tasks/ or epics/*/tasks/.\n' >&2
  fi
  return 1
}

# metis_parse_task_frontmatter <task-path>
#   Set STATUS, EPIC, DEPS_LINE from the file's YAML frontmatter.
metis_parse_task_frontmatter() {
  local task_path="$1"
  STATUS=""
  EPIC=""
  DEPS_LINE=""
  local in_fm=0
  local line
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
  done < "$task_path"
}

# metis_count_pending_deps <deps-line>
#   Set DEPS_PENDING from a depends_on YAML value (inline list shape).
metis_count_pending_deps() {
  local deps_line="$1"
  DEPS_PENDING=0
  [[ -z "$deps_line" ]] && return
  while IFS= read -r dep_id; do
    [[ -z "$dep_id" ]] && continue
    local dep_status=""
    for dep_candidate in tasks/"$dep_id"-*.md epics/*/tasks/"$dep_id"-*.md; do
      if [[ -f "$dep_candidate" ]]; then
        dep_status=$(awk -F': *' '/^status:/{gsub(/["\x27 ]/, "", $2); print $2; exit}' "$dep_candidate")
        break
      fi
    done
    if [[ "$dep_status" != "done" ]]; then
      DEPS_PENDING=$(( DEPS_PENDING + 1 ))
    fi
  done < <(printf '%s' "$deps_line" | grep -oE '[0-9]{4}')
}
