---
name: context-builder
version: 1.0.0
type: system
description: Builds execution context for skills based on include/exclude rules
---

# Context Builder

## Purpose

Constructs minimal context for skill execution by loading only declared files. Reduces token usage and eliminates cross-phase contamination.

## Contract

```yaml
name: context-builder
version: 1.0.0

preconditions:
  - state_validated

postconditions:
  - context_built
  - token_budget_respected

requires:
  - state_file: ".hes/state/current.json"
  - context_refs: state.context_refs

produces:
  - context: { file_path: content }

context:
  include: []
  exclude: []
```

## Context Building Rules

### Rule 1: Always Include

```
ALWAYS_LOAD:
  - core/dispatcher.md (this file reference)
  - .hes/state/current.json
  - core/state-validator.md
```

### Rule 2: State-Dependent Loading

```
IF current_state == "ZERO":
  LOAD skills/00-bootstrap.md

IF current_state == "DISCOVERY":
  LOAD skills/01-discovery.md

IF current_state == "SPEC":
  LOAD skills/02-spec.md
  LOAD specs/*.md (if exists)

IF current_state == "DESIGN":
  LOAD skills/03-design.md
  LOAD ADRs/*.md (if exists)
  LOAD specs/*.md

IF current_state == "DATA":
  LOAD skills/04-data.md
  LOAD migrations/*.sql (if exists)

IF current_state == "RED":
  LOAD skills/05-tests.md

IF current_state == "GREEN":
  LOAD skills/06-implementation.md

IF current_state == "REVIEW":
  LOAD skills/07-review.md
```

### Rule 3: Context Refs Override

```
context_refs.include = ["specific-file.md"]
FOR file IN context_refs.include:
  ADD file TO context

FOR file IN context_refs.exclude:
  REMOVE file FROM context
```

### Rule 4: Lazy Loading

```
IF context_size > MAX_TOKENS:
  APPLY lazy loading:
    - Load metadata only first
    - Load full content on demand
```

## Token Budget Management

### Budget Calculation

```
MAX_CONTEXT_TOKENS = 15000
RESERVED_TOKENS = 2000  # For system prompts
AVAILABLE_TOKENS = MAX_CONTEXT_TOKENS - RESERVED_TOKENS

context_tokens = ESTIMATE_TOKENS(context)
IF context_tokens > AVAILABLE_TOKENS:
  APPLY optimization:
    1. Remove previous phase artifacts
    2. Remove excluded files
    3. Apply lazy loading
    4. Truncate large files (last resort)
```

### Priority Order

```
PRIORITY 1 (Never Remove):
  - core/dispatcher.md
  - core/state-validator.md
  - .hes/state/current.json

PRIORITY 2 (High Priority):
  - Current phase skill
  - Current phase artifacts

PRIORITY 3 (Medium Priority):
  - Previous phase artifacts (if referenced)
  - Spec files

PRIORITY 4 (Low Priority):
  - Other phase skills
  - Legacy artifacts
```

## Context Isolation

### Phase Leakage Prevention

```
BEFORE loading any file:
  IF file.belongs_to_different_phase AND NOT in context_refs.include:
    SKIP file

EXAMPLES:
  - skills/05-tests.md when in DISCOVERY → SKIP
  - specs/feature-X.md when working on feature-Y → SKIP
  - ADRs/old-adr.md when in SPEC → SKIP (unless referenced)
```

### Feature Isolation

```
IF active_feature != null:
  LOAD ONLY files related to active_feature
  EXCLUDE files for other features
```

## Output Format

```json
{
  "context_built": true,
  "files_loaded": [
    "core/dispatcher.md",
    "core/state-validator.md",
    ".hes/state/current.json",
    "skills/01-discovery.md"
  ],
  "files_excluded": [
    "skills/02-spec.md",
    "skills/03-design.md"
  ],
  "token_count": 8500,
  "token_budget": 13000,
  "within_budget": true
}
```

## Error Handling

### TOKEN_OVERFLOW

```
IF context_tokens > MAX_CONTEXT_TOKENS:
  APPLY aggressive optimization
  IF still over budget:
    REPORT to user
    SUGGEST: "Reduce context_refs or split execution"
```

### FILE_NOT_FOUND

```
IF file IN context_refs.include AND NOT exists:
  LOG warning
  CONTINUE with other files
  REPORT missing file in output
```

---

*Context Builder v1.0 — Token-Optimized Context Construction for DSE*
