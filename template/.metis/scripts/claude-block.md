## Metis workflow

This project uses Metis — a docs-first toolset for keeping a project's intent, status, and history legible across agent sessions. The engineering loop (plan/implement/review) is optional; the context maintenance is the value.

**Layout**: flat (`tasks/` at the project root) or epic (`epics/<name>/tasks/`) — whichever exists on disk. Commands check the filesystem and error with a helpful alternative on shape mismatch.

**Key files**:
- `BUILD.md` — what we're building (forward-looking).
- `tasks/` or `epics/` — individual work items.
- `decisions/` — append-only ADRs.
- `docs/` — source material (docs-first projects).
- `scratch/CURRENT.md` — session handoff (read first on any new session).
- `BOARD.md` — generated task-state index.

**Write rules (highlights)**:
- Only the main session writes to `scratch/CURRENT.md`.
- Subagents write only to their assigned task file.
- Decisions go in `decisions/` (append-only, never edited in place).
- `BOARD.md` is generated; don't hand-edit.

**Conventions** (on-disk formats) live in `.metis/conventions/`. **Command-register skills** live at `.claude/skills/metis/metis-<name>/SKILL.md`; type `/metis:` to see the set.
