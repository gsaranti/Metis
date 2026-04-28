---
name: generate-tasks
description: Generate task files from BUILD.md or one epic's EPIC.md.
disable-model-invocation: true
---

# /metis:generate-tasks

Generate task files from `BUILD.md` (flat layout) or `epics/<name>/EPIC.md` (epic layout).

## Preflight

Run `${CLAUDE_PLUGIN_ROOT}/.metis/scripts/generate-tasks-preflight.sh <epic-name>` (omit the argument for flat layout). It exits non-zero on layout mismatch, missing epic, regeneration attempt, or ambiguous layout — surface and stop. On success it reports `TARGET` (where new tasks go) and `SPEC_VERSION` (stamp on each task's `spec_version` frontmatter).

## Load

- `BUILD.md` (flat layout) or `epics/<name>/EPIC.md` plus the `BUILD.md` sections it cites (epic layout).
- Source-doc passages on demand when a candidate task needs an excerpt.
- For tasks touching existing code: code from the source tree, via `code-explorer` dispatches.

## Do not load

- Other epics' `EPIC.md` files.
- Other task files.
- `decisions/`, `scratch/`, `docs/CONTRADICTIONS.md`, `docs/QUESTIONS.md`.

## Read first

- `${CLAUDE_PLUGIN_ROOT}/references/decomposing-work-into-tasks.md` — read before proposing the decomposition.
- `${CLAUDE_PLUGIN_ROOT}/references/writing-a-task-file.md` — read before writing task files.

## Two-phase flow

1. **Propose.** Surface the decomposition — Goal, `depends_on`, and source-doc cite per proposed task. Wait for approval or redirection before writing.
2. **Write.** On approval, write each task file at `TARGET/NNNN-kebab-slug.md`.

## Write scope

- Task files under `TARGET` from the preflight. Create the directory if absent.
- `scratch/questions.md` — append an entry when task-writing surfaces a local ambiguity that the main session should pick up later.

Do not write to `BUILD.md`, `EPIC.md`, `decisions/`, `docs/`, or `scratch/` beyond `questions.md`.

## Invocation prompt

Trailing prompt: see `${CLAUDE_PLUGIN_ROOT}/.metis/conventions/command-prompts.md`.

## Return

- **Proposed set** during the propose phase — ids, titles, dependencies.
- **Files written** during the write phase — one line per task file path.
- **Flagged ambiguities** — architectural calls the body of work did not commit to.
- **Next step** — `/metis:skeleton-plan` on the first call for a project, `/metis:pick-task` afterwards.
