# Changelog

All notable changes to Metis are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/), versioning follows [SemVer](https://semver.org/).

## [0.1.0] — 2026-04-24

Initial release.

### Added

- 21 skills under `/metis:*` covering setup, doc reconciliation, build spec + backlog, the optional engineering loop, sessions, and reconciliation of work done outside Metis.
- 4 subagents (`task-planner`, `task-reviewer`, `domain-researcher`, `code-explorer`) with scoped tool restrictions.
- 17 references (10 plugin-root + 7 per-primary) carrying artifact-shape teaching.
- 5 conventions specifying canonical on-disk formats (`frontmatter-schema`, `task-format`, `epic-format`, `decision-format`, `command-prompts`).
- 14 bash scripts handling preflight checks, drift detection, and project init, with a shared `lib/common.sh` for cross-script helpers.
- Two project layouts: flat (`tasks/`) and epic (`epics/<name>/tasks/`), with `/metis:promote-to-epics` graduating one to the other.
- Drift detection via `doc_hashes` + `spec_version` baseline fields, surfaced by `/metis:rebaseline` and walked as a cascade by `/metis:sync`.
- `docs/research/` directory with INDEX-based prior-art lookup and a 60-day staleness window for the `domain-researcher` subagent.
- Four-phase canonical workflow (reconcile → build spec + backlog → skeleton → optional engineering loop), with the loop optional at every step.

### Notes

- v0.1 targets Claude Code; other harnesses are deferred.
- The engineering loop is one path; pair-programming with hand-edits + `/metis:log-work` reconciliation is equally supported.

[0.1.0]: https://github.com/gsaranti/Metis/releases/tag/v0.1.0
