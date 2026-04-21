# Decision format

Decisions (ADRs) live in `decisions/` as an append-only log that spans epics and sessions. Each file records one decision at the moment it was made. Decisions are never edited in place; if a decision is revisited, write a new decision that supersedes it.

## Who writes decisions

Decisions are created by:

- **`/metis:walk-open-items`** — one decision per resolved item (contradiction or question) during doc reconciliation.
- **`/metis:sync`** — one decision per accepted cascading change when a source doc or `BUILD.md` edit propagates through epics and tasks.
- **`/metis:log-work`** — one decision when code written outside the workflow touches architecture-level concerns.
- **The main session** — when a change to `BUILD.md`, a doc, or an epic warrants a standing record, the user and main agent can write a decision directly.

The three task-level subagents (planner, implementer, reviewer) do not write decisions. Their observations land in the task's Notes section; if something warrants a decision, the parent session writes it.

## Filename

`YYYY-MM-DD-kebab-case-slug.md`.

Examples:

- `2026-04-18-auth-session-duration.md`
- `2026-04-19-db-postgres-over-sqlite.md`
- `2026-05-02-replace-auth-session-model.md`

The date is the date the decision was made (usually the date it was written). The slug is a short noun phrase — what the decision is *about*, not what the decision *is*. `auth-session-duration`, not `use-30-day-refresh-tokens`.

Multiple decisions on the same day disambiguate by slug; no numeric suffix is needed.

## Frontmatter

None. Decisions are pure prose.

## Section order

```markdown
# <Title>

One-line summary of the decision.

## Date

2026-04-18

## Context

Why this decision was needed. What was being chosen between.

## Decision

What was chosen, stated plainly.

## Consequences

What this enables, what this costs, what it rules out.

## Evidence

(Optional) Links to discussions, prototypes, benchmarks, or specific
passages in `docs/` that supported the decision.
```

### Per-section guidance

- **Title** — short, noun-phrase. Matches the slug conceptually (e.g., "Auth session duration").
- **One-line summary** — directly under the title. The decision in a single sentence, so a reader scanning `decisions/` can see the outcome without opening the file.
- **Date** — ISO `YYYY-MM-DD`. Redundant with the filename but makes the body self-contained.
- **Context** — one paragraph, occasionally two. The state of the world that made this decision necessary and the options considered. No recap of history the reader can get elsewhere.
- **Decision** — one paragraph. The chosen option stated plainly and imperatively. Not "we considered X and Y and chose Y" (that belongs in Context) — just "Refresh tokens last 30 days; access tokens last 15 minutes."
- **Consequences** — one paragraph, or a short bullet list when the consequences are genuinely list-shaped. What downstream work this implies, what it forecloses, what it makes easier.
- **Evidence** — optional. Pointers (paths, URLs, commit SHAs) to material that backed the decision. Quote sparingly; the value is in the pointer.

## Sizing

Target: **one paragraph per section**, occasionally two. The whole file is rarely more than ~400 words. If it runs long, the decision is probably two decisions; split.

## Superseding

Decisions are append-only. When a decision is overturned or revised, write a new decision whose Context names the superseded file explicitly:

```markdown
## Context

Supersedes `decisions/2026-04-18-auth-session-duration.md`. The 30-day
refresh token policy proved too long for our compliance posture. We
are tightening to 7 days.
```

Do not edit the old decision to add a back-pointer. To find superseders, grep `decisions/` for the old filename. This keeps the log strictly append-only.

Superseded decisions remain in `decisions/` as historical record; they are not deleted.
