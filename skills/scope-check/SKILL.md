---
name: scope-check
description: Render a scope report against recent work.
disable-model-invocation: true
---

# /metis:scope-check

Render a scope report against recent work — what was skipped, deferred, stubbed, or handled differently.

## Preconditions

- If no recent work is apparent, stop and ask which surface to check:

  ```
  /metis:scope-check needs recent work to report against. Which
  should it check?

    - the last /metis:implement-task pass (name the task id)
    - uncommitted changes in the working tree
    - a specific commit range (name the range)
  ```

- If the task's Notes already contain a scope report, probe whether it's honest rather than generating a new one.

## Load

- The task file (acceptance criteria, scope boundaries, expected file changes).
- The diff or change-set being probed (`git diff` against the baseline, or the user-named commit range).
- The existing Notes scope report (if any) to probe against.

## Do not load

- The plan at `scratch/plans/<id>.md`.
- Other task files, `BUILD.md`, `decisions/`.

## Read first

- `${CLAUDE_PLUGIN_ROOT}/references/honest-scope-reporting.md` — read before rendering the list.

## Write scope

- When probing a finished `/metis:implement-task`, append a new scope-report block to Notes (marked as a scope-check pass, dated) only if the check finds new reductions. Do not rewrite the implementer's report.
- When the scope-check is against uncommitted changes with no task file, the report is the return to the user — no persisted artifact.

### Do not write to

- Code and test files.
- `BUILD.md`.
- `decisions/`.
- The task file's non-Notes sections.

## Invocation prompt

Trailing prompt: see `${CLAUDE_PLUGIN_ROOT}/.metis/conventions/command-prompts.md`.

## Return

- **Report** per `${CLAUDE_PLUGIN_ROOT}/references/honest-scope-reporting.md`.
- **Notes append** — path when a report was appended to a task's Notes.
- **Next step** — depends on findings:
  - Empty report — `/metis:review-task <id>` or merge.
  - Reductions present — the user triages (promote a `Deferred` item to a follow-up task, re-open a `Skipped` item as a new task, decide whether a `Stubbed` entry ships).
