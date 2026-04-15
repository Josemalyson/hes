---
name: harness-engineer
version: 3.4.0
trigger: /hes | /harness | "iniciar projeto" | "analisar projeto" | "nova feature" | "hes start" | "hes status" | "hes switch"
author: Josemalyson Oliveira | 2026
framework: HES — Harness Engineer Standard v3.4 (DSE)
references:
  - "Fowler 2026: Harness Engineering for Coding Agent Users"
  - "LangChain 2026: Deterministic Skill Engine Architecture"
  - "ADR-001: Migration to Deterministic Skill Engine"
---

# HES SKILL v3.4 — Deterministic Skill Engine (DSE)

> **DSE MANDATE**: This is HES v3.4 running in Deterministic Skill Engine mode.
> Execution follows FSM-defined states with explicit transitions.
> Context is built per-skill via context-builder.md to minimize tokens.
> State is validated before every skill execution.

---

## Architecture Overview

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
│                    STATE UPDATE                          │
│              .hes/state/current.json                     │
└─────────────────────────────────────────────────────────┘
```

---

## Execution Protocol

### Step 1: Load State

```
READ .hes/state/current.json
IF NOT exists:
  IF .hes/ NOT exists:
    SET project_state = "ZERO"
    LOAD skills/00-bootstrap.md
    EXECUTE bootstrap
  ELSE:
    SET project_state = "ORPHAN"
    LOAD skills/legacy.md
    EXECUTE legacy-assessment
```

### Step 2: Validate State

```
CALL core/state-validator.md
IF validation_result.valid == false:
  HANDLE validation errors
  RETURN
```

### Step 3: Build Context

```
CALL core/context-builder.md
context = BUILD_CONTEXT(current.json)
```

### Step 4: Route to Skill

```
state = current.json.current_state
skill = ROUTING_TABLE[state]

IF command == "/hes start":
  skill = "skills/00-bootstrap.md"
IF command == "/hes status":
  skill = "skills/session-manager.md"
IF command == "/hes report":
  skill = "skills/report.md"
```

### Step 5: Execute Skill

```
LOAD skill
EXECUTE skill.instructions
COLLECT execution_result
```

### Step 6: Validate Output

```
IF skill.postconditions NOT met:
  REPORT failure
  RETURN
```

### Step 7: Update State

```
IF execution_result.success:
  UPDATE current.json
  LOG transition to events.log
  COMPUTE new checksum
```

---

## FSM States

| State | Skill File | Gate |
|-------|------------|------|
| ZERO | `skills/00-bootstrap.md` | None |
| DISCOVERY | `skills/01-discovery.md` | None |
| SPEC | `skills/02-spec.md` | br_list_approved |
| DESIGN | `skills/03-design.md` | bdd_scenarios_approved |
| DATA | `skills/04-data.md` | adrs_approved |
| RED | `skills/05-tests.md` | migrations_reviewed |
| GREEN | `skills/06-implementation.md` | failing_test_exists |
| REVIEW | `skills/07-review.md` | tests_passing |
| DONE | (summary) | review_checklist_complete |

---

## Phase Gates

| Transition | Gate | Description |
|------------|------|-------------|
| DISCOVERY → SPEC | br_list_approved | BR list approved by user |
| SPEC → DESIGN | bdd_scenarios_approved | BDD scenarios + API contract approved |
| DESIGN → DATA | adrs_approved | ADRs approved |
| DATA → RED | migrations_reviewed | Migrations reviewed |
| RED → GREEN | failing_test_exists | ≥1 failing test exists |
| GREEN → REVIEW | tests_passing | Build + all tests passing |
| REVIEW → DONE | review_checklist_complete | 5-dimension checklist complete |

---

## Project States

| State | Description | Action |
|-------|-------------|--------|
| ZERO | No .hes/ directory | Run bootstrap |
| ORPHAN | .hes/ exists, no current.json | Run legacy assessment |
| LEGACY | .hes/ exists, current.json exists | Normal operation |
| ACTIVE | Feature in progress | Continue execution |

---

## Context Optimization

### Token Budget

```
MAX_CONTEXT_TOKENS = 15000
RESERVED = 2000
AVAILABLE = 13000
```

### Load Strategy

```
ALWAYS:
  - core/dispatcher.md
  - core/state-validator.md
  - .hes/state/current.json

CONDITIONAL:
  - Current phase skill only
  - Current phase artifacts
  - Referenced specs/ADRs

NEVER:
  - Other phase skills
  - Unrelated feature artifacts
```

---

## Commands

| Command | Skill | Action |
|---------|-------|--------|
| `/hes` | dispatcher | Show status |
| `/hes start <feature>` | 00-bootstrap.md | New feature |
| `/hes status` | session-manager.md | Show state |
| `/hes switch <feature>` | session-manager.md | Switch feature |
| `/hes rollback <phase>` | session-manager.md | Revert phase |
| `/hes report` | report.md | Batch learning |
| `/hes refactor` | refactor.md | Guided refactoring |
| `/hes harness` | harness-health.md | Diagnostics |
| `/hes lessons` | error-recovery.md | Lessons review |
| `/hes error` | error-recovery.md | Error recovery |
| `/hes language <code>` | (inline) | Set language |
| `/hes mode <mode>` | (inline) | Set audience mode |

---

## State File Format

```json
{
  "version": "1.0",
  "project_state": "LEGACY",
  "current_state": "DISCOVERY",
  "active_skill": "skills/01-discovery.md",
  "allowed_transitions": ["SPEC"],
  "context_refs": {
    "include": [],
    "exclude": []
  },
  "last_validated_at": "ISO8601",
  "validation_checksum": "sha256:...",
  "feature_context": {
    "active_feature": "payment",
    "features": { "payment": "DISCOVERY" },
    "dependency_graph": {}
  },
  "project_metadata": {
    "project": "my-project",
    "stack": "Java 17",
    "user_language": "pt-BR",
    "audience_mode": "expert"
  },
  "session": {
    "checkpoint": null,
    "phase_lock": null,
    "messages_in_session": 0
  }
}
```

---

## Event Sourcing

All transitions logged to `.hes/state/events.log`:

```json
{
  "timestamp": "ISO8601",
  "feature": "payment",
  "from": "DISCOVERY",
  "to": "SPEC",
  "agent": "discovery-agent",
  "metadata": {
    "artifacts": ["br-list.md"],
    "duration_minutes": 15
  }
}
```

---

## Validation Checksum

Each state update computes:

```
checksum = SHA256(JSON.stringify(state))
```

This ensures state integrity and enables rollback.

---

## Announce Format

```
📍 HES v3.4.0 — {{PROJECT_NAME}} (DSE Mode)
State     : {{CURRENT_STATE}}
Feature   : {{ACTIVE_FEATURE}}
Skill     : {{ACTIVE_SKILL}}
Language  : {{USER_LANGUAGE}} | Mode: {{AUDIENCE_MODE}}
Cycles    : {{COMPLETED_CYCLES}}

▶ Executing: {{SKILL_NAME}}
```

---

## LLM Execution Responsibilities

```
1. STATE MANAGEMENT
   → Read current.json on session start
   → Update state after phase advancement
   → Log transitions to events.log

2. VALIDATION
   → Validate state before skill execution
   → Check gate satisfaction before transition
   → Verify output against postconditions

3. CONTEXT BUILDING
   → Load only declared context files
   → Apply token budget optimization
   → Prevent cross-phase contamination

4. SKILL EXECUTION
   → Execute skill instructions via tools
   → Do NOT exceed skill scope
   → Report results accurately
```

---

## Absolute Rules

```
RULE-01   NEVER skip state validation before execution
RULE-02   NEVER load files outside context_refs
RULE-03   NEVER transition without gate satisfaction
RULE-04   NEVER skip checksum computation
RULE-05   NEVER log incomplete transitions
RULE-06   ALWAYS use context-builder for context
RULE-07   ALWAYS validate output against postconditions
RULE-08   ALWAYS compute validation checksum
RULE-09   NEVER assume—always verify
RULE-10   In doubt? ASK the user
```

---

## Migration from v3.3

| v3.3 Component | v3.4 Equivalent |
|----------------|-----------------|
| Monolithic SKILL.md | Thin dispatcher + skills |
| Phase embedded in rules | FSM in schema |
| All context loaded | Context builder (per-skill) |
| Implicit transitions | Explicit gates |
| No state checksum | SHA256 validation |

---

## Integration Points

- **Uses:** `core/dispatcher.md`, `core/state-validator.md`, `core/context-builder.md`
- **Dispatches to:** All `skills/XX-*.md` files
- **Validates with:** `.hes/state/schema/fsm-schema.json`
- **Updates:** `.hes/state/current.json`, `.hes/state/events.log`

---

*HES SKILL v3.4.0 — Deterministic Skill Engine (DSE)*
*References: ADR-001 · LangChain 2026 · Josemalyson Oliveira | 2026*
