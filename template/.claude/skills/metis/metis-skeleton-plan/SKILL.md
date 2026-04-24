---
name: metis:skeleton-plan
description: Plan the thinnest end-to-end slice that exercises the project's first vertical slice. Read-only — writes no files.
disable-model-invocation: true
---

# /metis:skeleton-plan

Plan how to build the first end-to-end slice: one route, one screen, one database write, one passing test — all in one deployable shape. Writes nothing. The skeleton is the first real test of the architecture `BUILD.md` committed to, and this command stops at the plan.

## Preconditions

- `BUILD.md` must exist and must name a first vertical slice. If it does not, stop and name the gap:

  ```
  /metis:skeleton-plan needs BUILD.md to name a concrete first
  vertical slice. If BUILD.md is missing, run /metis:build-spec.
  If it exists but skips the "first vertical slice" section, the
  architecture has not committed enough to plan a skeleton against
  yet — amend BUILD.md with a concrete slice first.
  ```

- The first call for a project is typically right after `/metis:generate-tasks` for the first epic (or the flat first batch). If task files already exist for the work the skeleton plans, fold the plan against them — do not propose parallel work that duplicates a task's acceptance criteria.

## Load

- `BUILD.md`, in particular the "first vertical slice" section and the risk lead it sits under.
- For epic layout: the first epic's `EPIC.md`, so the skeleton stays inside its scope.
- The task files for work the skeleton will exercise — open at Goal and Acceptance criteria, not the full body.
- Source-doc passages that the first slice turns on, via task `docs_refs`.

## Do not load

- Epics beyond the first. The skeleton is the first pass, not a whole-project plan.
- Tasks outside the skeleton's surface. "Obviously related" work is pulled in by task-level planning, not at this layer.
- `decisions/`, `BOARD.md`, `scratch/`. None of these shape the skeleton.

## Skills

This command does not invoke a skill — it is the reading pass that produces a skeleton-level sequence, not a task-level plan. The task-level planner runs per-task via `/metis:plan-task` once the skeleton lands in the work queue.

## Write scope

**None.** This is a read-only command. The output is a message to the user; no file is written. If the user wants the sequence captured, they can copy it into `scratch/` on their own or run `/metis:plan-task` once individual tasks are picked up.

## Output shape

The return is a short plan — shorter than a task-level plan, because it names surfaces rather than steps:

- **What the slice does end-to-end.** One sentence naming the route, the screen, the write, and the assertion that proves it.
- **Sequence.** Two to five numbered high-level steps — one per surface that has to exist for the slice to run.
- **Tasks it exercises.** The specific task ids (or the first-epic scope, in flat mode before tasks exist) that the skeleton will work against.
- **Risk check.** One line naming whether the skeleton exercises the risk `BUILD.md` led with. A skeleton that does not is not wrong, but it leaves the architectural bet unchecked; surface the gap rather than hiding it.
- **Assumptions or flags.** Anything the skeleton had to pin down that `BUILD.md` did not settle. Surface rather than guess.

## Return

- **Plan summary** in the shape above.
- **Next step** — the first task to pick up, typically via `/metis:plan-task <first-task-id>`.
- **Flagged ambiguities** — architectural calls the skeleton surfaced that `BUILD.md` did not commit to. One line per.

This command silently ignores any trailing free-text prompt — it is mechanical enough that a per-invocation tune adds little. A user who wants to bias the slice toward a particular surface should edit `BUILD.md`'s first-vertical-slice section directly rather than routing that intent through this command.
