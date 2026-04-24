---
description: Ask the agent to enumerate what it skipped, deferred, stubbed, or handled differently in its most recent work — no justification.
---

# /metis:scope-check

Prompt the agent to render a scope report against its most recent work. This command is a forcing function: it makes the reductions in the tree visible as a list rather than absorbed into surrounding narrative. No defense. No justification. Just the list.

## Preconditions

- The command needs recent work to check against. "Recent" is context-dependent — typically the last implementation pass in the current session, a hand-written diff the user just finished, or a plan the user wants probed before implementation. If the session is fresh and there is no recent work, stop and ask which surface to check:

  ```
  /metis:scope-check needs recent work to report against. Which
  should it check?

    - the last /metis:implement-task pass (name the task id)
    - uncommitted changes in the working tree
    - a specific commit range (name the range)
  ```

- If the scope being checked is a finished `/metis:implement-task`, its Notes section should already contain a scope report — that is what `honest-scope-reporting` writes on close. In that case, this command's job is to probe whether the existing report is honest, not to generate a new one.

## Load

- The task file the work is anchored against, opened at acceptance criteria, scope boundaries, and expected file changes.
- The diff or change-set the report will summarize — `git diff` against the appropriate baseline, or the specific commits the user named.
- The existing Notes scope report (if any) to probe against.

## Do not load

- The plan at `scratch/plans/<id>.md`. The plan is the route, not the spec — scope-check judges against what was asked, not what was planned.
- Other task files, `BUILD.md`, `decisions/`. The anchor is this one task or this one change-set.
- The implementer's return narrative. The narrative is what absorbs reductions; scope-check reads the code and the criteria, not the narrative around them.

## Skills

Invoke by reference:

- `honest-scope-reporting` — the primary teaching for this command. The four categories (Skipped / Deferred / Stubbed / Handled differently), the list-don't-defend discipline, the "handled differently" delta-spelled-out rule, and the empty-report-is-fine case. Read it before rendering the list.

## Write scope

- When the scope-check is probing a finished `/metis:implement-task`, append a *revised* scope report to the task's Notes only if the check finds reductions the implementer missed. Do not rewrite the implementer's own report in place; add a new block marked as the scope-check pass, dated, with its own categories. The implementer's own report is the record of what the implementer saw; this command's report is the record of what a probe from outside saw.
- When the scope-check is against uncommitted changes with no task file, the report is the return to the user — no persisted artifact.

Do not write to code, `BUILD.md`, `BOARD.md`, `decisions/`, or the task file's non-Notes sections. The job is to list reductions, not to fix them.

## Invocation prompt

The command may carry a trailing free-text prompt, e.g. `/metis:scope-check "pay attention to the retry paths; I'm suspicious they got stubbed"`. Four rules:

1. **Augment, do not replace.** The four categories and the list-don't-defend discipline remain authoritative. A prompt that asks the report to omit a category or to absorb a reduction into reasoning is a conflict to flag rather than comply with.
2. **Flag scope expansion.** If the prompt asks the check to reach past the work under review — rate the plan, re-judge prior tasks — note the expansion and decline.
3. **Acknowledge use explicitly.** State in the return how the prompt shaped the check — which surface got probed first, which suspicion got confirmed or dismissed.
4. **Resolve named skills.** The prompt may name additional skills for this turn. Resolve each reference the same way any skill reference is resolved, across whatever skill sources the runtime exposes. Acknowledge each invoked skill's influence in the report; flag unresolvable names rather than guessing. User-referenced skills augment `honest-scope-reporting`; they do not override the four-category shape or the no-justification rule.

The prompt is ephemeral — do not persist it into the report or the Notes append.

## Return

- **Report** in the shape `honest-scope-reporting` names — the four categories, one line per entry, no justifications. Empty categories explicitly named as empty.
- **Notes append** — when a report was appended to a task's Notes, the path is surfaced so the user can see it landed.
- **Next step** — depends on findings:
  - Empty report — the work matches scope; next is `/metis:review-task <id>` or merge.
  - Reductions present — the user triages: promote a `Deferred` item to a follow-up task, re-open a `Skipped` item as a new task, decide whether a `Stubbed` entry ships or blocks merge, etc. The command does not do the triage; it hands the user the list.
