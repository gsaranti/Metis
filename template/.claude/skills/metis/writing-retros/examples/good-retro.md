# Retro — epic 002-billing

_Exit criterion passed: 2026-04-18. Retro written: 2026-04-19._

## Estimation accuracy

- `0007` — Stripe webhook handler: tracked as planned.
- `0008` — subscription state machine: undershot by ~40% (planned 1 day, took 2). Cancellation-with-refund transitions were not in the original task.
- `0009` — invoice list endpoint: tracked as planned.
- `0010` — invoice PDF generation: undershot by ~50%. The PDF library's font handling needed a separate spike.
- `0011` — payment-method update: tracked as planned.
- `0012` — Stripe client wrapper: undershot by ~25%. Idempotency-key plumbing was larger than the task named.
- `0013` — webhook retry: tracked as planned after replan (see Replans).
- `0014` — integration test harness: overshot (planned 2 days, took 1). The wrapper from `0012` made the harness cheaper than expected.

## Replans

- `0013` split into `0013` + `0017` when the retry path turned out to share a dedup table with the idempotency work in `0012`. Reading `docs/billing.md §Retries` alongside `§Idempotency` at decomposition would have caught the shared primitive.

## Assumption failures

- `BUILD.md` said "Stripe webhooks are deduplicated by event type." Dedup must happen at event-id granularity — the same event type recurs for different subscriptions within a window. The wrapper in `0012` carries the event-id check; `decisions/2026-04-12-webhook-dedup-granularity.md` records the shift.

## Task-breakdown lessons

- All three Stripe-integration tasks (`0007`, `0012`, `0014`) undershot because the task files treated "Stripe client is configured" as a precondition rather than part of the work. Next epic with a third-party integration should budget a first task for client plumbing explicitly.

## Scratch promotions

- `scratch/research/stripe-test-mode-matrix.md` — became load-bearing during `0014` and will be again for any future Stripe epic. Flag for `/metis:scratch-cleanup` to move before the directory is cleaned.
