---
name: reconcile
description: Read the docs corpus and produce SYNTHESIS.md, INDEX.md, CONTRADICTIONS.md, and QUESTIONS.md.
disable-model-invocation: true
---

# /metis:reconcile

Read everything under `docs/`. Produce four reconcile artifacts: `docs/SYNTHESIS.md`, `docs/INDEX.md`, `docs/CONTRADICTIONS.md`, `docs/QUESTIONS.md`.

## Preflight

Run `.metis/scripts/reconcile-preflight.sh` before reading. It exits non-zero if `docs/` is missing (surface the error and stop). Otherwise it reports `STATUS` (`fresh` / `rereconcile`), `SIZE_CLASS` (`small` / `medium` / `large`), and counts for the corpus and any prior items.

On `SIZE_CLASS=large`, apply the slicing guidance in `references/reconciling-docs.md`.

## Load

- The source docs under `docs/`.
- On `rereconcile`, the prior `docs/CONTRADICTIONS.md` and `docs/QUESTIONS.md`. Re-reconcile preserves prior items and re-checks them against the current corpus (per the `references/reconciling-docs.md` skill) rather than starting over.

## Do not load

- `docs/RESOLVED.md`.
- `BUILD.md`.
- Anything under `decisions/`, `tasks/`, `epics/`, or `scratch/`.

## Read first

`references/reconciling-docs.md` — read before drafting any of the output artifacts.

## Write scope

Four files in `docs/`:

- `docs/SYNTHESIS.md` — overwrite.
- `docs/INDEX.md` — overwrite.
- `docs/CONTRADICTIONS.md` — overwrite; preserve items marked `stale`.
- `docs/QUESTIONS.md` — same treatment as `CONTRADICTIONS.md`.

Do not write to `docs/RESOLVED.md`, any source doc under `docs/`, `decisions/`, or `BUILD.md`.

## Invocation prompt

Trailing prompt: see `.metis/conventions/command-prompts.md`.

## Return

One message to the user:

- **Files written** — four paths with item counts per `CONTRADICTIONS.md` / `QUESTIONS.md` (open / deferred / stale).
- **Coverage** — which docs were read in full vs. sliced, and any passages deliberately deferred to a later pass. On `SIZE_CLASS=large`, include the completeness caveat here.
- **Next step** — `/metis:walk-open-items` when there are open or stale items; `/metis:build-spec` when the open set is empty.
