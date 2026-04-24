# 01 · DISCOVERY — Feature Scoping

phase  DISCOVERY  ·  pre  ZERO  ·  next  SPEC
gate   business rules captured + user approval
skill  skills/01-discovery.md

> Never invent business rules. Every RN comes from the user.

---

## ◈ CONTEXT TO LOAD BEFORE ACTING

```
1. Read .hes/state/current.json → get active_feature
2. Check if .hes/domains/{{domain}}/context.md exists → if yes, read it
3. Check if .hes/tasks/lessons.md exists → check for relevant lessons
4. Check if .hes/specs/{{feature}}/01-discovery.md exists
   → If exists: resume and present to user for review
   → If does not exist: start discovery from scratch
```

---

## ◈ STEP 1 — IDENTIFY FEATURE

If called via `/hes start <feature>`:
- Extract the feature name from the command
- Create slug: `{{name-in-kebab-case}}`
- Create directory: `.hes/specs/{{feature-slug}}/`

If called without a feature name:
```
What is the feature you want to develop?
(e.g., JWT authentication, PIX payment endpoint, reporting module)
```

---

## ◈ STEP 2 — DISCOVERY QUESTIONS (maximum 6)

```
🔍 Discovery — {{FEATURE_NAME}}

To specify correctly, I need to understand:

1. Who uses this feature? (user persona/role)
2. What problem does it solve? (in 1-2 sentences, business language)
3. What are the non-obvious business rules?
   (constraints, limits, exceptions, special cases)
4. What defines "success" for this feature?
   (acceptance criteria in business language)
5. Are there external integrations involved?
   (third-party APIs, legacy systems, queues, events)
6. Are there technical or deadline constraints I should know about?
```

**Anti-hallucination:** Do not assume any business rules.
If the answer is ambiguous, ask for clarification before proceeding.

---

## ◈ STEP 3 — GENERATE `.hes/specs/{{FEATURE_SLUG}}/01-discovery.md`

```markdown
# Discovery — {{FEATURE_NAME}}

Date: {{CURRENT_DATE}} | Version: 1.0 | Status: DRAFT
Feature: {{FEATURE_SLUG}} | Domain: {{DOMAIN_IF_APPLICABLE}}

---

## Context
{{PROBLEM_IN_BUSINESS_LANGUAGE}}

## Stakeholders
| Persona | Role | Primary Interest |
|---------|------|-----------------|
| {{PERSONA_1}} | {{ROLE}} | {{INTEREST}} |

## Use Cases
| ID   | Name | Actor | Action | Expected Result |
|------|------|-------|--------|-----------------|
| UC-01 | {{USE_CASE_NAME}} | {{PERSONA}} | {{ACTION}} | {{RESULT}} |

## Business Rules
| ID    | Rule | Source | Verifiable? |
|-------|------|--------|-------------|
| RN-01 | {{EXPLICIT_RULE}} | User | Yes |

> ⚠️ Every rule comes from the user. Never invent business rules.

## External Integrations
| System | Protocol | Direction | Formal Contract? |
|--------|----------|-----------|-----------------|
| {{SYSTEM}} | REST/gRPC/Event | Inbound/Outbound | Yes/No |

## Constraints
- Technical: {{TECHNICAL_CONSTRAINTS_OR_NONE}}
- Business: {{BUSINESS_CONSTRAINTS_OR_NONE}}
- Deadline: {{DEADLINE_IF_PROVIDED}}

## Business Acceptance Criteria
{{WHAT_DEFINES_SUCCESS_IN_BUSINESS_LANGUAGE}}

## Open Questions
- [ ] {{OPEN_QUESTION — or "None" if everything was clarified}}

## Approval
- [ ] Approved by user to advance to Step 2 (SPEC)
```

---

## ◈ STEP 4 — UPDATE STATE

### Update `.hes/state/current.json`:

```json
{
  ...
  "active_feature": "{{FEATURE_SLUG}}",
  "features": {
    "{{FEATURE_SLUG}}": "DISCOVERY"
  },
  "last_updated": "{{CURRENT_ISO_DATE}}"
}
```

### Register event in `.hes/state/events.log`:

```json
{
  "timestamp": "{{CURRENT_ISO_DATE}}",
  "feature": "{{FEATURE_SLUG}}",
  "from": "ZERO",
  "to": "DISCOVERY",
  "agent": "hes-v3",
  "metadata": {
    "artifacts": ["01-discovery.md"]
  }
}
```

---


────────────────────────────────────────────────────────────────
  DISCOVERY complete
  .hes/specs/{{FEATURE_SLUG}}/01-discovery.md generated
────────────────────────────────────────────────────────────────
  → SPEC                                       skills/02-spec.md

  A  approve — advance to SPEC
  B  adjust — "I need to change [what]"
  C  add rule — "one more business rule: [rule]"

  💡 Each uncaptured RN here costs rework in SPEC and RED phase.
────────────────────────────────────────────────────────────────
