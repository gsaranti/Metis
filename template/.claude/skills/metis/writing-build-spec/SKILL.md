---
name: writing-build-spec
description: Reference for writing BUILD.md — a forward-looking, risk-first architecture brief in the agent's own words that synthesises the reconciled corpus and names the first vertical slice.
disable-model-invocation: true
---

# Writing the build spec

`BUILD.md` is a short, forward-looking architecture and build plan — roughly 3–8 pages — written in the agent's own words from the reconciled corpus. It is the document the rest of Phase 1 hangs off: the epic breakdown is cut from it, the first vertical slice is specified in it, and downstream drift checks compare against it. The job of this skill is to render one `BUILD.md` that condenses the corpus without restating it, and that commits to the architectural risks it is taking on.

Two failure modes pull against each other. A brief that transcribes the docs — paraphrased section by section, no synthesis across them — adds no judgment a fresh reader would not get more cheaply from `docs/` itself. A brief that skips the load-bearing calls — no named risks, no first slice, no shape for the data model — is too thin to steer epic breakdown or Phase 2 and will be rewritten on first contact.

## Read first

- `docs/SYNTHESIS.md` and `docs/INDEX.md` if they exist — Phase 0 orientation over the reconciled corpus. Used to choose which source docs to re-open, not as the brief's content.
- The source docs under `docs/` at the passages the brief will synthesize from. Open them at the cited sections rather than working off the orientation's paraphrase.

`decisions/` is grep-only — if prior decisions exist, find them by slug or content match rather than listing. For an existing-codebase project, the relevant code is read the same way: as input to the synthesis, not as material for a tour.

## Risk-first framing

Name the riskiest architectural decision before committing to the details that depend on it. A brief that opens on the data model or module boundaries has already bet on the decision underneath them; the reader cannot tell what the bet is or whether it held. Lead with the one call the rest of the architecture is most sensitive to — the system boundary that decides how much state lives server-side, the integration that forces a particular async shape, the identity model the downstream schema assumes — and state it committally.

Risk comes from the corpus, not from invention. The right risk to lead on is the largest resolved question, the most load-bearing constraint, or the thing Phase 2 will have to work around if the call turns out wrong. If no risk can be named, either the brief is premature or the corpus is still missing its sharp edges — surface that in the build spec rather than padding.

## Own words, not transcription

Restate the corpus's commitments in the brief's own synthesis. If a paragraph of `BUILD.md` could be replaced by a quote from `docs/`, it should be a link, not a copy — the value the brief adds is what the docs mean when held together, not what they said section-by-section. The test: with the source docs open next to the brief, can a reader tell what judgment the brief is making across them? If each paragraph just mirrors one doc section, no judgment is being made.

## Excerpt vs. summarize

Summarize by default. Quote verbatim only when the exact words are load-bearing — a specific contractual constraint, a named exit condition, a clause the implementer must treat as literal. Every quote carries its source path inline (`` `docs/auth.md §Sessions` ``) so a reader can always drop back into the original. A paraphrase of a contractual commitment is a silent weakening; if the exact words matter downstream, quote them.

## Forward-looking, not backward

`BUILD.md` states what is being built. It does not describe the existing system. For an existing-codebase project, the brief describes the delta — what this build adds, changes, or replaces — and treats existing surfaces as context from the corpus, not as content to tour. System-state descriptions belong in reconcile artifacts under `docs/`, not in the build spec.

## What the brief covers

The substantive territory: data model, module boundaries, integrations, testing approach, and the first vertical slice. These are topics to cover when the corpus speaks to them, not a mandated table of contents. Order follows the risk lens — lead with the area the most load-bearing decision sits in, then walk outward to what depends on it. A fixed section order that buries the architectural bet under standard headings fights the risk-first property.

If the corpus covers an area and the brief is silent on it, either include it or say why it is out of scope — silent omission lets drift start before Phase 2 does.

## The first vertical slice

A named section in `BUILD.md`. This is what Phase 2 will build: the thinnest end-to-end pass through the system that actually runs — one route, one screen, one database write, one passing test, all in one deployable shape. The slice is specified concretely, not categorically: the specific endpoint, the specific entity written, the specific check that proves it end-to-end. A categorical slice ("a read path and a write path") reads like an architecture sketch; a concrete slice reads like a task worth picking up.

The slice earns its own section because it is the architecture's first real test. If it cannot be named, the architecture has not committed enough to steer Phase 2.

## Sizing as feedback

The 3–8 page band is a shape, not a rule. Drafts that run past 8 pages almost always fail the own-words discipline — trimming excerpts and pushing detail back into the source docs usually recovers the range. Drafts under 3 pages usually skip the risk lead or the first slice, and a reader cannot tell what has been committed to.

Any change to `BUILD.md` after initial creation is written through `/metis:sync` and accompanied by a new entry in `decisions/` — `.metis/conventions/write-rules.md` treats `BUILD.md` edits as spec-shaping by default. The implication: initial creation is where the architectural judgment is captured cleanly, before the decisions log starts carrying the why.

## Examples

- `examples/good-build.md` — a mid-scope build spec landing in the 3–4 page band: a risk-first opening, a synthesis-not-transcription read of the corpus, a concretely named first vertical slice. **Read this before writing your first build spec in a session.**
