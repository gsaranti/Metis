# Example: decomposing a small team task-tracker

**Input.** A `BUILD.md` fragment naming what the first release ships:

> A web app where teams manage a shared task list.
>
> - Users sign up with email and password, log in, and can reset a forgotten password.
> - Users create a team, invite others by email, and remove members.
> - Team members create tasks, assign them to a member, and move them through workflow states (todo / doing / done).
> - When a task is assigned or moved to done, the assignee is notified — in the app and by email.
> - Every Monday morning each user gets a digest email summarizing their team's task activity for the past week.
> - The public API enforces rate limits (10/min anonymous, 120/min authenticated).
> - Team admins view and update their team's billing via an admin-only console.

**Decomposition.** Five epic-sized units, two initial candidates merged, one item absorbed as a task inside another epic, and one item surfaced as structural ambiguity rather than decomposed here.

1. **Users can sign up, log in, and recover their password.**
   Exit criterion: "a new user signs up, logs in from a clean browser, requests a password reset, follows the emailed link, and logs in with the new password."
   Renamed from "Auth" during the capability-not-category pass — "auth is complete" failed the exit-criterion test.

2. **Users can form a team, invite members, and manage membership.**
   Exit criterion: "a user creates a team, invites a second user by email, the second user accepts and appears in the roster, and either user can remove the other."
   `depends_on: [001-account-management]` — the invite path cannot complete without the invitee being able to sign in. Hard block, not soft ordering.

3. **Team members can create, assign, and move tasks through workflow states.**
   Exit criterion: "a team member creates a task, assigns it to another member, moves it through todo → doing → done, and both members see the current state after a reload."
   Initially paired with "search across tasks" as one "Tasks" epic; split because search ships after v1 and the CRUD capability stands on its own. Search is deferred from this batch, not hidden inside epic 3.

4. **Users receive in-app and email notifications for task events.**
   Exit criterion: "an assigned user sees a new in-app notification within five seconds of assignment, and an email arrives within one minute; marking a task done produces the same for the creator."
   Merged from two initial candidates ("in-app notifications" and "email notifications") — same exit condition, same event source. Two surfaces, one capability.

5. **Each user receives a weekly digest email summarizing their team's activity.**
   Exit criterion: "after a simulated week of activity, the Monday-morning run sends one email per user containing that week's task changes for their team."
   Considered for merge into epic 4; declined because the digest is schedule-driven rather than event-driven, with distinct failure modes (missed runs, timezone batching). Same surface as epic 4's email path, different capability.

**Absorbed (not its own epic).** Rate limiting. Its exit-criterion candidate ("over-limit requests receive 429 with `Retry-After`") is testable but sits at the wrong grain — one piece of middleware, not a capability shipped as a milestone. Lives as a task inside whichever epic first introduces a public API surface.

**Structural ambiguity surfaced (not decomposed here).** Admin billing. The build spec says admins view and update billing but does not commit to per-team vs. per-user, or whether an external provider is used. A per-team model with a payment provider is a different epic from a per-user model with local records; encoding a guess produces an epic whose exit criterion shifts the moment the call is made. Surfaced back for an amendment to the build spec or a decision entry, not decomposed here.

**Batch-level checks.**

- *Coverage.* Every capability the build spec commits to belongs to one epic, is absorbed into tasks inside an existing epic, or is held for an upstream call. Rate limiting absorbed; admin billing held.
- *Rough count.* Five epics, below the eight-to-fifteen diagnostic band. The build spec's scope is small; the number is honest rather than a signal to split further.
- *Coherence.* The names read as a progression — account, team, task, notifications, digest — each one an observable capability. No pair is a subset of the other, and no two would be hard to tell apart at a glance.
