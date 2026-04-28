#!/usr/bin/env bash
#
# .metis/scripts/walk-open-items-preflight.sh
#
# Mechanical preflight for /metis:walk-open-items. Reports the state of
# captured items so the skill can plan the walk.
#
# Output: key=value lines on stdout.
# Exits non-zero if docs/ is missing or if neither CONTRADICTIONS.md nor
# QUESTIONS.md exists (skill surfaces the error, points at /metis:reconcile).
#
# Fields emitted:
#   OPEN                   total open items across both active files
#   OPEN_CONTRADICTIONS    open items in CONTRADICTIONS.md
#   OPEN_QUESTIONS         open items in QUESTIONS.md
#   DEFERRED               total deferred items across both files
#   STALE                  total stale items across both files
#   RESOLVED_PRIOR         items archived in RESOLVED.md from prior sessions

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PWD}"

# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

DOCS_DIR="docs"
[[ -d "$DOCS_DIR" ]] || {
  printf 'error: docs/ not found at %s\n' "$(pwd)" >&2
  exit 1
}

CONTRADICTIONS="$DOCS_DIR/CONTRADICTIONS.md"
QUESTIONS="$DOCS_DIR/QUESTIONS.md"
RESOLVED="$DOCS_DIR/RESOLVED.md"

if [[ ! -f "$CONTRADICTIONS" && ! -f "$QUESTIONS" ]]; then
  printf 'error: no CONTRADICTIONS.md or QUESTIONS.md in docs/ — run /metis:reconcile first\n' >&2
  exit 1
fi

OPEN_CONTRADICTIONS=$(metis_count_status "$CONTRADICTIONS" open)
OPEN_QUESTIONS=$(metis_count_status "$QUESTIONS" open)
OPEN=$(( OPEN_CONTRADICTIONS + OPEN_QUESTIONS ))

DEFERRED=$((
  $(metis_count_status "$CONTRADICTIONS" deferred) +
  $(metis_count_status "$QUESTIONS" deferred)
))

STALE=$((
  $(metis_count_status "$CONTRADICTIONS" stale) +
  $(metis_count_status "$QUESTIONS" stale)
))

# RESOLVED.md entries are top-level "## " headings (one per resolved item)
RESOLVED_PRIOR=0
if [[ -f "$RESOLVED" ]]; then
  RESOLVED_PRIOR=$(grep -c '^## ' "$RESOLVED" 2>/dev/null) || RESOLVED_PRIOR=0
fi

cat <<EOF
OPEN=$OPEN
OPEN_CONTRADICTIONS=$OPEN_CONTRADICTIONS
OPEN_QUESTIONS=$OPEN_QUESTIONS
DEFERRED=$DEFERRED
STALE=$STALE
RESOLVED_PRIOR=$RESOLVED_PRIOR
EOF
