# Session handoff

`scratch/CURRENT.md` is the handoff note the next session reads first to rehydrate — what happened, where things stand, what's still open, and where to start. The job of this skill is to render that note tightly enough that the fresh session gets oriented from a small, predictable read rather than from the session's transcript or from grepping through task files and scratch.

Two failure modes pull against each other. Under-reporting leaves the next session to re-discover what it needs — "continued on 0007" reads like a handoff but forces the reader to open the task file and guess at the state of play. Over-reporting narrates the whole session — every file touched, every decision explored, every aside — and buries the one or two lines the next session actually needs under the ones it doesn't.

## Read first

- The current `scratch/CURRENT.md` being replaced. Writing the next handoff without it makes it easy to re-state still-true context or drop state the previous session flagged as live.
- `scratch/questions.md`. The open-questions block in the handoff is the cut of this file after the session-end prune.

## Artifact shape

There is no convention file for `CURRENT.md`. Four blocks, each with its own judgment:

- **What happened.** One paragraph, past tense. Load-bearing changes only — the shape that shifted, the surface that landed, the call that got made. A disproven approach the next session would otherwise retry counts; one already recorded in a task's Notes does not. The test is whether the next session needs the line to act, not whether the work was interesting to do. If every file touched in the session makes it into this paragraph, the paragraph is doing the wrong job.
- **Current state.** In-progress, blocked, and queued, as three short lists keyed to task ids with a one-line pointer each. The triage view, not prose. The task files carry the detail; duplicating it here taxes every rehydration for content that is already on disk and already current.
- **Open questions.** One line per question, with enough context that the reader can engage without opening another file. This is the cut of `scratch/questions.md` still open at session end.
- **Where to start.** One to three directive sentences naming the first action the next session should take. The most load-bearing lines in the file — a reader who only has time for one section should be able to pick up work from this one.

## Pruning `scratch/questions.md` at session end

`scratch/questions.md` is committed; the handoff step is where it stays honest. Remove entries that were resolved this session — the choice lives in the code, the task Notes, or a decision entry, not in a stale questions list. Add entries for questions surfaced mid-session that are still live going forward, with enough context that a fresh reader can engage them. When a question has grown into a standing choice the project will need to remember outside the code — a structural commitment, an architectural boundary — surface it upstream for a decision entry rather than letting it thicken into a multi-line entry in `questions.md`. A question that cannot be answered yet stays open; one that has been answered but never committed to disk is a decision in hiding.

## Sizing as feedback

Keep `CURRENT.md` under ~1k tokens. The cap is not aesthetic — rehydration reads this file every new session, and a bloated handoff taxes every one of them. When a draft runs long, two patterns dominate: session history in *What happened* that the next session does not need to act, and in-progress detail in *Current state* that belongs in the relevant task's Notes. Both recover by pushing content to the surface that owns it — Notes for per-task state, decisions for standing choices, the docs for architectural shifts — and leaving the handoff as the thin pointer across them.

An empty block is fine when there is nothing to report. Manufacturing entries to fill each block is the mirror image of burying state in narrative.

## Examples

- `examples/good-session-handoff.md` — a post-session `CURRENT.md` with the four blocks populated, a pruned open-questions list, and a directive *Where to start*. **Read this before your first handoff in a session.**
