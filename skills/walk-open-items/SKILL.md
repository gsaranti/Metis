---
name: walk-open-items
description: Walk captured open items one at a time, resolving each into the relevant source doc.
disable-model-invocation: true
---

# /metis:walk-open-items

Walk open items — contradictions and gray areas — one at a time, resolving each into the source doc it points at and appending a minimal pointer to `docs/RESOLVED.md`.

## Preflight

Run `${CLAUDE_PLUGIN_ROOT}/.metis/scripts/walk-open-items-preflight.sh` before starting. It exits non-zero if `docs/` is missing or if neither `CONTRADICTIONS.md` nor `QUESTIONS.md` exists (surface the error, point the user at `/metis:reconcile`, and stop). Otherwise it reports `OPEN`, `OPEN_CONTRADICTIONS`, `OPEN_QUESTIONS`, `DEFERRED`, `STALE`, and `RESOLVED_PRIOR`.

If `OPEN + DEFERRED + STALE == 0`, report the empty set and suggest `/metis:build-spec`. Otherwise show the counts and offer four navigation choices: continue from next, list all, pick by number, quit. After resolving an out-of-order item, ask whether to continue or pick another.

## Pacing

After each item: present the proposal and wait for the user's input — confirm / redirect / defer / quit — before opening the next item. Do not chain. The narrow auto-land carve-out in `references/walking-open-items.md` is the exception; the rhythm is one item, one user response.

## Load (per item)

- The one open item being walked — its status header, cited passages, and framing from the active file.
- The source-doc passages it cites. Re-open the source at the cited section; do not work off the capture's paraphrase.

## Do not load

- `docs/RESOLVED.md`.
- `BUILD.md`.
- Other open items.
- `decisions/`, `tasks/`, `epics/`, `scratch/`.

## Read first

`references/walking-open-items.md` — read before offering options on the first item.

## Write scope

- Source docs under `docs/` — the smallest edit per resolution.
- `docs/CONTRADICTIONS.md` and `docs/QUESTIONS.md` — remove resolved items; update status on `deferred` or `stale`; append newly surfaced items when a resolution spawned one.
- `docs/RESOLVED.md` — append the minimal pointer per resolved item. Create the file if absent.

Do not write to `BUILD.md`, `decisions/`, `tasks/`, `epics/`, or `scratch/`.

## Invocation prompt

Trailing prompt: see `.metis/conventions/command-prompts.md`.

## Return

When the user quits the walk or the open set is empty:

- **Resolved this session** — count plus the pointers appended to `docs/RESOLVED.md`.
- **Remaining** — open, deferred, stale counts split by file.
- **Doc edits** — list of source docs changed, one line per edit.
- **Next step** — `/metis:build-spec` when the open set is empty (or consciously deferred); otherwise a note that the walk can be resumed next session.
