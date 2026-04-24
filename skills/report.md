# HES Skill — Report: Batch Learning + Harness Improvement

> Skill invoked via: `/hes report`
> Objective: transform events.log + lessons.md into concrete harness improvements.
>
> "If you want to improve the harness, give a coding agent access to these traces.
>  This pattern is how we improved our base harness." — LangChain, 2026
>
> "An issue that happens multiple times should trigger improvement of the harness,
>  not just correction of the instance." — Fowler, 2026
>
> Execute: every 3 DONE cycles (completed_cycles % 3 == 0)

---

## ◈ CONTEXT TO LOAD BEFORE ACTING

```
1. Read .hes/state/current.json → list features with DONE state + completed_cycles
2. Read .hes/state/events.log   → complete transition history
3. Read .hes/tasks/lessons.md   → consolidate learnings
4. Read .hes/tasks/backlog.md   → evaluate delivered vs planned
```

---

## ◈ STEP 1 — EXTRACT METRICS FROM TRACES (events.log)

For each feature with DONE state:

```
Time per phase = timestamp(to) - timestamp(from)

Feature: {{FEATURE_SLUG}}
  ZERO      → DISCOVERY : {{T}} min
  DISCOVERY → SPEC      : {{T}} min
  SPEC      → DESIGN    : {{T}} min
  DESIGN    → DATA      : {{T}} min
  DATA      → RED       : {{T}} min
  RED       → GREEN     : {{T}} min  [refinement_iterations: {{N}}]
  GREEN     → REVIEW    : {{T}} min
  REVIEW    → DONE      : {{T}} min
  ─────────────────────────────────
  Total: {{T}} min | Self-refinement iterations: {{total_N}}
```

Also extract per event:
- How many rollbacks occurred? In which phase?
- How many self-refinement iterations per feature?
- Which phase has the most time variance between features?

---

## ◈ STEP 2 — IDENTIFY PATTERNS IN LESSONS (hot path → offline consolidation)

```
Classify lessons from lessons.md into categories:

CATEGORY A — HES rule violation
  → Example: "I implemented before having approved spec"
  → Action: reinforce RULE-xx in CLAUDE.md and corresponding skill-file

CATEGORY B — Recurring technical error
  → Example: "import of non-existent class"
  → Action: reinforce anti-hallucination checklist in 06-implementation.md

CATEGORY C — Guide gap (insufficient feedforward)
  → Example: "agent chose unlisted library"
  → Action: improve loaded context in corresponding skill-file

CATEGORY D — Sensor gap (feedback did not detect)
  → Example: "boundary violation went unnoticed"
  → Action: propose new computational sensor (ArchUnit rule, linter rule)

CATEGORY E — Process (approval flow, communication)
  → Example: "user approved spec without reading RNs"
  → Action: add alert in spec's NEXT ACTION block

Lessons per category: A={{N}} B={{N}} C={{N}} D={{N}} E={{N}}
```

---

## ◈ STEP 3 — GENERATE REPORT

Generate `.hes/tasks/report-{{DATE}}.md`:

```markdown
# HES Evolution Report — {{DATE}}

Project: {{PROJECT_NAME}} | HES v3.1
Period: {{START_DATE}} → {{END_DATE}}
Analyzed cycles: {{N}} (cycles {{X}} to {{Y}})

---

## Velocity per Phase (minutes — average across cycles)

| Phase | {{Feature 1}} | {{Feature 2}} | {{Feature N}} | Average | Trend |
|-------|--------------|--------------|--------------|---------|-------|
| ZERO → DISCOVERY | | | | | ↓/→/↑ |
| DISCOVERY → SPEC | | | | | |
| SPEC → DESIGN | | | | | |
| DESIGN → DATA | | | | | |
| DATA → RED | | | | | |
| RED → GREEN | | | | | |
| GREEN → REVIEW | | | | | |
| **TOTAL** | | | | | |

## Slowest phase (main bottleneck)

**{{PHASE_WITH_HIGHEST_AVG_TIME}}** — average: {{T}} min

Hypothesis: {{BASED_ON_LESSONS_AND_CATEGORIES}}
Gap type: Guide (feedforward) / Sensor (feedback) / Process

---

## Self-Refinement Analysis

| Feature | RED→GREEN Iterations | Cause of Iterations |
|---------|--------------------|--------------------|
| {{feature}} | {{N}} | {{ERROR_CATEGORY}} |

Average iterations: {{N}}
Trend: {{decreasing / stable / increasing}}

---

## Lessons by Category

| Category | Occurrences | Distribution |
|----------|------------|-------------|
| A — HES rule violation | {{N}} | {{%}} |
| B — Recurring technical error | {{N}} | {{%}} |
| C — Guide gap | {{N}} | {{%}} |
| D — Sensor gap | {{N}} | {{%}} |
| E — Process | {{N}} | {{%}} |

---

## Recurring Lessons → Skill-File Candidates

| Lesson | Occurrences | Category | Target skill-file | Action |
|--------|------------|----------|-------------------|--------|
| {{LESSON}} | {{N}} | {{CAT}} | skills/{{XX}}.md | Add checklist / Reinforce rule |

> Rule (Fowler + LangChain): lesson with N >= 2 → improve the harness, not just fix instances.

---

## Identified Harness Gaps

### Recommended new computational sensors

| Gap | Type | Proposed Sensor | Effort |
|-----|------|----------------|--------|
| {{BOUNDARY_VIOLATION}} | Architecture Fitness | ArchUnit rule | S |
| {{STYLE_ISSUE}} | Maintainability | Custom linter rule | S |

### Guides to improve

| Skill-file | Improvement | Justification (trace-based) |
|-----------|------------|-----------------------------|
| skills/{{XX}}.md | {{WHAT_TO_ADD}} | {{PROBLEM_FREQUENCY}} |

---

## Harness Backlog (prioritized by velocity impact)

1. {{IMPROVEMENT_1}} — estimated impact: {{T}} min/cycle — Type: Guide/Sensor
2. {{IMPROVEMENT_2}}
3. {{IMPROVEMENT_3}}

---

## Process Health

| Indicator | Status | Observation |
|-----------|--------|------------|
| Skipped steps | 🟢/🔴 | {{N}} times |
| Specs before code | 🟢/🔴 | {{N}} violations |
| Average coverage | 🟢/🟡 | {{X}}% |
| Rollbacks | 🟢/🟡 | {{N}} rollbacks |
| ADRs generated | ✅ | {{N}} ADRs |
| Architecture fitness checks | ✅/❌ | configured/absent |

---

*HES Report | Cycles {{X}}–{{Y}} | v3.1.0 | {{CURRENT_DATE}}*
```

---

## ◈ STEP 4 — EXECUTE HARNESS IMPROVEMENTS

For each gap identified in Category C (guide) or D (sensor):

### Improve inferential guides (skill-files):

```
For Category C gaps — Insufficient guide:

1. Identify which skill-file did not guide the agent adequately
2. Propose addition to the skill-file:
   "Add to skills/{{XX}}.md → Anti-Hallucination section:
    [✅ NEW] Before {{ACTION}}, verify {{CONDITION}}"
3. Confirm with user before modifying the skill-file

For Category A gaps — HES rule violation:
1. Identify which RULE-XX was violated
2. Propose reinforcement in project's CLAUDE.md:
   "Add to .claude/CLAUDE.md:
    ATTENTION: Rule-XX violated in {{FEATURE}}. Verify {{WHAT}} before {{ACTION}}"
```

### Propose new computational sensors:

```
For Category D gaps — Missing sensor:

Example: undetected module boundary violation

Proposed new sensor:
  → ArchUnit rule: "{{RULE_NAME}}"
  → File: src/test/java/.../ArchitectureTest.java
  → Rule: {{RULE_DESCRIPTION_IN_CODE}}
  → Add to .hes/domains/{{domain}}/fitness/

[A] "approve and implement" → sensor code generated
[B] "implement later" → registered in harness backlog
[C] "not applicable" → registered with justification
```

---

## ◈ STEP 5 — UPDATE STATE

Update `current.json` — `completed_cycles` was already incremented at DONE.

Register in `events.log`:

```json
{
  "timestamp": "{{CURRENT_ISO_DATE}}",
  "feature": "global",
  "from": "ACTIVE",
  "to": "REPORT_GENERATED",
  "agent": "hes-v3.3",
  "metadata": {
    "report_file": ".hes/tasks/report-{{DATE}}.md",
    "cycles_analyzed": {{N}},
    "lessons_promoted": {{N}},
    "new_sensors_proposed": {{N}},
    "guides_improved": {{N}},
    "identified_bottleneck": "{{PHASE}}"
  }
}
```

---

────────────────────────────────────────────────────────────────
  REPORT complete
  {{N}} events · {{N}} lessons · {{N}} promotions pending
────────────────────────────────────────────────────────────────
  → continue

  A  promote lessons to skill-files — execute now
  B  start next feature — "feature name: [name]"
  C  view full events.log — "/hes status"

  💡 Lessons promoted 2× become permanent harness improvements.
────────────────────────────────────────────────────────────────
