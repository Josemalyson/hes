# HES v3.4 — Technical Specification

## 1. System Overview

HES v3.4 implements a Deterministic Skill Engine (DSE) to orchestrate LLM-driven workflows.

---

## 2. Core Components

### 2.1 Dispatcher

Responsibilities:
- Load current state
- Validate state
- Select active skill
- Trigger execution

---

### 2.2 State Engine (FSM)

#### State Schema

File: `.hes/state/current.json`

```json
{
  "version": "1.0",
  "current_state": "DISCOVERY",
  "active_skill": "01-discovery.md",
  "allowed_transitions": ["SPEC"],
  "context_refs": {},
  "last_validated_at": "ISO8601"
}
```

---

#### State Rules

- State must always be valid before execution
- Transitions must be explicit
- No implicit state changes allowed

---

## 2.3 Skill Contract

Each skill must follow:

```yaml
name: string
version: string

preconditions:
  - expression

postconditions:
  - expression

produces:
  - file

requires:
  - resource

context:
  include: []
  exclude: []
```

---

## 2.4 Context Builder

### Behavior

- Loads only declared files
- Excludes irrelevant phases
- Supports lazy loading

---

## 2.5 Execution Flow

1. Load state
2. Validate state
3. Load skill
4. Build context
5. Execute skill
6. Validate output
7. Update state

---

## 2.6 Validation Layer

### Types

#### State Validation

- Valid transitions
- Schema compliance

#### Output Validation

- Required artifacts generated
- Format compliance

---

## 2.7 Recovery Mechanism

### Trigger Conditions

- Invalid state
- Missing outputs
- Execution failure

---

### Recovery Flow

1. Restore last valid state
2. Rebuild context
3. Re-execute skill

---

## 3. File Structure

```text
.hes/
  state/
    current.json
    schema/
      fsm-schema.json
      skill-contract-schema.yaml
  config.json

skills/
  00-bootstrap.md
  01-discovery.md
  ...

core/
  dispatcher.md
  context-builder.md
  validator.md
```

---

## 4. Non-Functional Requirements

### Performance

- Minimal context injection
- Token usage optimization

---

### Reliability

- 100% validated execution

---

### Determinism

- Same input must produce same structured output

---

## 5. Constraints

- LLM is non-deterministic → system must compensate
- Context window is limited → aggressive filtering required

---

## 6. FSM States

| State | Description | Next State | Gate |
|-------|-------------|------------|------|
| ZERO | Initial state, no project | DISCOVERY | None |
| DISCOVERY | Requirements gathering | SPEC | br_list_approved |
| SPEC | Specification writing | DESIGN | bdd_scenarios_approved |
| DESIGN | Architecture design | DATA | adrs_approved |
| DATA | Data modeling | RED | migrations_reviewed |
| RED | Test-first (failing tests) | GREEN | failing_test_exists |
| GREEN | Implementation | REVIEW | tests_passing |
| REVIEW | Code review | DONE | review_checklist_complete |
| DONE | Feature complete | - | - |

---

## 7. Commands

| Command | Action |
|---------|--------|
| `/hes start <feature>` | New feature → DISCOVERY |
| `/hes switch <feature>` | Switch focus |
| `/hes status` | Show state |
| `/hes rollback <phase>` | Revert phase |
| `/hes report` | Batch learning |
| `/hes refactor` | Guided refactoring |
| `/hes harness` | Diagnostics |
| `/hes error` | Error recovery |

---

## 8. Validation Checksums

Each valid state update computes:
```
checksum = SHA256(JSON.stringify(state))
```

This ensures state integrity and enables rollback to known good states.

---

## 9. Context Optimization Rules

### Always Load
- core/dispatcher.md
- core/state-validator.md
- .hes/state/current.json

### Conditional Load
- IF state == DISCOVERY: skills/01-discovery.md
- IF state == SPEC: skills/02-spec.md + specs/*
- IF state == DESIGN: skills/03-design.md + ADRs/*

### Never Load
- Other phase skills
- Previous phase artifacts (unless required)

---

## 10. Event Sourcing

All state transitions logged to `.hes/state/events.log`:

```json
{
  "timestamp": "ISO8601",
  "feature": "feature-name",
  "from": "SPEC",
  "to": "DESIGN",
  "agent": "spec-agent",
  "metadata": {}
}
```
