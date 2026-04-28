---
name: promote-to-epics
description: Graduate a flat tasks/ layout to an epic layout by grouping existing tasks into proposed epics.
disable-model-invocation: true
---

# /metis:promote-to-epics

Graduate a flat-layout project to an epic layout.

## Preflight

Invoke `${CLAUDE_PLUGIN_ROOT}/.metis/scripts/promote-to-epics-preflight.sh` first. If it exits non-zero, surface its stderr verbatim and stop.

## Load

- `BUILD.md`. Read in full.
- Every task file under `tasks/` — frontmatter and Goal only.
- `docs/SYNTHESIS.md` and `docs/INDEX.md` if they exist — orientation for capabilities the tasks cite via `docs_refs`.

## Do not load

- Task bodies.
- `decisions/`, `scratch/`.
- Source docs directly.

## Read first

- `../../references/decomposing-build-into-epics.md` — read before proposing the groups. The existing task set is the input rather than a `BUILD.md` section.
- `../../references/writing-an-epic-file.md` — invoked once the grouping is approved, to render each `EPIC.md`.

## Three-phase flow

1. **Propose.** Group the existing tasks into candidate epics. One line per proposed epic: name, one-line capability, one-line exit criterion, the list of task ids it would own. Flag any tasks the grouping could not place cleanly (ambiguous ownership, work that predates current `BUILD.md` capabilities). Ask for approval before anything moves.
2. **Scaffold.** On approval, create `epics/NNN-kebab-name/EPIC.md` for each approved group per `../../references/writing-an-epic-file.md`.
3. **Migrate.** Move task files from `tasks/<id>-*.md` to `epics/<name>/tasks/<id>-*.md`. Update each moved task's frontmatter: add `epic: <name>`. Task ids do not change. After all moves are complete, remove the (now empty) `tasks/` directory.

## Write scope

- `epics/NNN-kebab-name/EPIC.md` per approved epic. Create parent directories.
- `epics/<name>/tasks/<id>-*.md` — moved from `tasks/`, with `epic:` added to frontmatter.
- Removal of the flat `tasks/` directory after all task files have moved.

### Do not write to

- `BUILD.md`.
- `decisions/`.
- `docs/`.
- `scratch/`.

## Handling the edge cases

- **Tasks that do not fit any epic cleanly.** Surface explicitly. The user decides whether they really are a sibling epic, should be merged into the nearest group, or are superseded work that wants a `done` or `deleted` status before promotion proceeds.
- **Tasks with `id` collisions.** Should not occur, but if they do, stop and surface — renaming is a user-driven repair, not a silent fix.
- **Tasks with `depends_on` across proposed epic boundaries.** Allowed — flag them so the user can verify the epic dependency graph reflects them.

## Invocation prompt

Trailing prompt: see `.metis/conventions/command-prompts.md`.

## Return

- **Proposed grouping** during the propose phase — epics, task ids per epic, unclaimed tasks, cross-boundary dependencies.
- **Files written and moved** during the scaffold and migrate phases — epic paths, task file paths before and after.
- **Removed** — the flat `tasks/` directory once empty.
- **Flagged findings** — architectural gaps, collision situations, orphan tasks.
- **Next step** — `/metis:pick-task` to resume the feature loop under the epic layout.
