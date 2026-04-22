# HES — Telemetry Protocol (v3.5.0)
# Spans OpenTelemetry-style: latência, custo, hierarquia de ações
# Referência: OpenAI Codex (2026) — ephemeral observability stack per worktree

---

## ◈ PROBLEMA RESOLVIDO

O Action Event Protocol (v3.4.0) registra o QUÊ aconteceu.
A Telemetria registra o QUANTO TEMPO e QUANTO CUSTOU.
Juntos formam o stack complete de observabilidade do HES.

---

## ◈ SCHEMA DE SPAN (OpenTelemetry-compatible)

```json
{
  "trace_id":      "uuid-da-feature — imutável por feature",
  "span_id":       "uuid-da-acao — único",
  "parent_span_id":"uuid-pai (fase = parent de ação)",
  "name":          "EXEC_CMD:pytest",
  "phase":         "GREEN",
  "feature":       "payment",
  "session_id":    "uuid-da-sessão",
  "start_time":    "ISO8601",
  "end_time":      "ISO8601",
  "duration_ms":   2340,
  "tokens_estimated": 1200,
  "cost_usd_estimated": 0.0036,
  "status":        "SUCCESS | FAILED | TIMEOUT",
  "attributes": {
    "target":       "pytest tests/unit/",
    "result":       "42 passed, 0 failed",
    "offloaded":    false
  }
}
```

---

## ◈ file DE TELEMETRIA

```
.hes/state/telemetry.jsonl   ← um span por linha (JSONL format)
```

---

## ◈ ESTIMATIVA DE TOKENS POR AÇÃO

| Tipo de ação          | Estimativa de tokens     |
|-----------------------|--------------------------|
| Leitura de file    | `chars / 4`              |
| execution de comando   | 300 (output + analysis)   |
| generation de artefato   | 1.200 (spec/ADR)         |
| Decisão arquitetural  | 1.500                    |
| Security scan         | 600 (analysis de findings)|
| BDD scenario (1)      | 200                      |

Preço de referência (Claude Sonnet):
- Input:  $0.003 / 1K tokens
- Output: $0.015 / 1K tokens
- Média:  $0.009 / 1K tokens

---

## ◈ PROTOCOLO (LLM executa)

```bash
# Iniciar span de FASE (parent span)
bash scripts/hooks/telemetry.sh start_phase GREEN {feature}

# Para cada ação dentro da fase:
bash scripts/hooks/telemetry.sh start_action EXEC_CMD "pytest tests/" {phase_span_id}
# ... executar ação ...
bash scripts/hooks/telemetry.sh end_action {action_span_id} SUCCESS "42 passed" 2340

# Ao finalizar a fase:
bash scripts/hooks/telemetry.sh end_phase {phase_span_id} SUCCESS
```

---

## ◈ QUERIES ÚTEIS

```bash
# Timeline de uma feature
bash scripts/hooks/telemetry.sh timeline payment

# Fases mais lentas (all time)
bash scripts/hooks/telemetry.sh slowest-phases

# Custo por sessão
bash scripts/hooks/telemetry.sh cost --session {session_id}

# Output:
# Feature: payment | Total: 45.2 min | Cost: ~$0.38
# ┌─────────────┬──────────┬─────────┬──────────┐
# │ Phase       │ Duration │ Steps   │ Cost     │
# ├─────────────┼──────────┼─────────┼──────────┤
# │ DISCOVERY   │  8.2 min │  9 stp  │ $0.04    │
# │ SPEC        │ 12.1 min │ 14 stp  │ $0.08    │
# │ GREEN       │ 18.4 min │ 22 stp  │ $0.19    │
# │ SECURITY    │  6.5 min │  8 stp  │ $0.07    │
# └─────────────┴──────────┴─────────┴──────────┘
```

---

## ◈ INTEGRAÇÃO with ANNOUNCE BLOCK

Adicionar ao step 3 do SKILL.md:

```
📍 HES v3.5.0 — {PROJECT}
Feature  : {feature} | Phase: {phase}
Budget   : {steps_used}/{steps_max} steps
Telemetry: ~{duration_min:.1f}min | ~{tokens:,} tokens | ~${cost:.3f}
```
