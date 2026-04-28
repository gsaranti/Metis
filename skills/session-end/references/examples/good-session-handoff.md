# Current session handoff

## What happened

Closed `0042` (refresh-token rotation) and merged. The implementation followed the plan; one nit in code review (rotation log line included the token prefix) was fixed inline. Mid-session `docs/security.md §Sessions` was edited to capture the regulated-customer shift (the framing that prompted today's superseding decision), and `decisions/2026-05-02-session-duration-shortened-to-seven-days.md` landed as a result. Picked up `0043` (env-var key source for the new 7-day refresh) and got as far as the test stub before stopping.

## Current state

**In progress:**

- `0043` · env-var key source for refresh tokens — stub for `tests/auth/test_refresh_key_source.py` written; implementation not started.

**Blocked:**

- `0044` · cookie attribute matrix — depends on resolving the SameSite question still in `questions.md`.

**Queued:**

- `0044` · cookie attribute matrix — see Blocked.
- `0045` · revoke-all on password change — ready to plan once 0043 lands.

## Open questions

- SameSite=Lax vs. SameSite=Strict for the refresh cookie? The original session-duration decision left this open. `docs/security.md §Cookies` describes both; the regulated-customer set probably wants Strict, but Strict breaks the magic-link signin flow we ship for non-regulated tenants. Needs a call before `0044` can be planned.

## Where to start

Pick up `0043` — wire the key source to the env-var reader already in `config/env.py` and drop the hard-coded placeholder. The test stub at `tests/auth/test_refresh_key_source.py` lists the four cases to cover. If the SameSite question is still open by the time `0044` is up for planning, surface it for a decision entry; it shapes both `0044` and the magic-link flow.
