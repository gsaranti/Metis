---
name: metis:epic-retro
description: Write retro.md for a finished epic. Produces per-task estimation entries, replans with prevention signal, and assumption failures — for improvement, not reassurance.
disable-model-invocation: true
---

# /metis:epic-retro

Write the retro at `epics/<name>/retro.md` after an epic has closed. This is the record of what the next epic should do differently — per-task estimation, replans with the signal that would have caught them, assumption failures against the starting docs. Not a narrative; not a verdict; not reassurance.

## Arguments

- **`<epic-name>`** — required. The directory name of the finished epic (e.g., `002-billing`), without the `epics/` prefix and without a trailing slash.
- **Trailing prompt** — optional.

## Preconditions

- The project must use an epic layout. If `epics/` does not exist, stop:

  ```
  /metis:epic-retro is an epic-layout command, and this project
  has no epics/ directory. Retros for flat-layout projects happen
  informally at convenient boundaries; there is no dedicated command
  in v0.1.
  ```

- `epics/<name>/EPIC.md` must exist. If the name does not resolve, list the epics on disk.

- The epic's `status` should be `done`. If it is `pending` or `in-progress`, stop and ask the user to confirm — a retro against an unfinished epic is usually premature, though occasionally legitimate when the epic is being closed under `done`-equivalent conditions (abandoned, superseded, folded into another).

- `epics/<name>/retro.md` should not already exist. If it does, stop and surface; the user can delete or rename it before a rewrite.

## Load

- `epics/<name>/EPIC.md` — the starting goal, exit criterion, and scope lines are the anchor against which the retro names drift.
- Every task file under `epics/<name>/tasks/` — frontmatter and Notes at minimum; bodies when a specific task's estimation or replan entry turns on the original scope or acceptance criteria.
- `docs/SYNTHESIS.md` if it exists — only when an assumption failure turns on a corpus commitment whose starting shape the retro needs to name.

## Do not load

- `decisions/` wholesale. Decisions are findable by slug; load a specific decision only when an entry turns on it.
- Other epics' files. The retro is against this one.
- `BUILD.md`. An assumption failure against `BUILD.md` turns on a specific section; quote it rather than loading the file.
- `BOARD.md`, `scratch/CURRENT.md`. Neither feeds the retro.

## Skills

Invoke by reference:

- `writing-retros` — the primary teaching. The five blocks (estimation accuracy / replans / assumption failures / task-breakdown lessons / scratch promotions), per-task (not gestalt) estimation, replan entries that name the signal which would have caught the shift at task-write time, assumption-failure-vs-implementation-slip distinction, the for-improvement-not-reassurance register, and the one-to-two-page sizing target.

## Write scope

- `epics/<name>/retro.md`. New file.

Do not write to `EPIC.md`, task files, `BUILD.md`, `decisions/`, or `scratch/`. If the retro surfaces an assumption worth recording as a standing decision, flag it — the decision entry is its own act via the main session, not a silent append from here. If the retro flags scratch files for promotion (per `writing-retros`'s scratch-promotions block), name them in the retro; do not move them. `/metis:scratch-cleanup` handles the moves separately.

## Invocation prompt

The command may carry a trailing free-text prompt, e.g. `/metis:epic-retro 002-billing "focus on the estimation misses; the replans were fine"`.

Follow the command-prompts convention in `.metis/conventions/command-prompts.md`. The four rules (augment / flag scope expansion / acknowledge use / resolve named skills) apply; acknowledge prompt usage in the return per rule 3.

The prompt is ephemeral — do not persist it into the retro or any task's Notes.

## Return

- **Path written** — `epics/<name>/retro.md`.
- **Block summary** — one line per block noting whether it was populated or left empty.
- **Scratch promotions flagged** — the inline list from the retro's Scratch promotions block, surfaced for the user's convenience.
- **Pending follow-ups** — assumptions worth filing as decisions, task-breakdown lessons worth carrying into the next epic's `/metis:epic-breakdown`. Surfaced as flags, not written.
- **Prompt usage** — one line if a prompt was carried.
- **Next step** — `/metis:scratch-cleanup` when promotions are flagged, or `/metis:generate-tasks <next-epic>` to start the next epic.
