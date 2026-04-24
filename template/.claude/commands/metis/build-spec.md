---
description: Produce BUILD.md — the project's forward-looking, risk-first architecture brief — from the reconciled docs corpus or from a seed prompt when no docs exist.
argument-hint: [optional free-text prompt describing what to build]
---

# /metis:build-spec

Produce `BUILD.md` at the project root. `BUILD.md` is the forward-looking architecture brief epic breakdown is cut from and downstream drift checks compare against. Write it in the agent's own words; do not transcribe the docs.

## Preconditions

- If `BUILD.md` already exists at the project root, stop and name the situation. An existing `BUILD.md` is not rewritten by this command — that is `/metis:sync` territory, with the accompanying decision. The user may override by deleting `BUILD.md` first, but the default is to refuse:

  ```
  BUILD.md already exists at the project root.

  /metis:build-spec only creates the initial BUILD.md. To edit it:
    /metis:sync  — for propagating a doc-layer change through BUILD.md
                   with a decisions/ entry recording the shift.
    Hand edit, then run /metis:sync to cascade the change.
  ```

- At least one of the following inputs must be present: `docs/` with source material, a trailing prompt describing what to build, or both. With neither, stop and ask the user to supply one — this command does not invent a project out of nothing.

## Input shape

The command runs in three shapes:

- **Docs-first.** `docs/` carries the source corpus. `docs/SYNTHESIS.md` and `docs/INDEX.md` orient the read; the source docs are the synthesis target. A prompt, if supplied, augments the read but does not replace it.
- **Prompt-seeded, no docs.** `docs/` is empty or absent. The trailing prompt is the seed. Ask clarifying questions before writing if the prompt is too thin to commit to a risk lead or a first slice.
- **Existing codebase, no docs.** `docs/` is empty or absent, and the repo contains substantial existing code. The trailing prompt describes the delta — what this build adds, changes, or replaces on top of what exists. Explore the codebase natively to ground the synthesis, but write the brief forward-looking ("what we're building") rather than as a system tour.

## Load

- `docs/SYNTHESIS.md` and `docs/INDEX.md` if they exist — orientation.
- Source docs under `docs/` at the passages the brief will synthesize from. Re-open at the cited sections rather than working from the orientation's paraphrase.
- For the existing-codebase shape: the relevant code, explored on demand. Load as input to synthesis, not as material for a tour.
- Any `decisions/` entries that already exist (they rarely do this early, but may on a re-seeded project). Grep by slug; do not bulk-read.

## Do not load

- `docs/CONTRADICTIONS.md`, `docs/QUESTIONS.md`, `docs/RESOLVED.md`. If the walk is complete, their substance lives in the source docs already; loading them re-surfaces items the baseline has absorbed. If the walk is not complete, this command is premature — stop and point at `/metis:walk-open-items`.
- `tasks/`, `epics/`, `scratch/`. Downstream surface; the brief does not know about them yet.
- `BOARD.md`. Generated; carries no new input.

## Skills

Invoke by reference:

- `writing-build-spec` — the primary teaching for this command. Risk-first framing, own-words rule, excerpt-vs-summarize discipline, the forward-looking constraint for existing-codebase projects, what the brief covers, and the concrete first-vertical-slice section. Read it before drafting.

## Write scope

One file:

- `BUILD.md` at the project root.

Do not write to `decisions/`, `docs/`, `tasks/`, `epics/`, or `scratch/`. This is the initial creation — no decision entry is required for the first write (that obligation begins once `BUILD.md` exists and later edits against it need a standing record).

## Invocation prompt

The command may carry a trailing free-text prompt, e.g. `/metis:build-spec "a task-tracking app with auth, teams, and weekly digest emails"` or `/metis:build-spec "lean the architecture toward event-sourced; we already run Kafka"`. Four rules:

1. **Augment, do not replace.** When `docs/` exists, the prompt augments the corpus; the docs remain authoritative on commitments they have already specified. When `docs/` is empty, the prompt is the seed. If the prompt genuinely contradicts a doc commitment, flag the conflict — the resolution is a `/metis:walk-open-items` round, not a silent override here.
2. **Flag scope expansion.** If the prompt widens the brief beyond what the corpus or the seed support, note the expansion rather than quietly writing past it.
3. **Acknowledge use explicitly.** State in the return how the prompt shaped the brief — which risk it nudged to the lead, which assumption it supplied, which scope it narrowed.
4. **Resolve named skills.** The prompt may name additional skills — Metis's own, user-authored, or project-specific; local or global — for this turn. Resolve each reference the same way any skill reference is resolved, across whatever skill sources the runtime exposes. Acknowledge each invoked skill's influence in the return; flag unresolvable names rather than guessing. User-referenced skills augment `writing-build-spec`; they do not override the risk-first framing or the own-words rule.

The prompt is ephemeral — do not persist it into `BUILD.md` or anywhere else.

## Return

One message to the user:

- **Path written** — `BUILD.md`, with one-line summary of the risk lead and the first-vertical-slice section.
- **Inputs used** — which docs, which code paths (for existing-codebase projects), and whether the prompt supplied the seed or augmented the read.
- **Open assumptions** — anything the brief committed to that the corpus did not settle, surfaced so the user can audit the bet before epic breakdown.
- **Next step** — `/metis:epic-breakdown` for medium/large projects, `/metis:generate-tasks` for small ones.
- **Prompt usage** — if the invocation carried a prompt, one line on how it shaped the brief.
