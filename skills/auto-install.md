# HES Skill — Auto-Install: Automated Installation Protocol

> Skill invoked via: `/hes auto-install` or automatically on first `/hes` run
> Objective: completely automate HES installation using agentic tools
> Principle: harness should install itself with minimal user input

---

## ◈ FUNDAMENTAL RULE

> **Installation must be fully automated.**
> The agent uses tools to copy files, create directories, and validate setup.
> User only confirms — never manually copies files.

---

## ◈ STEP 1 — DETECT CURRENT STATE

```
1. Check if SKILL.md exists in project root
2. Check if skills/ directory exists
3. Count files in skills/ (should be 18)
4. Check if .hes/ directory exists
5. Check if .hes/state/current.json exists

Decision matrix:
  - No SKILL.md → User needs to install HES first
  - SKILL.md + no .hes/ → Run bootstrap
  - SKILL.md + .hes/ + current.json → Already installed, resume normal operation
```

---

## ◈ STEP 2 — AUTOMATIC FILE INSTALLATION

### If HES files not in project:

```
1. Agent identifies source location of HES files (user provides path or asks)
2. Agent uses file system tools to copy files:
   - Copy SKILL.md to project root
   - Create skills/ directory
   - Copy all .md files from source skills/ to project skills/
3. Agent validates:
   - Count files in skills/ (should be 18)
   - Verify SKILL.md exists
4. Agent commits to version control:
   git add SKILL.md skills/
   git commit -m "chore: install HES v3.3.0"
```

### Tool calls agent MUST make:

```
1. list_directory(source_skills_path) → verify source files exist
2. run_shell_command("mkdir -p skills") → create target directory
3. run_shell_command("cp source/SKILL.md ./SKILL.md") → copy orchestrator
4. run_shell_command("cp source/skills/*.md ./skills/") → copy all skill files
5. list_directory("skills") → verify all 18 files copied
6. run_shell_command("git add SKILL.md skills/ && git commit -m 'chore: install HES v3.3.0'") → version control
```

---

## ◈ STEP 3 — AUTOMATIC BOOTSTRAP

### After files installed, run bootstrap automatically:

```
1. Load skills/00-bootstrap.md
2. Auto-detect project information:
   - Project name: extract from git remote or package.json or current directory name
   - Stack: scan for common patterns (pom.xml=Java, package.json=Node, requirements.txt=Python)
   - IDE: detect from .vscode/, .cursor/, .claude/ directories
   - Domains: scan src/ directory structure for domain-like folders
3. Generate questions with auto-suggested answers
4. Wait for user confirmation or correction
5. Generate .hes/ structure using file system tools
```

### Auto-detection recipes:

**Project name:**
```
1. Try: git remote get-url origin | basename -s .git
2. Fallback: basename $(pwd)
3. Fallback: "my-project"
```

**Stack detection:**
```
if [ -f "pom.xml" ] → "Java + Maven"
elif [ -f "build.gradle" ] → "Java + Gradle"
elif [ -f "package.json" ] → "Node.js + npm"
elif [ -f "requirements.txt" ] → "Python + pip"
elif [ -f "Cargo.toml" ] → "Rust + Cargo"
elif [ -f "go.mod" ] → "Go"
else → "Unknown (user specifies)"
```

**IDE / tool detection (suggest only — never auto-install):**
```
Scan for presence of:
  [ ] claude CLI  → suggest "Claude Code"
  [ ] .cursor/    → suggest "Cursor"
  [ ] .vscode/    → suggest "VS Code / Copilot"
  [ ] codex CLI   → suggest "Codex CLI"
  [ ] gemini CLI  → suggest "Gemini CLI"
  [ ] opencode CLI→ suggest "OpenCode"
  [ ] kiro-cli    → suggest "Kiro (AWS)"
```

**→ ALWAYS ask the user which tool(s) to install for, even when detected.**

Display exactly:

```
  Detected tools:
    ✓ Claude Code
    ✓ Cursor
    · Gemini CLI       (not detected)
    · GitHub Copilot   (available, project-only)

  Which AI tool(s) do you want to install HES for?
  Enter number(s) separated by spaces — detection is a suggestion only.

    1.  Claude Code
    2.  Codex CLI
    3.  Gemini CLI
    4.  OpenCode
    5.  Cursor
    6.  Windsurf
    7.  GitHub Copilot / VS Code
    8.  Kiro (AWS)

  > [wait for user input]
```

Only after the user explicitly selects tools → proceed to install.
Never install all detected tools automatically. Detection informs — the user decides.

---

## ◈ STEP 4 — GENERATE .hes/ STRUCTURE

### Use shell commands to create directories:

```bash
mkdir -p .claude/commands .hes/state .hes/specs .hes/decisions .hes/tasks .hes/inventory
```

### Generate current.json with auto-detected values:

```json
{
  "project": "{{AUTO_DETECTED_NAME}}",
  "stack": "{{AUTO_DETECTED_STACK}}",
  "ide": "{{AUTO_DETECTED_IDE}}",
  "active_feature": null,
  "features": {},
  "domains": [],
  "dependency_graph": {},
  "harness_version": "3.3.0",
  "agent_model": "single-agent",
  "user_language": "auto",
  "audience_mode": "expert",
  "completed_cycles": 0,
  "last_updated": "{{CURRENT_ISO_DATE}}",
  "installation": {
    "installed_at": "{{CURRENT_ISO_DATE}}",
    "installation_type": "auto",
    "auto_detected": true,
    "files_installed": 19,
    "validation_passed": true
  },
  "session": {
    "checkpoint": null,
    "phase_lock": "ZERO",
    "messages_in_session": 0
  }
}
```

### Generate events.log:

```json
[
  {
    "timestamp": "{{CURRENT_ISO_DATE}}",
    "feature": "global",
    "from": "NONE",
    "to": "HARNESS_INSTALLED",
    "agent": "hes-auto-install",
    "metadata": {
      "project": "{{PROJECT_NAME}}",
      "stack": "{{STACK}}",
      "ide": "{{IDE}}",
      "harness_version": "3.3.0",
      "auto_installed": true
    }
  }
]
```

---

## ◈ STEP 5 — GENERATE IDE CONFIG (selected tool only)

Install the config file only for the tool(s) the user selected in the detection step.
Never install for tools the user did not select.

**Claude Code** (if selected):
Write `.claude/CLAUDE.md` + `CLAUDE.md` in project root.

**Cursor** (if selected):
Write `.cursor/rules/hes.mdc`.

**Codex CLI** (if selected):
Write `.agents/skills/hes/SKILL.md`. `AGENTS.md` already written by core install.

**Gemini CLI** (if selected):
Write `GEMINI.md` + `.agents/skills/hes/` (symlink `.gemini/skills/hes → .agents/skills/hes`).

**OpenCode** (if selected):
Write `.opencode/skills/hes/SKILL.md` + `.agents/skills/hes/SKILL.md`.

**Windsurf** (if selected):
Write `.windsurfrules` + `.agents/skills/hes/SKILL.md`.

**GitHub Copilot / VS Code** (if selected):
Write `.github/copilot-instructions.md`.

**Kiro (AWS)** (if selected):
Write `.kiro/steering/hes.md` + `.kiro/skills/hes/SKILL.md`.

---

## ◈ STEP 6 — VALIDATE INSTALLATION

### Run validation checklist:

```
[✓] SKILL.md exists in project root
[✓] skills/ directory exists
[✓] 18 skill files present
[✓] .hes/ directory created
[✓] .hes/state/current.json valid JSON
[✓] .hes/agents/registry.json exists (if applicable)
[✓] Git commit created
```

### If validation fails:
```
1. Identify missing files
2. Retry installation of missing files
3. If still fails → report to user with specific error
```

---

## ◈ STEP 7 — ANNOUNCE COMPLETION

────────────────────────────────────────────────────────────────
  ZERO complete
  HES 3.5.0 installed · {{PROJECT_NAME}} · {{STACK}}
  tools: {{SELECTED_TOOLS}} · scope: project
────────────────────────────────────────────────────────────────
  → DISCOVERY                              skills/01-discovery.md

  What is the first feature you want to build?

  💡 Name the feature as a verb phrase: "user auth", "payment processing".
────────────────────────────────────────────────────────────────  [D] "I want to refactor [module]"
      → Load REFACTOR protocol

💡 Tip: Your harness is now installed. Run /hes anytime to check state.
```

---

## ◈ TRIGGER CONDITIONS

### Auto-trigger on first /hes:

```
When user runs /hes for first time:
1. Check if .hes/state/current.json exists
2. If NO → announce "HES not detected. Running auto-install..."
3. Execute auto-install protocol
4. Ask user for confirmation of auto-detected values
5. Proceed to bootstrap

When user runs /hes and .hes/ exists:
1. Normal state resumption (no auto-install)
```

---

## ◈ INTEGRATION WITH SKILL.md

Add to SKILL.md STEP 0:

```
STEP 0 — READ STATE AND AUTO-INSTALL

1. Check .hes/state/current.json
2. No file AND no .hes/ directory → RUN AUTO-INSTALL
   → Load skills/auto-install.md
   → Execute auto-install protocol
   → After completion, resume from ZERO state
3. No file AND with .hes/ → LEGACY (load skills/legacy.md)
4. With file → read active_feature and state (normal operation)
```

---

## ◈ REGISTRY ENTRY

Add to .hes/agents/registry.json:

```json
{
  "agent": "auto-install-agent",
  "type": "system",
  "phase": "INSTALL",
  "skill_file": "skills/auto-install.md",
  "trigger": "/hes auto-install OR first /hes without .hes/",
  "context_load": ["SKILL.md", "skills/00-bootstrap.md"],
  "description": "Automated HES installation using agentic tools"
}
```

---

## ◈ ERROR RECOVERY

```
If auto-install fails:
1. Report specific error
2. Provide manual fallback instructions
3. Ask user to run manual install commands:
   mkdir -p skills
   cp /path/to/hes/SKILL.md ./SKILL.md
   cp /path/to/hes/skills/*.md ./skills/
   git add SKILL.md skills/ && git commit -m "chore: install HES v3.3.0"
```

---

▶ NEXT ACTION

```
🔧 Auto-Installation protocol ready.

  [A] "Run auto-install now"
      → Execute installation in current project

  [B] "Add to SKILL.md"
      → Integrate auto-install trigger

  [C] "Test auto-install"
      → Run in test directory

  [D] "Skip, install manually"
      → Use traditional INSTALL.md method

💡 Tip: Auto-install uses agentic file operations — no bash scripts needed.
   The agent copies files, validates, and commits automatically.
```
