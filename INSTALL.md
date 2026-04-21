# hes — Harness Engineer Standard

> HES v3.5.0 — Fully automated installation protocol for AI coding agents.
> The LLM executes ALL steps autonomously using file system tools.
> User only confirms or corrects auto-detected values — never manually copies files.

---

## OBJECTIVE

Install HES v3.5.0 in any project using any AI coding agent, with zero manual
file copying by the user. The LLM harness assumes full responsibility: it
detects environment, copies all files, generates the state structure, validates
the installation, and commits to version control — autonomously.

---

## DONE WHEN

The following conditions are ALL satisfied:

```
[✓] SKILL.md exists in project root
[✓] skills/ directory exists with all 24 skill files (19 stable + 5 v4.0 stubs)
[✓] .hes/ directory exists with state/current.json (valid JSON)
[✓] .hes/agents/registry.json exists
[✓] Native tool configs generated (AGENTS.md, CLAUDE.md, GEMINI.md, .cursor/rules/hes.mdc,
         .windsurfrules, .github/copilot-instructions.md, .kiro/steering/, .claude/CLAUDE.md)
[✓] Git commit created (chore: install HES v3.5.0)
[✓] /hes status returns valid state (or equivalent command for the environment)
```

---

## TODO

- [ ] **STEP 1** — Detect project metadata (name, stack, IDE, language)
- [ ] **STEP 2** — Identify source location of HES files
- [ ] **STEP 3** — Copy SKILL.md to project root
- [ ] **STEP 4** — Create skills/ and copy 18 skill files
- [ ] **STEP 5** — Generate .hes/ directory structure
- [ ] **STEP 6** — Generate .hes/state/current.json (auto-detected values)
- [ ] **STEP 7** — Generate .hes/state/events.log (install event)
- [ ] **STEP 8** — Generate .hes/agents/registry.json
- [ ] **STEP 9** — Generate native config for ALL supported tools
- [ ] **STEP 10** — Validate all files installed and state is valid
- [ ] **STEP 11** — Commit to git version control
- [ ] **STEP 12** — Announce completion to user

---

## STEP 1 — DETECT PROJECT METADATA

> The LLM MUST auto-detect all values before proceeding. User only corrects.

### Project Name

```
1. Try: git remote get-url origin | basename -s .git
2. Fallback: basename $(pwd)
3. Fallback: "my-project"
```

### Stack Detection

```
if [ -f "pom.xml" ]        → "Java + Maven"
elif [ -f "build.gradle" ]  → "Java + Gradle"
elif [ -f "package.json" ]  → "Node.js + npm"
elif [ -f "requirements.txt" ] → "Python + pip"
elif [ -f "Cargo.toml" ]    → "Rust + Cargo"
elif [ -f "go.mod" ]        → "Go"
elif [ -f "pom.xml" ] && [ -f "package.json" ] → "Java + Maven + Node.js"
else → "Unknown" (LLM asks user to specify)
```

### IDE Detection

```
if [ -d ".claude" ]     → "claude-code"
elif [ -d ".cursor" ]   → "cursor"
elif [ -d ".windsurf" ]  → "windsurf"
elif [ -d ".vscode" ]    → "vscode"
elif [ -d ".openhands" ] → "openhands"
elif [ -d ".qwen" ]      → "qwen"
else → "generic"
```

### User Language

```
Scan first user message for patterns:
  Portuguese : "iniciar", "projeto", "como", "funciona", "criar" → "pt-BR"
  Spanish   : "iniciar", "proyecto", "cómo", "funciona"        → "es"
  French    : "démarrer", "projet", "comment", "fonctionne"    → "fr"
  German    : "starten", "projekt", "wie", "funktioniert"      → "de"
  English   : default                                             → "en"
```

### Audience Mode

```
Check if user explicitly sets mode. Default: "expert"
  beginner → simple explanations, step-by-step
  expert   → technical, concise, assumes domain knowledge
```

---

## STEP 2 — IDENTIFY SOURCE LOCATION

```
1. Check if HES files are already in project → already installed, skip
2. User provides path to HES source: "HES is at /home/josemalyson/Projects/hes"
3. If no path given → LLM searches common locations:
   - current directory and subdirectories
   - parent directories
   - ~/.hes/ or ~/Projects/hes
4. If not found → LLM asks user to provide the path to HES source
```

---

## STEP 3 — COPY SKILL.md TO PROJECT ROOT

> LLM executes via file system tools — user never copies manually.

```
Tool call sequence:
1. list_directory("<source_path>")         → confirm SKILL.md exists
2. run_shell_command("cp <source_path>/SKILL.md ./SKILL.md")
3. read_file("SKILL.md")                   → verify copy succeeded
```

---

## STEP 4 — CREATE skills/ AND COPY ALL SKILL FILES

> LLM creates directory and copies all 18 files using file system tools.

### Files to install

**Orchestrator** (1 file):
```
SKILL.md  — LLM harness orchestrator (v3.3.0)
```

**Phase Skills** (8 files — sequential execution):
```
skills/00-bootstrap.md          — Initial project setup (ZERO state)
skills/01-discovery.md          — Business rules elicitation
skills/02-spec.md              — BDD scenarios + API contracts
skills/03-design.md            — Architecture decisions (ADRs)
skills/04-data.md              — Data model + migrations
skills/05-tests.md             — TDD RED phase (failing tests first)
skills/06-implementation.md     — TDD GREEN phase (minimal viable code)
skills/07-review.md            — 5-dimension review checklist
```

**Analysis & Issue Skills** (2 files):
```
skills/08-progressive-analysis.md — Large codebase analysis (>50 files)
skills/09-issue-create.md         — Auto-diagnostic GitHub Issues
```

**Agent & Delegation Skills** (2 files):
```
skills/tool-dispatch.md        — Tool dispatch protocol (NOT skill-file delegation)
skills/agent-registry.md        — Registry schema reference
```

**System & Recovery Skills** (7 files):
```
skills/auto-install.md          — Automated HES installation (this protocol)
skills/error-recovery.md       — Error diagnosis by category (A-E)
skills/harness-health.md        — 3-dimension coverage diagnostics
skills/legacy.md                — Legacy project onboarding
skills/refactor.md              — Safe refactoring by type (A-I)
skills/report.md                — Batch learning from events.log
skills/session-manager.md       — Session lifecycle & checkpoints
```

**Reference** (directory):
```
skills/reference/
  agent-identity.md     — Agent identity templates
  domain-templates.md  — Domain structure templates
  fitness-sensors.md   — Fitness function definitions
  git-hooks.md          — Git hook definitions
```

### Tool call sequence

```
1. run_shell_command("mkdir -p skills")
2. run_shell_command("cp <source_path>/skills/*.md ./skills/")
3. run_shell_command("cp -r <source_path>/skills/reference/ ./skills/")
4. list_directory("skills")  → verify all 18+.md files present
5. count files: should be ≥ 18 skill files + reference/ directory
```

---

## STEP 5 — GENERATE .hes/ DIRECTORY STRUCTURE

> LLM creates all required directories via file system tools.

```
Tool call sequence:
run_shell_command("mkdir -p .hes/state .hes/specs .hes/decisions .hes/tasks .hes/inventory")
```

Generated structure:
```
.hes/
├── state/
│   ├── current.json          — main state file
│   ├── events.log            — event sourcing log
│   └── session-checkpoint.json
├── specs/                    — BDD spec artifacts
├── decisions/                — ADR files
├── tasks/                    — task tracking
├── inventory/                — legacy project inventory
├── agents/
│   └── registry.json         — agent registry
└── specs/
```

---

## STEP 6 — GENERATE .hes/state/current.json

> LLM generates state file with auto-detected values.

```json
{
  "project": "{{PROJECT_NAME}}",
  "stack": "{{STACK}}",
  "ide": "{{IDE}}",
  "active_feature": null,
  "features": {},
  "domains": [],
  "dependency_graph": {},
  "harness_version": "3.3.0",
  "agent_model": "single-agent",
  "user_language": "{{DETECTED_LANGUAGE}}",
  "audience_mode": "expert",
  "completed_cycles": 0,
  "last_updated": "{{CURRENT_ISO_DATE}}",
  "installation": {
    "installed_at": "{{CURRENT_ISO_DATE}}",
    "installation_type": "auto",
    "auto_detected": true,
    "files_installed": 19,
    "validation_passed": false
  },
  "session": {
    "checkpoint": null,
    "phase_lock": "ZERO",
    "messages_in_session": 0
  }
}
```

---

## STEP 7 — GENERATE .hes/state/events.log

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
      "auto_installed": true,
      "files_installed": 19
    }
  }
]
```

---

## STEP 8 — GENERATE .hes/agents/registry.json

```json
{
  "agents": [
    { "agent": "harness-agent",    "phase": "ZERO",  "skill_file": "skills/00-bootstrap.md" },
    { "agent": "discovery-agent", "phase": "DISCOVERY", "skill_file": "skills/01-discovery.md" },
    { "agent": "spec-agent",      "phase": "SPEC",     "skill_file": "skills/02-spec.md" },
    { "agent": "design-agent",    "phase": "DESIGN",   "skill_file": "skills/03-design.md" },
    { "agent": "data-agent",      "phase": "DATA",     "skill_file": "skills/04-data.md" },
    { "agent": "test-agent",      "phase": "RED",      "skill_file": "skills/05-tests.md" },
    { "agent": "impl-agent",      "phase": "GREEN",    "skill_file": "skills/06-implementation.md" },
    { "agent": "review-agent",    "phase": "REVIEW",   "skill_file": "skills/07-review.md" }
  ],
  "system_agents": [
    { "agent": "auto-install-agent",    "type": "system", "skill_file": "skills/auto-install.md",        "trigger": "/hes auto-install" },
    { "agent": "error-recovery-agent",   "type": "system", "skill_file": "skills/error-recovery.md",     "trigger": "/hes error" },
    { "agent": "harness-health-agent",  "type": "system", "skill_file": "skills/harness-health.md",      "trigger": "/hes harness" },
    { "agent": "legacy-agent",          "type": "system", "skill_file": "skills/legacy.md",             "trigger": "LEGACY state" },
    { "agent": "refactor-agent",         "type": "system", "skill_file": "skills/refactor.md",           "trigger": "/hes refactor" },
    { "agent": "report-agent",           "type": "system", "skill_file": "skills/report.md",            "trigger": "/hes report" },
    { "agent": "session-manager",        "type": "system", "skill_file": "skills/session-manager.md",   "trigger": "/hes status" },
    { "agent": "issue-create-agent",     "type": "system", "skill_file": "skills/09-issue-create.md",   "trigger": "/hes bug" },
    { "agent": "progressive-analysis-agent", "type": "system", "skill_file": "skills/08-progressive-analysis.md", "trigger": ">50 files" },
    { "agent": "delegation-agent",       "type": "system", "skill_file": "skills/tool-dispatch.md",     "trigger": "multi-agent" },
    { "agent": "registry-agent",         "type": "system", "skill_file": "skills/agent-registry.md",    "trigger": "registry ref" }
  ],
  "harness_version": "3.3.0",
  "generated_at": "{{CURRENT_ISO_DATE}}"
}
```

---

## STEP 9 — GENERATE NATIVE CONFIGS FOR ALL SUPPORTED TOOLS

HES v3.5.0 ships with native config files for every major AI coding tool.
During install, the LLM copies ALL of them to the project root — no manual setup required.

### Files to copy (from HES repo → project root)

```bash
# Cross-tool standard (read by Codex, OpenCode, Cursor, Windsurf, Copilot)
cp HES_SOURCE/AGENTS.md       ./AGENTS.md

# Claude Code native entry point
cp HES_SOURCE/CLAUDE.md       ./CLAUDE.md
cp -r HES_SOURCE/.claude/     ./.claude/

# Gemini CLI
cp HES_SOURCE/GEMINI.md       ./GEMINI.md

# Cursor (legacy + modern MDC)
cp HES_SOURCE/.cursorrules    ./.cursorrules
cp -r HES_SOURCE/.cursor/     ./.cursor/

# Windsurf
cp HES_SOURCE/.windsurfrules  ./.windsurfrules

# GitHub Copilot / VS Code
mkdir -p .github
cp HES_SOURCE/.github/copilot-instructions.md ./.github/copilot-instructions.md

# Kiro (AWS)
cp -r HES_SOURCE/.kiro/       ./.kiro/
```

### Tool → File Mapping

| Tool               | Native Config File                          | Also Reads       |
|--------------------|---------------------------------------------|------------------|
| Claude Code        | `CLAUDE.md` + `.claude/CLAUDE.md`           | SKILL.md         |
| OpenAI Codex CLI   | `AGENTS.md`                                 | —                |
| OpenCode           | `AGENTS.md`                                 | —                |
| Gemini CLI         | `GEMINI.md`                                 | AGENTS.md        |
| Cursor             | `.cursor/rules/hes.mdc` (+ `.cursorrules`)  | AGENTS.md        |
| GitHub Copilot     | `.github/copilot-instructions.md`           | AGENTS.md        |
| VS Code (Copilot)  | `.github/copilot-instructions.md`           | AGENTS.md        |
| Windsurf           | `.windsurfrules`                            | AGENTS.md        |
| Kiro (AWS)         | `.kiro/steering/hes.md` + `hes-phases.md`  | SKILL.md         |

### Architecture

```
AGENTS.md               ← Source of truth for cross-tool (Codex, Cursor, Windsurf, Copilot)
CLAUDE.md               ← Thin Claude Code shim → @imports SKILL.md
GEMINI.md               ← Gemini bootstrap → references SKILL.md
.cursor/rules/hes.mdc   ← Cursor MDC format with YAML frontmatter (alwaysApply: true)
.cursorrules            ← Cursor legacy (kept for compatibility)
.windsurfrules          ← Windsurf bootstrap (also reads AGENTS.md)
.github/copilot-instructions.md ← Copilot/VS Code (also reads AGENTS.md)
.kiro/steering/hes.md   ← Kiro main steering (inclusion: always)
.kiro/steering/hes-phases.md    ← Phase reference (inclusion: always)
.kiro/steering/hes-commands.md  ← Command reference (inclusion: manual)
.claude/CLAUDE.md       ← Claude Code auto-loaded identity file
```

### For Claude.ai (Web/App) — Project Instructions

In **Settings → Project → Instructions**, paste:

```
You are a Harness Engineer (HES v3.5.0). Read SKILL.md and execute the HES protocol.

Triggers: /hes | nova feature | new feature | hes start

On receiving /hes:
1. Read SKILL.md in full
2. Check .hes/state/current.json for current phase
3. Load the skill-file for that phase
4. Execute autonomously
```

---

## STEP 10 — VALIDATE INSTALLATION

> LLM runs all validation checks. If any fail, LLM retries or reports error.

```
[✓] SKILL.md exists in project root
[✓] skills/ directory exists
[✓] 18 skill files present in skills/
[✓] skills/reference/ directory exists with 4 reference files
[✓] .hes/ directory exists
[✓] .hes/state/current.json is valid JSON
[✓] .hes/state/events.log is valid JSON
[✓] .hes/agents/registry.json is valid JSON
[✓] IDE config file exists
[✓] Git working tree clean (or commit created)

Total: 1 orchestrator + 18 skill files + reference/ = 19+ files installed
```

---

## STEP 11 — COMMIT TO GIT

```
Tool calls:
1. run_shell_command("git add SKILL.md skills/")
2. run_shell_command("git commit -m 'chore: install HES v3.3.0'")
3. read_file(".git/COMMIT_EDITMSG")  → verify commit succeeded
```

If not in a git repo:
```
Skip git commit. Document: "Installation complete (no git repo)"
```

---

## STEP 12 — ANNOUNCE COMPLETION

```
✅ HES v3.3.0 — Auto-Installation Complete!

Project        : {{PROJECT_NAME}}
Stack          : {{STACK}}
IDE            : {{IDE}}
Language       : {{DETECTED_LANGUAGE}} | Mode: {{AUDIENCE_MODE}}
Files installed: 19 (1 orchestrator + 18 skills + reference/)
State          : ZERO (ready to bootstrap)

  [A] "I want to start a new feature: [name]"
      → Begin DISCOVERY phase

  [B] "/hes status"
      → View current state

  [C] "This is an existing project, analyze it"
      → Load LEGACY assessment

  [D] "I want to refactor [module]"
      → Load REFACTOR protocol

💡 Tip: Your harness is now installed. Run /hes anytime to check state.
```

---

## ◈ AUTO-INSTALL TRIGGER CONDITIONS

### Auto-trigger on first /hes:

```
When user runs /hes for first time:
1. LLM checks if .hes/state/current.json exists
2. If NO → announce: "HES not detected. Running auto-install..."
3. Execute auto-install protocol (STEPS 1-12 above)
4. Ask user to confirm auto-detected values
5. Proceed to bootstrap

When user runs /hes and .hes/ exists:
→ Normal state resumption (no auto-install)
```

### Explicit trigger:

```
/hes auto-install

→ LLM executes full auto-install protocol
→ Skips if already installed (validates and reports)
```

---

## ◈ ERROR RECOVERY

```
If auto-install fails at any step:

1. Identify the specific failing step
2. Retry the step (max 2 retries)
3. If still fails → report to user:
   "Auto-install failed at STEP X. Details: [error]
    Manual fallback: run the following commands:
    mkdir -p skills
    cp <source>/SKILL.md ./SKILL.md
    cp <source>/skills/*.md ./skills/
    cp -r <source>/skills/reference/ ./skills/
    git add SKILL.md skills/ && git commit -m 'chore: install HES v3.3.0'"
4. Log error to .hes/state/events.log with metadata
```

---

## ◈ FILE STRUCTURE SUMMARY

```
your-project/
├── SKILL.md                        ← orchestrator (step 3)
├── skills/
│   ├── 00-bootstrap.md             (phase ZERO)
│   ├── 01-discovery.md             (phase DISCOVERY)
│   ├── 02-spec.md                  (phase SPEC)
│   ├── 03-design.md                (phase DESIGN)
│   ├── 04-data.md                  (phase DATA)
│   ├── 05-tests.md                 (phase RED)
│   ├── 06-implementation.md        (phase GREEN)
│   ├── 07-review.md                (phase REVIEW)
│   ├── 08-progressive-analysis.md  (large codebase)
│   ├── 09-issue-create.md         (bug/improvement)
│   ├── tool-dispatch.md         (tool dispatch)
│   ├── agent-registry.md          (registry ref)
│   ├── auto-install.md            (self-install)
│   ├── error-recovery.md          (errors A-E)
│   ├── harness-health.md          (coverage)
│   ├── legacy.md                  (onboarding)
│   ├── refactor.md                (refactoring)
│   ├── report.md                  (learning)
│   ├── session-manager.md         (session)
│   └── reference/
│       ├── agent-identity.md
│       ├── domain-templates.md
│       ├── fitness-sensors.md
│       └── git-hooks.md
└── .hes/
    ├── state/
    │   ├── current.json           (main state)
    │   └── events.log             (event sourcing)
    ├── specs/                     (BDD artifacts)
    ├── decisions/                 (ADR files)
    ├── tasks/                     (tasks)
    ├── inventory/                 (legacy)
    └── agents/
        └── registry.json          (agent registry)
```

---

## ◈ QUICK REFERENCE

### Commands after installation

```
/hes                       → Start HES (auto-installs if needed)
/hes auto-install          → Re-run auto-install protocol
/hes start <feature>       → New feature → DISCOVERY
/hes status                → View all features + state
/hes switch <feature>      → Switch feature focus
/hes refactor <module>     → Safe refactoring
/hes report                → Batch learning report
/hes harness               → Coverage diagnostics
/hes bug                   → Create bug issue
/hes improvement           → Create improvement issue
/hes checkpoint            → Save session state
/hes clear                 → Save checkpoint + clear session
/hes language <code>       → Set/override language
/hes mode <mode>           → Set audience mode
/hes unlock --force       → Bypass phase lock
```

### Phase flow

```
ZERO → DISCOVERY → SPEC → DESIGN → DATA → RED → GREEN → REVIEW → DONE
```

### Phase gate requirements

| Transition        | Gate Required                              |
|-------------------|--------------------------------------------|
| DISCOVERY → SPEC  | Business rules list approved               |
| SPEC → DESIGN     | BDD scenarios + API contract approved      |
| DESIGN → DATA     | ADRs approved                              |
| DATA → RED        | Migrations reviewed                        |
| RED → GREEN       | ≥ 1 failing test (proof of RED)           |
| GREEN → REVIEW    | Build + all tests passing                  |
| REVIEW → DONE     | 5-dimension checklist complete             |

---

*HES v3.3.0 — Installation Guide | Josemalyson Oliveira | 2026*
*Format: install.md standard (OBJECTIVE / DONE WHEN / TODO)*
*References: Fowler (2026) · LangChain (2026) · installmd.org*