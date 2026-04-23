# Review: 0007-stripe-webhook-handler

Task: `epics/002-billing/tasks/0007-stripe-webhook-handler.md`
Diff reviewed: commit `a7b3c21` against `main`.

## Per-criterion findings

- **POST `/webhooks/stripe` with a valid signed `customer.subscription.created` payload writes a row to `subscription_state` and returns 200.** Pass. `tests/billing/webhooks.test.ts::test_subscription_created_writes_row` asserts the row and status.
- **POST with a payload whose signature does not verify returns 400, no row written, body absent from logs.** Pass. `test_signature_failure_returns_400` covers status and row absence; `test_signature_failure_does_not_log_body` asserts the logger's captured records do not include the event payload.
- **POST with an `event.id` already in `processed_webhook_events` returns 200 without writing.** Pass. `test_duplicate_event_id_is_noop` asserts row count unchanged.
- **POST with a handled event type writes the event id to `processed_webhook_events` in the same transaction as the subscription state change.** Pass. Dispatch wraps both writes in `db.transaction()` at `src/billing/webhooks.ts:74`; `test_failure_rolls_back_both` forces a state-write exception and asserts the event-id row is absent.
- **POST with an unhandled event type (e.g., `invoice.paid`) returns 200 and writes nothing.** Fail. The handler returns 200 correctly, but `test_unhandled_event_writes_nothing` asserts zero rows in `processed_webhook_events` and the diff writes one. The implementer's Notes return describes this as "acknowledging the dedup table on every event so retries are cheap" — a scope change from the criterion as written.

Verification: `npm test -- tests/billing/webhooks.test.ts`, 14 tests, 1 fail (`test_unhandled_event_writes_nothing`).

## Scope reduction

The dedup table now records acknowledged-but-unhandled events. The task's Acceptance criteria specify writing nothing for unhandled types; the diff writes the event id. The substance may be right — unbounded retries on unhandled events are otherwise a cost — but it is a criterion change, not an implementation detail. Surface upstream before merging.

## Code-quality notes

- `handleEvent` in `src/billing/webhooks.ts` dispatches via nested `if` chains on `event.type`. A `switch` or a dispatch map would read cleaner given the three event families and would have made the unhandled-type branch more obvious at diff-review time. Non-blocking once the criterion question is resolved.

## Verdict

reject-with-reasons. The fifth acceptance criterion fails as written, and the fix is either a task-file amendment upstream or a diff change that restores the "writes nothing" behavior. The dispatch-style nit is recorded for follow-up regardless.
