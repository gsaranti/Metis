---
name: writing-task-files
description: Reference for writing well-formed task files — taking a body of work and breaking it into rightsized tasks with outcome-framed goals, excerpted context, and testable acceptance criteria.
disable-model-invocation: true
---

# Writing task files

A task file is a self-sufficient brief for one unit of implementation work. The job of this skill is to produce task files that a fresh subagent can act on — plan, implement, or review — with only the task file, `CLAUDE.md`, its cited docs, and the parent `EPIC.md` in epic mode. Anything else needed is a failure of the task file, not a missing context.

This skill fires when you have a body of work and the source docs it references, and need to turn it into a set of task files. The unit of output is the set, not a single task.

## Read first

- `.metis/conventions/task-format.md` — the structural spec (section order, excerpting rule, sizing). Not restated here.
- `.metis/templates/task.md` — the skeleton.

Load `.metis/conventions/frontmatter-schema.md` on demand when populating frontmatter or resolving a field question. It is a lookup, not a reader.

## Is this task-shaped?

Before writing anything, check that the unit of work belongs in a task file at all. The failure mode on either side is real: task-fragmenting work that belongs inline, or promoting a question into a task that cannot be implemented.

- **Task vs. checklist item.** A step with no independent acceptance criterion, sharing all its context with its sibling, and worked in the same sitting either way — that is a bullet in Expected file changes, not a new task. The test: could this be picked up by a different person in a different session and still make sense?
- **Task vs. spike.** Exploratory work without a testable outcome — "figure out whether library X meets our needs" — goes in `scratch/exploration/`. When the exploration concludes, it may spawn real tasks; that is how it enters the task system.
- **Task vs. decision.** A choice that must be made before work can proceed is a decision, not a task. If you catch yourself writing a task whose acceptance criterion is "we have decided X," stop and file it as a decision instead, via an open-item resolution or a direct `decisions/` entry.
- **Task vs. epic.** One task covering a whole capability ("Implement auth") is an epic in disguise. If the Goal reads at capability level and the acceptance criteria list four unrelated surfaces, step back to epic breakdown first.

## Splitting a body of work into tasks

The first judgment call is how finely to cut. Two forces push against each other: each task wants enough context to stand on its own; no task wants to carry a second task's work along with it.

Signals a unit wants to split:

- Two acceptance criteria that could genuinely be evaluated independently — one could pass while the other fails without it being a bug.
- Two disjoint sets of files in `touches` with no overlap and no shared code paths.
- A sizing pass pushes the file past ~150 lines and trimming excerpts does not recover it.

Signals two units want to merge:

- Identical `docs_refs` and heavily overlapping `touches`.
- One task's acceptance criterion is a prerequisite state of the other and has no observable effect on its own.
- Both would land in the same commit anyway.

Use `depends_on` to express ordering between tasks that should stay separate — not as a way to avoid merging. A chain of three tasks that all depend on each other in strict order often wants to be one task with three acceptance criteria.

## Writing each section well

The convention file has the shape. The judgment each section needs:

- **Goal.** Outcome-framed, not activity-framed. "A signed-in user can see their profile" beats "Implement the profile endpoint." The test: can a reviewer tell from the Goal alone whether the outcome was achieved, without reading the implementation?
- **Context.** Excerpt, do not link. Quote the *minimum relevant passage* — a task that pastes a whole 60-line section has almost certainly buried the load-bearing 8 lines. When the relevant passage is long, summarize in your own words and keep one or two load-bearing quotes verbatim.
- **Scope boundaries.** `### Out of scope` is the higher-value half. It pre-empts the natural scope creep of both implementer and reviewer. "No SSO; no password reset; no session revocation beyond the happy path" is worth more than six in-scope bullets restating what is obvious. Always populate it, even briefly.
- **Acceptance criteria.** Testable pass/fail with evidence. If a criterion cannot be evaluated without forming an opinion about the code, it is a wish. Rewrite to something a reviewer can check with a command or by reading a specific output — "returns 400 when the body is missing the `signature` header," "the migration adds a `deleted_at` column to `users`."
- **Expected file changes.** More granular than the `touches` frontmatter field. Each entry is path + short intent (add / update / remove). This is where a reviewer spots unstated file changes in the diff after the fact.
- **Notes.** Starts empty. Leave it that way at creation — it is the implementer's and reviewer's place to append, not the author's.

## Flagging ambiguity in the source

If the source docs do not resolve a point a task needs, do not guess. Two moves depending on what is unresolved:

- **Small, local ambiguity** (a specific field's type, a specific error code): write the task with a `TODO:` line in Context naming the gap, and surface the same question in `scratch/questions.md` for the main session. The task can ship with the flag; the implementer will see it and defer the guess upward.
- **Structural ambiguity** (which of two architectural paths this feature takes): do not write the task. Resolve the question first — via an open item, a decision entry, or a direct conversation. Tasks that bake in unresolved structural ambiguity produce downstream work that must be redone.

A task file with a hidden guess is worse than a missing task file. The hidden guess will be discovered only after the implementer has acted on it.

## Sizing

Per `task-format.md`, 50–150 lines is the target. The two failure modes:

- **Under 50 lines.** Usually under-excerpted — the task sends the implementer back to the source docs anyway. Pull more context in.
- **Over 150 lines.** Usually either an oversized excerpt (summarize and keep the key quotes) or two tasks that want splitting.

A 160-line task whose every line earns its place is fine. A 120-line task padded with ceremonial prose is not.

## IDs and numbering

Per `frontmatter-schema.md`, ids are zero-padded 4-digit strings, unique within the project, and match the filename prefix. When generating a batch, take the next unused project-wide id for each new file — not per-epic. Gaps are expected (a deleted or superseded task leaves its id retired); do not reuse ids to fill gaps.

## Epic mode: do not duplicate the parent

In epic mode, every task implicitly loads its parent `EPIC.md`. Do not duplicate the epic-level goal, scope, or exit criterion inside the task file. Quote from `EPIC.md` only when the task turns on a specific clause — and then only that clause. The parent is part of every subagent's context already; duplicating it taxes every load and breeds drift when the epic's scope shifts and only some tasks are updated.

## Examples

One file, demonstrating the shape this skill wants you to produce. Failure modes are described in the prose above, not kept as separate counter-example files.

- `examples/good-task.md` — a clean mid-sized epic-mode task: outcome-framed Goal, excerpted Context with attribution, specific scope boundaries, testable acceptance criteria with evidence, Notes empty. **Read this before writing your first task in a session.**
