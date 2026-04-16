# HES Skill — 06: Implementation (GREEN Phase — TDD)

> Skill loaded when: feature.state = GREEN
> Pre-condition: tests written (RED) and confirmed failing for the right reason.
>
> Role in the harness: **Execution guided by Behaviour + Maintainability Harness**
> The code produced here is regulated by sensors: tests (behaviour),
> linter (maintainability) and ArchUnit/dep-cruiser (architecture fitness).
> "Keep quality left" — sensors run during and after each change, not only at the end.

---

## ◈ CONTEXT TO LOAD BEFORE ACTING

```
1. Read .hes/specs/{{feature}}/03-design.md → components to implement
2. Read .hes/specs/{{feature}}/02-spec.md   → business rules (BR-xx)
3. Read .hes/specs/{{feature}}/04-data.md   → DTOs and schema
4. For EACH file to be modified → read it fully first
5. Verify pom.xml / package.json → confirm dependencies
```

---

## ◈ ANTI-HALLUCINATION — MANDATORY BEFORE ANY CODE

```
[ ] Have I listed all classes/interfaces to be created or modified?
[ ] For each import: does the class exist in the project? (do not import what does not exist)
[ ] Did I check pom.xml / package.json — are the dependencies there?
[ ] Did I read the existing file to be modified (if applicable)?
[ ] Is the implementation limited to the approved spec scope?
```

If any item is uncertain → verify before continuing.

---

## ◈ GREEN PRINCIPLE: MINIMUM VIABLE

> Implement ONLY the minimum for tests to pass.
> No premature optimizations. No extra features. No "since I'm here already".
> Elegant code is refactoring — it is not Green.

---

## ◈ STEP 1 — IMPLEMENTATION ORDER

Implement from inside out (dependencies first):

```
1. Exception classes          (no dependencies)
2. Entity / Model             (no dependencies)
3. Repository interface       (defines the contract)
4. DTOs (Request / Response)
5. Mapper (DTO ↔ Entity)
6. Repository implementation  (data access)
7. Service / UseCase          (business rules)
8. Controller / Router        (HTTP entry point)
```

---

## ◈ STEP 2 — LAYER RULES

### Controller / Router

```
✅ Receives request → validates → delegates to Service → returns response
✅ HTTP Status = exactly as defined in 02-spec.md
✅ No business logic
❌ No direct access to Repository
```

### Service / UseCase

```
✅ Implements BR-xx with EXACT messages from spec
✅ Throws typed domain exceptions
✅ No HTTP awareness
❌ No direct SQL
```

### Repository

```
✅ Parameterized SQL (zero string concatenation)
✅ No business logic
❌ No calls to other Services
```

---

## ◈ STEP 3 — SENSOR LOOP (Fowler: "keep quality left")

After each implemented component, run available sensors:

```bash
# Fastest sensor first (computational)
# Java
mvn compile                          # type check — seconds
mvn test -Dtest={{NomeService}}Test  # unit tests for the component

# Node
npx tsc --noEmit                     # type check
npx jest {{nome-service}}.test       # component tests

# Python
mypy src/                            # type check
pytest tests/unit/{{feature}}/       # unit tests
```

**Do not wait for the full suite to discover compilation errors.**
Fast sensors run after each component — slow sensors (integration, ArchUnit) run at the end.

---

## ◈ STEP 4 — SELF-REFINEMENT LOOP (max. 5 attempts)

```
⏱ Time Budget: 15 minutes for GREEN phase

Attempt {{N}}/5:

1. Run test suite
2. Analyze failures:
   → Compilation error?      → Fix import/type
   → Assertion failed?       → Verify logic vs spec (DO NOT change the test)
   → Unexpected exception?   → Analyze full stack trace
3. Make the minimal correction
4. Run the corresponding sensor
5. If still failing and N ≥ 3 → Loop detection: "You've tried {{N}} times. Consider a different approach."
6. If N ≥ 5 → BLOCK: Present current state to user and escalate

After 5 unsuccessful attempts:
  → Record in lessons.md (Category B — recurring technical error)
  → Present analysis to user
  → Load skills/error-recovery.md
```

**Golden rule:** Never adjust the test to make code pass.
If the test fails and the code seems correct → the code is wrong.

---

## ◈ STEP 5 — IMPLEMENTATION CHECKLIST

```
[ ] Controller implemented (correct HTTP status from spec)
[ ] Service with all BR-xx implemented
[ ] Repository with parameterized queries
[ ] DTO ↔ Entity Mapper working
[ ] Exceptions with EXACT messages from 02-spec.md
[ ] No TODO / FIXME / HACK in code
[ ] No magic numbers (named constants)
[ ] No sensitive data logged
[ ] Structured logs with context (feature, operation, IDs)
[ ] Green build: ALL tests passing
[ ] Coverage ≥ 80% on new module
[ ] Linter without errors (if configured)
[ ] ArchUnit passing (if configured)
```

---

## ◈ STEP 6 — FINAL VALIDATION

```bash
# Java — full suite + coverage + architecture fitness
mvn clean test jacoco:report
# → BUILD SUCCESS
# → target/site/jacoco/index.html: verify coverage ≥ 80%
# → ArchitectureTest: verify boundaries were not violated

# Node.js
npm test -- --coverage
# → All tests passed | Coverage ≥ 80%
# npm run check:arch (if dep-cruiser configured)

# Python
pytest --cov=src --cov-report=term-missing -v
# → passed, 0 failed | TOTAL coverage ≥ 80%
```

---

## ◈ STEP 7 — UPDATE STATE

### `.hes/state/current.json`: `"{{FEATURE}}": "GREEN"`

### `.hes/state/events.log`:

```json
{
  "timestamp": "{{CURRENT_ISO_DATE}}",
  "feature": "{{FEATURE_SLUG}}",
  "from": "RED",
  "to": "GREEN",
  "agent": "hes-v3.3",
  "metadata": {
    "tests_passing": {{N}},
    "coverage": "{{X}}%",
    "archunit_passing": {{true/false}},
    "refinement_iterations": {{N}},
    "lessons_added": {{N}}
  }
}
```

---

▶ NEXT ACTION — REVIEW

```
🟢 Implementation completed?

Confirm before proceeding:
  1. Green build (all tests passing)?
  2. Coverage ≥ 80%?
  3. No TODO/FIXME?
  4. ArchUnit passing (if configured)?

  [A] "green build, coverage ok"
      → Starting structured review (skills/07-review.md)

  [B] "test X failing: [error]"
      → Self-refinement attempt {{N}} — analyzing the issue

  [C] "coverage at {{X}}%"
      → Evaluate if acceptable or add tests for gaps

📄 Next skill file: skills/07-review.md
💡 Tip: coverage measures quantity of lines executed, not quality.
   A test without assertions protects nothing.
   Prefer tests that fail when logic is wrong (effective sensor).
```
