#!/usr/bin/env bash
#
# .metis/scripts/reconcile-preflight.sh
#
# Mechanical preflight for /metis:reconcile. Reports the shape of the
# docs/ corpus so the skill can plan its read.
#
# Output: key=value lines on stdout. Exits non-zero if docs/ is missing.
#
# Fields emitted:
#   STATUS                fresh | rereconcile
#   DOCS_COUNT            number of source files (excludes reconcile outputs)
#   CORPUS_WORDS          sum of wc -w across source files
#   CORPUS_TOKENS_EST     tokens estimate (words × per-file-type multiplier)
#   SIZE_CLASS            small (<40k) | medium (40-80k) | large (>=80k)
#   PRIOR_OPEN            open items carried in CONTRADICTIONS.md + QUESTIONS.md
#   PRIOR_DEFERRED        deferred items carried forward
#   PRIOR_STALE           stale items carried forward
#
# PRIOR_* are always 0 when STATUS=fresh.

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

# -- reconcile outputs that should be excluded from the source-doc set -------

OUTPUTS=(SYNTHESIS.md INDEX.md CONTRADICTIONS.md QUESTIONS.md RESOLVED.md)

is_output() {
  local path="$1"
  local base="${path##*/}"
  # Only match at the top level of docs/ — nested files with these names
  # (unlikely but possible) are user-owned docs.
  [[ "$path" == "$DOCS_DIR/$base" ]] || return 1
  for out in "${OUTPUTS[@]}"; do
    [[ "$base" == "$out" ]] && return 0
  done
  return 1
}

# -- enumerate source docs ---------------------------------------------------

source_files=()
while IFS= read -r -d '' f; do
  is_output "$f" && continue
  source_files+=("$f")
done < <(find "$DOCS_DIR" -type f -print0)

DOCS_COUNT=${#source_files[@]}

# -- word count + token estimate (per-file-type multiplier, integer math) ----

# Multipliers scaled ×10 to avoid floating point:
#   prose (.md .txt .rst)             -> 13   (×1.3)
#   schema (.yaml .yml .json .toml .xml .csv) -> 18   (×1.8)
#   code   (.py .js .ts .go .rb .rs .java .c .cpp .h) -> 15   (×1.5)
#   other                              -> 13   (default, treat as prose)

total_words=0
total_tokens_est=0
for f in "${source_files[@]}"; do
  w=$(wc -w < "$f" 2>/dev/null | tr -d ' ')
  [[ -z "$w" ]] && w=0
  ext="${f##*.}"
  case "$ext" in
    yaml|yml|json|toml|xml|csv)              mult=18 ;;
    py|js|ts|go|rb|rs|java|c|cpp|h|hpp)      mult=15 ;;
    *)                                        mult=13 ;;
  esac
  tokens=$(( (w * mult) / 10 ))
  total_words=$(( total_words + w ))
  total_tokens_est=$(( total_tokens_est + tokens ))
done

# -- classify corpus size ----------------------------------------------------

if   (( total_tokens_est < 40000 )); then SIZE_CLASS=small
elif (( total_tokens_est < 80000 )); then SIZE_CLASS=medium
else                                      SIZE_CLASS=large
fi

# -- fresh vs rereconcile ----------------------------------------------------

STATUS=fresh
for out in SYNTHESIS.md INDEX.md CONTRADICTIONS.md QUESTIONS.md; do
  if [[ -f "$DOCS_DIR/$out" ]]; then
    STATUS=rereconcile
    break
  fi
done

# -- prior item counts (rereconcile only) ------------------------------------

PRIOR_OPEN=0
PRIOR_DEFERRED=0
PRIOR_STALE=0

for f in "$DOCS_DIR/CONTRADICTIONS.md" "$DOCS_DIR/QUESTIONS.md"; do
  PRIOR_OPEN=$((     PRIOR_OPEN     + $(metis_count_status "$f" open) ))
  PRIOR_DEFERRED=$(( PRIOR_DEFERRED + $(metis_count_status "$f" deferred) ))
  PRIOR_STALE=$((    PRIOR_STALE    + $(metis_count_status "$f" stale) ))
done

# -- emit report -------------------------------------------------------------

cat <<EOF
STATUS=$STATUS
DOCS_COUNT=$DOCS_COUNT
CORPUS_WORDS=$total_words
CORPUS_TOKENS_EST=$total_tokens_est
SIZE_CLASS=$SIZE_CLASS
PRIOR_OPEN=$PRIOR_OPEN
PRIOR_DEFERRED=$PRIOR_DEFERRED
PRIOR_STALE=$PRIOR_STALE
EOF
