# Metis

> *Wisdom before code.*

A docs-first agentic development framework for Claude Code, built around **context management across sessions** as the hard problem.

Metis structures the project, not the agent — it gives Claude direction, order, and context on disk rather than trying to reshape how Claude thinks or writes. At any moment, a fresh agent session can read Metis's on-disk state and know exactly where the project stands: what's planned, what's in progress, what's done, what was decided, and why.

---

## Contents

- [What Metis is](#what-metis-is)
- [Who it's for](#who-its-for)
- [Principles](#principles)
- [Installation](#installation)
- [The workflow](#the-workflow)
- [Project layouts](#project-layouts)
- [The skill set](#the-skill-set)
- [Subagents](#subagents)
- [Patterns](#patterns)
- [When to use the less-obvious skills](#when-to-use-the-less-obvious-skills)
- [Reference](#reference)

---

## What Metis is

A filesystem layout, a set of skills, and a small library of subagents and references — all designed so the next agent session can rehydrate cleanly from disk.

What you get on disk:

- **`BUILD.md`** — the project's forward-looking architecture brief.
- **`tasks/`** or **`epics/`** — the task backlog (flat or capability-grouped).
- **`decisions/`** — append-only ADR log spanning epics and sessions.
- **`docs/`** — source material (your specs), plus reconcile artifacts (`SYNTHESIS.md`, `INDEX.md`, `CONTRADICTIONS.md`, `QUESTIONS.md`, `RESOLVED.md`) and `docs/research/` notes.
- **`scratch/`** — ephemeral session state; `CURRENT.md` is the resume point.
- **`.metis/`** — framework scaffolding (config, conventions, templates, scripts).

What you get as skills: 21 skills under `/metis:*`. Some produce those artifacts; some reconcile them when you've worked outside Metis.

The spine of Metis is **the artifacts and the reconciliation mechanisms**, not the engineering loop. The plan/implement/review skills are an option Metis offers, not a requirement. You can code alone, pair with an agent without invoking any Metis skills, drive work through the loop, or mix all three. Metis's reconciliation skills (`/metis:sync`, `/metis:log-work`, hand-editing followed by a resync) absorb your edits rather than fighting them.

---

## Who it's for

Engineers using Claude Code on projects where state needs to survive across sessions — typically medium-to-large projects that start with a pile of documentation (UX requirements, design docs, technical specs) and that multiple sessions will return to.

If the work is a throwaway prototype, a one-session script, or something you won't return to: **Metis is the wrong tool.** The structure pays off when sessions need to rehydrate; without that, it's overhead.

---

## Principles

The load-bearing opinions. Everything else is convention that can flex.

1. **Structure the project, not the agent.** Metis provides artifacts, conventions, and reconciliation. The agent decides how to solve each task. No TDD enforcement, no persona role-play, no prescribed reasoning steps.

2. **Optional at every step; reconciles, does not enforce.** Every artifact Metis produces can be hand-edited at any time. Reconciliation skills exist to absorb your edits, not prevent them.

3. **Docs before code, when docs exist.** On a doc-heavy project, reconciling first pays for itself — the agent reads `docs/`, surfaces contradictions and gaps, and you walk through them before building. This is Metis's strongest recommendation, but a recommendation, not a gate.

4. **Context is task-scoped, not project-scoped.** Every task file is self-sufficient. Subagents work from a task file plus `CLAUDE.md`, the referenced docs, and the parent epic when one exists — never from other task files or `BUILD.md`.

5. **Fresh instances at phase boundaries.** Resumption is for continuity within a phase, not across them. Starting a new phase in a fresh Claude Code instance drops accumulated context that would otherwise compound into drift.

6. **Decisions are append-only and span the project.** Not buried in task files. `decisions/` is the project's memory across epics and sessions. Superseding happens by writing a new decision, not by editing the old one.

7. **Token economy is load-bearing.** Skills are thin routers; references carry the reasoning; subagents have scoped tools. A typical Metis invocation loads one skill (~300 words) plus one reference (~1,000 words) — small enough that running Metis is cheaper than the disorder it prevents.

---

## Installation

Metis ships as a Claude Code plugin. Two install paths:

**Via the marketplace** (recommended if you might want other plugins from the same author):

```
/plugin marketplace add gsaranti/Metis
/plugin install metis@metis-marketplace
```

**Direct install:**

```
/plugin install gsaranti/Metis
```

Then run `/metis:init` once per project to scaffold project-specific files (config, scratch starters, the `docs/research/` index, delimited blocks in `CLAUDE.md` and `.gitignore`). Init is non-destructive — existing files are only modified between Metis's delimiters.

After init, type `/metis:` in Claude Code to see the full skill set.

---

## The workflow

Metis encodes a canonical flow for a doc-heavy greenfield project:

```
Phase 0 — Reconcile docs    →   /metis:reconcile
                                /metis:walk-open-items
Phase 1 — Build spec        →   /metis:build-spec
         + backlog              /metis:epic-breakdown   (or /metis:generate-tasks for flat)
                                /metis:generate-tasks <epic>
Phase 2 — Skeleton          →   /metis:skeleton-plan
                                (implement directly)
Phase 3 — Feature loop      →   /metis:pick-task
                                /metis:plan-task <id>
                                /metis:implement-task <id>
                                /metis:review-task <id>
                                /metis:scope-check
                                merge
```

Sessions wrap around the phases:

```
/metis:session-start    →    rehydrate from CURRENT.md
... work ...
/metis:session-end      →    update CURRENT.md
```

And reconciliation skills keep state honest when you've worked outside the flow:

```
hand edits to docs       →   /metis:rebaseline   →   /metis:sync
hand-coded a feature     →   /metis:log-work "<description>"
mid-stream new feature   →   /metis:feature "<description>"
```

Phase boundaries are best started in fresh Claude Code instances. Each phase's artifacts are designed to rehydrate a fresh agent quickly.

---

## Project layouts

Two structural shapes. The shape is **emergent from disk** — there's no mode flag.

**Flat layout** — for medium projects, ~10–40 tasks, no capability grouping needed:

```
tasks/
  0001-*.md
  0002-*.md
  ...
```

**Epic layout** — for larger projects with capability clusters:

```
epics/
  001-authentication/
    EPIC.md
    tasks/
      0001-*.md
      ...
    retro.md
  002-billing/
    ...
```

A project that runs `/metis:generate-tasks` (with no argument) becomes flat. One that runs `/metis:epic-breakdown` becomes epic. `/metis:promote-to-epics` graduates a flat project that's outgrown the format.

---

## The skill set

21 skills, all namespaced as `/metis:*`. Grouped by phase / role:

### Setup

- **`/metis:init`** — scaffold the framework directories and CLAUDE.md/gitignore blocks. Run once per project. Non-destructive.

### Phase 0 — Reconcile docs

- **`/metis:reconcile`** — read `docs/`, produce `SYNTHESIS.md` (own-words summary), `INDEX.md` (concept → file map), `CONTRADICTIONS.md` (direct conflicts between docs), `QUESTIONS.md` (gray areas, silences, ambiguities).
- **`/metis:walk-open-items`** — walk through open items one at a time. Agent offers 1–2 alternatives, a recommendation, or asks. Each resolution updates the source doc and moves the item to `RESOLVED.md`. Supports stop/resume across sessions.

### Phase 1 — Build spec + backlog

- **`/metis:build-spec`** — produce `BUILD.md` from the reconciled corpus (or from a prompt for prompt-seeded / existing-codebase projects). Risk-first framing, names a first vertical slice.
- **`/metis:epic-breakdown`** — propose 8–15 epics from `BUILD.md` and scaffold `epics/`. Refuses if a flat `tasks/` already exists.
- **`/metis:generate-tasks [epic]`** — generate task files. With an epic name, populates `epics/<name>/tasks/`. Without, populates flat `tasks/`. Errors if the argument shape doesn't match what's on disk.

### Phase 2 — Skeleton

- **`/metis:skeleton-plan`** — plan the thinnest end-to-end slice (one route, one screen, one DB write, one passing test). Read-only; you implement the skeleton directly.

### Phase 3 — The engineering loop (optional)

- **`/metis:pick-task`** — list unblocked, prioritized tasks with a suggested next.
- **`/metis:plan-task <id>`** — dispatch the `task-planner` subagent. Produces `scratch/plans/<id>.md`. No code.
- **`/metis:implement-task <id>`** — implement the task in the main session. Loads only the task file, parent `EPIC.md`, the approved plan if present, the docs in `docs_refs`, and the code being changed. Closes with a scope report.
- **`/metis:review-task <id>`** — dispatch the `task-reviewer` subagent. Reviews the diff against acceptance criteria. Returns `approve` / `approve-with-nits` / `reject-with-reasons` with per-criterion evidence.
- **`/metis:scope-check`** — enumerate what was skipped, deferred, stubbed, or handled differently. No defenses. Optional probe before review or merge.

The loop is one option. Any task can be coded by hand and reconciled later via `/metis:log-work`. Hand-edits to task files are equally legitimate; Metis reads from disk and trusts what it finds.

### Sessions

- **`/metis:session-start`** — fresh-instance loading dose. Loads `CLAUDE.md`, `scratch/CURRENT.md`, the active task file. Tells you where to start.
- **`/metis:session-end`** — update `scratch/CURRENT.md` with the four-block handoff (what happened, current state, open questions, where to start). Prune `questions.md`.

### Reconciliation (when you work outside the loop)

- **`/metis:rebaseline`** — drift detector. Read-only. Compares current state of `docs/`, `BUILD.md`, and the task/epic set against stored baselines (`doc_hashes`, `spec_version`). Reports what changed and which artifacts reference it.
- **`/metis:sync`** — write counterpart to rebaseline. Walks proposed cascading updates one at a time when source docs or `BUILD.md` have shifted (doc change → propose `BUILD.md` edit → propose epic edits → propose task edits). Every accepted change appends a `decisions/` entry. Status-aware: `done` tasks become new tasks or superseding decisions, `pending` tasks edit in place.
- **`/metis:log-work [task-ids] <description>`** — record code work you did outside Metis. Runs `git diff`; your description is the source of truth for intent, the diff for what happened. Updates statuses, appends Notes, handles task CRUD (split/merge/add). With no task argument, creates a retroactive `done` task.

### Mid-stream and maintenance

- **`/metis:feature <description>`** — describe a new feature mid-stream. Produces task files (flat) or a new epic with its task set (epic layout).
- **`/metis:promote-to-epics`** — graduate a flat `tasks/` project into an epic layout. Groups existing tasks into proposed epics, moves files, updates frontmatter.
- **`/metis:epic-retro <epic>`** — write `retro.md` for a finished epic. Per-task estimation entries, replans with prevention signal, assumption failures, task-breakdown lessons.

### Discipline

- **`/metis:pushback`** — ask the agent to defend its most recent substantive choice. Three beats: state the call plainly, name the alternatives, surface the weakness. If the agent can't render all three, it concedes — the choice was under-justified.

---

## Subagents

Four subagents, each with scoped tool restrictions that enforce workflow properties structurally.

- **`task-planner`** (Read/Glob/Grep/Write/Task) — read one task file, produce one plan at `scratch/plans/<id>.md`. Tool-restricted to writing only plan files; can't start implementing while planning. Can dispatch `code-explorer` and `domain-researcher` mid-plan.

- **`task-reviewer`** (Read/Glob/Grep/Bash/Write) — review one diff against one task's acceptance criteria. Bash for `git diff` and verification commands only — no mutating commands. Read-only against code; can't "helpfully fix," must report findings. Appends a verdict block to the task's Notes.

- **`domain-researcher`** (Read/Glob/Grep/WebSearch/WebFetch/Write) — investigate one technical question against the open web. Writes a research note to `docs/research/<slug>-<date>.md` with options, tradeoffs, and a recommendation tagged with confidence. Auto-dispatched by the skills that need a fact the corpus doesn't settle (`/metis:walk-open-items`, `/metis:build-spec`, `task-planner` mid-plan).

- **`code-explorer`** (Read/Glob/Grep, no Write) — investigate one question against the existing source tree. Returns a compressed report inline: answer, file:line evidence, seams, surprises, boundary. Nothing persists. Auto-dispatched in existing-codebase mode by `/metis:build-spec`, by `/metis:generate-tasks` per task whose surface isn't fully named, and by `task-planner` for unfamiliar surfaces.

The pattern: heavy reads happen in fresh subagent context; the parent's context grows by the synthesized report, not by everything the agent read to make it.

---

## Patterns

End-to-end skill sequences for common situations.

### Greenfield, docs-first

You have a `docs/` directory with specs that contradict each other in places.

```
/metis:init
/metis:reconcile               ← read docs/, surface contradictions and gaps
/metis:walk-open-items         ← resolve them one at a time
/metis:build-spec              ← BUILD.md from the reconciled corpus
/metis:epic-breakdown          ← propose epics, edit, commit
/metis:generate-tasks 001-foundation
/metis:skeleton-plan
... implement skeleton ...

# Then per task:
/metis:session-start
/metis:pick-task
/metis:plan-task 0007
/metis:implement-task 0007
/metis:review-task 0007
/metis:scope-check
... merge ...
/metis:session-end
```

### Prompt-seeded (no docs)

You're starting from an idea, not a corpus.

```
/metis:init
/metis:build-spec "<one-paragraph description>"
/metis:generate-tasks          ← flat layout for a small project
/metis:skeleton-plan
... continue with feature loop or hand-code ...
```

### Existing codebase, adding new work

You have a real codebase and want to layer Metis structure on a delta.

```
/metis:init
/metis:build-spec "<description of what's being added>"
                                ← code-explorer auto-dispatches per architectural seam
/metis:epic-breakdown           ← (or /metis:generate-tasks for flat)
/metis:generate-tasks 001-...
... feature loop or hand-code ...
```

### Pair programming, mostly hand-coded

You're driving the work yourself; Metis is keeping the record.

```
/metis:init
... write code, edit task files by hand, do whatever ...
/metis:log-work "Finished 0007 (signature verification). Done."
                                ← Metis reconciles your diff against the task file
                                ← updates status, appends Notes, files a decision
                                ← if the diff shifted a BUILD.md commitment
```

### Mid-stream feature

You've shipped a few epics and now need to add something the original spec didn't cover.

```
/metis:feature "Add a billing-history export for admins"
                                ← proposes the new epic + task set, you approve
... feature loop ...
```

### Catching drift after manual work

You hand-edited some docs and want to know what's now stale.

```
/metis:rebaseline               ← tells you what changed and what references it
/metis:sync                     ← walks the cascade with you, one item at a time
                                ← every accepted change writes a decisions/ entry
```

### Graduating to epics

You started flat, the project has grown.

```
/metis:promote-to-epics         ← proposes epic groupings of existing tasks
                                ← moves files, adds epic: frontmatter
                                ← scaffolds EPIC.md per group
```

---

## When to use the less-obvious skills

**`/metis:rebaseline`** — run it routinely between sessions, especially after you've hand-edited docs or `BUILD.md`. Tells you what's drifted before you start a new task and discover it the hard way. Read-only — safe to run anytime.

**`/metis:sync`** — when rebaseline reports drift you want to absorb. Walks proposed cascading edits one at a time; each accepted change writes a `decisions/` entry naming the upstream change and its downstream effects. Status-aware so `done` tasks aren't silently rewritten.

**`/metis:log-work`** — when you've coded outside the Metis loop. The argument is a free-text description of what you did; Metis runs `git diff` and reconciles your description against the diff. If the diff says "done" but the description says "in progress," it surfaces that as daylight rather than picking a side. Architecture-shifting diffs (boundary crossed, new component, schema migration) trigger a `decisions/` entry.

**`/metis:feature`** — when a new feature comes up after the build spec is locked. Avoids the temptation to bolt it onto an existing epic. Produces either a new epic with its task set (epic layout) or just task files (flat).

**`/metis:promote-to-epics`** — when a flat project has grown to ~40+ tasks and capability boundaries are emerging. One-time graduation; after this, treat the project as epic-layout for new work.

**`/metis:pushback`** — when the agent has made a non-obvious call you want defended. Forces three beats: name the call plainly, name the alternatives, surface what would change the call. If the agent can't honestly render all three, it concedes — the call was under-justified and you reopen it.

**`/metis:scope-check`** — between implementation and review when you suspect the agent reduced scope quietly. Enumerates `Skipped` / `Deferred` / `Stubbed` / `Handled differently` as one-liners with no defenses. Catches the failure mode where reductions get absorbed into the surrounding narrative.

**`/metis:epic-retro`** — at epic close. Names per-task estimation drift, replans with their prevention signal (what would have caught the split at task-write time), and assumption failures against `BUILD.md`. For improvement, not reassurance — empty blocks are fine.

---

## Reference

**Conventions** (`.metis/conventions/`) — file-format specs:

- `frontmatter-schema.md` — task frontmatter
- `task-format.md` — task file shape
- `epic-format.md` — `EPIC.md` shape
- `decision-format.md` — ADR shape
- `command-prompts.md` — how skills handle the trailing free-text argument

**Plugin source** — installed by Claude Code under `.claude/skills/metis/` and `.claude/agents/metis/`:

- `skills/<name>/SKILL.md` — 21 primary skills
- `agents/<name>.md` — 4 subagents
- `references/<name>.md` — plugin-root references (loaded by skills and subagents)
- `skills/<name>/references/<name>.md` — per-primary references

**License**: MIT. See [`LICENSE`](LICENSE).

**Repository**: <https://github.com/gsaranti/Metis>
