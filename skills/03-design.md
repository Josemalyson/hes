---
name: design
version: 3.4.0
type: feature
description: Architecture design and component specification
preconditions:
  - current_state == "DESIGN"
  - .hes/specs/{{feature}}/02-spec.md approved
postconditions:
  - components defined
  - adr_created
produces:
  - .hes/specs/{{feature}}/03-design.md
  - .hes/decisions/ADR-{{NNN}}.md
requires:
  - .hes/specs/{{feature}}/02-spec.md
context:
  include: [".hes/specs/{{feature}}/02-spec.md"]
  exclude: ["skills/*"]
---

# HES Skill — 03: Design + ADR

> Skill loaded when: feature.state = DESIGN
> Precondition: `02-spec.md` approved by the user.
>
> Role in harness: **Inferential Guide (Architecture Fitness + Maintainability)**
> The design defines boundaries that computational sensors will verify.
> Every design decision determines the module's harnessability.

---

## ◈ CONTEXT TO LOAD BEFORE ACTING

```
1. Read .hes/specs/{{feature}}/02-spec.md in full
2. Read .hes/state/current.json → feature domain
3. If domain exists → read .hes/domains/{{domain}}/context.md
4. If domain exists → read .hes/domains/{{domain}}/fitness/ (active rules)
5. Check src/ to maintain consistency with existing patterns:
   - Current package structure
   - Already adopted architectural patterns (Controller → Service → Repository)
   - Naming conventions
6. Check pom.xml / package.json → available libraries
```

**Anti-hallucination:** Never propose a pattern or library that does not exist in the project.
Always cite the reference `src/` file when proposing something.

---

## ◈ STEP 1 — GENERATE `.hes/specs/{{FEATURE_SLUG}}/03-design.md`

```markdown
# Design — {{FEATURE_NAME}}

Date: {{CURRENT_DATE}} | Version: 1.0
Derived from: 02-spec.md | Feature: {{FEATURE_SLUG}}

---

## Components

| Component | Type | Responsibility | File |
|-----------|------|----------------|------|
| {{NameController}} | Controller | Receive request, validate input, delegate to Service | `src/.../{{File}}` |
| {{NameService}} | Service/UseCase | Business rules (RN-xx), orchestration | `src/.../{{File}}` |
| {{NameRepository}} | Repository | Data access — no business logic | `src/.../{{File}}` |
| {{NameRequestDTO}} | DTO (in) | Input contract, field validations | `src/.../{{File}}` |
| {{NameResponseDTO}} | DTO (out) | Output contract | `src/.../{{File}}` |
| {{NameMapper}} | Mapper | DTO <-> Entity conversion | `src/.../{{File}}` |
| {{NameException}} | Exception | Domain exceptions with spec messages | `src/.../{{File}}` |

## Execution Flow

```
HTTP Request
    |
    v
{{NameController}}          [package: controller]
    | validates {{NameRequestDTO}}
    | delegates to service
    v
{{NameService}}             [package: service]
    | applies RN-01: {{rule}}
    | applies RN-02: {{rule}}
    | throws {{NameException}} if violation
    v
{{NameRepository}}          [package: repository]
    | parameterized query — no business logic
    v
  Database
    ^ returns entity
{{NameMapper}}
    | converts entity → {{NameResponseDTO}}
    v
HTTP Response ({{STATUS_CODE}})
```

## Patterns Used

| Pattern | Justification | Project Reference |
|---------|--------------|-------------------|
| Repository | Separation of concerns, testability | `src/.../ExistingRepo.java` |
| DTO/Mapper | Decouple domain from API | `src/.../ExistingDTO.java` |
| {{OTHER}} | {{JUSTIFICATION}} | `src/...` |

## Impact on Existing Modules

| Module/File | Impact Type | Required Action |
|-------------|-------------|-----------------|
| {{module}} | Addition / Modification / No impact | {{what to do}} |

## Design Harnessability (NEW in v3.1)

> "Technology decisions and architecture choices determine how governable
>  the codebase will be." — Fowler, 2026

| Design Decision | Harnessability | Reason |
|-----------------|---------------|--------|
| Clear package boundaries (controller/service/repository) | ✅ High | ArchUnit can verify automatically |
| Constructor DI (no internal new) | ✅ High | Mocking facilitated in unit tests |
| Typed domain exceptions | ✅ High | Test sensor can verify type + message |
| {{OTHER_DECISION}} | ✅/⚠️ | {{REASON}} |

## Sensors That Verify This Design

| Sensor | What it verifies | When it runs |
|--------|-----------------|-------------|
| ArchUnit (if configured) | Package boundaries, unidirectional dependencies | `mvn test` |
| Self-refinement loop | Implementation follows the flow defined here | During GREEN |
| Review Dimension 5 | Design vs implementation | REVIEW phase |

## Architectural Decision
See: `.hes/decisions/ADR-{{NNN}}.md`

## Approval
- [ ] Do components follow existing project patterns?
- [ ] Does the flow cover all spec scenarios?
- [ ] Do design decisions maximize harnessability?
- [ ] Is impact on existing modules mapped?
- [ ] Approved to advance to Step 4 (DATA)
```

---

## ◈ STEP 2 — GENERATE ADR

Determine next ADR number:
```bash
ls .hes/decisions/ADR-*.md 2>/dev/null | wc -l
# Next = count + 1, 3-digit format: ADR-001
```

Generate `.hes/decisions/ADR-{{NNN}}.md`:

```markdown
# ADR-{{NNN}} — {{DECISION_TITLE}}

Date: {{CURRENT_DATE}} | Status: Accepted | Feature: {{FEATURE_SLUG}}
Domain: {{DOMAIN_IF_APPLICABLE}}

---

## Context

{{WHAT_PROBLEM_NEEDED_TO_BE_DECIDED}}
{{WHY_THIS_DECISION_WAS_NEEDED_NOW}}

## Motivating Force

- {{DRIVER_1}} — e.g., read volume requires query separation
- {{DRIVER_2}} — e.g., need for change auditing

## Impact on Harnessability (NEW in v3.1)

The chosen decision {{increases / maintains / reduces}} harnessability because:
- {{HARNESSABILITY_REASON}}
- Impacted sensor: {{ArchUnit rule / linter / coverage}} — {{how}}

## Options Considered

### Option A: {{NAME}}
- Pros: {{ADVANTAGES}}
- Cons: {{DISADVANTAGES}}
- Harnessability: High / Medium / Low

### Option B: {{NAME}}
- Pros: {{ADVANTAGES}}
- Cons: {{DISADVANTAGES}}
- Harnessability: High / Medium / Low

## Decision

**Chosen: Option {{X}} — {{NAME}}**
{{DIRECT_JUSTIFICATION}}

## Consequences

**Positive:**
- {{GAIN_1}}

**Accepted trade-offs:**
- {{ACCEPTED_COST}}

**Risks and Mitigations:**
- {{RISK}} → Mitigation: {{HOW}}

## Review if

{{TRIGGER — e.g., "volume exceeds X/s" or "new domain needs isolation"}}
```

---

## ◈ STEP 3 — UPDATE FITNESS/ (if domain has ArchUnit)

If `.hes/domains/{{domain}}/fitness/` exists and the feature introduces a new boundary:

```
Check if the execution flow defines new boundaries to be captured:
→ New ArchUnit rule? → Add to ArchitectureTest.java
→ Document in .hes/domains/{{domain}}/fitness/README.md
```

---

## ◈ STEP 4 — UPDATE STATE

### `.hes/state/current.json`: `"{{FEATURE}}": "DESIGN"`

### `.hes/state/events.log`:

```json
{
  "timestamp": "{{CURRENT_ISO_DATE}}",
  "feature": "{{FEATURE_SLUG}}",
  "from": "SPEC",
  "to": "DESIGN",
  "agent": "hes-v3.3",
  "metadata": {
    "artifacts": ["03-design.md", "ADR-{{NNN}}.md"],
    "harnessability": "{{HIGH/MEDIUM/LOW}}",
    "archunit_updated": {{true/false}}
  }
}
```

---

▶ NEXT ACTION — DESIGN APPROVAL

```
🏗  Design generated:
    .hes/specs/{{FEATURE_SLUG}}/03-design.md
    .hes/decisions/ADR-{{NNN}}.md

Validate before approving:
  • Do components use patterns already existing in the project?
  • Does the ADR explain why alternatives were rejected?
  • Does the execution flow cover all BDD scenarios from the spec?
  • Do design decisions maximize harnessability?

  [A] "approve design"
      → I'll generate schema and migrations (skills/04-data.md)

  [B] "adjust [what]"
      → I'll fix design and/or ADR

  [C] "I prefer Option B from the ADR"
      → I'll update the decision and adjust the design

📄 Next skill-file: skills/04-data.md
💡 Tip (Fowler): "Technology decisions determine how governable the codebase will be."
   Constructor DI, clear package boundaries, and typed exceptions are the 3 decisions
   that most impact the harnessability of a Java/Spring Boot service.
```
