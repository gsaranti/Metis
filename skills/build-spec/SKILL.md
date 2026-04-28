---
name: build-spec
description: Produce BUILD.md — the project's forward-looking architecture brief.
disable-model-invocation: true
---

# /metis:build-spec

Produce `BUILD.md` at the project root.

## Preflight

Run `.metis/scripts/build-spec-preflight.sh` before drafting. It exits non-zero if `BUILD.md` already exists (surface the error, point the user at `/metis:sync`, and stop). Otherwise it reports `DOCS_PRESENT`, `RECONCILE_DONE`, and `WALK_PENDING`.

## Input shape

Determined from the preflight + the trailing prompt:

- **Docs-first ready** — `DOCS_PRESENT=yes`, `RECONCILE_DONE=yes`, `WALK_PENDING=no`. Synthesize from the reconciled corpus.
- **Reconcile or walk pending** — `RECONCILE_DONE=no` or `WALK_PENDING=yes`. Suggest the prerequisite command (`/metis:reconcile` or `/metis:walk-open-items`) and proceed only if the user explicitly insists.
- **No docs** — `DOCS_PRESENT=no`. The trailing prompt is required; if absent, stop and ask. If present, classify as **prompt-seeded** (fresh project) or **existing-codebase** (delta on top of code in the repo) based on what the prompt describes.

## Load

- For docs-first: `docs/SYNTHESIS.md`, `docs/INDEX.md`, and the source docs under `docs/` at the cited passages.
- For existing-codebase: the relevant code, on demand.
- Any `decisions/` entries that exist. Grep by slug; do not bulk-read.
- `docs/research/INDEX.md` and the research notes it points at — for technical commitments the corpus alone does not settle.

## Do not load

- `docs/CONTRADICTIONS.md`, `docs/QUESTIONS.md`, `docs/RESOLVED.md`.
- `tasks/`, `epics/`, `scratch/`.

## Skills

Invoke `metis:writing-build-spec` by reference — read the skill file before drafting.

## Write scope

One file: `BUILD.md` at the project root.

Do not write to `decisions/`, `docs/`, `tasks/`, `epics/`, or `scratch/`.

## Invocation prompt

Follow the command-prompts convention in `.metis/conventions/command-prompts.md`. The four rules (augment / flag scope expansion / acknowledge use / resolve named skills) apply; acknowledge prompt usage in the return per rule 3.

The prompt is ephemeral — do not persist it into `BUILD.md`.

## Return

One message to the user:

- **Path written** — `BUILD.md`, with one-line summary of the risk lead and the first-vertical-slice section.
- **Open assumptions** — anything the brief committed to that the corpus did not settle, surfaced so the user can audit the bet before epic breakdown.
- **Next step** — `/metis:epic-breakdown` for medium/large projects, `/metis:generate-tasks` for small ones.
