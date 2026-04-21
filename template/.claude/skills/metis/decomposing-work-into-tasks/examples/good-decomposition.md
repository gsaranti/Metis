# Example: decomposing a rate-limiting feature

**Input.** A mid-stream feature request from the product spec:

> Add rate limiting to the public API. Anonymous requests get 10/minute per IP; authenticated requests get 120/minute per account. Responses include `X-RateLimit-Limit`, `X-RateLimit-Remaining`, and `X-RateLimit-Reset` headers. Over-limit requests return 429 with `Retry-After`. Limits are configurable via `config/rate-limits.yaml`. Admin users bypass the limit entirely.

**Decomposition.** Four task-shaped units, one checklist item absorbed into its parent, one item deferred and explicitly out of scope.

1. **Implement rate-limit middleware and config loader.**  
   Middleware, `config/rate-limits.yaml` loader, per-IP and per-account bucket logic, 429 + `Retry-After` on overage. Black-box acceptance criterion: "an unauthenticated client making 11 requests in a minute from the same IP gets a 429 on the 11th with `Retry-After` set."

2. **Emit rate-limit response headers on every response.**  
   `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset` on all responses the middleware passes through. Acceptance criterion is an assertion on response headers for both under- and at-limit requests. Split from task 1 because a header bug can exist while the 429 path is correct, and vice versa — the two criteria fail independently.

3. **Admin bypass.**  
   Requests authenticated as an admin are exempt from the limiter. Split from task 1 because the middleware can be shipped and validated before the admin role exists; this unit depends on the auth epic's admin-role work and carries `depends_on: [<admin-role-task-id>]`. Merging would either block task 1 or force a stub in task 1 that task 3 then has to clean up.

4. **Operator docs for the limits file.**  
   `docs/operations/rate-limits.md` explaining the config format, reload behavior, and how to check current limits. Split from task 1 because it lands after the feature is verified in staging — it documents observed behavior, not intended behavior. Merging would force doc-writing before the feature is validated, which produces docs that lie.

**Absorbed (not a separate task).** "Default rate-limit values in `config/rate-limits.yaml`." No independent acceptance criterion — the values exist only in service of task 1's middleware. Lives as a line in task 1's Expected file changes.

**Deferred (noted as out of scope).** Per-endpoint overrides (e.g., stricter limits on `/auth/login`). Not in the source spec; mentioned here so task 1's `### Out of scope` can name it with a one-line pointer rather than leaving the reader to guess.

**Structural ambiguity surfaced (not decomposed here).** The spec does not say where rate-limit bucket state lives — per-process memory (simpler, breaks as soon as the app runs on more than one instance) or a shared store like Redis (correct in a fleet, adds a dependency). Writing task 1 forces that choice, and it cascades into task 3's bypass path and anything else that has to read or invalidate bucket state. The decomposition step stops and files the question as an open item for `/metis:walk-open-items`, rather than picking a persistence strategy and encoding it into the task files; a guess here would produce a chain of task files that all get redone once the question is actually decided.

**Batch-level checks.**

- *Coverage.* Every piece of the input spec maps to exactly one unit, is absorbed, or is explicitly deferred. The "admin bypass" sentence maps to task 3; the response-header sentence to task 2; the 429 / `Retry-After` sentence to task 1; the config file to task 1's file changes; per-endpoint overrides are deferred with reason.
- *Independence.* Each unit could in principle ship without the others and still make sense — task 1 works as rate-limiting-without-headers-or-bypass; task 2 adds visibility; task 3 adds the admin exception; task 4 documents what exists. None of them collapses another into "there's nothing here without its sibling."
