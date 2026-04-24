---
name: metis:implement-task
description: Implement one task in the main session. Loads the task file, the parent EPIC.md if present, the approved plan if present, and only the docs in docs_refs. Closes with a scope report.
disable-model-invocation: true
---

# /metis:implement-task

Implement one task. Runs in the main session — not a subagent — so the user can watch what happens, interject, and keep context that a subagent's compressed return would throw away. The write restrictions that a subagent would have enforced with tool permissions are carried here as prompt-level discipline.

## Arguments

- **`<task-id>`** — required. Zero-padded 4-digit id. If omitted or malformed, stop and ask.
- **Trailing prompt** — optional. Augments the task file per the invocation-prompt rules below.

## Preconditions

- The task file must exist. Resolve by id across the two possible locations:
  - Flat: `tasks/<id>-*.md`
  - Epic: `epics/*/tasks/<id>-*.md`
  
  If unresolved, stop and list the nearest matches.

- Block implementation when the task's `status` is `done`. Re-implementing a done task is how silent drift lands; if the user genuinely wants to re-work done behavior, it is a new task or a superseding decision (via `/metis:log-work` or `/metis:sync`).

- Block implementation when the task is `blocked` or when `depends_on` contains a not-`done` task, unless the user confirms the block is stale.

- `in-progress` is the status this command transitions to; `in-review` is the status it transitions out of on completion. A task already `in-review` means an implementation has been run — confirm with the user before picking it up again.

## Load

- The task file — full body, plus frontmatter.
- When the task lives under an epic (`epics/<name>/tasks/...`), the parent `EPIC.md`.
- The approved plan at `scratch/plans/<id>.md` when it exists. Treat it as the route the planner proposed — useful guidance, not a spec. The task's acceptance criteria remain authoritative.
- Only the docs listed in the task's `docs_refs` frontmatter. Read the cited sections, not the full files.
- The code the task is changing, on demand as implementation proceeds.

That list is the full brief. If it is not enough to implement the task, the task file is underspecified — surface the gap rather than widening the load.

## Do not load

- Other task files. Even "obviously related" ones.
- `BUILD.md`. The task file is authoritative for this unit of work.
- `BOARD.md`, other epics' `EPIC.md` files.
- `decisions/`. If a decision bears on this task, the task file should have cited it in `docs_refs`; surface the gap rather than grepping.
- `scratch/CURRENT.md`, `scratch/questions.md`. These are parent-session handoff surface, not per-task context.
- Other plans in `scratch/plans/`. This task's plan (if any) is the only plan that applies.

## Skills

Invoke by reference — read the skill file itself, do not paraphrase from memory:

- `planning-a-task` — load when no plan exists at `scratch/plans/<id>.md`. The implementation has to carry its own sequencing discipline when a planner did not. Read the precondition check (*the task may already be done*) before touching code.
- `honest-scope-reporting` — the closing scope report. Load before writing the final Notes block.

The task file's Goal, Scope boundaries, and Acceptance criteria are the anchors the implementation stays against — those are read from the task file itself, not through a skill. No skill in the v0.1 set teaches the shape of an implementer's Notes append; one paragraph combining what was built with the scope report is enough, and reviewers append per `reviewing-against-criteria` later.

## Write scope

As the main session, this command has access to edit any file in the repo. The discipline is which files it chooses to write:

- **The assigned task file.** Update `status` (usually `pending` → `in-progress` at start, `in-progress` → `in-review` on close), and append implementation Notes — a short return note plus the `honest-scope-reporting` block.
- **Code and test files.** The work itself. Confined to the surfaces the task's `touches` and `Expected file changes` name; widening beyond that is a scope-reduction sibling (scope expansion) and belongs in the scope report, not silent.

### Do not write to

Hard restrictions, carried as prompt-level discipline:

- Other task files. Even if a related task is "obviously" affected.
- `BUILD.md`. An implementation that wants a `BUILD.md` edit has crossed a scope boundary; surface the conflict and let `/metis:sync` handle it.
- `BOARD.md`. Generated.
- `decisions/`. If the work surfaces an architectural choice that warrants a decision, name the finding and leave the decision entry to the parent session outside this command, or to `/metis:log-work` after the fact.
- `scratch/CURRENT.md`, `scratch/questions.md`. Parent-session surface; this command touches only the task and the code.
- `scratch/plans/<id>.md`. The plan is the planner's artifact; an implementer that disagreed with it records the divergence in task Notes, not by rewriting the plan.
- `.metis/`, `.claude/`.

Reaching for any of these means the implementation has grown past its scope. Stop and surface the finding.

## Invocation prompt

The command may carry a trailing free-text prompt, e.g. `/metis:implement-task 0007 "skip mocking the webhook endpoint — use a real local test server"`.

Follow the command-prompts convention in `.metis/conventions/command-prompts.md`. The four rules (augment / flag scope expansion / acknowledge use / resolve named skills) apply; acknowledge prompt usage in the return per rule 3.

The prompt is ephemeral — do not copy it into the task file or any other persisted artifact beyond the brief "prompt usage" acknowledgment in Notes.

## Closing the implementation

Before returning:

1. Run the task's verification command (or the plan's, if one was produced). Paste the actual output into Notes — not a claim of what it said.
2. Append a Notes block with: what was built, what the scope report names as reduced (per `honest-scope-reporting`), any divergence from the plan, and the prompt-usage one-liner if applicable.
3. Transition `status` from `in-progress` to `in-review`. Do not set `done` — that is the reviewer's call via `/metis:review-task`.

## Return

- **Task path and status** — the file path and the new status.
- **Verification result** — the command run and its exit, summarized in one line.
- **Scope report** — the block appended to Notes, restated inline for the user's convenience.
- **Findings** — anything that warranted an upstream flag rather than a silent absorb (task-file gaps, scope conflicts, architectural questions the work surfaced).
- **Prompt usage** — one line if a prompt was carried.
- **Next step** — `/metis:review-task <id>` to dispatch the reviewer, or `/metis:scope-check` first if the user wants the scope report probed before formal review.
