---
name: state-validator
version: 1.0.0
type: system
description: Validates HES state against FSM schema before execution
---

# State Validator

## Purpose

Ensures state integrity before any skill execution. Validates:
- Schema compliance
- Valid transitions
- Gate satisfaction

## Contract

```yaml
name: state-validator
version: 1.0.0

preconditions:
  - state_file_exists: ".hes/state/current.json"
  - schema_file_exists: ".hes/state/schema/fsm-schema.json"

postconditions:
  - validation_result_returned
  - checksum_computed

requires:
  - state_file: ".hes/state/current.json"
  - schema_file: ".hes/state/schema/fsm-schema.json"

produces:
  - validation_result: { valid: boolean, errors: array, checksum: string }

context:
  include: []
  exclude: ["skills/*"]
```

## Validation Steps

### Step 1: Load State

```
READ .hes/state/current.json
IF not exists:
  RETURN { valid: false, errors: ["STATE_FILE_MISSING"], state: "ZERO" }
```

### Step 2: Load Schema

```
READ .hes/state/schema/fsm-schema.json
IF not exists:
  RETURN { valid: false, errors: ["SCHEMA_FILE_MISSING"] }
```

### Step 3: Schema Compliance

```
VALIDATE state against schema
IF validation fails:
  COLLECT all validation errors
  RETURN { valid: false, errors: errors }
```

### Step 4: Transition Validation

```
current_state = state.current_state
proposed_transition = state.proposed_transition (if any)

IF proposed_transition:
  allowed = schema.transition_rules[current_state].allowed_next
  IF proposed_transition NOT IN allowed:
    RETURN {
      valid: false,
      errors: ["INVALID_TRANSITION"],
      detail: "Cannot transition from {current_state} to {proposed_transition}"
    }
```

### Step 5: Gate Check (Optional)

```
IF check_gates == true:
  gate = schema.transition_rules[current_state].gate
  IF gate != null:
    gate_result = EVALUATE gate
    IF gate_result != true:
      RETURN {
        valid: false,
        errors: ["GATE_NOT_SATISFIED"],
        detail: "Gate '{gate}' not satisfied"
      }
```

### Step 6: Compute Checksum

```
checksum = SHA256(JSON.stringify(state))
state.validation_checksum = checksum
state.last_validated_at = ISO8601_NOW()
```

### Step 7: Return Result

```
RETURN {
  valid: true,
  errors: [],
  checksum: checksum,
  state: state
}
```

## Recovery Actions

### STATE_FILE_MISSING

```
IF project_state == "ZERO":
  TRIGGER auto-install
ELSE IF .hes/ exists:
  SET project_state = "ORPHAN"
  TRIGGER legacy-assessment
ELSE:
  TRIGGER bootstrap
```

### SCHEMA_FILE_MISSING

```
COPY default schema from core/schemas/fsm-schema.json
RE-RUN validation
```

### INVALID_TRANSITION

```
LOG error to events.log
REPORT to user with allowed transitions
WAIT for user decision
```

### GATE_NOT_SATISFIED

```
REPORT which gate failed
SUGGEST actions to satisfy gate
BLOCK advancement
```

## Integration Points

- Called by: `dispatcher.md` before skill execution
- Calls: `error-recovery.md` on validation failure
- Updates: `.hes/state/current.json` with checksum and timestamp

## Output Format

```json
{
  "valid": true,
  "errors": [],
  "checksum": "sha256:abc123...",
  "state": { ... },
  "validated_at": "2026-04-15T10:00:00Z"
}
```

Or on failure:

```json
{
  "valid": false,
  "errors": ["INVALID_TRANSITION"],
  "detail": "Cannot transition from DESIGN to GREEN",
  "allowed_transitions": ["DATA"],
  "recovery_hint": "Complete DATA phase first"
}
```

---

*State Validator v1.0 — FSM State Validation for Deterministic Skill Engine*
