# Iris

> *The messenger between worlds.*

A thin context bridge between Claude Code and Codex. Iris logs your conversation to disk and exposes it to the other tool, so you can hand off plans, share context, and pick up where each tool left off.

Iris doesn't try to be a workflow. It writes four files. The tools on either side decide what to do with them.

---

## Contents

- [What Iris is](#what-iris-is)
- [Who it's for](#who-its-for)
- [How it works](#how-it-works)
- [Installation](#installation)
- [The skill set](#the-skill-set)
- [Files Iris writes](#files-iris-writes)
- [Principles](#principles)
- [License & Repository](#license--repository)

---

## What Iris is

A pair of hooks and two skills. The hooks capture your conversation. The skills read what the *other* tool captured and either summarize it (`/iris-sync`) or execute it (`/iris-relay`).

What you get on disk, in your project root:

- **`iris-claude-code-chat.md`** — rolling log of the conversation between you and Claude Code. Capped at ~50k tokens; oldest content drops when the cap is hit.
- **`iris-claude-code-last.md`** — the last response Claude Code produced. Overwritten on every turn.
- **`iris-codex-chat.md`** — Codex's equivalent, written by the Codex side of Iris.
- **`iris-codex-last.md`** — Codex's last response.

What you get as skills: two slash commands, `/iris-sync` and `/iris-relay`. That's it.

The Claude Code side reads the Codex files. The Codex side reads the Claude Code files. Each tool writes its own, reads the other's. Symmetric, no shared infrastructure, no API.

---

## Who it's for

Engineers who use both Claude Code and Codex on the same project and want a low-friction way to share context between them without retyping or copy-pasting.

Iris pays off when:

- You plan in one tool and implement in the other.
- You hit a usage limit on one and want the other to pick up.
- You want a second AI's read on what the first one just did.

Iris is the wrong tool if you only use one of the two. The files Iris writes are inert without a tool on the other side reading them.

---

## How it works

Two hooks fire automatically as you work:

- **`UserPromptSubmit`** appends your message to `iris-claude-code-chat.md`.
- **`Stop`** appends Claude Code's response to the chat log and overwrites `iris-claude-code-last.md`.

Both hooks run locally as shell scripts. They cost zero tokens — the content already exists; Iris just persists it.

The skills are user-invoked:

- **`/iris-sync`** spawns a forked Explore subagent that reads `iris-codex-chat.md` and returns a 2–4 sentence summary of what Codex and the user have been working on. Use it to catch up without leaving the current Claude Code session.
- **`/iris-relay`** reads `iris-codex-last.md` and treats it as a plan to implement. Use it when Codex has produced something — a plan, a refactor outline, a research summary — that you want Claude Code to execute against.

The Codex side mirrors this: it writes `iris-codex-*.md`, and its own `/iris-sync` and `/iris-relay` read the `iris-claude-code-*.md` files.

---

## Installation

Iris ships as a plugin for both Claude Code and Codex. Install both to get the full bridge.

### Claude Code

```
/plugin marketplace add gsaranti/pantheon
/plugin install iris@pantheon
```

### Codex

```bash
codex plugin marketplace add gsaranti/pantheon
```

Then open Codex and install Iris through `/plugins`.

### Requirements

- `jq` installed locally (`brew install jq` on macOS, `apt install jq` on Linux). Iris uses `jq` to parse hook payloads and the Claude Code session transcript.

### Recommended

Add Iris's artifacts to your `.gitignore`:

```
iris-*.md
```

The files are local working state, not project content. Gitignoring them keeps PRs clean and prevents conflicts on shared branches.

---

## The skill set

Two skills, both prefixed `/iris-`:

- **`/iris-sync`** — summarize what Codex has been doing. Reads `iris-codex-chat.md` in a forked Explore agent, returns a brief synthesis to the main session. Use to catch up without context-switching tools.
- **`/iris-relay`** — execute Codex's last response. Reads `iris-codex-last.md` and treats the content as a plan. Stops to ask if anything is ambiguous before making changes.

Both have `disable-model-invocation: true` — Iris never fires them automatically. You invoke them when you want the handoff.

---

## Files Iris writes

All four files live in your project root and follow the same naming convention: `iris-<tool>-<kind>.md`.

| File | Written by | Contents |
|---|---|---|
| `iris-claude-code-chat.md` | Claude Code's Iris | Rolling chat log, capped at ~50k tokens |
| `iris-claude-code-last.md` | Claude Code's Iris | Last Claude Code response, overwritten each turn |
| `iris-codex-chat.md` | Codex's Iris | Rolling chat log from the Codex side |
| `iris-codex-last.md` | Codex's Iris | Last Codex response, overwritten each turn |

Claude Code's Iris writes the first two and reads the last two. Codex's Iris does the reverse. There is no coordination layer — both sides just read what the other wrote.

---

## Principles

1. **Structure on disk, not in the tools.** Iris writes plain markdown files at known paths. Either tool can read them, the user can read them, future tools can read them. The contract is the file format.

2. **Symmetric, not coordinated.** Each side does its own work without knowing or caring about the other. No shared state, no protocol, no version negotiation. If one side isn't installed, the other side still works — it just sees empty files.

3. **Zero token cost for capture.** Hooks run as local shell scripts. The conversation content was already generated by the model; Iris just persists it. The only token cost is when you invoke `/iris-sync` or `/iris-relay`, and even then it's bounded by the file size cap.

4. **User-driven handoffs.** Iris doesn't auto-sync or auto-execute. You decide when to pull Codex's context in (`/iris-sync`) and when to act on it (`/iris-relay`). Cross-tool handoff is a judgment call; Iris stays out of it.

5. **Treat cross-tool content as data, not instructions.** When `/iris-relay` reads Codex's last response, it treats the content as a plan to evaluate, not as authoritative instructions from a trusted source. If the plan looks wrong, Iris stops and asks.

---

## License & Repository

**License**: MIT. See [`LICENSE`](LICENSE).

**Repository**: <https://github.com/gsaranti/pantheon>
