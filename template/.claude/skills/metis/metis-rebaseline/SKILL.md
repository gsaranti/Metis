---
name: metis:rebaseline
description: Drift detector — compare current docs/, BUILD.md, and task/epic frontmatter against the lightweight baseline and report what changed. Read-only.
disable-model-invocation: true
---

# /metis:rebaseline

Detect drift between the project's current state and the baseline downstream artifacts were written against. Read-only. Reports only; does not propose or apply changes — that is `/metis:sync` territory.

## Preconditions

- The project must have a baseline to compare against. A baseline exists when task or epic frontmatter carries `doc_hashes` and `spec_version`, or when the project has git history such that a prior state can be recovered. If neither holds — a freshly scaffolded project with no tasks — stop and report:

  ```
  /metis:rebaseline has nothing to compare against yet. Tasks and
  epics store their baseline in frontmatter (doc_hashes, spec_version);
  run /metis:generate-tasks or /metis:epic-breakdown first.
  ```

## What counts as drift

Three kinds:

- **Doc drift.** A file under `docs/` has changed since one or more tasks or epics last baselined against it. Detect by computing the current `doc_hash` for each path named in `docs_refs` and comparing against the stored `doc_hashes` entry. A mismatch is a candidate.
- **Spec drift.** `BUILD.md` has changed since one or more tasks baselined against it. Detect by comparing the project `spec_version` in `.metis/config.yaml` against each task's frontmatter `spec_version`. A trailing version that overlaps the changed `BUILD.md` sections is a candidate.
- **Filesystem drift.** A task file cites a `docs_refs` path that no longer exists, or a task's `epic` frontmatter points at an epic that is not on disk, or the project layout has become ambiguous (both `tasks/` and `epics/` populated). These are structural inconsistencies, not just content drift.

## Load

- `.metis/config.yaml` for the project `spec_version`.
- Task frontmatter across `tasks/` and `epics/*/tasks/`. Read frontmatter only — bodies are not needed for drift detection.
- Epic frontmatter across `epics/*/EPIC.md`.
- The current on-disk hashes for each distinct path named in any `docs_refs` across the corpus. Compute once per path; tasks that share a path share the check.
- `BUILD.md` — read to identify which sections have changed since the version the trailing tasks baselined against, when git history is available. When it is not, name the spec-version gap without attributing it to specific sections.

## Do not load

- Task bodies, epic bodies, decision entries, source docs themselves. The drift check is against metadata, not content; loading content expands the command from drift detector into drift explainer.
- `scratch/`, `docs/CONTRADICTIONS.md`, `docs/QUESTIONS.md`, `docs/RESOLVED.md`. None of these feed the baseline.

## Skills

This command does not invoke a skill. The drift check is a mechanical comparison against baseline fields; no judgment skill is pulling weight here. `/metis:sync` invokes `propagating-spec-changes` once the user chooses to act on a finding.

## Write scope

**None.** This is a read-only command. If the report surfaces a `doc_hash` field that is missing where it should be present (a task whose `docs_refs` was never baselined), name the gap but do not populate it here — that happens during the next `/metis:sync` pass or on task creation.

## Return

- **Doc drift** — for each changed doc, the list of tasks and epics whose `docs_refs` include it, plus each artifact's `status`. Statuses matter because they govern what the eventual cascade can do.
- **Spec drift** — for each task trailing the project `spec_version`, the version gap and (when git makes it visible) which sections of `BUILD.md` likely caused the gap.
- **Filesystem drift** — each structural inconsistency named concretely, with the pair of files or paths involved.
- **Summary counts** — total candidates by kind, so the user can tell at a glance whether the drift is one stale doc or something structural.
- **Next step** — when drift is present, `/metis:sync` is the write counterpart. The user decides whether the scope justifies a cascade now or later. When no drift is found, say so — an empty report is a cheap reassurance.

This command silently accepts and ignores any trailing free-text prompt. The drift report is mechanical; `/metis:sync` is the command where a prompt meaningfully shapes the turn.
