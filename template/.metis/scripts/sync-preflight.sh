#\!/usr/bin/env bash
#
# .metis/scripts/sync-preflight.sh
#
# Validator for /metis:sync. Runs drift-scan.sh and adds sync-only
# blockers — conditions where rebaseline can safely report but sync
# cannot safely walk the cascade.
#
# Output: drift-scan.sh's stdout, unchanged on success.
# Exit:   0 on success (with or without drift);
#         1 on a sync-only blocker, with its own stderr message;
#         drift-scan.sh's exit code if drift-scan itself fails.
#
# Sync-only blockers detected here:
#   - layout=ambiguous (both tasks/ and epics/ populated). The cascade
#     cannot apply status rules uniformly across two task surfaces.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run drift-scan; capture its exit code explicitly. Stderr passes
# through to the user automatically.
set +e
output=$("${SCRIPT_DIR}/drift-scan.sh")
rc=$?
set -e

if [[ "$rc" -ne 0 ]]; then
  exit "$rc"
fi

# Surface drift-scan's output unchanged for the agent to consume.
printf '%s\n' "$output"

# -- sync-only blockers ------------------------------------------------------

if grep -q '^layout=ambiguous$' <<<"$output"; then
  cat >&2 <<'ERR'

error: ambiguous layout — both tasks/ and epics/ contain content.
/metis:sync cannot walk the cascade against two task surfaces at once.
Resolve the layout first (consolidate to one) before running sync.
/metis:rebaseline still runs in this state and surfaces the same finding.
ERR
  exit 1
fi
