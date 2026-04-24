---
name: writing-a-task-file
description: Reference for writing one well-formed task file — an outcome-framed Goal, excerpted Context, specific scope boundaries, and testable acceptance criteria.
disable-model-invocation: true
---

# Writing a task file

A task file is the self-sufficient brief a reader works from. The job of this skill is to take one decomposed unit of work and render it into that file. The decomposition call — what belongs in this task vs. a sibling, what the right number of tasks is — has already been made by the time this skill runs.

## Read first

- `.metis/conventions/task-format.md` — the structural spec (section order, excerpting rule, sizing). Not restated here.
- `.metis/templates/task.md` — the skeleton.

Load `.metis/conventions/frontmatter-schema.md` on demand when populating frontmatter or resolving a field question. Use it as a lookup, not required reading.

## Frontmatter quality

`depends_on` and `touches` are the fields that most commonly inflate. `depends_on` names real blocking prerequisites — another task must finish before this one can start — not a wishlist of related work. `touches` names the primary surfaces a planner needs to reason about; listing every file the implementer might incidentally open makes the field noise rather than signal. Inflated frontmatter degrades task-pickup and spec-change propagation more than missing values do.

## Describe outcomes, not implementation

Across every section, stay with outcomes and constraints. "Profile reads return in under 200ms" is a task concern; "use Redis for the cache" is an implementation concern and belongs in the task file only if a source doc or decision has already fixed the approach. Otherwise the implementer becomes a stenographer and the reviewer has nothing independent to check.

## Writing each section well

The convention file has the shape. The judgment each section needs:

- **Goal.** Outcome-framed, not activity-framed. "A signed-in user can see their profile" beats "Implement the profile endpoint." The test: can a reviewer tell from the Goal alone whether the outcome was achieved, without reading the implementation?
- **Context.** Quote the *minimum relevant passage* — a task that pastes 500 words of source material has almost certainly buried the 50 that are load-bearing. When the relevant passage is long, summarize in your own words and keep one or two load-bearing quotes verbatim.
- **Scope boundaries.** `### Out of scope` is the higher-value half. It pre-empts the natural scope creep of both implementer and reviewer. "No SSO; no password reset; no session revocation beyond the happy path" is worth more than six in-scope bullets restating what is obvious. Always populate it, even briefly.
- **Acceptance criteria.** If a criterion cannot be evaluated without forming an opinion about the code, rewrite to something a reviewer can check with a command or by reading a specific output — "returns 400 when the body is missing the `signature` header," "the migration adds a `deleted_at` column to `users`."
- **Expected file changes.** Name the intentional changes — the files the task means to create or modify, with a short intent. The list's job is to make unexpected new surfaces stand out in the diff, not to predict every incidental helper file the implementer opens.
- **Notes.** Leave empty at creation. The temptation is to pre-load design context here; resist it — Notes is the implementer's and reviewer's append-only log.

## Sizing as feedback

If a draft lands past the `task-format.md` sizing target and trimming excerpts does not recover it, the unit probably wanted to be two tasks — that is a decomposition call and belongs upstream, not a problem to solve in this file.

## Flagging ambiguity in the source

If the source docs do not resolve a point this task needs, do not guess. For a small, local ambiguity — a specific field's type, a specific error code — write the task with a `TODO:` line in Context naming the gap, and surface the same question in `scratch/questions.md` for the main session. The task can proceed with the flag; the implementer will see it and defer the guess upward. A task file with a hidden guess is worse than a missing task file; the hidden guess will be discovered only after the implementer has acted on it.

Structural ambiguity — which of two architectural paths this feature takes — is upstream of this skill. If you find one, stop writing; it belongs in decomposition or decision work, not inside the task file.

## IDs and numbering

Take the next unused project-wide id — not per-epic. Gaps are expected (a deleted or superseded task leaves its id retired); do not reuse ids to fill gaps.

## Tasks under an epic: do not duplicate the parent

When a task lives under an epic (`epics/<name>/tasks/<id>-*.md`), every reader — planner, implementer, reviewer — implicitly loads the parent `EPIC.md` alongside the task file. Do not duplicate the epic-level goal, scope, or exit criterion inside the task file. Quote from `EPIC.md` only when the task turns on a specific clause — and then only that clause. The parent is part of the load already; duplicating it taxes every read and breeds drift when the epic's scope shifts and only some tasks are updated.

## Examples

- `examples/good-task.md` — a clean mid-sized task that lives under an epic: outcome-framed Goal, excerpted Context with attribution, specific scope boundaries, testable acceptance criteria with evidence, Notes empty. **Read this before writing your first task in a session.**
