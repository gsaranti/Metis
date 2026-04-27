# Plan: 0007-stripe-webhook-handler

Task: `epics/002-billing/tasks/0007-stripe-webhook-handler.md`

## Ordered steps

1. **Add `StripeWebhookVerifier` in `src/billing/webhooks.py`.** Thin wrapper over `stripe.Webhook.constructEvent` that accepts raw body bytes and the `Stripe-Signature` header, returns the parsed `Event` on success, raises `WebhookVerificationError` on signature mismatch, and raises `WebhookPayloadError` on malformed JSON after signature passes. Nothing in the codebase verifies today, so this is additive.

2. **Route `/webhooks/stripe` in `src/api/webhooks.py`.** Read the request body before any JSON parse (Starlette's `await request.body()`), pull `Stripe-Signature`, call the verifier, dispatch by `event.type`. Return 400 for `WebhookVerificationError`, 400 for `WebhookPayloadError`, 200 once dispatch completes, 500 only for unhandled server errors.

3. **Dispatch map for the three event groups named in `docs/billing.md#webhook-events`.** `invoice.*` → `handle_invoice_event(event)`, `customer.subscription.*` → `handle_subscription_event(event)`, `charge.*` → `handle_charge_event(event)`. Handlers live in `src/billing/handlers.py`, each takes `Event`, returns `None`, and is a stub logging `event.type` for this task — business logic is a later task per the epic's scope.

4. **Register the route in `src/api/app.py`.** New router included under `/webhooks`. Do not change the existing auth middleware — the webhook endpoint must not require a session cookie.

5. **Read `STRIPE_WEBHOOK_SECRET` from env in `src/config.py`.** Fail loudly on startup if missing in production; warn and use a placeholder in local dev, matching the existing pattern for `STRIPE_API_KEY`.

## Expected file changes

- `src/billing/webhooks.py` — new, step 1.
- `src/billing/handlers.py` — new, step 3.
- `src/api/webhooks.py` — new, step 2.
- `src/api/app.py` — edit, step 4.
- `src/config.py` — edit, step 5.
- `tests/billing/test_webhook.py` — new, per test approach below.

## Test approach

Step 1 is tests-first — `StripeWebhookVerifier` has a sharp contract (inputs: bytes + signature; outputs: event or specific error). Write `test_valid_signature_returns_event`, `test_invalid_signature_raises`, `test_malformed_body_after_verify_raises`. Use Stripe's `stripe.WebhookSignature.generate_header` helper against a fixed test secret.

Step 2 is tests-after — end-to-end behavior is easier to assert once the route is in place. `test_signature_failure_returns_400` and `test_valid_event_returns_200_and_dispatches`, using a test client with monkeypatched handlers.

Steps 3–5 change no behavior worth testing directly. Step 3's handlers are logging stubs; step 4 is wiring; step 5 reuses the existing config pattern and is covered by the test secret in step 1.

## Verification command

`pytest tests/billing/test_webhook.py -v`

Five tests: three from step 1, two from step 2. All five pass ⇒ the task's acceptance criteria are met end-to-end.

## Assumptions and flags

- **Assumption.** The existing `WebhookError` base class in `src/billing/errors.py` is the right parent for `WebhookVerificationError` and `WebhookPayloadError`. If its fields don't fit (e.g., it assumes a `charge_id`), fall back to a fresh `StripeWebhookError` base in step 1 and call out the divergence in the Notes return.

- **Flag (local).** The task file does not pin the status code for an *unhandled* `event.type` (e.g., Stripe ships a new event family we haven't mapped). Step 2 returns 200 and logs at WARN, which matches the task's "don't 500 on unknown webhooks" note in Context but isn't spelled out. Defer upward if the implementer finds `docs/billing.md` has since been updated on this point.
