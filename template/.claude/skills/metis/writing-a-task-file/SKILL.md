---
name: writing-a-task-file
description: Reference for writing one well-formed task file — an outcome-framed Goal, excerpted Context, specific scope boundaries, and testable acceptance criteria.
disable-model-invocation: true
---

# Writing a task file

A task file is a self-sufficient brief for one unit of implementation work. The job of this skill is to produce a task file that a fresh subagent can act on — plan, implement, or review — with only the task file, `CLAUDE.md`, its cited docs, and the parent `EPIC.md` in epic mode. Anything else needed is a failure of the task file, not a missing context.

This skill fires when you have one decomposed unit of work and the source docs it references, and need to turn that into a file. The decomposition call — what belongs in this task vs. a sibling, what the right number of tasks is — has already been made by the time this skill runs.

## Read first

- `.metis/conventions/task-format.md` — the structural spec (section order, excerpting rule, sizing). Not restated here.
- `.metis/templates/task.md` — the skeleton.

Load `.metis/conventions/frontmatter-schema.md` on demand when populating frontmatter or resolving a field question. It is a lookup, not a reader.

## Writing each section well

The convention file has the shape. The judgment each section needs:

- **Goal.** Outcome-framed, not activity-framed. "A signed-in user can see their profile" beats "Implement the profile endpoint." The test: can a reviewer tell from the Goal alone whether the outcome was achieved, without reading the implementation?
- **Context.** Excerpt, do not link. Quote the *minimum relevant passage* — a task that pastes a whole 60-line section has almost certainly buried the load-bearing 8 lines. When the relevant passage is long, summarize in your own words and keep one or two load-bearing quotes verbatim.
- **Scope boundaries.** `### Out of scope` is the higher-value half. It pre-empts the natural scope creep of both implementer and reviewer. "No SSO; no password reset; no session revocation beyond the happy path" is worth more than six in-scope bullets restating what is obvious. Always populate it, even briefly.
- **Acceptance criteria.** Testable pass/fail with evidence. If a criterion cannot be evaluated without forming an opinion about the code, it is a wish. Rewrite to something a reviewer can check with a command or by reading a specific output — "returns 400 when the body is missing the `signature` header," "the migration adds a `deleted_at` column to `users`."
- **Expected file changes.** More granular than the `touches` frontmatter field. Each entry is path + short intent (add / update / remove). This is where a reviewer spots unstated file changes in the diff after the fact.
- **Notes.** Starts empty. Leave it that way at creation — it is the implementer's and reviewer's place to append, not the author's.

## Flagging ambiguity in the source

If the source docs do not resolve a point this task needs, do not guess. For a small, local ambiguity — a specific field's type, a specific error code — write the task with a `TODO:` line in Context naming the gap, and surface the same question in `scratch/questions.md` for the main session. The task can ship with the flag; the implementer will see it and defer the guess upward. A task file with a hidden guess is worse than a missing task file; the hidden guess will be discovered only after the implementer has acted on it.

Structural ambiguity — which of two architectural paths this feature takes — is upstream of this skill. If you find one, stop writing; it belongs in decomposition or decision work, not inside the task file.

## Sizing

Per `task-format.md`, 50–150 lines is the target. The two failure modes:

- **Under 50 lines.** Usually under-excerpted — the task sends the implementer back to the source docs anyway. Pull more context in.
- **Over 150 lines.** Usually an oversized excerpt. Summarize in your own words and keep one or two load-bearing quotes verbatim. If trimming the excerpt does not recover the target, the unit probably wanted to be two tasks — that is a decomposition call and belongs upstream.

A 160-line task whose every line earns its place is fine. A 120-line task padded with ceremonial prose is not.

## IDs and numbering

Per `frontmatter-schema.md`, ids are zero-padded 4-digit strings, unique within the project, and match the filename prefix. Take the next unused project-wide id — not per-epic. Gaps are expected (a deleted or superseded task leaves its id retired); do not reuse ids to fill gaps.

## Epic mode: do not duplicate the parent

In epic mode, every task implicitly loads its parent `EPIC.md`. Do not duplicate the epic-level goal, scope, or exit criterion inside the task file. Quote from `EPIC.md` only when the task turns on a specific clause — and then only that clause. The parent is part of every subagent's context already; duplicating it taxes every load and breeds drift when the epic's scope shifts and only some tasks are updated.

## Examples

- `examples/good-task.md` — a clean mid-sized epic-mode task: outcome-framed Goal, excerpted Context with attribution, specific scope boundaries, testable acceptance criteria with evidence, Notes empty. **Read this before writing your first task in a session.**
