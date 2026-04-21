---
name: decomposing-work-into-tasks
description: Reference for cutting a body of work into the right number of task-shaped units — task-vs-not judgment, split and merge signals, and flagging structural ambiguity before it bakes into files.
disable-model-invocation: true
---

# Decomposing work into tasks

A task is one unit of implementation work with its own testable acceptance criteria. The job of this skill is to take a body of work — a `BUILD.md` section, an `EPIC.md`, a mid-stream feature description — and decide how many tasks it wants to be, which unit of work goes into each, and whether any candidate units are not task-shaped at all. The output is the list of units that will be handed to the file-writing step, not files themselves.

Two failure modes pull against each other: cutting too fine, so sibling tasks share all their context and get worked in the same sitting anyway; and cutting too coarse, so one task carries a second task's work and its acceptance criteria cannot be evaluated independently.

## Read first

- `.metis/conventions/task-format.md` — what "task-shaped" means structurally: single testable outcome, ~400–1200 word target per file, excerpted source context. The sizing target is the constraint decomposition has to respect.

Load `.metis/conventions/epic-format.md` on demand when the body of work being decomposed lives inside an epic — the epic's scope and exit criterion bound what belongs in this batch and what belongs elsewhere.

## Where to cut

When unsure where to slice, look for seams the work already exposes: a module or service, a route or screen, an integration boundary, a single entity's lifecycle, an observable user capability. Cuts along existing seams tend to produce units with naturally disjoint file sets and independent acceptance criteria; cuts made against the grain tend to produce siblings that share so much context they wanted to be one task.

## Is this task-shaped?

Before adding a unit to the decomposition, check that it belongs in a task file at all. The failure mode on either side is real: fragmenting work that belongs inline, or promoting a question into a task that cannot be implemented.

- **Task vs. checklist item.** A step with no independent acceptance criterion, sharing all its context with a sibling, and worked in the same sitting either way — that is a bullet in a larger task's Expected file changes, not a new task. The test: could this be picked up by a different person in a different session and still make sense?
- **Task vs. spike.** Exploratory work without a testable outcome — "figure out whether library X meets our needs" — goes in `scratch/exploration/`. When the exploration concludes, it may spawn real tasks; that is how it enters the task system.
- **Task vs. decision.** A choice that must be made before work can proceed is a decision, not a task. If you catch yourself writing a unit whose acceptance criterion is "we have decided X," file it as a decision instead, via an open-item resolution or a direct `decisions/` entry.
- **Task vs. epic.** One unit covering a whole capability ("Implement auth") is an epic in disguise. If the unit reads at capability level and would carry four unrelated surfaces, step back to epic-level decomposition first.

## Splitting and merging

Signals a unit wants to split:

- Two acceptance criteria that could genuinely be evaluated independently — one could pass while the other fails without it being a bug.
- Two disjoint sets of files with no overlap and no shared code paths.
- A sizing pass on the eventual file would push it past ~1200 words and trimming excerpts would not recover it.

Signals two units want to merge:

- Identical source-doc references and heavily overlapping file sets.
- One unit's acceptance criterion is a prerequisite state of the other and has no observable effect on its own.
- Both would land in the same commit anyway.

Use `depends_on` in the eventual frontmatter to express ordering between tasks that should stay separate — not as a way to avoid merging. A strict dependency chain wants to collapse into one task only when the intermediate states have no standalone reviewable or user-visible value; when each step would be a real milestone on its own, keep them separate and let `depends_on` carry the order.

## Flagging structural ambiguity

Decomposition often surfaces architectural choices the source docs did not resolve: which of two persistence strategies to use, whether a concern lives in this service or a new one, whether a feature's v1 is scoped to one platform or two. Do not encode a guess into the decomposition — a hidden guess at this layer produces a chain of downstream files that all have to be redone once the choice is made.

Instead, stop and surface the question. Structural ambiguity is resolved via an open item, a decision entry, or a direct conversation — not inside a task. Local ambiguity (a specific field's type, a specific error code) is a different animal; it belongs in the eventual task file as a `TODO:` flag and is handled by the file-writing step, not here.

## Batch shape

A decomposition is the set of units that come out together. Two batch-level checks before handing off:

- **Coverage.** Every piece of the input body of work belongs to exactly one unit, is explicitly deferred (noted as out of scope with a one-line reason), or is resolved as not task-shaped above. Gaps that were neither split out nor deferred are the most common source of "missing work" found later.
- **Independence.** Take any two units in the batch. Could one ship without the other and still make sense? If the honest answer is "no, they're really one piece of work," merge them.

## Examples

- `examples/good-decomposition.md` — a short body of work and the resulting list of task-shaped units, with one-line rationale per cut and per merge. **Read this before your first decomposition in a session.**
