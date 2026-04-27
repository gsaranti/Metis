---
id: "0007"
epic: 002-billing
title: Stripe webhook handler
status: pending
priority: 2
depends_on: ["0003"]
estimate: medium
touches:
  - src/billing/webhooks.ts
  - src/api/routes.ts
  - tests/billing/webhooks.test.ts
docs_refs:
  - docs/billing.md#webhook-events
  - docs/security.md#webhook-verification
doc_hashes:
  docs/billing.md: a3f1c9e2d4b6
  docs/security.md: 7b2e4481f0ac
spec_version: 3
---

## Goal

The billing system accepts Stripe webhook events for subscription
lifecycle changes, verifies them, and updates local subscription
state so downstream features see a consistent view.

## Context

From `docs/billing.md#webhook-events`:

> Stripe sends webhooks for invoice events, subscription events,
> and charge events. We handle subscription lifecycle events only
> in v1: `customer.subscription.created`,
> `customer.subscription.updated`, `customer.subscription.deleted`.
> Invoice and charge events are acknowledged but not processed.

From `docs/security.md#webhook-verification`:

> Use `stripe.Webhook.constructEvent` with the raw request body.
> Do not parse the body as JSON before verification — the signature
> is computed against the exact bytes received. Failed verification
> is a 400 response, not a 500, and must not leak event content to
> logs.

Idempotency is required: Stripe retries on any non-2xx response and
may redeliver the same event. Dedup on `event.id` persisted in the
`processed_webhook_events` table (added in 0003).

## Scope boundaries

### In scope

- POST `/webhooks/stripe` route.
- Signature verification against the configured endpoint secret.
- Dispatch of the three subscription lifecycle events to the
  `subscription_state` table.
- Dedup against `processed_webhook_events`.
- 200 acknowledgment for handled-but-unprocessed event types, so
  Stripe does not retry them.

### Out of scope

- Invoice or charge event handling — deferred to its own task under
  003-invoicing.
- Local retry of failed dispatches — Stripe's retry is relied upon.
- Admin UI for replaying webhooks — v2 concern.

## Acceptance criteria

- POST `/webhooks/stripe` with a valid Stripe-signed
  `customer.subscription.created` payload writes a row to
  `subscription_state` and returns 200.
- POST with a payload whose signature does not verify returns 400
  with an empty body; no row is written; the event body does not
  appear in logs.
- POST with an `event.id` already present in
  `processed_webhook_events` returns 200 without writing to
  `subscription_state`.
- POST with a handled event type writes the event id to
  `processed_webhook_events` in the same transaction as the
  subscription state change (or rolls both back together on
  failure).
- POST with an unhandled event type (e.g., `invoice.paid`) returns
  200 and writes nothing.

## Expected file changes

- `src/billing/webhooks.ts` — add handler with verification, dedup,
  and event dispatch.
- `src/api/routes.ts` — register the POST `/webhooks/stripe` route.
- `tests/billing/webhooks.test.ts` — add coverage for the five
  acceptance criteria.

## Notes

<\!-- Append-only. Starts empty. Implementer and reviewer append their returns here. -->
