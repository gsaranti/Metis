# Auth session duration

Refresh tokens last 30 days; access tokens last 15 minutes.

## Date

2026-04-18

## Context

The auth epic needs a session-duration policy before the refresh endpoint can be built. Two options were live: short-lived refresh tokens (7 days) with a stricter security posture at the cost of more frequent re-auth, and long-lived refresh tokens (30 days) matching the convenience expected by our consumer-product peers. The product brief prioritizes sign-in friction over theoretical session-theft risk for this launch; no compliance constraint currently forces a shorter window.

## Decision

Refresh tokens expire 30 days after issue; access tokens expire 15 minutes after issue. Both rotate on refresh. Sessions bind to a device fingerprint captured at sign-in.

## Consequences

The refresh endpoint has a clear TTL contract to implement against. Revocation on password change must invalidate all outstanding refresh tokens for the user — tracked as a new task under the auth epic. The 30-day window commits us to storing refresh tokens server-side (see `docs/auth.md §Token storage`); stateless refresh is ruled out without a superseding decision. Device-fingerprint binding adds a re-auth event when users change devices, which the onboarding flow must surface clearly.
