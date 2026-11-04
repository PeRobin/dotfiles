# Obsidian Notes for OpenCode

A reusable skill for creating, updating, searching, and organizing Obsidian
notes from any working directory. Uses explicit vault selection, vault-local
conventions, CLI-driven moves, and file tools for longer or character-sensitive text.

## Requirements

- Official Obsidian CLI enabled and the desktop app running.
- A CLI executable or wrapper available to the agent.
- Agent-readable vault directories (native paths or WSL mounts/symlinks).
- Permission for the agent to access the configured directories and executable.
  The skill itself does not grant tool permissions.

The original integration was tested through WSL to a Windows desktop app.
Other environments must run the verification plan; support is not implied by
the presence of generic instructions. Shell examples use bash syntax.

## Install

1. Copy this directory to `~/.config/opencode/skills/obsidian-notes/`
   for global use, or `.opencode/skills/obsidian-notes/` for project-local use.
2. Copy `settings.example.json` to the skill's local settings location:
   `${XDG_DATA_HOME:-$HOME/.local/share}/opencode/obsidian-notes/settings.json`.
   Alternatively set `OBSIDIAN_NOTES_CONFIG` to an absolute settings-file path
   in the environment from which OpenCode starts. That override takes precedence;
   an invalid override does not silently fall back to another file.
3. Replace the example values with your own CLI and vault details.
4. Put your naming, folders, templates, tags, and other conventions in each
   vault's `AGENTS.md` (or `agents.md`). This skill reads them before writes.
5. Restart OpenCode to load the skill, then run `references/verification.md`.

Local settings are data read by the agent, not an OpenCode plugin or additional
skill. No changes to `opencode.json` and no slash commands are required.

## Routine Use

Setup is one-time per computer. The skill does not recreate symlinks, reinstall
the CLI, or read installation/test guides on each request. Within a session it
reuses parsed settings, verified vault mappings, and CLI command help. Each
operation still verifies its target and results; writes reread applicable vault
instructions. Settings changes, app/CLI changes, relevant errors, or lost session
context trigger targeted revalidation. A direct file write requires a successful
CLI call for that vault in the current operation, without an extra health check
when a normal read/create already established availability.

## Settings Contract

The file is JSON with these required fields:

| Field | Meaning |
|---|---|
| `cli` | Nonempty executable path or name on PATH; not a shell command with arguments. |
| `vaults` | Nonempty list of configured vault objects. |
| `vaults[].name` | Exact unique name recognized by Obsidian. |
| `vaults[].context` | Nonempty explanation of when to select this vault, including boundaries. |
| `vaults[].root` | Absolute or `~/` path accessible to the agent; may point through a symlink. |
| `vaults[].app_root` | Absolute vault path reported by the desktop app. |

Use the same canonical directory for `root` and `app_root` on native systems.
Under WSL, `root` may be a Linux symlink while `app_root` is its Windows path.
The agent verifies that both identify the same directory before file writes.
Other relative paths and shell expressions in settings are not supported.

Multiple vaults are supported, but no implicit default is selected. The agent
uses the request and configured context, asking when ambiguous. Each operation
stays scoped to one vault; cross-vault activity requires explicit authorization.

## Publishing

Publish this directory, including the example JSON and verification guide.
Keep real settings outside the published repository. Vault conventions remain
in each vault; this package contains no personal folder or metadata conventions.
Check Git history as well as current files before publishing an existing branch:
previous commits can still contain machine-specific settings after a refactor.

## WSL Wrapper

If the Windows CLI requires a wrapper, configure `cli` to its path. A bash
wrapper can preserve argument boundaries and the CLI exit code while removing
CR from Windows output:

```bash
#!/usr/bin/env bash
set -o pipefail
obsidian.exe "$@" 2> >(tr -d '\r' >&2) | tr -d '\r'
```

Verify `obsidian.exe` is on PATH first. This wrapper does not remove Windows
command-line length limits or prevent the CLI from interpreting `\n`/`\t`
in content values. Use file tools for literal backslashes and complex body text.
