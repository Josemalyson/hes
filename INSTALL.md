# HES v3.3 — Installation Guide

> How the LLM harness installs and configures HES skill files in different AI environments.

> **LLM HARNESS RESPONSIBILITY**: The LLM assumes full responsibility for:
> - Detecting when HES is not installed
> - Executing auto-install protocol using available tools
> - Auto-detecting project metadata
> - Copying all files using file system tools
> - Generating .hes/ state structure
> - Validating installation
> - Committing to version control
> - Reporting any errors or issues

---

## ◈ FILE STRUCTURE (what the LLM installs)

```
your-project/
├── SKILL.md                       ← place in project root
│   └── Orchestrator file (v3.3.0) — reads state, routes to agents
│
└── skills/                        ← 19 skill files total
    ├── 00-bootstrap.md            (794 lines) — initial project setup
    ├── 01-discovery.md            — business rules elicitation
    ├── 02-spec.md                 — BDD scenarios + API contracts
    ├── 03-design.md               — architecture decisions (ADRs)
    ├── 04-data.md                 — data model + migrations
    ├── 05-tests.md                — test-first implementation (RED)
    ├── 06-implementation.md       — code implementation (GREEN)
    ├── 07-review.md               — 5-dimension review checklist
    ├── 08-progressive-analysis.md (377 lines) — large codebase analysis
    ├── 09-issue-create.md         (187 lines) — GitHub Issue creation
    ├── agent-delegation.md        (268 lines) — multi-agent delegation
    ├── agent-registry.md          (198 lines) — registry reference
    ├── auto-install.md            (~280 lines) — automated installation
    ├── error-recovery.md          (209 lines) — error diagnosis & recovery
    ├── harness-health.md          (351 lines) — coverage diagnostics
    ├── legacy.md                  (272 lines) — legacy project onboarding
    ├── refactor.md                (274 lines) — safe refactoring
    ├── report.md                  (287 lines) — batch learning reports
    └── session-manager.md         (274 lines) — session lifecycle
```

> Files in `.hes/` are generated automatically by bootstrap.
> You only manually install the files listed above.

### Skill Categories

**Phase Skills (Sequential - 8 files):** 00-bootstrap → 07-review
**Analysis & Issue Skills (2 files):** 08-progressive-analysis, 09-issue-create
**Agent & Delegation Skills (2 files):** agent-delegation, agent-registry
**System & Recovery Skills (7 files):** auto-install, error-recovery, harness-health, legacy, refactor, report, session-manager

---

## ◈ PREREQUISITES

- **Git repository** (state tracking requires version control)
- **AI coding agent** (Claude Code, Cursor, Copilot, etc.)
- **Node.js 18+** (if using CLI tools)
- **Language**: Auto-detected (pt, es, fr, de, en)

---

## ◈ AUTOMATIC INSTALLATION (RECOMMENDED)

> **LLM Responsibility**: The LLM executes the entire installation protocol autonomously.
> The LLM MUST NOT ask the user to manually copy files or run commands.
> The LLM uses file system tools to perform all installation actions.

HES v3.3 supports **fully automatic installation** executed by the LLM harness.

### Quick Start (Automatic)

```
User runs: /hes
  ↓
LLM HARNESS executes:
  1. Detects HES is not installed via file system tools
  2. Loads skills/auto-install.md
  3. Auto-detects project metadata (name, stack, IDE, domains)
  4. Copies all files using file system tools
  5. Generates .hes/ state structure
  6. Creates IDE config files
  7. Validates installation completeness
  8. Commits to version control
  9. Announces ready to use!
```

### Explicit Auto-Install

```
/hes auto-install

LLM HARNESS executes:
  ✓ Copies 19 files (1 orchestrator + 18 skills) via file system tools
  ✓ Auto-detects project metadata
  ✓ Generates .hes/ state structure
  ✓ Creates IDE config files
  ✓ Validates installation
  ✓ Commits to git
```

### What Gets Auto-Detected

| Item | Detection Method | Fallback |
|------|------------------|----------|
| Project name | `git remote` or `pwd` | "my-project" |
| Stack | Scan for pom.xml, package.json, etc. | User specifies |
| IDE | Check .claude/, .cursor/, .vscode/ | "generic" |
| Domains | Scan src/ structure | Empty array |

### Manual Override

If auto-detection is wrong, you can correct during the bootstrap questionnaire.

---

## ◈ MANUAL INSTALLATION (ALTERNATIVE)

---

## ◈ ENVIRONMENT 1 — CLAUDE CODE (CLI)

> **LLM Responsibility**: In all environments, the LLM executes all actions autonomously.

### Installation

```
LLM HARNESS executes via tools:
  1. Creates skills/ directory via file system tools
  2. Copies SKILL.md to project root via write_file
  3. Copies all skill files to skills/ directory
  4. Commits to version control via shell command
```

### Usage

Claude Code automatically reads `CLAUDE.md` at session start.
After bootstrap, `.claude/CLAUDE.md` instructs the LLM to read `SKILL.md`.

```
LLM HARNESS executes on /hes:
  → Reads state via file system tools
  → Routes to correct skill-file
  → Executes skill-file instructions
  → Reports results to user
```

### Configuration `.claude/CLAUDE.md` (generated by bootstrap)

The bootstrap generates this automatically. For manual installation:

```markdown
# HES — Harness Engineer Standard

On session start:
1. LLM reads SKILL.md completely via file system tools
2. LLM identifies state via .hes/state/current.json
3. LLM loads correct skill-file based on current phase
4. LLM executes phase-specific instructions autonomously
```

---

## ◈ ENVIRONMENT 2 — CURSOR / WINDSURF / COPILOT

Same file structure. The LLM executes HES protocol autonomously in all environments.

### LLM Configuration

```
LLM HARNESS is configured to:
  → Read SKILL.md and identify current project state
  → Execute HES v3.3 protocol on /hes command
  → Use file system tools for all file operations
  → Report results back to user
```

### Alternative — `.cursorrules`

```
# .cursorrules
On receiving /hes or any engineering command:
1. LLM reads SKILL.md in project root via file system tools
2. LLM reads .hes/state/current.json
3. LLM loads skill-file corresponding to current state
4. LLM executes skill-file instructions autonomously
```

---

## ◈ ENVIRONMENT 3 — CLAUDE.AI (Web / App)

HES v3.3 works via **Projects** in Claude.ai. The LLM executes autonomously in all environments.

### Configuration via Project Instructions

In **Settings → Project → Instructions**, add:

```
You are a Harness Engineer (HES v3.3). The LLM executes all actions autonomously.

On receiving /hes or being invoked for engineering tasks:
1. LLM reads SKILL.md content via available tools
2. LLM reads and follows orchestrator instructions
3. LLM reads skill-file content indicated by orchestrator
4. LLM executes corresponding phase autonomously
5. LLM reports results back to user

If user pastes a skill-file directly, LLM executes it immediately.
```

### Usage in chat (without Project)

Paste SKILL.md content at conversation start:

```
I'm sharing the HES v3.3 system. The LLM should read and follow instructions:

[paste SKILL.md content here]

Current state: [paste current.json content here]

LLM executes autonomously from this point.
```

---

## ◈ ENVIRONMENT 4 — OPENHANDS / CODEX CLI / GEMINI CLI

Tools supporting system prompts or configuration files. The LLM executes autonomously.

```
LLM HARNESS is configured via:

# OpenHands — via AGENT.md in root
  → LLM reads SKILL.md (copied to AGENT.md)
  → LLM executes instructions autonomously

# Codex CLI — via --system-prompt flag
  → LLM receives SKILL.md content as system prompt
  → LLM executes protocol autonomously

# Gemini CLI — via .gemini/system.md
  → LLM reads SKILL.md from .gemini/system.md
  → LLM executes protocol autonomously
```

---

## ◈ SKILL-FILE REGISTRY

HES v3.3 uses a registry-based routing system (`.hes/agents/registry.json`) with **18 specialized agents**:

### Phase Agents (Sequential)

| Phase | Agent | Skill-file | Trigger |
|-------|-------|-----------|---------|
| ZERO | harness-agent | `skills/00-bootstrap.md` | First session |
| LEGACY | harness-agent | `skills/legacy.md` | Existing codebase |
| DISCOVERY | discovery-agent | `skills/01-discovery.md` | `/hes start <feature>` |
| SPEC | spec-agent | `skills/02-spec.md` | After DISCOVERY approval |
| DESIGN | design-agent | `skills/03-design.md` | After SPEC approval |
| DATA | data-agent | `skills/04-data.md` | After DESIGN approval |
| RED | test-agent | `skills/05-tests.md` | After DATA approval |
| GREEN | impl-agent | `skills/06-implementation.md` | After RED (failing tests) |
| REVIEW | review-agent | `skills/07-review.md` | After GREEN (tests pass) |
| DONE | harness-agent | Summary + next feature | After REVIEW approval |

### System Agents

| Command | Agent | Skill-file | Purpose |
|---------|-------|-----------|---------|
| `/hes auto-install` | auto-install-agent | `skills/auto-install.md` | Automated HES installation |
| `/hes refactor <module>` | refactor-agent | `skills/refactor.md` | Safe refactoring by type (A-I) |
| `/hes report` | report-agent | `skills/report.md` | Batch learning from events.log |
| `/hes harness` | harness-health-agent | `skills/harness-health.md` | 3-dimension coverage diagnostics |
| `/hes error` or error | error-recovery-agent | `skills/error-recovery.md` | Error diagnosis (categories A-E) |
| `/hes status`, `/clear` | session-manager | `skills/session-manager.md` | Session lifecycle & checkpoints |
| `/hes bug`, `/hes improvement` | issue-create-agent | `skills/09-issue-create.md` | Auto-diagnostic GitHub Issue creation |
| — | progressive-analysis-agent | `skills/08-progressive-analysis.md` | Large codebase analysis (>50 files) |
| — | delegation-agent | `skills/agent-delegation.md` | Multi-agent dispatch protocol |
| — | registry-agent | `skills/agent-registry.md` | Registry schema reference |

### Sub-Agents

Spawned by `impl-agent` during implementation:
- `test-runner` — executes test suites
- `linter` — runs linting checks
- `arch-check` — validates architecture constraints

---

## ◈ STATE MODEL

State resides in `.hes/state/current.json`:

```json
{
  "project": "project-name",
  "stack": "Java 17 + Spring Boot",
  "ide": "claude-code",
  "active_feature": "payment",
  "features": { "payment": "DESIGN", "auth": "DONE" },
  "domains": ["billing", "auth"],
  "dependency_graph": { "payment": ["auth"] },
  "harness_version": "3.3.0",
  "agent_model": "multi-agent",
  "user_language": "en",
  "audience_mode": "expert",
  "completed_cycles": 0,
  "last_updated": "2025-01-01T00:00:00Z",
  "session": {
    "checkpoint": null,
    "phase_lock": "DESIGN",
    "messages_in_session": 0
  }
}
```

**Possible states per feature:**
```
ZERO → DISCOVERY → SPEC → DESIGN → DATA → RED → GREEN → REVIEW → DONE
```

---

## ◈ USAGE FLOW — SESSION TO SESSION

> **LLM Responsibility**: The LLM executes all session flows autonomously.

### Session 1 (new project)

```
1. User: /hes
2. LLM HARNESS reads SKILL.md → detects ZERO → loads skills/00-bootstrap.md
3. LLM executes bootstrap: asks 4 questions via prompts
4. LLM generates entire .hes/ structure via file system tools
5. LLM suggests: "What's the first feature?"
6. User: "I want to implement JWT authentication"
7. LLM loads skills/01-discovery.md → executes Discovery autonomously
```

### Session 2 (resumed)

```
1. User: /hes status
2. LLM HARNESS reads current.json via file system tools → shows state of all features
3. User: "continue"
4. LLM loads skill-file of current phase → executes autonomously
```

### Session N (parallel features)

```
1. User: /hes switch billing
2. LLM HARNESS updates active_feature → loads skill of current phase for "billing"
3. LLM executes billing phase autonomously
4. When done: /hes switch payment → LLM returns to payment
```

---

## ◈ HOW TO INVOKE A SKILL-FILE DIRECTLY

At any moment, you can invoke a specific skill-file. The LLM executes it autonomously:

```
"Read skills/03-design.md and redesign the payment module"
  → LLM loads the file → executes redesign autonomously

"We got a migration error — load skills/error-recovery.md"
  → LLM loads the file → executes error recovery autonomously

"I want to refactor PaymentService — skills/refactor.md"
  → LLM loads the file → executes refactoring autonomously

"Generate cycle report — skills/report.md"
  → LLM loads the file → executes report generation autonomously
```

The LLM loads ONLY that skill-file, without going through the orchestrator.
The LLM executes all instructions in the skill-file autonomously.

---

## ◈ COMPLETE SKILL FILE DETAILS

### Phase Skills (Sequential Execution)

| File | Lines | Agent | When Loaded | Key Functions |
|------|-------|-------|-------------|---------------|
| `00-bootstrap.md` | ~794 | harness-agent | State = ZERO | 4 questions, generates `.hes/` structure, git hooks, fitness sensors |
| `01-discovery.md` | — | discovery-agent | Feature start | Business rules capture, use case identification, domain analysis |
| `02-spec.md` | — | spec-agent | After DISCOVERY | BDD scenarios, API contracts, requirements traceability |
| `03-design.md` | — | design-agent | After SPEC | Component design, ADRs, architecture decisions |
| `04-data.md` | — | data-agent | After DESIGN | Schema design, SQL migrations (Flyway), DTOs |
| `05-tests.md` | — | test-agent | After DATA | TDD RED phase — unit/integration test templates (Java/Node/Python) |
| `06-implementation.md` | — | impl-agent | After RED | TDD GREEN phase — minimal viable implementation, sensor loops |
| `07-review.md` | — | review-agent | After GREEN | 5-dimension review: behavior, maintainability, security, observability, architecture |

### Analysis & Issue Skills

| File | Lines | Agent | Trigger | Key Functions |
|------|-------|-------|---------|---------------|
| `08-progressive-analysis.md` | ~377 | progressive-analysis-agent | Large codebase (>50 files) | Incremental analysis with state preservation, anti-hallucination protocol |
| `09-issue-create.md` | ~187 | issue-create-agent | `/hes bug`, `/hes improvement` | Auto-collect diagnostics, create structured GitHub Issues |

### Agent & Delegation Skills

| File | Lines | Agent | Purpose | Key Functions |
|------|-------|-------|---------|---------------|
| `agent-delegation.md` | ~268 | delegation-agent | Multi-agent dispatch | Dispatch protocol, sub-agent spawning, context isolation |
| `agent-registry.md` | ~198 | registry-agent | Reference | Registry schema, custom agent creation guide |

### System & Recovery Skills

| File | Lines | Agent | Trigger | Key Functions |
|------|-------|-------|---------|---------------|
| `auto-install.md` | ~280 | auto-install-agent | `/hes auto-install` or first `/hes` | Automated installation, auto-detection, validation |
| `error-recovery.md` | ~209 | error-recovery-agent | Error detection | Diagnosis by category (A-E), surgical correction, systemic prevention |
| `harness-health.md` | ~351 | harness-health-agent | `/hes harness` | 3-dimension coverage diagnostics (Maintainability, Architecture, Behaviour) |
| `legacy.md` | ~272 | legacy-agent | State = LEGACY | Inventory + harnessability assessment for existing projects |
| `refactor.md` | ~274 | refactor-agent | `/hes refactor <module>` | Safe refactoring by type (A-I), harnessability improvement |
| `report.md` | ~287 | report-agent | `/hes report` | Batch learning from events.log, harness improvement |
| `session-manager.md` | ~274 | session-manager | `/hes status`, `/clear` | Checkpoint, recovery, context bloat detection, phase lock |

---

## ◈ PHASE LOCK GATES

Phase advancement requires gate validation:

| Transition | Required Gate |
|-----------|---------------|
| DISCOVERY → SPEC | Business rules list approved by user |
| SPEC → DESIGN | BDD scenarios + API contract approved |
| DESIGN → DATA | ADRs approved |
| DATA → RED | Migrations reviewed |
| RED → GREEN | ≥1 failing test (proof of RED) |
| GREEN → REVIEW | Build + all tests passing |
| REVIEW → DONE | 5-dimension checklist complete |

**Violation** → delegated to session-manager.md

---

## ◈ MAINTENANCE TIPS

**Version skill-files with project:**
```bash
git add SKILL.md skills/
git commit -m "chore: install HES v3.3.0"
```

**Evolve skills as you learn:**
- Lessons promoted from `lessons.md` → add to corresponding skill-file
- Whenever a phase seems slow → review that phase's skill-file

**Update version:**
Change the `version` field in `SKILL.md` header after significant evolution.

**Language detection:**
Auto-detected from first messages. Override with:
```bash
/hes language pt     → Force Portuguese
/hes language en     → Force English
/hes language auto   → Re-enable auto-detection
```

**Audience mode:**
Adapts response complexity:
```bash
/hes mode beginner   → Simple explanations, step-by-step
/hes mode expert     → Technical, concise, assumes knowledge
```

---

## ◈ TROUBLESHOOTING

| Issue | Solution |
|-------|----------|
| Agent ignores /hes commands | Check SKILL.md is in project root |
| State file missing | Run `/hes` to regenerate via bootstrap |
| Wrong phase routing | Check `.hes/state/current.json` manually |
| Language not detected | Use `/hes language <code>` to override |
| Phase lock blocked | Review gate requirements or use `/hes unlock --force` |

---

## ◈ QUICK REFERENCE

### Installation Checklist

**Automatic (Recommended) — LLM Executes:**
```
[ ] User runs: /hes or /hes auto-install
[ ] LLM auto-detects project info via file system tools
[ ] LLM copies all 19 files using file system tools
[ ] LLM generates .hes/ structure
[ ] LLM commits to version control
[ ] User verifies: /hes status works
```

**Manual (Alternative):**
```
[ ] User copies SKILL.md to project root
[ ] User copies all 19 skill files to skills/ directory
[ ] User commits to version control
[ ] User runs /hes to verify installation
[ ] LLM completes bootstrap (if new project)
```

### What Gets Installed

**Automatic installation — LLM executes:**
- LLM uses file system tools to copy all files autonomously
- LLM auto-detects project metadata (name, stack, IDE)
- LLM generates .hes/ state structure autonomously
- LLM commits everything to version control
- Total: 1 orchestrator + 19 skill files (including auto-install.md)

**Manual installation:**
- **1 orchestrator file:** SKILL.md (entry point)
- **19 skill files:** 8 phase + 2 analysis + 2 delegation + 7 system
- **Total lines:** ~4,800+ lines of specialized AI agent instructions
- **Generated:** .hes/ directory structure (by bootstrap or auto-install)

### Key Commands

> **LLM Responsibility**: The LLM executes all commands autonomously when invoked.

```
/hes                       → LLM starts HES (auto-installs if needed)
/hes auto-install          → LLM executes automatic installation
/hes start <feature>       → LLM starts new feature → DISCOVERY phase
/hes status                → LLM shows all features + state
/hes switch <feature>      → LLM switches feature focus
/hes refactor <module>     → LLM executes safe refactoring
/hes report                → LLM generates batch learning report
/hes harness               → LLM runs coverage diagnostics
/hes bug                   → LLM creates bug issue
/hes improvement           → LLM creates improvement issue
/hes checkpoint            → LLM saves session state
/hes clear                 → LLM clears session (saves checkpoint)
```

---

*HES v3.3.0 — Installation Guide | Josemalyson Oliveira | 2026*
