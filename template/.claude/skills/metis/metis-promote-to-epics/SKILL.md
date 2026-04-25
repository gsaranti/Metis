---
name: metis:promote-to-epics
description: Graduate a flat tasks/ layout to an epic layout by grouping existing tasks into proposed epics.
disable-model-invocation: true
---

# /metis:promote-to-epics

Graduate a flat-layout project to an epic layout. Groups existing tasks into proposed epics, scaffolds `epics/<name>/` directories, and moves task files into `epics/<name>/tasks/` after approval. The commitment point of the flat-to-epic transition.

## Preconditions

- The project must have a flat `tasks/` directory with existing task files. If it does not, stop:

  ```
  /metis:promote-to-epics graduates a flat tasks/ layout into epics.
  This project has no flat tasks/ directory.

  If you want an epic-layout project from scratch, run:
    /metis:epic-breakdown
  ```

- The project must not already have an `epics/` directory with content. If it does, the layout is already epic and this command does not apply:

  ```
  This project already has an epics/ directory at <path>.
  /metis:promote-to-epics only applies to flat-layout projects.

  To add a new epic to an existing epic-layout project, run:
    /metis:feature "<description>"
  ```

- `BUILD.md` must exist. The grouping uses it to infer capability seams across the existing task set; without it, promotion is guesswork against the tasks alone.

## Load

- `BUILD.md`. Read in full — the capability cut comes from here.
- Every task file under `tasks/` — frontmatter and Goal only. Bodies are not needed to group; the grouping judgment is capability-level.
- `docs/SYNTHESIS.md` and `docs/INDEX.md` if they exist — orientation for capabilities the tasks cite via `docs_refs`.

## Do not load

- Task bodies. The grouping does not rehydrate each task's Context; it works from title, Goal, `touches`, and `docs_refs`.
- `decisions/`, `scratch/`.
- Source docs directly. `BUILD.md` is the synthesized anchor; re-reading the corpus re-does the build-spec's work.

## Skills

Invoke by reference:

- `decomposing-build-into-epics` — the grouping judgment. Capability-not-category framing, exit-criterion tests, split and merge signals, dependency discipline, batch-level coverage. Read it before proposing the groups; the existing task set is the input the skill cuts into epics rather than a `BUILD.md` section.
- `writing-an-epic-file` — invoked once the grouping is approved, to render each `EPIC.md`.

## Three-phase flow

1. **Propose.** Group the existing tasks into candidate epics. One line per proposed epic: name, one-line capability, one-line exit criterion, the list of task ids it would own. Flag any tasks the grouping could not place cleanly (ambiguous ownership, work that predates current `BUILD.md` capabilities). Ask for approval before anything moves.
2. **Scaffold.** On approval, create `epics/NNN-kebab-name/EPIC.md` for each approved group per `writing-an-epic-file`.
3. **Migrate.** Move task files from `tasks/<id>-*.md` to `epics/<name>/tasks/<id>-*.md`. Update each moved task's frontmatter: add `epic: <name>`. Task ids do not change. After all moves are complete, remove the (now empty) `tasks/` directory.

## Write scope

- `epics/NNN-kebab-name/EPIC.md` per approved epic. Create parent directories.
- `epics/<name>/tasks/<id>-*.md` — moved from `tasks/`, with `epic:` added to frontmatter.
- Removal of the flat `tasks/` directory after all task files have moved.

Do not write to `BUILD.md`, `decisions/`, `docs/`, or `scratch/`. If the grouping surfaces a `BUILD.md` gap (capability the tasks cover but `BUILD.md` does not), flag the finding for the user to address via a hand edit plus `/metis:sync`. If it surfaces an architectural choice worth a standing record, flag it — the decision entry is a separate act.

## Handling the edge cases

- **Tasks that do not fit any epic cleanly.** Surface explicitly. The user decides whether they really are a sibling epic, should be merged into the nearest group, or are superseded work that wants a `done` or `deleted` status before promotion proceeds.
- **Tasks with `id` collisions after rename.** Ids are project-wide and do not change on promotion, so collisions should not occur. If they do (two flat tasks accidentally shared an id), the command stops and surfaces — renaming is a user-driven repair, not a silent fix.
- **Tasks with `depends_on` across proposed epic boundaries.** Allowed — tasks across epics may still depend on each other. Flag the cross-boundary deps so the user can verify the epic dependency graph (`EPIC.md`'s `depends_on` frontmatter) reflects the task-level dependencies honestly.

## Invocation prompt

The command may carry a trailing free-text prompt, e.g. `/metis:promote-to-epics "keep auth and users as one epic; split billing into separate payment and subscription epics"`.

Follow the command-prompts convention in `.metis/conventions/command-prompts.md`. The four rules (augment / flag scope expansion / acknowledge use / resolve named skills) apply; acknowledge prompt usage in the return per rule 3.

The prompt is ephemeral — do not persist it into any `EPIC.md` or task frontmatter.

## Return

- **Proposed grouping** during the propose phase — epics, task ids per epic, unclaimed tasks, cross-boundary dependencies.
- **Files written and moved** during the scaffold and migrate phases — epic paths, task file paths before and after.
- **Removed** — the flat `tasks/` directory once empty.
- **Flagged findings** — architectural gaps, collision situations, orphan tasks.
- **Prompt usage** — one line if a prompt was carried.
- **Next step** — `/metis:pick-task` to resume the feature loop under the epic layout, or `/metis:sync` if the promotion surfaced drift against the baseline.
