# Walked items

Two items followed through resolution — one contradiction, one question. Walking an item produces two new bits of on-disk state: an inline edit to the source doc in `docs/` so it no longer reads as open, and a pointer appended to `docs/RESOLVED.md`. The item itself is removed from `docs/CONTRADICTIONS.md` or `docs/QUESTIONS.md`.

This file shows the doc update and the `docs/RESOLVED.md` pointer for each example, and narrates the alternatives the walk offered — that narrative is context, not a persisted artifact. The items are the `C3` and `Q7` captures from `reconciling-docs/examples/good-open-items.md`, so the upstream framing and the downstream resolution read together.

---

## Contradiction (C3): webhook retry budget

**What the walk offered.**

`docs/billing.md §Webhooks` committed to a 72-hour retry window; `docs/ops.md §External integrations` committed to a 24-hour queue-drain ceiling. Two genuine alternatives:

- (A) Keep the 72-hour retry budget and carve webhook failures out of the shared 24-hour drain. Matches the billing commitment; costs a separate retention policy for webhooks.
- (B) Shorten the retry budget to 24 hours. Matches the ops ceiling; costs a weaker delivery guarantee for downstream integrations that expected 72-hour recovery.

Both are defensible from the cited passages. The user chose (B) on retention-alignment grounds.

**Doc update.** `docs/billing.md §Webhooks` was edited in the same walk to read:

> Failed webhooks retry with exponential backoff for up to 24 hours, aligned with the shared outbound-queue drain window. Beyond 24 hours the failure is archived; downstream integrations that need longer recovery must surface their own deferred-retry posture.

**Pointer appended to `docs/RESOLVED.md`:**

```markdown
## C3: Webhook retry budget
Resolved: 2026-04-19
Summary: 24-hour retry window, aligned with the ops queue-drain ceiling.
```

Why this shows genuine alternatives: each option costs something real and a careful reader could pick either. (A) preserves the stronger delivery guarantee at the price of non-uniform retention; (B) preserves retention uniformity at the price of a weaker guarantee. A user picking (B) is making a real trade, not rejecting a straw man.

---

## Question (Q7): behaviour on signature-verification failure

**What the walk offered.**

`docs/billing.md §Webhooks` required signature verification but did not specify the failure path. The walk found no doc-supported answer — neither `docs/billing.md` nor `docs/security.md` named a response code, a drop-and-log posture, or a retry rule for this case. Rather than invent options, the walk asked:

> The docs commit to verifying signatures but do not define the failure path. Candidate shapes are 400 (malformed request), 401 (auth failure), or silent drop with a log entry — the docs support none of them specifically. Which fits this service's error model?

The user chose 401 with a log entry, citing the broader API's treatment of authentication failures.

**Doc update.** `docs/billing.md §Webhooks` was extended with:

> Requests that fail signature verification return `401 Unauthorized` and are logged for review. Failed payloads are not queued for retry — a signature mismatch is usually an attacker or a misconfigured sender, and retry would not help either case.

**Pointer appended to `docs/RESOLVED.md`:**

```markdown
## Q7: Behaviour on signature-verification failure
Resolved: 2026-04-19
Summary: 401 with a log entry; no retry on verification failure.
```

Why this shows the ask-rather-than-fabricate move: the walk could have presented "400 vs 401 vs silent drop" as if they were equivalent alternatives, but the docs did not support any of them specifically. Surfacing candidates without a corpus anchor would be invention dressed as alternatives. The honest move was to name the gap, describe the shape of the question, and let the user's context about the broader API break the tie.
