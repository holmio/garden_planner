---
name: agents-check
description: Check repository AGENTS.md instructions before starting and before finishing project work. Use when Codex is changing code, tests, docs, backlog items, project structure, runtime wiring, integrations, or any task where local repository instructions may affect implementation, verification, docs, or final response.
---

# Agents Check

Use this skill to keep repository instructions active throughout a task.

## Workflow

1. Before starting work, read the nearest relevant `AGENTS.md` from the repository root or current working tree.
2. Summarize only the task-relevant constraints to yourself, especially commands, runtime setup, architecture boundaries, testing quirks, docs maintenance, backlog maintenance, and response-mode rules.
3. During the task, follow the repo instructions over generic habits when they conflict.
4. Before finishing, re-read or quickly re-check `AGENTS.md`.
5. Apply any completion rules:
   - Run the verification command that matches the touched area when feasible.
   - If the change affects project structure, app wiring, major directories, runtime flow, or core integrations, ask whether `README.md` should be updated.
   - Check `BACKLOG.md` after completing work. Remove a backlog item only when the delivered change fully satisfies it.
   - Mention any verification that could not be completed.

Keep the final response concise and include only the AGENTS-driven details that matter to the user.
