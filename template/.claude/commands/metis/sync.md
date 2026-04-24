---
description: Reconcile spec drift — cascade a source-doc or BUILD.md change through downstream epics and tasks one proposed edit at a time, writing a decision per accepted change.
argument-hint: [optional free-text prompt]
---

# /metis:sync

Write counterpart to `/metis:rebaseline`. When `docs/`, `BUILD.md`, or an epic has changed and downstream artifacts were baselined against the prior framing, this command walks the cascade: detect candidates, classify cosmetic vs. substantive, propose edits one at a time (or batch the cosmetic set), and record each accepted change as a `decisions/` entry. Main-session command — cross-document reasoning, not subagent work.

## Preconditions

- At least one artifact on disk that can drift. If the project has no tasks and no epics yet, there is nothing to cascade against — stop and point at `/metis:generate-tasks` or `/metis:epic-breakdown`.
- A detectable upstream change. Run the rebaseline check (same logic as `/metis:rebaseline`) before proposing any edits. If nothing has drifted, stop and report the empty set — a sync with no candidates is a cheap reassurance, not a no-op that writes decisions.

## Load

- `.metis/config.yaml` for the project `spec_version`.
- Task and epic frontmatter across the corpus — enough to run the drift scan and filter to the candidate set.
- For each candidate in the proposal phase: the task file or epic in full, plus the upstream change that made it a candidate (the specific doc passage or `BUILD.md` section).
- `decisions/` — grep-only, by slug, to surface any prior decision the change supersedes. Never bulk-read.

## Do not load

- The full source-doc corpus. Read only the passages the cascade walks.
- `BOARD.md`, `scratch/`. Neither feeds the cascade.
- Task bodies outside the candidate set. The point of the baseline is that a scan against it narrows the read.
- `docs/CONTRADICTIONS.md`, `docs/QUESTIONS.md`, `docs/RESOLVED.md`. Phase 0 resolution is a separate command.

## Skills

Invoke by reference, in the order the flow needs them:

- `propagating-spec-changes` — the primary teaching. Detection, cosmetic-vs-substantive classification, cascade rules by task and epic status (`done` → new task or superseding decision; `in-progress` → confirm; `pending` / `in-review` → edit in place), baseline-after-edit discipline, termination rules, and decision-per-accepted-change shaping. Read it before proposing anything.
- `writing-decisions` — invoked per accepted substantive change. One decision per coherent upstream shift, not one per cascade.

## Flow

1. **Detect.** Run the drift scan. Produce the candidate set split by kind (doc drift, spec drift, filesystem drift) and by affected artifact.
2. **Classify.** For each candidate, classify the upstream change as cosmetic or substantive. Cosmetic changes propagate via a single bulk-approval prompt; substantive changes walk one at a time. When unsure, err substantive.
3. **Walk the substantive set.** For each substantive candidate: show the user the upstream change, the artifact, and the proposed edit. Apply status rules — `done` tasks get a new task or a superseding decision, never in-place; `in-progress` needs explicit confirmation; `pending` / `in-review` edits land with approval.
4. **Record.** Per accepted substantive change (and per accepted cosmetic *batch*), write a `decisions/` entry via `writing-decisions` naming the upstream change, the downstream artifacts edited, and the consequences.
5. **Bump baselines.** When a task absorbs a substantive edit (or is inspected and judged non-edit), bump its `doc_hashes` and, when `BUILD.md` was touched, its `spec_version`. Skipping the bump means the next rebaseline re-surfaces the same candidate.
6. **Terminate if runaway.** When the cascade would walk an unreasonable number of items (dozens of substantive edits from one change, candidates running into every epic), stop and surface upstream rather than pushing through. A partial `BUILD.md` rewrite or a fresh reconcile on the affected slice produces a smaller, honest cascade.

## Write scope

- Task files across the candidate set — `status`, Notes appends for cascade record, `doc_hashes` / `spec_version` bumps after absorption. `done` tasks are never edited in place; drift against them becomes a new task or a superseding decision.
- Epic files (`EPIC.md`) across the candidate set, under the same status-aware rules.
- New task files when a `done` task's drift spawns net-new implementation work.
- `decisions/YYYY-MM-DD-<slug>.md` — one per accepted substantive change or per accepted cosmetic batch.
- `.metis/config.yaml` — bump the project `spec_version` when the cascade landed a `BUILD.md`-level change.

Do not write to `BUILD.md` or source docs directly. This command propagates *from* an upstream change the user or a separate command already made; it does not author the upstream change. If the cascade surfaces that `BUILD.md` itself has an issue, flag it — editing `BUILD.md` is a separate act (hand edit plus a `/metis:sync` cascade on the result, or a `/metis:build-spec` on a deleted file for a hard restart).

Do not write to `BOARD.md`, `scratch/`, `docs/` beyond what a cascade might name.

## Invocation prompt

The command may carry a trailing free-text prompt, e.g. `/metis:sync "only propagate the auth doc changes, defer the billing ones"`. Four rules:

1. **Augment, do not replace.** The drift set and the cascade rules remain authoritative. If the prompt asks the cascade to skip a rule (e.g., "just overwrite the done tasks"), flag the conflict rather than comply.
2. **Flag scope expansion.** If the prompt asks the cascade to edit artifacts outside the detected candidate set, note the expansion and decline. A cascade's scope is what drift detection surfaced, not a free-form rewrite.
3. **Acknowledge use explicitly.** State in the return how the prompt shaped the walk — which candidates got deferred, which got prioritized, which got reclassified substantive on the user's flag.
4. **Resolve named skills.** The prompt may name additional skills for this turn. Resolve each reference the same way any skill reference is resolved, across whatever skill sources the runtime exposes. Acknowledge each invoked skill's influence; flag unresolvable names rather than guessing. User-referenced skills augment `propagating-spec-changes` and `writing-decisions`; they do not override the cascade rules by status.

The prompt is ephemeral — do not persist it into task files, epic files, or decision entries.

## Return

- **Candidate summary** — cosmetic batch count, substantive walk count, structural inconsistencies named.
- **Edits landed** — one line per task, epic, or new-task spawned. Include the decision filename each edit was recorded against.
- **Deferred** — candidates the user chose not to walk now. They stay in the drift report for a later pass.
- **Baselines bumped** — which task `doc_hashes` / `spec_version` were updated, and whether the project `spec_version` advanced.
- **Pending follow-ups** — new tasks spawned from `done`-task drift, named so the user can pick them up next.
- **Prompt usage** — one line if a prompt was carried.
- **Next step** — `/metis:rebaseline` to confirm the drift set is empty after this pass (or narrowed enough to defer further work).
