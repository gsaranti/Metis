# Command-prompts convention

The convention for how a Metis skill or subagent handles the optional trailing free-text prompt a user can type after a slash invocation. Skills and subagents that accept such a prompt reference this file; the four rules below are not restated at each caller.

## The prompt shape

A user can append free-text after the slash invocation:

```
/metis:plan-task 0007 "focus on retry semantics; the existing code uses
tenacity, follow that pattern"

/metis:reconcile "give special weight to docs/billing.md, it's the most recent"

/metis:sync "only propagate the auth doc changes, defer the billing ones"
```

## The four rules

1. **Augment, do not replace.** The prompt adds to the skill's authoritative input; it does not override it. If the prompt genuinely contradicts that input — a task file's acceptance criteria, a captured open item's citation, the docs being reconciled — flag the conflict and ask rather than silently choosing a side.

2. **Flag scope expansion.** If the prompt widens scope beyond what the skill would otherwise do, note the expansion in the return instead of quietly doing it.

3. **Acknowledge use explicitly.** The return states how the prompt was used, so the influence is traceable after the fact. Example: *"Per your note about tenacity, I followed the retry pattern in `billing/client.py` rather than adding a new dependency."*

4. **Resolve named skills.** The prompt may name additional skills — Metis's own, user-authored, or project-specific; local or global — for the agent to consult alongside the skills the caller already invokes. Resolve each reference the same way any skill reference is resolved, across whatever skill sources the runtime exposes. An invoked skill's influence is acknowledged in the return. If a name cannot be resolved, flag it rather than guessing. User-referenced skills augment — they do not override the skill's authoritative input, the built-in skill references, or the three rules above.

## Ephemerality

The prompt is ephemeral. It is never persisted to disk, never added to frontmatter, never copied into a task Notes section except as a natural part of the skill's return commentary.
