#!/usr/bin/env bash
#
# .metis/scripts/feature-preflight.sh
#
# Validator for /metis:feature. Confirms BUILD.md exists and resolves
# the output shape (flat vs epic) from the on-disk layout.
#
# Output: key=value lines on stdout.
# Exits non-zero with a specific stderr error if BUILD.md is missing
# or the layout is ambiguous (both tasks/ and epics/ populated).
#
# Fields emitted on success:
#   MODE           flat | epic
#   SPEC_VERSION   project spec_version from .metis/config.yaml (default: 1)
#
# An empty project (neither tasks/ nor epics/ populated) reports
# MODE=flat per the feature convention: flat is the default layout.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "$PROJECT_ROOT"

# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if [[ ! -f "BUILD.md" ]]; then
  printf 'error: BUILD.md not found — run /metis:build-spec first, including this feature in the seed.\n' >&2
  exit 1
fi

metis_detect_layout

if [[ $FLAT_CONTENT -eq 1 && $EPIC_CONTENT -eq 1 ]]; then
  printf 'error: ambiguous layout — both tasks/ and epics/ contain content. Resolve manually before running this command.\n' >&2
  exit 1
fi

MODE=flat
[[ $EPIC_CONTENT -eq 1 ]] && MODE=epic

metis_read_spec_version

cat <<EOF
MODE=$MODE
SPEC_VERSION=$SPEC_VERSION
EOF
