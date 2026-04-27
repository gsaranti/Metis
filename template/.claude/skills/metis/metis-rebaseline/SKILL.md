---
name: metis:rebaseline
description: Drift detector — compare current docs/, BUILD.md, and task/epic frontmatter against the lightweight baseline and report what changed. Read-only.
disable-model-invocation: true
---

# /metis:rebaseline

Compare each task and epic's stored baseline against the current state of `docs/` and `BUILD.md`. Report drift only; do not propose or apply changes.

## Run the scan

Invoke `.metis/scripts/drift-scan.sh`. The script enumerates tasks and epics, computes current doc hashes, and emits the candidate set in three sections (Doc drift, Spec drift, Filesystem drift) plus a Summary footer.

If the script exits non-zero, surface its stderr verbatim and stop.

If the Summary reports `status=no-artifacts`, report that the project has no tasks or epics to baseline against and point at `/metis:generate-tasks` or `/metis:epic-breakdown`.

## Load

- The scan output. The Return is rendered directly from it.

## Do not load

- Task bodies, epic bodies, decision entries, source docs themselves.
- `scratch/`, `docs/CONTRADICTIONS.md`, `docs/QUESTIONS.md`, `docs/RESOLVED.md`.

## Write scope

**None.** If the scan reports a task whose `docs_refs` was never baselined, name the gap; do not populate it here.

## Invocation prompt

Silently accept and ignore any trailing free-text prompt.

## Return

- **Doc drift** — for each changed doc, the tasks and epics whose `docs_refs` include it, plus each artifact's `status`.
- **Spec drift** — for each task trailing the project `spec_version`, the version gap.
- **Filesystem drift** — each structural inconsistency, with the pair of files or paths involved.
- **Summary counts** — total candidates by kind.
- **Next step** — `/metis:sync` if drift warrants a cascade; say so when the report is empty.
