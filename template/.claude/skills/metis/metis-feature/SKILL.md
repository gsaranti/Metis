---
name: metis:feature
description: Describe a new feature mid-stream. Produces a feature spec plus task files (flat layout) or a new epic with its task set (epic layout).
disable-model-invocation: true
---

# /metis:feature

Absorb a net-new feature into the project mid-stream. This is the command for *additions* — work that was not in `BUILD.md` when the breakdown or backlog was cut. `/metis:sync` handles changes to work already in the record; `/metis:log-work` handles code the user wrote outside Metis.

## Argument

- **Required**: a free-text description of the feature. If no description is supplied, stop and ask for one — the feature cannot be cut without intent.

## Preconditions

- `BUILD.md` must exist. If it does not, stop and point at `/metis:build-spec`:

  ```
  /metis:feature adds work relative to an existing BUILD.md, and
  did not find one.

  Run /metis:build-spec first, including this feature in the seed.
  ```

- Layout detection governs the output shape. Check the filesystem:
  - **Flat** (`tasks/` exists, `epics/` does not): produce a feature spec at `features/NNN-kebab-slug.md` plus task files in `tasks/`.
  - **Epic** (`epics/` exists, `tasks/` does not): produce a new `epics/NNN-kebab-name/` with `EPIC.md` and a task set under `tasks/`.
  - **Empty** (neither exists): treat as flat; the first layout-defining act is `/metis:generate-tasks` or this command.
  - **Ambiguous** (both populated): stop and surface the state; user resolves before this command proceeds.

## Load

- The feature description (the argument).
- `BUILD.md` — the architectural context the feature lands against.
- In epic mode, the names and goals of existing epics (from `EPIC.md` files) so this feature does not duplicate or straddle one; read the full `EPIC.md` only for a sibling whose scope the new feature might overlap.
- `docs/SYNTHESIS.md` and `docs/INDEX.md` if they exist — orientation for any corpus the feature description cites.
- `.metis/config.yaml` for the current `spec_version` to stamp new tasks with.

## Do not load

- The full epics' task files, or other epics' task directories. Layout-level coverage is enough to avoid collisions.
- `decisions/`, `BOARD.md`, `scratch/`. Grep `decisions/` by slug only if the feature description explicitly names a prior decision.
- `docs/CONTRADICTIONS.md`, `docs/QUESTIONS.md`, `docs/RESOLVED.md`. A feature that hinges on an unresolved Phase 0 item is premature; surface that rather than proceeding.

## Skills

Invoke by reference, in the order the flow needs them:

- `decomposing-build-into-epics` — invoked only in epic mode, to confirm the feature is epic-shaped rather than task-cluster-shaped. A feature that is really one task's worth of work should land in an existing epic or as a retro note, not as a new epic.
- `writing-an-epic-file` — invoked in epic mode once the new epic is confirmed.
- `decomposing-work-into-tasks` — the task-level cut.
- `writing-a-task-file` — invoked once the decomposition is approved.

In flat mode, only the task-level skills are needed; the "feature spec" lives at `features/NNN-kebab-slug.md` as a one-page brief carrying the description and the task set's coverage.

## Two-phase flow

1. **Propose.** Surface the shape: in flat mode, the feature spec's one-liner plus the proposed task set; in epic mode, the new epic (name, goal, exit criterion, dependencies) plus its initial task set. Flag structural ambiguity (a product-shape call the feature description did not commit to) and ask rather than taking a side. Wait for approval.
2. **Write.** On approval, scaffold the artifacts per the write scope below. In epic mode, pick the next unused epic id; in flat mode, pick the next unused feature id and then the next unused project-wide task ids.

## Write scope

- **Flat mode.** `features/NNN-kebab-slug.md` (feature spec — a short brief, one page, owning the feature's goal/scope/exit notes) and the task files in `tasks/`.
- **Epic mode.** `epics/NNN-kebab-name/EPIC.md` and task files under `epics/NNN-kebab-name/tasks/`.
- Create the parent directory (`features/` or `epics/NNN-name/tasks/`) if absent.

Do not write to `BUILD.md`, sibling epics' files, `decisions/`, `docs/`, or `scratch/`. If the feature warrants an architectural update to `BUILD.md`, that is a finding to surface — the update happens via `/metis:sync` with its decision entry.

## Invocation prompt

The command may carry a trailing free-text prompt after the description, e.g. `/metis:feature "weekly digest email" "keep it under four tasks; we ship this in one sprint"`.

Follow the command-prompts convention in `docs/metis-write-rules.md` § *Command-prompts convention*. The four rules (augment / flag scope expansion / acknowledge use / resolve named skills) apply; acknowledge prompt usage in the return per rule 3.

The prompt is ephemeral — do not persist it into the feature spec, the new epic, or any task file.

## Return

- **Proposed shape** during the propose phase — feature spec (flat) or new epic (epic) plus the initial task set.
- **Files written** during the write phase — each path written, with one-line summary.
- **Layout decision** — explicit note of the output shape chosen (flat feature spec vs. new epic) so the user can see the inference on a layout boundary.
- **Flagged ambiguities** — product-shape or scope calls the description did not commit to.
- **Next step** — `/metis:pick-task` (flat) or `/metis:pick-task` after confirming the new epic's first task is unblocked (epic).
- **Prompt usage** — if the invocation carried a prompt, one line on how it shaped the work.
