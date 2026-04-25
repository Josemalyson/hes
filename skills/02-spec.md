# HES Skill — 02: Spec (BDD + API Contract)

> Skill loaded when: feature.state = SPEC
> Precondition: `01-discovery.md` approved by the user.

---

## ◈ CONTEXT TO LOAD BEFORE ACTING

```
1. Read .hes/specs/{{feature}}/01-discovery.md in full
2. Identify: all RN-xx, UC-xx, integrations, acceptance criteria
3. Check if 02-spec.md exists (session resumption)
4. Check .hes/tasks/lessons.md for specification lessons
```

---

## ◈ GOLDEN RULE OF SPEC

> Each BDD scenario must be traceable to an RN or UC from discovery.
> Each RN must have at least 1 BDD scenario that validates it.
> Error messages must be SPECIFIC — never generic.

---

## ◈ STEP 1 — GENERATE `.hes/specs/{{FEATURE_SLUG}}/02-spec.md`

```markdown
# Specification — {{FEATURE_NAME}}

Date: {{CURRENT_DATE}} | Version: 1.0
Derived from: 01-discovery.md | Feature: {{FEATURE_SLUG}}

---

## BDD Scenarios

Feature: {{FEATURE_NAME}}
  As {{PERSONA}}
  I want {{ACTION}}
  So that {{BUSINESS_OUTCOME}}

  # ─── Happy Path ────────────────────────────────────────────

  Scenario: {{MAIN_SCENARIO_NAME}}
    Given {{SPECIFIC_PRECONDITION}}
    When {{USER_OR_SYSTEM_ACTION}}
    Then {{EXPECTED_RESULT}}
    And {{ADDITIONAL_VALIDATION_IF_ANY}}
    # Covers: UC-01, RN-01

  # ─── Input Validations ─────────────────────────────────────

  Scenario: missing required field — {{FIELD}}
    Given {{PRECONDITION}}
    When the request is sent without the "{{FIELD}}" field
    Then the system returns HTTP 400
    And the body contains {"error": "{{FIELD}} is required"}
    # Covers: RN-0x

  Scenario: invalid format — {{FIELD}}
    Given {{PRECONDITION}}
    When the "{{FIELD}}" field contains "{{INVALID_VALUE}}"
    Then the system returns HTTP 422
    And the body contains {"error": "{{FIELD}} must be {{EXPECTED_FORMAT}}"}

  # ─── Business Rules ────────────────────────────────────────

  Scenario: RN-01 violation — {{RULE_NAME}}
    Given {{PRECONDITION_THAT_VIOLATES_RN}}
    When {{ACTION}}
    Then the system returns HTTP {{STATUS_CODE}}
    And the body contains {"error": "{{SPECIFIC_RN_ERROR_MESSAGE}}"}
    # Covers: RN-01

  # ─── Edge Cases ────────────────────────────────────────────

  Scenario: {{EDGE_CASE_IDENTIFIED_IN_DISCOVERY}}
    Given {{PRECONDITION}}
    When {{ACTION}}
    Then {{RESULT}}
    # Covers: RN-0x

---

## API Contract

### {{HTTP_METHOD}} {{ROUTE}}

**Required headers:**
```
Authorization: Bearer {{TOKEN}}
Content-Type: application/json
```

**Request Body:**
```json
{
  "{{field_1}}": "{{type}} — {{description}} — {{required|optional}}",
  "{{field_2}}": "{{type}} — {{description}} — {{required|optional}}"
}
```

**Response 200/201:**
```json
{
  "{{field}}": "{{type}} — {{description}}"
}
```

**Error Map:**
| HTTP | Error Code | Message to Client | When It Occurs |
|------|-----------|-------------------|----------------|
| 400  | MISSING_FIELD  | "{{field}} is required" | Required field missing |
| 422  | INVALID_FORMAT | "{{field}} must be {{format}}" | Invalid format |
| 409  | ALREADY_EXISTS | "{{entity}} already exists" | Duplicate |
| 404  | NOT_FOUND      | "{{entity}} not found" | Resource does not exist |
| 403  | FORBIDDEN      | "No permission to {{action}}" | Authorization denied |
| 500  | INTERNAL_ERROR | "Internal error. Contact support." | Unhandled exception |

---

## Domain Model

### Entity: {{ENTITY_NAME}}
| Field | Type | Required | Validation Rule | RN |
|-------|------|----------|-----------------|-----|
| id | UUID | Yes | Auto-generated | — |
| {{field}} | {{type}} | {{yes/no}} | {{rule}} | RN-0x |
| created_at | ISO 8601 | Yes | Auto-generated | — |
| updated_at | ISO 8601 | Yes | Auto-generated | — |

---

## Traceability: Scenarios x Business Rules

| Business Rule | Scenario(s) that cover | Status |
|---------------|----------------------|--------|
| RN-01 — {{RULE}} | Scenario: {{name}} | ✅ Covered |
| RN-02 — {{RULE}} | Scenario: {{name}} | ✅ Covered |

> Rules without coverage = incomplete spec. Do not advance without 100% coverage.

---

## Approval
- [ ] Do all UC and RN from discovery have scenario coverage?
- [ ] Are error messages specific (not generic)?
- [ ] Does the API contract cover all entity fields?
- [ ] Approved by user to advance to Step 3 (DESIGN)
```

---

## ◈ STEP 2 — UPDATE STATE

### `.hes/state/current.json`: change `"{{FEATURE}}": "SPEC"`

### `.hes/state/events.log`:

```json
{
  "timestamp": "{{CURRENT_ISO_DATE}}",
  "feature": "{{FEATURE_SLUG}}",
  "from": "DISCOVERY",
  "to": "SPEC",
  "agent": "hes-v3",
  "metadata": {
    "artifacts": ["02-spec.md"],
    "scenarios_count": {{N}},
    "rn_coverage": "100%"
  }
}
```

---

────────────────────────────────────────────────────────────────
  SPEC complete
  .hes/specs/{{FEATURE_SLUG}}/02-spec.md · {{N}} BDD scenarios · API contract
────────────────────────────────────────────────────────────────
  → DESIGN                                     skills/03-design.md

**Read `current.json.interaction_tool` before rendering choices:**

If `interaction_tool = "question"`: call the question tool with single-select:
  - "SPEC complete. What next?"
    · "approve — advance to DESIGN"
    · "adjust scenario — describe which scenario and what to change"
    · "missing rule — describe the business rule to add"

If `interaction_tool = null`:
**Read `current.json.interaction_tool` before rendering choices:**

If `interaction_tool = "question"`: call the question tool with single-select:
  - "SPEC complete. What next?"
    · "approve — advance to DESIGN"
    · "adjust scenario — describe which scenario and what to change"
    · "missing rule — describe the business rule to add"

If `interaction_tool = null`:
  A  approve — advance to DESIGN
  B  adjust scenario — "scenario {{N}}: [what to change]"
  C  missing rule — "add business rule: [rule]"

  💡 Each BDD scenario becomes a test in RED phase. Be precise with "Then".
────────────────────────────────────────────────────────────────
