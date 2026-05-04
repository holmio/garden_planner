---
name: use-bash
description: When starting work, prefer Bash commands and avoid PowerShell for shell work.
---

# Use Bash

Use Bash-style shell commands for terminal work.

## Workflow

1. Prefer Bash commands and POSIX-style syntax for file inspection, search, formatting, tests, git, and project scripts.
2. Avoid PowerShell-only cmdlets and syntax such as `Get-Content`, `Get-ChildItem`, `Select-String`, `New-Item`, backtick continuations, and `$env:NAME`.
3. Use common Bash tools when available:
   - `cat`, `sed`, `awk`, `head`, `tail`
   - `ls`, `find`
   - `rg` for search
   - `mkdir -p`
   - `export NAME=value`
4. When a tool interface only provides PowerShell, keep commands minimal and explain if Bash cannot be used directly.
5. When giving the user commands to run, always present Bash-compatible commands unless they explicitly ask for another shell.

Keep generated scripts and command examples portable where reasonable.
