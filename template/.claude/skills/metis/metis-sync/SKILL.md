---
name: metis:sync
description: Reconcile spec drift — cascade a source-doc or BUILD.md change through downstream epics and tasks one proposed edit at a time, writing a decision per accepted change.
disable-model-invocation: true
---

# /metis:sync

Cascade a detected upstream change through downstream tasks and epics one proposed edit at a time, recording each accepted change as a `decisions/` entry. After the cascade settles, walk any `BUILD.md` gaps the cascade surfaced.

## Run the preflight

Invoke `.metis/scripts/sync-preflight.sh` first.

- Exit non-zero: surface the script's stderr verbatim and stop.
- Summary `status=no-artifacts`: stop and point at `/metis:generate-tasks` or `/metis:epic-breakdown` — there are no downstream artifacts to cascade against.
- Summary `total=0`: stop and report the empty set.

Otherwise, proceed with the Flow against the reported candidate set.

## Load

- The scan output.
- For each candidate in the proposal phase: the task file or epic in full, plus the upstream change that made it a candidate (the specific doc passage or `BUILD.md` section).
- `decisions/` — grep-only, by slug, to surface any prior decision the change supersedes.

## Do not load

- The full source-doc corpus.
- `scratch/`.
- Task bodies outside the candidate set.
- `docs/CONTRADICTIONS.md`, `docs/QUESTIONS.md`, `docs/RESOLVED.md`.

## Skills

Invoke by reference, in the order the flow needs them:

- `propagating-spec-changes` — read before proposing edits.
- `writing-decisions` — invoked per accepted substantive change and per accepted upstream `BUILD.md` edit.

## Flow

1. **Classify.** For each candidate in the scan output, classify the upstream change as cosmetic or substantive. Cosmetic changes propagate via a single bulk-approval prompt; substantive changes walk one at a time. When unsure, err substantive.
2. **Walk the substantive set.** For each substantive candidate: show the user the upstream change, the artifact, and the proposed edit. Apply status rules — `done` tasks get a new task or a superseding decision, never in-place; `in-progress` needs explicit confirmation; `pending` / `in-review` edits land with approval. Collect `BUILD.md` surfaces along the way — observations where `BUILD.md` is silent, stale, or wrong on something the cascade had to resolve. Do not act on them yet; carry them into step 5.
3. **Record.** Per accepted substantive change (and per accepted cosmetic *batch*), write a `decisions/` entry via `writing-decisions` naming the upstream change, the downstream artifacts edited, and the consequences.
4. **Bump baselines.** When a task absorbs a substantive edit (or is inspected and judged non-edit), bump its `doc_hashes` and, when the upstream change was a `BUILD.md` shift, its `spec_version`.
5. **Upstream pass.** If the walk collected any `BUILD.md` surfaces, propose each as a `BUILD.md` edit with explicit user approval. Per accepted edit: write the edit, file a `decisions/` entry, and bump the project `spec_version` in `.metis/config.yaml` when the edit was substantive. Source docs in `docs/` remain off-limits — those are upstream of sync. If the surface is a wholesale `BUILD.md` rewrite rather than a targeted edit, stop and point at `/metis:build-spec` instead.
6. **Terminate if runaway.** When the cascade would walk an unreasonable number of items (dozens of substantive edits from one change, candidates running into every epic), stop and surface upstream rather than pushing through.

## Write scope

- Task files across the candidate set — `status`, Notes appends for cascade record, `doc_hashes` / `spec_version` bumps after absorption. `done` tasks are never edited in place; drift against them becomes a new task or a superseding decision.
- Epic files (`EPIC.md`) across the candidate set, under the same status-aware rules.
- New task files when a `done` task's drift spawns net-new implementation work.
- `decisions/YYYY-MM-DD-<slug>.md` — one per accepted substantive change, per accepted cosmetic batch, and per accepted upstream `BUILD.md` edit.
- `BUILD.md` — only in the upstream pass (Flow step 5), one edit at a time with explicit user approval.
- `.metis/config.yaml` — bump the project `spec_version` after a substantive `BUILD.md` edit lands in the upstream pass.

### Do not write to

- Source docs in `docs/`.
- `scratch/`.

## Invocation prompt

The command may carry a trailing free-text prompt, e.g. `/metis:sync "only propagate the auth doc changes, defer the billing ones"`.

Follow the command-prompts convention in `.metis/conventions/command-prompts.md`. The four rules (augment / flag scope expansion / acknowledge use / resolve named skills) apply; acknowledge prompt usage in the return per rule 3.

The prompt is ephemeral — do not persist it into task files, epic files, or decision entries.

## Return

- **Candidate summary** — cosmetic batch count, substantive walk count, structural inconsistencies named.
- **Edits landed** — one line per task, epic, or new-task spawned. Include the decision filename each edit was recorded against.
- **Upstream edits** — `BUILD.md` edits landed in the upstream pass, each with its decision filename. "(none)" if no `BUILD.md` surfaces were proposed or accepted.
- **Deferred** — candidates the user chose not to walk now, plus any `BUILD.md` surfaces the user declined.
- **Baselines bumped** — which task `doc_hashes` / `spec_version` were updated, and whether the project `spec_version` advanced.
- **Pending follow-ups** — new tasks spawned from `done`-task drift.
- **Next step** — `/metis:rebaseline` to confirm the drift set is empty. If the upstream pass advanced the project `spec_version`, a fresh `/metis:sync` may be wanted to cascade the new `BUILD.md` against tasks not in this pass's candidate set.
