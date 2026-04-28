# Auth session duration

Refresh tokens last 30 days, access tokens 15 minutes, refresh-on-use rotation.

## Date

2026-04-19

## Context

Authenticated sessions need a duration policy. The product gives users a choice between two implicit shapes that the docs name without committing to:

- **Long-lived refresh tokens, short-lived access tokens.** The user logs in once and stays logged in across browser restarts; the browser silently refreshes the access token from the refresh token until the refresh token expires.
- **Single session token, expires on close.** No refresh token. The session ends when the access token expires or the browser closes, whichever comes first.

The first is the standard pattern for SaaS products with daily-active users; the second is the pattern for higher-security products where sessions explicitly should not persist across closes (banking, healthcare). The user docs describe a daily-active SaaS use case but do not pin a session duration anywhere.

## Decision

Refresh tokens last 30 days; access tokens last 15 minutes. Refresh tokens are single-use — each refresh issues a new refresh token and invalidates the prior one (rotating refresh). Refresh tokens are stored as HTTP-only secure cookies.

## Consequences

- Users stay logged in across browser restarts, matching the daily-active expectation in the user docs.
- A leaked access token is exploitable for at most 15 minutes; a leaked refresh token is exploitable until next refresh, at which point the rotation invalidates it.
- The refresh-token table needs a row per active session; expect one row per active user. At 100k users this is ~10MB of storage.
- A refresh-token database outage takes the whole product down for new requests every 15 minutes. The fallback is a read replica and a one-line cache on the access-token check.
- "Log out everywhere" is implementable as a server-side revoke of all refresh tokens for a user; access tokens still work for up to 15 minutes after.
