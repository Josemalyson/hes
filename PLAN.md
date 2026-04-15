# HES v3.4 — Execution Plan

## Strategy

Incremental migration with validation at each step.

---

## Phase 1 — Core Foundation

### Goals
- Introduce deterministic core without breaking system

### Tasks

- [ ] Define FSM schema
- [ ] Implement state validator
- [ ] Create new current.json structure
- [ ] Implement thin dispatcher (v1)

### Deliverable
- Functional dispatcher + valid state

---

## Phase 2 — Skill Contracts

### Goals
- Standardize execution model

### Tasks

- [ ] Define skill contract schema
- [ ] Refactor 00-bootstrap.md
- [ ] Implement pre/post conditions
- [ ] Add validation hooks

### Deliverable
- First skill running with contract

---

## Phase 3 — Core Pipeline Migration

### Goals
- Migrate main flow

### Tasks

- [ ] Refactor discovery
- [ ] Refactor spec
- [ ] Refactor design
- [ ] Refactor implementation

### Deliverable
- End-to-end flow working

---

## Phase 4 — Context Optimization

### Goals
- Reduce token usage

### Tasks

- [ ] Implement context builder
- [ ] Add include/exclude logic
- [ ] Add lazy loading
- [ ] Remove redundant context

### Deliverable
- Token reduction achieved

---

## Phase 5 — Validation & Recovery

### Goals
- Increase reliability

### Tasks

- [ ] Implement output validation
- [ ] Implement recovery skill
- [ ] Add fallback logic

### Deliverable
- Resilient execution

---

## Phase 6 — DX & Documentation

### Goals
- Improve usability

### Tasks

- [ ] Update README
- [ ] Update INSTALL
- [ ] Add IDE integration guides
- [ ] Document workflow

---

## PR Strategy

### PR 1 — Core Engine
- FSM + dispatcher

### PR 2 — Skill Contracts
- Schema + bootstrap

### PR 3 — Pipeline
- Core skills

### PR 4 — Optimization
- Context builder

### PR 5 — DX
- Docs + setup

---

## Risks

- Overengineering → mitigate via incremental delivery
- Skill inconsistency → enforce contracts
- State corruption → validation layer

---

## Success Criteria

- Token reduction ≥ 80%
- Deterministic execution
- Zero invalid transitions
- Full pipeline execution without manual fixes

---

## Execution Order

```
Phase 1 (Core Foundation)
├── 1.1 Create FSM schema → .hes/state/schema/fsm-schema.json
├── 1.2 Create state-validator.md
├── 1.3 Create dispatcher.md
├── 1.4 Update current.json structure

Phase 2 (Skill Contracts)
├── 2.1 Define skill-contract-schema.yaml
├── 2.2 Create context-builder.md
├── 2.3 Refactor skills/00-bootstrap.md

Phase 3 (Pipeline)
├── 3.1 Refactor 01-discovery.md
├── 3.2 Refactor 02-spec.md
├── 3.3 Refactor 03-design.md
├── 3.4 Refactor 04-data.md
├── 3.5 Refactor 05-tests.md
├── 3.6 Refactor 06-implementation.md
├── 3.7 Refactor 07-review.md

Phase 4 (Optimization)
├── 4.1 Implement context builder logic
├── 4.2 Add lazy loading
├── 4.3 Tune token budgets

Phase 5 (Validation & Recovery)
├── 5.1 Add output validation
├── 5.2 Create error-recovery.md
├── 5.3 Add fallback logic

Phase 6 (DX)
├── 6.1 Update docs
├── 6.2 Update INSTALL
├── 6.3 Final testing
```

---

## Dependencies

- Phase 1 must complete before Phase 2
- Phase 2 must complete before Phase 3
- Phase 3 must complete before Phase 4
- Phase 4 must complete before Phase 5
- Phase 5 can run parallel to Phase 6

---

## Milestones

| Milestone | Description | Target |
|-----------|-------------|--------|
| M1 | FSM + Validator working | Day 1 |
| M2 | First skill with contract | Day 2 |
| M3 | Full pipeline (manual test) | Day 3 |
| M4 | Token optimization verified | Day 4 |
| M5 | Recovery mechanism tested | Day 5 |
| M6 | Documentation complete | Day 6 |
