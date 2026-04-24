---
name: metis:walk-open-items
description: Walk captured open items one at a time, resolving each into the relevant source doc.
disable-model-invocation: true
---

# /metis:walk-open-items

Walk open items — contradictions and gray areas — one at a time, resolving each into the source doc it points at and appending a minimal pointer to `docs/RESOLVED.md`.

## Preflight

Run `.metis/scripts/walk-open-items-preflight.sh` before starting. It exits non-zero if `docs/` is missing or if neither `CONTRADICTIONS.md` nor `QUESTIONS.md` exists (surface the error, point the user at `/metis:reconcile`, and stop). Otherwise it reports `OPEN`, `OPEN_CONTRADICTIONS`, `OPEN_QUESTIONS`, `DEFERRED`, `STALE`, and `RESOLVED_PRIOR`.

If `OPEN + DEFERRED + STALE == 0`, report the empty set and suggest `/metis:build-spec`. Otherwise show the user the counts and offer the navigation choice:

```
You have N open items remaining (C contradictions, Q questions).
R were resolved in previous sessions.

  [C] continue from the next open item
  [L] list all open items
  [N] pick by number
  [Q] quit the walk (resume later)
```

Non-sequential navigation is first-class — after resolving an out-of-order item, ask "continue to next open, or pick another?" rather than forcing linearity.

## Load (per item)

- The one open item being walked — its status header, cited passages, and framing from the active file.
- The source-doc passages it cites. Re-open the source at the cited section; do not work off the capture's paraphrase.

## Do not load

- `docs/RESOLVED.md`. Archive-only. Load on demand only if the user explicitly asks whether a related topic has been resolved before.
- `BUILD.md`. Loading it biases resolution toward downstream framing.
- Other open items. Walk one at a time; cross-contamination between items is how biased framing lands.
- `decisions/`, `tasks/`, `epics/`, `scratch/`.

## Skills

Invoke `walking-open-items` by reference — read the skill file before offering options on the first item.

## Write scope

- Source docs under `docs/` — the smallest edit per resolution.
- `docs/CONTRADICTIONS.md` and `docs/QUESTIONS.md` — remove resolved items; update status on `deferred` or `stale`; append newly surfaced items when a resolution spawned one.
- `docs/RESOLVED.md` — append the minimal pointer per resolved item. Create the file if absent.

Do not write to `BUILD.md`, `decisions/`, `tasks/`, `epics/`, or `scratch/`.

## Invocation prompt

Follow the command-prompts convention in `.metis/conventions/command-prompts.md`. The four rules (augment / flag scope expansion / acknowledge use / resolve named skills) apply; acknowledge prompt usage in the return per rule 3.

The prompt is ephemeral — do not persist it into any doc, pointer, or active-file entry.

## Return

When the user quits the walk or the open set is empty:

- **Resolved this session** — count plus the pointers appended to `docs/RESOLVED.md`.
- **Remaining** — open, deferred, stale counts split by file.
- **Doc edits** — list of source docs changed, one line per edit.
- **Next step** — `/metis:build-spec` when the open set is empty (or consciously deferred); otherwise a note that the walk can be resumed next session.
- **Prompt usage** — if the invocation carried a prompt, one line on how it shaped the walk.
