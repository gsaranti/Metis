# Review of `0007` — Stripe webhook signature verification

**Verdict**: reject-with-reasons.

## Per-criterion results

- **`test_valid_signature_passes` — pass.** `tests/billing/test_webhook_signature.py:18` exercises a happy-path request with a freshly-signed body; the test passes against the implementation in `src/billing/webhook.py:42-71`.
- **`test_missing_signature_rejected` — pass.** `test_webhook_signature.py:34`, returns 400 as required.
- **`test_tampered_body_rejected` — pass.** `test_webhook_signature.py:48`, constant-time compare in `webhook.py:65` confirmed via `hmac.compare_digest`.
- **`test_replay_window_enforced` — fail.** The test in `test_webhook_signature.py:62` asserts a 6-minutes-old request returns 400; the implementation rejects only requests older than 5 minutes *plus the network jitter buffer* the implementer added (60 seconds — see `webhook.py:57`), so a 5-min-30-sec request still passes. The acceptance criterion was "older than 5 minutes is rejected"; the buffer makes the actual cutoff 6 minutes. The tampered-window test runs at 6:30 and passes, but a 5:30 request also passes, which the criterion does not allow.
- **`from_payload` not called on failure — pass.** `test_webhook_signature.py:82`, all three failure-mode tests patch `from_payload` and assert zero calls.

## Findings

**Reject reason 1 — replay window cutoff is wrong.** The implementer added a 60-second jitter buffer that effectively widens the replay window from 5 minutes to 6 minutes. The task acceptance criterion is unambiguous: "older than 5 minutes returns 400." Either the implementation drops the buffer, or the criterion changes via a /metis:sync — but the current state has the implementation deviating from the spec without surfacing the deviation in the implementer's return.

**Reject reason 2 — failure logging includes the signature header.** `webhook.py:54` logs `request.headers["Stripe-Signature"]` on rejection. The task's acceptance criteria did not name this, but the source doc `docs/security.md §Webhook verification` explicitly says signature values should never appear in logs (an attacker observing logs would learn whether their signature attempts are getting close). This is a spec compliance failure tied to the cited source doc, not a code-quality nit.

## Scope reductions surfaced

The implementer's return notes flag one reduction: "Did not implement env-var fallback for `STRIPE_WEBHOOK_SECRET`; if the env var is missing, the module fails to import per the original design." This matches the task's plan (step 3) — not a reduction, just a confirmation. No follow-up needed.

## Code quality (separate from spec compliance)

- **Nit, not blocking**: `verify_stripe_signature` mixes header parsing and HMAC computation in one function. Splitting parsing into `_parse_signature_header` would make the constant-time compare easier to test in isolation. Leave for follow-up; not in scope for this review.
- **Nit, not blocking**: the test for `test_tampered_body_rejected` only tests one tamper shape (a flipped byte in the middle). A property-test pass would catch edge cases the example test doesn't, but the criterion is met by the existing test.

The implementation needs the replay-window fix (drop the buffer) and the logging fix (don't log the signature) before re-review.
