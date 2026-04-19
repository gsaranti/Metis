# Task file format

A task file is a self-sufficient brief for one unit of implementation work. A subagent loading a task file — plus `CLAUDE.md` and the docs the task references — must have everything it needs to plan, implement, or review without reading any other task file.

If a subagent needs context beyond the task file to do its job, the task file is underspecified. Fix the task file; don't widen the context.

## Filename

`NNNN-kebab-case-slug.md`, where `NNNN` is the zero-padded id (see `frontmatter-schema.md`) and the slug is derived from the title.

- Flat mode: `tasks/0007-stripe-webhook-handler.md`
- Epic mode: `epics/002-billing/tasks/0007-stripe-webhook-handler.md`

## Frontmatter

Per `frontmatter-schema.md`. The frontmatter block is always first in the file.

## Section order

The body has exactly these sections, in this order:

1. **Goal** — one or two sentences. What this task achieves, in outcome terms. Not "implement X" but "users can do Y" or "the system enforces Z."
2. **Context** — excerpted source-doc content (see Excerpting, below). The task writer's job is to pull the relevant passages from `docs_refs` into the task file itself.
3. **Scope boundaries** — two subsections, `### In scope` and `### Out of scope`, each a bullet list. Be specific. "Auth" is not a scope boundary; "signup endpoint for email/password; no SSO, no password reset" is.
4. **Acceptance criteria** — testable conditions as a bullet list. Each criterion must be checkable pass/fail with evidence. If it is not, it is not a criterion; it is a wish.
5. **Expected file changes** — bullet list of files or directories the task is expected to create or modify, each with a brief intent ("add handler", "update schema"). Overlaps the `touches` frontmatter field but is more granular.
6. **Notes** — free-form append-only log. Starts empty. Implementer appends a return note on completion; reviewer appends findings. The format of appended entries is governed by subagent system prompts, not by this file.

No other top-level sections. If content does not fit one of these, it goes in Notes or belongs in a separate task.

## Sizing

Target: **50–150 lines** including frontmatter.

- Under 50 lines: the task is probably under-excerpted. Pull more context in.
- Over 150 lines: the task is probably two tasks. Split it.

The range is an indicator, not a hard rule. A 160-line task is fine if every line earns its place. A 40-line task is fine if the work really is that tightly scoped.

## Excerpting rule

**Quote, do not just link.** When a task references a doc section, paste the relevant passage into the Context section as a blockquote with a source attribution line.

Example:

```markdown
## Context

From `docs/billing.md#webhook-events`:

> Stripe sends webhooks for invoice events, subscription events,
> and charge events. Every webhook must be verified against the
> endpoint secret before being processed. Failed verification is
> a 400 response, not a 500.

From `docs/security.md#webhook-verification`:

> Use `stripe.Webhook.constructEvent` with the raw request body.
> Do not parse the body as JSON before verification — the signature
> is computed against the exact bytes received.
```

Why: subagents work in fresh context. If the task file only links to docs, the subagent must load the whole doc to see a single paragraph. Excerpting keeps the subagent's context tight and keeps the task file a stable record of what was intended, even if the source doc later changes.

When an excerpt would run beyond ~30 lines, summarize in the task's own words and retain one or two key quotes. Do not paste whole sections wholesale.

## Immutability

`id` and `title` are immutable once assigned (see `frontmatter-schema.md`). If the scope genuinely changes, supersede the task — do not rewrite its identity. All other fields change freely, subject to `write-rules.md`.
