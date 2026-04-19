---
id: "NNNN"
# epic: NNN-name           # required in epic mode; omit entirely in flat mode
title:
status: pending
# priority: 3              # 1–5, 1 is highest; default 3
# depends_on: []           # list of task ID strings, e.g. ["0003", "0005"]
# estimate: medium         # small | medium | large
# touches: []              # paths the task will modify
# docs_refs: []            # source-doc references; excerpt these into Context
# doc_hashes: {}           # generated — populated by /metis:rebaseline and /metis:sync
# spec_version: 1          # generated — set at task creation
---

## Goal

One or two sentences. The outcome, not the activity. "Users can Y," "the system enforces Z" — not "implement X."

## Context

Excerpt the relevant passages from each `docs_refs` entry as blockquotes with source attribution. Quote, do not just link — a subagent with only this task file and its cited docs must have enough to work.

> From `docs/path.md#anchor`:
>
> The passage verbatim.

## Scope boundaries

### In scope

- Specific capabilities or surfaces. Not categories.

### Out of scope

- Anything a reader might assume is included but isn't, with a one-line reason.

## Acceptance criteria

- Each criterion is a testable pass/fail condition with evidence. If it isn't checkable, it isn't a criterion.

## Expected file changes

- `path/to/file.ext` — brief intent (add / update / remove).

## Notes

<!-- Append-only. Starts empty. Implementer and reviewer append their returns here. -->
