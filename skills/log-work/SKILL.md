---
name: log-work
description: Reconcile implementation drift — record code the user wrote outside Metis against task files, using git diff as the source of truth for what happened and the user's description as the source of truth for intent.
disable-model-invocation: true
---

# /metis:log-work

Absorb work the user did outside the Metis loop — a hotfix, a spike, a refactor, a hand-driven feature — into task files and any decisions warranted.

## Argument

- **`<description>`** — required. Free-text describing what happened and what the user claims about it. Task ids (`0007`) and epic ids (`002-billing`) referenced anywhere in the description are extracted as the attributed artifacts; if none are found, the work is treated as unattributed and produces a retroactive task. Passed verbatim to the reconcile step — never paraphrased.

Example shapes:

```
/metis:log-work Finished the webhook handler in 0007. Done.
/metis:log-work Refactored the handler; split 0009 in two — created 0011 for the retry logic.
/metis:log-work Fixed the race in the session cache during a spike. Unplanned.
```

## Preconditions

- Git must be available and the working tree accessible. If git reports no repo, stop.
- Task and epic ids referenced in the description must resolve to existing files, or be claimed as new by a CRUD operation in the same description (e.g., a split's new id). Ambiguous references stop the command, listing nearest matches.
- A non-trivial diff must exist, or the description must name CRUD (a split / add at the task-file level with no code in this commit range). If neither holds, surface as daylight before proceeding.

## Load

- The user's description, verbatim.
- The `git diff` for the relevant range. Default: uncommitted working-tree changes plus all commits on the current branch since it diverged from main — i.e., every change the branch contains that main does not. On main itself (or any branch with no divergence), this collapses to uncommitted changes only. The description can scope the range broader (e.g., "since commit abc123" for trunk-based workflows) or narrower (e.g., "in commit abc123" to limit to one commit).
- Each named task file in full — Goal, Context, Scope boundaries, Acceptance criteria, Expected file changes, Notes, frontmatter.
- When any named task lives under an epic, the parent `EPIC.md`.
- Source-doc passages behind the tasks' `docs_refs`, only when a criterion under verification turns on a passage the task abbreviated.
- `decisions/` — grep by slug when the description names a prior decision or when an architectural trigger fires.

## Do not load

- Task files other than those named.
- `BUILD.md`.
- `scratch/CURRENT.md`, `scratch/questions.md`.
- `decisions/` wholesale.

## Skills

Invoke by reference:

- `metis:logging-external-work` — read before reconciling.
- `metis:writing-decisions` — invoked only when an architecture-level trigger fires. Not every log-work produces a decision.

## Flow

1. **Propose.** Render the reconciliation proposal: per-task claim type and done-claim verdict, any CRUD operations implied, any retroactive task, any architecture trigger. Surface daylight explicitly. Wait for user approval or redirection before writing.
2. **Write.** On approval, land the task-file updates, retroactive task, and decision entry. Bump `doc_hashes` or `spec_version` only if the diff changed a task's baseline — most log-work does not.

## Write scope

- **Named task files.** Notes appends and `status` transitions per claim type (see `metis:logging-external-work`).
- **Retroactive task files.** Per `metis:logging-external-work` shape.
- **CRUD artifacts.** Split, merge, or add per `metis:logging-external-work`.
- **`decisions/YYYY-MM-DD-<slug>.md`** — only when an architecture trigger fires.

### Do not write to

- `BUILD.md` and source docs.
- `scratch/`.

If the diff shifts a `BUILD.md` commitment, that is a finding for the decision entry.

## Invocation prompt

The `<description>` argument serves as both the command's primary input (passed verbatim to `metis:logging-external-work`) and a command prompt subject to the rules in `.metis/conventions/command-prompts.md` — augment / flag scope expansion / acknowledge use / resolve named skills. Acknowledge use in the return per rule 3.

Unlike most invocation prompts, the description is durable: for named-task work it appends to that task's Notes; for unnamed work it becomes the new task's Context.

## Return

- **Reconciliation proposal** during the propose phase — per-task verdicts, CRUD operations, retroactive task (if any), decision trigger (if any), daylight list.
- **Files written** during the write phase — each task file, each retroactive task, each decision path.
- **Daylight** — explicit list of mismatches between description and diff that the user chose to accept or redirect.
- **Architecture trigger** — named explicitly when a decision was written, or "no trigger" when the diff was purely implementation.
- **Next step** — `/metis:rebaseline` when the log-work may have put tasks out of sync with their baselines, or nothing when the log was self-contained.
