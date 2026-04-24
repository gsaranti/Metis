# Epic format

An `EPIC.md` file defines one capability-level unit of work: a cluster of tasks held together by a single testable exit criterion. Epics are optional — a project either has an `epics/` directory with one or more `EPIC.md` files, or it keeps a flat `tasks/` directory at the project root. There is no target task count — the work dictates that.

## Filename and location

`epics/NNN-kebab-case-name/EPIC.md`, where `NNN` is a zero-padded 3-digit prefix. (Epic IDs have fewer digits than task IDs because there are far fewer epics.)

Example: `epics/001-authentication/EPIC.md`.

The epic directory also contains:

- `tasks/` — task files for this epic (see `task-format.md`)
- `retro.md` — written at epic close

## Frontmatter

```yaml
---
name: 001-authentication
goal: Users can sign up, log in, and stay logged in across sessions.
status: pending
exit_criterion: A new user can sign up with email/password, log in, log out, and a protected endpoint returns their identity.
depends_on: []
---
```

Fields:

- **`name`** — required. Matches the directory name. Stable by default: other artifacts (task frontmatter `epic:`, decisions, `depends_on`) reference it. Renames require a resync.
- **`goal`** — required. One sentence. Outcome-framed; states what users or the system can do when this epic is done.
- **`status`** — required. Enum: `pending`, `in-progress`, `done`. Simpler than task status; epics have no review gate in v0.1, and blockers live on the individual tasks.
- **`exit_criterion`** — required. One sentence. A single testable condition that marks the epic complete. See the Exit-criterion discipline section below.
- **`depends_on`** — optional. List of epic names (e.g., `[001-authentication]`) that must be `done` before this epic starts. Default `[]`.

## Section order

1. **Goal** — one paragraph expanding the frontmatter `goal`. Why this epic exists, who benefits, where it sits in the product.
2. **Scope** — bullet list of capabilities in scope. Capability-level, not task-level. "Email/password signup and login" not "write a POST /signup handler."
3. **Out of scope** — bullet list of things a reader might assume are in scope but aren't, with one-line reasons. Deferred work goes here with a pointer (e.g., "SSO — deferred to 007-sso").
4. **Exit criterion** — one paragraph expanding the frontmatter `exit_criterion`. A concrete check a human can run to see the epic is done. Not a checklist — a single test. If it wants a checklist, break the epic smaller.
5. **Notes** — append-only log. Decisions that shaped this epic's scope, reminders for the epic-retro, open questions at the epic level. Starts empty.

## Sizing

Target: **one page** — roughly 300–600 words including frontmatter. Epics describe; tasks detail. If an `EPIC.md` runs past ~800 words, content has leaked in that belongs in task files.

## Exit-criterion discipline

The exit criterion is the most important part of an epic. It should:

- Be **a single testable condition**, not a list. If the criterion needs to say "and" more than once, the epic probably wants to split.
- Be **checkable by a human in a short sitting** (minutes, not hours).
- Prefer **observable user or system behavior** over internal completeness ("a user can log in" over "the auth module is implemented").

Counter-examples:

- "Auth is complete." Not testable.
- "Signup, login, logout, password reset, MFA, and email verification all work." Six criteria masquerading as one. Split.
- "All 14 tasks in this epic are marked `done`." Tautological. The epic being done is the thing we are trying to test.

## Status transitions

`pending → in-progress` when work starts on the epic's first task. `in-progress → done` when the exit criterion passes. Transitions are free-form; no tooling enforces them. Retro is written after `done` and is not itself a gate.
