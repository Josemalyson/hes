# HES v3.5.0 — System Architecture

> Technical reference document for HES — Harness Engineer Standard.
> Based on: Fowler (2026), LangChain/Harrison (2026), OpenAI (2026), Google Research (2026).

---

## ◈ CONCEPTUAL MODEL

### What is a Harness (LangChain, 2026)

```
Agent = Model + Harness

The Harness is everything around the model:
  → Code that orchestrates the agent
  → Instructions in context (SKILL.md, skill-files)
  → Available tools (git hooks, scripts)
  → Memory (events.log, lessons.md, specs, ADRs)
```

> "Managing context, and therefore memory, is a core capability and responsibility
>  of the agent harness." — LangChain, 2026

**LLM HARNESS RESPONSIBILITY**: The LLM executing in the harness IS the harness. Each skill-file is an **inferential guide**.
Each git hook is a **computational sensor**. The specs are the **behavior harness**.

> **The LLM executing these instructions assumes full responsibility for:**
> - Reading and interpreting all skill-files
> - Making execution decisions based on the state machine
> - Using available tools to perform all actions
> - Validating outcomes via sensors
> - Learning from errors and updating lessons
> - Maintaining project state across sessions

---

## ◈ CONTROL TAXONOMY (Fowler, 2026)

```
GUIDES (feedforward — anticipate and prevent errors before acting)
┌─────────────────────────────────────────────────────────────┐
│ Inferential (semantic — executed by the LLM harness)        │
│   → SKILL.md (orchestrator)                                 │
│   → skills/01-discovery.md ~ skills/07-review.md           │
│   → .claude/CLAUDE.md (agent identity)                      │
│   → .hes/domains/*/context.md (DDD bounded context)         │
│   → .hes/decisions/ADR-*.md (architectural decisions)       │
│   → .hes/specs/*/0[1-4]-*.md (feature specs)               │
│                                                             │
│ Computational (deterministic — executed by CPU)             │
│   → pom.xml / package.json verification (pre-impl)         │
│   → Bootstrap templates (.hes/domains/*/fitness/)          │
│   → Anti-hallucination checklist (structured in skill-files)│
└─────────────────────────────────────────────────────────────┘

SENSORS (feedback — observe after acting and self-correct)
┌─────────────────────────────────────────────────────────────┐
│ Inferential (semantic)                                      │
│   → Self-refinement loop (05-tests + 06-implementation)     │
│   → Review checklist 5 dimensions (07-review)               │
│   → Harness health assessment (harness-health)              │
│                                                             │
│ Computational (deterministic)                               │
│   → LLM-executed pre-commit safety check (secrets, destructive SQL) │
│   → LLM-executed commit-msg validation (Conventional Commits) │
│   → Build + coverage report (mvn/npm test)                  │
│   → Linters (Checkstyle/ESLint/ruff)                        │
│   → ArchUnit / dep-cruiser / import-linter                  │
│   → Dependency vulnerability scanner                        │
└─────────────────────────────────────────────────────────────┘
```

> **LLM Responsibility**: The LLM MUST execute all inferential guides and sensors autonomously.
> When computational sensors require tool execution, the LLM MUST invoke appropriate tools.

---

## ◈ REGULATION DIMENSIONS (Fowler, 2026)

```
┌──────────────────────────────────────────────────────────────┐
│ MAINTAINABILITY HARNESS                                      │
│   Objective: internal code quality                           │
│   Guides:  CLAUDE.md with quality rules                      │
│            Anti-hallucination checklists in skill-files      │
│   Sensors: coverage ≥ 80%, linter, complexity check         │
│            Review checklist — "Quality" dimension            │
├──────────────────────────────────────────────────────────────┤
│ ARCHITECTURE FITNESS HARNESS                                 │
│   Objective: module boundaries + architectural drift         │
│   Guides:  03-design.md + ADRs + domain context.md          │
│            .hes/domains/*/fitness/ (domain rules)            │
│   Sensors: ArchUnit / dep-cruiser / import-linter           │
│            Review checklist — "Architecture" dimension       │
│            /hes report — offline drift detection             │
├──────────────────────────────────────────────────────────────┤
│ BEHAVIOUR HARNESS                                            │
│   Objective: the code does what the spec says               │
│   Guides:  01-discovery + 02-spec (BDD scenarios)           │
│            Traceability BR → scenario → test                │
│   Sensors: unit + integration test suite                    │
│            Self-refinement loop (05 + 06)                    │
│            Human review (07-review)                          │
└──────────────────────────────────────────────────────────────┘
```

> **LLM Responsibility**: The LLM MUST actively monitor all 3 dimensions during execution.
> When any dimension falls below threshold, the LLM MUST trigger corrective action via appropriate skill-files.

---

## ◈ LEARNING LAYERS (LangChain, 2026)

```
┌─────────────────────────────────────────────────────────────┐
│ HARNESS LAYER (skill-files, SKILL.md)                       │
│   → Evolves via self-improvement protocol                    │
│   → /hes report: batch learning over events.log             │
│   → Recurrent lesson (N ≥ 2) → corresponding skill-file    │
│   → Changes for ALL future projects                          │
├─────────────────────────────────────────────────────────────┤
│ CONTEXT LAYER (lessons.md, decisions/, context.md, specs)   │
│   → Evolves by cycle/feature/project                        │
│   → Hot path: lessons registered during errors              │
│   → Offline: consolidation via /hes report                  │
│   → Changes for THIS project only                           │
├─────────────────────────────────────────────────────────────┤
│ MEMORY = CONTEXT MANAGEMENT                                  │
│   → The harness IS the memory (LangChain, 2026)            │
│   → events.log = traces = primary source of learning loop   │
│   → lessons.md = consolidated project memory                │
│   → ADRs = permanent architectural memory                   │
└─────────────────────────────────────────────────────────────┘
```

> **LLM Responsibility**: The LLM MUST maintain and evolve the learning layers autonomously.
> On each error, the LLM MUST register lessons. On recurrent patterns, the LLM MUST update skill-files.
> The LLM MUST run /hes report periodically to perform batch learning over events.log.

---

## ◈ STATE MACHINE

Project bootstrap states (resolved before feature state machine):
  ZERO   → virgin project, no .hes/ → bootstrap
  ORPHAN → .hes/ present, no state  → legacy assessment
  LEGACY → .hes/ + state present    → normal phase routing

```
                    ZERO
                      │
          ┌───────────┴───────────┐
          │ (new project)         │ (existing project / cloned)
          ▼                       ▼
     00-bootstrap.md          ORPHAN
          │                       │
          │                       └─ legacy.md (Harnessability Assessment)
          └───────────┬───────────┘
                      │
                      ▼
         ┌────────────────────────────────────┐
         │  PRE-FLIGHT (v4.0 — /hes start --parallel)      │
         │                                    │
         │  planner.md ← analisa escopo       │
         │       │                            │
         │       ├── single-agent mode ───────┼──→ sequential flow (default)
         │       │                            │
         │       └── multi-agent mode ────────┼──→ orchestrator.md
         │               │                   │        │
         │               └───────────────────┘    [Agent Fleet em worktrees]
         └────────────────────────────────────┘        │
                      │ (single-agent ou após integração multi-agent)
                      ▼
               01-discovery.md    ← Inferential guide
                      │ approved
                      ▼
                 02-spec.md       ← Inferential guide (behaviour harness)
                      │ approved
                      ▼
                 03-design.md     ← Inferential guide (architecture fitness)
                      │ approved
                      ▼
                 04-data.md       ← Inferential guide + computational
                      │ migration ok
                      ▼
                 05-tests.md (RED) ← Inferential sensor (behaviour)
                      │ tests failing as expected
                      ▼
             06-implementation.md (GREEN)
                      │ build green
                      ▼
                 10-security.md   ← SECURITY phase (Bandit + Semgrep)
                      │ 0 HIGH findings (security-policy.yml)
                      ▼
                 07-review.md     ← Inferential sensor (5 dimensions)
                      │ ArchUnit + coverage + checklist ok
                      ▼
                    DONE
                      │
                      ├─ (every 3 cycles)
                      ▼
                 report.md        ← Batch learning (offline)
                      │
                      ▼
             harness-health.md    ← 3 dimensions diagnostics
                      │
                      ├─ (v3.8+ background)
                      ▼
             harness-evolver.md   ← Auto-evolução (LOW_RISK auto | HIGH_RISK human approval)
                      │
                      ▼
                 [improved harness]
                      │
                      ▼
               next feature ──→ loop
```

> **LLM Responsibility**: The LLM MUST execute this state machine autonomously.
> The LLM MUST NOT skip phases or advance without meeting gates.
> The LLM MUST make all execution decisions based on the current state and skill-file instructions.
> The LLM MUST use tools to perform all actions (file creation, test execution, git operations, etc.).

---

## ◈ EVENT SOURCING

```
events.log = traces = learning flywheel (LangChain, 2026)

Each event contains:
  timestamp, feature, from, to, agent, metadata
  metadata: artifacts, duration_minutes, refinement_iterations, lessons_added

Trace uses:
  → /hes report: batch analysis → harness improvement
  → /hes status: current state of all features
  → /hes rollback: identify target state to revert
  → Bottleneck diagnostics per phase
```

> **LLM Responsibility**: The LLM MUST log every state transition to events.log.
> The LLM MUST use events.log data for /hes report and /hes status commands.
> The LLM MUST analyze traces to identify patterns and improve the harness autonomously.

---

## ◈ MULTI-FEATURE + DEPENDENCY GRAPH

```json
{
  "active_feature": "payment",
  "features": {
    "payment": "DESIGN",
    "auth":    "DONE",
    "billing": "SPEC"
  },
  "dependency_graph": {
    "billing": ["payment"]
  }
}
```

Rules:
- `active_feature` = current session focus
- `/hes switch` changes focus without losing state
- Feature blocked by non-DONE dependency → automatic warning
- `/hes status` shows state of all features + dependencies

> **LLM Responsibility**: The LLM MUST manage the dependency graph autonomously.
> The LLM MUST prevent execution of blocked features and warn the user.
> The LLM MUST maintain accurate state for all concurrent features.

---

## ◈ HARNESSABILITY (Fowler, 2026)

> "Not every codebase is equally amenable to harnessing."

Strongly typed codebase + clear boundaries + DI + tests = high harnessability.
The harness adapts proportionally to the score (see `legacy.md`).

```
High   → Complete harness (all guides + sensors)
Medium → Incremental harness (start with guides + hooks)
Low    → Minimal harness (only hooks + specs) + harnessability sprint
```

> **LLM Responsibility**: The LLM MUST assess harnessability at project start.
> The LLM MUST adapt the harness depth based on the harnessability score.
> For low harnessability projects, the LLM MUST prioritize harnessability improvements.

---

## ◈ FILE STRUCTURE

```
project/
├── SKILL.md                      ← Orchestrator (read first always)
├── ARCHITECTURE.md               ← This document
├── INSTALL.md                    ← Installation guide
│
└── skills/
    ├── 00-bootstrap.md           ← HES structure + git hooks + domains
    ├── 01-discovery.md           ← Understanding + BR + UC [Inferential Guide]
    ├── 02-spec.md                ← BDD + API contract [Inferential Guide]
    ├── 03-design.md              ← Components + ADR [Inferential Guide]
    ├── 04-data.md                ← Schema + migration [Inferential + Computational]
    ├── 05-tests.md               ← RED phase [Inferential Sensor]
    ├── 06-implementation.md      ← GREEN phase [Inferential Sensor]
    ├── 07-review.md              ← 5 dimensions + DONE [Inferential Sensor]
    ├── 08-progressive-analysis.md← Large codebase (>50 files)
    ├── 09-issue-create.md        ← GitHub Issue creation
    ├── 10-security.md            ← SECURITY phase [Computational Sensor]
    ├── 11-eval.md                ← Eval harness (pass@k + LLM-as-judge)
    ├── 12-harness-tests.md       ← Harness self-testing (structural + behavioral)
    ├── legacy.md                 ← Harnessability + inventory
    ├── session-manager.md        ← Session lifecycle + checkpoints
    ├── auto-install.md           ← Auto-install protocol
    ├── error-recovery.md         ← Diagnosis by category (A-E)
    ├── refactor.md               ← Safe refactoring by type
    ├── report.md                 ← Batch learning (offline)
    ├── harness-health.md         ← 3 dimensions diagnostics
    ├── tool-dispatch.md          ← Tool dispatch protocol
    ├── agent-registry.md         ← Registry reference + schema
    │
    │   ── v4.0 ROADMAP STUBS ──────────────────────────────────────────
    │
    ├── planner.md                ← (v3.6) PRÉ-FLIGHT: decomposição de tarefas
    ├── orchestrator.md           ← (v3.7) Maestro da frota de agentes paralelos
    ├── harness-evolver.md        ← (v3.8) Auto-evolução do harness via events.log
    ├── optimizer.md              ← (v3.9) Otimização código para legibilidade de agente
    └── reviewer.md               ← (v4.0) Revisão autônoma de PR — 5 dimensões
```

> **LLM Responsibility**: The LLM MUST read SKILL.md first on every session.
> The LLM MUST load skill-files based on the current state machine phase.
> The LLM MUST execute the instructions in each skill-file without deviation.
> The LLM MUST use tools to perform all file operations, test execution, and git commands.

---

## ◈ DEV HARNESS — Repository Self-Harness

HES uses HES to develop itself. The repository root contains LLM-specific
configuration directories alongside the distributable skill-files:

```
hes/ (repository root)
├── .claude/                      ← Claude Code agent identity
│   └── CLAUDE.md                 ← Loaded automatically by Claude Code on every session
├── .hes/                         ← HES state for HES development itself
│   ├── state/current.json        ← Active feature being developed in HES
│   └── state/events.log          ← Development cycle traces
└── images/                       ← Documentation assets
```

> **Note**: `.claude/` (and equivalent per-tool dirs) are platform-specific entry points.
> They are NOT distributed to the user's project. Only `SKILL.md` and `skills/` are distributed.
> The `.hes/` directory in the repository root tracks HES's own development state.

---

## ◈ DESIGN DECISIONS — WHAT WAS LEFT OUT AND WHY

| Proposal                   | Decision       | Justification                                                  |
| -------------------------- | -------------- | -------------------------------------------------------------  |
| "Semantic RAG"             | 🔄 Adapted      | Structured context loading by convention — works with any LLM |
| Unlimited self-refinement  | 🔄 Limited      | Max 3-5 attempts + mandatory human escalation                 |
| Complete event sourcing    | ✅ Included     | `events.log` with rich metadata — learning loop foundation    |
| Multi-feature              | ✅ Included     | `dependency_graph` + `/hes switch`                            |
| DDD domains                | ✅ Included     | `.hes/domains/*/context.md + fitness/`                        |
| Architecture Fitness       | ✅ New in v3.1  | Fowler dimension missing from v3                              |
| Harnessability assessment  | ✅ New in v3.1  | Essential for legacy projects (Fowler)                        |
| Context compaction         | ✅ New in v3.1  | Explicit protocol for long sessions                           |
| Formal learning loop       | ✅ New in v3.1  | Hot path + offline (LangChain continual learning)             |
| `/hes harness`             | ✅ New in v3.1  | 3 regulation dimensions diagnostics                           |
| SECURITY phase             | ✅ New in v3.4  | Bandit + Semgrep gate before do REVIEW — bloqueante            |
| Action Event Protocol      | ✅ New in v3.4  | Debug tracking intra-phase with session_id UUID                 |
| Eval harness               | ✅ New in v3.5  | pass@k + LLM-as-judge + golden dataset + regressão            |
| Telemetria OTel-compatible | ✅ New in v3.5  | Spans with trace_id, cost_usd, duration_ms                     |
| Step + Token budget        | ✅ New in v3.5  | Hard limit por phase, escalada ao esgotar                       |
| Typed handoff schemas      | ✅ New in v3.5  | 6 JSON schemas validados em toda transição de phase            |
| Harness self-testing       | ✅ New in v3.5  | 10 structural + 5 behavioral tests do próprio harness         |
| Multi-model support        | ✅ New in v3.5  | claude.md + gpt-4o.md + default.md                            |
| Multi-agent / parallelism  | 📋 Planned v3.7 | planner.md + orchestrator.md + Git worktrees                  |
| Harness auto-evolution     | 📋 Planned v3.8 | harness-evolver.md + trust-policy LOW/MEDIUM/HIGH_RISK        |
| Autonomous PR review       | 📋 Planned v4.0 | reviewer.md — 5 dimensões, integração GitHub/GitLab           |
| Agent-readable code        | 📋 Planned v3.9 | optimizer.md — nomenclatura semântica, logs JSON, hints       |
| Security policies-as-code  | 📋 Planned v3.6 | security-policy.yml — 3 modos: default, enterprise, relaxed   |
| MCP integration            | 📋 Planned v3.9 | Protocolo padrão for ferramentas e fontes de data            |
| LangSmith observability    | 📋 Planned v3.9 | Spans do telemetry.jsonl → grafo de decisão visual            |
| Cryptographic audit trail  | 📋 Planned v4.0 | Assinatura sha256 em each transição de phase                   |

---

*HES v3.5.0 — Architecture Document*
*Referências: Fowler (2026) · LangChain Harrison (2026) · OpenAI (2026) · Google Research (2026)*
*Josemalyson Oliveira | 2026*

---

## ◈ ACTION EVENT PROTOCOL (v3.4.0)

> Resolve o gap de rastreabilidade intra-phase: eventos agora cobrem ações individuais,
> not only transições de phase.

```
events.log (antes v3.3):
  { "from": "SPEC", "to": "DESIGN", ... }   ← apenas transições

events.log (v3.4 — Action Event Protocol):
  { "action_type": "EXEC_CMD", "status": "STARTED", "target": "bandit -r .", ... }
  { "action_type": "EXEC_CMD", "status": "SUCCESS", "target": "bandit -r .", ... }
  { "action_type": "GATE_CHECK", "status": "SUCCESS", "target": "security-gate", ... }
  { "from": "SECURITY", "to": "REVIEW", ... }   ← transição de fase
```

**Componentes:**
- `scripts/hooks/log-action.sh` — executa o log de each ação
- `skills/reference/action-event-protocol.md` — protocolo e schema complete
- `.hes/state/session-id` — UUID único por sessão (gerado no bootstrap)

---

## ◈ SECURITY PHASE (v3.4.0)

new phase **SECURITY** between GREEN e REVIEW na state machine.

```
GREEN → SECURITY → REVIEW
         ↑
    Bandit + Semgrep
    (LLM-orchestrated)
    Auto-fix loop
    Gate: 0 HIGH findings
```

**flow:**
```
bandit -r . → parse JSON → triage (HIGH/MEDIUM/LOW)
  → auto-fix HIGH (max 2 tentativas/finding)
  → documenta MEDIUM/LOW como exceções
  → re-scan final → gate check
  → avança para REVIEW se gate passou
```

**Ferramenta:** `skills/10-security.md` | **Agent:** `security-agent`

---

## ◈ v4.0 MULTI-AGENT ARCHITECTURE (Roadmap)

### Visão Geral

```
┌─────────────────────────────────────────────────────────────┐
│                    HES v4.0 HARNESS                         │
│                                                             │
│  ┌─────────────┐     /hes start --parallel                  │
│  │  planner.md │ ── analisa escopo ──→ execution-plan.json  │
│  └──────┬──────┘                                            │
│         │                                                   │
│         ▼ multi-agent mode                                  │
│  ┌──────────────────┐                                       │
│  │ orchestrator.md  │  ← O Maestro                         │
│  └──────┬───────────┘                                       │
│         │ despacha em paralelo                              │
│         ├──→ [designer]    worktree: .worktrees/designer    │
│         ├──→ [data-modeler] worktree: .worktrees/data       │
│         └──→ [spec-writer]  worktree: .worktrees/spec       │
│                   │                                         │
│                   ▼ integração + merge                      │
│         fluxo sequencial padrão (RED → GREEN → SECURITY…)  │
└─────────────────────────────────────────────────────────────┘
```

### Camada de Auto-Evolução (v3.8+)

```
┌─────────────────────────────────────────────────────────────┐
│               HARNESS EVOLUTION LAYER                       │
│                                                             │
│   events.log ──→ harness-evolver.md ──→ proposals.json     │
│                         │                                   │
│                         ▼                                   │
│              trust-policy.yml                               │
│                │             │                              │
│         LOW_RISK          HIGH_RISK                         │
│       auto-apply         human approval                     │
│           │                   │                             │
│           ▼                   ▼                             │
│    skill-files.md      review → approve → apply             │
│           │                                                 │
│           └──→ harness-evolution-log.md                     │
└─────────────────────────────────────────────────────────────┘
```

### new Componentes de state (v4.0)

```json
// .hes/state/execution-plan.json — gerado pelo planner.md
{
  "feature": "payment-gateway",
  "mode": "multi-agent",
  "parallel_groups": [
    { "group": 1, "tasks": ["DESIGN", "DATA"], "depends_on": [] },
    { "group": 2, "tasks": ["RED"], "depends_on": [1] }
  ]
}

// .hes/state/fleet-status.json — gerenciado pelo orchestrator.md
{
  "agents": [
    { "agent": "designer", "status": "completed", "worktree": ".worktrees/designer" },
    { "agent": "data-modeler", "status": "running", "worktree": ".worktrees/data" }
  ]
}

// .hes/state/harness-proposals.json — gerado pelo harness-evolver.md
{
  "proposals": [
    { "id": "prop-001", "risk_level": "LOW_RISK", "target_file": "skills/02-spec.md",
      "description": "Adicionar checklist de ambiguidades ao STEP 3" }
  ]
}
```

### new RULES Propostos (v4.0)

```
RULE-29  LLM INVOKES planner.md before multi-agent execution — /hes start --parallel
RULE-30  LLM USES orchestrator.md to dispatch and monitor Agent Fleet
RULE-31  LLM READS trust-policy.yml before any harness-evolver auto-modification
RULE-32  LLM VALIDATES security-policy.yml active_policy before SECURITY gate
RULE-33  LLM APPLIES optimizer.md transformations only after test suite passes
```

> See `skills/planner.md`, `skills/orchestrator.md`, and `skills/harness-evolver.md` for full specifications.
