---
name: metis:walk-open-items
description: Walk open items from docs/CONTRADICTIONS.md and docs/QUESTIONS.md one at a time, resolving each by updating the relevant source doc and archiving a pointer to docs/RESOLVED.md.
disable-model-invocation: true
---

# /metis:walk-open-items

Walk open items — contradictions and gray areas captured by `/metis:reconcile` — one at a time, resolving each into the source doc it points at and appending a minimal pointer to `docs/RESOLVED.md`. Phase 0 does not write `decisions/` entries.

## Preconditions

- At least one of `docs/CONTRADICTIONS.md` or `docs/QUESTIONS.md` must exist. If neither does, stop and point at `/metis:reconcile`:

  ```
  /metis:walk-open-items expects docs/CONTRADICTIONS.md and/or
  docs/QUESTIONS.md to exist. They are produced by /metis:reconcile.

  Run /metis:reconcile first, or skip to /metis:build-spec if the
  corpus has no open items to walk.
  ```

- If both files exist but contain no `open`, `deferred`, or `stale` items, report the empty set and suggest `/metis:build-spec`. Do not invent items to walk.

## Session-open bookkeeping

Count `open`, `deferred`, and `stale` entries across both files, and count `resolved` entries that were moved to `docs/RESOLVED.md` in prior sessions (the header pointer, not the body). Show the user the counts and offer the navigation choice:

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
- When the task lives under an epic, the parent `EPIC.md` *only if* an item turns on the epic's commitments — this command runs before epics typically exist, so skip by default.

## Do not load

- `docs/RESOLVED.md`. Archive-only. Load on demand only if the user explicitly asks whether a related topic has been resolved before.
- `BUILD.md`. Phase 0 finalizes the docs that `BUILD.md` will be written from; loading it biases resolution.
- Other open items. Walk one at a time; cross-contamination between items is how biased framing lands.
- `decisions/`, `tasks/`, `epics/`, `scratch/`. None of these apply to Phase 0 resolution.

## Skills

Invoke by reference:

- `walking-open-items` — the primary teaching for this command. The three registers (two genuine alternatives / one recommendation / an honest ask), the user-in-loop threshold between architectural and local resolutions, smallest-source-doc-edit discipline, the minimal `RESOLVED.md` pointer shape, and the `open` / `deferred` / `resolved` / `stale` lifecycle. Read it before offering options on the first item.

## Per-item flow

For each item the user elects to walk:

1. Verify the cited passages still say what the capture claims. If they do not, mark the item `stale` in its active file, note what changed, and move on — do not force a resolution against a framing the docs no longer make.
2. Pick the register that fits the item (alternatives / recommendation / ask) and present to the user.
3. On user choice or redirect, apply the source-doc edit — the smallest change that closes the captured gap.
4. Remove the item from its active file, append the minimal pointer to `docs/RESOLVED.md`, and proceed.
5. If the resolution surfaces a new downstream question, capture it as a fresh entry in the relevant active file rather than hiding it inside the closed item.

`deferred` items stay in the active file with the reason recorded in the body. `stale` items also stay — next reconcile replaces them.

## Write scope

- Source docs under `docs/` — the smallest edit per resolution.
- `docs/CONTRADICTIONS.md` and `docs/QUESTIONS.md` — remove resolved items; update status on `deferred` or `stale`; append newly surfaced items when a resolution spawned one.
- `docs/RESOLVED.md` — append the minimal pointer per resolved item. Create the file if absent.

Do not write to `BUILD.md`, `decisions/`, `tasks/`, `epics/`, or `scratch/`. Phase 0 resolutions live in the docs; decisions start at Phase 1.

## Invocation prompt

The command may carry a trailing free-text prompt, e.g. `/metis:walk-open-items "prioritize the auth items; defer anything billing-related"`.

Follow the command-prompts convention in `.metis/conventions/command-prompts.md`. The four rules (augment / flag scope expansion / acknowledge use / resolve named skills) apply; acknowledge prompt usage in the return per rule 3.

The prompt is ephemeral — do not persist it into any doc, pointer, or active-file entry.

## Return

When the user quits the walk or the open set is empty:

- **Resolved this session** — count plus the pointers appended to `docs/RESOLVED.md`.
- **Remaining** — open, deferred, stale counts split by file.
- **Doc edits** — list of source docs changed, one line per edit.
- **Next step** — `/metis:build-spec` when the open set is empty (or consciously deferred); otherwise a note that the walk can be resumed next session.
- **Prompt usage** — if the invocation carried a prompt, one line on how it shaped the walk.
