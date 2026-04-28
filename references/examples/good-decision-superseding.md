# 2026-05-02 Session duration shortened to seven days

## Context

Supersedes `2026-04-19-session-duration.md`, which set refresh tokens to 30 days. The original Context committed to a daily-active SaaS shape and chose the standard pattern; this superseder narrows that shape after a real signal.

The signal: an internal security review flagged that 30-day refresh tokens — even rotating ones — leave a stolen device with up to 30 days of access if the user does not notice and revoke. The product's customer base, since the original decision, has shifted to include users in regulated industries (healthcare, finance) for whom 30 days is materially too long. The choice is no longer between "long-lived for daily-active" and "session-only for higher-security" — it is between "long enough for daily-active" and "short enough for the regulated subset that now exists."

A 7-day refresh window covers the daily-active case (a user who logs in Monday is still logged in Friday; one re-login per week is the cost) without the 30-day exposure.

## Decision

Refresh tokens last 7 days; access tokens stay at 15 minutes. Rotation behavior unchanged.

## Consequences

- Daily-active users see a re-login prompt roughly once a week. Weekly-active users (~12% of the base) re-login every visit.
- A leaked refresh token is exploitable for at most 7 days, down from 30.
- Existing 30-day refresh tokens are honored until their natural expiry; new tokens issued after the deploy use 7 days. No forced logout.
- The "Log out everywhere" semantics are unchanged (server-side revoke); the typical case (lose your phone) just has a smaller worst-case exposure window.
- Renewal load on the refresh endpoint roughly quadruples (1/7 days vs. 1/30 days). Capacity planning shows this is well within the existing quota; no infra change required.

## Evidence

- `decisions/2026-04-19-session-duration.md` — the superseded decision.
- `docs/security.md §Sessions` — updated 2026-05-01 to describe the regulated-customer shift that prompted this revision.
- `scratch/plans/0044.md` — implementation plan for the rotation, including the no-forced-logout migration step.
