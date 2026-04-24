---
name: metis:init
description: Scaffold the Metis framework surface in the current project. Non-destructive — preserves any existing CLAUDE.md and .gitignore content via delimited sections.
disable-model-invocation: true
---

# /metis:init

Scaffold Metis into the current project. Creates `.metis/`, the `metis/` namespace under `.claude/`, and `scratch/`; adds a delimited section to `CLAUDE.md` and `.gitignore`. Does not ask a layout question — flat vs. epic emerges from whichever of `/metis:generate-tasks` or `/metis:epic-breakdown` the user runs first.

## Preconditions

- Current directory is writable and is a reasonable project root (the presence of `.git/`, a `package.json`, a `pyproject.toml`, or similar is a positive signal; its absence is not a hard block, but the command surfaces the check and asks for confirmation if none is found).
- If `.metis/` already exists and is non-empty, this is a re-run. The command is idempotent — reconfirm and re-land the delimited sections, surface any drift between the installed files and the current upstream (e.g., updated conventions). It does not clobber user customizations to files under `.metis/` or `.claude/metis/`.

## Input — optional

- `--name=<project-name>` — sets the `name:` field in `.metis/config.yaml`. If omitted, infer from the containing directory name; if the inference looks off, ask interactively.

The rest of the first-time setup (git-init, policy defaults) is interactive for a first-time user and silent for a re-run.

## What gets scaffolded

### Fresh creates

- **`.metis/config.yaml`** — project settings. At minimum, `name:`, `version:` (the Metis version that scaffolded this), and `spec_version: 1` (the initial baseline). No `mode:` field — layout is emergent.
- **`.metis/version`** — plain-text file with the Metis version, for upgrade tooling.
- **`.metis/MANIFEST.md`** — human-readable list of what Metis created, so the user can see the install surface and uninstall cleanly if they ever want to.
- **`.metis/conventions/`** — the four convention files (`task-format.md`, `epic-format.md`, `decision-format.md`, `frontmatter-schema.md`), copied from the distribution.
- **`.metis/templates/`** — the three template files (`task.md`, `epic.md`, `decision.md`), copied from the distribution.
- **`.claude/commands/metis/`** — the 22 command files, copied from the distribution.
- **`.claude/agents/metis/`** — the 2 subagent files (`task-planner.md`, `task-reviewer.md`), copied from the distribution.
- **`.claude/skills/metis/`** — the 15 skill directories (`SKILL.md` plus `examples/`), copied from the distribution.
- **`scratch/`** — the ephemeral surface. Creates the directory plus `scratch/CURRENT.md` (empty starter with the four block headers) and `scratch/questions.md` (empty starter with one header). `scratch/plans/`, `scratch/exploration/`, `scratch/research/` are created as empty directories with `.gitkeep`.

### Delimited modifications

- **`CLAUDE.md`** — add or replace the Metis block between `<\!-- metis:start -->` and `<\!-- metis:end -->`. Content outside the delimiters is preserved verbatim. If the file does not exist, create it with only the delimited block. The block's contents are the minimal workflow pointer per `docs/metis-write-rules.md` and the handoff's CLAUDE.md section — a short primer, key files, a few headline write rules, the pointer to `.metis/conventions/`, and a pointer to the command set. Target ≤2k tokens for the always-on load.
- **`.gitignore`** — add or replace the Metis block between `# <\!-- metis:start -->` and `# <\!-- metis:end -->`. Content outside the delimiters is preserved. The block is:

  ```
  # <\!-- metis:start -->
  scratch/*
  \!scratch/CURRENT.md
  \!scratch/questions.md
  \!scratch/.gitkeep
  # <\!-- metis:end -->
  ```

  If the file does not exist, create it with only the delimited block.

## What does not get scaffolded

Deliberately absent at init:

- **`BUILD.md`**. Produced by `/metis:build-spec`.
- **`BOARD.md`**. Generated downstream.
- **`tasks/`, `epics/`**. Emerges from `/metis:generate-tasks` or `/metis:epic-breakdown`.
- **`decisions/`**. The directory is created empty if any decision is written; init does not create it ahead of first use.
- **`docs/`**. If the project is docs-first, the user brings the docs in; init does not pre-create a `docs/` skeleton.
- **`features/`**. Created by the first `/metis:feature` call that lands in flat mode.

## Load

- The current state of `CLAUDE.md` and `.gitignore` if they exist — needed to preserve content outside the delimiters.
- `.metis/config.yaml` and related Metis files if this is a re-run — needed to detect drift against the distribution and to preserve user customizations.
- The Metis distribution's conventions, templates, commands, subagents, and skills — the source files being installed into the project. These are bundled with the framework itself; how the runtime locates them is resolution-layer concern, not something this prompt prescribes.

## Do not load

- Source docs under `docs/`, `BUILD.md`, tasks, epics, `scratch/`, `decisions/`. Init is a filesystem scaffold; it does not read the project's own state beyond what is needed to place the delimiters without clobbering.

## Skills

This command does not invoke a skill. Init is pure scaffolding — no artifact-shaping judgment, no capture bar. The skills and conventions it installs carry the judgment; init just puts them in place.

## Write scope

- All the paths named under *What gets scaffolded* above.
- Delimited modifications to `CLAUDE.md` and `.gitignore` at the project root.

Do not write outside the paths named. Do not create `BUILD.md`, `BOARD.md`, `tasks/`, `epics/`, `decisions/`, or `docs/` — those are downstream commands' responsibilities.

## Non-destructive guarantees

- Delimited sections in `CLAUDE.md` and `.gitignore` replace only content between the markers. User content elsewhere in those files is preserved exactly.
- Existing files under `.metis/` or `.claude/metis/` that differ from the distribution are flagged as user customizations and not overwritten by default. On a re-run, the command offers a diff-level choice for each modified file: keep the local version, take the upstream version, or render the diff for the user to reconcile manually. The default is keep-local.
- Existing files under `scratch/` are never overwritten.

## Interactive prompts (first-time setup)

If the user does not pass `--name`, ask for it once. If the project does not look git-initialized, ask whether to run `git init` as part of scaffolding. Neither prompt blocks the scaffolding — both have sensible defaults.

On re-run, no interactive prompts; the command reports what it checked, what it re-landed, and what it skipped.

## Return

- **Created** — every new file written, as a list. Grouped by top-level directory for readability.
- **Modified** — `CLAUDE.md` and `.gitignore` delimiter changes, each with a one-line summary.
- **Preserved** — any existing Metis files detected as user-customized (re-run only).
- **Skipped** — paths the command deliberately did not touch (`BUILD.md`, `tasks/`, etc., with one-line reasons where useful).
- **Next step** — the honest starting point depends on the project's shape:
  - Docs-first, greenfield → `/metis:reconcile`
  - Prompt-seeded, no docs → `/metis:build-spec "<description>"`
  - Existing codebase → `/metis:build-spec "<description of the delta>"`
  
  The command does not try to detect which shape applies; it lists all three and lets the user pick.

This command silently accepts and ignores any trailing free-text prompt beyond the `--name` flag — init is pure scaffolding, and per-invocation tuning has nowhere to land. A user who wants different defaults should edit `.metis/config.yaml` after init runs.
