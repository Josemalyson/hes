# HES v3.4 — Execution Plan

## Strategy

Incremental migration with validation at each step.

---

## Phase 1 — Core Foundation ✅

### Goals
- Introduce deterministic core without breaking system

### Tasks

- [x] Define FSM schema
- [x] Implement state validator
- [x] Create new current.json structure
- [x] Implement thin dispatcher (v1)

### Deliverable
- Functional dispatcher + valid state

---

## Phase 2 — Skill Contracts ✅

### Goals
- Standardize execution model

### Tasks

- [x] Define skill contract schema
- [x] Refactor 00-bootstrap.md
- [x] Implement pre/post conditions
- [x] Add validation hooks

### Deliverable
- First skill running with contract

---

## Phase 3 — Core Pipeline Migration ✅

### Goals
- Migrate main flow

### Tasks

- [x] Refactor discovery
- [x] Refactor spec
- [x] Refactor design
- [x] Refactor data
- [x] Refactor tests
- [x] Refactor implementation
- [x] Refactor review

### Deliverable
- End-to-end flow working

---

## Phase 4 — Context Optimization ✅

### Goals
- Reduce token usage

### Tasks

- [x] Implement context builder
- [x] Add include/exclude logic
- [x] Add lazy loading
- [x] Remove redundant context

### Deliverable
- Token reduction achieved

---

## Phase 5 — Validation & Recovery ✅

### Goals
- Increase reliability

### Tasks

- [x] Implement output validation
- [x] Implement recovery skill
- [x] Add fallback logic

### Deliverable
- Resilient execution

---

## Phase 6 — DX & Documentation ✅

### Goals
- Improve usability

### Tasks

- [x] Update README
- [x] Update INSTALL
- [x] Add IDE integration guides
- [x] Document workflow

---

## PR Strategy

### PR 1 — Core Engine ✅
- FSM + dispatcher

### PR 2 — Skill Contracts ✅
- Schema + bootstrap

### PR 3 — Pipeline ✅
- Core skills

### PR 4 — Optimization ✅
- Context builder

### PR 5 — DX ✅
- Docs + setup

---

## Implementation Summary

### Core Components Created

| Component | File | Description |
|-----------|------|-------------|
| Dispatcher | `core/dispatcher.md` | Thin orchestrator |
| State Validator | `core/state-validator.md` | FSM validation |
| Context Builder | `core/context-builder.md` | Token optimization |
| Output Validator | `core/output-validator.md` | Postcondition check |

### Schema Files

| Schema | File | Description |
|--------|------|-------------|
| FSM | `.hes/state/schema/fsm-schema.json` | State transitions |
| Skill Contract | `.hes/state/schema/skill-contract-schema.yaml` | Skill metadata |

### Skills with Contracts

| Skill | File | Status |
|-------|------|--------|
| Bootstrap | `skills/00-bootstrap.md` | ✅ Contract |
| Discovery | `skills/01-discovery.md` | ✅ Contract |
| Spec | `skills/02-spec.md` | ✅ Contract |
| Design | `skills/03-design.md` | ✅ Contract |
| Data | `skills/04-data.md` | ✅ Contract |
| Tests | `skills/05-tests.md` | ✅ Contract |
| Implementation | `skills/06-implementation.md` | ✅ Contract |
| Review | `skills/07-review.md` | ✅ Contract |
| Legacy | `skills/legacy.md` | ✅ Contract |
| Error Recovery | `skills/error-recovery.md` | ✅ Contract |
| Session Manager | `skills/session-manager.md` | ✅ Contract |
| Report | `skills/report.md` | ✅ Contract |
| Harness Health | `skills/harness-health.md` | ✅ Contract |
| Refactor | `skills/refactor.md` | ✅ Contract |

---

## Risks

- Overengineering → mitigated via incremental delivery
- Skill inconsistency → enforced via contracts
- State corruption → validation layer in place

---

## Success Criteria

- [x] Token reduction ≥ 80% (via context builder)
- [x] Deterministic execution (via FSM)
- [x] Zero invalid transitions (via state validator)
- [x] Full pipeline execution without manual fixes

---

## DSE Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    THIN DISPATCHER                       │
│                   core/dispatcher.md                     │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   STATE VALIDATOR                        │
│                  core/state-validator.md                 │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│              CONTEXT BUILDER (per skill)                  │
│                 core/context-builder.md                  │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                      SKILL EXECUTION                     │
│              skills/XX-*.md (contract-based)             │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   OUTPUT VALIDATOR                       │
│                  core/output-validator.md                │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                    STATE UPDATE                          │
│              .hes/state/current.json                     │
└─────────────────────────────────────────────────────────┘
```

---

*HES v3.4.0 — Deterministic Skill Engine (DSE) — All Phases Complete*
