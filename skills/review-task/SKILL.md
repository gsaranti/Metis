---
name: review-task
description: Dispatch the task-reviewer subagent to judge a task's diff against its acceptance criteria. Returns a verdict with per-criterion evidence.
disable-model-invocation: true
---

# /metis:review-task

Dispatch the `task-reviewer` subagent to review one task's implementation against its acceptance criteria.

## Arguments

- **`<task-id>`** — required. A zero-padded 4-digit task id (e.g., `0007`).
- **Trailing prompt** — optional.

## Preflight

Run `.metis/scripts/review-task-preflight.sh <task-id>`. It exits non-zero if the id is missing, malformed, doesn't resolve to a task file (with nearest-match guidance), or the working dir isn't a git repo. On success it reports `TASK_PATH`, `STATUS`, `EPIC`, and `DIFF_PRESENT`.

Apply policy from the preflight output:

- `STATUS=in-review` — proceed.
- `STATUS=pending` or `in-progress` — point at `/metis:implement-task`.
- `STATUS=done` — confirm before running a second review.
- `STATUS=blocked` — surface the block reason from Notes.
- `DIFF_PRESENT=no` — surface as an "empty diff" finding without dispatching.

## Subagent dispatch

Dispatch `task-reviewer` with:

- The resolved `TASK_PATH` from the preflight.
- Any trailing free-text prompt, verbatim.

## Write scope

This command writes nothing.

## Invocation prompt

The trailing prompt is forwarded to the subagent verbatim. The four discipline rules live canonically in `.metis/conventions/command-prompts.md` and are enforced inside `task-reviewer.md`.

## Return

Relay the subagent's return:

- **Verdict** — `approve`, `approve-with-nits`, or `reject-with-reasons`.
- **Per-criterion results** — pass/fail with evidence per acceptance criterion.
- **Scope reduction findings** — surfaced from the implementer's return.
- **Code-quality notes** — separate from spec compliance.
- **Next step** — depends on verdict:
  - `approve` / `approve-with-nits` — the user transitions `status` to `done` and merges.
  - `reject-with-reasons` — back to `/metis:implement-task <id>` with the reviewer's findings in Notes.

If the subagent returns an "empty diff" finding instead of a review, pass it through as-is.
