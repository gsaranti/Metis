---
name: 002-team-management
goal: A user can create a team, invite others by email, and manage membership.
status: pending
exit_criterion: A user creates a team, invites a second user by email, the invitee accepts and appears in the roster, and either member can remove the other.
depends_on: [001-account-management]
---

## Goal

Teams are the unit of collaboration in the product — every task
lives under one, and every action in the app happens from the
perspective of a team member. This epic introduces the team itself:
how one is formed, how members join, and how the roster is kept
current. It sits between account management, where individual
identities become real, and task management, where members act on
shared work.

## Scope

- Team creation by a signed-in user; the creator becomes the first
  member.
- Inviting another user by email address; the invite delivers a link
  the invitee follows after signing in.
- Accepting an invite, which adds the invitee to the team roster.
- Removing a member from the team, visible to the other members.
- Viewing the current team roster.

## Out of scope

- Multiple teams per user. The v1 shape is one team per user; a user
  who needs to belong to two creates a second account. A proper
  multi-team model is held for a later epic when the product commits
  to it.
- Role distinctions inside the team (admin vs. member). Every member
  has the same permissions here; admin-only capabilities are owned
  by 005-admin-console once the admin console ships.
- Team deletion. The first release does not offer a self-serve
  delete path — a team is abandoned by removing all members. A
  proper delete path is a later epic once its audit rules are
  settled.
- Transferring team ownership. Moot while there is no ownership
  distinction; will be revisited with role work.

## Exit criterion

Starting from a clean state with two accounts already created under
epic 001: the first user signs in, creates a team, and sends an
invite to the second user's email address. The second user receives
the invite, signs in, follows the link, and appears in the team
roster on a refresh. Either member can then remove the other from
the roster, and the removed user no longer sees the team on their
next sign-in. The whole sequence runs at a browser in one sitting,
no backend inspection required.

## Notes

<!-- Append-only. Starts empty. Scope-shaping decisions, retro reminders, and epic-level open questions land here. -->
