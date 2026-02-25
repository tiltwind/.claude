# .claude

Reusable Claude Code agents, rules, commands, and skills.

## Install

Run in your project directory:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/tiltwind/.claude/main/scripts/install.sh)
```

Or specify a target project:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/tiltwind/.claude/main/scripts/install.sh) /path/to/your-project
```

Re-run the same command to update — existing symlinks are refreshed and non-symlink files are never overwritten.

## What gets linked

| Source | Target | Method |
|---|---|---|
| `agents/*.md` | `<project>/.claude/agents/` | Individual file symlinks |
| `rules/*.md` | `<project>/.claude/rules/` | Individual file symlinks |
| `commands/*.md` | `<project>/.claude/commands/` | Individual file symlinks |
| `skills/*/` | `<project>/.claude/skills/` | Directory symlinks |
| `settings.local.json` | `<project>/.claude/settings.local.json` | File symlink |

## Contents

### Agents

- `architect.md` — Software architect
- `go-developer.md` — Go developer
- `go-reviewer.md` — Go code reviewer
- `openapi-designer.md` — OpenAPI spec designer
- `postgresql-designer.md` — PostgreSQL schema designer
- `tdd-guide.md` — TDD guide

### Rules

- `agents.md` — Agent behavior rules
- `coding-style.md` — Code style conventions
- `git-workflow.md` — Git workflow guidelines
- `hooks.md` — Hook configuration
- `performance.md` — Performance best practices
- `security.md` — Security guidelines
- `testing.md` — Testing standards

### Commands

- `commitpush.md` — Commit and push workflow

### Skills

- `golang-testing/` — Go test generation and execution
- `open-skill-manager/` — Install and link shared skills
