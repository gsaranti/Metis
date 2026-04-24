# Task file format

A task file is a self-sufficient brief for one unit of implementation work. A reader loading a task file — plus `CLAUDE.md`, the docs the task references, and the parent `EPIC.md` when the task lives under one — must have everything it needs to plan, implement, or review without reading any other task file.

If a reader needs context beyond that to do its job, the task file is underspecified. Fix the task file; don't widen the context.

## Filename

`NNNN-kebab-case-slug.md`, where `NNNN` is the zero-padded id (see `frontmatter-schema.md`) and the slug is derived from the title.

The task file sits in one of two places, depending on whether the project uses epics:

- Flat: `tasks/0007-stripe-webhook-handler.md`
- Under an epic: `epics/002-billing/tasks/0007-stripe-webhook-handler.md`

The two are not alternate configurations of a single project — a given project has one or the other. A project can graduate from the flat layout to the epic layout when the work grows to justify it.

## Frontmatter

Per `frontmatter-schema.md`. The frontmatter block is always first in the file.

## Section order

The body has exactly these sections, in this order:

1. **Goal** — one or two sentences. What this task achieves, in outcome terms. Not "implement X" but "users can do Y" or "the system enforces Z."
2. **Context** — excerpted source-doc content (see Excerpting, below). The task writer's job is to pull the relevant passages from `docs_refs` into the task file itself.
3. **Scope boundaries** — two subsections, `### In scope` and `### Out of scope`, each a bullet list. Be specific. "Auth" is not a scope boundary; "signup endpoint for email/password; no SSO, no password reset" is.
4. **Acceptance criteria** — testable conditions as a bullet list. Each criterion must be checkable pass/fail with evidence. If it is not, it is not a criterion; it is a wish.
5. **Expected file changes** — bullet list of files or directories the task is expected to create or modify, each with a brief intent ("add handler", "update schema"). Overlaps the `touches` frontmatter field but is more granular.
6. **Notes** — free-form append-only log. Starts empty. Implementer appends a return note on completion; reviewer appends findings. The format of appended entries is governed by the callers' prompts, not by this file.

No other top-level sections. If content does not fit one of these, it goes in Notes or belongs in a separate task.

## Sizing

Target: **~400–1200 words** including frontmatter.

- Under 400 words: the task is probably under-excerpted. Pull more context in.
- Over 1200 words: the task is probably two tasks. Split it.

The range is an indicator, not a hard rule. A 1400-word task is fine if every word earns its place. A 350-word task is fine if the work really is that tightly scoped.

Words are a token proxy: `wc -w × 1.3` for prose, higher for code- or schema-heavy content. When a task embeds a lot of code, bias toward the lower end of the range to leave token headroom.

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

Why: readers often work in fresh context. If the task file only links to docs, the reader must load the whole doc to see a single paragraph. Excerpting keeps the reader's context tight and keeps the task file a stable record of what was intended, even if the source doc later changes.

When an excerpt would run beyond ~250 words, summarize in the task's own words and retain one or two key quotes. Do not paste whole sections wholesale.

## Editing

Task files are stable by default, not immutable. The user may edit any field — including `id` and `title` — at any time. Keeping those two stable once a task is underway is strongly preferred because other artifacts refer to them, but if they do change, dependents will need reconciling after the fact rather than treating the change itself as an error.

If a task's scope genuinely changes mid-flight, superseding it with a new task (and pointing to the old one in Notes) is usually cleaner than heavy in-place rewriting — but this is a judgment call, not a rule.
