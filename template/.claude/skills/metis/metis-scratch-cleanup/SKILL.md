---
name: metis:scratch-cleanup
description: Propose promotions out of scratch/ and deletions of ephemeral content. Waits for approval before moving or deleting.
disable-model-invocation: true
---

# /metis:scratch-cleanup

Walk `scratch/` and propose: which files should be promoted out (to `docs/`, a task's Notes, a `decisions/` entry), which should be deleted, and which should stay. Wait for user approval before acting.

## Preconditions

- `scratch/` must exist. If it does not, stop and point at `/metis:init` — the scratch surface has not been scaffolded yet.
- If `scratch/` is effectively empty (only `CURRENT.md` and `questions.md`, both load-bearing and neither in scope for this command), stop and say so.

## Load

- A listing of every file under `scratch/`, excluding `CURRENT.md` and `questions.md`. The subdirectories in scope: `scratch/plans/`, `scratch/exploration/`, `scratch/research/`, plus any ad hoc files at the root.
- Filename and first-paragraph scan per file. Full contents are loaded only for files the proposal surfaces as promotion candidates, and only at the point the user approves the promotion.
- Previous `scratch/CURRENT.md` handoffs' *Scratch promotions* block, if flagged inline — a session-end's flag is this command's shortlist. Do not re-derive candidates the last session already identified.
- Task frontmatter across the corpus, when classifying `scratch/plans/<id>.md` files — a plan file for a `done` task is deletable, a plan file for an `in-progress` task is load-bearing.

## Do not load

- `CURRENT.md`, `questions.md`. These are the two files in `scratch/` this command deliberately does not touch.
- Task bodies, epic bodies, `BUILD.md`, `decisions/`, source docs. The cleanup classifies scratch; it does not re-read everything else to decide.

## Skills

This command does not invoke a dedicated skill. The judgment it carries — is this file ephemeral, promote-able, or load-bearing — is local enough to sit in the prompt. When a promotion lands as a decision entry, `writing-decisions` is invoked at that step; when a promotion lands as a task's Notes append, the append follows the task-format Notes shape.

## Classification

Every file in scope lands in one of four buckets:

- **Delete.** Ephemeral scratch a future session does not need to read. Spike code for a landed task, web-fetch dumps that were consumed, plans for `done` tasks, research notes whose substance is already in `docs/` or code.
- **Promote to a decision.** A scratch note that has grown into a standing architectural choice — a structural commitment, a pattern the project will need to remember outside the code. Target: `decisions/YYYY-MM-DD-<slug>.md` via `writing-decisions`.
- **Promote to a task's Notes.** A scratch note specific to one task that belongs in that task's Notes — a reviewer's deferred observation, an implementer's follow-up thought. Target: the named task file's Notes section.
- **Promote to `docs/`.** A note that has grown into material a fresh session will want to read on its own — a gotcha, a pattern, a reference table. Target: a new or existing file under `docs/`; if a new file, name the proposed path.
- **Keep.** Still active scratch — plans for tasks in flight, research mid-exploration, notes that do not yet belong anywhere else. Stays in `scratch/` with no action.

## Two-phase flow

1. **Propose.** Render the classification with one line per file and the proposed target for promotions. Wait for approval or redirection.
2. **Act.** On approval, move or delete per the approved classification. Run the move as an actual file operation (the user sees the before and after paths); do not silently copy-without-delete or delete-without-copy.

## Write scope

- Deletions within `scratch/`.
- Moves from `scratch/` to `docs/`, to a task's Notes (append only; do not edit other sections), or to a new `decisions/` entry.

Do not write to `CURRENT.md`, `questions.md`, `BUILD.md`, `BOARD.md`, `EPIC.md` files, or any task file's non-Notes sections. If a promotion to `BUILD.md` seems warranted, that is not a scratch-cleanup move — it is a `/metis:sync` cascade starting from a manual `BUILD.md` edit. Surface the finding rather than land the edit.

## Return

- **Proposed classification** during the propose phase — one line per file, grouped by bucket.
- **Actions taken** during the act phase — one line per move or delete, paths on both sides.
- **Decisions written** — the `decisions/` paths created from promotions, if any.
- **Unclassified** — files the command could not classify with confidence. Surface rather than default-to-keep; user chooses.
- **Next step** — often none (cleanup is self-contained); sometimes `/metis:sync` if a promotion surfaced drift against the baseline.

This command silently accepts and ignores any trailing free-text prompt — the classification is mechanical enough that tuning it per-invocation adds little. A user who wants one bucket emphasized can simply redirect during the approval step.
