# Reviewing against criteria

A review is the check that a task's acceptance criteria were met by the diff that claims to have met them. The job of this skill is to take one task file and one diff and render the review as a block appended to the task file's Notes — per-criterion judgment with specific evidence, a clean separation between code-quality findings and criterion evaluation, and a verdict a caller can act on without re-deriving the work.

Two failure modes pull against each other. Under-rejecting approves a diff that quietly handled a criterion "differently" and lets the scope reduction land silently; a later reader has to re-read the diff to notice what is missing. Over-rejecting blocks a passing diff on nits that should have been noted and moved past; the review becomes tax rather than signal.

## Read first

- The task file being reviewed and the diff under review, along with the source-doc passages behind the task's `docs_refs` and the command output the implementer cited for tests or verification. Re-open the cited doc sections when a criterion turns on a passage the task abbreviated.
- When the task lives under an epic, the parent `EPIC.md`.

The plan at `scratch/plans/<id>.md` is deliberately not on the read list — see "Reviewing without the plan" below.

## Artifact shape

There is no convention file for a review. The on-disk shape — one block appended to the task file's Notes — sits here:

- **Per-criterion findings** — one entry per acceptance criterion, each a pass or fail with specific evidence. Criteria are taken verbatim from the task file so the mapping is unambiguous.
- **Scope reduction** — a separate list, present only when the diff delivers less than the task file promised. Absent when the diff meets the criteria as written.
- **Code-quality notes** — nits and smells kept out of the criterion findings. Absent when the diff is clean enough to need none.
- **Verdict** — one line: `approve`, `approve-with-nits`, or `reject-with-reasons`.

Sections beyond this belong in a task Note the reviewer did not need to file.

## Criterion by criterion, with evidence

Each criterion gets a pass or fail and the specific thing the reviewer pointed at — a test name, a diff hunk, the output of the task's verification command, a grep result against the repo. "Passes because the code looks right" is not evidence; it is a vibe with a verdict attached. Where the task's criterion names a visible condition ("returns 400 when the signature is missing"), the evidence is the test or output that shows the condition. Where the criterion is structural ("migration adds a `deleted_at` column"), the evidence is the diff line.

A criterion that cannot be evaluated without forming an opinion about the code is not a criterion; it is an underspecified line in the task file. Surface that upstream rather than passing the criterion on a reading the reviewer cannot point to.

## Scope reduction is a finding, not a concession

When the implementer's return says a criterion was "handled differently" — a stubbed path, a deferred case, a feature toggled off — the reviewer's job is to name that as reduction against the task's scope, not to absorb it into the verdict. The anchor is the task file's acceptance criteria and its out-of-scope list as written when the work started; changes to either belong upstream, not in a review that quietly accepts them.

The test for whether a "handled differently" is reduction or equivalence: can a reader hold the original criterion and the shipped behavior next to each other and see them as the same promise? If no, it is reduction, and the review says so.

## Code quality vs. spec compliance

Two axes. A clean diff does not buy a criterion miss; a code smell does not sink a criterion pass. Nits — naming that reads oddly, a helper that belongs elsewhere, a missed logging opportunity — live in the code-quality notes and adjust the verdict along the approve / approve-with-nits boundary, never the approve / reject boundary. A reviewer who rejects on a nit has confused taste with compliance; a reviewer who approves a criterion miss because the code is otherwise good has done the opposite.

## Verdict

- **approve** — every criterion passes, no scope reduction, no nits worth recording. The shortest verdict, and the most common when the task file was well-formed.
- **approve-with-nits** — every criterion passes, no scope reduction, but code-quality notes are worth leaving behind. The nits are recorded with enough specificity that a follow-up can act on them, and the caller is not blocked.
- **reject-with-reasons** — at least one criterion fails or cannot be evaluated, or scope was reduced. Reasons are specific: the criterion verbatim, the evidence (or its absence) that forced the verdict, and what would have to change for a re-review to pass. A reject that reads as "doesn't feel right" is a review that needs to be rewritten before it is posted.

A verdict that approves while listing reasons that sound like rejects is a reject that flinched. Commit to the verdict the evidence supports.

## Reviewing without the plan

The judgment anchor is the task file's acceptance criteria, not the plan's steps. The plan was the implementer's route to meeting the criteria; meeting them is what the review checks. An implementer's Notes return may explain a deviation from the plan, and reading that note is fair context, but the review is against the task, not the plan. A reviewer who judges the diff against the plan rewards plan fidelity over outcome delivery — the opposite of what the verdict is for.

The practical consequence: when plan and diff diverge but the criteria pass, the review can approve. When plan and diff align but a criterion fails, the review rejects. The plan does not enter the verdict reasoning in either direction.

## The diff may be empty

Before rendering the review, confirm the diff under review actually exists. A branch that matches its baseline, a `git diff` with zero lines, or a working tree whose changes are entirely unrelated to the task's `touches` — any of these means there is no implementation work to judge. The right return is not a review — it is a finding naming the branch, the baseline compared against, and the conclusion that nothing evidences an attempt at the task's acceptance criteria. Manufacturing per-criterion *fails* against an absent implementation buries the real finding (the work did not happen) inside a template the caller has to parse.

The bar is whether there is implementation work to evaluate, not whether every file the task named was touched — a task whose criteria are met by fewer files than expected is still reviewable, with the mismatch itself a scope finding.

## Sizing as feedback

Short by default — most reviews fit in a page. A review that outgrows the task file is either finding scope drift worth surfacing upstream as its own item, or editorializing between findings rather than evidencing them. A single-paragraph review is usually missing evidence on at least one criterion.

## Examples

- `${CLAUDE_PLUGIN_ROOT}/references/examples/good-review.md` — a review block for a mid-sized task: per-criterion evidence, one scope-reduction finding, one code-quality nit kept separate, a `reject-with-reasons` verdict. **Read this before your first review in a session.**
