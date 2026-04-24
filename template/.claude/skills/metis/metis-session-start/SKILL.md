---
name: metis:session-start
description: Rehydrate a fresh session from on-disk state. Reads CLAUDE.md, scratch/CURRENT.md, BOARD.md, and the active task file if one is in flight.
disable-model-invocation: true
---

# /metis:session-start

Rehydrate a fresh session. Read the minimum set of files that orients the agent to the project's current state without pulling the whole tree into context. The design target for this loading dose is under about 5k tokens total — enough to know what is in flight and where to start, not enough to re-derive the project.

## Preconditions

- No hard preconditions. The command runs even on a bare project; it just reports what is absent.
- If `scratch/CURRENT.md` is missing or empty, the session is the first after `/metis:init` (or the last session ended without running `/metis:session-end`). Report the state and carry on — rehydration proceeds from the rest of the set.

## Load

In this order:

1. **`CLAUDE.md`** — the always-on framing. Auto-loaded by the harness in most configurations; re-read if the harness did not.
2. **`scratch/CURRENT.md`** — the previous session's handoff. The four blocks there (*What happened*, *Current state*, *Open questions*, *Where to start*) are what this command surfaces first.
3. **`BOARD.md`** — the generated task-state index. If it is missing or visibly stale against the task files, note the staleness in the return; do not try to regenerate from this command.
4. **The active task file** — if `scratch/CURRENT.md` names one as in flight, read that file (and the parent `EPIC.md` if the task lives under an epic). This is the concrete next-action anchor.
5. **`scratch/questions.md`** — one-pass read. The committed open-questions file that `scratch/CURRENT.md`'s *Open questions* block is cut from. Useful for questions the prior handoff did not surface.

## Do not load

- `BUILD.md`. The handoff has enough to orient; `BUILD.md` loads at the per-task level where it is actually needed (and usually is not needed because the task file excerpts from it).
- Epics beyond the one the active task lives under.
- Other task files. `BOARD.md` carries their state; bodies are not session-start reading.
- `decisions/`, `docs/`. Neither belongs in rehydration context.
- `scratch/plans/`, `scratch/exploration/`, `scratch/research/`. Ephemeral; they enter context only when the active work pulls them in.

## Write scope

**None.** This is a read-only command. No file is written.

## Return

A tight session-start summary, sized for the *Where to start* line of `CURRENT.md` to be actionable:

- **What happened last session** — one paragraph, cribbed from `CURRENT.md` *What happened*.
- **In flight** — task ids with a one-line pointer. If nothing is in flight, say so.
- **Blocked / queued** — one line each from `CURRENT.md` *Current state*.
- **Open questions** — the pruned list from `CURRENT.md` *Open questions* plus any still-open entries in `scratch/questions.md` not already in the handoff.
- **Where to start** — directly from `CURRENT.md` *Where to start*. Do not rewrite it — pass it through.
- **Anomalies** — anything unexpected: missing `CURRENT.md`, stale `BOARD.md`, an `in-progress` task with no handoff mention, a `scratch/plans/<id>.md` for a task not in flight. Surface rather than absorb.

This command silently accepts and ignores any trailing free-text prompt — session-start is mechanical enough that per-invocation tuning rarely helps. A user who wants the session to focus somewhere specific can say so in the next command.
