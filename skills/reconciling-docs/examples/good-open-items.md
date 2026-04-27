# Good open items

Two fragments — one from `docs/CONTRADICTIONS.md`, one from `docs/QUESTIONS.md` — showing what a well-framed item looks like in each file. They live in separate files in the actual project; shown together here because the structural difference is the teaching point.

---

## `docs/CONTRADICTIONS.md` (fragment)

```markdown
## C3: Webhook retry budget
Status: open
Added: 2026-04-18

docs/billing.md §Webhooks: "Failed webhooks retry with exponential
backoff up to 72 hours."

docs/ops.md §External integrations: "All outbound failure queues are
drained every 24 hours; anything older is archived and not retried."

These specify the same retry surface differently: billing commits to a
72-hour window, ops commits to a 24-hour ceiling. A resolution has to
name which ceiling binds, or reshape the queue so both hold.
```

Why this works: both passages are quoted verbatim with their paths, so the later walk does not have to re-read the docs to see the disagreement. The framing sentence is neutral — it names the surface under dispute and the shape of the divergence, without proposing which side to take. The status header carries only what the walk needs.

---

## `docs/QUESTIONS.md` (fragment)

```markdown
## Q7: Behaviour on signature-verification failure
Status: open
Added: 2026-04-18

docs/billing.md §Webhooks: "Incoming webhooks are verified against the
signing secret before being processed."

The docs do not specify what happens when verification fails: whether
the request is rejected with a 400, a 401, silently dropped, or logged
for review. Downstream handlers assume a verified payload but no doc
defines the failure path.
```

Why this works: the quoted passage points at the topic so the walk knows where the question lives. The paragraph under the quote articulates what the docs *don't* say — the shape of the silence — rather than listing candidate answers. Alternatives belong in the walk, not the capture. The item is scoped to one gap; a second gap (e.g. retention of failed payloads) would be its own `Q` entry.
