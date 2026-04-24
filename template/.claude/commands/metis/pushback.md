---
description: Ask the agent to defend its most recent choice, forcing it to articulate the reasoning or concede the choice is under-justified.
---

# /metis:pushback

Make the agent defend its most recent substantive choice. Used when the user suspects the agent took a call too quickly or without naming the alternatives. The output is a defense — or a concession that the choice is under-justified and wants to be revisited.

## What counts as "most recent choice"

The last non-trivial call the agent made in the session:

- An architectural move in a plan (the planner chose an approach).
- A scope call in an implementation (the implementer decided a criterion was met, or reduced scope a specific way).
- A verdict in a review.
- A resolution or deferral of an open item.
- A decomposition call (this belongs in one epic vs. two).
- A draft phrasing in a build spec, an epic, a task, a decision, or a retro.

Trivial choices — a variable name, a commit message, a line break — are not what this command is for. If no non-trivial choice has been made in the session, the command stops and says so.

## Preconditions

- Recent session activity. If the session just started and nothing substantive has landed, stop:

  ```
  /metis:pushback needs a recent choice to push back against.
  Nothing substantive has happened in this session yet — run the
  command that produced the choice first.
  ```

## Load

- The specific call being pushed back on. In practice the agent reaches this from the session's own memory, not a file read — the call is what the agent just did, not something on disk.
- The artifact the call lives in (a plan, a task, a review, a draft), opened at the specific place the choice was made. A pushback that argues about the call in the abstract is weaker than one that points at the line.
- The anchor the call should have been made against — the task file's acceptance criteria for an implementation choice, the epic's exit criterion for a decomposition call, the docs' cited passages for a plan choice.

## Do not load

- The full surrounding context the agent had when making the choice. Pushback is a check on the reasoning, not a re-read of every input.
- Unrelated session state. The command is scoped to one choice.

## Skills

This command does not invoke a skill. It is a register the command carries in its prompt — the agent is asked to defend its call explicitly — not a skill's worth of teaching.

## Write scope

**None.** This command is conversational. The agent either articulates the defense (and the choice stands) or concedes the defense is thin (and the user decides whether to re-open the choice via a follow-up command). No file is written from here.

## The defense register

The agent's response has three beats, in this order:

1. **State the call plainly.** Restate what was chosen in one sentence, without hedging. "I approved task 0007 despite the retry test failing." "I sequenced the migration before the endpoint because the endpoint depends on the column." If the restatement itself sounds thin, that is already a finding.
2. **Name the alternatives.** What else could have been chosen, and what tipped the call this way. A defense with no alternatives is not a defense — it is a preference. If no real alternatives existed, say so and name why.
3. **Surface the weakness.** Every real choice has one. What would change the call? What evidence would tip it the other way? A defense that claims no weakness is the kind of defense that rots the fastest.

If the agent cannot do all three without reaching past the artifact the choice lives in, concede — the choice was under-justified. A conceded pushback is a successful one; the user reopens the choice with a follow-up command.

## Return

- **The defense** in the three-beat shape above, or
- **A concession** naming which of the three beats the agent could not honestly render, plus a pointer at the command that would let the user re-open the choice.

This command silently accepts and ignores any trailing free-text prompt — pushback is a forcing function, and tuning it per-invocation blunts the function. A user who wants to push back on a specific angle should name the angle in a follow-up message.
