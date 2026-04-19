# Frontmatter schema

Canonical YAML frontmatter for **task files**. Every task file begins with this block. Fields not listed here are not permitted.

Epic frontmatter is smaller and is specified in `epic-format.md`. Decisions have no frontmatter.

## Example

```yaml
---
id: "0007"
epic: 002-billing
title: Stripe webhook handler
status: pending
priority: 2
depends_on: ["0003", "0005"]
estimate: medium
touches:
  - src/billing/
  - src/api/webhooks.ts
docs_refs:
  - docs/billing.md#webhook-events
  - docs/security.md#webhook-verification
doc_hashes:
  docs/billing.md: a3f1c9e2d4b6
  docs/security.md: 7b2e4481f0ac
spec_version: 3
---
```

Note the quoted strings on `id` and `depends_on` values — leading-zero numbers are parsed as integers by most YAML loaders, losing the zero-padding. Always quote ID values in YAML.

## Fields

### `id` — required

Zero-padded 4-digit string. Unique within the project. The filename prefix matches (`0007-stripe-webhook-handler.md`).

Stable by default: other artifacts (frontmatter `depends_on`, decisions, `CURRENT.md`, etc.) reference this id, so changing it has cascading cost. If it must change, reconcile the dependents via `/metis:log-work` or a resync.

Valid: `"0007"`, `"0042"`, `"1234"`.
Invalid: `7`, `"00007"`, `"7"`.

### `epic` — required in epic mode; forbidden in flat mode

Directory name of the owning epic, without the `epics/` prefix and without a trailing slash. Must match the on-disk directory exactly.

Example: `002-billing`.

### `title` — required

One-line human-readable summary. Stable by default — other artifacts may refer to it, and renames ripple — but the user may change it. When scope has genuinely shifted, superseding the task with a new one is usually cleaner than retitling.

### `status` — required

Enum, exactly one of:

- `pending` — not started
- `in-progress` — being implemented
- `in-review` — implementer returned; reviewer not yet run or in flight
- `done` — reviewer approved, merged
- `blocked` — cannot proceed; the reason lives in the Notes section

Transitions are free-form. No tooling enforces the order.

### `priority` — optional

Integer, 1–5. **1 is highest.** Default: 3.

### `depends_on` — optional

List of task IDs as zero-padded strings. Absent or empty means no dependencies. `/metis:pick-task` filters out tasks whose dependencies are not `done`.

### `estimate` — optional

Enum: `small`, `medium`, or `large`. For triage only. No time unit is implied.

Rough intent: `small` fits a single sitting, `medium` a day, `large` a few days — and a `large` task should prompt "does this want to be split?"

### `touches` — optional

List of paths (files or directories) the task is expected to modify. Advisory — not enforced. Useful for spotting conflicts when picking concurrent tasks.

### `docs_refs` — recommended

List of source-doc references. Each entry is a path from the project root, optionally suffixed with `#section-anchor`. Task files must **excerpt** these sections (see `task-format.md`), not merely link them.

`/metis:rebaseline` and `/metis:sync` read this field to detect drift.

### `doc_hashes` — generated

Map of `docs_refs` path → first 12 characters of the SHA-256 of the referenced file's contents at the time the task was last reconciled with that doc.

Generated when the task is created. Updated by `/metis:sync` when the task absorbs a doc change. If a path in `docs_refs` is missing from `doc_hashes`, `/metis:rebaseline` computes the hash on next run.

Hashing the whole file (not just the section anchor) is intentional: simpler, and the common case is "the whole doc changed."

### `spec_version` — generated

Integer. The project's `BUILD.md` version that this task was last reconciled against. Stored project-wide in `.metis/config.yaml` and copied into each new task at creation. Bumped by `/metis:sync` when the `BUILD.md` sections referenced by a task change.

A task is flagged stale when the project `spec_version` is greater than the task's `spec_version` **and** the intervening `BUILD.md` delta touches sections this task references.

## Required vs optional

| Field | Required | Notes |
|---|---|---|
| `id` | yes | both modes |
| `title` | yes | both modes |
| `status` | yes | both modes |
| `epic` | yes in epic mode | forbidden in flat mode |
| `priority` | no | default 3 |
| `depends_on` | no | default `[]` |
| `estimate` | no | — |
| `touches` | no | — |
| `docs_refs` | recommended | absent is legal but rare |
| `doc_hashes` | generated | present iff `docs_refs` is |
| `spec_version` | generated | set at task creation |

## Validity rules

A frontmatter block is invalid if any of the following hold:

- An unknown field is present
- A required field is missing
- `status` or `estimate` is not in its enum
- `epic` is present in a flat-mode project
- `epic` is absent in an epic-mode project
- `id` does not match the filename prefix
- `doc_hashes` contains a key that is not in `docs_refs`
- `priority` is outside 1–5

Invalid frontmatter is a user-visible error, not a silent fix.

## Epic frontmatter

See `epic-format.md`.
