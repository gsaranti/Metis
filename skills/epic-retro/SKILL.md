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

- The project must use an epic layout. If `epics/` does not exist, stop and report that this is an epic-layout-only command.
- `epics/<name>/EPIC.md` must exist. If the name does not resolve, list the epics on disk.
- The epic's `status` should be `done`. If it is `pending` or `in-progress`, stop and ask the user to confirm.
- `epics/<name>/retro.md` should not already exist. If it does, stop and surface.

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

## Invocation prompt

Trailing prompt: see `.metis/conventions/command-prompts.md`.

## Return

- **Path written** — `epics/<name>/retro.md`.
- **Block summary** — one line per block noting whether it was populated or left empty.
- **Pending follow-ups** — assumptions worth filing as decisions, task-breakdown lessons worth carrying into the next epic. Surfaced as flags, not written.
