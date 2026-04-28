---
id: "0007"
epic: 002-billing
title: Stripe webhook signature verification
status: pending
priority: 2
depends_on: ["0003"]
estimate: small
touches:
  - src/billing/webhook.py
  - tests/billing/test_webhook_signature.py
docs_refs:
  - docs/billing.md#webhook-events
  - docs/security.md#webhook-verification
doc_hashes:
  docs/billing.md: a3f1c9e2d4b6
  docs/security.md: 7b2e4481f0ac
spec_version: 3
---

# Stripe webhook signature verification

## Goal

A POST to `/webhooks/stripe` from Stripe's servers is verified against the configured signing secret before any business logic runs. Requests without a valid `Stripe-Signature` header are rejected with `400` and never reach downstream handlers.

## Context

> "Every webhook from Stripe carries a `Stripe-Signature` header that includes a timestamp and one or more signatures of the raw payload. We verify the signature using our endpoint's signing secret. Replay protection is implicit in the timestamp — a request older than 5 minutes is rejected even if the signature checks out."
>
> — `docs/security.md §Webhook verification`

> "The webhook endpoint MUST verify before parsing. Parsing first leaks the body shape to attackers and risks invoking handler code on a forged event."
>
> — `docs/billing.md §Webhook events`

The signing secret is read from `STRIPE_WEBHOOK_SECRET` (env var). The 5-minute replay window is the published Stripe recommendation; treat it as a hard bound, not a tunable.

## Scope boundaries

### In scope

- Signature verification on `POST /webhooks/stripe`.
- Timestamp-based replay rejection (>5 minutes old → 400).
- Returning `400` with no body on signature failure.
- Logging the failure (with the request id, never the signature) so ops can see the rate.

### Out of scope

- Idempotency. Deduplication of accepted events lives in `0008`; this task's only job is verify-or-reject.
- Multiple signing secrets (rotation). One secret for v1; rotation is `0019`.
- Test-mode vs. live-mode separation. The endpoint accepts whichever secret is configured; routing by mode is `0021`.
- Internal-handler fanout. Verified events are passed to the existing `WebhookEvent.from_payload` constructor; what happens after that is `0009`.

## Acceptance criteria

- `POST /webhooks/stripe` with a valid `Stripe-Signature` header (timestamped within 5 minutes, signed with the configured secret) returns `200`. Verified by `pytest tests/billing/test_webhook_signature.py::test_valid_signature_passes`.
- `POST /webhooks/stripe` with a missing `Stripe-Signature` header returns `400`. Verified by `pytest tests/billing/test_webhook_signature.py::test_missing_signature_rejected`.
- `POST /webhooks/stripe` with a tampered body (signature does not match) returns `400`. Verified by `pytest tests/billing/test_webhook_signature.py::test_tampered_body_rejected`.
- `POST /webhooks/stripe` with a timestamp older than 5 minutes returns `400` even if the signature is otherwise valid. Verified by `pytest tests/billing/test_webhook_signature.py::test_replay_window_enforced`.
- The endpoint never invokes `WebhookEvent.from_payload` on a request that fails verification. Verified by patching `from_payload` in the rejection tests and asserting it was not called.

## Expected file changes

- `src/billing/webhook.py` — add `verify_stripe_signature(request) -> bool` and call it as the first thing in the route handler. Existing handler shape stays; verification gates the call to `from_payload`.
- `tests/billing/test_webhook_signature.py` — new file. Four tests above.

## Notes

(empty)
