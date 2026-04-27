---
name: feature
description: Describe a new feature mid-stream. Produces task files (flat layout) or a new epic with its task set (epic layout).
disable-model-invocation: true
---

# /metis:feature

Absorb a net-new feature into the project mid-stream.

## Argument

- **Required**: a free-text description of the feature. If no description is supplied, stop and ask.

## Preflight

Run `.metis/scripts/feature-preflight.sh`. It exits non-zero if `BUILD.md` is missing or the layout is ambiguous (both `tasks/` and `epics/` populated). On success it reports `MODE` (`flat` / `epic`) and `SPEC_VERSION`.

## Load

- The feature description (the argument).
- `BUILD.md`.
- In epic mode, the names and goals of existing epics (from `EPIC.md` files) so this feature does not duplicate or straddle one; read the full `EPIC.md` only for a sibling whose scope the new feature might overlap.
- `docs/SYNTHESIS.md` and `docs/INDEX.md` if they exist.

## Do not load

- Other epics' task files.
- `decisions/`, `scratch/`.
- `docs/CONTRADICTIONS.md`, `docs/QUESTIONS.md`, `docs/RESOLVED.md`.

## Skills

- `metis:decomposing-build-into-epics` — epic mode, before proposing the new epic.
- `metis:writing-an-epic-file` — epic mode, before scaffolding the epic.
- `metis:decomposing-work-into-tasks` — before proposing tasks.
- `metis:writing-a-task-file` — before writing tasks.

## Two-phase flow

1. **Propose.** Surface the shape: in flat mode, the proposed task set; in epic mode, the new epic (name, goal, exit criterion, dependencies) plus its initial task set. Wait for approval.
2. **Write.** On approval, scaffold the artifacts per the write scope below.

## Write scope

- **Flat mode.** Task files in `tasks/`.
- **Epic mode.** `epics/NNN-kebab-name/EPIC.md` and task files under `epics/NNN-kebab-name/tasks/`. Create the parent directory if absent.

### Do not write to

- `BUILD.md`.
- Sibling epics' files.
- `decisions/`.
- `docs/`.
- `scratch/`.

## Invocation prompt

Follow the command-prompts convention in `.metis/conventions/command-prompts.md`. The four rules (augment / flag scope expansion / acknowledge use / resolve named skills) apply; acknowledge prompt usage in the return per rule 3.

The prompt is ephemeral — do not persist it into the new epic or any task file.

## Return

- **Proposed shape** during the propose phase — task set (flat) or new epic plus task set (epic).
- **Files written** during the write phase — each path, with a one-line summary.
- **Flagged ambiguities** — product-shape or scope calls the description did not commit to.
- **Next step** — `/metis:pick-task`.
