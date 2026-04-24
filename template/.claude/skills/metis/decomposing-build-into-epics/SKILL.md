---
name: decomposing-build-into-epics
description: Reference for cutting a build spec into the right number of capability-sized epics — exit-criterion test, capability-not-category framing, split and merge signals, and flagging product-shape ambiguity upstream.
disable-model-invocation: true
---

# Decomposing a build into epics

An epic is one capability held together by a single testable exit criterion. The job of this skill is to take a body of work — a `BUILD.md`, or an existing flat `tasks/` backlog being promoted — and decide how many epics it wants to be, which capability goes into each, and whether any candidate is not epic-shaped at all. The output is the list of capability units that will be handed to the file-writing step, not files themselves.

Two failure modes pull against each other: cutting too fine, so an epic's exit criterion is tiny and the directory-per-epic overhead outweighs the grouping benefit; and cutting too coarse, so one epic bundles two capabilities and the exit criterion has to say "and" to cover them — at which point the epic cannot be called done without hand-waving.

## Read first

- `.metis/conventions/epic-format.md` — what "epic-shaped" means structurally: a single testable exit criterion, capability-level scope, ~300–600 word target per file. The exit-criterion rule is the constraint decomposition has to respect.

## Capability, not category

Cut along observable capabilities, not along technical layers or product domains. "A user can sign up and log in" is a capability; "auth" is a category, and a category can hide two or three capabilities inside it — signup, login, password reset, MFA — that each want their own exit criterion. Category-named epics tend to fail the exit-criterion test the moment anyone tries to write it: "auth is complete" is not a check a human can run, because the name was chosen for the concept's boundary, not for what the system does when the epic is done.

The test: can the candidate be stated as one sentence a human could run in a short sitting that proves it works? If the honest answer needs a list of checks, the candidate is not one epic.

## Where the seams are

When unsure where to slice, look for seams the product exposes: a user-visible capability that can be demo'd on its own, an integration boundary whose internals are self-contained, a lifecycle for one entity that begins and ends inside the candidate. Cuts along these seams tend to produce epics whose exit criteria write themselves and whose task sets have naturally disjoint surfaces. Cuts along technical-layer seams — an "API epic," a "database epic" — produce candidates that cannot be demo'd without another epic, which is the tell that a category, not a capability, was doing the cutting.

## Is this epic-shaped?

Before adding a candidate, check that it belongs in an epic at all. The capability-and-exit-criterion test does most of the work, but four failure modes slip past it:

- **Epic vs. task cluster.** A candidate whose parts are sequential implementation steps for one narrow behavior — add the table, write the migration, wire the endpoint, tests — is one task or a small task set, not an epic. Epics cluster tasks serving a capability; they are not implementation checklists stretched upward.
- **Epic vs. foundation.** An epic that exists only to prepare for later epics ("Core Infrastructure," "Shared Platform") becomes a sinkhole with no observable exit. Move the enabling work into the downstream epics that actually need it; a genuinely shared piece can live as a task inside the first epic that uses it.
- **Epic vs. release window.** Names like "MVP" or "Polish" are time-ordering, not capabilities. A release-window label hides whatever capabilities actually live inside it; decompose those instead.
- **Epic vs. decision or spike.** Work whose outcome is "we have decided X" or "we have learned whether Y is feasible" is not a capability. A decision belongs in `decisions/`, a spike in `scratch/exploration/` — neither is epic-shaped.

## Splitting signals

Signals a candidate wants to split:

- The candidate's exit criterion needs "and" more than once to cover the scope — each clause is a separate testable condition and wants its own epic.
- Two disjoint task clusters with no shared surfaces, where each cluster would ship and be useful without the other.
- The candidate spans multiple user-facing capabilities that would be announced to a user separately, even though they share an underlying subsystem.

A candidate whose exit criterion has to say "signup works AND login works AND password reset works" has three epics asking to come out.

## Merging signals

Signals two candidates want to merge:

- They share the same exit condition — the same demo-able behavior would close both.
- One is a prerequisite state of the other with no standalone value a user or operator would notice. Internal scaffolding that exists only so a sibling can ship is not its own epic.
- Both would be built, tested, and shipped in the same sitting anyway, with no reviewable intermediate state.

Epic-level merges are rarer than task-level merges because epics are already the large grain. When two feel close to merging, check whether the relationship is actually dependency rather than duplication — `depends_on` in the eventual frontmatter expresses ordering between epics that should stay separate and does not require that they collapse into one.

## Dependencies between epics

Epic dependencies are sparser and coarser than task dependencies. Most capability ordering is real but soft — a second epic reads more naturally after a first but could technically start earlier against stubs. Encode only the hard blocks: an epic whose exit criterion literally cannot pass until another epic's exit criterion has. Soft ordering is better expressed in the sequence the epics are picked up rather than as frontmatter claims later tooling has to respect.

An epic dependency is also a hint to re-examine decomposition: when several epics all `depends_on` one of them, some of that upstream's scope may have belonged in the downstream siblings in the first place. A hub with many dependents usually has a piece that wanted to move.

## Flagging structural ambiguity

Epic decomposition routinely surfaces product-shape calls the build spec did not commit to: which platform the first release targets, whether a capability's v1 covers one tenant or many, whether a feature lives in this product or a sibling. These are upstream of this skill. Encoding a guess across several epics produces a decomposition whose seams all shift at once when the call is made; the rework is the whole batch, not one file.

Stop and surface the ambiguity. A product-shape call is resolved by an amendment to the build spec, a decision entry, or a direct conversation — not by the decomposition quietly taking a side. Local ambiguity that only affects one candidate (a specific boundary inside one capability) is a different animal and belongs as a flag on that candidate for the file-writing step to carry.

## Batch shape

A decomposition is the set of epics that come out together. Three batch-level checks before handing off:

- **Coverage.** Every capability the build spec commits to belongs to exactly one epic, is explicitly deferred (noted as out of scope with a one-line reason), or is resolved as not epic-shaped above. Silent gaps — a capability the build spec named that no epic owns — are the common "missing feature" found months later.
- **Rough count.** A typical build lands around eight to fifteen epics. Far fewer usually means capability-bundling; far more usually means layer-slicing or task-level units escaping into the epic layer. The number is a diagnostic, not a quota; a genuinely small build can honestly have four, a genuinely large one can honestly have twenty.
- **Coherence.** Read the epic names as a list. If two sit next to each other and are hard to tell apart, or if one's name is a subset of the other's, re-check the merge signals above before handing off.

## Examples

- `examples/good-epic-decomposition.md` — a `BUILD.md` fragment and the resulting list of epic-sized units, with one-line rationale per cut and per merge. **Read this before your first epic decomposition in a session.**
