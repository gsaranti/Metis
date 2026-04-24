---
name: metis:pick-task
description: List unblocked, prioritized tasks the user can pick up next. Read-only.
disable-model-invocation: true
---

# /metis:pick-task

Surface the short list of tasks that are ready to be worked on right now — not blocked, not done, sorted so the obvious next thing is at the top. Read-only.

## Preconditions

- A task surface must exist: either a flat `tasks/` directory with at least one file, or an `epics/` directory with at least one `EPIC.md` and one task file under it. If neither holds, stop and point at the likely next move:

  ```
  No tasks on disk to pick from.

  If this project has not generated tasks yet, run:
    /metis:generate-tasks          (flat layout)
    /metis:generate-tasks <epic>   (epic layout)

  If work is meant to be done ad hoc outside Metis, /metis:log-work
  reconciles it after the fact.
  ```

## Load

- `BOARD.md` if it exists — it is the designed index for task state; prefer it over enumerating task files. If it is stale or missing, fall back to listing task frontmatter only (status, priority, depends_on, epic, title).
- Task frontmatter for any tasks not already summarized by `BOARD.md`. Do not open task bodies; the body is unnecessary for triage.

## Do not load

- Task bodies (Goal, Context, Scope, Acceptance criteria). They are not needed to pick.
- `BUILD.md`, `EPIC.md` files beyond names, `decisions/`, `docs/`. The pick is made from task-level state.
- `scratch/CURRENT.md`. This command runs frequently; loading the handoff every time inflates the cheap-command budget.

## Filter and sort

Include a task in the pickable set when all of:

- `status` is `pending` or `blocked` with a resolved blocker.
- Every id in `depends_on` resolves to a `done` task.
- (Epic mode only) the parent epic's `status` is `pending` or `in-progress`; tasks under a `done` epic are not pickable.

Sort the pickable set:

1. `priority` ascending (1 is highest).
2. Among equal priority, tasks that unblock the most other tasks first.
3. Finally, id ascending.

Exclude `in-progress`, `in-review`, and `done` tasks from the pickable set — an `in-progress` task has an owner, even if the owner is the user's prior session. Name them separately in the return for visibility.

## Write scope

**None.** This command is read-only. If `BOARD.md` is detected as stale against the task files, surface that as a finding — regenerating `BOARD.md` is out of scope here.

## Return

- **Pickable** — up to the top five, each a single line: `id · title · priority · estimate · epic (if any)`.
- **In flight** — any `in-progress` or `in-review` tasks named separately so the user can resume their own work rather than start fresh.
- **Blocked** — count of tasks whose `depends_on` is not yet satisfied, with one line naming the most commonly blocking task (by fan-out).
- **Suggested next** — one line recommending the top pickable task by default, with a one-phrase reason (e.g., *"unblocks three other tasks"* or *"highest priority"*). The user is free to pick differently.

This command silently ignores any trailing free-text prompt — pick-task is mechanical enough that per-invocation tuning rarely helps. A user who wants to bias selection should express that in the next command (`/metis:plan-task <id>` with a note about the angle they want planned).
