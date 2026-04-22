---
name: writing-an-epic-file
description: Reference for writing one well-formed epic file — an outcome-framed goal, capability-level scope, and a single testable exit criterion.
disable-model-invocation: true
---

# Writing an epic file

An `EPIC.md` is the short, capability-level brief that holds a cluster of tasks together around one testable exit criterion. The job of this skill is to take one decomposed capability unit and render it into that file. The decomposition call — what belongs in this epic vs. a sibling, whether a candidate is epic-shaped — has already been made by the time this skill runs.

Two failure modes pull against each other: an epic that reads like a task list, where scope and exit criterion describe implementation steps rather than the capability they combine into; and an epic whose exit criterion is really a checklist wearing a single-sentence disguise, so the epic can never be honestly called done without hand-waving.

## Read first

- `.metis/conventions/epic-format.md` — the structural spec (section order, sizing target, exit-criterion discipline). Not restated here.
- `.metis/templates/epic.md` — the skeleton.

## Frontmatter quality

`goal` and `exit_criterion` carry the most load. `goal` names the outcome — what users or the system can do when the epic is done — in one sentence. `exit_criterion` names the single testable check that proves it. If `goal` reads as a theme ("billing") rather than a capability ("a team admin can view and update their billing"), the epic has no real anchor for scope decisions, and both scope and `exit_criterion` drift to fill the vacuum.

`depends_on` is where unneeded ordering accumulates. Record it only when this epic's exit criterion literally cannot pass until another epic's has — a hard block, not a preference for reading order. Soft ordering is better expressed in the sequence epics are picked up than as a frontmatter claim downstream tooling has to respect.

## Describe capabilities, not tasks

Across every section, stay at the capability grain. "Team members see task changes reflected after a reload" is a capability concern; "add a five-second polling interval to the task list view" is a task concern and belongs in a task file. If a scope bullet reads like a task title — imperative verb, specific file or endpoint — the detail has leaked down and the epic has started doing work that the task files will duplicate and drift against.

## Writing each section well

The convention file has the shape. The judgment each section needs:

- **Goal.** One paragraph expanding the frontmatter goal. States why the epic exists and who benefits; does not preview the exit criterion. A Goal that ends by paraphrasing the exit criterion has nothing left to say.
- **Scope.** Capability-level bullets, not a task list. Three to six bullets is typical; a dozen is usually two capabilities masquerading as one, which is a decomposition call upstream of this file.
- **Out of scope.** Pre-empts the scope creep the in-scope list cannot cover on its own. "No SSO — deferred to 008-sso" is worth more than a sixth in-scope bullet restating what a reader would have assumed. Deferred capabilities carry a pointer to where they eventually live.
- **Exit criterion.** One paragraph, one check. The paragraph may expand the frontmatter criterion with the setup a reader needs to actually run it, but the check itself stays a single condition. If the expansion starts introducing more conditions, the epic wanted to split; stop writing and surface the split upstream.
- **Notes.** Empty at creation. Notes is the epic's append-only log — scope-shaping decisions, retro reminders, and epic-level questions caught during the epic's life land here. Pre-loading design context duplicates content that belongs in `decisions/` or in the individual task files.

## Exit-criterion judgment

The convention has the rule — one testable condition, observable behavior, runnable by a human in a short sitting. Two judgment calls show up in practice:

- A criterion that reads plausibly as one sentence but bundles two conditions with a hidden comma — "a user signs up, and the team admin sees them in the roster" — is two checks. Either pick the one the epic actually closes on, or recognize that the decomposition missed a seam and surface the split.
- A criterion that depends on a reviewer forming an opinion — "the billing flow feels coherent" — cannot be run. Rewrite to behavior a reviewer can see without judgment: "the admin, starting from the console, adds a card, returns to the dashboard, and sees the plan labeled as active."

## Sizing as feedback

If a draft lands past the `epic-format.md` sizing target, the overrun is usually task-shaped detail leaking up. Push the detail into the task files the epic will contain, and the epic recovers its shape. A draft that stays long after pruning is a decomposition signal — the candidate may be two capabilities — and is not a sizing problem to solve in this file.

## Flagging ambiguity in the source

If the corpus does not resolve a point the epic needs, do not guess. A small, local ambiguity — a specific word for a user-facing control, a minor boundary inside one capability — can be written through with a `TODO:` line in Notes. A larger ambiguity — whether the epic covers one tenant or many, whether a capability is in this epic or a sibling — is a decomposition call and belongs upstream. If you find one mid-draft, stop; it belongs in the decomposition pass, not inside this file.

## IDs and numbering

Epic IDs are a zero-padded three-digit prefix on the directory (e.g., `002-team-management`). Take the next unused project-wide epic id. Gaps are expected — an abandoned or superseded epic leaves its id retired — and are not filled by reuse.

## Examples

- `examples/good-epic.md` — a clean mid-sized epic: outcome-framed goal, capability-level scope, one testable exit criterion, Notes empty. **Read this before writing your first epic in a session.**
