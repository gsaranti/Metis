# CURRENT.md

_Last updated: 2026-04-22, end of session._

## What happened

Landed task 0042 (signup endpoint, happy path + missing-field 400s). The stub for 0043's session-cookie signing went in under `auth/sessions.py` — wired but the key source is hard-coded; real key rotation is still pending. Reviewer flagged one `Handled differently` on expiry (24h absolute vs. 24h sliding); the delta was deferred to 0051.

## Current state

**In-progress:**
- `0043` — session cookie signing: scaffolding merged, key rotation outstanding.

**Blocked:**
- `0044` — login endpoint, depends on `0043` landing the real key source.

**Queued:**
- `0045` — logout endpoint.
- `0046` — signup rate limiting.

## Open questions

- Should the session cookie carry `SameSite=Lax` or `SameSite=Strict`? `docs/security.md §Cookies` is silent; infra's preference unclear. Affects 0043 and 0044.
- Refresh-token rotation cadence — the docs commit to 30-day refresh but do not specify whether each use rotates or a fixed interval does. 0051 will need the answer.

## Where to start

1. Pick up `0043` — wire the key source to the env-var reader already in `config/env.py` and drop the hard-coded placeholder.
2. If the SameSite question is still open by the time `0044` is planned, surface it for a decision entry; it will shape both tasks.
