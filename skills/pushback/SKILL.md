---
name: pushback
description: Ask the agent to defend its most recent choice, forcing it to articulate the reasoning or concede the choice is under-justified.
disable-model-invocation: true
---

# /metis:pushback

Force the agent to defend its most recent substantive choice — or concede it is under-justified.

## Preconditions

- A substantive choice must have been made in this session. If none has, stop and report:

  ```
  /metis:pushback needs a recent substantive choice. Nothing
  substantive has happened in this session yet — run a planning,
  implementation, or review command first.
  ```

## What counts as a substantive choice

- An architectural move in a plan.
- A scope call in an implementation (a criterion judged met, scope reduced a specific way).
- A verdict in a review.
- A resolution or deferral of an open item.
- A decomposition call.
- A draft phrasing in a build spec, an epic, a task, a decision, or a retro.

## Load

- The specific call being pushed back on, from the session's own memory.
- The artifact the call lives in (plan, task, review, draft), opened at the place the choice was made.
- The anchor the call should have been made against — the task's acceptance criteria for an implementation choice, the epic's exit criterion for a decomposition call, the docs' cited passages for a plan choice.

## Do not load

- The full surrounding context the agent had when making the choice.
- Unrelated session state.

## Write scope

**None.**

## The defense register

Three beats:

1. **State the call plainly.** Restate what was chosen in one sentence, without hedging.
2. **Name the alternatives.** What else could have been chosen, and what tipped the call this way.
3. **Surface the weakness.** What would change the call? What evidence would tip it the other way?

If the agent cannot do all three from the artifact alone, concede — name which beat could not be rendered.

## Invocation prompt

Silently accept and ignore any trailing free-text prompt.

## Return

- **The defense** in the three-beat shape above, or
- **A concession** naming which beat the agent could not honestly render, plus a pointer at the command that produced the choice so the user can re-open it.
