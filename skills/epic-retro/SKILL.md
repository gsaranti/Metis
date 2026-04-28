---
name: epic-retro
description: Write retro.md for a finished epic. Produces per-task estimation entries, replans with prevention signal, and assumption failures — for improvement, not reassurance.
disable-model-invocation: true
---

# /metis:epic-retro

Write the retro at `epics/<name>/retro.md` after an epic has closed.

## Argument

- **`<epic-name>`** — required. The directory name of the finished epic (e.g., `002-billing`), without the `epics/` prefix and without a trailing slash.

## Preconditions

- The project must use an epic layout. If `epics/` does not exist, stop:

  ```
  /metis:epic-retro is an epic-layout command, and this project
  has no epics/ directory. Retros for flat-layout projects happen
  informally at convenient boundaries; there is no dedicated command
  in v0.1.
  ```

- `epics/<name>/EPIC.md` must exist. If the name does not resolve, list the epics on disk.

- The epic's `status` should be `done`. If it is `pending` or `in-progress`, stop and ask the user to confirm — a retro against an unfinished epic is usually premature unless the epic is being closed under done-equivalent conditions (abandoned, superseded, folded).

- `epics/<name>/retro.md` should not already exist. If it does, stop and surface; the user can delete or rename it before a rewrite.

## Load

- `epics/<name>/EPIC.md` — the starting goal, exit criterion, and scope lines.
- Every task file under `epics/<name>/tasks/` — frontmatter and Notes at minimum; bodies when a specific task's estimation or replan entry turns on the original scope or acceptance criteria.
- `docs/SYNTHESIS.md` if it exists — only when an assumption failure turns on a corpus commitment whose starting shape the retro needs to name.

## Do not load

- `decisions/` wholesale.
- Other epics' files.
- `BUILD.md`.
- `scratch/CURRENT.md`.

## Read first

- `references/writing-retros.md` — read before drafting the retro.

## Write scope

- `epics/<name>/retro.md`. New file.

### Do not write to

- `EPIC.md`.
- Task files.
- `BUILD.md`.
- `decisions/`.
- `scratch/`.

If the retro surfaces an assumption worth recording as a standing decision, flag it; the decision entry is its own act. Scratch files flagged for promotion are named in the retro, not moved.

## Invocation prompt

The command may carry a trailing free-text prompt. Follow the command-prompts convention in `.metis/conventions/command-prompts.md`. The four rules (augment / flag scope expansion / acknowledge use / resolve named skills) apply; acknowledge prompt usage in the return per rule 3.

The prompt is ephemeral — do not persist it into the retro or any task's Notes.

## Return

- **Path written** — `epics/<name>/retro.md`.
- **Block summary** — one line per block noting whether it was populated or left empty.
- **Pending follow-ups** — assumptions worth filing as decisions, task-breakdown lessons worth carrying into the next epic. Surfaced as flags, not written.
