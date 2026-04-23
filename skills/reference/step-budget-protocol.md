# HES — Step Budget Protocol (v3.5.0)
# Controls the number of LLM calls per phase
# Prevents doom loops and runaway costs

---

## ◈ PROBLEM SOLVED

HES had time warnings (5/10/15 min) and doom loop prevention (max N attempts),
but no **hard limit on LLM calls per phase**. Production systems (OpenAI, 2026)
define step budgets of 20–50 per task. When exhausted: checkpoint + escalation.

---

## ◈ STEP BUDGETS PER PHASE

| Phase      | Max Steps | Rationale                                      |
|-----------|-----------|------------------------------------------------|
| DISCOVERY | 15        | Structured elicitation — should not iterate much |
| SPEC      | 20        | BDD has a fixed format — few loops needed        |
| DESIGN    | 20        | ADRs follow a well-defined format                |
| DATA      | 15        | Migrations follow a fixed pattern               |
| RED       | 25        | TDD may need more iterations                    |
| GREEN     | 30        | Implementation is the most complex phase        |
| SECURITY  | 10        | Scan + auto-fix per file                        |
| REVIEW    | 15        | 5 dimensions with checklists                    |

---

## ◈ SCHEMA IN CURRENT.JSON

```json
{
  "step_budget": {
    "DISCOVERY": { "max": 15, "used": 0, "last_reset": "ISO8601" },
    "SPEC":      { "max": 20, "used": 0, "last_reset": "ISO8601" },
    "DESIGN":    { "max": 20, "used": 0, "last_reset": "ISO8601" },
    "DATA":      { "max": 15, "used": 0, "last_reset": "ISO8601" },
    "RED":       { "max": 25, "used": 0, "last_reset": "ISO8601" },
    "GREEN":     { "max": 30, "used": 0, "last_reset": "ISO8601" },
    "SECURITY":  { "max": 10, "used": 0, "last_reset": "ISO8601" },
    "REVIEW":    { "max": 15, "used": 0, "last_reset": "ISO8601" }
  },
  "token_tracking": {
    "session_id": "uuid",
    "tokens_estimated": 0,
    "cost_usd_estimated": 0.0,
    "model_price_per_1k_input": 0.003,
    "model_price_per_1k_output": 0.015
  }
}
```

---

## ◈ DECREMENT PROTOCOL (LLM executes)

At the start of each action that invokes LLM reasoning:

```bash
bash scripts/hooks/step-budget.sh decrement
```

The script:
1. Reads `current.json` → `step_budget[phase].used++`
2. If `used >= max * 0.8` → warning (80% exhausted)
3. If `used >= max` → **CHECKPOINT + ESCALATION** (not a doom loop)
4. Logs action `GATE_CHECK:step_budget` to events.log

---

## ◈ ESCALATION WHEN BUDGET IS EXHAUSTED

```
⚠️ STEP BUDGET EXHAUSTED — {PHASE} ({used}/{max} steps)

Current state:
  Feature  : {feature}
  Phase    : {phase}
  Progress : {completed_steps}

Pending actions not yet completed:
  - {pending_step_1}
  - {pending_step_2}

  [A] "/hes checkpoint" → save state + continue in next session
  [B] "/hes unlock --force" → increase budget to {max + 10} (logs risk)
  [C] "continue" → LLM attempts to finish with current information

💡 Budget exhausted is not a failure — it signals the task needs to be
   split into smaller sub-tasks (/hes start {feature}-part-2).
```

---

## ◈ TOKEN TRACKING (estimate)

The LLM ESTIMATES tokens consumed per action:

| Action type          | Estimated tokens (avg)   |
|----------------------|--------------------------|
| File read         | file_chars / 4            |
| Command execution | 200 (output) + 100 (analysis)|
| Artifact generation| 800 (spec) / 1500 (ADR)  |
| Architectural decision | 1200                   |
| Security scan      | 500 (findings analysis)   |

At the end of each phase, log to events.log:
```json
{
  "action_type": "PHASE_COMPLETE",
  "phase": "GREEN",
  "tokens_estimated": 12400,
  "cost_usd_estimated": 0.22,
  "steps_used": 18,
  "steps_max": 30
}
```

---

## ◈ UPDATED ANNOUNCE BLOCK (SKILL.md step 3)

```
📍 HES v3.5.0 — {PROJECT}
Feature  : {feature} | Phase: {phase}
Agent    : {agent}
Budget   : {used}/{max} steps remaining
Tokens   : ~{tokens_estimated} (~${cost_usd_estimated:.3f})
```

---

## ◈ RULE-26 (added to SKILL.md)

```
RULE-26  LLM DECREMENTS step_budget[phase].used on each reasoning call
         At 80% → warn user of approaching limit
         At 100% → CHECKPOINT + ESCALATE (never doom loop, never silent continue)
         Reset step_budget when phase advances to next phase
```
