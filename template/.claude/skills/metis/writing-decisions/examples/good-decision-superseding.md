# Auth session shortened to seven days

Refresh tokens now expire 7 days after issue; device-fingerprint binding is dropped.

## Date

2026-05-02

## Context

Supersedes `decisions/2026-04-18-auth-session-duration.md`. The compliance review for enterprise customers — required before the Acme pilot — flagged the 30-day refresh window as out of policy for their vendor agreements; 7 days is their stated ceiling. Separately, device-fingerprint binding has been causing legitimate re-auth churn on iOS background refreshes since the beta opened, generating disproportionate support volume. Both issues pointed at the same decision; revisiting the prior policy together is cleaner than two follow-on decisions.

## Decision

Refresh tokens expire 7 days after issue. Access tokens remain at 15 minutes. Sessions no longer bind to a device fingerprint; binding is per-user only. All outstanding sessions issued under the prior policy are invalidated at rollout.

## Consequences

The Acme pilot is unblocked. Users on mobile will re-auth roughly weekly instead of monthly — acceptable tradeoff per product. Support volume from iOS fingerprint churn should drop; tracked via the fingerprint-churn dashboard referenced in Evidence. The session-invalidation migration needs its own task under the auth epic. The 7-day window keeps server-side storage necessary, so the storage commitment from the superseded decision carries forward unchanged.

## Evidence

- `docs/compliance/acme-vendor-review-2026-04-29.md` — the flagged finding.
- `decisions/2026-04-18-auth-session-duration.md` — the superseded policy.
- Support dashboard: *Auth re-authentication failures, iOS* (April 2026).
