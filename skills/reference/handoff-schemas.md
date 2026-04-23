# HES — Typed Handoff Schemas (v3.5.0)
# Resolves: handoffs between agents were prose-based — no typed validation
# Reference: GitHub (2026) "Multi-Agent Workflows Often Fail"

---

## ◈ PROBLEM SOLVED

> "Multi-agent systems behave like distributed systems, so every handoff needs
>  typed schemas, constrained action schemas, and explicit boundary validation."
> — GitHub Engineering Blog, Feb 2026

HES had delegation between agents defined in Markdown prose (tool-dispatch.md).
Schemas now define the formal contract for each handoff.

---

## ◈ SCHEMA LOCATIONS

```
.hes/schemas/
  ├── discovery-output.schema.json
  ├── spec-output.schema.json
  ├── design-output.schema.json
  ├── security-output.schema.json
  └── review-output.schema.json
```

---

## ◈ SCHEMA STRUCTURE

```json
{
  "phase": "SECURITY",
  "description": "What the security-agent must deliver",
  "artifacts_required": [
    ".hes/state/security-report-final.json",
    ".hes/state/security-exceptions.json"
  ],
  "gate_fields": {
    "high_findings":  { "operator": "==", "value": 0 },
    "gate_passed":    { "operator": "==", "value": true }
  },
  "validation_command": "python3 .hes/scripts/check-security-gate.py",
  "checklist": [...]
}
```

---

## ◈ HANDOFF VALIDATION PROTOCOL (LLM executes)

Before any phase transition, the LLM MUST:

```
STEP 1 — Load current phase schema
  → Ler .hes/schemas/{phase}-output.schema.json

STEP 2 — Verify artifacts_required
  → For each artifact: verify the file exists
  → If missing: BLOCK handoff + list missing items

STEP 3 — Execute validation_command (if defined)
  → bash scripts/hooks/log-action.sh GATE_CHECK STARTED "handoff-schema" "validating {phase} → {next_phase}"
  → Executar o comando
  → Se exit code ≠ 0: BLOQUEAR handoff

STEP 4 — Verify checklist (inferential)
  → For each checklist item: confirm it was executed
  → If any item not done: complete before advancing

STEP 5 — Log the handoff
  → bash scripts/hooks/log-action.sh GATE_CHECK SUCCESS "handoff-{phase}" "schema validated"
```

---

## ◈ RULE-27 (added to SKILL.md)

```
RULE-27  LLM VALIDATES handoff schema before every phase transition
         Load .hes/schemas/{phase}-output.schema.json
         Verify artifacts_required exist
         Execute validation_command if defined
         Complete checklist before advancing
         Never advance phase without schema validation
```
