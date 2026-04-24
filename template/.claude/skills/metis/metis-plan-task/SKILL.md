---
name: metis:plan-task
description: Dispatch the task-planner subagent to produce an implementation plan for one task. Writes no code.
disable-model-invocation: true
---

# /metis:plan-task

Dispatch the `task-planner` subagent to produce one implementation plan for the specified task. The subagent runs in fresh context with restricted tools (Read, Glob, Grep, Write-to-`scratch/plans/`) — the planner cannot start implementing.

## Arguments

- **`<task-id>`** — required. A zero-padded 4-digit task id (e.g., `0007`). If omitted or malformed, stop and ask.
- **Trailing prompt** — optional. Forwarded to the subagent verbatim.

## Preconditions

- The task file must exist. Look up by id across the two possible locations:
  - Flat: `tasks/<id>-*.md`
  - Epic: `epics/*/tasks/<id>-*.md`
  
  If the id cannot be resolved, stop and list the nearest matches:

  ```
  No task file found for id "0007".

  Nearest ids on disk: 0005, 0006, 0008.
  ```

- The task's `status` should not be `done`. If it is, stop and ask the user to confirm — planning against a done task is occasionally legitimate (re-planning under `/metis:sync` cascade), but silently producing a plan against already-shipped work is how drift starts.

- The task's `depends_on` should all be `done`. If any is not, surface the blocker and ask whether to proceed anyway (a planner may reasonably plan a task whose dependencies are close but not yet merged).

## Load (this command's own context)

- The task file's frontmatter only — id, title, status, epic, depends_on. Used to verify preconditions and construct the subagent brief. The body is the subagent's to read.

## Do not load (this command's own context)

- The task body. Not this command's reading — it goes to the subagent.
- Source docs, `BUILD.md`, `EPIC.md`. The subagent loads what it needs per its own read list.
- Prior plans at `scratch/plans/<id>.md`. The subagent overwrites if present; loading the prior plan into this command adds nothing.

## Subagent dispatch

Dispatch `task-planner` with:

- The resolved task-file path.
- Any trailing free-text prompt, verbatim.

The subagent's system prompt (see `.claude/agents/metis/task-planner.md`) carries its own load list, write scope, invocation-prompt rules, and the invocation of the `planning-a-task` skill. Do not restate them here.

## Write scope

- The `task-planner` subagent writes `scratch/plans/<id>.md`. This command itself writes nothing.

Do not write to task files, `BUILD.md`, `BOARD.md`, `decisions/`, or any other surface from this command. If the planner's return flags a task-file issue, surface it — do not edit from here.

## Invocation prompt

The trailing prompt is forwarded to the subagent verbatim. The four discipline rules (augment / flag scope expansion / acknowledge use / resolve named skills) live canonically in `.metis/conventions/command-prompts.md` and are enforced inside `task-planner.md`. This command does not re-check them; it relays the subagent's prompt-usage acknowledgment through to the user in the return.

## Return

Relay the subagent's return plus one orientation line:

- **Plan path** — `scratch/plans/<id>.md`.
- **Plan summary** — the subagent's one-paragraph summary of the sequence and verification command.
- **Flagged ambiguities** — the subagent's list, passed through unchanged.
- **Prompt usage** — if a prompt was forwarded, the subagent's one-line acknowledgment.
- **Next step** — `/metis:implement-task <id>` if the plan is ready to execute, or a hand-edit pass on `scratch/plans/<id>.md` if the user wants to redirect the implementer before dispatch.

If the subagent returned a "task appears done" finding instead of a plan, pass that through as-is — no plan file was written, and the user decides from the evidence.
