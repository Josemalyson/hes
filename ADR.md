# ADR-001: Migration to Deterministic Skill Engine (DSE)

## Status
Accepted

## Context

The current HES (v3.3.0) operates as a monolithic prompt-based orchestrator, where all rules, flows, and context are embedded in a single SKILL.md file.

Problems identified:
- High token consumption due to large system prompt
- Lack of determinism in execution
- Context leakage between phases (hallucinations)
- Difficult scalability and maintainability
- Tight coupling between phases

The system behaves probabilistically rather than deterministically.

---

## Decision

We will migrate HES to a **Deterministic Skill Engine (DSE)** architecture, composed of:

- Thin Dispatcher
- Finite State Machine (FSM)
- Context Builder
- Skill Runtime
- Validation Layer

---

## Key Architectural Changes

### 1. Thin Dispatcher
- Replaces monolithic SKILL.md
- Responsible only for orchestration
- Delegates execution to skills

---

### 2. Finite State Machine (FSM)
- Explicit state transitions
- Prevents invalid flows
- Guarantees execution order

---

### 3. Stateless Skills (Contract-based)
- Each skill is self-contained
- No implicit dependency on previous context
- Operates via declared inputs/outputs

---

### 4. Context Isolation
- Only required files are loaded per skill
- Eliminates cross-phase contamination
- Reduces token usage

---

### 5. Validation Layer
- State validation
- Schema validation
- Output validation

---

## Alternatives Considered

### ❌ Keep Monolithic Prompt
Rejected due to:
- Token inefficiency
- Lack of scalability

---

### ❌ Multi-Agent System
Rejected (for now) due to:
- High complexity
- Coordination overhead

---

### ❌ Fully Stateless (No State File)
Rejected due to:
- Loss of execution traceability
- Reduced determinism

---

## Consequences

### ✅ Positive

- Deterministic execution
- Significant token reduction
- Modular architecture
- Easier extensibility

---

### ⚠️ Negative

- Increased architectural complexity
- Need for strict validation
- Initial migration effort

---

## Future Considerations

- Multi-agent orchestration
- Distributed execution
- Observability (tracing, metrics)

---

## Decision Owner
HES Core Architecture

## Date
2026-04-15
