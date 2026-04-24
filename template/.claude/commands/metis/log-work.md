---
description: Reconcile implementation drift — record code the user wrote outside Metis against task files, using git diff as the source of truth for what happened and the user's description as the source of truth for intent.
argument-hint: [task-ids] <description>
---

# /metis:log-work

Absorb work the user did outside the Metis loop — a hotfix, a spike, a refactor, a feature driven by hand — into the on-disk record. The user's description is the source of truth for intent; `git diff` is the source of truth for what happened. Daylight between the two is surfaced, not smoothed over.

## Arguments

- **`[task-ids]`** — optional. Zero-padded task ids, comma-separated, naming the tasks the work attributes to (e.g., `0007,0009`). When omitted, the command treats the work as unattributed and produces a retroactive task (see below).
- **`<description>`** — required. Free-text describing what happened and what the user claims about it. Passed verbatim to the reconcile step — never paraphrased before it informs the updates.

Example shapes:

```
/metis:log-work 0007 "Finished the webhook handler. Done."
/metis:log-work 0007,0009 "Refactored the handler; split 0009 in two — created 0011 for the retry logic."
/metis:log-work "Fixed the race in the session cache during a spike. Unplanned."
```

## Preconditions

- Git must be available and the working tree accessible. `git diff` is load-bearing; without it this command cannot reconcile. If git reports no repo, stop and point the user at the setup surface.
- The named task ids (if any) must resolve to task files. Unresolved ids stop the command; listing nearest matches is the same shape as other commands.
- A non-trivial diff must exist, or the description must name CRUD (a split / add that the command will handle at the task-file level with no code in this commit range). An empty diff plus a description claiming implementation work is daylight worth surfacing before proceeding.

## Load

- The user's description, verbatim.
- The `git diff` for the relevant range. Default: uncommitted changes plus commits on the current branch not yet on the project's main line. If the description narrows the scope (e.g., "in commit abc123"), follow that narrower scope.
- Each named task file in full — Goal, Context, Scope boundaries, Acceptance criteria, Expected file changes, Notes, frontmatter. Needed to verify done-claims and to propose Notes appends.
- When any named task lives under an epic, the parent `EPIC.md`.
- Source-doc passages behind the tasks' `docs_refs`, only when a criterion under verification turns on a passage the task abbreviated.

## Do not load

- Task files other than those named (and any implied by a CRUD claim — a split's new id, a merge's superseder).
- `BUILD.md`. If the diff touches an architectural commitment, that surfaces as a decision trigger; re-reading `BUILD.md` here does not change the check.
- `BOARD.md`, `scratch/CURRENT.md`, `scratch/questions.md`. Parent-session surface; the log is against the code and the task files.
- `decisions/` wholesale. Grep by slug when the description names a prior decision or when an architectural trigger fires.

## Skills

Invoke by reference:

- `logging-external-work` — the primary teaching. Reading the description and the diff, daylight surfaced rather than smoothed, per-task updates by claim type (done / progress / CRUD), the lightweight done-claim check against the diff, retroactive-task shape with provenance in Context, and architecture-level diff detection that triggers a decision entry.
- `writing-decisions` — invoked only when the diff hits an architecture-level trigger and a decision is warranted. Not every log-work produces a decision.

## Flow

1. **Propose.** Render the reconciliation proposal: per-task claim type, per-task done-claim verdict (evidenced / partially / unverified / gap), any CRUD operations implied by the description, any retroactive task for unnamed work in the diff, any architecture trigger. Surface daylight explicitly. Wait for user approval or redirection before writing.
2. **Write.** On approval, land the task-file updates (Notes appends, `status` transitions, CRUD), create any retroactive task, and write the decision entry when triggered. Bump `doc_hashes` or `spec_version` only if the diff changed the baseline against which a task was written — most log-work does not.

## Write scope

- **Named task files.** Notes appends (description plus diff summary, clearly separating claim from mechanical), `status` transitions driven by claim type (done → `done` if evidenced; progress → `in-progress`; gap or daylight → stay where the user decides).
- **Retroactive task files.** Per `logging-external-work` shape — Context carries the description verbatim and the provenance note, Goal restates the description's outcome, acceptance criteria follow the description's testable claims or the placeholder if none were named, status reflects diff reality.
- **CRUD artifacts.** Split creates a new task at `pending` (no diff signal yet) or at the evidenced status; merge writes a superseder preserving the merged ids in Notes and does not delete originals.
- **`decisions/YYYY-MM-DD-<slug>.md`** — only when an architecture trigger fires. Context pins the description passage and the diff surfaces; Evidence links the diff range and the task ids.

Do not write to `BUILD.md`, source docs, `BOARD.md`, or `scratch/`. If the diff shifts a `BUILD.md` commitment, that is a finding — the decision entry records it, and `/metis:sync` handles the cascade through downstream tasks (which this command does not run itself).

## Invocation prompt

The required `<description>` is not an invocation prompt — it is an argument the command consumes directly and passes to the skill. If a trailing quoted prompt follows the description (rare in practice), treat it per the standard four rules:

1. **Augment, do not replace.** The description is the intent record; a trailing prompt tunes how the reconciliation is read (e.g., "pay close attention to test coverage in the diff"). It does not override the description.
2. **Flag scope expansion.** If the trailing prompt asks the command to edit files beyond the reconciliation surface (source docs, `BUILD.md`, other tasks), flag and decline.
3. **Acknowledge use explicitly.** State in the return how the prompt shaped the reconciliation.
4. **Resolve named skills.** Resolve additional skills named in the prompt the same way any skill reference is resolved, across whatever skill sources the runtime exposes. Acknowledge each invoked skill's influence; flag unresolvable names rather than guessing. User-referenced skills augment `logging-external-work`; they do not override the description / diff asymmetry.

The description is persisted (in Notes, Context); a trailing prompt is ephemeral.

## Return

- **Reconciliation proposal** during the propose phase — per-task verdicts, CRUD operations, retroactive task (if any), decision trigger (if any), daylight list.
- **Files written** during the write phase — each task file, each retroactive task, each decision path.
- **Daylight** — explicit list of mismatches between description and diff that the user chose to accept or redirect.
- **Architecture trigger** — named explicitly when a decision was written, or named as "no trigger" when the diff was purely implementation.
- **Prompt usage** — one line if a trailing prompt was carried.
- **Next step** — `/metis:rebaseline` when the log-work may have put tasks out of sync with their baselines, or nothing when the log was self-contained.
