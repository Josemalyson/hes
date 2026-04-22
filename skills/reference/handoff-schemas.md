# HES — Typed Handoff Schemas (v3.5.0)
# Resolve: handoffs between agents eram em prosa — sem validation tipada
# Referência: GitHub (2026) "Multi-Agent Workflows Often Fail"

---

## ◈ PROBLEMA RESOLVIDO

> "Multi-agent systems behave like distributed systems, so every handoff needs
>  typed schemas, constrained action schemas, and explicit boundary validation."
> — GitHub Engineering Blog, Feb 2026

HES tinha delegação between agents definida em prosa Markdown (tool-dispatch.md).
Os schemas agora definem o contrato formal de each handoff.

---

## ◈ LOCALIZAÇÃO DOS SCHEMAS

```
.hes/schemas/
  ├── discovery-output.schema.json
  ├── spec-output.schema.json
  ├── design-output.schema.json
  ├── security-output.schema.json
  └── review-output.schema.json
```

---

## ◈ ESTRUTURA DE UM SCHEMA

```json
{
  "phase": "SECURITY",
  "description": "O que o security-agent deve entregar",
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

## ◈ PROTOCOLO DE validation DE HANDOFF (LLM executa)

before de any transição de phase, o LLM must:

```
STEP 1 — Carregar schema da fase atual
  → Ler .hes/schemas/{phase}-output.schema.json

STEP 2 — Verificar artifacts_required
  → Para cada artifact: verificar se arquivo existe
  → Se ausente: BLOQUEAR handoff + listar faltantes

STEP 3 — Executar validation_command (se definido)
  → bash scripts/hooks/log-action.sh GATE_CHECK STARTED "handoff-schema" "validando {phase} → {next_phase}"
  → Executar o comando
  → Se exit code ≠ 0: BLOQUEAR handoff

STEP 4 — Verificar checklist (inferencial)
  → Para cada item do checklist: confirmar que foi executado
  → Se algum item não executado: completar antes de avançar

STEP 5 — Log do handoff
  → bash scripts/hooks/log-action.sh GATE_CHECK SUCCESS "handoff-{phase}" "schema validado"
```

---

## ◈ RULE-27 (adicionada ao SKILL.md)

```
RULE-27  LLM VALIDATES handoff schema before every phase transition
         Load .hes/schemas/{phase}-output.schema.json
         Verify artifacts_required exist
         Execute validation_command if defined
         Complete checklist before advancing
         Never advance phase without schema validation
```
