# Example: cascading an idempotency-window change

One edit to `docs/billing.md §Idempotency` propagating through the 002-billing epic. The candidate set mixes every case the skill names: a non-edit after inspection, a cosmetic batch, a `pending` walked edit, an `in-progress` confirmed edit, and a `done` task that produces both a new task and a superseding decision. The decision file the cascade wrote is included at the end at full shape.

## The upstream change

`docs/billing.md §Idempotency` was edited by the user.

Before:

> The `processed_webhook_events` table retains entries indefinitely; dedup on `event.id` is permanent. A webhook redelivered months later is recognized and dropped.

After:

> The `processed_webhook_events` table retains entries for a rolling 48 hours. Entries older than 48 hours are garbage-collected by the nightly ops job. Webhook redeliveries older than the idempotency window are treated as first-delivery events.

This is substantive: the commitment shifted from permanent dedup to a bounded window, and a new component (nightly GC) is implied.

## Candidate set

Scan against `docs_refs` and `doc_hashes`:

| Task | Status | Classification |
|---|---|---|
| `0007` — Stripe webhook handler | `done` | non-edit after inspection |
| `0014` — integration test harness | `pending` | cosmetic (Context quote update) |
| `0019` — operator docs for webhooks | `pending` | cosmetic (Context quote update) |
| `0013` — webhook retry | `pending` | substantive — walked |
| `0012` — Stripe client wrapper | `in-progress` | substantive — confirmed |
| `0008` — subscription state machine | `done` | substantive — new task + superseding decision |

## Non-edit: `0007`

`0007`'s `docs_refs` include `docs/billing.md#webhook-events` and `docs/security.md#webhook-verification`, not `#idempotency`. The `doc_hashes` entry for `docs/billing.md` still mismatched because the file hash is whole-file, but the excerpted Context in `0007` quotes the webhook-events section, which did not move. No edit; baseline bumped on `doc_hashes` for `docs/billing.md` so the next rebaseline does not re-surface this task.

## Cosmetic batch: `0014`, `0019`

Both quote the idempotency passage in their Context blocks and both need the new wording. Nothing in either task's acceptance criteria turns on the indefinite-vs-48h distinction — `0014` asserts "duplicate `event.id` within the test window is a no-op," and `0019` describes the dedup mechanism at a level ("retries are deduplicated") that remains true.

Batched as a single proposal: both tasks quote `docs/billing.md §Idempotency` in Context only; the cascade offers to update both to the new wording in one edit, with acceptance criteria and file changes untouched. The user approved the batch; both Context quotes were replaced and `doc_hashes` bumped on both.

## Pending walk: `0013`

`0013` — webhook retry, `pending`. Its acceptance criteria include *"a webhook failing at delivery time is retried until either success or the retry budget is exhausted, after which the event is archived and the dedup entry remains."* The final clause ("the dedup entry remains") is a commitment the new policy contradicts — after 48h, the dedup entry is GC'd.

The walk proposed editing `0013`'s fourth acceptance criterion to *"a webhook failing at delivery time is retried until either success or the retry budget is exhausted, after which the event is archived; dedup entries are subject to the 48-hour window and are not guaranteed to outlast the retry budget,"* with the Context excerpt updated to the new passage and Expected file changes extended to cover the retry path's handling of post-window redeliveries. The user approved. The task is still `pending`, so the edit landed in place; `doc_hashes` bumped; `spec_version` unchanged (the `BUILD.md` sections this task references did not move).

## In-progress confirm: `0012`

`0012` — Stripe client wrapper, `in-progress`. An implementer is actively working against the current framing; the wrapper's dedup-check sits at the boundary where the policy change lands.

Because the task is `in-progress`, the cascade surfaced the proposed edit for confirmation rather than applying it: the wrapper's dedup-check contract would shift from "permanent dedup" to "48-hour bounded dedup; callers must handle post-window redelivery as first-delivery," which is a substantive reframe of the work in flight. The user chose to land the edit now and notify the implementer — the implementer had not yet committed the dedup path, and absorbing the change early was cheaper than a later rewrite. The task's Context and acceptance criteria were edited in place with a Notes entry recording the mid-flight reframe; `doc_hashes` bumped.

## Done: `0008` — new task plus superseding decision

`0008` — subscription state machine, `done`. The task's acceptance criteria include *"a redelivered webhook for a past subscription transition is a no-op"* — which the state machine achieves by relying on `processed_webhook_events` as permanent. Under the new 48h window, a redelivery older than 48h will be treated as first-delivery and re-apply the transition, which for idempotent transitions is fine but for cancellation-with-refund (per the retro's replan on `0008`) could double-refund.

This is both a retraction (the "rely on permanent dedup" assumption is no longer true) and new implementation work (the state machine needs its own post-window guard for non-idempotent transitions). Both resolutions apply:

- **Superseding decision** — records that the `0008` assumption no longer holds, so a later reader finding `0008` sees the superseder next to it.
- **New task `0020`** — *state-machine guard against post-window redeliveries*. Its Context references the decision; the new task's `depends_on` does not block anything further in the epic but is surfaced for triage.

`0008` itself is not edited — it is the archive of what was built against the prior policy. `doc_hashes` for `0008` is bumped to the post-change baseline so rebaseline does not re-surface it; the "reviewer looked and decided no in-place edit" outcome is what the baseline now reflects.

## The decision file

`decisions/2026-04-16-idempotency-window-48h.md`:

```markdown
# Idempotency window bounded to 48 hours

Webhook dedup is bounded to a 48-hour rolling window; redeliveries beyond the window are first-delivery events.

## Date

2026-04-16

## Context

`docs/billing.md §Idempotency` was edited to bound the dedup window at 48 hours, with nightly GC of `processed_webhook_events` rows older than that. The prior policy — permanent dedup — had been in place through the skeleton and the in-flight wrapper work in `0012`. The shift was surfaced by the user after an ops review flagged unbounded table growth; the change propagated across the 002-billing epic via a cascade over six candidate tasks.

## Decision

The idempotency window is 48 hours, enforced by the nightly ops job. The cascade landed: `0013` (webhook retry, `pending`) — acceptance criterion and Context updated in place; `0012` (Stripe client wrapper, `in-progress`) — Context and acceptance criteria updated mid-flight, implementer notified; `0014` and `0019` — Context quotes updated as a cosmetic batch. `0008` (subscription state machine, `done`) is not edited in place; this decision supersedes its permanent-dedup assumption, and new task `0020` carries the state-machine guard against post-window redeliveries. `0007` was inspected and confirmed non-edit; its baseline is bumped.

## Consequences

The nightly GC job is now on the epic's critical path and is scoped under `0020`. Non-idempotent state transitions (cancellation-with-refund, per `0008`'s retro entry) need an explicit guard that `0008` did not implement; without `0020` shipping before the next release, a 48h-old redelivery could double-apply a refund. The in-flight reframe of `0012` means the wrapper's contract changed under the implementer — tracked as a mid-flight note on the task. Future doc edits touching `#idempotency` should expect the same candidate set; the baseline bumps from this cascade make the next cascade cheaper to scan.

## Evidence

- `docs/billing.md §Idempotency` — the edited passage.
- `decisions/2026-04-12-webhook-dedup-granularity.md` — prior decision on dedup granularity (event-id vs. event-type); unchanged by this cascade.
```
