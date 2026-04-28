---
name: implement-task
description: Implement one task. Closes with a scope report.
disable-model-invocation: true
---

# /metis:implement-task

Implement one task and close with a scope report.

## Arguments

- **`<task-id>`** — required. A zero-padded 4-digit task id (e.g., `0007`).
- **Trailing prompt** — optional.

## Preflight

Run `${CLAUDE_PLUGIN_ROOT}/.metis/scripts/implement-task-preflight.sh <task-id>`. It exits non-zero if the id is missing, malformed, or doesn't resolve to a task file (with nearest-match guidance). On success it reports `TASK_PATH`, `STATUS`, `EPIC`, `DEPS_PENDING`, and `PLAN_EXISTS`.

Apply policy from the preflight output:

- `STATUS=done` — block.
- `STATUS=blocked` or `DEPS_PENDING > 0` — block unless confirmed stale.
- `STATUS=in-review` — confirm before re-implementing.
- Otherwise — proceed; transition `status` to `in-progress`.

## Load

- The task file — full body, plus frontmatter.
- When the task lives under an epic, the parent `EPIC.md`.
- The approved plan at `scratch/plans/<id>.md` when `PLAN_EXISTS=yes`.
- Only the docs listed in the task's `docs_refs` frontmatter, at the cited sections.
- The code the task is changing, on demand as implementation proceeds.

If the brief is not enough to implement the task, surface the gap rather than widening the load.

## Do not load

- Other task files.
- `BUILD.md`.
- Other epics' `EPIC.md` files.
- `decisions/`.
- `scratch/CURRENT.md`, `scratch/questions.md`.
- Other plans in `scratch/plans/`.

## Read first

- `${CLAUDE_PLUGIN_ROOT}/references/planning-a-task.md` — load when `PLAN_EXISTS=no`.
- `${CLAUDE_PLUGIN_ROOT}/references/honest-scope-reporting.md` — read before writing the closing Notes block.

## Write scope

- **The assigned task file.** Update `status` and append the implementation Notes block.
- **Code and test files.** Confined to surfaces named in the task's `touches` and `Expected file changes`. Widening goes in the scope report.

### Do not write to

- Other task files.
- `BUILD.md`.
- `decisions/`.
- `scratch/CURRENT.md`, `scratch/questions.md`.
- `scratch/plans/<id>.md`.
- `.metis/`, `.claude/`.

## Invocation prompt

Trailing prompt: see `${CLAUDE_PLUGIN_ROOT}/.metis/conventions/command-prompts.md`.

## Closing the implementation

Before returning:

1. Run the task's verification command (or the plan's, if one was produced). Paste the actual output into Notes — not a claim of what it said.
2. Append a Notes block: what was built, the scope report (per `${CLAUDE_PLUGIN_ROOT}/references/honest-scope-reporting.md`), any divergence from the plan, and the rule-3 prompt-usage acknowledgment if applicable.
3. Transition `status` to `in-review`. Do not set `done`; that's the reviewer's call.

## Return

- **Task path and status** — the file path and the new status.
- **Verification result** — the command run and its exit, summarized in one line.
- **Scope report** — the block appended to Notes, restated inline.
- **Findings** — upstream flags (task-file gaps, scope conflicts, architectural questions).
- **Next step** — `/metis:review-task <id>`, or `/metis:scope-check` first if the user wants the scope report probed before review.
