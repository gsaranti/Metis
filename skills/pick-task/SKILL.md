---
name: pick-task
description: List unblocked, prioritized tasks.
disable-model-invocation: true
---

# /metis:pick-task

Run `.metis/scripts/pick-task.sh` and relay its output verbatim. The script lists pickable tasks (sorted by priority + fan-out + id), in-flight work, blocked counts with the most common blocker, and a suggested next. It exits non-zero with a recovery pointer if no task surface exists.

## Write scope

None. The script writes nothing.

## Invocation prompt

Silently accept and ignore any trailing free-text prompt. Per-invocation tuning does not apply to this mechanical command.
