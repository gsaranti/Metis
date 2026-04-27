#!/usr/bin/env bash
#
# .metis/scripts/build-spec-preflight.sh
#
# Mechanical preflight for /metis:build-spec. Reports input availability
# so the skill can determine the project shape (docs-first / prompt-seeded
# / existing-codebase) and route accordingly.
#
# Output: key=value lines on stdout.
# Exits non-zero if BUILD.md already exists (this command does not edit
# an existing brief — /metis:sync is the path for that).
#
# Fields emitted:
#   DOCS_PRESENT      yes | no    (docs/ has at least one source file)
#   RECONCILE_DONE    yes | no    (docs/SYNTHESIS.md exists)
#   WALK_PENDING      yes | no    (open or stale items remain)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "$PROJECT_ROOT"

if [[ -f "BUILD.md" ]]; then
  printf 'error: BUILD.md already exists at %s/BUILD.md — /metis:build-spec only creates the initial brief. Use /metis:sync to propagate doc-layer changes through it, or delete BUILD.md manually if a fresh rewrite is intended.\n' "$(pwd)" >&2
  exit 1
fi

DOCS_DIR="docs"
DOCS_PRESENT=no
RECONCILE_DONE=no
WALK_PENDING=no

if [[ -d "$DOCS_DIR" ]]; then
  # Source docs exclude the five reconcile output files at the top of docs/
  OUTPUTS=(SYNTHESIS.md INDEX.md CONTRADICTIONS.md QUESTIONS.md RESOLVED.md)
  source_count=0
  while IFS= read -r -d '' f; do
    base="${f##*/}"
    skip=0
    if [[ "$f" == "$DOCS_DIR/$base" ]]; then
      for out in "${OUTPUTS[@]}"; do
        [[ "$base" == "$out" ]] && { skip=1; break; }
      done
    fi
    [[ "$skip" -eq 0 ]] && source_count=$(( source_count + 1 ))
  done < <(find "$DOCS_DIR" -type f -print0)

  [[ $source_count -gt 0 ]] && DOCS_PRESENT=yes
  [[ -f "$DOCS_DIR/SYNTHESIS.md" ]] && RECONCILE_DONE=yes

  count_status() {
    local file="$1" value="$2" n
    [[ -f "$file" ]] || { printf '0'; return; }
    n=$(grep -c "^Status: ${value}" "$file" 2>/dev/null) || n=0
    printf '%d' "$n"
  }

  pending=$((
    $(count_status "$DOCS_DIR/CONTRADICTIONS.md" open) +
    $(count_status "$DOCS_DIR/QUESTIONS.md" open) +
    $(count_status "$DOCS_DIR/CONTRADICTIONS.md" stale) +
    $(count_status "$DOCS_DIR/QUESTIONS.md" stale)
  ))
  [[ $pending -gt 0 ]] && WALK_PENDING=yes
fi

cat <<EOF
DOCS_PRESENT=$DOCS_PRESENT
RECONCILE_DONE=$RECONCILE_DONE
WALK_PENDING=$WALK_PENDING
EOF
