# Retro: `002-billing`

Closed 2026-05-08. The exit criterion held: a Stripe-side cancellation reaches our system within 30 seconds, no duplicates, no lost events under handler failure. Eleven tasks shipped; one was split mid-flight; one assumption against `BUILD.md` did not hold.

## Estimation accuracy

- `0007` · Stripe webhook signature verification — small, tracked as planned.
- `0008` · Webhook idempotency layer — medium, tracked as planned.
- `0009` · Event fanout to internal handlers — medium, undershot by one day. The internal handler registry took less than expected once the event-id dedup framing was settled.
- `0010` · Subscription event handler — medium, **overshot by ~50%**. The Stripe SDK's subscription object has more fields than the docs led the breakdown to expect; the mapping work to our internal `subscriptions` table was a sub-project on its own.
- `0011` · Subscription state sync — medium, tracked as planned.
- `0012` · Invoice event handler — small, tracked as planned.
- `0013` · Handler-failure retry policy — small, tracked as planned.
- `0014` · Dead-letter queue — medium, tracked as planned.
- `0015`, `0016`, `0017` — small handler tasks, tracked as planned.

The slip on `0010` is the only material miss. Pattern: when a task's surface depends on an external SDK's object shape, the breakdown should budget mapping work as a sibling task rather than fold it into the handler task.

## Replans

- `0010` was split mid-flight into `0010` (subscription handler — receive event, dispatch to mapper) and `0018` (subscription mapper — Stripe object → our schema). The split surfaced after two days of `0010` because the implementer kept blurring "respond to event" with "translate object." The signal that would have caught it at task-write time: the source doc `docs/billing.md §Subscription state sync` describes the mapping in a separate sub-section from the event-handling — reading both sub-sections at decomposition would have surfaced the seam. Future epics whose tasks depend on an external SDK's object shape should check whether the source doc is already shaped two-ways and split there.

## Assumption failures

- `BUILD.md §Webhook fanout` committed to "internal handlers run in parallel; aggregate failures are reported as a single DLQ entry per event." The implementation kept the parallelism but the DLQ shape ended up being one entry per failed handler, not one entry per event. Reason: when two of three handlers fail on the same event, the operator needs to see both reasons to debug, not a merged "two handlers failed" line. The `BUILD.md` framing was a guess at a clean shape that didn't match the operational need. `BUILD.md` was edited mid-epic to reflect the per-handler DLQ shape; `decisions/2026-04-30-dlq-per-handler.md` records the reasoning.

## Task-breakdown lessons

- **External-SDK mapping wants its own task** (per the `0010` replan above). Lesson generalizes beyond Stripe — any epic that integrates with a third-party SDK whose objects have non-trivial shape should budget a mapping task explicitly.
- **DLQ shape is operations-driven, not architecture-driven.** The `BUILD.md` framing reasoned about clean event-level entries; the operators reasoned about debug-readability per handler. For epics that have an "operations side," the breakdown should consult ops conventions before locking the framing.
