---
name: writing-decisions
description: Reference for writing well-formed decision files — judging whether a decision is warranted vs. a note or question, phrasing Context / Decision / Consequences, slug naming, and the one-paragraph-per-section discipline.
disable-model-invocation: true
---

# Writing decisions

A decision file is a standing record of a choice that spans epics and sessions. The job of this skill is to keep each decision short, committal, and findable — and to catch the cases where a single "decision" is actually two, or where no decision was really needed in the first place.

## Read first

- `.metis/conventions/decision-format.md` — the structural spec (filename, section order, sizing). The format is not restated here; read it.
- `.metis/templates/decision.md` — the skeleton to start from.

## Permanence and preview

Decisions are append-only. A silently bad framing lives in the log forever or requires a superseder to correct — and upstream approval of the substance (a walk-open-items resolution, a sync confirmation, a log-work description) does not cover the framing produced here: the Context narrative, the Consequences named, the slug picked. This is the artifact where the preview step owned by the calling command most needs to run; skipping it is what turns a wrong phrasing into a permanent one.

If prior art on the topic is suspected but cannot be confirmed, surface that uncertainty during preview rather than hoping a filename or content search will catch it — the user is the backstop for duplicates, since semantically equivalent topics routinely take slightly different slugs (`auth-session-duration` vs `auth-session-lifetime` vs `refresh-token-policy`) and prose keywords are brittle across synonyms.

## When a decision is actually warranted

Write a decision when a choice is architecturally consequential and will need to be remembered later, outside the code and the task log. Good triggers:

- A `BUILD.md` edit changes a structural commitment (stack choice, system boundary, major API shape).
- Walking an open item resolves a contradiction or question with a concrete position.
- A sync propagates a substantive spec change that other work will have to follow.
- Logging external work reveals architecture-level intent that the task Notes cannot hold.

Do *not* write a decision for:

- Local implementation choices inside a task — those belong in the task's Notes, or in the plan file.
- Preferences that would be obvious from reading the resulting code.
- Things you cannot yet commit to. That is a question, not a decision. Put it in `scratch/questions.md` (or `docs/QUESTIONS.md` if it surfaced during reconcile) and come back when you have a position.

The test: would a reader six months from now benefit from finding this on its own, in `decisions/`, without context? If no, it is not a decision.

## How to think about each section

The convention file has the sizes and the structure. The judgment each section needs:

- **Context** states *what was being chosen between and why the choice was forced now*. It is not a history recap (the reader can get that elsewhere) and it is not the decision itself. If Context can be removed without losing what alternatives existed or why the choice was forced now, Context is doing its job wrong — either redundant with the Decision or missing the options. For retroactive decisions (choices already reflected in code, typically logged via `/metis:log-work` or walked out of an open item), Context should describe the architecture now in place and how it came to exist — not confabulate a prospective deliberation that never happened.
- **Decision** is imperative, in the present tense: "Refresh tokens last 30 days; access tokens last 15 minutes." Not "we considered X and Y and chose Y" — the comparison belongs in Context. A Decision that hedges ("we'll probably go with X for now") is a question masquerading as a decision; stop and file it as a question instead.
- **Consequences** is concrete — what this enables, what it costs, what it forecloses. Not aspirational ("we'll see how it goes"), not a reassurance ("this should be fine"). If you cannot name at least one concrete downstream effect, the decision is not ready to commit yet.
- **Evidence** is a pointer, not a recap. Link to the discussion, the prototype, the commit, the doc passage. Quote sparingly — the value is in where to look. If the section would be empty, delete it per the template.

## Picking a slug

Why the slug convention is a noun phrase about *what the decision concerns* rather than *what was decided*: when a decision is later superseded, the superseder's slug ("auth-session-shortened-to-seven-days" or similar) reads sensibly next to the original, and grepping for the topic surfaces both.

The date is the date the decision was *made*, not the date a related task was completed or the underlying conversation began.

## Sizing as feedback

When the file is running long, it is almost always two decisions — split it. A common failure pattern is bundling a primary choice (e.g., session duration) with an adjacent choice (e.g., refresh-token storage mechanism) because they came up in the same conversation. The right move is two files, each with its own Context focused on one choice, cross-referenced in Evidence.

## Cross-referencing

When a decision rests on a source doc passage or a prior decision, put the pointer in Evidence (or inline in Context if the pointer is what forced the choice). Use paths, not prose: `` `docs/auth.md §Sessions` `` beats "per the auth doc." This keeps Decision and Consequences readable at a glance, and makes the pointers greppable by the next reader.

## Examples

Two files, both demonstrating shapes the skill wants you to produce. Failure modes are described in the prose above, not kept as separate counter-example files.

- `examples/good-decision.md` — a clean decision. Tight Context naming the options, imperative Decision, concrete Consequences, no Evidence section because it is not needed. **Read this before writing your first decision in a session.**
- `examples/good-decision-superseding.md` — supersedes the above. Demonstrates the supersede-Context pattern and an Evidence section that earns its keep.
