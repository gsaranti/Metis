---
name: plan-task
description: Dispatch the task-planner subagent to produce an implementation plan for one task.
disable-model-invocation: true
---

# /metis:plan-task

Dispatch the `task-planner` subagent to produce one implementation plan for the specified task.

## Arguments

- **`<task-id>`** — required. A zero-padded 4-digit task id (e.g., `0007`).
- **Trailing prompt** — optional.

## Preflight

Run `${CLAUDE_PLUGIN_ROOT}/.metis/scripts/plan-task-preflight.sh <task-id>`. It exits non-zero if the id is missing, malformed, or doesn't resolve to a task file (with nearest-match guidance — surface and stop). On success it reports `TASK_PATH`, `STATUS`, `EPIC`, and `DEPS_PENDING`.

If `STATUS=done`, ask the user to confirm before dispatching. If `DEPS_PENDING > 0`, surface the count and ask whether to proceed.

## Subagent dispatch

Dispatch `task-planner` with:

- The resolved `TASK_PATH` from the preflight.
- Any trailing free-text prompt, verbatim.

## Write scope

This command writes nothing.

## Invocation prompt

Trailing prompt: forwarded verbatim to the subagent.

## Return

Relay the subagent's return:

- **Plan path** — `scratch/plans/<id>.md`.
- **Plan summary** — one-paragraph summary of the sequence and verification command.
- **Flagged ambiguities** — items the plan could not settle.
- **Next step** — `/metis:implement-task <id>` if the plan is ready, or hand-edit `scratch/plans/<id>.md` to redirect first.

If the subagent returns a "task appears done" finding instead of a plan, pass it through as-is.
