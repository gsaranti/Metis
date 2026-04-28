# Cascade: `docs/billing.md §Idempotency` was edited

The user ran `/metis:rebaseline` after editing `docs/billing.md §Idempotency` to commit to event-id-based deduplication (was previously underspecified — both event-id and event-type were possibilities). Drift scan surfaced 5 candidates; `/metis:sync` walked them.

## Candidate set

- **Doc drift, cosmetic batch (2):** tasks `0008` and `0014` reference `docs/billing.md §Idempotency` but their excerpts are unchanged in substance — the section's wording got tightened, not its commitment. Bulk-approved as cosmetic, baselines bumped.
- **Doc drift, substantive walk (1):** task `0009` (Event fanout) — the dedup signature it builds was based on event-type; the new commitment to event-id changes what "duplicate" means for fanout. Walked one at a time.
- **Doc drift, in-progress (1):** task `0011` (Subscription state sync) is `in-progress`. The rewrite affects how `0011` recognizes a duplicate subscription update. Confirmed with the user before editing.
- **Doc drift, done (1):** task `0007` (Stripe webhook signature verification) is `done` but `docs_refs` includes the changed section. The change does not invalidate `0007`'s implementation (signature verification is upstream of dedup). No new task; the cascade landed a baseline bump only after inspecting and confirming the verification logic still holds.

## What landed

### Cosmetic batch

`0008` and `0014` Notes appended with a one-line note: *"Doc cite for `docs/billing.md §Idempotency` updated 2026-04-15; passage tightened, no commitment change."* `doc_hashes` for both bumped.

### Substantive walk: `0009`

The cascade proposed an edit to `0009`'s Acceptance criteria — the existing line *"the same logical event delivered twice is processed once"* needed to commit to *"the same Stripe event id delivered twice is processed once"*. User approved the edit. `0009`'s body was updated, status stayed `pending`, baseline bumped.

### Substantive walk: `0011` (in-progress)

User confirmed before the edit. `0011`'s body got the same event-id framing in its Context excerpt; the implementer's WIP code was checked against the new framing and matched (the implementation already keyed on event id, the prior framing had just been imprecise). Notes appended with the cascade record. Baseline bumped.

### Done task: `0007`

No edit to the task body — `0007` is `done` and the cascade doesn't rewrite the historical record. Inspected the task against the new framing; the implementation does not turn on dedup keying (it's pure signature verification). Baseline bumped to acknowledge the inspection. No new task spawned; no superseding decision needed.

### Decision filed

One decision entry, naming the cosmetic batch and the four walked candidates as a single cascade against one upstream change.

## The decision file the cascade wrote

```markdown
# Idempotency keying on event id

Stripe-webhook idempotency keys on `event.id`, replacing the prior event-type framing.

## Date

2026-04-15

## Context

`docs/billing.md §Idempotency` was tightened to commit to event-id-based deduplication. The prior framing left both event-id and event-type as possibilities; the new framing pins event id. The cascade surfaced four downstream artifacts whose framings turned on the prior ambiguity.

## Decision

Idempotency for Stripe webhooks keys on `event.id`. Two deliveries of the same event id within the dedup window are accepted at-most-once for our internal handlers; two events of the same type with different ids are independent and both flow through.

## Consequences

- Tasks `0009` (`pending`) and `0011` (`in-progress`) carry edits to align excerpts with the new framing. Implementations were either not started (`0009`) or already aligned (`0011`).
- Task `0007` (`done`) is unaffected at the implementation level; baseline bumped after inspection to acknowledge the cascade walked it.
- Tasks `0008` and `0014` carry cosmetic-only edits (excerpt wording, not commitment).
- Future tasks under `002-billing` can rely on `event.id` as the dedup key without re-deriving from the doc.

## Evidence

- `docs/billing.md §Idempotency` — the edited passage.
- `decisions/2026-04-12-webhook-dedup-granularity.md` — prior decision on dedup granularity (event-id vs. event-type); unchanged by this cascade.
```
