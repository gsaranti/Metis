---
name: writing-retros
description: Reference for writing one epic retro — per-task estimation entries, replans named with the signal that would have caught them, assumption failures distinguished from implementation slips, and all of it sized for improvement rather than reassurance.
disable-model-invocation: true
---

# Writing retros

An epic retro is the record of what the next epic should do differently — written to `epics/<name>/retro.md` at epic close. The job of this skill is to render that record as signal — per-task estimation, replans with the lesson named, assumption failures against the starting docs — rather than as a narrative of the epic's arc or an overall verdict on how it went.

Two failure modes pull against each other. Reassurance absorbs per-task misses into gestalt lines — "most tasks landed close to estimate" tells the next breakdown nothing because it hides which tasks slipped, by how much, and what shape they shared. Self-flagellation mirrors the same error from the opposite side — every surprise narrated as a miss, every replan phrased as an apology — and buries the handful of entries that would actually change the next epic under noise. Both leave the next retro's reader where they started.

## Read first

- The `EPIC.md` being retroed. The starting goal, the exit criterion, and the scope lines are the anchor against which the retro's entries name drift.
- The epic's task files. Per-task estimation and replanning entries require each task's record — `BOARD.md` is not enough, and a gestalt read of the epic cannot produce per-task signal.

Decisions made during the epic live in `decisions/` and are findable by slug; the retro does not bulk-load that corpus. Load a specific decision only when an entry turns on it.

## Artifact shape

There is no convention file for a retro. Five blocks, each with its own judgment:

- **Estimation accuracy** — per task, not gestalt. One line for every task in the epic, naming the actual-vs-planned shape (time, scope, or complexity) or "tracked as planned."
- **Replans** — tasks that were rewritten or split mid-flight, each with the task id, the shift, and the signal that would have surfaced it at task-write time. Absent when the breakdown held.
- **Assumption failures** — Phase 1 positions (in `BUILD.md`, in the `EPIC.md`, in a starting decision) that the epic's work proved wrong. One line per, naming the assumption verbatim and the shape the code settled on.
- **Task-breakdown lessons** — patterns across the epic's tasks: splits that were too large, splits that were too small, dependencies that did not land. Absent when no pattern emerged.
- **Scratch promotions** — scratch files that became load-bearing mid-epic and should leave `scratch/` before the directory is cleaned. The retro flags; it does not move. Absent when no promotions are due.

An empty block is fine. Manufacturing entries to fill each one is the mirror image of absorbing them into gestalt.

## Per-task, not gestalt

The estimation block names each task individually. "Most tasks landed close to estimate" tells the next epic nothing — the signal is which tasks slipped, by how much, and what shape they shared. Per-task entries let the next breakdown notice patterns that only emerge across tasks: that all the schema tasks undershot by a third, that the integration tasks consistently missed on test-harness setup, that the one unusually small task actually needed its own epic. A gestalt line reads as reassurance and asks the reader to take the writer's feel on faith; the per-task list shows the shape at a glance.

## Replans are signal, not apology

Each replan entry names three things: the task id, what shifted, and what would have surfaced the shift at task-write time if the writer had seen it. The third is the one the entry earns its keep on. "0007 was harder than expected" records that a replan happened; "0007 split into 0007+0014 when the session-cookie logic turned out to share a signing primitive with CSRF; reading `docs/security.md §Cross-cutting` at decomposition would have caught it" gives the next breakdown something to do differently. The first shape is narration; the second is signal.

## Assumption failures vs. implementation slips

Not every surprise belongs in the retro. An assumption failure is a Phase 1 position — a `BUILD.md` commitment, an `EPIC.md` scope line, a starting decision — that the epic's work proved wrong. A typo, a library quirk, a flaky test is not. The test: would a reader of the starting docs have expected the epic to land the way it did? If no, and the gap is architectural, it is an assumption failure worth recording. If yes, the slip is local and belongs in the task's own Notes, not in the retro. Conflating the two pads the block with churn and hides the two or three entries that would actually shape the next epic's planning.

## For improvement, not reassurance

No self-congratulation; no self-flagellation. "The team pushed hard on this one" is reassurance content — it does not change what the next epic does. "I failed to anticipate the migration complexity" is the mirror image — it narrates guilt rather than pointing at what the next epic should check. Every entry should name something the next epic can act on: a specific passage to read at decomposition, a tighter task size for a particular shape of work, a check before committing to a starting assumption.

## Sizing as feedback

Short by default — one to two pages. A retro that runs longer is usually narrating the epic's story rather than naming the deltas against starting assumptions. Push the narrative back to the task Notes and decisions that already hold it; the retro is only what changed between the starting docs and what shipped. If retros are routinely running long across epics, the upstream assumption-setting — in `BUILD.md` or in epic scope — is drifting loose, and that itself is signal worth surfacing.

## Examples

- `examples/good-retro.md` — a post-epic retro with per-task estimation entries, one replan with its prevention signal named, one assumption failure against a `BUILD.md` line, one task-breakdown lesson, and one scratch promotion flagged for cleanup. **Read this before your first retro in a session.**
