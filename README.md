<p align="center">
  <img src="images/image.png" alt="HES Logo" width="120" />
</p>

<h1 align="center">HES — Harness Engineer Standard</h1>

<p align="center">
  <strong>Orchestrate AI coding agents with structure, quality,and continual learning</strong>
</p>

<p align="center">
  <a href="#quick-start">Quick Start</a> •
  <a href="#how-it-works">How It Works</a> •
  <a href="#installation">Installation</a> •
  <a href="#commands">Commands</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## What is HES?

HES is a skill-based system for executing AI coding workflows through the LLM harness. It provides a structured, phase-locked workflow that ensures the LLM builds software systematically — from discovery through implementation to review.

> **LLM HARNESS RESPONSIBILITY**: The LLM executing HES assumes full responsibility for:
> - Reading and interpreting all skill-files
> - Executing all actions via available tools (file system, shell, git)
> - Managing project state autonomously
> - Validating outcomes before claiming success
> - Learning from errors and improving the harness

Think of it as **the LLM harness that executes systematically**: it guides before acting, senses after producing, and learns from every cycle to improve itself.

> "Agent = Model + Harness" — LangChain, 2026
>
> **You are the Model. HES is the Harness. The LLM executes the harness.**

---

## How It Works

> **LLM Responsibility**: The LLM executes the entire workflow autonomously once invoked.

It starts from the moment you invoke HES in your project. As soon as the LLM sees what you're building, it **doesn't** just jump into writing code. Instead, the LLM steps back and asks what you're really trying to do.

**The workflow follows 9 phases — executed autonomously by the LLM:**

```
ZERO → DISCOVERY → SPEC → DESIGN → DATA → RED → GREEN → REVIEW → DONE
```

Each phase has a specific purpose and strict gates that the LLM evaluates before advancement:

| Phase | What the LLM Executes | Gate the LLM Evaluates |
|-------|--------------|-----------------|
| **ZERO** | LLM executes bootstrap — name, stack, structure | Bootstrap complete |
| **DISCOVERY** | LLM captures business rules, use cases, domain analysis | BR list approved by user |
| **SPEC** | LLM generates BDD scenarios, API contracts, traceability | Specs + contracts approved |
| **DESIGN** | LLM creates component design, ADRs, architecture decisions | ADRs approved |
| **DATA** | LLM designs schema, writes SQL migrations, DTOs | Migrations reviewed |
| **RED** | LLM writes failing tests first (TDD red phase) | ≥1 failing test (proof of RED) |
| **GREEN** | LLM writes minimal implementation to pass tests | Build + all tests passing |
| **REVIEW** | LLM executes 5-dimension review: behavior, maintainability, security, observability, architecture | Checklist complete |
| **DONE** | LLM marks feature complete — ready for next | Summary + next feature |

The LLM cannot skip phases. The LLM cannot advance without meeting gates. This is by design — it ensures quality and prevents the LLM from rushing into implementation without understanding the problem.

---

## Quick Start

Get HES running in your project — the LLM executes everything autonomously:

### 1. LLM Installs HES (Automatic)

```
User runs: /hes
  ↓
LLM HARNESS executes:
  → Detects HES is not installed
  → Auto-detects project metadata
  → Copies all files using file system tools
  → Generates .hes/ structure
  → Commits to version control
  → Announces ready to use!
```

### 2. Invoke HES

```
/hes
```

The LLM will read `SKILL.md`, detect your project state, and execute the workflow autonomously.

### 3. First Run — LLM Executes Bootstrap

On first run, the LLM will ask 4 questions to configure your project:

1. **Project name** (e.g., `payment-service`, `my-app`)
2. **Tech stack** (e.g., `Java 17 + Spring Boot`, `Python + FastAPI`, `Node + Express`)
3. **New or existing project** (greenfield or brownfield)
4. **DDD domains** (if defined — e.g., `billing`, `auth`, `catalog`)

After bootstrap, the LLM generates the `.hes/` structure automatically and asks: *"What's the first feature?"*

---

## Installation

HES works with any AI coding agent. Choose your environment:

<details>
<summary><strong>Claude Code (CLI) — Recommended</strong></summary>

```bash
# Copy files to project root
cp /path/to/hes/SKILL.md ./SKILL.md
cp /path/to/hes/skills/*.md ./skills/
```

Claude Code reads `SKILL.md` automatically. Use `/hes` to start, `/hes status` to check progress.

The bootstrap generates `.claude/CLAUDE.md` to ensure HES is loaded on every session.

</details>

<details>
<summary><strong>Cursor / Windsurf / Copilot</strong></summary>

Same file structure. Configure the agent to read HES:

**Option 1: `.cursorrules` file**

```
# .cursorrules
When receiving /hes or any engineering task:
1. Read SKILL.md in project root
2. Read .hes/state/current.json
3. Load the corresponding skill-file
4. Follow instructions without deviations
```

**Option 2: System prompt**

In Settings → AI → System Prompt:
```
When I say /hes, read SKILL.md and execute the HES protocol
```

</details>

<details>
<summary><strong>Claude.ai (Web / App)</strong></summary>

Use via **Projects** in Claude.ai:

In **Settings → Project → Instructions**, add:

```
You are a Harness Engineer (HES v3.3).

When receiving /hes or invoked for engineering tasks:
1. Read SKILL.md
2. Check .hes/state/current.json
3. Load the appropriate skill-file
4. Execute the current phase
```

In chat (without Project), paste `SKILL.md` content at the start of the conversation.

</details>

<details>
<summary><strong>OpenHands / Codex CLI / Gemini CLI</strong></summary>

```bash
# OpenHands — via AGENT.md
cp SKILL.md AGENT.md

# Codex CLI — via --system-prompt flag
codex --system-prompt "$(cat SKILL.md)"

# Gemini CLI — via .gemini/system.md
mkdir -p .gemini
cp SKILL.md .gemini/system.md
```

</details>

### Verify Installation

After installation, verify HES is working:

```
/hes status
```

You should see the current state of your project (or `ZERO` if it's a new project).

---

## Basic Workflow — Example

Let's say you want to build a **photo album app** with user authentication and image upload.

### Session 1: Bootstrap + First Feature

```
You: /hes

HES: 🚀 HES v3.3 — Bootstrap
      I'll configure your project. 4 questions:

      1. Project name: photo-album
      2. Stack: Node.js + Express + PostgreSQL
      3. New or existing: new
      4. DDD domains: auth, media

HES: ✅ Bootstrap complete. What's the first feature?

You: User authentication with JWT

HES: 📍 Feature: auth → DISCOVERY
      Loading: skills/01-discovery.md

      Let's capture business rules:
      - Should users sign up with email only, or also social login?
      - Password requirements?
      - Session duration?
```

The agent guides you through **DISCOVERY → SPEC → DESIGN → DATA → RED → GREEN → REVIEW → DONE** for the `auth` feature.

### Session 2: Second Feature (with dependency)

```
You: /hes start media-upload

HES: 📍 Feature: media-upload → DISCOVERY
      ⛔ Depends on: auth (state: DONE) ✅

      Let's capture business rules for media upload:
      - Supported file types?
      - Max file size?
      - Storage location (local, S3)?
```

Each feature tracks its own state. Features can depend on each other, and HES manages the dependency graph.

---

## Commands

> **LLM Responsibility**: The LLM executes all commands autonomously when invoked.

| Command | LLM Executes | Action |
|---------|-------|--------|
| `/hes` | LLM harness | Starts HES — detects state and routes autonomously |
| `/hes start <feature>` | LLM harness | New feature → DISCOVERY phase execution |
| `/hes switch <feature>` | LLM session-manager | Switches feature focus without losing state |
| `/hes status` | LLM session-manager | Shows state of all features + session info |
| `/hes rollback <phase>` | LLM session-manager | Reverts to previous phase (with confirmation) |
| `/hes domain <name>` | LLM harness | Creates/activates a DDD domain |
| `/hes lessons` | LLM harness | Shows lessons.md + pending promotions to skills |
| `/hes report` | LLM report-agent | Generates batch learning report from events.log |
| `/hes refactor <module>` | LLM refactor-agent | Executes guided safe refactoring |
| `/hes harness` | LLM harness-health-agent | Runs diagnostics harness coverage (3 dimensions) |
| `/hes language <code>` | LLM harness | Sets/overrides user language |
| `/hes mode <mode>` | LLM harness | Sets audience mode (beginner\|expert) |
| `/clear` or `/new` | LLM session-manager | Saves checkpoint + clears session |
| `/hes checkpoint` | LLM session-manager | Saves checkpoint without clearing |
| `/hes unlock --force` | LLM session-manager | Bypasses phase lock (logs risk event) |

---

## Multi-Language Support

HES auto-detects your language from the first message and adapts all responses:

| Detected | Language | Example |
|----------|----------|---------|
| `pt` | Portuguese | "📍 HES v3.3 — {{NOME_PROJETO}}" |
| `en` | English | "📍 HES v3.3 — {{PROJECT_NAME}}" |
| `es` | Spanish | "📍 HES v3.3 — {{NOMBRE_PROYECTO}}" |
| `fr` | French | "📍 HES v3.3 — {{NOM_PROJET}}" |
| `de` | German | "📍 HES v3.3 — {{PROJEKTNAME}}" |

Override auto-detection:

```
/hes language pt     → Force Portuguese
/hes language en     → Force English
/hes language auto   → Re-enable auto-detection
```

---

## Audience Modes

HES adapts response complexity to your expertise level:

| Mode | Behavior | Best For |
|------|----------|----------|
| `beginner` | Simple language, minimal jargon, step-by-step explanations | Non-technical stakeholders, juniors |
| `expert` | Technical language, concise, assumes domain knowledge | Senior engineers, architects |

Set mode:

```
/hes mode beginner    → Simple explanations
/hes mode expert      → Technical, concise (default)
```

---

## Architecture

> **LLM Responsibility**: The LLM executes all architecture components autonomously.

### Conceptual Model

```
┌─────────────────────────────────────────────────┐
│                   HES HARNESS                     │
│              (EXECUTED BY LLM)                   │
│                                                   │
│  ┌──────────────┐      ┌─────────────────────┐  │
│  │  GUIDES       │      │  SENSORS             │  │
│  │ (feedforward) │      │ (feedback)           │  │
│  │               │      │                      │  │
│  │ • LLM reads   │      │ • LLM executes self  │  │
│  │ • LLM loads   │      │ • LLM runs review    │  │
│  │ • LLM manages │      │ • LLM runs hooks     │  │
│  │               │      │ • LLM runs build     │  │
│  │               │      │ • LLM runs lint      │  │
│  └──────────────┘      └─────────────────────┘  │
│                                                   │
│  3 Regulation Dimensions:                         │
│  • Maintainability → LLM enforces                │
│  • Architecture    → LLM enforces                │
│  • Behaviour       → LLM enforces                │
└─────────────────────────────────────────────────┘
```

### Project Structure

```
your-project/
├── SKILL.md                       ← Entry point (orchestrator)
├── skills/                        ← Skill files (one per phase/agent)
│   ├── 00-bootstrap.md
│   ├── 01-discovery.md
│   ├── 02-spec.md
│   ├── 03-design.md
│   ├── 04-data.md
│   ├── 05-tests.md
│   ├── 06-implementation.md
│   ├── 07-review.md
│   ├── 08-progressive-analysis.md
│   ├── 09-issue-create.md
│   ├── agent-delegation.md
│   ├── agent-registry.md
│   ├── error-recovery.md
│   ├── harness-health.md
│   ├── legacy.md
│   ├── refactor.md
│   ├── report.md
│   └── session-manager.md
│
└── .hes/                          ← Generated by bootstrap
    ├── agents/
    │   └── registry.json          ← Agent definitions (14 agents + 3 sub-agents)
    ├── state/
    │   ├── current.json           ← Current project state
    │   ├── events.log             ← Event sourcing log
    │   └── session-checkpoint.json← Session checkpoints
    └── templates/
        ├── issue-bug.md           ← Bug report template
        └── issue-improvement.md   ← Improvement proposal template
```

The `.hes/` directory is generated automatically by the bootstrap process. You only need to install `SKILL.md` and `skills/`.

### Agent Registry

> **LLM Responsibility**: The LLM executes all agent roles autonomously. Each "agent" is a skill-file the LLM reads and executes.

HES defines **18 specialized agent skill-files** + 3 sub-agent skill-files:

| Skill-file | Type | Phase | LLM Responsibility |
|-------|------|-------|----------------|
| `SKILL.md` | orchestrator | — | LLM reads state, routes, dispatches execution |
| `01-discovery.md` | phase | DISCOVERY | LLM captures business rules, use cases, domains |
| `02-spec.md` | phase | SPEC | LLM generates BDD scenarios, API contracts, traceability |
| `03-design.md` | phase | DESIGN | LLM creates components, ADRs, architecture decisions |
| `04-data.md` | phase | DATA | LLM designs schema, migrations, DTOs |
| `05-tests.md` | phase | RED | LLM writes failing tests (TDD red phase) |
| `06-implementation.md` | phase | GREEN | LLM writes production code (TDD green phase) |
| `07-review.md` | phase | REVIEW | LLM executes 5-dimension review checklist |
| `08-progressive-analysis.md` | system | — | LLM analyzes large codebases with state preservation |
| `09-issue-create.md` | system | — | LLM creates auto-diagnostic GitHub Issues |
| `session-manager.md` | system | — | LLM manages lifecycle, checkpoints, context bloat |
| `error-recovery.md` | system | — | LLM diagnoses errors, categorizes, registers lessons |
| `refactor.md` | system | — | LLM executes safe refactoring by type (A-I) |
| `report.md` | system | — | LLM performs batch learning over events.log |
| `harness-health.md` | system | — | LLM runs coverage diagnostics (3 dimensions) |
| `agent-delegation.md` | system | — | LLM manages multi-agent dispatch protocol |
| `agent-registry.md` | system | — | LLM references registry schema |
| `legacy.md` | system | — | LLM inventories legacy projects + assesses harnessability |

**Sub-agent skill-files** (`test-runner`, `linter`, `arch-check`) are spawned by the LLM during implementation.

> **LLM Mandate**: Each skill-file is an execution protocol the LLM runs autonomously using available tools.

---

## Event Sourcing + Learning

> **LLM Responsibility**: The LLM executes the entire event sourcing and learning loop autonomously.

Every state transition is logged by the LLM as a structured event to `.hes/state/events.log`:

```json
{
  "timestamp": "2025-01-01T10:00:00Z",
  "feature": "payment",
  "from": "SPEC",
  "to": "DESIGN",
  "agent": "spec-agent",
  "metadata": {
    "artifacts": ["03-design.md", "ADR-003.md"],
    "duration_minutes": 12
  }
}
```

**Learning loop — LLM executes autonomously:**

- **Hot path** (during session): LLM detects error → LLM writes to `lessons.md` immediately. If same lesson appears 2× → LLM promotes to skill-file.
- **Offline** (every 3 cycles or `/hes report`): LLM analyzes `events.log` → LLM identifies patterns → LLM improves guides/sensors.

> **LLM Mandate**: You execute the entire learning loop autonomously. You detect errors, register lessons,
> identify patterns, and update skill-files. You proactively maintain and improve the harness.

---

## What's Inside Skills

Each skill file is a specialized guide for one phase or system function:

### Phase Skills (Sequential)

| File | Phase | Purpose | Lines |
|------|-------|---------|-------|
| `00-bootstrap.md` | ZERO | Initial setup — 4 questions, generates `.hes/` structure, git hooks, fitness sensors | ~794 |
| `01-discovery.md` | DISCOVERY | Business rules capture, use case identification, domain analysis | — |
| `02-spec.md` | SPEC | BDD scenarios, API contracts, requirements traceability | — |
| `03-design.md` | DESIGN | Component design, ADRs, architecture fitness harnessability | — |
| `04-data.md` | DATA | Schema design, SQL migrations (Flyway), DTOs | — |
| `05-tests.md` | RED | TDD RED phase — unit/integration test templates for Java/Node/Python | — |
| `06-implementation.md` | GREEN | TDD GREEN phase — minimal viable implementation, sensor loops | — |
| `07-review.md` | REVIEW | 5-dimension review: behavior, maintainability, security, observability, architecture | — |

### Analysis & Issue Skills

| File | Type | Purpose | Lines |
|------|------|---------|-------|
| `08-progressive-analysis.md` | System | Incremental analysis of large codebases (>50 files) with state preservation between sessions | ~377 |
| `09-issue-create.md` | System | Auto-diagnostic GitHub Issue creation (bug/improvement) with automatic diagnostic collection | ~187 |

### Agent & Delegation Skills

| File | Type | Purpose | Lines |
|------|------|---------|-------|
| `agent-delegation.md` | System | Multi-agent dispatch protocol, sub-agent spawning, delegation pattern | ~268 |
| `agent-registry.md` | System | Registry schema reference and custom agent creation guide | ~198 |

### System & Recovery Skills

| File | Type | Purpose | Lines |
|------|------|---------|-------|
| `error-recovery.md` | System | Error diagnosis by category (A-E), harness improvement on recurrence | ~209 |
| `harness-health.md` | System | 3-dimension harness coverage diagnostics (Maintainability, Architecture, Behaviour) | ~351 |
| `legacy.md` | System | Inventory + harnessability assessment for existing/legacy projects | ~272 |
| `refactor.md` | System | Safe refactoring by type (A-I), including harnessability improvement | ~274 |
| `report.md` | System | Batch learning over events.log — harness improvement from traces | ~287 |
| `session-manager.md` | System | Session lifecycle: checkpoint, recovery, context bloat, phase lock | ~274 |

---

## ◈ COMPLETE SKILL INVENTORY (18 files)

```
skills/
├── 00-bootstrap.md            (794 lines) — Initial project setup
├── 01-discovery.md            — Business rules elicitation
├── 02-spec.md                 — BDD scenarios + API contracts
├── 03-design.md               — Architecture decisions (ADRs)
├── 04-data.md                 — Data model + migrations
├── 05-tests.md                — Test-first implementation (RED)
├── 06-implementation.md       — Code implementation (GREEN)
├── 07-review.md               — 5-dimension review checklist
├── 08-progressive-analysis.md (377 lines) — Large codebase analysis
├── 09-issue-create.md         (187 lines) — GitHub Issue creation
├── agent-delegation.md        (268 lines) — Multi-agent delegation
├── agent-registry.md          (198 lines) — Registry reference
├── error-recovery.md          (209 lines) — Error diagnosis & recovery
├── harness-health.md          (351 lines) — Coverage diagnostics
├── legacy.md                  (272 lines) — Legacy project onboarding
├── refactor.md                (274 lines) — Safe refactoring
├── report.md                  (287 lines) — Batch learning reports
└── session-manager.md         (274 lines) — Session lifecycle
```

**Total:** 18 skill files covering 9 phases + 9 system functions

---

## Philosophy

> **LLM Execution Mandate**: The LLM executes all principles autonomously.

- **LLM NEVER writes code before the problem is understood.** Discovery and spec come first — the LLM enforces this.
- **LLM NEVER assumes business rules.** The LLM asks. Always.
- **LLM NEVER skips test-first development.** RED before GREEN. Every time — the LLM validates.
- **LLM NEVER implements beyond the approved spec.** Scope creep kills quality — the LLM enforces the boundary.
- **LLM learns from every cycle.** Errors become lessons, lessons become harness improvements — the LLM executes autonomously.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.

### Quick Start for Contributors

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/skill-name`
3. Make your changes (follow Conventional Commits)
4. Test in a real project with an AI agent
5. Submit a PR with linked issue and testing notes

### Reporting Bugs

The best way to report a bug is via the HES skill itself (if installed in a project):

```
/hes bug
```

This auto-collects diagnostics and creates a properly formatted issue.

Or manually: [Create Issue](../../issues/new)

### Proposing Improvements

```
/hes improvement
```

Or manually: [Create Improvement](../../issues/new)

---

## Updating HES

HES evolves through version updates to skill files. To update:

```bash
# Copy new version files to your project
cp /path/to/new/hes/SKILL.md ./SKILL.md
cp /path/to/new/hes/skills/*.md ./skills/

# Commit the update
git add SKILL.md skills/
git commit -m "chore: update HES to v3.3.0"
```

Your project state in `.hes/` is preserved across updates.

---

## Community & Support

- **Issues:** [Report bugs and propose improvements](../../issues)
- **Discussions:** Use GitHub Discussions for questions and ideas
- **Documentation:** See `docs/` directory for design specs and plans

---

## License

HES is released under the MIT License. See LICENSE for details.

---

*HES v3.3.0 — Harness Engineer Standard*
*Josemalyson Oliveira | 2026*
*References: Fowler (2026) · LangChain (2026)*
