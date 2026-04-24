---
name: metis:generate-tasks
description: Generate task files from BUILD.md (flat layout) or one epic's EPIC.md (epic layout). The argument shape must match the filesystem shape.
disable-model-invocation: true
---

# /metis:generate-tasks

Generate a batch of well-formed task files from a body of work. Argument shape follows filesystem shape — and the command errors out helpfully on mismatch rather than inferring.

## Argument and layout

- **No argument, flat layout.** The project has a flat `tasks/` directory (or no tasks surface yet) and no `epics/` directory. Generate into `tasks/`. Cut from `BUILD.md`.
- **Epic-name argument, epic layout.** The project has an `epics/` directory with the named epic present. Generate into `epics/<name>/tasks/`. Cut from `epics/<name>/EPIC.md`, bounded by the epic's scope and exit criterion; `BUILD.md` is loaded only where the epic's scope turns on one of its sections.

The shape mismatches get helpful errors naming what is on disk:

```
This command was run without an epic argument, but this project has
an epics/ directory. /metis:generate-tasks requires an epic name in
an epic layout.

Run:
  /metis:generate-tasks <epic-name>

Or, if this project has outgrown epics and you want a flat layout,
that is a larger refactor — start a conversation rather than running
this command.
```

```
This command was run with epic name "<name>", but this project has
a flat tasks/ directory and no epics/ directory.

Run without an argument to generate into tasks/:
  /metis:generate-tasks

If you intended to graduate this project to an epic layout, run:
  /metis:promote-to-epics
```

```
This command was run with epic name "<name>", but epics/<name>/ does
not exist. The epics currently on disk are: <list>.

Run /metis:epic-breakdown to create epics, or pass one of the
existing names.
```

## Regeneration

If the target directory already has task files, this command refuses regeneration. Doc or spec drift is `/metis:sync` territory; new work is `/metis:feature` territory:

```
tasks/ (or epics/<name>/tasks/) already contains task files.

This command does not regenerate existing task sets. For:
  - propagating a BUILD.md or doc change through existing tasks,
      run /metis:sync
  - adding a new feature or cluster of tasks mid-stream,
      run /metis:feature "<description>"
  - reconciling hand-written code against the task record,
      run /metis:log-work
```

## Load

- The body of work being cut — `BUILD.md` in the flat shape, or `<epic>/EPIC.md` in the epic shape. Plus any `BUILD.md` sections the epic explicitly cites.
- `.metis/config.yaml` for the current `spec_version` to stamp new tasks with.
- The source-doc passages each candidate task will excerpt, opened at the cited sections rather than loaded in full.

## Do not load

- Other epics' `EPIC.md` files. The cut is bounded by the one epic (or `BUILD.md` in flat mode), not by the sibling set.
- Other task files. Dependencies are named by id; the contents of other tasks do not inform this batch.
- `BOARD.md`, `decisions/`, `scratch/`, `docs/CONTRADICTIONS.md`, `docs/QUESTIONS.md`. None of these feed the cut.

## Skills

Invoke by reference:

- `decomposing-work-into-tasks` — the cut. Task-shape judgment, split/merge signals, `depends_on` discipline, structural-ambiguity flagging, batch-level coverage and independence checks.
- `writing-a-task-file` — invoked once the decomposition is approved, to render each task file.

Read `decomposing-work-into-tasks` before proposing the unit set; read `writing-a-task-file` before writing files.

## Two-phase flow

1. **Propose.** Surface the decomposition — one line per proposed task with its Goal, a short `depends_on` note where applicable, and the source-doc excerpt each will carry. Flag any structural ambiguity (an architectural call the body of work did not commit to) and ask rather than encoding a guess across the batch. Wait for approval or redirection.
2. **Write.** On approval, write each task file at `tasks/NNNN-kebab-slug.md` (flat) or `epics/<name>/tasks/NNNN-kebab-slug.md` (epic). Take the next unused project-wide id; gaps are expected and are not reused.

## Write scope

- Task files under `tasks/` (flat) or `epics/<name>/tasks/` (epic). Create the parent directory if absent.

Do not write to `BUILD.md`, `EPIC.md`, `decisions/`, `docs/`, or `scratch/`. If the decomposition surfaces a question the body of work needs to settle, that is a finding to surface rather than a silent upstream edit.

## Invocation prompt

The command may carry a trailing free-text prompt, e.g. `/metis:generate-tasks 002-billing "small tasks; prefer one endpoint per task"`.

Follow the command-prompts convention in `.metis/conventions/command-prompts.md`. The four rules (augment / flag scope expansion / acknowledge use / resolve named skills) apply; acknowledge prompt usage in the return per rule 3.

The prompt is ephemeral — do not persist it into any task file or frontmatter.

## Return

- **Proposed set** during the propose phase — ids, titles, dependencies, structural flags.
- **Files written** during the write phase — one line per task file path.
- **Flagged ambiguities** — architectural calls the body of work did not commit to, surfaced for upstream resolution.
- **Next step** — `/metis:skeleton-plan` on the first call for a project, `/metis:pick-task` afterwards.
- **Prompt usage** — if the invocation carried a prompt, one line on how it shaped the cut.
