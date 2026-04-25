---
name: metis:rebaseline
description: Drift detector — compare current docs/, BUILD.md, and task/epic frontmatter against the lightweight baseline and report what changed. Read-only.
disable-model-invocation: true
---

# /metis:rebaseline

Compare each task and epic's stored baseline against the current state of `docs/` and `BUILD.md`. Report drift only; do not propose or apply changes.

## Preconditions

- At least one task or epic must carry `doc_hashes` and `spec_version` in frontmatter. If none do, stop and report:

  ```
  /metis:rebaseline has nothing to compare against yet. Tasks and
  epics store their baseline in frontmatter (doc_hashes, spec_version);
  run /metis:generate-tasks or /metis:epic-breakdown first.
  ```

## What counts as drift

Three kinds:

- **Doc drift.** A file under `docs/` has changed since one or more tasks or epics last baselined against it.
- **Spec drift.** `BUILD.md` has changed since one or more tasks baselined against it — detectable via the project `spec_version` vs. each task's stored `spec_version`.
- **Filesystem drift.** A task cites a `docs_refs` path that no longer exists, a task's `epic` frontmatter points at an epic that is not on disk, or the layout has become ambiguous (both `tasks/` and `epics/` populated).

## Load

- `.metis/config.yaml` for the project `spec_version`.
- Task frontmatter across `tasks/` and `epics/*/tasks/` (frontmatter only).
- Epic frontmatter across `epics/*/EPIC.md`.
- Current on-disk hashes for each distinct path named in any `docs_refs` — compute once per path and share across tasks.
- `BUILD.md` — when git history is available, identify which sections have changed; otherwise name only the spec-version gap.

## Do not load

- Task bodies, epic bodies, decision entries, source docs themselves.
- `scratch/`, `docs/CONTRADICTIONS.md`, `docs/QUESTIONS.md`, `docs/RESOLVED.md`.

## Write scope

**None.** If a task's `docs_refs` was never baselined, name the gap; do not populate it here.

## Invocation prompt

Silently accept and ignore any trailing free-text prompt.

## Return

- **Doc drift** — for each changed doc, the tasks and epics whose `docs_refs` include it, plus each artifact's `status`.
- **Spec drift** — for each task trailing the project `spec_version`, the version gap plus, when git makes it visible, the `BUILD.md` sections that likely caused it.
- **Filesystem drift** — each structural inconsistency, with the pair of files or paths involved.
- **Summary counts** — total candidates by kind.
- **Next step** — `/metis:sync` if drift warrants a cascade; say so when the report is empty.
