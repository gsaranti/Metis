# Plan for `0007` — Stripe webhook signature verification

## Sequence

1. **Add the verification function in isolation.** Write `verify_stripe_signature(request, secret) -> bool` in `src/billing/webhook.py`. The function reads `Stripe-Signature` from the request headers, parses the `t=...,v1=...` format, recomputes the HMAC-SHA256 over `<timestamp>.<body>` using the secret, compares in constant time, and rejects timestamps older than 5 minutes. No call sites yet.

   - **Files**: `src/billing/webhook.py` (add function only).
   - **Test approach**: tests-first, since the contract is sharp. Write `tests/billing/test_webhook_signature.py` with the four tests named in the task's acceptance criteria, against a stub `verify_stripe_signature` that returns `False`. They all fail. Then implement the function until they pass.

2. **Wire verification into the route handler.** In the `POST /webhooks/stripe` handler, call `verify_stripe_signature` as the first line. On `False`, return `400` with no body and log a warning with the request id. On `True`, fall through to existing `WebhookEvent.from_payload(...)`.

   - **Files**: `src/billing/webhook.py` (route handler).
   - **Test approach**: add one test that verifies `from_payload` is *not* called on a rejected request. Patch `from_payload` and assert the call count is zero on each of the three failure-mode tests.

3. **Surface the env-var read.** The signing secret comes from `STRIPE_WEBHOOK_SECRET`. Read it once at module load via the existing `config.env.get_required(...)` helper. If missing, the module fails to import — which is the right behavior: don't start the service without the secret configured.

   - **Files**: `src/billing/webhook.py` (top-of-module env read).
   - **Test approach**: no test. The failure mode is "service won't start," which is verified by the existing import-time integration test in `tests/conftest.py`.

## Verification command

`pytest tests/billing/test_webhook_signature.py -v`

Five tests pass: `test_valid_signature_passes`, `test_missing_signature_rejected`, `test_tampered_body_rejected`, `test_replay_window_enforced`, plus `test_from_payload_not_called_on_failure`.

## Assumptions and flags

- **Assumes** `config.env.get_required` raises on a missing key (existing behavior in `src/config/env.py`). If the helper has been changed to return `None`, the module-load failure mode breaks; check before merge.
