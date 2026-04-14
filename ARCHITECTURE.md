# HES v3.3 — System Architecture

> Technical reference document for HES — Harness Engineer Standard.
> Based on: Fowler (2026), LangChain/Harrison (2026).

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
│   → scripts/hooks/safety_validator.py (pre-commit)          │
│   → scripts/hooks/sdd_commit_checker.py (commit-msg)        │
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

```
                    ZERO
                      │
          ┌───────────┴───────────┐
          │ (new project)         │ (existing project)
          ▼                       ▼
     00-bootstrap.md          legacy.md
          │                       │
          │                  [Harnessability
          │                   Assessment]
          └───────────┬───────────┘
                      │
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
                 07-review.md     ← Inferential sensor (5 dimensions)
                      │ ArchUnit + coverage + checklist ok
                      ▼
                    DONE
                      │
                      ├─ (every 3 cycles)
                      ▼
                 report.md        ← Batch learning (offline)
                      │ improvements identified
                      ▼
             harness-health.md    ← 3 dimensions diagnostics
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
├── INSTALL.md                    ← Installation by environment (per agent: Claude Code, Cursor, web)
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
    ├── legacy.md                 ← Harnessability + inventory
    ├── session-manager.md       ← Session lifecycle + checkpoints
    ├── auto-install.md          ← Auto-install protocol (no .hes/ detected)
    ├── error-recovery.md         ← Diagnosis by category
    ├── refactor.md               ← Safe refactoring by type
    ├── report.md                 ← Batch learning (offline)
    └── harness-health.md         ← 3 dimensions diagnostics [NEW]
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
├── .claude/                      ← Claude Code agent identity (CLAUDE.md)
│   └── CLAUDE.md                 ← Loaded automatically by Claude Code on every session
├── .qwen/                        ← Qwen agent identity (equivalent to CLAUDE.md)
│   └── (agent config)
├── .hes/                         ← HES state for HES development itself
│   ├── state/current.json        ← Active feature being developed in HES
│   └── state/events.log          ← Development cycle traces
├── scripts/hooks/                ← Computational sensors (pre-commit, commit-msg)
│   ├── safety_validator.py
│   └── sdd_commit_checker.py
└── images/                       ← Documentation assets
```

> **Note**: `.claude/` and `.qwen/` are platform-specific entry points.
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

---

*HES v3.3.0 — Architecture Document*
*Referências: Fowler (2026) · LangChain Harrison (2026)*
*Josemalyson Oliveira | 2026*
