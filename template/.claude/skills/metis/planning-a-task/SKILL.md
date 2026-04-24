---
name: planning-a-task
description: Reference for writing one task's plan — an ordered sequence of steps with named file changes, a fit-for-purpose test approach, a specific verification command, and honest assumptions and flags.
disable-model-invocation: true
---

# Planning a task

A plan is the bridge from a task file to the implementer. The job of this skill is to take one task file and render it into a short, sequenced plan an implementer can execute without re-deriving the work from the task's source material. The plan does not contain code; it names the changes and the order they go in.

Two failure modes pull against each other. Over-planning prescribes every keystroke and pretends the task file isn't already the authoritative brief; the implementer reads a redundant summary before doing the work anyway. Under-planning hands over an outline — "add the handler, wire the verifier, test it" — and calls sequencing left to the reader a plan; the implementer ends up decomposing mid-implementation.

## Read first

- The task file being planned, and the source-doc passages behind its `docs_refs`. Re-open the cited sections when a step turns on a passage the task abbreviated.
- When the task lives under an epic, the parent `EPIC.md`. The plan stays inside the epic's exit criterion; a plan that reaches past it has crossed a task boundary, not a step boundary.

Load `.metis/conventions/task-format.md` on demand when a task-file field question arises. Use it as a lookup, not required reading.

## Artifact shape

There is no convention file for a plan. The on-disk shape sits here:

- **Ordered steps** — the sequence the implementer walks. Numbered.
- **Expected file changes** — the files or modules each step will modify, with a one-line intent. A speculative touch list is noise, not insurance.
- **Test approach** — which tests the plan writes or changes, when they run, and what they prove.
- **Verification command** — one command (or a minimum set) that shows the work is done.
- **Assumptions and flags** — what the plan had to guess, and what it could not settle and is returning upstream.

Sections beyond this belong in the task file's Notes or the plan was never a plan.

## Ordered steps, not a checklist

Sequencing is the point. A set of bullets that could be executed in any order is a decomposition, not a plan — the implementer still has to work out which bit unblocks which. Number the steps and make the dependency between them explicit when the order alone does not show it.

Step granularity is a judgment call. A step that takes a paragraph to describe is usually two steps; a step described in three words is usually three steps hidden in a checkbox. The working test: can the implementer execute this step, verify it, and move on without reading the next step first? If no, it is not one step.

## Test approach without forced TDD

Name the approach that fits the change. Tests-first earns its cost when the contract is sharp and known in advance — a pure function, a new endpoint with specified inputs and outputs, a migration's post-state. Tests-after is honest when the shape is itself the unknown — a refactor in progress, a spike, a UI pass where the assertion only comes from seeing the thing run. Some steps modify no behavior worth testing — a rename, a config change, a dependency bump — and the plan says so rather than manufacturing a test to preserve ritual.

Pick the register per step, not per plan. A plan with one contract-shaped step and one refactor-shaped step is allowed to mix.

## The verification command

Name a specific command the plan promises will show the implementation works end-to-end — `pytest tests/billing/test_webhook.py::test_signature_failure`, not "run the tests." Prefer the repo's native entry point (`make test`, `npm test -- <target>`, whatever the project already uses) over an invented shell recipe. The specificity is what makes the plan checkable: the implementer runs the command, the reviewer reads its output, neither of them has to rediscover what "the tests" meant.

If no single command can prove the work, name the minimum set and state what each one covers. Two commands with clean purposes beats one vague one. A plan that cannot name a verification command at all has not committed to what "done" looks like.

## Assumptions vs. flagged ambiguities

An **assumption** is a guess the plan needed to make and can name. Because it is named, the implementer and reviewer can check whether it held; the plan is still honest. "Assumes the existing `WebhookError` type carries the right fields for the new code path — fall back to a dedicated type if not" is an assumption worth keeping moving on.

A **flag** is a gap the plan could not settle without guessing in a way that would not be checkable. Local flags — a field type, a specific error code — go in the plan's flags section and the implementer is told to defer them upward. Structural flags — acceptance criteria that turn on behavior the source docs do not pin down — do not belong in a flags section. They belong upstream — the finding is that the task file itself is underspecified, not that the plan needs more words.

## The task may already be done

Before sequencing the plan, a light check against the task's `touches` and acceptance criteria is worth the cost. Glob the expected paths, read the likely files, look for whether the commitments the task makes are already evidenced in the code. If they are, the right return is not a plan — it is a finding naming which files already exist and which criteria are visibly met. The caller decides from the finding what to do next.

The bar is *is there evidence the work is substantially done*, not *is every criterion verified*. A full verification would re-read files the plan should only glance at; it belongs downstream of the plan, not inside it. When evidence is ambiguous — some files present, some criteria partially evident — produce the plan but flag the overlap in its assumptions section so the caller can weigh the overlap against proceeding. A plan that proceeds as if the code were absent when it is obviously present is the same kind of silent drift this skill warns against in the other direction.

## Pushing back on the task file

This is the one upstream-facing register the plan carries. When acceptance criteria cannot be made testable without an extra call, when two honest plans could be written depending on a scope detail the task did not fix, when `depends_on` is missing a real blocking prerequisite, when the task bundles two unrelated outcomes, or when making the plan honest would require changes outside the task's scope, the plan's job is to surface the gap upstream — not to widen itself until the ambiguity is hidden inside the steps. A plan that silently resolves a task-file ambiguity is where silent drift starts.

## Sizing as feedback

Short by default — a page or two for a normal task. The diagnostic is whether each section still earns its place, not a word count. A plan that has outgrown its task file is usually two tasks wearing one plan (return it upstream), or a plan that has started narrating intent between steps rather than sequencing them (trim the prose, keep the steps). A plan that is a single paragraph is almost always missing the verification command or the flags section.

## Examples

- `examples/good-plan.md` — a clean plan for a mid-sized task: numbered steps with their file changes, a specific verification command, test approach chosen per step, and one named assumption. **Read this before writing your first plan in a session.**
