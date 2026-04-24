---
name: metis:reconcile
description: Read the docs corpus and produce SYNTHESIS.md, INDEX.md, CONTRADICTIONS.md, and QUESTIONS.md — the reconcile artifacts that make Phase 0 walkable.
disable-model-invocation: true
---

# /metis:reconcile

Read everything under `docs/`. Produce four reconcile artifacts: `docs/SYNTHESIS.md`, `docs/INDEX.md`, `docs/CONTRADICTIONS.md`, `docs/QUESTIONS.md`. Stop there — this command captures open items; `/metis:walk-open-items` walks them.

## Preconditions

- `docs/` must exist at the project root. If it does not, stop and point the user at the likely-correct move:

  ```
  /metis:reconcile expects a docs/ directory at the project root
  and did not find one.

  If this is a docs-first project and the directory is missing, create
  docs/ and add the source material first. If this is a prompt-seeded
  or existing-codebase project with no docs to reconcile, skip to
  /metis:build-spec with a prompt describing what to build.
  ```

- If `docs/SYNTHESIS.md`, `docs/INDEX.md`, `docs/CONTRADICTIONS.md`, or `docs/QUESTIONS.md` already exist, this is a re-reconcile — load the prior items so the capture can detect `stale` entries against doc drift rather than re-surfacing them from scratch. Do not silently overwrite an existing `docs/RESOLVED.md`; it is archival and is not read during a walk.

## Load

- The source docs under `docs/`, excluding the four reconcile outputs and `RESOLVED.md`. Use the sizing heuristic from the handoff (`wc -w × 1.3` for prose, up to × 1.8 for schema-heavy) to judge whether the corpus fits in one read. Over ~80k tokens, read a coherent slice at a time rather than the whole corpus; over ~150k, surface that the corpus is larger than this command can hold honestly and propose pruning before continuing.
- Any prior `docs/CONTRADICTIONS.md` and `docs/QUESTIONS.md`, to detect `stale` items on re-reconcile.

## Do not load

- `docs/RESOLVED.md`. Archival only.
- `BUILD.md`. `BUILD.md` is written downstream of this command; loading it biases the capture toward the synthesis that will follow.
- Anything under `decisions/`, `tasks/`, `epics/`, or `scratch/`. This command reconciles the docs corpus, not the downstream record.

## Skills

Invoke by reference — read the skill file itself, do not paraphrase from memory:

- `reconciling-docs` — the primary teaching for this command. The cross-referential read, contradiction-vs-gray-area distinction, framing-without-resolving, stale detection on re-reconcile, and batch-level check for the output set. Read it before starting the read.

## Write scope

Four files in `docs/`:

- `docs/SYNTHESIS.md` — overwrite.
- `docs/INDEX.md` — overwrite.
- `docs/CONTRADICTIONS.md` — overwrite the open and deferred sections; preserve the `stale` marker on any items whose cited passages have drifted since prior capture.
- `docs/QUESTIONS.md` — same treatment as `CONTRADICTIONS.md`.

Do not write to `docs/RESOLVED.md`, any source doc under `docs/`, `decisions/`, or `BUILD.md`. Resolution lives in `/metis:walk-open-items`; decisions are not written in Phase 0.

## Invocation prompt

The command may carry a trailing free-text prompt, e.g. `/metis:reconcile "give special weight to docs/billing.md, it's the most recent"`.

Follow the command-prompts convention in `.metis/conventions/command-prompts.md`. The four rules (augment / flag scope expansion / acknowledge use / resolve named skills) apply; acknowledge prompt usage in the return per rule 3.

The prompt is ephemeral — do not persist it into any of the four output files.

## Return

One message to the user:

- **Files written** — the four paths with one-line contents summaries (e.g., *"CONTRADICTIONS.md: 3 open, 0 deferred, 1 stale"*).
- **Coverage** — which docs were read in full vs. sliced, and any passages deliberately deferred to a later pass.
- **Next step** — name `/metis:walk-open-items` when there are open or stale items, or `/metis:build-spec` when the corpus was empty-handed enough to skip the walk.
- **Prompt usage** — if the invocation carried a prompt, one line on how it shaped the read.
