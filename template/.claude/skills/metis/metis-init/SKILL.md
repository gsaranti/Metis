---
name: metis:init
description: Finalize project-specific Metis setup. Thin wrapper around .metis/scripts/init.sh — populates .metis/config.yaml, inserts delimited blocks in CLAUDE.md and .gitignore, creates scratch/ starters.
disable-model-invocation: true
---

# /metis:init

Run `.metis/scripts/init.sh` and relay its output verbatim. The script handles arguments (`--name=<name>`, `--reinit`), preconditions, interactive prompts, and re-run idempotency; this skill does not intermediate.

## Write scope

None. The script writes.

## Invocation prompt

Silently accept and ignore any trailing free-text prompt. Per-invocation behavior is controlled by the script's flags, not by the command-prompts convention.
