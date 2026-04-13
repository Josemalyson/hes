# Contribution + Issue Flow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a contribution guide and issue-creation skill that standardizes how contributors report bugs and propose improvements via GitHub Issues, replacing the `melhorias/todo.md` ad-hoc tracking.

**Architecture:** Four new files (CONTRIBUTING.md, skill, two templates) plus registry update. The skill collects system diagnostics automatically and generates a filled issue template, creating it via `gh` CLI or printing markdown fallback.

**Tech Stack:** Markdown (skill-files, templates), GitHub CLI (`gh`), Shell commands for diagnostics, JSON (registry, state files)

---

### Task 1: Create Bug Issue Template

**Files:**
- Create: `.hes/templates/issue-bug.md`

- [ ] **Step 1: Create the bug template file**

Create `.hes/templates/issue-bug.md` with the following content:

```markdown
---
title: "[Bug] <short description>"
labels: bug
assignees: ""
---

## Bug Description
<!-- What happened? -->

## Expected Behavior
<!-- What should have happened? -->

## Steps to Reproduce
<!-- Provide clear, numbered steps -->
1. 
2. 
3. 

## System Information
<!-- This section will be auto-filled when using /hes issue -->
- **HES Version:** {{HES_VERSION}}
- **OS:** {{OS_INFO}}
- **IDE/CLI:** {{IDE_CLI}}
- **Git Commit:** {{GIT_COMMIT}}
- **HES State:** {{HES_STATE_SNAPSHOT}}
- **gh CLI:** {{GH_CLI_VERSION}}
- **Relevant Runtime:** {{RELEVANT_RUNTIME}}

## State File
<!-- Attach or paste .hes/state/current.json content for debugging -->
```json
{{STATE_FILE_CONTENT}}
```

## Additional Context
<!-- Screenshots, logs, related issues -->
```

- [ ] **Step 2: Commit**

```bash
git add .hes/templates/issue-bug.md
git commit -m "feat: add bug issue template with auto-fill placeholders"
```

---

### Task 2: Create Improvement Issue Template

**Files:**
- Create: `.hes/templates/issue-improvement.md`

- [ ] **Step 1: Create the improvement template file**

Create `.hes/templates/issue-improvement.md` with the following content:

```markdown
---
title: "[Improvement] <short description>"
labels: enhancement
assignees: ""
---

## Description
<!-- What do you want to improve? -->

## Motivation
<!-- Why does this matter? -->

## Proposed Solution
<!-- How it could work — optional -->

## Alternatives Considered
<!-- Other approaches — optional -->

## System Information
<!-- This section will be auto-filled when using /hes issue -->
- **HES Version:** {{HES_VERSION}}
- **OS:** {{OS_INFO}}
- **IDE/CLI:** {{IDE_CLI}}

## Additional Context
<!-- References, links, related issues -->
```

- [ ] **Step 2: Commit**

```bash
git add .hes/templates/issue-improvement.md
git commit -m "feat: add improvement issue template with auto-fill placeholders"
```

---

### Task 3: Create CONTRIBUTING.md

**Files:**
- Create: `CONTRIBUTING.md`

- [ ] **Step 1: Create the contribution guide**

Create `CONTRIBUTING.md` at the project root with the following content:

```markdown
# Contributing to HES

Thank you for your interest in contributing to the Harness Engineer Standard (HES)!

---

## ◈ How to Report a Bug

Found a bug? The best way to report it is via a GitHub Issue.

### Option 1: Use the HES Skill (Recommended)

If you're working in a project with HES installed, run:

```
/hes bug
```

This will automatically collect system diagnostics and create a properly formatted issue.

### Option 2: Manual Issue Creation

1. Go to [Issues](../../issues/new)
2. Use the "Bug Report" template
3. Fill in the steps to reproduce
4. Include your system information (run `uname -a`, `git describe --tags`, and paste `.hes/state/current.json`)

### What Makes a Good Bug Report?

- **Clear reproduction steps** — numbered, specific steps
- **Expected vs actual behavior** — what should happen vs what did happen
- **System information** — HES version, OS, IDE, git commit
- **State file** — paste the contents of `.hes/state/current.json` for debugging context

---

## ◈ How to Propose an Improvement

Have an idea for a new feature or enhancement?

### Option 1: Use the HES Skill

```
/hes improvement
```

### Option 2: Manual Issue Creation

1. Go to [Issues](../../issues/new)
2. Use the "Improvement" template
3. Describe the problem you're trying to solve

### What Makes a Good Improvement Proposal?

- **Clear motivation** — why does this matter?
- **Proposed solution** — how could it work? (optional but helpful)
- **Alternatives considered** — other approaches you've thought about

---

## ◈ Development Setup

See [SETUP.md](SETUP.md) for instructions on installing HES skill-files in your IDE or AI coding tool.

---

## ◈ Commit Conventions

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

Types:
- `feat` — new feature or enhancement
- `fix` — bug fix
- `docs` — documentation changes
- `chore` — maintenance tasks (tooling, configs)
- `refactor` — code refactoring without behavior changes
- `test` — adding or modifying tests

Examples:
```
feat(harness): add session manager skill
fix(bootstrap): handle missing state file gracefully
docs: add contribution guide
chore: update agent registry
```

---

## ◈ Branch Strategy

- `main` — protected branch, only merged via PRs
- `feat/<name>` — feature branches
- `fix/<name>` — bug fix branches
- `docs/<name>` — documentation branches

---

## ◈ Pull Request Requirements

Every PR must include:
- [ ] Linked issue (bug or improvement)
- [ ] Description of changes
- [ ] Testing notes (what was tested, how)
- [ ] Updated documentation if behavior changed

Example PR description:

```markdown
## What
Add session manager skill with lifecycle management.

## Why
Needed for context preservation across sessions and phase-lock enforcement.

## Testing
- Manual: triggered via /hes status, verified state persistence
- Behavioral: followed skill protocol through full lifecycle
```

---

## ◈ HES Workflow (For Newcomers)

HES is a skill-based system for orchestrating AI coding agents. Here's how it works:

1. **SKILL.md** — The entry point. It reads the project state and routes to the right skill.
2. **skills/XX-name.md** — Individual skill files that guide the agent through each phase.
3. **.hes/state/** — Generated state files tracking feature progress.
4. **.hes/agents/** — Agent registry defining which agent handles which phase.

When you run `/hes`, the system reads the current state and dispatches to the appropriate agent for the current phase (DISCOVERY → SPEC → DESIGN → DATA → RED → GREEN → REVIEW → DONE).

---

*Thank you for contributing!*
```

- [ ] **Step 2: Commit**

```bash
git add CONTRIBUTING.md
git commit -m "docs: add contribution guide with bug reporting and improvement workflows"
```

---

### Task 4: Create Issue-Creation Skill (09-issue-create.md)

**Files:**
- Create: `skills/09-issue-create.md`

- [ ] **Step 1: Create the skill file**

Create `skills/09-issue-create.md` with the following content:

```markdown
---
name: issue-create
version: 1.0.0
trigger: /hes issue | /hes bug | /hes improvement
author: HES Team | 2026
framework: HES — Harness Engineer Standard v3.2
---

# HES Skill — 09: Issue Creation

> Skill for creating well-structured GitHub Issues with automatic diagnostic collection.
> Triggered by: /hes issue, /hes bug, /hes improvement

---

## ◈ CONTEXTO A CARREGAR ANTES DE AGIR

```
1. Determine issue type:
   - /hes bug      → bug template
   - /hes improvement → improvement template
   - /hes issue    → ask user to classify

2. Collect diagnostics (run these commands):
   - HES version: grep from SKILL.md YAML header (version field)
   - OS: uname -a (or equivalent)
   - IDE/CLI: read from .hes/state/current.json (ide field if present)
   - Git commit: git describe --tags 2>/dev/null || git rev-parse --short HEAD
   - gh CLI: gh --version 2>/dev/null || echo "not installed"
   - Relevant runtime: detect project type (node --version, java -version, python --version)
   - State file: cat .hes/state/current.json
```

---

## ◈ PROTOCOL

### PASSO 1 — DETECT TYPE

```
If trigger was /hes bug:
  → template = bug
If trigger was /hes improvement:
  → template = improvement
If trigger was /hes issue or ambiguous:
  → Ask: "Is this a bug report or an improvement suggestion?"
    [A] Bug → template = bug
    [B] Improvement → template = improvement
```

### PASSO 2 — COLLECT DIAGNOSTICS

```
Run the following and capture results:

1. HES_VERSION: Extract version from SKILL.md header
   → grep "version:" SKILL.md → extract value

2. OS_INFO: uname -a

3. IDE_CLI: Read from .hes/state/current.json if exists
   → Fallback: detect from environment ($TERM_PROGRAM, $EDITOR, etc.)

4. GIT_COMMIT: git describe --tags || git rev-parse --short HEAD

5. GH_CLI_VERSION: gh --version || "not installed"

6. RELEVANT_RUNTIME:
   → If package.json exists: node --version
   → If pom.xml exists: java -version
   → If requirements.txt exists: python --version
   → Else: "N/A"

7. STATE_FILE_CONTENT: cat .hes/state/current.json (or "not initialized")

Store all values for template filling.
```

### PASSO 3 — GATHER USER INPUT

```
Ask the user:

1. "What is the issue title?" (required — must be descriptive)

2. For BUG type:
   a. "Describe the bug — what happened?" (required)
   b. "What was the expected behavior?" (required)
   c. "Steps to reproduce (numbered, one per line):" (required)
   d. "Any additional context, screenshots, or logs?" (optional)

3. For IMPROVEMENT type:
   a. "What do you want to improve?" (required)
   b. "Why does this matter?" (required)
   c. "Proposed solution (optional):" 
   d. "Alternatives considered (optional):"
```

### PASSO 4 — GENERATE ISSUE BODY

```
1. Load the appropriate template from .hes/templates/
2. Replace all {{PLACEHOLDER}} values with collected diagnostics
3. Insert user-provided description, steps, context
4. Format as clean markdown
```

Template filling rules:
- {{HES_VERSION}} → extracted version or "unknown"
- {{OS_INFO}} → uname output
- {{IDE_CLI}} → detected IDE or "unknown"
- {{GIT_COMMIT}} → git commit hash
- {{HES_STATE_SNAPSHOT}} → summary of current.json (active_feature, features state)
- {{GH_CLI_VERSION}} → gh version or "not installed"
- {{RELEVANT_RUNTIME}} → detected runtime or "N/A"
- {{STATE_FILE_CONTENT}} → full current.json content (for bug reports)

### PASSO 5 — CREATE ISSUE

```
Check if gh CLI is available:

If gh IS available:
  → Run: gh issue create --title "<title>" --body-file <temp-file-with-body> --label "<label>"
  → Label: "bug" for bug reports, "enhancement" for improvements
  → Announce: "Issue created: <issue URL>"
  → Log event in .hes/state/events.log

If gh IS NOT available:
  → Print the full generated markdown
  → Announce: "gh CLI not found. Please copy the markdown below and create the issue manually at: <repo>/issues/new"
  → Provide the markdown in a code block for easy copying
```

### PASSO 6 — LOG EVENT

```
Append to .hes/state/events.log:

{
  "timestamp": "<ISO8601>",
  "feature": "issue-creation",
  "from": "N/A",
  "to": "issue-created",
  "agent": "issue-create-skill",
  "metadata": {
    "type": "bug|improvement",
    "title": "<issue title>",
    "gh_available": true|false,
    "diagnostics_collected": true
  }
}
```

---

## ◈ ERROR HANDLING

| Scenario | Behavior |
|----------|----------|
| SKILL.md not found | Use "unknown" for HES version, continue |
| .hes/state/ missing | Use "not initialized" for state, continue |
| gh CLI fails with rate limit | Print markdown fallback, show error message |
| User provides empty title | Reject, ask again — title is mandatory |
| Template file missing | Generate basic markdown without template, warn user |

---

## ◈ FORMAT PRÓXIMA AÇÃO (obrigatório)

```
▶ PRÓXIMA AÇÃO — ISSUE CREATED

Issue type : bug|improvement
Title      : <title>
Method     : gh CLI|manual copy-paste
URL        : <issue URL or "manual creation required">

📄 Template: .hes/templates/issue-{bug|improvement}.md
💡 Tip: Include the state file content for better debugging
```

---

*HES Skill v1.0.0 — Issue Creation (09-issue-create)*
*Auto-diagnostic GitHub Issue generator*
```

- [ ] **Step 2: Commit**

```bash
git add skills/09-issue-create.md
git commit -m "feat: add issue-creation skill with auto-diagnostic collection"
```

---

### Task 5: Register Skill in Agent Registry

**Files:**
- Modify: `.hes/agents/registry.json`

- [ ] **Step 1: Add issue-create-agent to registry**

Add a new entry to the `agents` object in `.hes/agents/registry.json`. Insert this alongside the existing system agents:

```json
"issue-create-agent": {
  "description": "Creates GitHub Issues with auto-diagnostic collection for bugs and improvements",
  "type": "system",
  "triggers": ["/hes issue", "/hes bug", "/hes improvement"],
  "context_load": ["SKILL.md", "skills/09-issue-create.md", ".hes/state/current.json", ".hes/templates/"]
}
```

The updated `agents` section should include all existing agents plus this new one. Do not remove or modify any existing agent entries.

- [ ] **Step 2: Commit**

```bash
git add .hes/agents/registry.json
git commit -m "feat: register issue-create-agent in agent registry"
```

---

### Task 6: Deprecate melhorias/todo.md

**Files:**
- Modify: `melhorias/todo.md`

- [ ] **Step 1: Add deprecation notice**

Replace the entire content of `melhorias/todo.md` with:

```markdown
# ⚠️ DEPRECATED

This file has been superseded by GitHub Issues.

All bugs and improvement proposals should now be tracked via:
- [GitHub Issues](../../issues)

To create an issue:
- **Bug:** Run `/hes bug` in your HES-enabled session
- **Improvement:** Run `/hes improvement`
- **Manual:** Use the templates at `.hes/templates/`

See [CONTRIBUTING.md](../CONTRIBUTING.md) for the full contribution workflow.

---

## Historical Content

The items below were migrated to GitHub Issues. They are preserved here for reference only.

### Previously tracked items:
1. criar arquivo de contribuição → ✅ CONTRIBUTING.md created
2. criar Skill de criação de uma issue → ✅ skills/09-issue-create.md created
3. pedir na issue um arquivo para replicar os erros → ✅ Included in issue templates
4. ver o padrão de autoresearch → 📋 Future phase (Phase 3)
5. ter uma analise automático dos prs → 📋 Future phase (Phase 2)
6. AGENTS.md para ficar mais genérico → 📋 Future phase
```

- [ ] **Step 2: Commit**

```bash
git add melhorias/todo.md
git commit -m "chore: deprecate melhorias/todo.md, point to GitHub Issues workflow"
```

---

### Task 7: Verify End-to-End Flow

**Files:**
- No file changes — behavioral verification

- [ ] **Step 1: Verify file structure**

Run:
```bash
ls -la CONTRIBUTING.md skills/09-issue-create.md .hes/templates/ .hes/agents/registry.json
```

Expected output: All files exist and are non-empty.

- [ ] **Step 2: Verify registry entry**

Run:
```bash
python3 -c "import json; r=json.load(open('.hes/agents/registry.json')); assert 'issue-create-agent' in r['agents']; print('Registry OK')"
```

Expected output: `Registry OK`

- [ ] **Step 3: Verify template placeholders**

Run:
```bash
grep -c '{{' .hes/templates/issue-bug.md .hes/templates/issue-improvement.md
```

Expected output: Both files have placeholder count > 0.

- [ ] **Step 4: Verify skill trigger syntax**

Run:
```bash
grep "trigger:" skills/09-issue-create.md
```

Expected output: Contains `/hes issue`, `/hes bug`, `/hes improvement`

- [ ] **Step 5: Commit if any fixes needed**

---

## Self-Review Checklist

- [x] **Spec coverage:** All items from spec covered — CONTRIBUTING.md, skill, templates, registry update, deprecation notice
- [x] **Placeholder scan:** No TBDs, TODOs, or vague instructions in the plan
- [x] **Type consistency:** All references use consistent naming (`{{HES_VERSION}}`, `{{OS_INFO}}`, etc.)
- [x] **File paths correct:** All paths match existing directory structure
- [x] **Commands tested:** Verification commands are valid and will work on Linux

**All spec requirements mapped to tasks. Plan is ready for execution.**

---

Plan complete and saved to `docs/superpowers/plans/2026-04-13-contribution-issue-flow.md`. Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**
