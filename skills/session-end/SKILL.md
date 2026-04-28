---
name: session-end
description: Update scratch/CURRENT.md with the session handoff and prune scratch/questions.md.
disable-model-invocation: true
---

# /metis:session-end

Close out the session: rewrite `CURRENT.md`, prune `questions.md`.

## Preconditions

- `scratch/` must exist. If it does not, stop and point at `/metis:init`.

## Load

- The current `scratch/CURRENT.md`.
- `scratch/questions.md`.
- The session's in-flight state from context — the active task, what just happened, what got decided, what is queued.

## Do not load

- Task files.
- `BUILD.md`, `epics/`, `decisions/`.
- Other plans in `scratch/plans/`.

## Read first

- `references/session-handoff.md` — read before writing the handoff.

## Write scope

- **`scratch/CURRENT.md`** — rewrite.
- **`scratch/questions.md`** — prune in place.

### Do not write to

- Task files.
- `BUILD.md`.
- `EPIC.md` files.
- `decisions/`.
- `docs/`.

## Invocation prompt

Follow the command-prompts convention in `.metis/conventions/command-prompts.md`. The four rules (augment / flag scope expansion / acknowledge use / resolve named skills) apply; acknowledge prompt usage in the return per rule 3.

The prompt is ephemeral — do not persist it into `CURRENT.md` or `questions.md`.

## Return

- **Handoff summary** — the four blocks of the new `CURRENT.md`, rendered inline.
- **Questions delta** — what was pruned from `questions.md`, what was added.
- **Pending decisions** — any architectural choice made this session that has not yet been filed. Surfaced as a flag, not written.
- **Next step** — typically the session ends here.
