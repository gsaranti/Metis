# Metis v0.1 — Project Handoff Document

This document is a complete handoff for the Metis project. It's intended to bring a fresh Claude conversation up to the exact point where design ended, so building can continue without losing context.

Read this document top to bottom. Every section matters. By the end, you should know what Metis is, why it exists, what it's not, what it ships in v0.1, and what's been decided about every meaningful design question.

---

## Table of contents

1. [What Metis is](#what-metis-is)
2. [Why I'm building it](#why-im-building-it)
3. [The existing landscape](#the-existing-landscape)
4. [Metis's positioning and principles](#metiss-positioning-and-principles)
5. [The workflow Metis encodes](#the-workflow-metis-encodes)
6. [Project modes: flat vs epic](#project-modes-flat-vs-epic)
7. [Directory structure](#directory-structure)
8. [The command list](#the-command-list)
9. [Conventions](#conventions)
10. [Skills](#skills)
11. [Subagents](#subagents)
12. [Example flows](#example-flows)
13. [Design decisions already made](#design-decisions-already-made)
14. [Build order](#build-order)
15. [What's deferred to v0.2+](#whats-deferred-to-v02)
16. [Open questions](#open-questions)
17. [How to pick up from here](#how-to-pick-up-from-here)
18. [Refinements (post-handoff design conversation)](#refinements-post-handoff-design-conversation)
19. [Appendix: the conversation that produced this](#appendix-the-conversation-that-produced-this)

---

## What Metis is

Metis is an agentic development toolset for Claude Code, oriented around **context management across sessions** as the hard problem. It works on projects of any size and doc-maturity — flat task mode for smaller work, epic mode for larger builds, with or without an existing docs corpus. It structures the project, not the agent — giving Claude direction, order, and context rather than trying to reshape how Claude thinks or writes.

The core value proposition is simple: at any moment, a fresh agent session can read Metis's on-disk state and know where the project stands — what's planned, what's in progress, what's done, what was decided, and why. How the code actually got written between sessions is orthogonal. The user can code alone, pair with an agent without invoking any Metis commands, use Metis's plan/implement/review loop, or mix all three. Metis's job is to make the next session's context accurate regardless.

It provides:

- A filesystem layout (`BUILD.md`, `epics/` or `tasks/`, `decisions/`, `docs/` reconcile artifacts, `scratch/`, `.metis/`) that makes project state explicit on disk
- Slash commands (`/metis:*`) — some produce those artifacts, some reconcile them against changes the user made outside Metis
- Skills that capture reusable know-how for the agent
- Subagents with scoped tool permissions for task-level execution, when the user wants that structure
- Conventions that standardize file formats

The engineering-loop commands (`/metis:plan-task`, `/metis:implement-task`, `/metis:review-task`) are an option Metis offers, not the spine of Metis. The spine is the artifacts themselves and the reconciliation mechanisms (`/metis:sync`, `/metis:log-work`, hand-editing plus a resync) that keep the artifacts honest when the user bypasses the loop.

The core insight driving the design: **coding agents mostly fail not because they can't write code, but because they lose track of intent across long sessions and silently drift from specs.** Metis counters that failure mode with structure on disk — reconciled specs, task-scoped artifacts, explicit state — and with reconciliation commands that absorb user edits rather than fight them.

The name: Metis is the Greek goddess of wisdom and deep thought, mother of Athena. Tagline candidate: *"Wisdom before code."*

---

## Why I'm building it

### The problem

I'm an engineer who works on medium-to-large projects that typically start with a pile of documentation — UX requirements, design docs, technical specs written at different times, often by different people. The standard "prompt Claude Code to build this" approach breaks down quickly:

- The agent picks one side of a contradiction and runs with it, silently
- Context across sessions degrades — feature 6 doesn't know about decisions made in feature 3
- "Done" is self-reported, not verified
- Scope quietly shrinks; the agent reports the reduced scope as complete
- Architectural drift compounds — a wrong assumption in task 3 becomes a bug in task 17

Existing frameworks address pieces of this but none take "start with a docs directory" as the primary entry point. They assume greenfield or prototype-level work. Metis is for the case where you have substantial specs *before* you start building.

### Why build another framework instead of using existing ones

Several reasons:

1. **None of the existing frameworks center doc reconciliation.** The upstream problem — "I have 80 pages of specs that contradict each other in places" — is where my projects actually start. Superpowers, gstack, and GSD all assume that phase is done.

2. **Existing frameworks are rigid in different ways.** Superpowers enforces TDD at the skill level, forcing the ritual even when it doesn't fit. gstack role-plays the agent through a CEO → PM → QA → engineer arc for every feature, which is theater. GSD is portable but light on opinion.

3. **I want to internalize the design.** Building it myself forces me to actually understand which parts matter and which are ceremony. It also means I can iterate on the shape without waiting for someone else's roadmap.

4. **The "structure the project, not the agent" principle isn't in the current ecosystem.** Existing frameworks try to constrain how the agent thinks. I want something that gives the agent a well-defined task and lets it solve the task however it works best. This is a real positioning gap.

### What success looks like for v0.1

I use it on one real large project end-to-end and it holds up. That's it. No publication, no community, no marketplace. Ship it privately, use it, fix what breaks, then consider publishing.

---

## The existing landscape

Three frameworks I've looked at and the specific thing each does well, plus where Metis differs:

### Superpowers (obra/superpowers)

**What's good**: Principled engineering discipline. TDD enforcement, systematic debugging, verification-before-completion. The subagent-driven development pattern with two-stage review (spec compliance, then code quality) is genuinely good. Skills are the right abstraction and superpowers is the reference for how to write them.

**What's not for me**:
- TDD enforcement is rigid. Forcing RED-GREEN-REFACTOR on every change, including refactors or config work, is ceremony.
- Assumes greenfield. Starts with `brainstorming` skill. Doesn't address the "here's 80 pages of specs" case.
- Heavy prompt weight. The discipline costs tokens even on small changes.

**What Metis borrows**: Two-stage review (implementer + fresh reviewer subagent). Skills as a first-class abstraction. Self-sufficient task files for subagent dispatch.

### gstack (garrytan/gstack)

**What's good**: The `/office-hours` forcing-questions pattern is useful for surfacing what a founder is actually trying to build. Role-based organization fits founder/early-stage workflows well. Event-sourced pipeline mindset.

**What's not for me**:
- The virtual-team metaphor (CEO, PM, QA, Engineer, Designer personas running sequentially per feature) is theater. The model isn't better at code when you tell it "you are the engineer now" — it's better when it has a good plan and clear acceptance criteria.
- Oriented toward product/founder thinking, not engineering rigor on an existing spec.
- 23 skills is too many; most aren't used per feature.

**What Metis borrows**: Personas as exceptions at gates (not per-task). Treating mid-stream feature additions as a first-class operation.

### GSD / get-shit-done (codejunkie99/agentic-stack and related)

**What's good**: Portable — works across many agents (Claude Code, Cursor, Windsurf, Codex, etc.). Memory layers (working/episodic/semantic/personal) and nightly staging cycle for context compression.

**What's not for me**:
- Light on opinion. It's a context system, not a methodology.
- The memory layers are more than I need. `decisions/` as an append-only log is simpler and does the job.
- Portability is not a v0.1 concern — Claude Code is the target.

**What Metis borrows**: Filesystem-as-memory. State on disk, not in session transcripts.

### Google ADK, LangChain, etc.

Different category entirely. These are for building agents, not for structuring how a user works with an agent on a codebase. Not competitors.

---

## Metis's positioning and principles

### Audience

**Engineers using Claude Code on projects where state needs to survive across sessions.**

If the work is a throwaway prototype, a single-session script, or something you won't return to — **Metis is the wrong tool**. The overhead pays off when multiple sessions will touch the same project and you want each one to rehydrate cleanly; without that, the structure is cost without benefit. Tools that know their limits get trusted more.

### The load-bearing opinions

These are Metis's spine. Everything else is convention that can flex:

1. **Structure the project, not the agent.** Metis provides artifacts, conventions, and reconciliation mechanisms. The agent decides how to solve each task. No TDD enforcement, no persona role-play, no prescribed reasoning steps.

2. **Metis is optional at every step; it reconciles, it does not enforce.** Every artifact Metis produces can be hand-edited by the user at any time. The engineering-loop commands (plan/implement/review) are a convenience, not a requirement. The user can code alone, pair with an agent without invoking Metis, or drive work through Metis — and mix freely. Metis's reconciliation commands (`/metis:sync`, `/metis:log-work`, hand-editing followed by a resync) exist to absorb user edits, not to prevent them.

3. **Docs before code, when docs exist.** On a large doc-heavy project, Phase 0 reconciliation pays for itself. The agent reads `docs/`, produces synthesis + contradictions + open questions, and the user walks through them to populate a decisions log before building. This is Metis's strongest recommendation — but a recommendation, not a gate.

4. **Context is task-scoped, not project-scoped.** Every task file is self-sufficient. Subagents work from a task file plus `CLAUDE.md`, the referenced docs, and the parent epic (in epic mode) — never from other task files or `BUILD.md`. State lives on disk, not in session transcripts.

5. **Fresh instances at phase boundaries.** Resumption is for continuity within a phase, not across them. Starting Phase 1 in a fresh instance drops context that would otherwise compound into drift. Metis's artifacts are built to rehydrate a fresh agent quickly.

6. **Decisions are append-only and span the project.** Not buried in task files or docs. `decisions/` is the project's memory across epics and sessions. Superseding happens by writing a new decision, not by editing the old one.

7. **Context efficiency is load-bearing.** Every skill, subagent, and command is authored under a token budget. A Metis-structured session should cost less context than the disorder it prevents. "Works but bloated" is a bug, not a tradeoff; each layer loads only the slice of the conventions it actually needs.

### Tagline candidate

*"Wisdom before code."*

Ties to Metis the goddess (wisdom, deep thought) and to the Phase 0 ethos (reconcile before implementing). Short enough for a README.

### What Metis is not

- Not a general-purpose agent framework (not ADK, not LangChain)
- Not a prototyping tool (use raw prompting)
- Not a replacement for Claude Code (Metis runs *on* Claude Code, leveraging native capabilities like `/init`, plan mode, agentic search)
- Not cross-harness yet (v0.1 targets Claude Code; other harnesses deferred)

### The differentiation from existing frameworks

| Framework | Center of gravity | Metis's difference |
|---|---|---|
| Superpowers | Engineering discipline (TDD, systematic debugging) | Metis is less rigid about *how* the agent works |
| gstack | Product thinking via role-play personas | Metis treats personas as exceptions at gates, not per-task |
| GSD | Portability across agents | Metis is opinionated and Claude Code-first |
| *(gap)* | Starting from existing docs | **This is Metis's wedge** |

---

## The workflow Metis encodes

Metis encodes a canonical four-phase flow for a greenfield doc-heavy project. It is the intended path — the one Metis's artifacts and commands are shaped for — but it is not a gate system. The user can skip phases, reorder them, or bypass the commands entirely and hand-edit artifacts, then run a reconciliation command (`/metis:sync`, `/metis:log-work`) to bring Metis's view back in line. The phases describe *what good looks like*, not what Metis forces.

Phase boundaries are still worth respecting when they're used: each is best started in a fresh Claude Code instance to drop accumulated context that would otherwise compound into drift.

### Phase 0 — Reconcile

Before writing a line of code, the agent reads `docs/` and produces:
- `docs/SYNTHESIS.md` — one-page summary of what the app is, in the agent's own words
- `docs/INDEX.md` — concepts → file + section map
- `docs/CONTRADICTIONS.md` — direct conflicts between docs (doc A says X, doc B says Y)
- `docs/QUESTIONS.md` — gray areas: silences, ambiguities, implicit assumptions, terms used loosely (one thing underspecified vs. two things disagreeing)

Then the user walks through both files with the agent via `/metis:walk-open-items`, one item at a time. For each, the agent offers 1–2 suggested resolutions plus a free-form input option. Each resolution updates the relevant doc and appends a one-paragraph entry to `decisions/` (date, context, decision, consequences). Resolved items are moved immediately to `docs/RESOLVED.md` (a minimal-pointer archive that links to the decision entry); active files only contain `open` and `deferred` items, so resume is cheap.

Per-item status: `open` (default), `resolved` (moved to RESOLVED.md), `deferred` (still in active file but explicitly skipped for now), `stale` (referenced doc has changed since item was captured — needs re-consideration). The walk supports stop/resume across sessions and non-sequential navigation.

**Phase 0 is always main-agent, not subagents.** Contradictions are cross-document; fragmenting reading across subagents misses them. Subagents may be used as scalpels for compressing a single dense doc or doing a mechanical consistency sweep, but the synthesis and reconciliation stays with the main agent.

**Threshold for hybrid approach**: under 80k tokens total `docs/` size, main agent reads everything. 80k–150k, main agent does a first pass and produces `INDEX.md`, then dispatches subagents to compress the densest docs. Over 150k, hybrid is mandatory and `docs/` itself probably needs pruning.

Token estimation: `wc -w docs/ × 1.3` for prose, × 1.5 for mixed, × 1.8 for schema/code-heavy.

### Phase 1 — Build spec + backlog

From the reconciled docs, produce:
- `BUILD.md` — short (3–8 pages) architecture/build plan in the agent's own words. Data model, modules, integrations, testing approach, first vertical slice.
- Epic breakdown (epic mode) or flat task backlog (flat mode)
- Task files for the first epic only (epic mode) or the full backlog (flat mode, if small enough)

User edits ruthlessly. The editing pass is the highest-leverage hour of the project.

### Phase 2 — Skeleton

Ship the thinnest end-to-end slice: one route, one screen, one DB write, one passing test, runnable. User drives this directly — too architectural to delegate.

### Phase 3 — Feature loop

The canonical per-task loop, when the user wants Metis's engineering structure:

1. `/metis:pick-task` → choose an unblocked task
2. `/metis:plan-task <id>` → planner subagent produces a plan, user reviews
3. `/metis:implement-task <id>` → implementer subagent implements, tests, returns with real test output
4. `/metis:review-task <id>` → reviewer subagent judges against acceptance criteria (two-stage review)
5. `/metis:scope-check` → agent enumerates what it skipped
6. Merge

This loop is optional. Any task can be coded by the user alone, paired with an agent outside Metis, or partially driven through Metis (e.g., plan by hand, implement with the subagent) and still end up reconciled. `/metis:log-work` absorbs code written outside the loop by diffing the working tree against the task file and updating status, notes, and frontmatter accordingly. Hand-edits to task files are equally legitimate; Metis reads from disk and trusts what it finds there.

Session begins with `/metis:session-start` (loading dose), ends with `/metis:session-end` (update `CURRENT.md`).

Epic boundaries (epic mode): `/metis:epic-retro` writes a retro, `/metis:scratch-cleanup` promotes useful scratch out, next epic's tasks get generated.

### Pair programming dynamics

Treat the agent as the junior, user as the navigator. Hard rules:
- Ask the agent to defend non-obvious choices before accepting them (`/metis:pushback`)
- Rebaseline every hour or two (`/metis:rebaseline`)
- After every feature, ask what was NOT done (`/metis:scope-check`)
- Keep docs alive — update them in the same PR as implementation reveals truth

---

## Project modes: flat vs epic

Metis supports two structural modes, determined at `/metis:init` and stored in `.metis/config.yaml`.

### Flat mode

For medium projects with roughly 10–40 tasks that don't need capability-level grouping.

```
tasks/
  0001-*.md
  0002-*.md
  ...
```

No `epics/` directory. No `EPIC.md` files. Just a flat list.

### Epic mode

For large projects with 40+ tasks and work that clusters into capabilities.

```
epics/
  001-authentication/
    EPIC.md
    tasks/
      0001-*.md
      0002-*.md
    retro.md
  002-billing/
    EPIC.md
    tasks/
      ...
```

Directory-per-epic. Tasks nested under their epic. Retro lives with the epic.

### Graduation

`/metis:promote-to-epics` exists for projects that start flat and grow. Takes existing flat tasks, proposes epic grouping, moves files, rewrites paths.

### Mode-dependent command behavior

Most commands work in both modes. A few are mode-specific:
- `/metis:epic-breakdown` — epic mode only (errors in flat)
- `/metis:epic-retro` — epic mode only
- `/metis:promote-to-epics` — flat mode only (errors in epic)
- `/metis:generate-tasks` — takes no arg in flat mode, takes an epic name in epic mode (errors if mismatched)

When a command is invoked in the wrong mode, error messages should suggest the likely-correct alternative. Example:
```
This command requires epic mode, but this project is configured 
for flat mode (.metis/config.yaml).

If your project has outgrown flat mode, run:
  /metis:promote-to-epics
```

### What never differs

- The feature loop commands (`/metis:plan-task`, `/metis:implement-task`, `/metis:review-task`, `/metis:scope-check`)
- Session commands (`/metis:session-start`, `/metis:session-end`)
- Maintenance (`/metis:scratch-cleanup`, `/metis:rebaseline`, `/metis:pushback`)

The feature loop is the spine of Metis and is identical in both modes.

---

## Directory structure

Two sets of files: project-root artifacts (project's own truth) and `.metis/` (framework scaffolding). Plus `.claude/` for harness integration.

### Full layout (epic mode example)

```
README.md                  # human onboarding
CLAUDE.md                  # agent operating manual, has a delimited Metis section
BUILD.md                   # canonical "what we're building", from /metis:build-spec
BOARD.md                   # generated status index

docs/                      # source material
  SYNTHESIS.md             # from /metis:reconcile
  INDEX.md                 # from /metis:reconcile
  CONTRADICTIONS.md        # from /metis:reconcile (open + deferred items only)
  QUESTIONS.md             # from /metis:reconcile (open + deferred items only)
  RESOLVED.md              # archive of resolved items (pointers to decisions/)
  ... (user's existing docs)

decisions/                 # append-only ADRs, span epics
  2026-04-18-auth-flow.md
  2026-04-19-db-choice.md
  ...

epics/                     # work organized by capability
  001-authentication/
    EPIC.md                # goal, scope, exit criterion
    tasks/
      0001-auth-schema.md
      0002-signup-endpoint.md
      ...
    retro.md               # written at epic close
  002-billing/
    ...

scratch/                   # ephemeral, mostly gitignored
  CURRENT.md               # session handoff (committed)
  questions.md             # running Qs for human (committed)
  plans/                   # subagent-produced plans (gitignored)
    0007.md
  exploration/             # spikes (gitignored)
  research/                # web fetches (gitignored)

.metis/                    # framework scaffolding
  config.yaml              # mode: flat|epic, project settings
  version                  # Metis version that scaffolded this
  MANIFEST.md              # what Metis created (for uninstall clarity)
  conventions/
    task-format.md
    epic-format.md
    decision-format.md
    frontmatter-schema.md
    write-rules.md
  templates/
    task.md
    epic.md
    decision.md

.claude/                   # Claude Code integration (harness-specific)
  commands/
    metis/
      init.md
      reconcile.md
      ... (22 commands)
  agents/
    metis/
      task-planner.md
      task-implementer.md
      task-reviewer.md
  skills/
    metis/
      writing-task-files/
        SKILL.md
        examples/
      reconciling-docs/
        SKILL.md
      ... (12 skills)
```

### Flat mode variation

Replace `epics/` with:

```
tasks/
  0001-*.md
  0002-*.md
  ...
```

Everything else is identical.

### Principle: what goes where

**Project root** — the project's own truth. Would exist in some form even without Metis. `BUILD.md`, `decisions/`, `tasks/` or `epics/`, `docs/`. First-class citizens.

**`.metis/`** — framework scaffolding only. Config, conventions, templates. If Metis is uninstalled, `.metis/` is deleted cleanly and project artifacts remain.

**`.claude/`** — harness integration. Commands, agents, skills in the Claude Code format. Harness-specific; future harnesses would have their own equivalents (`.codex/`, etc.).

Test for placement: *would a user care about this if Metis didn't exist?* If yes, project root. If no, `.metis/`.

### Files Metis creates vs modifies

**Creates fresh**: `BUILD.md`, `BOARD.md`, `decisions/`, `tasks/` or `epics/`, `scratch/`, `.metis/`, `.claude/commands/metis/`, `.claude/agents/metis/`, `.claude/skills/metis/`, `docs/SYNTHESIS.md`, `docs/INDEX.md`, `docs/CONTRADICTIONS.md`, `docs/QUESTIONS.md`, `docs/RESOLVED.md`.

**Modifies with delimited sections**: `CLAUDE.md`, `.gitignore`.

### CLAUDE.md delimited section

`CLAUDE.md` may exist already (user-written, auto-generated by Claude Code's `/init`, or from another framework). Metis never clobbers existing content. It uses delimiters:

```markdown
<!-- existing user content stays untouched -->

<!-- metis:start -->
## Metis workflow

This project uses Metis for structured agentic development.

**Mode**: flat (or epic)

**Key files**:
- BUILD.md — what we're building
- tasks/ (or epics/) — individual work items
- decisions/ — append-only ADRs
- scratch/CURRENT.md — session handoff

**Write rules**:
- Only the parent session writes to scratch/CURRENT.md
- Subagents write only to their assigned task file and their return value
- Decisions go in decisions/, not in scratch
- BOARD.md is generated; don't hand-edit

**Task file format**: see .metis/conventions/task-format.md

**Commands**: /metis:session-start, /metis:pick-task, 
/metis:plan-task <id>, /metis:implement-task <id>, 
/metis:review-task <id>, /metis:session-end
<!-- metis:end -->
```

On re-run, `/metis:init` replaces content between `<!-- metis:start -->` and `<!-- metis:end -->`, preserving user edits elsewhere in the file.

### .gitignore additions

```gitignore
# <!-- metis:start -->
scratch/*
!scratch/CURRENT.md
!scratch/questions.md
# <!-- metis:end -->
```

---

## The command list

Twenty-two commands total. All namespaced as `/metis:<name>` to avoid collisions with Claude Code built-ins and other frameworks.

### Setup (4)

- **`/metis:init`** — scaffold the Metis directory structure. Asks flat vs epic mode. Non-destructive; preserves existing files via delimited sections.
- **`/metis:reconcile [prompt]`** — read `docs/`, produce `docs/SYNTHESIS.md`, `docs/INDEX.md`, `docs/CONTRADICTIONS.md`, and `docs/QUESTIONS.md`. Surfaces both contradictions (direct conflicts) and gray areas (silences, ambiguity, underspecification). Requires `docs/` to exist.
- **`/metis:walk-open-items [prompt]`** — walk through open items from both `docs/CONTRADICTIONS.md` and `docs/QUESTIONS.md` one at a time. For each item, agent offers 1–2 suggested resolutions plus a free-form user-input option. Supports stop/resume across sessions via per-item status (`open` / `resolved` / `deferred` / `stale`); resolved items are moved to `docs/RESOLVED.md` immediately so the active files stay lean. Each resolution updates the relevant doc and appends to `decisions/`.
- **`/metis:build-spec [prompt]`** — produce `BUILD.md`. Reads `docs/` + `decisions/` if they exist; accepts optional prompt as alternative or supplement.

### Planning (4)

- **`/metis:epic-breakdown`** — *epic mode only*. Propose 8–15 epics from `BUILD.md`. Creates `EPIC.md` files after approval.
- **`/metis:generate-tasks [epic]`** — generate task files. Flat mode: no arg, populates `tasks/`. Epic mode: takes epic name, populates that epic's `tasks/`. Errors on mode/arg mismatch.
- **`/metis:feature <description>`** — describe a new feature mid-stream. Produces feature spec and task files. Works in all modes.
- **`/metis:skeleton-plan`** — plan the thinnest end-to-end slice. Read-only.

### Feature loop (5)

- **`/metis:pick-task`** — list unblocked, prioritized tasks.
- **`/metis:plan-task <id>`** — dispatch `task-planner` subagent. Does not write code.
- **`/metis:implement-task <id>`** — dispatch `task-implementer` subagent.
- **`/metis:review-task <id>`** — dispatch `task-reviewer` subagent. Judges against acceptance criteria.
- **`/metis:scope-check`** — ask agent to enumerate what it skipped or reduced, no justification.

### Sessions (4)

- **`/metis:session-start`** — fresh-instance loading dose (`CLAUDE.md`, `CURRENT.md`, `BOARD.md`, active task file).
- **`/metis:session-end`** — update `scratch/CURRENT.md`, flag promotions out of `scratch/`.
- **`/metis:rebaseline`** — drift detector. Read-only. Compares current state of `docs/`, `BUILD.md`, and `epics/`/`tasks/` against a lightweight baseline (git markers + frontmatter `doc_hash` / `spec_version`) and reports what changed and which downstream artifacts reference it. Does not write.
- **`/metis:pushback`** — ask agent to defend its last choice.

### Change management (2)

- **`/metis:sync [prompt]`** — write counterpart to `/metis:rebaseline`. Reconciles *spec drift*: when source docs, `BUILD.md`, or epics have changed, walks proposed cascading updates one at a time (doc change → propose `BUILD.md` edit → on approval, propose epic edits → propose task edits). Every accepted change appends a `decisions/` entry. Never auto-applies. Main-agent (not subagent) work — cross-document reasoning. Cascade rules: `done` tasks don't update in place (changes become new tasks or superseding decisions), `pending`/`in-review` edit in place, `in-progress` requires confirmation. Batches simple textual updates; walks substantive ones interactively.
- **`/metis:log-work [task-ids] <description>`** — reconciles *implementation drift*: records code work the user did outside Metis (hand-edits, hotfixes, experiments). Runs `git diff` to verify; user's natural-language description is the source of truth for intent, the diff is the source of truth for what happened. Updates task statuses, appends Notes, handles task CRUD (split/merge/add). With no task argument, creates a retroactive `done` task from the diff + description.

### Epic boundaries (1)

- **`/metis:epic-retro <epic>`** — *epic mode only*. Write `retro.md` for a finished epic.

### Maintenance (2)

- **`/metis:scratch-cleanup`** — propose promotions out of `scratch/` and deletions. Waits for approval.
- **`/metis:promote-to-epics`** — *flat mode only*. Graduate flat → epic by grouping existing tasks into proposed epics.

### Command-to-skill-to-subagent mapping

| Command | Uses skill(s) | Dispatches subagent |
|---|---|---|
| `/metis:init` | — | — |
| `/metis:reconcile` | `reconciling-docs` | — |
| `/metis:walk-open-items` | `reconciling-docs`, `writing-decisions` | — |
| `/metis:build-spec` | `writing-build-spec` | — |
| `/metis:epic-breakdown` | `breaking-down-epics` | — |
| `/metis:generate-tasks` | `writing-task-files` | — |
| `/metis:feature` | `writing-task-files`, `breaking-down-epics` | — |
| `/metis:skeleton-plan` | — | — |
| `/metis:pick-task` | — | — |
| `/metis:plan-task` | — | `task-planner` |
| `/metis:implement-task` | — | `task-implementer` |
| `/metis:review-task` | — | `task-reviewer` |
| `/metis:scope-check` | `honest-scope-reporting` | — |
| `/metis:session-start` | — | — |
| `/metis:session-end` | `session-handoff` | — |
| `/metis:rebaseline` | — | — |
| `/metis:pushback` | — | — |
| `/metis:sync` | `propagating-spec-changes`, `writing-decisions` | — |
| `/metis:log-work` | `logging-external-work`, `writing-decisions` | — |
| `/metis:epic-retro` | `writing-retros` | — |
| `/metis:scratch-cleanup` | — | — |
| `/metis:promote-to-epics` | `breaking-down-epics` | — |

Commands are thin wrappers. Skills carry the substance. Subagents provide clean context + tool restrictions for task-level execution.

### Error messages on mode mismatch

Commands that check mode should produce helpful errors:

```
This command requires epic mode, but this project is configured 
for flat mode (.metis/config.yaml).

If your project has outgrown flat mode, run:
  /metis:promote-to-epics

Otherwise, you probably want:
  /metis:generate-tasks
```

Helpful errors with the likely-correct alternative. Not "wrong mode, goodbye."

---

## Conventions

Five files at `.metis/conventions/`. They define the canonical on-disk formats Metis relies on. Conventions are a **human- and design-time reference**: they encode the shape of files so both the user and Metis's agents agree on what those files mean. At runtime, skills, subagents, and commands each carry only the slice of the conventions they need — the conventions files are not bulk-loaded into every session.

### `task-format.md`

Specifies task file structure:
- Frontmatter fields (see `frontmatter-schema.md`)
- Section order: Goal, Context (excerpted), Scope boundaries, Acceptance criteria, Expected file changes, Notes
- Sizing: 50–150 lines. Longer means split.
- Excerpting rule: quote doc sections directly, don't just link
- In epic mode, the parent `EPIC.md` is part of every task's implicit context (subagents load it alongside the task file)

Task files are stable by default, not immutable: the user may edit any field by hand. The `id` and `title` are expected to stay fixed once a task is underway because other artifacts refer to them, but changing them is a supported workflow — reconcile via `/metis:log-work` or a direct resync, not by forbidding the edit.

### `epic-format.md`

Specifies `EPIC.md` structure:
- Frontmatter: name, goal, status, exit criterion, dependencies
- Sections: Goal, Scope, Out-of-scope, Exit criterion, Notes
- Sizing: ~1 page
- No strict task-count range. Epics cluster around a single testable exit criterion; task volume follows from the work, not from a quota.

### `decision-format.md`

ADR template for `decisions/` entries:
- Filename: `YYYY-MM-DD-kebab-case-title.md`
- Sections: Date, Context, Decision, Consequences, Evidence (optional)
- One paragraph per section, sometimes more
- Append-only — superseding is done by writing a new decision whose Context names the old one

Decisions are written by `/metis:walk-open-items`, `/metis:sync`, `/metis:log-work`, and by the main session whenever a change to `BUILD.md` or a source doc warrants a standing record. Subagents do not write decisions.

### `frontmatter-schema.md`

Canonical YAML frontmatter fields:

```yaml
---
id: "0007"                    # zero-padded 4-digit STRING (quoted — YAML parses 0007 as int 7)
epic: 002-billing             # epic mode only
title: Stripe webhook handler
status: pending | in-progress | in-review | done | blocked
priority: 1-5
depends_on: ["0003", "0005"]  # list of task ID strings (quoted)
estimate: small | medium | large
touches: [src/billing/, src/api/webhooks.ts]
docs_refs:
  - docs/billing.md#webhook-events
  - docs/security.md#webhook-verification
doc_hashes:                   # for drift detection by /metis:rebaseline + /metis:sync
  docs/billing.md: a3f1c9...
  docs/security.md: 7b2e44...
spec_version: 3               # bumps when BUILD.md sections this task references change
---
```

Specifies what's required vs optional, what values are valid, and why each field exists. The `doc_hashes` and `spec_version` fields support drift detection — when a referenced doc or `BUILD.md` section changes, the task is flagged stale by `/metis:rebaseline` and offered for cascade by `/metis:sync`.

### `write-rules.md`

A design-time reference for who writes what. Captures the rules as a whole so the design stays legible; the actual enforcement lives in the individual skill and subagent prompts, which each carry the one or two rules they need. Highlights:

- Only the parent/main session writes to `scratch/CURRENT.md`
- Subagents write only to their assigned task file and their return value
- Decisions go in `decisions/`, never in scratch; they are append-only
- `BUILD.md` changes only with an accompanying decision entry
- `BOARD.md` is generated; don't edit by hand
- Task files are stable by default but the user can hand-edit any field; Metis reconciles edits via `/metis:log-work` or a resync rather than forbidding them
- When a doc in `docs/` changes, update `BUILD.md` if relevant and log a decision entry
- Resolved items from `CONTRADICTIONS.md` / `QUESTIONS.md` move to `docs/RESOLVED.md` as minimal pointers; `RESOLVED.md` is never loaded during a walk unless explicitly requested

It also defines the **command-prompts convention** (an optional trailing free-text argument to most substantive commands) and three discipline rules for it: augment-not-replace, flag-scope-expansion, and acknowledge-use-explicitly. The prompt is ephemeral — never persisted to disk. Individual commands and subagents pick up this convention on their own; the convention file is the single source that documents it.

---

## Skills

Twelve skills at `.claude/skills/metis/<name>/SKILL.md`. Each is focused know-how that embeds judgment, not just rules.

### `writing-task-files`

**Purpose**: How to write a good task file.

**Covers**: Sizing (split if >150 lines), excerpting rule (quote relevant doc sections directly, don't link), scope-boundary articulation (explicitly list what's out), acceptance criteria as testable conditions, when to use `depends_on`, how to flag ambiguity.

**Used by**: `/metis:generate-tasks`, `/metis:feature`.

**References**: `.metis/conventions/task-format.md`, `.metis/conventions/frontmatter-schema.md`.

### `reconciling-docs`

**Purpose**: How to spot contradictions and gray areas across documents, and how to walk a user through resolving them.

**Covers**: 
- *Detection*: cross-doc pattern matching (same term used differently), implicit assumption detection, terminology drift, "what the docs don't say" (gaps). Distinguishes contradictions (two specified things disagreeing) from gray areas (one thing underspecified).
- *Surfacing*: how to populate `CONTRADICTIONS.md` and `QUESTIONS.md` without resolving; citing both sides for contradictions; articulating what's unclear for questions.
- *Walking*: per-item lifecycle format with status header (`open` / `resolved` / `deferred` / `stale`); how to offer 1–2 *genuine* alternatives (not straw men) per item, and the discipline to say "I don't have a good read here, need your input" when alternatives would be invented.
- *Archiving*: on resolution, move the item from its active file to `docs/RESOLVED.md` as a minimal pointer (decision link + one-line summary). Do not load `RESOLVED.md` during a walk unless asked.
- *Stale handling*: detect when a referenced doc has changed since the item was captured (via `doc_hash`); flag the item for re-consideration.

**Used by**: `/metis:reconcile`, `/metis:walk-open-items`.

### `writing-build-spec`

**Purpose**: How to produce `BUILD.md`.

**Covers**: Scope (3–8 pages), risk-first framing (state the riskiest architectural decision before committing), own-words rule (don't copy-paste from docs), what to excerpt vs summarize, the "first vertical slice" section.

**Used by**: `/metis:build-spec`.

### `breaking-down-epics`

**Purpose**: Sizing and structuring epics.

**Covers**: single testable exit criterion (the load-bearing constraint), capability-not-category framing ("Users can sign up and log in" not "Auth"), dependency identification, rough targets (~8–15 epics total, enough tasks per epic to justify the directory but no quota), "does this want to split?" heuristics, when to merge.

**Used by**: `/metis:epic-breakdown`, `/metis:promote-to-epics`.

### `planning-a-task`

**Purpose**: How to plan implementation for one task.

**Covers**: Ordered steps, file-level changes, test approach (not forced TDD — when tests-first fits), verification command, flagging ambiguity vs assumptions, when to push back on the task file itself.

**Used by**: `task-planner` subagent.

### `reviewing-against-criteria`

**Purpose**: Reviewing a diff against acceptance criteria.

**Covers**: Pass/fail per criterion with evidence, scope-reduction detection, separating code quality from spec compliance, verdict structure (approve / approve-with-nits / reject-with-reasons), reviewing without the plan (judgment against the task file, not the plan).

**Used by**: `task-reviewer` subagent.

### `writing-decisions`

**Purpose**: Good ADR entries.

**Covers**: Context → decision → consequences structure, when evidence is needed, keeping it one paragraph per section, making decisions findable (filenames, cross-references), when a decision supersedes another.

**Used by**: `/metis:walk-open-items`, `/metis:sync`, `/metis:log-work`, and the main session when a doc or `BUILD.md` change warrants a standing record.

**References**: `.metis/conventions/decision-format.md`.

### `honest-scope-reporting`

**Purpose**: Enumerating what was skipped or reduced.

**Covers**: No-justification rule (just list, don't defend), categories (skipped, deferred, stubbed, handled differently), making it easy for the parent to triage.

**Used by**: `/metis:scope-check`, `task-implementer` subagent returns.

### `session-handoff`

**Purpose**: Writing useful `CURRENT.md` updates.

**Covers**: What happened (1 paragraph), current state (in-progress/blocked/queued), open questions (move resolved out of `questions.md`, add new), what the next session should start with, what's ready to promote out of `scratch/`.

**Used by**: `/metis:session-end`.

### `writing-retros`

**Purpose**: Honest epic retros.

**Covers**: Estimation accuracy (per-task, not gestalt), replanning reasons (what got replanned and why), assumption failures (Phase 1 assumptions that turned out wrong), task-breakdown lessons, scratch promotions. "For improvement, not reassurance."

**Used by**: `/metis:epic-retro`.

### `propagating-spec-changes`

**Purpose**: How to cascade a source-doc or `BUILD.md` change through `BUILD.md` → epics → tasks without silent drift.

**Covers**: Detecting which downstream artifacts reference a changed doc (via `doc_hash` / `spec_version` on task frontmatter and `docs_refs`); classifying changes as cosmetic/textual vs. substantive (batch cosmetic for bulk approval, walk substantive one at a time); cascade rules by task status (`done` → new task or superseding decision, never in-place; `pending`/`in-review` → edit in place; `in-progress` → confirm before editing); writing decision entries that link the upstream change to each downstream edit; termination rules when the cascade would walk an unreasonable number of items.

**Used by**: `/metis:sync`.

### `logging-external-work`

**Purpose**: How to reconcile code the user wrote outside the Metis workflow against Metis state.

**Covers**: Using `git diff` as the source of truth for what changed; using the user's natural-language description as the source of truth for intent; reconciling the two and flagging daylight; verifying "done" claims against the diff (lightweight review pass); handling task CRUD implied by the description (split/merge/add tasks); detecting architecture-level changes that warrant a decision entry; creating retroactive `done` tasks when no existing task matches.

**Used by**: `/metis:log-work`.

### Skill structure

Each skill is a directory:

```
.claude/skills/metis/writing-task-files/
  SKILL.md              # the skill itself
  examples/
    good-task.md        # example of a well-formed task file
    bad-task-too-big.md # counter-example: task that should be split
    bad-task-vague.md   # counter-example: task without concrete criteria
```

Examples earn their keep when prose alone would leave the reader writing a noticeably worse artifact — usually zero or one per skill, occasionally two when they demonstrate materially different structural patterns. Counter-examples live in the SKILL.md prose as one-line failure descriptions, not as files; the full-file version of a failure mode rarely teaches something the one-liner doesn't, and it pays storage and maintenance cost for content nobody should be loading at runtime.

Examples are also the one place where register — terse, declarative, committal prose — transmits to Claude. That's legitimate because register is part of what makes the artifact work; it is not character dressing on top. The discipline: every register choice in an example should be traceable to a property the skill or convention names. A register choice that isn't artifact-justified is leaking character without warrant, and either the example should be revised or the skill should name the property the example was implicitly relying on.

Each skill sets `disable-model-invocation: true` in its frontmatter. Metis skills are a library dispatched by commands (or by explicit user invocation like `/metis:writing-decisions` or an inline reference in the prompt), not ambient helpers that auto-trigger on conversation cues. Two corollaries for skill content: descriptions are a one-line summary of *what the skill teaches*, not an enumeration of who calls it or when to invoke it; and SKILL.md files do not carry a "Used by" section — by the time a reader is inside the file, they are using it, and the callers are already documented in the command prompts and in `write-rules.md`. This keeps the always-on context small, keeps control flow explicit, and keeps SKILL.md content focused on the teaching rather than on routing metadata.

Skills teach what makes the artifact work, not how Claude should behave. Structural advice about the artifact belongs in skills ("a Decision that hedges is a question in disguise — readers can't tell what was decided"); character-shaping advice about Claude does not ("be more committal"). The two can sound adjacent but do different work. This does not rule out judgment content — what makes a good Context section, when to split a file, when something isn't decision-shaped are all load-bearing calls a skill should make — but the judgment is anchored to the artifact's function, not to Claude's voice. If a prospective skill cannot find a structural hook and its content only makes sense as advice about Claude's approach, that content belongs in a command prompt (which is allowed to be directive about a specific turn) or is not skill-shaped. The underlying bet: good user taste plus Claude's default behavior plus Metis structure produces better outputs than a framework that tries to rewrite Claude's character. Metis gives direction, order, and context; it does not adjust personality.

---

## Subagents

Three subagents at `.claude/agents/metis/<name>.md`. Each has tool restrictions that enforce workflow properties structurally rather than through prompt discipline.

### `task-planner`

**Purpose**: Read a task file, produce an implementation plan. No code changes.

**Tools**: `Read`, `Glob`, `Grep`, `Write` (restricted to `scratch/plans/`).

**Uses skills**: `planning-a-task`.

**System prompt covers**:
- Who they are (fresh context, no parent memory)
- What to load (CLAUDE.md, the specified task file, the parent `EPIC.md` in epic mode, only the docs in `docs_refs`)
- What NOT to read (other task files, `BUILD.md`, other epics)
- What to produce (plan at `scratch/plans/<id>.md`)
- What to return (plan summary + flagged ambiguities)

**Why the tool restriction**: can't start implementing while planning. Enforced structurally.

### `task-implementer`

**Purpose**: Implement a task per an approved plan.

**Tools**: `Read`, `Edit`, `Write` (restricted from `BUILD.md`, `BOARD.md`, `scratch/CURRENT.md`, `decisions/`, other task files), `Bash`, `Glob`, `Grep`.

**Uses skills**: `honest-scope-reporting`, plus whatever task-level skills exist (future: `writing-code-well`, `test-discipline`, etc.).

**System prompt covers**:
- Fresh context
- What to load (CLAUDE.md, task file, parent `EPIC.md` in epic mode, approved plan, only referenced docs)
- Rules: follow the plan, deviate only with explanation; tests when they fit; real test output in return
- Updates: task file status → in-review, appended Notes section
- Hard restrictions: do NOT write to BUILD.md/BOARD.md/CURRENT.md/other tasks/decisions
- Return shape: what did, what skipped + why, test results, open questions

**Why the tool restriction**: prevents silent architectural drift. Implementer can't decide mid-task that `BUILD.md` should change.

### `task-reviewer`

**Purpose**: Review a diff against acceptance criteria.

**Tools**: `Read`, `Glob`, `Grep`, `Bash` (for running `git diff` and tests only, no mutating commands).

**Uses skills**: `reviewing-against-criteria`.

**System prompt covers**:
- Fresh context — the reviewer didn't write the code, has no ego
- What to load (CLAUDE.md, task file including acceptance criteria, parent `EPIC.md` in epic mode, git diff, implementer's return notes)
- What NOT to load (the plan — we want judgment against the task file, not compliance with the plan)
- Evaluation per acceptance criterion: pass/fail + evidence (file/line citations)
- Separate code quality from spec compliance
- Return: verdict (approve / approve-with-nits / reject-with-reasons) + findings

**Why the tool restriction**: read-only means reviewer can't "helpfully fix" — must report findings. Prevents the reviewer from becoming a second implementer.

### Handling invocation prompts (all three subagents)

Each of the three subagents accepts an optional free-text prompt from the dispatching command (e.g., `/metis:plan-task 0007 "focus on retry semantics; the existing code uses tenacity, follow that pattern"`). Discipline rules baked into every subagent's system prompt:

1. **Augment, don't replace.** The invocation prompt augments the task file. The task file remains authoritative. If the prompt genuinely contradicts the task file (e.g., "ignore the acceptance criteria for test coverage"), the subagent flags the conflict and asks rather than silently choosing.

2. **Flag scope expansion.** If the prompt asks for something that expands scope beyond the task file, the subagent notes it in its return rather than quietly doing it. Same honest-scope-reporting discipline, applied in the other direction.

3. **Acknowledge use explicitly.** The subagent's return states how the prompt was used so it's traceable after the fact. Example: "Per your note to use tenacity, I followed the existing retry pattern in `billing/client.py` rather than implementing from scratch."

These rules also apply to main-agent commands that accept a prompt (`/metis:reconcile`, `/metis:walk-open-items`, `/metis:build-spec`, `/metis:sync`, `/metis:log-work`, `/metis:epic-breakdown`, `/metis:epic-retro`). The prompt is ephemeral; it is never persisted to disk.

### Subagent composition with skills

The relationship:

- **Subagent** = container (system prompt, tools, identity)
- **Skills** = capabilities invoked within the subagent's context

A subagent's system prompt references skills it should use. Skills activate within the subagent's fresh context and guide its behavior. This is why the skill list above maps to subagent use: most skills get invoked *within* subagents, not by the parent agent.

---

## Example flows

### Epic mode, docs-first, greenfield

The canonical Metis flow.

**Setup** (fresh instance per step):

1. `/metis:init` → choose epic mode
2. `/metis:reconcile` → synthesis + contradictions
3. `/metis:walk-open-items` → resolve each contradiction and open question, populate `decisions/`
4. `/metis:build-spec` → `BUILD.md`
5. `/metis:epic-breakdown` → propose epics, user edits, commit
6. `/metis:generate-tasks 001-<name>` → task files for first epic only
7. `/metis:skeleton-plan` → plan the end-to-end slice
8. Implement the skeleton directly

**Feature loop** (repeats per task):

9. `/metis:session-start`
10. `/metis:pick-task`
11. `/metis:plan-task 0007` → review plan
12. `/metis:implement-task 0007`
13. `/metis:review-task 0007`
14. `/metis:scope-check`
15. Merge
16. `/metis:session-end`

Occasionally: `/metis:rebaseline`, `/metis:pushback`.

**Epic boundary** (once per finished epic):

17. `/metis:epic-retro 001-<name>`
18. `/metis:scratch-cleanup`
19. `/metis:generate-tasks 002-<name>` → start next epic

**Mid-stream addition**: `/metis:feature "..."` when new requirements emerge.

### Flat mode, docs-first

For medium projects.

1. `/metis:init` → flat mode
2. `/metis:reconcile` (skip if `docs/` is thin)
3. `/metis:walk-open-items` (skip if no open items)
4. `/metis:build-spec`
5. `/metis:generate-tasks` (no arg in flat mode)
6. `/metis:skeleton-plan`, implement skeleton
7. Feature loop (same as epic mode, no epic ceremony)
8. Periodic `/metis:rebaseline`, `/metis:scratch-cleanup`
9. `/metis:promote-to-epics` if project outgrows flat

### Flat mode, prompt-seeded, no docs

Weakest mode but supported.

1. `/metis:init` → flat mode
2. `/metis:build-spec "a task-tracking app with auth, teams, and weekly digest emails"` → agent asks clarifying questions, produces `BUILD.md`
3. `/metis:generate-tasks`
4. Skeleton + feature loop as above

### Existing codebase, no docs

Simplified in v0.1 (no dedicated `/metis:explore`). Relies on Claude Code's native exploration.

1. `/metis:init` → flat or epic mode
2. `/metis:build-spec "add SSO and billing on top of the existing codebase"` → agent explores the codebase natively, reads relevant code, asks clarifying questions, produces `BUILD.md` describing what to build (not what exists)
3. `/metis:generate-tasks`
4. Feature loop — each task's `docs_refs` can point at code paths as well as docs

---

## Design decisions already made

These were worked through in conversation and shouldn't be re-opened unless new information emerges.

### On framework positioning

- **Metis is a toolset, not a workflow.** Its value is context maintenance across sessions — a fresh agent can read on-disk state and know where the project stands. The engineering-loop commands (plan/implement/review) are optional.
- **Targeting engineers with large doc-heavy projects.** Explicit audience.
- **"Structure the project, not the agent"** is the load-bearing principle.
- **Seven opinions are the spine**: structure-project-not-agent; Metis-is-optional; docs-before-code when docs exist; task-scoped-context (including parent `EPIC.md` in epic mode); fresh-instances-at-boundaries; append-only-decisions; context-efficiency.
- **The user retains full control.** Every artifact Metis produces can be hand-edited. Reconciliation (`/metis:sync`, `/metis:log-work`) absorbs user edits rather than fighting them.
- **Context efficiency is a design constraint, not a polish task.** Skills, subagents, commands, and conventions are each authored under a token budget. Each layer loads only the slice of the conventions it actually needs.
- **Not building cross-harness support in v0.1.** Claude Code only.
- **Not building lite/heavy modes.** Metis is the heavy-structure option; people who want lighter should use something else.

### On modes

- **Two modes: flat and epic.** Determined at `/metis:init`.
- **Flat is default.** Epic is opt-in via flag at init or graduation via `/metis:promote-to-epics`.
- **No sub-epics.** Subtasks live as checklists inside task files. If a "subtask" deserves its own file, it's actually a task.
- **Mode stored in `.metis/config.yaml`.** Commands check mode and error with helpful alternatives when invoked wrong.

### On commands

- **All commands namespaced `/metis:*`** to avoid collisions.
- **`/metis:init` is non-destructive.** Uses delimited sections in `CLAUDE.md` and `.gitignore`. Preserves existing content.
- **`/metis:generate-tasks` takes an arg in epic mode, no arg in flat mode.** Errors on mismatch.
- **`/metis:init` is run last in build order** because it scaffolds everything else; knowing what "everything else" looks like helps.
- **Commands are thin wrappers over skills and subagents.** ~30–80 lines each. Heavy lifting in skills and conventions.

### On directory layout

- **`.metis/` holds framework scaffolding only** (config, conventions, templates).
- **Project-root holds project's own truth** (`BUILD.md`, `tasks/` or `epics/`, `decisions/`, `docs/`, `scratch/`).
- **Test for placement**: "would a user care about this if Metis didn't exist?"
- **`.claude/` is harness-specific** (commands, agents, skills). Future harnesses would have `.codex/`, etc.
- **`BUILD.md` is always forward-looking** — what we're building. Never backward-looking (what exists). Existing-codebase mode would need a separate artifact (deferred to v0.2).

### On workflow

- **Phase 0 through Phase 2 are separate fresh instances.** Resume within a phase, not across. State survives via committed files, not session transcripts.
- **Phase 0 reconciliation is main-agent by default.** Subagents are scalpels for compressing single dense docs or mechanical consistency sweeps, not for the reconciliation itself.
- **Hybrid Phase 0 threshold**: 80k tokens total `docs/` size. Under 80k, main agent reads everything. 80k–150k, hybrid. Over 150k, hybrid mandatory + probably prune `docs/`.
- **Token estimation**: `wc -w × 1.3` for prose, × 1.5 for mixed, × 1.8 for schema/code-heavy.
- **Fresh Claude Code instance per phase.** State on disk, not in transcript. `/clear` is the closest thing to "new instance without restarting."
- **Generate task files for the first epic only** after epic breakdown. You'll learn from the first epic things that should change how later epics are broken down.

### On subagents

- **Three subagents in v0.1**: `task-planner`, `task-implementer`, `task-reviewer`.
- **Tool restrictions enforce workflow properties.** Planner can't edit code. Reviewer is read-only. Implementer can't write to `BUILD.md`/`BOARD.md`/etc.
- **Two-stage review** (implementer + reviewer, both fresh contexts) is standard for non-trivial tasks.
- **Subagent briefs are self-sufficient.** Task file + CLAUDE.md + referenced docs + parent `EPIC.md` (in epic mode) is enough context. If it's not, the task file is underspecified.

### On skills vs conventions

- **Conventions = what** (schemas, formats, rules). Static reference.
- **Skills = how** (judgment, patterns, best practice). Applied know-how.
- **Skills reference conventions.** Users and agents can read either.

### On existing codebases

- **No `/metis:explore` in v0.1.** Claude Code's native exploration is used via `/metis:build-spec` with a prompt.
- **No `docs/SYSTEM.md`-style artifact in v0.1.** Agent explores on demand per task.
- **`/metis:explore` and dedicated existing-codebase artifacts are v0.2 targets.**

### On prompts

- **Fresh-instance prompts need explicit load blocks.** Same-instance prompts can reference prior conversation.
- **Every prompt specifies what NOT to read** as much as what to read.
- **Demand real output, not claims** ("show me test output" not "run the tests").
- **Ask for self-critique before user critique.**

---

## Build order

Build from the deepest layer outward. Each layer depends only on what's below it. **Complete each layer in full before starting the next.**

### Order

1. **Conventions** (5 files). Everything else depends on these: `task-format.md`, `epic-format.md`, `decision-format.md`, `frontmatter-schema.md`, `write-rules.md`.
2. **Templates** (3 files). Directly instantiate the conventions — `task.md`, `epic.md`, `decision.md` — and serve as canonical starting points for each artifact type. Built immediately after conventions because writing the templates solidifies the convention spec by making it concrete.
3. **Skills** (12 skills). The substance of agent behavior. Each skill is a directory with `SKILL.md` plus an `examples/` folder. Examples are critical — skills without examples are hand-wavy.
4. **Subagents** (3 subagents). Containers that compose skills + tool restrictions: `task-planner`, `task-implementer`, `task-reviewer`.
5. **Commands** (22 commands). Thin wrappers that dispatch subagents or invoke skills. **Within this step, `/metis:init` is built last** because it scaffolds everything else; knowing what "everything else" looks like helps.

### Why layer-by-layer instead of vertical slice

An earlier draft of this section recommended building the smallest vertical slice first (one convention + one skill + one command) to validate the convention → skill → command relationship before investing in 22 commands. That approach was considered and rejected in favor of the layer-by-layer order above. The reasons:

- Per-layer focus is cleaner and less context-switchy than bouncing between convention, skill, and command authoring.
- Writing each layer as a coherent set produces stronger internal consistency (the 5 conventions naturally feel like a family when written together; same for the 12 skills).
- The conventions and templates layers are essentially zero-risk because they're pure spec — build them in full and cash in the cohesion benefit immediately.

The tradeoff being accepted: if the convention → skill → command relationship has a structural flaw, it surfaces after writing 5 conventions + 3 templates + 12 skills + 3 subagents rather than after one of each. Mitigations: most of these files are short and well-specified by this document, the structural risk is real but bounded, and refactoring skills when the first command lands is a tolerable cost.

If the first command lands and reveals a shape change, expect to revisit some skills. Treat that as expected, not as a failure.

### Within-layer ordering hints

Inside each layer, dependency order still matters for a few specific items:

- **Conventions**: `frontmatter-schema.md` before `task-format.md` and `epic-format.md` (they reference it). `write-rules.md` last (it encodes cross-file rules that depend on understanding the other formats).
- **Templates**: Any order; they're peers.
- **Skills**: `writing-decisions` early (other skills reference it). `reconciling-docs` is the heaviest skill; budget accordingly.
- **Subagents**: Any order; they're peers once the skills they reference exist.
- **Commands**: `/metis:init` last (scaffolds everything). Otherwise any order, though grouping by workflow phase (setup → planning → feature loop → sessions → change management → epic boundaries → maintenance) is a sensible default.

---

## What's deferred to v0.2+

Explicitly out of scope for v0.1, to keep the shipping bar reasonable.

- **`/metis:explore`** and a dedicated `docs/SYSTEM.md` or `docs/ARCHITECTURE.md` artifact for existing-codebase synthesis. v0.1 handles existing codebases via prompt-seeded `/metis:build-spec` and agent-on-demand exploration.
- **`/metis:architect-pass`** — fresh-context architectural review at epic boundaries. Valuable but not critical for v0.1.
- **Cross-harness support** (Codex, OpenCode, Cursor, etc.). v0.1 is Claude Code only.
- **Plugin marketplace distribution.** v0.1 is clone-and-run.
- **A dedicated `doc-reconciler` subagent** for very large doc sets. v0.1 uses main agent + ad hoc subagents for compression.
- **Additional skills** like `writing-code-well`, `test-discipline`. v0.1 trusts the agent's defaults for these. Add when real usage reveals inconsistency.
- **`/metis:uninstall`** command. v0.1 users can manually delete per the MANIFEST.
- **Web dashboard, analytics, telemetry.** None in v0.1.

These aren't rejected — they're deferred. The rough order of v0.2 priorities would be: `/metis:explore` → `/metis:architect-pass` → cross-harness → everything else.

---

## Open questions

Things not fully decided. Worth addressing when building.

1. **Should `/metis:init` interactively ask questions, or take flags?** e.g. `/metis:init --mode=epic --name="MyProject"` vs. interactive Q&A. Leaning interactive for first-time users, with flags for power users.

2. **How should `BOARD.md` be generated?** Options: regenerated on-demand by a command, regenerated automatically on task status changes (hook?), or hand-updated. Leaning toward "regenerated on-demand by a new `/metis:refresh-board` command or as a side effect of other commands" — but this is unspecified.

3. **Where exactly do plans live during `/metis:plan-task` → `/metis:implement-task`?** Current assumption: `scratch/plans/<id>.md`, gitignored. Confirm this is right.

4. **Should `/metis:feature` produce a feature spec file, or inline the feature description into task files?** Probably a spec file at `features/NNN-<name>.md` in flat mode, and a new epic in epic mode. But the exact file vs inline trade-off wasn't fully worked through.

5. **How to handle `/metis:generate-tasks` regeneration?** ~~If tasks exist already and user runs it again (e.g., after editing BUILD.md), does it refuse, merge, or replace?~~ **Partially resolved** by the post-handoff refinements: `/metis:sync` now handles the "spec changed, cascade to tasks" case explicitly, so `/metis:generate-tasks` can simply refuse regeneration and point users to `/metis:sync` for edits or `/metis:feature` for additions.

6. **What about task revision?** ~~If a task is half-done and the spec changes, how does Metis handle it?~~ **Resolved** by `/metis:sync`. Cascade rules by status: `done` tasks don't update in place (changes become new tasks or superseding decisions); `pending` / `in-review` can be edited in place; `in-progress` requires explicit confirmation.

7. **Should there be a `/metis:status` command?** Just a quick "where are we, what's blocked, what's the next thing" overview. Might be subsumed by `/metis:session-start` or `BOARD.md`. Undefined.

8. **The name "features/"** directory in flat mode vs. tagging tasks with `feature: NNN-<name>` frontmatter. Tagging feels cleaner (keeps the structure flat) but features being first-class files makes them easier to find. Unresolved.

9. **Token estimation for `/metis:reconcile` decision.** Should Metis automatically count tokens and choose between main-agent and hybrid modes, or should it prompt the user? Probably the former, with a manual override flag.

10. **Subagent output persistence.** When a subagent returns its summary, where does it go? Inline in the parent's chat? Appended to the task file? Both? Spec this out when building.

11. **Is `/metis:sync` aggressive or explicit?** Should it auto-detect drift at every `/metis:session-start`, or only run when the user explicitly invokes it? Leaning explicit (ambient alerts are fatiguing), with a light session-start banner like "looks like `docs/` changed since last session, want to run `/metis:rebaseline`?"

12. **Does `/metis:log-work` require task names, or infer them from the diff?** Inference is nicer ergonomically but can go wrong quietly. Leaning "name the tasks, agent verifies against diff."

13. **Are the names `/metis:sync` and `/metis:log-work` final?** `/metis:sync` is a bit generic; alternatives: `/metis:propagate-changes`, `/metis:reconcile-drift`. `/metis:log-work` alternatives: `/metis:record-work`, `/metis:catch-up`.

14. **Does the optional-prompt convention apply to every command, or only substantive ones?** Leaning "every command where the agent does real thinking" — excludes mechanical ones like `/metis:pick-task`, `/metis:session-start`, `/metis:scratch-cleanup`. Also fine to say "all commands accept an optional prompt; most of them just ignore it if it doesn't apply."

---

## How to pick up from here

If you're a new Claude conversation reading this to continue the work:

**Where to start**: Layer by layer, per §14. Build all 5 conventions first, then all 3 templates, then all 12 skills (with examples), then all 3 subagents, then all 22 commands (with `/metis:init` last). Propose a concrete plan for the current layer before writing, and surface any ambiguity against the doc as you go.

**What to reference**:

- This document as the canonical source of design decisions.
- [Claude Code docs on custom commands](https://code.claude.com/docs/en/slash-commands) for the command file format.
- [Claude Code docs on skills](https://code.claude.com/docs/en/extend-claude-code) for skill file format.
- [Claude Code docs on subagents](https://code.claude.com/docs/en/subagents) for the agent file format.

**What NOT to do**:

- Don't re-open the positioning questions unless you have new information. The five principles are set.
- Don't add more commands to v0.1 than the 22 listed. Scope creep kills v0.1.
- Don't try to build cross-harness support yet. Claude Code only.
- Don't implement `/metis:explore` yet. It's v0.2.
- Don't implement a lite mode. Metis is the heavy option.

**What to focus on**:

- Completing the current layer cleanly before starting the next.
- Dogfooding Metis on one real project after v0.1 is built. This is the only real validation.
- Writing out examples in each skill directory. Examples make skills concrete.
- Keeping command files thin. If a command is >100 lines, its skill isn't pulling its weight.

**How to handle disagreement**:

If something in this document seems wrong as you build, that's fine — the design isn't sacred. But document the change explicitly (update this doc, or write a `decisions/` entry in the Metis project itself). Silent drift from the design is the failure mode.

**The final principle worth internalizing**:

Metis is an opinionated tool for a specific audience. Its value comes from its opinions. Don't make it generic. If a design choice feels like it's trying to please everyone, it's probably wrong.

---

## Refinements (post-handoff design conversation)

The sections above describe the v0.1 design as it stood at the close of the original design conversation (20 commands / 10 skills / 5 conventions / 3 subagents). A subsequent design pass surfaced two structural gaps and three behavioral refinements. Those changes have been folded into the canonical sections above; this section preserves the rationale so future readers can understand *why* — not just *what*.

The net manifest impact of all refinements: **+2 commands, +2 skills, no new conventions, no new subagents.** Final manifest: 22 / 12 / 5 / 3.

### Refinement 1 — Change management as a first-class concern

The original v0.1 design was implicitly one-directional: docs flow into `BUILD.md`, into epics, into tasks. The only feedback mechanism was `/metis:feature` for net-new additions. That's not enough — three change-propagation cases need explicit handling:

- **Case A — User edits a doc in `docs/`.** Most common, most dangerous, because the drift is silent. The doc change invalidates the premise of any downstream artifact that referenced it (`BUILD.md`, epics, task files via `docs_refs`). Without a detection mechanism, nothing notices.
- **Case B — User edits `BUILD.md` directly.** They've rethought architecture or scope. Epics and tasks beneath it may now be wrong.
- **Case C — User edits an epic or task file directly.** Localized, but can still cascade (e.g., changing an epic's scope changes what tasks belong under it).

Resolution: keep `/metis:rebaseline` as the read-only detector with real teeth (compares against a baseline using git markers + frontmatter `doc_hash` / `spec_version`), and add **`/metis:sync`** as the write counterpart that walks proposed cascading updates one at a time. Every accepted change appends a `decisions/` entry. Never auto-applies.

`/metis:sync` is **main-agent work, not subagent work** — it's cross-document reasoning, same category as Phase 0 reconciliation. A subagent can't see the whole picture.

Sub-decisions that follow:

- Task files need `doc_hashes` and `spec_version` in frontmatter so drift can be detected per task without re-reading everything.
- The cascade needs termination rules. Ten tasks downstream of one doc change shouldn't all be walked interactively — batch "these five look like simple text updates, approve as a group?" vs. "these two look substantive, let's walk them one at a time."
- Tasks that are `done` don't update in place — changes either become new tasks or decision entries that supersede. `pending` / `in-review` can be edited directly. `in-progress` requires explicit confirmation because someone's actively working on it.

This refinement also retires open question #6 (task revision when spec changes) by giving it a command, and partially closes #5 (task regeneration).

### Refinement 2 — Logging work done outside Metis

Metis must never *require* the user to route through its commands. Users will write code by hand — bugfixes, refactors, spikes, hotfixes — and Metis's view of the project will silently diverge from reality unless it has a catch-up command.

**`/metis:log-work [task-ids] <description>`**:

```
/metis:log-work 0007,0009 "Refactored the webhook handler to use the
new event schema. Task 0007 is done. Task 0009 I split into two —
the retry logic was bigger than expected; created 0011 for it."
```

The agent then:

1. Runs `git diff` on the relevant branch to see what actually changed.
2. Updates task file statuses and appends Notes sections combining the user's description with what the diff shows.
3. If the user says "done," verifies acceptance criteria against the diff (lightweight `/metis:review-task` pass).
4. If the user says "I split / added / merged tasks," handles the task-file CRUD.
5. If the diff touches architecture-level concerns, prompts for a decision entry.
6. Reports back any mismatch between what the user described and what the diff shows.

The key property: **the user's natural-language description is the source of truth for intent; `git diff` is the source of truth for what happened.** The command reconciles them and asks if there's daylight between them.

With no task argument, `/metis:log-work` creates a retroactive task file in `done` state with the description and diff as context — keeps the ledger complete without forcing users to pre-plan work they ended up doing ad hoc.

### How `/metis:sync` and `/metis:log-work` interact

Both commands reconcile external changes against Metis state. The split:

- **`/metis:sync`** reconciles *spec* drift (what we intend to build has changed)
- **`/metis:log-work`** reconciles *implementation* drift (what we've actually built has diverged from what's logged)

They likely share a "drift report" helper inside `propagating-spec-changes` and `logging-external-work` skills, but as user-facing commands they are different workflows and should not be merged.

Why these are worth doing in v0.1 rather than deferring: the whole point of Metis is that it holds up on a real project. A framework that assumes specs are stable and all work flows through its commands will be trusted until week one and then distrusted forever.

### Refinement 3 — `/metis:reconcile` covers gray areas, not just contradictions

The original `/metis:reconcile` was scoped to contradictions only. But contradictions and gray areas are different categories of doc problem:

- A **contradiction** is two specified things disagreeing (doc A says X, doc B says Y) — forces a *choice*.
- A **gray area** is one thing underspecified (doc says X but doesn't specify Y, or uses a term in a way that could mean two things) — forces a *specification*.

Both must be closed before coding. They get separate output files because the framing differs: `CONTRADICTIONS.md` entries cite both sides of the disagreement; `QUESTIONS.md` entries cite the ambiguous passage and articulate what's unclear. The `reconciling-docs` skill teaches both detection patterns.

Phase 0's exit criterion is now "`CONTRADICTIONS.md` and `QUESTIONS.md` are both empty (or consciously deferred)" rather than just contradictions.

The follow-on rename: `/metis:walk-contradictions` → **`/metis:walk-open-items`**. More honest than stretching "contradictions" to cover ambiguity.

### Refinement 4 — Walk-open-items offers genuine alternatives, not just dumps items

For each item, the agent offers **1–2 suggested resolutions** plus a free-form user-input option. This turns Phase 0 from "user sits and explains every decision from scratch" into "user confirms or redirects the agent's read." It's also a forcing function: the agent must do real thinking rather than dumping items back at the user.

Per-item UX:

```
Item 3 of 12 (question): Session duration

docs/auth.md says sessions "persist across browser restarts"
but docs/security.md mentions "short-lived tokens."
Duration is unspecified.

Agent's read:
  A) 30-day refresh token + 15-min access token. This is the common
     pattern that satisfies both passages — persistent across restarts
     via refresh, short-lived at the access layer.
  B) 7-day session with sliding expiration. Simpler, single token,
     matches "persist across browser restarts" more literally but
     less consistent with "short-lived tokens."

Your options:
  [A] go with A
  [B] go with B
  [C] your own answer (type it)
  [S] skip / defer
  [Q] quit the walk (resume later)
```

Two discipline points the `reconciling-docs` skill must teach:

- The agent's suggestions need to be **genuine alternatives** (not one real option and a straw man).
- For genuinely unclear items, the agent must be allowed to say "I don't have a good read here, need your input" rather than inventing options.

Every resolution writes the chosen answer into the relevant doc *and* appends a decision entry with the reasoning. Skipped items stay in `QUESTIONS.md` / `CONTRADICTIONS.md` for a later pass — they don't disappear.

### Refinement 5 — Walk-open-items resume behavior

The state-on-disk principle handles resume cleanly: **the files themselves are the resume state**, no separate bookkeeping file needed.

Each item gets a small status header:

```markdown
## Q3: Session duration
Status: open
Added: 2026-04-18

docs/auth.md says sessions "persist across browser restarts"
but docs/security.md mentions "short-lived tokens."
Duration is unspecified.
```

Item statuses: `open` (default), `resolved` (moved to `RESOLVED.md`), `deferred` ("not now, but don't bug me about this for a while"), `stale` (referenced doc has changed since item was captured — needs re-consideration; detected via `doc_hash`).

Starting or resuming the walk:

```
/metis:walk-open-items

You have 12 open items remaining (3 contradictions, 9 questions).
4 were resolved in the previous session.

Continue from the next open item, or pick a different starting point?
  [C] continue from Q3
  [L] list all open items
  [N] pick by number
  [Q] quit
```

Three additional pieces:

- New items can appear between sessions. If the user runs `/metis:reconcile` again (because docs changed substantially), new items get appended with `Status: open` — they show up in the next walk naturally.
- The walk supports **non-sequential navigation**. Users often know the answer to item 8 but not item 3. After resolving an out-of-order item, the walk asks "continue to next open item, or pick another?" rather than forcing linearity.
- **Un-resolve** (rare, but possible): leave the `RESOLVED.md` entry alone and add a new open item to the relevant active file that references the superseded decision. Resolution history is preserved; the superseding decision gets its own entry. Same pattern as ADR superseding.

### Refinement 6 — RESOLVED.md archive (don't re-read resolved items)

When the walk resolves an item, the entry is removed from the active file and appended to `docs/RESOLVED.md` as a minimal pointer:

```markdown
## Q3: Session duration
Resolved: 2026-04-19
Decision: decisions/2026-04-19-session-duration.md
Summary: 30-day refresh + 15-min access token.
```

The full reasoning lives in the decision entry, not duplicated in `RESOLVED.md`. This keeps the archive as a lightweight trail — useful if someone wants to scan "what did we resolve during Phase 0?" without grepping all of `decisions/`, but with almost no bytes to load.

**Active files (read during walk):** `CONTRADICTIONS.md` and `QUESTIONS.md` — open and deferred items only.

**`RESOLVED.md` is never read during a walk** unless the user specifically asks. This is the load-bearing property: on resume, the agent's context is just the still-open items + `CLAUDE.md` + referenced doc sections. Resolved items are archival, not contextual.

Deferred items stay in the active files (still "open" from the walk's perspective). Stale items also stay in the active files (need re-consideration). One unified `RESOLVED.md` rather than separate files for contradictions and questions — by the time they're resolved, the distinction doesn't matter much.

This pattern generalizes: anywhere Metis accumulates items-to-work-through (future commands, future queues), resolved items should move to a separate "resolved" file so active work stays lean in context.

### Refinement 7 — Optional invocation prompts as a framework-wide convention

This was originally floated for `/metis:plan-task`, `/metis:implement-task`, `/metis:review-task`, then generalized. Every substantive Metis command accepts an optional free-text prompt that augments its default behavior:

```
/metis:plan-task 0007 "focus on retry semantics; the existing code uses tenacity, follow that pattern"
/metis:implement-task 0007 "skip mocking the webhook endpoint — use a real local test server"
/metis:review-task 0007 "pay close attention to the idempotency logic"
/metis:reconcile "give special weight to docs/billing.md, it's the most recent"
/metis:epic-breakdown "prefer vertical slices over horizontal layers"
/metis:sync "only propagate the auth doc changes, defer the billing ones"
/metis:epic-retro 001-auth "focus on the estimation misses"
```

The reasoning ties to principle #1 ("structure the project, not the agent"). If Metis forbids the user from giving in-the-moment guidance, then Metis *is* the religion you're trying to avoid. The framework provides scaffolding and opinions; it should not dictate how every task is approached.

Three discipline points (codified in `write-rules.md` and the subagent system prompts):

1. **Augment, don't replace.** The prompt augments the task file (or command context); it does not override it. If the prompt genuinely contradicts the task file, flag the conflict and ask.
2. **Flag scope expansion.** If the prompt expands scope, note it in the return rather than silently doing it.
3. **Acknowledge use explicitly.** The return states how the prompt was used. Traceable after the fact.

The prompt is **ephemeral** — never persisted to disk.

Open question (#14 above): does this convention apply to *every* command, or only substantive ones? Leaning "every command where the agent does real thinking" — excludes purely mechanical ones like `/metis:pick-task`, `/metis:session-start`, `/metis:scratch-cleanup`.

### Refinement 8 — Reframing Metis as a context-maintenance toolset

The design to this point was described in workflow language — "the workflow Metis encodes," phases, a per-task feature loop — which made Metis sound like a pipeline the user has to route through. A later review reframed this. The point of Metis is not that the user runs `/metis:plan-task` → `/metis:implement-task` → `/metis:review-task` in order. The point is that at any moment, a fresh agent session can read on-disk state and know the project's intent, status, and history. How code actually got written between sessions is orthogonal.

Concretely:

- **The engineering-loop commands are optional.** The user can code alone, pair with an agent outside Metis, or drive work through Metis — and mix freely. Metis doesn't gate any of this.
- **Every artifact is user-editable.** Task files, epics, `BUILD.md`, `CURRENT.md`, and `docs/` are all fair game for hand editing. Metis's reconciliation commands (`/metis:sync`, `/metis:log-work`) absorb external edits rather than forbidding them.
- **Immutability claims were too strong.** Earlier drafts said task `id` and `title` were immutable; softened to "stable by default — if they change, reconcile via `/metis:log-work` or a resync." Same logic for the "10–30 tasks per epic" rule, which was dropped.
- **The conventions layer is a human/design-time reference.** At runtime, each skill / subagent / command carries only the slice it needs. Conventions files are not bulk-loaded into sessions.
- **Context efficiency is promoted to a load-bearing principle.** Metis should cost less context than the disorder it prevents. "Works but bloated" is a bug.

No manifest changes. The shift is in *framing and discipline*, which is carried through the principles in §4, the workflow section, the conventions descriptions, and the subagent load lists (parent `EPIC.md` added in epic mode).

### Manifest impact of all refinements

| Layer | Before refinements | After refinements |
|---|---|---|
| Commands | 20 | 22 (+`/metis:sync`, +`/metis:log-work`; renamed walk-contradictions → walk-open-items) |
| Skills | 10 | 12 (+`propagating-spec-changes`, +`logging-external-work`; expanded `reconciling-docs`) |
| Conventions | 5 | 5 (no new files; `frontmatter-schema` adds `doc_hashes` + `spec_version`; `write-rules` adds command-prompts convention) |
| Subagents | 3 | 3 (no new subagents; existing ones gain invocation-prompt discipline and load parent `EPIC.md` in epic mode) |

---

## Appendix: the conversation that produced this

This document distills a long design conversation. Key moments worth knowing about, in case they help ground future discussions:

- The initial framing was "how do I go from a `docs/` directory to a working product with an agent." This grew into the four-phase workflow.
- Task files, task-scoped context, and subagent dispatch emerged as the solution to context management on large projects.
- The decision to build a framework (rather than adopt an existing one) came after evaluating Superpowers, gstack, and GSD and identifying a real gap: none of them take docs-first seriously.
- "Structure the project, not the agent" came late in the design — it's what differentiates Metis from existing rigid frameworks.
- The two-mode (flat/epic) design replaced an earlier plan for a single "medium/large" distinction.
- `.metis/` as a directory for framework scaffolding was chosen to keep project artifacts first-class at the root.
- Namespacing commands as `/metis:*` was a deliberate choice after recognizing collision risk with Claude Code built-ins.
- The v0.1 scope was repeatedly trimmed as features were added. Initial post-handoff scope was 20 commands / 10 skills / 5 conventions / 3 subagents. A subsequent design pass (see "Refinements" section) added two change-management commands (`/metis:sync`, `/metis:log-work`) and two supporting skills, bringing the manifest to 22 / 12 / 5 / 3.

The last meaningful decision before this handoff: Metis v0.1 manifest. Ready to build.
