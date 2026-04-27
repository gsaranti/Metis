# Example: logging session rotation, password reset, and a drive-by refactor

One description naming two tasks plus an unplanned refactor, reconciled against a diff that evidences the first task cleanly, shows daylight on the second, confirms half a named split, and touches a module boundary that earns a decision. The example traces each of the cases the skill names: a done-verified update, a done-with-daylight proposal, a confirmed-then-planned split, a retroactive task, and the Context a log-triggered decision produces.

## The user's description

> Finished 0022 (session rotation — rotation + revocation + tests).
> Worked on 0024 (password-reset email) — I split it into 0024 (the
> plaintext path, finished) and 0027 (the HTML variant, still to do),
> the templating pulled in more than I expected. While I was in there
> I also refactored the event bus to use a dispatch map instead of the
> switch ladder — the switch was getting unreadable.

## The diff

`git diff main..HEAD` — summarized:

| Path | Shape |
|---|---|
| `src/auth/session.ts` | `rotateSession`, `revokeSession` added |
| `src/auth/middleware.ts` | rotate on every request; revoke on logout |
| `src/auth/session.test.ts` | 12 new tests covering rotation, revocation, race |
| `src/auth/reset/send-plaintext.ts` | new — renders plaintext template, calls mailer |
| `src/auth/reset/templates/plaintext.txt` | new |
| `src/auth/reset/send-plaintext.test.ts` | new — 4 tests |
| `src/auth/reset/templates/reset.html` | new (template only; no sender wired) |
| `src/events/dispatcher.ts` | new — dispatch-map registry |
| `src/events/index.ts` | old switch removed; imports dispatcher |
| `src/billing/webhook.ts` | switched from raw switch to `dispatcher.dispatch` |
| `src/auth/logout.ts` | same switch-to-dispatch swap |

Net shape: +480 / −260 across auth, events, and billing.

## `0022` — done, verified cleanly

`0022`'s acceptance criteria:

1. A successful request rotates the session id and returns the new id in a `Set-Cookie` header.
2. Logout revokes the session server-side so subsequent requests with the old id are rejected.
3. Concurrent rotations do not race — the second rotation reads the already-rotated id, not the pre-rotation one.

Each is evidenced: (1) `rotateSession` + the middleware call + a test asserting the `Set-Cookie` change; (2) `revokeSession` + the logout path + a test asserting rejection on the old id; (3) the race test in `session.test.ts`. No daylight.

Update: `status: done`. Notes appended:

```
2026-04-23 — logged external work.
User: "Finished 0022 (session rotation — rotation + revocation + tests)."
Diff: rotate/revoke in `src/auth/session.ts`, middleware wired in `src/auth/middleware.ts`, 12 tests; all three acceptance criteria evidenced.
```

## `0024` — done claim with daylight surfaced

`0024`'s acceptance criteria:

1. A password-reset request sends an email to the account's verified address.
2. The email contains a reset link with a time-limited token (1 hour).
3. Rate-limited: no more than 3 reset emails per account per hour.

The diff evidences (1) and (2): `send-plaintext.ts` renders the template, calls the mailer, and the link-construction code references the token module. Criterion (3) has no evidenced surface — no rate-limit module is imported in `send-plaintext.ts`, and the tests do not exercise the limit.

The proposal surfaced the three criteria with their states and the three honest moves: mark `done` with a Notes entry naming the rate-limit gap; leave `in-review` and open a follow-up task for the rate-limit work; or hold at `in-progress` until the limit lands. The user chose the middle option. `0024` moves to `in-review`; a new follow-up task `0029` is added for the rate-limit work; `0024`'s Notes records the gap so a later reader can trace why the follow-up exists.

Notes appended to `0024`:

```
2026-04-23 — logged external work.
User: "Worked on 0024 (password-reset email) — I split it into 0024 (the plaintext path, finished) and 0027 (the HTML variant, still to do), the templating pulled in more than I expected."
Diff: `src/auth/reset/send-plaintext.ts` + template + 4 tests. Acceptance criteria evidenced: (1) mailer call, (2) tokenized link. Gap: (3) rate limit has no evidenced surface; moved to 0029 as a follow-up. Status set to `in-review`.
```

## `0024` / `0027` — split confirmed on one half, planned on the other

The description split `0024` into the plaintext path (finished) and `0027` (the HTML variant, not done). The diff evidences the plaintext half — `send-plaintext.ts`, the plaintext template, four tests. The HTML half shows only `reset.html` added as a template file; no sender, no tests.

So `0027` is a plan rather than a fact. It is written at `status: pending`, with Context carrying the user's split rationale and Expected file changes anchoring on the existing template file plus the `send-html.ts` and tests the task will produce. Its `depends_on` lists `0024` — the shared mailer abstraction already landed there, and the HTML sender consumes it.

## `0028` — retroactive task for the event-bus refactor

The description names an event-bus refactor with no existing task. One new task, written at `done` because the diff evidences completion:

```
---
id: "0028"
title: Event bus dispatch-map refactor
status: done
estimate: small
touches:
  - src/events/
  - src/billing/webhook.ts
  - src/auth/logout.ts
---

## Goal

Event dispatch is structured as a registry lookup rather than a central switch ladder.

## Context

Logged after the fact.

> Refactored the event bus to use a dispatch map instead of the switch ladder — the switch was getting unreadable.

## Scope boundaries

### In scope

- Registry module and migration of existing call sites.

### Out of scope

- No changes outside `src/events/`, `src/billing/webhook.ts`, and `src/auth/logout.ts`. Call-site migrations only; no behavior change in dispatched handlers.

## Acceptance criteria

- The changes listed below are the intended changes.

## Expected file changes

- `src/events/dispatcher.ts` — new dispatch-map registry.
- `src/events/index.ts` — old switch removed; imports and re-exports the dispatcher.
- `src/billing/webhook.ts`, `src/auth/logout.ts` — call sites migrated to `dispatcher.dispatch`.

## Notes

2026-04-23 — logged retroactively. Diff range: `main..HEAD`. No daylight — every file the description named appears in the diff and every diff surface in `src/events/` is accounted for by the description.
```

Goal restates the user's framing; scope and acceptance criteria are not invented beyond what the description and diff jointly support; Expected file changes carries the diff's evidence so a later reader can reconstruct what was done without re-running the diff.

## The decision the refactor triggered

The event-bus change removed a cross-module contract (the old switch was the project's single enumeration of event types) and introduced a new component (the dispatcher registry). This fires the "new component introduced" and "cross-module contract changed" triggers, so the update proposal added a decision alongside `0028`.

`decisions/2026-04-23-event-bus-dispatch-map.md` — Context extract:

```markdown
## Context

The event bus changed from a central switch statement in `src/events/index.ts` to a dispatch-map registry in `src/events/dispatcher.ts`. Existing call sites (`src/billing/webhook.ts`, `src/auth/logout.ts`) migrated to `dispatcher.dispatch`. The change was made during external work on password-reset templating (`0024` / `0027`) and logged retroactively as `0028`. The prior switch was the project's single source for the event-type enumeration; moving to a registry shifts that enumeration to the registration calls made at module load, which the decision's Consequences section lands.
```

Decision and Consequences are authored per `.metis/conventions/decision-format.md`. What the log step contributes is the Context framing — the trigger, the surfaces touched, and the task ids that absorbed the work — so a later reader can find the refactor through the decision log without having to diff the original range by hand.
