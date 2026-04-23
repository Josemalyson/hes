# HES — Installation Guide

> HES v3.5.0 — Harness Engineer Standard

## Quick Install (any tool)

```bash
git clone https://github.com/Josemalyson/hes.git /tmp/hes
cd /tmp/hes
chmod +x setup   # required: git clone may not preserve execute permissions
./setup
```

The interactive installer detects your AI tools, asks where to install (project or global),
and places the correct files for each tool automatically.

---

## What `./setup` Does

1. Asks: **project** (in this repo) or **global** (home dir) or **both**
2. Detects installed AI tools (Claude Code, Codex, Gemini, Cursor, etc.)
3. Lets you toggle which tools to include
4. Copies the correct files to the correct locations per tool
5. Commits to git (project mode)

---

## Non-Interactive Install

```bash
# Install for all detected tools in current project
./setup --yes

# Install for specific tools only
./setup --tools claude,codex,gemini --scope project

# Global install for Claude Code only
./setup --tools claude --scope global

# Install everything, everywhere
./setup --tools all --scope both --yes
```

---

## File Locations per Tool

| Tool | Context File | Skills Directory |
|------|-------------|------------------|
| **Claude Code** | `CLAUDE.md` + `.claude/CLAUDE.md` | `.claude/skills/hes/` |
| **Claude Code (global)** | `~/.claude/CLAUDE.md` | `~/.claude/skills/hes/` |
| **OpenAI Codex CLI** | `AGENTS.md` | `.agents/skills/hes/` |
| **Codex (global)** | `~/.codex/AGENTS.md` | `~/.codex/skills/hes/` |
| **Gemini CLI** | `GEMINI.md` + `AGENTS.md` | `.gemini/skills/hes/` + `.agents/skills/hes/` |
| **Gemini (global)** | `~/.gemini/GEMINI.md` | `~/.gemini/skills/hes/` + `~/.agents/skills/hes/` |
| **OpenCode** | `AGENTS.md` | `.opencode/skills/hes/` + `.agents/skills/hes/` |
| **OpenCode (global)** | `~/.config/opencode/AGENTS.md` | `~/.config/opencode/skills/hes/` |
| **Cursor** | `.cursor/rules/hes.mdc` | `.cursor/skills/hes/` |
| **Cursor (global)** | `~/.cursor/rules/hes.mdc` | `~/.cursor/skills/hes/` |
| **Windsurf** | `.windsurfrules` + `AGENTS.md` | `.agents/skills/hes/` |
| **Windsurf (global)** | `~/.windsurfrules` | `~/.agents/skills/hes/` |
| **GitHub Copilot** | `.github/copilot-instructions.md` | `.github/instructions/*.instructions.md` |
| **Kiro (AWS)** | `.kiro/steering/hes.md` | `.kiro/skills/hes/` |
| **Kiro (global)** | `~/.kiro/steering/hes.md` | `~/.kiro/skills/hes/` |

---

## Cross-Tool Skill Standard

All tools read the Agent Skills standard format:

```
<skill-name>/
  SKILL.md      ← required: name, description, instructions (YAML frontmatter)
  scripts/      ← optional: shell/Python scripts Claude can execute
  references/   ← optional: documentation loaded on demand
```

The HES skill is installed at `<skills-dir>/hes/SKILL.md` for each tool.
The `/hes` slash command becomes available as soon as the skill is discovered.

---

## Claude.ai (Web / App)

In **Settings → Project → Instructions**, paste:

```
You are a HES Harness Engineer (v3.5.0). When /hes is invoked:
1. Read SKILL.md in full
2. Check .hes/state/current.json for current phase
3. Load skills/<phase>.md and execute autonomously
```

---

## Verify Installation

After install:

```bash
# Claude Code
claude> /hes status

# Gemini CLI
gemini> /hes

# OpenCode
opencode> /hes status

# Codex CLI
codex> /hes
```

You should see: `📍 HES v3.5.0 — [PROJECT] | Phase: ZERO`

---

## Update HES

```bash
cd /tmp/hes && git pull
./setup --yes  # re-runs with same options
```

Project state in `.hes/` is preserved across updates.

---

## Uninstall HES

To completely remove HES from a project, run `/hes uninstall` in your AI assistant.

The uninstall skill (`skills/13-uninstall.md`) handles everything automatically:

1. **Inventory** — scans and lists every HES-owned file actually present
2. **Confirmation #1** — shows the manifest, asks `[A] yes / [B] cancel`
3. **Confirmation #2** — requires typing `REMOVE HES` exactly
4. **Export** — saves `hes-history-export-<date>.jsonl` and `hes-lessons-export-<date>.md` to project root before deletion
5. **Removal** — deletes `.hes/`, `skills/`, `SKILL.md`, IDE configs (`.claude/`, `.cursor/`, `.kiro/`, `.agents/`, `.github/copilot-instructions.md`, `.windsurfrules`), and `scripts/` (if HES-generated only)
6. **Validation** — confirms no HES artifacts remain

**What is NOT removed:** `src/`, `app/`, `tests/`, `package.json`, `pom.xml`, `pyproject.toml`, `.env` — your application code is never touched.

### Manual removal (fallback)

If the AI assistant does not have shell tool access:

```bash
# Export before removing
cp .hes/state/events.log hes-history-export.jsonl 2>/dev/null || true
cp .hes/tasks/lessons.md hes-lessons-export.md 2>/dev/null || true

# Remove HES artifacts
rm -rf .hes/ skills/ SKILL.md AGENTS.md ARCHITECTURE.md INSTALL.md \
       CHANGELOG.md CONTRIBUTING.md security-policy.yml setup scripts/

# Remove IDE configs (HES-generated only)
rm -f  .claude/CLAUDE.md .cursor/rules/hes.mdc .kiro/steering/hes.md \
       .github/copilot-instructions.md .github/workflows/harness-validation.yml \
       .windsurfrules
rm -rf .claude/commands/ .cursor/skills/ .kiro/skills/ .agents/skills/ .gemini/

# Clean up empty dirs
rmdir .claude .cursor .kiro .agents 2>/dev/null || true
```
