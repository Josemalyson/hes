# HES Skill — 07: Review + Cycle Closure

> Skill loaded when: feature.state = REVIEW
> Pre-condition: all tests passing (GREEN), coverage ≥ 80%.
> This is the end regulation step before DONE. Combines inferential and computational sensors.

---

## ◈ CONTEXT TO LOAD BEFORE ACTING

```
1. Read .hes/specs/{{feature}}/02-spec.md   → BDD scenarios (baseline)
2. Read .hes/specs/{{feature}}/03-design.md → components (design adherence)
3. Read .hes/decisions/ADR-{{NNN}}.md       → architectural decision (verify implementation)
4. Read .hes/tasks/lessons.md               → previous error patterns to check
5. Verify computational sensor results:
   → Latest build: coverage % and test count
   → Linter output (if configured)
   → ArchUnit / dep-cruiser (if configured)
```

---

## ◈ DIMENSION 1 — BEHAVIOUR HARNESS ADHERENCE (Spec)

```
[ ] Do all BDD scenarios from 02-spec.md have test coverage?
[ ] BR → scenario traceability: does each BR-xx have at least 1 test?
[ ] Are implemented error messages = EXACTLY those defined in the spec?
[ ] Is the API contract (route, method, fields, status codes) = implemented?
[ ] Is there code implemented beyond spec scope? (feature creep)
    → If yes: register as debt or propose complementary spec
```

---

## ◈ DIMENSION 2 — MAINTAINABILITY HARNESS (Internal Quality)

```
[ ] No business logic in Controller/Router
[ ] No direct data access in Service
[ ] No business rules in Repository
[ ] Descriptive names — no obscure abbreviations, no variables like "data", "info"
[ ] No magic numbers (use named constants)
[ ] No obvious comments (code should be self-explanatory)
[ ] No dead code (unused methods, unnecessary imports)
[ ] No duplication — if there are 2+ copies, extract
[ ] Cyclomatic complexity ≤ 10 per method
[ ] All domain errors mapped to correct HTTP responses
```

---

## ◈ DIMENSION 3 — SECURITY (Automated Scan Verification)

> **HES v3.4.0**: The automated scan (Bandit + Semgrep) was already run in the SECURITY phase.
> This dimension verifies the scan result and complements it with a conceptual security review
> covering aspects that static tools do not catch.

```
[ ] security-report-final.json exists in .hes/state/?
[ ] SECURITY gate passed (zero HIGH findings)?
[ ] Exceptions documented in security-exceptions.json have valid justifications?

--- Complementary review (not covered by Bandit/Semgrep) ---
[ ] Authorization logic correct — resources verified before access
[ ] Principle of least privilege applied in queries and operations
[ ] Rate limiting / throttling considered on public endpoints
[ ] Security logs (access attempts, auth failures) instrumented
[ ] External data sanitized before internal use
```

**Reference:** `.hes/state/security-report-end.json` | `.hes/state/security-exceptions.json`

---

## ◈ DIMENSION 4 — OBSERVABILITY

```
[ ] Structured logs with context:
    - feature / operation being executed
    - relevant IDs (userId, entityId, correlationId/traceId)
    - result (success / error + reason)
[ ] Correct log level:
    DEBUG → execution details (not in production)
    INFO  → relevant business events
    WARN  → unexpected but recoverable situations
    ERROR → failures needing attention (with stack trace)
[ ] Exceptions logged with full stack trace on ERROR
[ ] No sensitive data in logs
[ ] Trace ID propagated (if distributed tracing is in use)
[ ] Critical metrics instrumented (if Prometheus/Datadog/CloudWatch active)
```

---

## ◈ DIMENSION 5 — ARCHITECTURE FITNESS HARNESS (NEW in v3.1)

> "The agent harness acts like a cybernetic governor, combining feedforward and
>  feedback to regulate the codebase towards its desired state." — Fowler, 2026

```
[ ] Does implementation follow the flow defined in 03-design.md?
[ ] Was the ADR-{{NNN}} decision respected?
[ ] No circular dependencies introduced?
[ ] Module boundaries respected (Controller → Service → Repository):
    → If ArchUnit configured: verify output of latest architecture test
    → If not configured: manually review imports and dependencies
[ ] No DDD bounded context violation (if domains defined)?
[ ] Is migration reversible — rollback possible without data loss?
[ ] Did the new feature create unintentional coupling with another module?

DRIFT CHECK (run if ArchUnit/dep-cruiser is available):
  java:   mvn test -Dtest=ArchitectureTest
  node:   npm run check:arch
  python: python -m import-linter
```

---

## ◈ GENERATE PR TEMPLATE

```markdown
## {{FEATURE_NAME}} — {{type}}: {{brief_description}}

### Context
{{PROBLEM_BEING_SOLVED_in_business_language}}

### What was done
- {{CHANGE_1}}
- {{CHANGE_2}}

### HES References
- 📋 Discovery   : `.hes/specs/{{feature}}/01-discovery.md`
- 📐 Spec        : `.hes/specs/{{feature}}/02-spec.md`
- 🏗  Design     : `.hes/specs/{{feature}}/03-design.md`
- 🏛  ADR        : `.hes/decisions/ADR-{{NNN}}.md`
- 💾 Data Layer  : `.hes/specs/{{feature}}/04-data.md`

### Checklist
- [ ] BDD scenarios covered (BR → scenario → test traceability)
- [ ] Coverage ≥ 80%
- [ ] Architecture fitness: ArchUnit/dep-cruiser green (if configured)
- [ ] Migration tested (up + rollback)
- [ ] No secrets in code
- [ ] Structured logs with context
- [ ] No TODO/FIXME

### How to test
```bash
{{COMMAND_TO_START_ENVIRONMENT}}

curl -X {{METHOD}} {{URL}} \
  -H "Authorization: Bearer {{TOKEN}}" \
  -d '{{PAYLOAD}}'

# Expected: HTTP {{STATUS}} — {{RESPONSE_DESCRIPTION}}
```
```

---

## ◈ LEARNING LOOP — UPDATE LESSONS.MD (hot path)

```markdown
## Session: {{DATE}} — {{FEATURE_SLUG}}

### ✅ What worked
- {{POSITIVE_LEARNING}}

### ❌ What failed / required rework
- {{ERROR_COMMITTED}}
  - Root cause: {{CAUSE}}
  - Impact: {{WASTED_TIME_OR_REWORK}}
  - Future prevention: {{HOW_TO_AVOID}}

### 🔄 Behavior change adopted
- {{NEW_BEHAVIOR}}

### 📌 Promote to skill-file? (Fowler: "recurring issue → improve the harness")
- [ ] {{LESSON}} → skills/{{XX-file}}.md
      (mark if it appeared before — automatic promotion on 2nd occurrence)
```

**Verify:** if any lesson in this session already appears in previous lessons.md → promote now.

---

## ◈ CLOSE THE CYCLE — UPDATE STATE

### `.hes/state/current.json`:

```json
{
  ...
  "features": {
    "{{FEATURE_SLUG}}": "DONE"
  },
  "active_feature": null,
  "completed_cycles": {{N + 1}},
  "last_updated": "{{CURRENT_ISO_DATE}}"
}
```

### `.hes/tasks/backlog.md`: move to `✅ Completed`

### `.hes/state/events.log`:

```json
{
  "timestamp": "{{CURRENT_ISO_DATE}}",
  "feature": "{{FEATURE_SLUG}}",
  "from": "REVIEW",
  "to": "DONE",
  "agent": "hes-v3.3",
  "metadata": {
    "review_dimensions_passed": 5,
    "security_scan_passed": true,
    "architecture_fitness_checked": true,
    "lessons_added": {{N}},
    "pr_ready": true,
    "cycle_number": {{completed_cycles}}
  }
}
```

---

▶ NEXT ACTION — AFTER DONE

```
🏁 Cycle {{completed_cycles}} complete! {{FEATURE_NAME}} delivered.

Summary:
  📋 Specs    : .hes/specs/{{FEATURE_SLUG}}/
  🏛  ADR     : .hes/decisions/ADR-{{NNN}}.md
  📚 Lessons  : .hes/tasks/lessons.md (updated)
  🔀 PR       : ready for human review

  [A] "next feature: [name]"
      → Starting Discovery (skills/01-discovery.md)

  [B] "I want to see the backlog"
      → Showing prioritized .hes/tasks/backlog.md

  [C] "/hes report"  (recommended if completed_cycles % 3 == 0)
      → Batch learning on events.log → harness improvement

  [D] "/hes harness"
      → Harness health diagnosis across 3 dimensions

📄 Next skill file: skills/01-discovery.md or skills/report.md
💡 Tip: review is an inferential sensor — it complements, but does not replace,
   computational sensors (linter, ArchUnit, coverage).
   Together they form the behaviour + architecture fitness harness.
```
