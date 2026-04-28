---
name: 002-billing
status: pending
priority: 1
depends_on: ["001-foundation"]
exit_criterion: "A user-initiated subscription change in Stripe is reflected in our system within 30 seconds of the webhook landing, with no duplicates and no lost events under handler failure."
docs_refs:
  - docs/billing.md
  - docs/security.md#webhook-verification
doc_hashes:
  docs/billing.md: a3f1c9e2d4b6
  docs/security.md: 7b2e4481f0ac
spec_version: 3
---

# Billing webhooks

## Goal

When a customer changes their subscription in Stripe — upgrades, downgrades, cancels, adds a seat — the change reaches our system reliably and within 30 seconds of Stripe sending the webhook. Reliable means: no event we acknowledge is later silently lost, and no event is processed twice in a way the user can observe (charged twice, billed twice, refunded twice). The 30-second budget covers verification, idempotency, fanout to internal handlers, and the synchronous handlers' own work.

## Scope

- Webhook ingress at `POST /webhooks/stripe`. Verifies the signature against the configured signing secret; rejects requests outside the 5-minute replay window.
- Idempotent acceptance. Repeated deliveries of the same Stripe event id (Stripe retries on 5xx) are accepted at-most-once for our internal handlers.
- Fanout to internal handlers. Each accepted event is dispatched to the registered handler set; handlers run in parallel and report success/failure.
- Failed-handler recovery. Handler failures route the event to a dead-letter queue with the failure reason and enough context to replay manually.
- Subscription state sync. The internal handler for `customer.subscription.*` events writes through to our `subscriptions` table.

## Out of scope

- The admin replay UI for the dead-letter queue — deferred to `003-admin`.
- Test-mode vs. live-mode separation — deferred to `004-stripe-modes`. v1 of this epic supports one mode at a time, configured via env var.
- Email notifications on handler failure — deferred indefinitely; ops will read DLQ depth from monitoring.
- Stripe object types beyond `customer.subscription.*` and `invoice.*` — deferred. Other event types are accepted, deduplicated, and routed to a no-op handler that logs and acks.

## Exit criterion

Starting from a customer with an active monthly subscription on Stripe: the customer cancels via Stripe's hosted portal; within 30 seconds, the cancellation is visible in our admin tooling (`subscriptions.status = canceled`, `subscriptions.canceled_at` populated). Stripe's retry behavior on a forced 5xx response leaves the same end state — no duplicate row, no lost cancellation. A handler-side failure (database unreachable) routes the event to the DLQ with enough context that the cancellation can be replayed once the database recovers.

## Notes

(empty)
