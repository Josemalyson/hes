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

HES is a skill-based system for orchestrating AI coding agents (Claude Code, Cursor, Copilot, Gemini CLI, and others). It provides a structured, phase-locked workflow that ensures AI agents build software systematically — from discovery through implementation to review.

Think of it as **a harness for AI agents**: it guides before acting, senses after producing, and learns from every cycle to improve itself.

> "Agent = Model + Harness" — LangChain, 2026

HES is the harness. It turns an enthusiastic AI with poor project context into a disciplined engineer who follows specs, writes tests, and respects architecture boundaries.

---

## How It Works

It starts from the moment you invoke HES in your project. As soon as it sees what you're building, it **doesn't** just jump into writing code. Instead, it steps back and asks what you're really trying to do.

**The workflow follows 9 phases:**

```
ZERO → DISCOVERY → SPEC → DESIGN → DATA → RED → GREEN → REVIEW → DONE
```

Each phase has a specific purpose and strict gates that prevent advancement until requirements are met:

| Phase | What Happens | Gate to Advance |
|-------|--------------|-----------------|
| **ZERO** | Project bootstrap — name, stack, structure | Bootstrap complete |
| **DISCOVERY** | Business rules, use cases, domain analysis | BR list approved |
| **SPEC** | BDD scenarios, API contracts, requirements traceability | Specs + contracts approved |
| **DESIGN** | Component design, ADRs, architecture decisions | ADRs approved |
| **DATA** | Schema design, SQL migrations, DTOs | Migrations reviewed |
| **RED** | Write failing tests first (TDD red phase) | ≥1 failing test (proof of RED) |
| **GREEN** | Minimal implementation to pass tests | Build + all tests passing |
| **REVIEW** | 5-dimension review: behavior, maintainability, security, observability, architecture | Checklist complete |
| **DONE** | Feature complete — ready for next | Summary + next feature |

You can't skip phases. You can't advance without meeting gates. This is by design — it ensures quality and prevents the AI from rushing into implementation without understanding the problem.

---

## Quick Start

Get HES running in your project in under 2 minutes:

### 1. Copy skill files to your project

```bash
# In your project root
cp /path/to/hes/SKILL.md ./SKILL.md
mkdir -p skills
cp /path/to/hes/skills/*.md ./skills/
```

### 2. Invoke HES

```
/hes
```

That's it. The AI agent will read `SKILL.md`, detect your project state, and guide you through the workflow.

### 3. First Run — Bootstrap

On first run, HES will ask 4 questions to configure your project:

1. **Project name** (e.g., `payment-service`, `my-app`)
2. **Tech stack** (e.g., `Java 17 + Spring Boot`, `Python + FastAPI`, `Node + Express`)
3. **New or existing project** (greenfield or brownfield)
4. **DDD domains** (if defined — e.g., `billing`, `auth`, `catalog`)

After bootstrap, HES generates the `.hes/` structure automatically and asks: *"What's the first feature?"*

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

| Command | Agent | Action |
|---------|-------|--------|
| `/hes` | harness-agent | Start HES — detects state and routes |
| `/hes start <feature>` | harness-agent | New feature → DISCOVERY phase |
| `/hes switch <feature>` | session-manager | Switch feature focus without losing state |
| `/hes status` | session-manager | Show state of all features + session info |
| `/hes rollback <phase>` | session-manager | Revert to previous phase (with confirmation) |
| `/hes domain <name>` | harness-agent | Create or activate a DDD domain |
| `/hes lessons` | harness-agent | View lessons.md + pending promotions to skills |
| `/hes report` | report-agent | Generate batch learning report from events.log |
| `/hes refactor <module>` | refactor-agent | Guided safe refactoring by type |
| `/hes harness` | harness-health-agent | Diagnostic harness coverage (3 dimensions) |
| `/hes language <code>` | harness-agent | Set/override user language (`pt`, `en`, `es`, `auto`) |
| `/hes mode <mode>` | harness-agent | Set audience mode (`beginner`, `expert`) |
| `/clear` or `/new` | session-manager | Save checkpoint + clear session |
| `/hes checkpoint` | session-manager | Save checkpoint without clearing |
| `/hes unlock --force` | session-manager | Bypass phase lock (logs risk event) |

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

### Conceptual Model

```
┌─────────────────────────────────────────────────┐
│                   HES HARNESS                     │
│                                                   │
│  ┌──────────────┐      ┌─────────────────────┐  │
│  │  GUIDES       │      │  SENSORS             │  │
│  │ (feedforward) │      │ (feedback)           │  │
│  │               │      │                      │  │
│  │ • SKILL.md    │      │ • Self-refinement    │  │
│  │ • skill-files │      │ • Review checklist   │  │
│  │ • specs, ADRs │      │ • Git hooks          │  │
│  │               │      │ • Build + coverage   │  │
│  │               │      │ • Linters, ArchUnit  │  │
│  └──────────────┘      └─────────────────────┘  │
│                                                   │
│  3 Regulation Dimensions:                         │
│  • Maintainability Harness                         │
│  • Architecture Fitness Harness                    │
│  • Behaviour Harness                               │
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

HES defines **18 specialized agents** + 3 sub-agents:

| Agent | Type | Phase | Responsibility | Skill File |
|-------|------|-------|----------------|------------|
| `harness-agent` | orchestrator | — | Default router, reads state, dispatches | `SKILL.md` |
| `discovery-agent` | phase | DISCOVERY | Captures business rules, use cases, domains | `01-discovery.md` |
| `spec-agent` | phase | SPEC | BDD scenarios, API contracts, traceability | `02-spec.md` |
| `design-agent` | phase | DESIGN | Components, ADRs, architecture decisions | `03-design.md` |
| `data-agent` | phase | DATA | Schema design, migrations, DTOs | `04-data.md` |
| `test-agent` | phase | RED | Writes failing tests (TDD red phase) | `05-tests.md` |
| `impl-agent` | phase | GREEN | Writes production code (TDD green phase) | `06-implementation.md` |
| `review-agent` | phase | REVIEW | 5-dimension review checklist | `07-review.md` |
| `progressive-analysis-agent` | system | — | Large codebase analysis with state preservation | `08-progressive-analysis.md` |
| `issue-create-agent` | system | — | Auto-diagnostic GitHub Issue creation | `09-issue-create.md` |
| `session-manager` | system | — | Lifecycle, checkpoints, context bloat detection | `session-manager.md` |
| `error-recovery-agent` | system | — | Error diagnosis, categorization, lessons | `error-recovery.md` |
| `refactor-agent` | system | — | Safe refactoring by type (A-I) | `refactor.md` |
| `report-agent` | system | — | Batch learning over events.log | `report.md` |
| `harness-health-agent` | system | — | Coverage diagnostics (3 dimensions) | `harness-health.md` |
| `delegation-agent` | system | — | Multi-agent dispatch protocol | `agent-delegation.md` |
| `registry-agent` | system | — | Registry schema reference | `agent-registry.md` |
| `legacy-agent` | system | — | Legacy project inventory + harnessability | `legacy.md` |

**Sub-agents** (`test-runner`, `linter`, `arch-check`) are spawned by `impl-agent` during implementation.

---

## Event Sourcing + Learning

Every state transition is logged as a structured event to `.hes/state/events.log`:

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

**Learning loop:**

- **Hot path** (during session): Error → `lessons.md` immediately. If same lesson appears 2× → promote to skill-file.
- **Offline** (every 3 cycles or `/hes report`): Analyze `events.log` → identify patterns → improve guides/sensors.

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

- **Never write code before the problem is understood.** Discovery and spec come first.
- **Never assume business rules.** Ask. Always.
- **Never skip test-first development.** RED before GREEN. Every time.
- **Never implement beyond the approved spec.** Scope creep kills quality.
- **Learn from every cycle.** Errors become lessons, lessons become harness improvements.

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
