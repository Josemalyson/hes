# HES Skill — Refactor: Guided Refactoring Protocol

> Skill invoked via: "I want to refactor [module]" or `/hes refactor <module>`
> Objective: safe, evidence-based refactoring without regressions.
>
> Principle: refactoring does not change behavior — it changes structure.
> "Legacy teams face the harder problem: the harness is most needed
>  where it is hardest to build." — Fowler, 2026

---

## ◈ FUNDAMENTAL RULE

> **Before any refactoring: the test suite must be green.**
> Without tests covering the module → write tests BEFORE refactoring.
> Refactoring without tests is blind rewriting.

---

## ◈ CONTEXT TO LOAD BEFORE ACTING

```
1. Read .hes/state/current.json → check active feature (do not interrupt)
2. Identify the module to refactor (user provides)
3. List module files: ls src/...{{module}}/
4. Check current test coverage of the module
5. Read .hes/tasks/lessons.md → error patterns in this module
6. If harnessability is the goal → assess current module score
```

---

## ◈ STEP 1 — CLASSIFY THE TYPE

```
What is the primary objective of the refactoring?

  [A] Separation of responsibilities (Service with Controller logic)
  [B] Eliminate code duplication (DRY)
  [C] Improve naming (variables, methods, classes)
  [D] Simplify complex logic (CC > 10)
  [E] Extract reusable component
  [F] Improve exception handling
  [G] Remove dead code
  [H] Improve testability (DI, interfaces) ← improves harnessability
  [I] Improve harnessability (NEW in v3.1)
      → Add DI, clarify boundaries, enable sensors
```

---

## ◈ STEP 2 — GENERATE REFACTORING SPEC

Create `.hes/specs/refactor-{{MODULE}}-{{DATE}}/refactor-spec.md`:

```markdown
# Refactoring Spec — {{MODULE}}

Date: {{CURRENT_DATE}} | Type: {{SELECTED_TYPE}}

---

## Current State (AS-IS)

### Identified problems
| Problem | Location | Impact | Evidence |
|---------|----------|--------|----------|
| {{PROBLEM}} | `src/{{file}}:{{line}}` | {{IMPACT}} | {{SYMPTOM}} |

### Current metrics
| Metric | Current Value | Target |
|--------|--------------|--------|
| Cyclomatic complexity | {{N}} | <= 10 |
| Lines per method | {{N}} | <= 20 |
| Module coverage | {{X}}% | >= 80% |
| Harnessability | High/Medium/Low | High |
| ArchUnit-verifiable boundaries? | Yes/No | Yes |

---

## Target State (TO-BE)

### What changes
| Before | After | Justification |
|--------|-------|--------------|
| {{CURRENT_STRUCTURE}} | {{NEW_STRUCTURE}} | {{WHY}} |

### What does NOT change
- External behavior (API contracts, responses, HTTP status)
- Business rules (RN-xx)
- Database schema

### Harnessability gain (if Type H or I)
- Enabled sensor: {{ArchUnit rule / linter / coverage}}
- How: {{Constructor DI / extracted interface / explicit boundary}}

### Execution plan (atomic steps)
1. {{STEP_1}} → Verify: {{HOW_TO_CONFIRM}}
2. {{STEP_2}} → Verify: {{HOW_TO_CONFIRM}}

---

## Completion Criteria
- [ ] All existing tests passing after each step
- [ ] No new behavior introduced
- [ ] Coverage maintained or improved
- [ ] Harnessability increased (if that was the objective)
```

---

## ◈ STEP 3 — SAFE EXECUTION PROTOCOL

```
Before each change:
  1. Confirm: suite is green
  2. Checkpoint: git add -A && git commit -m "refactor({{module}}): checkpoint"
  3. Execute the minimal change
  4. Run sensor: if green → proceed | if red → revert

Rules:
  ✅ One type of change at a time
  ✅ Small, frequent commits
  ✅ Tests before, during, and after
  ❌ Never refactor + add feature in the same commit
  ❌ Never refactor without test coverage
```

---

## ◈ STEP 4 — RECIPES BY TYPE

### A — Separation of Responsibilities

```
1. Identify the misplaced code
2. Create a private method with descriptive name (without moving yet)
3. Extract to the correct class
4. Update calls → run tests
5. Remove the original method
```

### B — Eliminate Duplication (DRY)

```
1. Identify the 2+ duplicated code sections
2. Create a shared method with a name that expresses the concept
3. Replace the first usage → run tests
4. Replace the second usage → run tests
5. Never create premature abstraction (extract only with 2+ real usages)
```

### H — Improve Testability (improves harnessability)

```
Objective: remove impediments to mocking and sensors

Recipe:
1. Identify dependency that prevents mocking (internal new, static, singleton)
2. Extract interface if it does not exist
3. Inject via constructor (constructor injection)
4. Update tests to use interface mock
5. Verify: is it now possible to add an ArchUnit rule for this component?
```

### I — Improve Harnessability

```
Objective: make the module governable by computational sensors

Recipe:
1. Assess current harnessability (refer to Step 3 of legacy.md)
2. Identify the main impediment:
   → No DI → apply recipe H
   → No clear package boundaries → extract packages
   → No typing → add types (TypeScript, Python type hints)
   → Circular coupling → detect and break

3. For circular coupling (Java):
   mvn dependency:analyze
   → Identify the cycle: A → B → A
   → Extract interface in a separate module
   → A and B depend on the interface, not on each other

4. For package boundaries (Java):
   → Create a package with clear responsibility
   → Move classes to correct packages
   → Add ArchUnit rule for the new boundary
   → Verify: mvn test -Dtest=ArchitectureTest

5. At the end: run /hes harness to validate harnessability gain
```

### D — Simplify Complex Logic (CC > 10)

```
Recipes:
  Early return:   if (!condition) throw/return — eliminates else
  Guard clause:   validations at the top, main logic without nesting
  Extraction:     5+ line block → method with descriptive name
  Strategy:       multiple if/else by type → interface + implementations
```

---

## ◈ STEP 5 — VERIFY HARNESSABILITY GAIN

If refactoring was type H or I, verify after completion:

```
[ ] Constructor DI implemented → mocking now possible?
[ ] Explicit package boundaries → ArchUnit rule applicable?
[ ] Interface extracted → computational sensor now detects violations?
[ ] Circular coupling removed → dep-cruiser without circularities?
[ ] Coverage increased or maintained >= 80%?

If gain confirmed → /hes harness to update project score
```

---

## ◈ STEP 6 — end CHECKLIST

```
[ ] Are all existing tests passing?
[ ] Is coverage maintained or improved?
[ ] Has no external behavior changed?
[ ] Have target metrics been reached?
[ ] Are commits atomic with descriptive messages?
[ ] Is harnessability improved (if objective)?
```

---

## ◈ REGISTER IN LESSONS.MD

```markdown
## Refactoring: {{MODULE}} — {{DATE}}

- Type: {{TYPE}}
- Resolved problem: {{DESCRIPTION}}
- Technique: {{TECHNIQUE}}
- Result: {{METRIC_BEFORE}} → {{METRIC_AFTER}}
- Harnessability gain: {{YES/NO}} — {{DESCRIPTION}}
- Enabled sensor: {{ArchUnit rule / linter / coverage}}
- Time spent: {{ESTIMATE}}
```

---

────────────────────────────────────────────────────────────────
  REFACTOR complete
  {{module}} · all tests passing · no regressions
────────────────────────────────────────────────────────────────
  → continue

  A  commit refactor — generate commit message
  B  refactor another module — "module: [name]"
  C  back to feature — "/hes status"

  💡 Refactor = same behaviour, better structure. No new features here.
────────────────────────────────────────────────────────────────
