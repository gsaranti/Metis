---
name: metis:session-end
description: Update scratch/CURRENT.md with the session handoff, prune scratch/questions.md, and flag scratch candidates for promotion.
disable-model-invocation: true
---

# /metis:session-end

Close out the session. Rewrite `scratch/CURRENT.md` so the next session's rehydration is cheap. Prune `scratch/questions.md` to what is still open. Flag any scratch files that have earned their way out of `scratch/`.

## Preconditions

- No hard preconditions. The command runs even on a session that did nothing substantive — in that case the handoff will be mostly empty, which is fine.
- If `scratch/` itself does not exist, stop and point at `/metis:init` — the session-end surface lives under `scratch/` and has not been scaffolded yet.

## Load

- The current `scratch/CURRENT.md`. Load before writing so still-true context is preserved and state the previous session flagged as live is not dropped.
- `scratch/questions.md`. Read to decide what is still open, what got resolved, and what new questions landed this session.
- The session's in-flight state from context — the active task, what just happened, what got decided, what is queued. This is the session's own memory, not a file read.
- A short pass over `scratch/exploration/` and `scratch/research/` to spot candidates for promotion. Filenames and first-paragraph scan only; do not load the contents of every scratch file.

## Do not load

- Task files. The handoff references them by id; their state is already on disk for the next session.
- `BOARD.md`, `BUILD.md`, `epics/`, `decisions/`. None of these feed the handoff.
- Other plans in `scratch/plans/`. Plans are per-task artifacts, not session-level.

## Skills

Invoke by reference:

- `session-handoff` — the primary teaching for this command. The four blocks of `CURRENT.md` (*What happened*, *Current state*, *Open questions*, *Where to start*), the pruning rule for `scratch/questions.md`, the promotion-flagging heuristic, and the under-1k-tokens sizing target. Read it before writing the handoff.

## Write scope

- **`scratch/CURRENT.md`** — rewrite. This is the only file this command rewrites; preserving user-written sections across the rewrite is not required because the file is load-bearing as the *current* handoff, not as a history.
- **`scratch/questions.md`** — prune in place. Remove resolved entries; append new ones surfaced this session.

Do not write to task files, `decisions/`, `BUILD.md`, `BOARD.md`, `EPIC.md` files, or `docs/`. If this session produced a decision that has not been filed, flag it in the handoff's *Where to start* — writing the decision entry is its own act with its own discipline (see `writing-decisions`), not a silent append inside session-end.

Do not move scratch files out of `scratch/`. Promotion is flagged; the move is a separate, deliberate step.

## Invocation prompt

The command may carry a trailing free-text prompt, e.g. `/metis:session-end "flag that the retry-notes file needs to move into docs/ before the next session"`.

Follow the command-prompts convention in `.metis/conventions/command-prompts.md`. The four rules (augment / flag scope expansion / acknowledge use / resolve named skills) apply; acknowledge prompt usage in the return per rule 3.

The prompt is ephemeral — do not persist it into `CURRENT.md` or `questions.md`.

## Return

- **Handoff summary** — the four blocks of the new `CURRENT.md`, rendered inline for the user's convenience. The user reads this before the session closes so state has their signoff.
- **Questions delta** — what was pruned from `questions.md`, what was added.
- **Promotion candidates** — scratch files flagged inline in *Where to start* for the next session to move out. One line per.
- **Pending decisions** — any architectural choice made this session that has not yet been filed. Surfaced as a flag, not written.
- **Prompt usage** — one line if a prompt was carried.
- **Next step** — typically the session can end here; the user may follow up with `/metis:scratch-cleanup` if the flagged promotions should be landed immediately rather than deferred.
