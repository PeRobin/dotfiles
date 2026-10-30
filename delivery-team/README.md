# Delivery team

Seven self-contained agents for requirements, design, implementation and review. Start with `delivery-lead`, which coordinates the six specialists as needed.

Agents live in `delivery-team/agents/`. The three supporting skills live alongside the repository's existing skills in [`home/.config/opencode/skills/`](../home/.config/opencode/skills/): `requirements-architect`, `ux-advisor` and `design-advisor`.

## Install in OpenCode

- **Project:** copy this folder's `agents/` into your project's `.opencode/agents/`. Copy the three supporting skill directories from `home/.config/opencode/skills/` into the project's `.opencode/skills/`.
- **Global:** copy this folder's `agents/` into `~/.config/opencode/agents/`. Copy the three supporting skill directories from `home/.config/opencode/skills/` into `~/.config/opencode/skills/`.

Merge folders if they already exist. Quit and restart OpenCode, then select `delivery-lead` and describe the outcome you want. No models are fixed; agents inherit your model selection.

Each agent keeps OpenCode metadata and permissions in YAML frontmatter, with its instructions in the Markdown body. Each skill is a self-contained `SKILL.md`. No generator or adapter setup is required.

## Reuse with other tools

Skill bodies are reusable guidance for Claude Code and Google Antigravity. Agent permissions and frontmatter are OpenCode-specific; native agent conversion for those tools is not bundled or claimed.

Google Antigravity is the current primary Google tool referenced here. For migration from Gemini CLI, see the [official migration guide](https://antigravity.google/docs/cli/gcli-migration/).

Reviewed at source level only; native runtime compatibility with other tools has not been tested.
