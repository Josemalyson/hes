---
name: error-recovery
version: 3.4.0
type: system
description: Error diagnosis and recovery protocol
preconditions:
  - error_detected
postconditions:
  - error_resolved
  - lessons_registered
produces:
  - .hes/tasks/lessons.md update
requires:
  - .hes/tasks/lessons.md
context:
  include: [".hes/tasks/lessons.md"]
  exclude: ["skills/*"]
---

# HES Skill — Error Recovery

> Skill loaded when: user reports an error in any pipeline phase.
> Objective: surgical diagnosis + minimal correction + systemic prevention.
>
> Principle (Fowler, 2026): "An issue that happens multiple times should trigger
> improvement to the harness, not just correction of the instance."

---

## ◈ DIAGNOSIS PROTOCOL

```
1. Request full error if not provided
   → "Paste the complete stack trace / error message"

2. Identify CATEGORY:
   A → HES rule violation (code before spec, etc.)
   B → Recurring technical error (invalid import, wrong type)
   C → Guide gap (agent was not instructed on something)
   D → Sensor gap (problem was not detected before reaching here)
   E → Process (approval skipped, communication failed)

3. Identify ROOT CAUSE (not the symptom):
   - Is the error in production code or in the test?
   - Is it a consequence of violating a HES step?
   - Is it an environment configuration problem?
   - Is it a harness gap that allowed the problem to reach here?

4. Propose MINIMAL and SURGICAL correction:
   - Smallest change that resolves the problem
   - Do not refactor during debugging
   - Do not add functionality during debugging

5. Verify harness impact:
   - Category D → propose new sensor or strengthen existing sensor
   - Category C → propose improvement to corresponding skill-file
   - Category A → reinforce rule in CLAUDE.md
   - N ≥ 2 occurrences → MANDATORY to improve the harness

6. Record in lessons.md after resolution
```

---

## ◈ DIAGNOSIS BY CATEGORY

### Category A — HES Rule Violation

```
Symptom: code implemented before spec / unchecked library / skipped step

Immediate action:
  → Revert what was done out of order
  → Complete the step that was skipped

Harness action (if N ≥ 2):
  → Reinforce RULE-xx in .claude/CLAUDE.md
  → Add alert in the skill-file of the phase where it occurred
```

### Category B — Compilation Errors

```
Most common cause: import of class that does not exist yet

Diagnosis:
  → Verify if class exists in src/
  → Verify if package is correct
  → Verify if dependency is in manifest

Correction:
  → Create missing class (minimal, no logic)
  → Fix the import
  → Add the dependency (with approval — RULE-03)

Harness action (if recurring):
  → Reinforce anti-hallucination checklist in 06-implementation.md
```

### Category B — Dependency Injection (Spring)

```
BeanCreationException / NoSuchBeanDefinitionException

Diagnosis:
  → Verify: @Service, @Repository, @Component, @Bean
  → Verify if package is in @ComponentScan
  → Verify active profile (prod vs test)

Minimal correction:
  → Add missing annotation
  → Fix qualifier if necessary
```

### Category B — Migration Errors (Flyway)

```
Checksum mismatch:
  → NEVER modify an applied migration in production (RULE-04)
  → Create a NEW migration with the fix

Column already exists:
  → Use CREATE TABLE IF NOT EXISTS
  → Verify if migration has already been applied

FK violation:
  → Verify table creation order
  → Verify ON DELETE behavior
```

### Category B — Test Errors

```
Expected X but was Y:
  → DO NOT change the test to make it pass
  → Verify: is the implemented logic correct?
  → Verify: does the message EXACTLY match 02-spec.md?
  → Verify: is the mock configured correctly?

NullPointerException in test:
  → Verify if mock is injected
  → Verify if @BeforeEach initializes the subject
```

### Category C — Guide Gap (insufficient feedforward)

```
Symptom: agent did something incorrectly due to lack of instruction

Examples:
  → Used an unlisted library
  → Chose a different pattern from the project
  → Did not follow naming convention

Harness action (ALWAYS — it is a guide gap):
  → Identify which skill-file should have instructed the agent
  → Propose addition to skill-file:
     "Add to skills/0X.md → Anti-Hallucination section:
      [✅ NEW] Before {{ACTION}}, verify {{CONDITION}}"
```

### Category D — Sensor Gap (feedback did not detect)

```
Symptom: problem reached the user when the harness should have detected it

Examples:
  → Boundary violation reached review without being detected
  → Secret was committed (hook failed)
  → Module boundary was violated silently

Harness action (ALWAYS — it is a sensor gap):
  → Identify which sensor should have detected it
  → If computational sensor: strengthen the rule or add new sensor
    Examples: new ArchUnit rule, new regex pattern in git-hooks.md
  → If inferential sensor: add to the 07-review.md checklist
  → Record as Category D in lessons.md

  Ask the user:
  "This problem reached review without being automatically detected.
   Would you like me to configure a sensor to catch this earlier?
   [A] Yes — I propose the configuration now
   [B] Register in harness backlog — implement later"
```

---

## ◈ REGISTRATION TEMPLATE IN LESSONS.MD

```markdown
### ❌ Resolved Error — {{DATE}} — {{FEATURE_SLUG}}

- **Symptom:** {{BRIEF_ERROR_MESSAGE}}
- **Category:** A / B / C / D / E
- **Root cause:** {{REAL_CAUSE}}
- **HES rule violated?** {{YES/NO}} → {{WHICH}}
- **Correction applied:** {{WHAT_WAS_DONE}}
- **Harness gap?** {{YES/NO}}
  - Type: Guide (C) / Sensor (D) / Rule (A)
  - Harness action: {{WHAT_TO_IMPROVE}}
- **Prior occurrence?** {{YES → PROMOTE TO SKILL-FILE / NO → 1st time}}
```

---

▶ NEXT ACTION — RETURN TO PIPELINE

```
After error resolution:

  [A] "error resolved, green build"
      → Return to current phase skill-file: skills/{{CURRENT_PHASE}}.md

  [B] "error persists: [new message]"
      → Continue diagnosis with new context

  [C] "I want to configure a sensor to prevent this"
      → Load skills/harness-health.md → sensor proposal section

  [D] "I had to change the spec/design because of the error"
      → Record as ADR or note in the affected document
         and update tests before reimplementing

💡 Tip (Fowler): "Whenever an issue happens multiple times, the feedforward
   and feedback controls should be improved to make the issue less probable."
   Every recurring error is an opportunity for systemic harness improvement.
```
