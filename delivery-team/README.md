# Delivery team

Seven self-contained agents and three skills for requirements, design, implementation and review. Start with `delivery-lead`, which coordinates the six specialists as needed.

## Install in OpenCode

- **Project:** copy `agents/` into your project's `.opencode/agents/` and `skills/` into `.opencode/skills/`.
- **Global:** copy `agents/` into `~/.config/opencode/agents/` and `skills/` into `~/.config/opencode/skills/`.

Merge folders if they already exist. Quit and restart OpenCode, then select `delivery-lead` and describe the outcome you want. No models are fixed; agents inherit your model selection.

Each agent keeps OpenCode metadata and permissions in YAML frontmatter, with its instructions in the Markdown body. Each skill is a self-contained `SKILL.md`. No generator or adapter setup is required.

## Reuse with other tools

Skill bodies are reusable guidance for Claude Code and Google Antigravity. Agent permissions and frontmatter are OpenCode-specific; native agent conversion for those tools is not bundled or claimed.

Google Antigravity is the current primary Google tool referenced here. For migration from Gemini CLI, see the [official migration guide](https://antigravity.google/docs/cli/gcli-migration/).

Reviewed at source level only; native runtime compatibility with other tools has not been tested.
