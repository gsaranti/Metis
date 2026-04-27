---
name: walking-open-items
description: Reference for walking one captured open item to resolution — reading the capture, picking between genuine alternatives, a recommendation, or an honest ask, updating the source doc with the chosen answer, and moving the item's lifecycle state so the files on disk are the next session's resume point.
disable-model-invocation: true
---

# Walking open items

An open item is a captured entry in `docs/CONTRADICTIONS.md` or `docs/QUESTIONS.md` — a contradiction or gray area surfaced during reconcile and waiting for a position. The job of this skill is to walk one open item to resolution: judging whether the corpus implies an answer, offering 1–2 genuine alternatives, or calling for the user's input; updating the relevant source doc with the chosen answer; and moving the item's lifecycle state so the on-disk files are the next session's resume point.

Two failure modes pull against each other: resolving too eagerly, so the agent picks a side the docs do not actually commit to; and punting every item back to the user with no real thinking, so the walk reverts to the user explaining every call from scratch.

## Read first

- The one open item being walked, and the source-doc passages it cites. Re-open the source at the cited section so the walk is not working off a paraphrase that has since drifted.

`docs/RESOLVED.md` is archive-only and is not read during a walk. Load it on demand if the user asks whether a related topic has been resolved before.

## Reading the item before proposing anything

An open item arrives pre-framed by the reconcile pass: quoted passages, a neutral sentence naming the disagreement or gap. Start from the captured framing, but verify the cited passages still say what the item claims. When the quoted text has been rewritten, renamed, or dropped since capture, the item is **stale** — the walk cannot honestly resolve a framing the docs no longer make. Mark the status, note what changed, and leave re-capture to the next reconcile.

## Alternatives, recommendation, or ask

For each open item, pick one of three registers. The pick is the core judgment this skill carries.

- **Two genuine alternatives.** The corpus supports more than one honest reading, each defensible from the cited passages. Surface both with the trade-offs they imply and let the user choose. A genuine alternative is one a careful reader could pick without being pushed; if the second option is weaker on every axis and only exists to make the first look chosen, drop it. A user who accepts the "recommendation" against a straw man has not really chosen.
- **One recommendation.** The corpus implies a single answer the user is very likely to confirm. Surface that read with its reasoning and let the user redirect. A recommendation is honest when inventing a second option would require reaching outside what the docs actually say.
- **Ask.** The corpus genuinely does not imply an answer. Name the gap and ask rather than fabricating options. An invented alternative dressed as a choice is worse than an honest "I don't have a good read here."

Across all three registers, the user is free to supply an answer the agent did not surface — the registers shape what the agent contributes, not what the user can say back.

The test for which register fits: how much does each candidate answer lean on what the docs say vs. on invention? Heavily on docs → recommendation. Evenly between two doc-supported reads → alternatives. On invention → ask.

## Asking the user vs. deciding

Even with a strong recommendation, some resolutions must be confirmed by the user rather than landed by the agent. The threshold is downstream reach: a resolution that shapes `BUILD.md`, spans epics, or forecloses future options is the user's to make. A resolution that specifies a local detail with no architectural spread — a specific error code, a log field name — can be landed by the agent, with the doc update and the `docs/RESOLVED.md` pointer making the choice legible for later review. The tiebreaker: a reader six months later wants the user's name on architectural resolutions; if the doc would read oddly without that fingerprint, ask.

## The source-doc update

Whether the agent lands the edit or the user confirms it, prefer the smallest change that removes the ambiguity the item named. A walk is license to close the specific gap captured, not to rewrite surrounding prose the item didn't force.

## Deferred, resolved, and stale

`deferred` is a conscious "not now." The item stays in its active file with the reason for deferral recorded in the body, so a later walk does not re-offer the same options. It remains open from the walk's perspective — deferral is not a quiet way to archive.

`resolved` means the source doc has been updated so it no longer reads as open. The item is removed from its active file and a pointer is appended to `docs/RESOLVED.md`.

`stale` is the re-read outcome above: the capture no longer matches the docs. The item stays in its active file until the next reconcile replaces it, or until the user confirms the topic is no longer live.

The three are not interchangeable. Flipping `open` straight to `resolved` without the source-doc update, or collapsing `stale` into `resolved` because the topic seems to have gone away, breaks the property that the on-disk files are the walk's resume state.

## Shape of the resolved pointer

The `docs/RESOLVED.md` entry is minimal — title, date resolved, and a one-line summary of the answer that was written into the doc:

```markdown
## Q3: Session duration
Resolved: 2026-04-19
Summary: 30-day refresh + 15-min access token.
```

The resolution's substance lives in the updated source doc, not the pointer. The docs themselves are the architectural record going into development; the pointer is only a thin archive trail — what has been resolved — not a second copy of the answer.

## Follow-ups from a walk

A walk can produce new captures, not just close old ones. When a resolution answers the item at hand but exposes a downstream uncertainty — a new term introduced, a consequence that wasn't specified, a sibling question the chosen answer raises — append a fresh item to `docs/QUESTIONS.md` or `docs/CONTRADICTIONS.md` for a later pass. Closing one item by quietly hiding the follow-up it spawned is a form of over-resolving.

## Examples

- `examples/walked-item.md` — one walked `C` entry and one walked `Q` entry, showing the doc update each walk wrote, the `docs/RESOLVED.md` pointer it appended, and the alternatives-or-ask the walk actually offered. **Read this before your first walk in a session.**
