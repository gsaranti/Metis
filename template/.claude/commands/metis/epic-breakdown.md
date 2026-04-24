---
description: Propose eight to fifteen capability-sized epics from BUILD.md and, after approval, scaffold the epics/ directory with one EPIC.md per epic.
argument-hint: [optional free-text prompt]
---

# /metis:epic-breakdown

Read `BUILD.md`. Propose a set of capability-sized epics — typically eight to fifteen — and, after the user approves the shape, scaffold `epics/<NNN-name>/EPIC.md` for each. Task files are not created by this command; `/metis:generate-tasks <epic>` handles that per-epic.

## Preconditions

- `BUILD.md` must exist at the project root. If it does not, stop and point at `/metis:build-spec`:

  ```
  /metis:epic-breakdown needs BUILD.md to cut from, and did not
  find one.

  Run /metis:build-spec first, or /metis:promote-to-epics if this
  project already has a flat tasks/ directory you want to graduate
  into an epic layout.
  ```

- A flat `tasks/` directory with content is an incompatible layout for this command. If it exists and is non-empty, stop and point at `/metis:promote-to-epics`:

  ```
  This project has a flat tasks/ directory with existing task files.
  /metis:epic-breakdown would create an ambiguous layout.

  To graduate this project to an epic layout, run:
    /metis:promote-to-epics

  To keep the flat layout and add more tasks, run:
    /metis:generate-tasks
  ```

- An `epics/` directory containing existing `EPIC.md` files means this command is being re-run on an already-broken-down project. Stop and name the state; point at `/metis:feature` for mid-stream additions or at a manual path for deliberate re-decomposition.

## Load

- `BUILD.md` in full. It is the input this skill cuts from.
- `docs/SYNTHESIS.md` and `docs/INDEX.md` if they exist — orientation for the capabilities `BUILD.md` references.

## Do not load

- Source docs under `docs/` directly. `BUILD.md` is the synthesized input; re-reading the corpus re-does the build-spec's work.
- `decisions/`, `tasks/`, `scratch/`, `BOARD.md`. None of these inform the capability cut.
- Any already-present `epics/` beyond confirming the preconditions above.

## Skills

Invoke by reference:

- `decomposing-build-into-epics` — the primary teaching. Capability-not-category framing, splitting and merging signals, the epic-shaped-vs-not tests, dependency discipline, batch-level coverage check.
- `writing-an-epic-file` — invoked once the user approves the cut, to render each `EPIC.md`.

Read `decomposing-build-into-epics` before proposing the set; read `writing-an-epic-file` before scaffolding files.

## Two-phase flow

1. **Propose.** Surface the proposed epic list with name, one-line capability, one-line exit criterion, and declared `depends_on` where applicable. Flag any structural ambiguity the breakdown surfaced (a product-shape call `BUILD.md` did not commit to) and ask rather than taking a side. Wait for user approval or redirection before writing anything.
2. **Scaffold.** On approval, create `epics/NNN-kebab-name/` for each, with `EPIC.md` populated per `writing-an-epic-file`. Do not create `tasks/` subdirectories yet — the first `/metis:generate-tasks <epic>` call creates them.

## Write scope

- `epics/NNN-kebab-name/EPIC.md` per approved epic. Create the parent directory if absent.

Do not write to `BUILD.md`, `decisions/`, `docs/`, `tasks/`, `scratch/`, or `BOARD.md`. If the breakdown surfaces a question `BUILD.md` needs to settle, that is a finding to surface — not a `BUILD.md` edit from inside this command.

## Invocation prompt

The command may carry a trailing free-text prompt, e.g. `/metis:epic-breakdown "prefer vertical slices over horizontal layers; keep the first epic demo-able in a week"`. Four rules:

1. **Augment, do not replace.** `BUILD.md` and the capability-level cut remain authoritative. If the prompt asks for a cut that contradicts `BUILD.md` commitments, flag the conflict rather than silently rewriting the build spec from here.
2. **Flag scope expansion.** If the prompt asks the breakdown to reach beyond `BUILD.md` (seed new capabilities, bring in work from outside the brief), note the expansion rather than quietly doing it.
3. **Acknowledge use explicitly.** State in the return how the prompt shaped the cut — which seam it biased toward, which ordering it pinned.
4. **Resolve named skills.** The prompt may name additional skills for this turn. Resolve each reference the same way any skill reference is resolved, across whatever skill sources the runtime exposes. Acknowledge each invoked skill's influence; flag unresolvable names rather than guessing. User-referenced skills augment `decomposing-build-into-epics` and `writing-an-epic-file`; they do not override the exit-criterion test or the capability-not-category framing.

The prompt is ephemeral — do not persist it into any `EPIC.md` or epic directory metadata.

## Return

- **Proposed set** during the propose phase — names, capabilities, exit criteria, dependencies. Ask for approval before writing.
- **Files written** during the scaffold phase — each `epics/NNN-name/EPIC.md` path.
- **Flagged ambiguities** — product-shape calls `BUILD.md` did not commit to, surfaced for upstream resolution rather than absorbed into the cut.
- **Next step** — `/metis:generate-tasks <first-epic-name>` to populate the first epic's task set. Generate tasks for the first epic only; learning from it will shape later breakdowns.
- **Prompt usage** — if the invocation carried a prompt, one line on how it shaped the cut.
