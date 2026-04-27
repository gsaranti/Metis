---
name: skeleton-plan
description: Plan the thinnest end-to-end slice. Read-only.
disable-model-invocation: true
---

# /metis:skeleton-plan

Plan how to build the first end-to-end slice: one route, one screen, one database write, one passing test — all in one deployable shape.

## Preconditions

- `BUILD.md` must exist and must name a first vertical slice. If it does not, stop and name the gap:

  ```
  /metis:skeleton-plan needs BUILD.md to name a concrete first
  vertical slice. If BUILD.md is missing, run /metis:build-spec.
  If it exists but skips the "first vertical slice" section, the
  architecture has not committed enough to plan a skeleton against
  yet — amend BUILD.md with a concrete slice first.
  ```

- If task files exist for the work the skeleton plans, fold the plan against them rather than duplicating their acceptance criteria.

## Load

- `BUILD.md` — the "first vertical slice" section and the risk lead it sits under.
- For epic layout: the first epic's `EPIC.md`.
- The task files for work the skeleton will exercise — open at Goal and Acceptance criteria, not the full body.
- Source-doc passages that the first slice turns on, via task `docs_refs`.

## Do not load

- Epics beyond the first.
- Tasks outside the skeleton's surface.
- `decisions/`, `scratch/`.

## Write scope

**None.**

## Output shape

A short plan naming surfaces, not steps:

- **What the slice does end-to-end.** One sentence naming route, screen, write, and assertion.
- **Sequence.** Two to five numbered high-level steps — one per surface.
- **Tasks it exercises.** Task ids (or first-epic scope, pre-task-generation).
- **Risk check.** One line on whether the skeleton exercises the risk `BUILD.md` led with. If it doesn't, surface the gap.
- **Assumptions or flags.** Gaps `BUILD.md` did not settle.

## Return

- **Plan summary** in the shape above.
- **Next step** — the first task to pick up, typically via `/metis:plan-task <first-task-id>`.
- **Flagged ambiguities** — architectural calls the skeleton surfaced that `BUILD.md` did not commit to. One line per.

## Invocation prompt

Silently accept and ignore any trailing free-text prompt.
