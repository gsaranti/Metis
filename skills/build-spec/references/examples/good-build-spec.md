# BUILD.md — Billing webhook service

This document is the architecture brief for `billing-webhooks`, the internal service that receives Stripe webhooks and propagates state to the rest of the platform. It is a forward-looking commitment based on the reconciled corpus under `docs/`; it does not summarize the existing system. Where the corpus committed to a position, this brief restates it in the service's framing; where the corpus left a call open, this brief commits and names the assumption.

## Risk lead — at-most-once handler invocation under retries

The single architectural decision the rest of the build is most sensitive to is how this service guarantees that internal handlers see each Stripe event at-most-once, despite Stripe's retry behavior on 5xx responses. Stripe retries with exponential backoff for up to 3 days; a poorly-designed dedup layer will either let duplicate handler invocations through (double-billing being the worst-case observable) or block legitimate Stripe retries that we actually need to handle (resulting in a dropped event, the inverse failure).

The decision: **dedup keys on Stripe `event.id`, stored in a Postgres table with a unique index, with the dedup check inside the same transaction as the handler invocation log.** The transaction boundary is the load-bearing piece — a dedup-then-invoke flow split across two transactions admits a race where two parallel deliveries both pass the dedup check before either records the invocation. The single-transaction shape rules this out structurally; the cost is that the handler invocation log is in Postgres rather than wherever else we might store it.

The downstream architecture inherits this decision. Handlers run inside the dedup transaction (synchronous from the webhook's perspective); a handler that needs to do slow work enqueues to a job queue and the handler's "success" is the enqueue. The 30-second exit criterion in `002-billing/EPIC.md` budgets sync-handler time; async work is opaque to the SLA.

This call could turn out wrong if Postgres write throughput becomes the bottleneck under the burst patterns Stripe sends during incidents. The fallback is moving the dedup table to Redis with a per-key SETNX and accepting that we have a separate failure mode (Redis primary loss = handler invocation log loss); that's a v2 decision, not a v1 one.

## What the service does, end-to-end

A POST from Stripe to `/webhooks/stripe` flows through three stages, each with its own write boundary:

1. **Verify.** The `Stripe-Signature` header is checked against the configured signing secret with a 5-minute replay window per `docs/security.md §Webhook verification`. Failure returns 400 immediately, without parsing the body. Success advances to dedup.
2. **Dedup.** Inside one Postgres transaction, the service inserts into `webhook_invocations(event_id, ...)` with a unique constraint on `event_id`. A unique-violation means we've seen this event id; the transaction rolls back and the response returns 200 (Stripe needs success on duplicates to stop retrying). A clean insert means this is the first time we've seen the event; the transaction stays open through handler invocation.
3. **Fanout.** Per `docs/billing.md §Webhook fanout`, registered handlers for the event type run in parallel. Each handler returns success or a typed failure. The aggregate result is recorded in `webhook_invocations.handler_results` (per-handler, per `decisions/2026-04-30-dlq-per-handler.md`) and the transaction commits.

A handler failure does not roll back the transaction — the event was successfully verified, deduped, and routed; the handler-side failure is a downstream concern that the DLQ owns. The webhook response is 200 once the transaction commits.

## Data model

Three tables earn their keep in this service. `BUILD.md` commits to the columns; the migration files commit to the SQL.

**`webhook_invocations`** — the dedup ledger and the handler-results record. One row per accepted event. Columns: `event_id` (text, primary key), `event_type` (text), `received_at` (timestamptz), `payload_hash` (text, for replay-from-DLQ verification), `handler_results` (jsonb, structured per-handler success/failure entries). Unique index on `event_id` is what makes dedup work; everything else is observability.

**`subscriptions`** — the projection of Stripe subscription state into our schema, written by the `subscription_handler`. Columns track what the product needs to query: `stripe_subscription_id`, `customer_id`, `status`, `current_period_start`, `current_period_end`, `cancel_at`, `canceled_at`, `plan_id`. Updates are upserts keyed on `stripe_subscription_id`; the row's last-write-wins on the assumption that Stripe events arrive in order. Out-of-order arrivals are real but rare per Stripe's docs; the handler logs and accepts them, since the projection just needs to be eventually correct.

**`webhook_dlq`** — the dead-letter queue. One row per failed handler invocation, with `event_id` (foreign-key-ish to `webhook_invocations`; not enforced because we want DLQ rows to survive a `webhook_invocations` cleanup), `handler_name`, `failure_reason`, `failure_payload`, `retry_count`, `last_attempt_at`. The admin replay flow (`003-admin`) reads this table.

## Integrations

**Stripe.** Inbound only for v1. We don't call back to Stripe from the webhook service; the rest of the platform does that through a separate billing-api service that's already deployed. The webhook service knows nothing about Stripe API keys; only the signing secret.

**Postgres.** Same primary instance as the rest of the platform. The dedup transaction is the only thing we add; existing connection pooling and migration tooling apply.

**Job queue.** For handlers that need async work (sending emails, syncing to billing-api), we use the existing internal job queue (Redis-backed). The webhook service enqueues; consumers run elsewhere.

**Observability.** Standard OpenTelemetry traces around the three stages. DLQ depth is the load-bearing metric for ops; alerting fires at sustained depth > 10.

## The first vertical slice

The thinnest end-to-end pass through this service that runs and proves the architecture's load-bearing call:

**Slice:** A POST to `/webhooks/stripe` with a forged-but-valid signature for a `customer.subscription.deleted` event lands in `webhook_invocations` exactly once (verified by sending the same event twice and asserting one row), dispatches to a stub `subscription_handler` that returns success, and the response is 200. No other handler types; no DLQ; the `subscriptions` table is read but not yet written by the handler.

This slice exercises the risk lead — the at-most-once dedup transaction. Two deliveries of the same event id, one row in `webhook_invocations`, one stub-handler call: that's the test that proves the architecture's most load-bearing decision. If this slice doesn't hold, no other handler work is worth starting.

The slice is captured in tasks `0007` (signature verification), `0008` (idempotency layer), and a stub-handler task (`0009`'s scaffolding only — the real handler comes later). The verification command is `pytest tests/billing/test_first_slice.py` — a single test that posts twice and asserts the dedup property.

## Out of scope for v1

- **Test-mode vs. live-mode separation.** v1 supports one mode at a time, configured via the `STRIPE_WEBHOOK_SECRET` env var. The mode-aware routing is `004-stripe-modes`.
- **Multiple signing secrets / rotation.** v1 supports one secret. Rotation is `0019` under a later epic.
- **Admin replay UI.** The DLQ exists in v1; the UI to inspect and replay it is `003-admin`.
- **Email notifications on handler failure.** Ops will read DLQ depth from monitoring; user-facing notifications are deferred indefinitely.
- **Stripe object types beyond `customer.subscription.*` and `invoice.*`.** Other event types pass verification and dedup, route to a no-op handler that logs and acks. Adding handlers for new types is a future-epic concern.

## Open assumptions

- **Stripe sends most events in order.** The `subscriptions` projection is upsert-with-last-write-wins, which is correct only if out-of-order arrivals are rare. The Stripe docs claim they are; we have no signal that contradicts this. If an out-of-order event corrupts the projection in practice, the fix is a per-row version stamp from the Stripe `created` field, gating the upsert; but this brief commits to the simpler shape and accepts the assumption.
- **The handler set is known at deploy time.** Dynamic handler registration would require a different storage shape for `handler_results`. v1 wires handlers in code; if the operational pattern shifts to runtime registration, the data model needs revisiting.
- **30-second sync budget is honored by handlers.** The dedup transaction stays open through handler execution; a handler that takes 60 seconds blocks Stripe's connection. The convention is that handlers either finish fast or enqueue. Lint-style enforcement isn't in v1; the convention is documented in `docs/billing.md §Handler timing` and reviewed at task time.
