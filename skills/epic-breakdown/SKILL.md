---
name: epic-breakdown
description: Propose capability-sized epics from BUILD.md and scaffold the epics/ directory.
disable-model-invocation: true
---

# /metis:epic-breakdown

Read `BUILD.md`. Propose a set of capability-sized epics; on approval, scaffold `epics/<NNN-name>/EPIC.md` for each.

## Preflight

Run `.metis/scripts/epic-breakdown-preflight.sh` before drafting. It exits non-zero with a specific error if `BUILD.md` is missing, a flat `tasks/` directory has content, or `epics/` already contains `EPIC.md` files. Surface the error and stop.

## Load

- `BUILD.md` in full.
- `docs/SYNTHESIS.md` and `docs/INDEX.md` if they exist.

## Do not load

- Source docs under `docs/`.
- `decisions/`, `tasks/`, `scratch/`.

## Read first

- `../../references/decomposing-build-into-epics.md` — read before proposing the epic set.
- `../../references/writing-an-epic-file.md` — read before scaffolding files.

## Two-phase flow

1. **Propose.** Surface the proposed epic list with name, one-line capability, one-line exit criterion, and `depends_on` where applicable. Wait for user approval or redirection before writing anything.
2. **Scaffold.** On approval, create `epics/NNN-kebab-name/` for each, with `EPIC.md` populated per `../../references/writing-an-epic-file.md`. Do not create `tasks/` subdirectories.

## Write scope

- `epics/NNN-kebab-name/EPIC.md` per approved epic. Create the parent directory if absent.

Do not write to `BUILD.md`, `decisions/`, `docs/`, `tasks/`, or `scratch/`.

## Invocation prompt

Follow the command-prompts convention in `.metis/conventions/command-prompts.md`. The four rules (augment / flag scope expansion / acknowledge use / resolve named skills) apply; acknowledge prompt usage in the return per rule 3.

The prompt is ephemeral — do not persist it into any `EPIC.md`.

## Return

- **Proposed set** during the propose phase — names, capabilities, exit criteria, dependencies.
- **Files written** during the scaffold phase — each `epics/NNN-name/EPIC.md` path.
- **Flagged ambiguities** — product-shape calls `BUILD.md` did not commit to, surfaced for upstream resolution.
- **Next step** — `/metis:generate-tasks <first-epic-name>` to populate the first epic's task set.
