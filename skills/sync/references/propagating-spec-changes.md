# Propagating spec changes

A cascade is what happens when one upstream change — an edit to a file in `docs/`, or a direct edit to `BUILD.md` — reaches downstream artifacts that were built against the prior framing. The job of this skill is to detect what the change reaches, classify each candidate as cosmetic or substantive, move through the substantive set under user approval using status-aware rules, and record each accepted change as a decision so the "why" is not buried in file edits.

Two failure modes pull against each other. Silent drift leaves downstream artifacts quoting a passage the source has since rewritten; a later reader plans against a framing the docs no longer support. Indiscriminate cascade walks every wording tweak as a commitment shift; ceremony exhausts the user and the changes that actually matter get rubber-stamped inside the pile.

## Read first

- `.metis/conventions/decision-format.md` — every accepted cascading change produces a decision.
- `.metis/conventions/task-format.md` — the structural target for downstream task-file edits.

## What the change reaches

Detection is a scan, not a walk. `docs_refs` on task and epic frontmatter names the candidate set — artifacts that cite the changed file. `doc_hashes` and `spec_version` narrow it: a task whose `doc_hashes` entry for the changed path no longer matches was baselined before the change and deserves a look; a task whose `spec_version` trails the project's and whose `docs_refs` overlap the moved `BUILD.md` sections does too.

A candidate is not an edit. Read the change against each candidate's excerpted Context before deciding — a task whose excerpt still reads as true is a non-edit even with a mismatched hash.

## Cosmetic vs. substantive

Classification is the hinge of the cascade. Cosmetic changes are wording tightened, a heading renumbered, a clause rephrased without moving what it commits the project to. Substantive changes shift a commitment — a threshold, a failure mode, a scope boundary, a flow step, a field's semantics, an invariant downstream work was written against.

The test: does the change alter what a reviewer would check, or what an implementer would build? If no, cosmetic. If yes, substantive.

Cosmetic edits across the candidate set propagate as a single bulk-approval prompt — the changed passage, the artifacts that quote it, one line of rationale. If any candidate's acceptance criteria turn on the specific wording being rephrased, that candidate leaves the batch and gets reclassified substantive. Substantive edits get the walk register: one item, the diff the cascade proposes, user accepts or redirects. Bulk-approving a substantive edit is the failure mode this classification exists to prevent; when unsure, err substantive and walk.

## Cascade by task status

Each task's `status` determines the rule the cascade applies to it:

- `pending` / `in-review` — edit in place with approval. No code has committed to the prior framing that the edit invalidates; an accepted substantive edit against `in-review` usually reopens the review, which the proposed diff should call out.
- `in-progress` — explicit confirmation before editing. Someone is actively working against the current framing, and a silent edit reframes their work mid-flight; surface the proposed change and let the user decide whether to land it now, defer until the task exits `in-progress`, or redirect the in-flight work.
- `done` — never edited in place. The task is the historical record of what was built against the prior spec; drift against it becomes a new task or a superseding decision, not a rewrite of the archive.
- `blocked` — treat as `pending`. The block is orthogonal to the cascade and does not license silent edits.

## Cascade by epic state

Epic states mirror task states. The one nuance: `in-progress` epics bundle any in-flight tasks the shift invalidates into the same cascade pass.

## `done` tasks: new task or superseding decision

A `done` task's drift has two possible resolutions, and the choice is substantive.

A new task is right when the change creates implementation work — a behavior to add, a case to handle, a field to migrate, a flow step that needs code. The new task references the upstream change in its Context, and its relationship to the `done` task lives in the decision entry rather than in either task file.

A superseding decision alone is right when the change retracts or reframes a commitment without requiring net-new implementation — a threshold tightened within what the code already enforces, a deprecated option never built, a scope line redrawn around work already shipped.

When both are true, do both: the decision records the reframing, the new task carries the work, and each cross-references the other.

## Decision per accepted change

One decision per accepted cascading change, not one per cascade. The unit is one coherent upstream commitment shift — a single doc edit, or one `BUILD.md` section rewrite — absorbed across its candidate set. An independent downstream policy question the cascade happens to uncover gets its own decision.

Context pins the upstream change to a specific path and passage, or to the `BUILD.md` section that shifted. Decision names the downstream edits the cascade landed — which task files were edited, which `done` tasks spawned superseders or follow-ups, which epic scopes narrowed — as a concrete list, not a summary. Consequences names what this commits the project to that the upstream change alone did not.

The file's shape lives in `.metis/conventions/decision-format.md`; what this skill names is what Context must make legible for a later reader — the upstream change, the candidate set, the classification call, and the specific downstream artifacts that absorbed it.

## Baseline after edits land

When a task absorbs a substantive edit, bump its `doc_hashes` entry for the changed path and, if the cascade touched `BUILD.md`, its `spec_version`. Skipping the bump leaves the task indistinguishable from drift; the next rebaseline re-surfaces it and the cascade gets proposed a second time against a file that already absorbed it. Tasks inspected and judged non-edit get the same bump — the reviewer having looked is what the baseline now reflects.

## Termination

A cascade can propose more work than it can honestly absorb. Dozens of substantive edits spawning from one upstream change, the candidate set running into every epic, the decision log ballooning to track it — signals the upstream change was too large for a cascade to hold.

The move is to stop and surface upstream. A partial `BUILD.md` rewrite, a fresh reconcile pass over the affected slice, or a scoped-down upstream edit each produces a smaller, honest cascade.

## Examples

- `examples/good-cascade.md` — one doc change propagating across a small mixed batch: a cosmetic batch, a `pending` walked edit, an `in-progress` confirmed edit, a `done` task spawning a superseding decision, and the full decision file the cascade wrote. **Read this before your first cascade in a session.**
