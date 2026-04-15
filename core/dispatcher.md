---
name: dispatcher
version: 1.0.0
type: orchestrator
description: Thin dispatcher for HES v3.4 Deterministic Skill Engine
---

# HES Dispatcher v1.0 — Thin Orchestrator

## Purpose

Orchestrate HES execution with minimal context. Delegates to skills, doesn't execute logic.

## Contract

```yaml
name: dispatcher
version: 1.0.0

preconditions:
  - state_validated

postconditions:
  - skill_executed
  - state_updated

requires:
  - state_file: ".hes/state/current.json"
  - validator: "core/state-validator.md"

produces:
  - execution_result
  - state_update

context:
  include: ["core/state-validator.md"]
  exclude: ["skills/*"]
```

## Execution Flow

### Phase 1: Bootstrap

```
IF .hes/state/current.json NOT exists:
  IF .hes/ NOT exists:
    STATE = "ZERO"
    LOAD skills/00-bootstrap.md
    EXECUTE bootstrap
    RETURN
  ELSE:
    STATE = "ORPHAN"
    LOAD skills/legacy.md
    EXECUTE legacy-assessment
    RETURN
```

### Phase 2: Validate State

```
CALL state-validator.md
IF validation_result.valid == false:
  HANDLE validation errors
  RETURN
```

### Phase 3: Route to Skill

```
state = current.json.current_state
active_feature = current.json.feature_context.active_feature

IF state == "ZERO":
  skill = "skills/00-bootstrap.md"
ELIF active_feature != null:
  skill = MAP[state]
ELSE:
  skill = "skills/00-bootstrap.md"

LOAD skill
```

### Phase 4: Build Context

```
context_refs = current.json.context_refs
context = {}

FOR file IN context_refs.include:
  context[file] = READ(file)

FOR file IN context_refs.exclude:
  SKIP file
```

### Phase 5: Execute Skill

```
EXECUTE skill with context
COLLECT execution_result
```

### Phase 6: Update State

```
IF execution_result.success:
  UPDATE current.json
  LOG transition to events.log
  
RETURN execution_result
```

## Routing Table

| State | Skill | Gate |
|-------|-------|------|
| ZERO | `skills/00-bootstrap.md` | None |
| DISCOVERY | `skills/01-discovery.md` | None |
| SPEC | `skills/02-spec.md` | br_list_approved |
| DESIGN | `skills/03-design.md` | bdd_scenarios_approved |
| DATA | `skills/04-data.md` | adrs_approved |
| RED | `skills/05-tests.md` | migrations_reviewed |
| GREEN | `skills/06-implementation.md` | failing_test_exists |
| REVIEW | `skills/07-review.md` | tests_passing |
| DONE | (summary) | review_checklist_complete |

## Command Routing

| Command | Skill |
|---------|-------|
| `/hes` | dispatcher (this file) |
| `/hes start <feature>` | `skills/00-bootstrap.md` |
| `/hes status` | `skills/session-manager.md` |
| `/hes switch <feature>` | `skills/session-manager.md` |
| `/hes rollback <phase>` | `skills/session-manager.md` |
| `/hes report` | `skills/report.md` |
| `/hes refactor` | `skills/refactor.md` |
| `/hes harness` | `skills/harness-health.md` |
| `/hes lessons` | `skills/error-recovery.md` |

## Context Optimization

### Load Strategy

```
ALWAYS_LOAD:
  - core/dispatcher.md
  - core/state-validator.md
  - .hes/state/current.json

CONDITIONAL_LOAD:
  - IF state == DISCOVERY: skills/01-discovery.md
  - IF state == SPEC: skills/02-spec.md + specs/*
  - IF state == DESIGN: skills/03-design.md + ADRs/*
  - etc.

NEVER_LOAD:
  - Other phase skills
  - Previous phase artifacts (unless required)
```

### Token Budget

```
MAX_CONTEXT_TOKENS = 15000

current_usage = ESTIMATE_TOKENS(context)
IF current_usage > MAX_CONTEXT_TOKENS:
  APPLY context_refs.exclude rules
  RE-ESTIMATE
```

## Error Handling

```
ON validation_error:
  LOG to events.log
  REPORT to user
  SUGGEST recovery action
  
ON execution_error:
  LOG to events.log
  LOAD skills/error-recovery.md
  EXECUTE recovery protocol
  
ON timeout:
  CHECKPOINT current state
  INFORM user
  WAIT for continuation
```

## State Updates

After successful skill execution:

```json
{
  "action": "update_state",
  "updates": {
    "current_state": "{{next_state}}",
    "active_skill": "{{skill_path}}",
    "allowed_transitions": "{{allowed_next}}",
    "last_validated_at": "{{ISO8601}}",
    "validation_checksum": "{{sha256}}"
  },
  "log_event": {
    "timestamp": "{{ISO8601}}",
    "feature": "{{feature_name}}",
    "from": "{{previous_state}}",
    "to": "{{next_state}}",
    "agent": "{{agent_name}}",
    "metadata": {}
  }
}
```

## Announce Format

```
📍 HES v3.4.0 — {{PROJECT_NAME}} (DSE Mode)
State     : {{CURRENT_STATE}}
Feature   : {{ACTIVE_FEATURE}}
Skill     : {{ACTIVE_SKILL}}
Language  : {{USER_LANGUAGE}} | Mode: {{AUDIENCE_MODE}}

▶ Executing: {{SKILL_NAME}}
```

## Integration

- **Uses:** `core/state-validator.md`
- **Dispatches to:** All skill files
- **Updates:** `.hes/state/current.json`, `.hes/state/events.log`

---

*HES Dispatcher v1.0 — Thin Orchestrator for Deterministic Skill Engine*
