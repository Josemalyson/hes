# HES Skill — Legacy: Inventory + Harnessability Assessment

> Skill loaded when: global state = LEGACY
> (project with existing `src/` but no `.hes/` structure)
>
> "Legacy teams, especially with applications that have accrued a lot of technical debt,
>  face the harder problem: the harness is most needed where it is hardest to build."
>  — Fowler, 2026

---

## ◈ PROTOCOL

```
1. Announce the inventory protocol
2. Collect project information
3. Assess harnessability (NEW in v3.1)
4. Generate architectural inventory
5. Generate tech debt map
6. Execute bootstrap (skills/00-bootstrap.md — step 2 onwards)
7. Return to skills/01-discovery.md with inventory context
```

---

## ◈ STEP 1 — ANNOUNCE

```
🔍 HES detected an existing project without harness installed.

Before any modification, I will:
  1. Inventory what exists
  2. Assess project harnessability
  3. Install the harness with guides and sensors appropriate to the maturity level

This protects the project from inconsistent changes relative to its current state.
```

---

## ◈ STEP 2 — COLLECT INFORMATION (maximum 5 questions)

```
I need to understand the existing project:

1. Project name and main purpose:
2. Main stack? (language, framework, database, versions)
3. How many years old (approximately)?
4. Is there a test suite? If yes: estimated coverage and framework?
5. What problem or feature motivated you to call HES now?
```

---

## ◈ STEP 3 — HARNESSABILITY ASSESSMENT (NEW in v3.1)

> "Not every codebase is equally amenable to harnessing." — Fowler, 2026
> "Greenfield teams can bake harnessability in from day one.
>  Legacy teams face the harder problem." — Fowler, 2026

Assess the project on the following axes:

### 3a — Language and Typing

```
[ ] Is the language strongly typed? (Java, TypeScript, Kotlin, Go, C#)
    → Yes: type checker available as free computational sensor
    → No: quality sensors depend more on linters (less reliable)

[ ] Framework with strong conventions? (Spring Boot, NestJS, Django)
    → Yes: module boundaries easier to define and verify
    → No: lower harnessability — boundaries need to be made explicit
```

### 3b — Modularity

```
[ ] Does the code have clear package/module boundaries?
    → Yes: ArchUnit/dep-cruiser can verify automatically
    → No: high risk of silent architectural regression

[ ] Is there a clear separation of concerns (Controller/Service/Repo)?
    → Yes: layer fitness functions are immediately applicable
    → No: structural refactoring needed before effective harnessing

[ ] Is there circular coupling between modules?
    → Execute: mvn dependency:analyze / npx madge --circular src/
    → Yes → high risk, prioritize as critical tech debt
```

### 3c — Testability

```
[ ] Does the code have dependency injection (DI)?
    → Yes: mocking facilitated, unit tests viable
    → No: hard to test in isolation — high test cost

[ ] Is there a working test suite?
    → Yes: current coverage? framework?
    → No: any change is blind — maximum priority before features

[ ] Are there static objects / singletons that make testing difficult?
    → Yes → low harnessability in that area
```

### 3d — Harnessability Score

```
High   → Strong typing + clear boundaries + DI + existing tests
         → Full harness can be installed immediately

Medium → Some characteristics present but not all
         → Install harness incrementally, start with simplest sensors

Low    → No strong typing OR no tests OR circular coupling
         → Prioritize harnessability refactoring BEFORE new features
         → Install only git hooks and specs as first step
```

---

## ◈ STEP 4 — GENERATE `.hes/inventory/architecture.md`

```markdown
# Architectural Inventory — {{PROJECT_NAME}}

Date: {{CURRENT_DATE}} | Analyst: HES Auto-Discovery

---

## Overview

| Attribute | Value |
|---------|-------|
| Type | Monolith / Microservice / Modular Monolith |
| Language | {{LANGUAGE}} + {{VERSION}} |
| Framework | {{FRAMEWORK}} + {{VERSION}} |
| Database | {{DATABASE}} |
| Estimated age | {{YEARS}} years |

## Harnessability Score

| Axis | Score | Notes |
|------|-------|-----------|
| Typing | High/Medium/Low | |
| Modularity | High/Medium/Low | |
| Testability | High/Medium/Low | |
| **Overall Score** | **High/Medium/Low** | |

## Entry Points

| Type | File | Route/Endpoint | Authentication |
|------|---------|--------------|-------------|
| _to fill_ | | | |

> Execute to identify:
> Java:   `grep -r "@RestController\|@Controller" src/ --include="*.java" -l`
> Node:   `grep -r "router\.\|app\.\(get\|post\|put\|delete\)" src/ -l`
> Python: `grep -r "@app.route\|@router" src/ -l`

## Critical Dependencies

| Dependency | Current Version | Notes |
|-------------|-------------|-----------|
| _to fill_ | | |

## Test Coverage

| Metric | Value |
|---------|-------|
| Estimated coverage | {{X}}% |
| Test framework | |
| Unit tests | Yes / No |
| Integration tests | Yes / No |

## Modules / Packages

| Module | Responsibility | Health | Harnessable? |
|--------|-----------------|-------|-------------|
| | | 🟢/🟡/🔴 | Yes/No |

## Circular Coupling

[ ] Verify: `mvn dependency:analyze` or `npx madge --circular src/`
Result: {{NONE / LIST_OF_CYCLES}}

## Identified Risks

- [ ] _to fill after analysis_
```

---

## ◈ STEP 5 — GENERATE `.hes/inventory/tech-debt.md`

```markdown
# Tech Debt — {{PROJECT_NAME}}

Date: {{CURRENT_DATE}}

---

## 🔴 CRITICAL — blocks delivery or causes production risk

| Debt | Location | Impact | Effort | Strategy |
|--------|------------|---------|---------|-----------|
| | | | S/M/L | Hotfix/Refactor/Rewrite |

## 🟡 HIGH — degrades quality, complicates maintenance

| Debt | Location | Impact | Effort | Strategy |
|--------|------------|---------|---------|-----------|

## 🟢 MEDIUM — desirable improvement, no urgency

| Debt | Location | Impact | Effort | Strategy |
|--------|------------|---------|---------|-----------|

---

## Module Strategy Decision

| Module | Coverage | Harnessability | Recommended Strategy |
|--------|----------|---------------|----------------------|
| | | High/Medium/Low | Immediate harnessing / Refactor first / Rewrite |
```

---

## ◈ STEP 6 — INSTALL HARNESSES PROPORTIONAL TO SCORE

```
Harnessability HIGH:
  → Execute full bootstrap (skills/00-bootstrap.md)
  → Propose ArchUnit/dep-cruiser immediately (architecture fitness)
  → Install coverage target ≥ 80%

Harnessability MEDIUM:
  → Execute bootstrap (git hooks + specs)
  → Defer ArchUnit until main module has clear boundaries
  → Install linter + coverage target ≥ 60% (evolve to 80%)

Harnessability LOW:
  → Install ONLY git hooks (LLM-executed safety checks)
  → Create specs for the motivating feature BEFORE any code
  → Plan harnessability sprint before new features
  → Note in CLAUDE.md: "Codebase with low harnessability — review manually before implementing"
```

---

▶ NEXT ACTION

```
🔍 Inventory + Harnessability Assessment completed.

Score: {{HIGH/MEDIUM/LOW}} → Harness {{FULL/INCREMENTAL/MINIMAL}}

  [A] "install the harness and start discovery of [feature]"
      → Execute bootstrap proportional to score and start Discovery

  [B] "I want to see the tech debt before deciding"
      → Show .hes/inventory/tech-debt.md and discuss priorities

  [C] "I need to improve harnessability first"
      → Load skills/refactor.md for harnessability protocol

📄 Next skill file: skills/01-discovery.md
💡 Tip (Fowler): low harnessability does not prevent harness — it only changes the starting point.
   Start with the simplest sensors (git hooks + specs) and evolve incrementally.
```
