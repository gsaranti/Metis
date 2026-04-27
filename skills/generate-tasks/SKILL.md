---
name: generate-tasks
description: Generate task files from BUILD.md or one epic's EPIC.md.
disable-model-invocation: true
---

# /metis:generate-tasks

Generate task files from `BUILD.md` (flat layout) or `epics/<name>/EPIC.md` (epic layout).

## Preflight

Run `.metis/scripts/generate-tasks-preflight.sh <epic-name>` (omit the argument for flat layout). It exits non-zero on layout mismatch, missing epic, regeneration attempt, or ambiguous layout — surface and stop. On success it reports `TARGET` (where new tasks go) and `SPEC_VERSION` (stamp on each task's `spec_version` frontmatter).

## Load

- `BUILD.md` (flat layout) or `epics/<name>/EPIC.md` plus the `BUILD.md` sections it cites (epic layout).
- Source-doc passages on demand when a candidate task needs an excerpt.

## Do not load

- Other epics' `EPIC.md` files.
- Other task files.
- `decisions/`, `scratch/`, `docs/CONTRADICTIONS.md`, `docs/QUESTIONS.md`.

## Skills

- `metis:decomposing-work-into-tasks` — read before proposing the decomposition.
- `metis:writing-a-task-file` — read before writing task files.

## Two-phase flow

1. **Propose.** Surface the decomposition — Goal, `depends_on`, and source-doc cite per proposed task. Wait for approval or redirection before writing.
2. **Write.** On approval, write each task file at `TARGET/NNNN-kebab-slug.md`.

## Write scope

- Task files under `TARGET` from the preflight. Create the directory if absent.

Do not write to `BUILD.md`, `EPIC.md`, `decisions/`, `docs/`, or `scratch/`.

## Invocation prompt

Follow the command-prompts convention in `.metis/conventions/command-prompts.md`. The four rules (augment / flag scope expansion / acknowledge use / resolve named skills) apply; acknowledge prompt usage in the return per rule 3.

The prompt is ephemeral — do not persist it into any task file or frontmatter.

## Return

- **Proposed set** during the propose phase — ids, titles, dependencies.
- **Files written** during the write phase — one line per task file path.
- **Flagged ambiguities** — architectural calls the body of work did not commit to.
- **Next step** — `/metis:skeleton-plan` on the first call for a project, `/metis:pick-task` afterwards.
