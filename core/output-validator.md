---
name: output-validator
version: 1.0.0
type: system
description: Validates skill outputs against postconditions
---

# Output Validator

## Purpose

Validates that skill execution produced all required artifacts and met postconditions.

## Contract

```yaml
name: output-validator
version: 1.0.0

preconditions:
  - skill_executed

postconditions:
  - validation_result_returned

requires:
  - skill_contract: "skill header YAML"
  - execution_result

produces:
  - validation_result: { valid: boolean, errors: array, artifacts: array }

context:
  include: []
  exclude: ["skills/*"]
```

## Validation Steps

### Step 1: Load Skill Contract

```
READ skill header YAML (name, version, produces, postconditions)
```

### Step 2: Check Required Artifacts

```
FOR each artifact IN skill.produces:
  IF artifact is file:
    IF NOT EXISTS(artifact):
      COLLECT error: "MISSING_ARTIFACT: {artifact}"
  
  IF artifact is pattern (e.g., "src/**/*.java"):
    IF NOT MATCHES_ANY(artifact):
      COLLECT error: "MISSING_ARTIFACT_PATTERN: {artifact}"
```

### Step 3: Evaluate Postconditions

```
FOR each condition IN skill.postconditions:
  result = EVALUATE(condition)
  IF result == false:
    COLLECT error: "POSTCONDITION_FAILED: {condition}"
```

### Step 4: Return Result

```
IF errors.length > 0:
  RETURN { valid: false, errors: errors, artifacts: checked_artifacts }
ELSE:
  RETURN { valid: true, errors: [], artifacts: checked_artifacts }
```

## Artifact Patterns

| Pattern | Meaning |
|---------|---------|
| `{{feature}}/01-discovery.md` | Exact file path |
| `src/**/*.java` | Any Java file in src/ |
| `tests/unit/{{feature}}/*.test.*` | Test files with any extension |
| `.hes/decisions/ADR-*.md` | Any ADR file |

## Error Types

| Error | Meaning | Recovery |
|-------|---------|----------|
| MISSING_ARTIFACT | Required file not created | Create the file |
| MISSING_ARTIFACT_PATTERN | No files match glob pattern | Create at least one |
| POSTCONDITION_FAILED | Condition not met | Fix the issue |
| INVALID_FORMAT | Output format incorrect | Reformat |

## Integration

- Called by: `dispatcher.md` after skill execution
- Updates: none (read-only validation)

---

*Output Validator v1.0 — Skill Output Validation for DSE*
