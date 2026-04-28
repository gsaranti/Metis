---
name: session-start
description: Rehydrate a fresh session from on-disk state.
disable-model-invocation: true
---

# /metis:session-start

Read the minimum set of files that orients the agent to the project's current state.

## Preconditions

No hard preconditions. Missing state surfaces as an Anomaly in the Return.

## Load

In this order:

1. **`scratch/CURRENT.md`** — the previous session's handoff.
2. **The active task file** — if `scratch/CURRENT.md` names one as in flight, read that file (and the parent `EPIC.md` if the task lives under an epic).
3. **`scratch/questions.md`** — one-pass read; may carry questions beyond the CURRENT.md block.

## Do not load

- `BUILD.md`.
- Epics beyond the one the active task lives under.
- Other task files.
- `decisions/`, `docs/`.
- `scratch/plans/`, `scratch/exploration/`.

## Write scope

**None.**

## Return

- **What happened last session** — one paragraph from `CURRENT.md` *What happened*.
- **In flight** — task ids with a one-line pointer. If nothing is in flight, say so.
- **Blocked / queued** — one line each from `CURRENT.md` *Current state*.
- **Open questions** — the pruned list from `CURRENT.md` *Open questions* plus any still-open entries in `scratch/questions.md` not already in the handoff.
- **Where to start** — directly from `CURRENT.md` *Where to start*. Do not rewrite — pass it through.
- **Anomalies** — anything unexpected: missing `CURRENT.md`, an `in-progress` task with no handoff mention, a `scratch/plans/<id>.md` for a task not in flight. Surface rather than absorb.

## Invocation prompt

Silently accept and ignore any trailing free-text prompt.
