# Logging external work

External work is code the user wrote outside the Metis loop — a hotfix, a spike, a refactor, a feature they drove by hand. The job of this skill is to reconcile that work with the on-disk record: updates to the task files the user names, optionally a new task for unplanned work, and optionally a decision when the diff shifts something structural. The reconciliation rests on one asymmetry — the user's description is the source of truth for **intent**, the `git diff` is the source of truth for **what happened**, and the job is to surface the daylight between them rather than quietly pick a side.

Two failure modes pull against each other. Trusting the description and skipping the diff lets "done" claims past that the code does not actually evidence — criteria unmet, scope leaked into an adjacent task, tests missing — and the on-disk ledger starts lying. Trusting the diff and skipping the description invents intent — unrelated file changes pinned to whichever task sounds nearest, and the task history poisoned with work the user never meant to log there.

## Read first

- The user's description, verbatim. It is the intent record and is not paraphrased before it informs the updates.
- The `git diff` for the relevant range. The record of what changed in code; everything else is claim.

Load `.metis/conventions/task-format.md` on demand when shaping a Notes append or a retroactive task, `.metis/conventions/frontmatter-schema.md` on demand for `status` transitions, and `.metis/conventions/decision-format.md` on demand only when the diff triggers a decision.

## Reading the description and the diff

The diff gives files changed, surfaces touched, net line direction, and — read against a task's `touches` and `docs_refs` — a rough attribution hint. Renames and deletions register distinctly from line churn and should be named in the description or surfaced as daylight. It does not give why the change was made or which task the user meant it to close. The description gives the attribution and the claim frame ("0022 is done," "I split 0024 into two," "I also refactored the event bus while I was in there"). It does not give whether the code supports the claim.

Daylight is the set of mismatches: a file in the diff that no named task touches; a "done" claim against a task whose acceptance criteria the diff does not evidence; a split the description names but only one half of which is present in the diff; a surface the description did not mention but that the diff clearly expanded. Daylight is listed explicitly in the proposal back to the user, not smoothed into a synthesized summary. Papering over it is the shape of the first failure mode. Two shape-extremes register as daylight too: unrelated clusters in the diff the description does not name — propose splitting the log into separate reconciliations rather than forcing the extras under the nearest task — and a claim against a diff silent on the named surfaces, which is daylight at its strongest.

## Per-task updates by claim

Each task the description names carries one of three claim types, and the update shape follows the claim:

- **Done claim.** Verify against the diff (see below). If the diff evidences the criteria, move `status` to `done` and append a Notes entry combining the user's description with a short diff summary. If the diff shows a gap, surface it rather than quietly marking `done`.
- **Progress claim.** The user worked on the task but is not claiming completion. Append a Notes entry summarizing the description and the diff's shape; set `status` to `in-progress` if it was `pending`, or leave it where it was. Do not mark `done` on a partial, and do not invent progress where the diff is silent.
- **CRUD claim.** Split, merge, or add implied by the description — see below.

Notes appends carry two parts — the user's description (verbatim or near-verbatim) and a short diff summary naming the surfaces touched — so a later reader can tell which line is claim and which is mechanical.

## Verifying "done" against the diff

A done-claim check is a lightweight pass, not a full review. For each acceptance criterion, judge whether the diff evidences it. A criterion phrased as *"returns 400 when the `signature` header is missing"* is evidenced when the diff adds the check and a test that exercises it. A check that lands without a test, or a failure branch handled but not exercised, is partially evidenced — enough signal to mention, not enough to silently mark `done`. One phrased as *"profile reads return under 200ms"* is not mechanically verifiable from a diff and is surfaced as unverified. One whose surface the diff does not touch at all is a likely gap.

When the check finds daylight, the proposal names each criterion's state — evidenced, partially evidenced, unverified, or gap — and the three honest next moves: mark `done` with a Notes entry naming the unverified criteria; leave `in-review` and surface the gap as a follow-up task; or hold at `in-progress` because the claim is premature. The judgment is the user's; naming the three cleanly is the skill's.

## Task CRUD from the description

Split, merge, and add are description-driven, but each is checked against the diff before it lands.

- **Split.** The user names the split ("0024 I split into 0024 and 0027 — the HTML template grew bigger than expected"). Confirm the diff's surfaces cluster into the claimed halves; if the second half has no diff signal, the split is a plan rather than a fact, and the new task is written at `pending`. The existing task is rescoped per `.metis/conventions/task-format.md`; its id stays.
- **Merge.** Uncommon. Two tasks collapsing into one usually means one supersedes the other — write the superseder, preserve both ids in its Notes so the merged history is recoverable, and do not delete the originals.
- **Add.** Work named in the description that has no existing task. Written per the retroactive-task shape below; `status` reflects whether the diff evidences completion.

A CRUD call the diff does not support is surfaced upstream rather than landed silently.

## Retroactive task when no existing task matches

When the description attributes work to no existing task — either because the invocation named no tasks at all, or because the description mentions unplanned work alongside named tasks — the artifact is one new task, shaped per `.metis/conventions/task-format.md`. What the retroactive case adds on top of the convention is three honesty constraints:

- **Context carries provenance.** The description sits in Context verbatim, prefaced with a one-line note that the work was logged after the fact. Without the preface, a later reader cannot tell a retroactive task from a pre-planned one.
- **Do not invent what the description did not supply.** Goal restates the description's outcome framing rather than a prospective goal derived from the diff. Acceptance criteria use the description's testable conditions if named; otherwise one placeholder — *"the changes listed below are the intended changes"* — and `### Out of scope` restates the diff's surface boundary rather than inventing new constraints.
- **Status reflects reality.** `done` if the diff evidences completion; `in-progress` otherwise. A retroactive task is not required to be `done` — the "after the fact" part is the log timing, not the work state.

A thin retroactive task told honestly beats a padded one. Inventing a richer Goal or scope frame the description did not supply re-introduces the second failure mode on a task with no prior record to fall back on.

## Architecture-level diffs trigger a decision

Some diffs touch a structural commitment the task Notes cannot hold. Signals: a boundary crossed (service call turned into a library import, or the inverse); a new component introduced (queue, cache, scheduler, background worker); a schema migration; a removed constraint or relaxed invariant; a cross-module contract changed. When one of those fires, the update proposal includes a decision in addition to the task updates.

The decision's Context pins the upstream trigger — the description passage that named the move and the diff's specific surfaces — and Evidence links the diff range and the task ids that absorbed the work. Decision and Consequences follow `.metis/conventions/decision-format.md`; the judgment this skill carries is the trigger, not the shape of the file.
