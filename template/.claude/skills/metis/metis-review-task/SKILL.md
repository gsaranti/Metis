---
name: metis:review-task
description: Dispatch the task-reviewer subagent to judge a task's diff against its acceptance criteria. Returns a verdict with per-criterion evidence.
disable-model-invocation: true
---

# /metis:review-task

Dispatch the `task-reviewer` subagent to review one task's implementation against its acceptance criteria. The subagent runs in fresh context with restricted tools (Read, Glob, Grep, Bash for `git diff` and tests only, Write for the task's Notes) — the reviewer cannot "helpfully fix."

## Arguments

- **`<task-id>`** — required. Zero-padded 4-digit id. If omitted or malformed, stop and ask.
- **Trailing prompt** — optional. Forwarded to the subagent verbatim.

## Preconditions

- The task file must exist. Resolve by id across the two possible locations:
  - Flat: `tasks/<id>-*.md`
  - Epic: `epics/*/tasks/<id>-*.md`

  If unresolved, stop and list the nearest matches.

- The task's `status` should be `in-review`. This is what `/metis:implement-task` sets on close. Other statuses get specific messages:
  - `pending` or `in-progress` — no implementation to review. Stop and point at `/metis:implement-task`.
  - `done` — already reviewed and merged. Stop and confirm with the user before running a second review; a re-review on a done task is rare and usually means the user is reconsidering rather than reviewing.
  - `blocked` — the block needs clearing first. Surface the reason from Notes.

- The branch must have changes to review. If `git diff` against the baseline is empty and the branch is clean, surface that as a finding before dispatching — the subagent will reach the same conclusion, but catching it here saves a dispatch.

## Load (this command's own context)

- The task file's frontmatter — id, status, epic. Used to verify preconditions and construct the subagent brief. The body is the subagent's to read.
- Light git state to verify a diff exists — `git rev-parse` on the current branch, `git diff --stat` against the likely baseline. Enough to decide whether to dispatch.

## Do not load (this command's own context)

- The task body. Not this command's reading — it goes to the subagent.
- The plan at `scratch/plans/<id>.md`. Deliberately — the review is against the task, not the plan, and the subagent must not see the plan.
- Source docs, `BUILD.md`, `EPIC.md`. The subagent loads what it needs per its own read list.

## Subagent dispatch

Dispatch `task-reviewer` with:

- The resolved task-file path.
- The git diff scope (the default is uncommitted changes plus branch commits not yet on the main line; narrow if the user's trailing prompt scopes it explicitly).
- Any trailing free-text prompt, verbatim.

The subagent's system prompt (see `.claude/agents/metis/task-reviewer.md`) carries its own load list, write scope, invocation-prompt rules, and the invocation of the `reviewing-against-criteria` skill. Do not restate them here.

## Write scope

- The `task-reviewer` subagent appends its review block to the task file's Notes. This command itself writes nothing beyond relaying the verdict.

Do not write to the task file's non-Notes sections, code, `BUILD.md`, `BOARD.md`, `decisions/`, or any other surface. If the review's verdict is `approve` and the user wants the task marked `done`, that transition happens outside this command — the reviewer does not own status transitions, and this command does not either.

## Invocation prompt

The trailing prompt is forwarded to the subagent verbatim. The four discipline rules (augment / flag scope expansion / acknowledge use / resolve named skills) live canonically in `.metis/conventions/command-prompts.md` and are enforced inside `task-reviewer.md`. This command does not re-check them; it relays the subagent's prompt-usage acknowledgment through to the user in the return.

## Return

Relay the subagent's return:

- **Verdict** — `approve`, `approve-with-nits`, or `reject-with-reasons`.
- **Per-criterion results** — pass/fail with evidence per acceptance criterion.
- **Scope reduction findings** — surfaced from the implementer's return, not absorbed into the verdict.
- **Code-quality notes** — kept separate from spec compliance.
- **Prompt usage** — one line if a prompt was forwarded.
- **Next step** — depends on verdict:
  - `approve` / `approve-with-nits` — the user transitions `status` to `done` and merges.
  - `reject-with-reasons` — back to `/metis:implement-task <id>` with the reviewer's findings in Notes.

If the subagent returned an "empty diff" finding instead of a review, pass that through as-is — no review block was written, and the user decides from the evidence.
