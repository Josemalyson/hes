# HES — Step Budget Protocol (v3.5.0)
# Controla o número de chamadas ao LLM por fase
# Previne doom loops e custos descontrolados

---

## ◈ PROBLEMA RESOLVIDO

HES tinha time warnings (5/10/15 min) e doom loop prevention (max N tentativas),
mas sem **hard limit em chamadas ao LLM por fase**. Sistemas de produção (OpenAI, 2026)
definem step budgets de 20–50 por tarefa. Quando esgota: checkpoint + escalation.

---

## ◈ STEP BUDGETS POR FASE

| Fase      | Max Steps | Justificativa                                  |
|-----------|-----------|------------------------------------------------|
| DISCOVERY | 15        | Elicitação estruturada — não deve iterar muito |
| SPEC      | 20        | BDD tem formato fixo, não precisa de muitos loops |
| DESIGN    | 20        | ADRs são bem-definidos                         |
| DATA      | 15        | Migrations têm padrão fixo                     |
| RED       | 25        | TDD pode precisar de mais iterações            |
| GREEN     | 30        | Implementação é a fase mais complexa           |
| SECURITY  | 10        | Scan + auto-fix por arquivo                    |
| REVIEW    | 15        | 5 dimensões com checklists                     |

---

## ◈ SCHEMA EM CURRENT.JSON

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

## ◈ PROTOCOLO DE DECREMENTO (LLM executa)

No início de CADA ação que invoca raciocínio do LLM:

```bash
bash scripts/hooks/step-budget.sh decrement
```

O script:
1. Lê `current.json` → `step_budget[phase].used++`
2. Se `used >= max * 0.8` → warning (80% esgotado)
3. Se `used >= max` → **CHECKPOINT + ESCALATION** (não doom loop)
4. Loga ação `GATE_CHECK:step_budget` no events.log

---

## ◈ ESCALATION QUANDO BUDGET ESGOTA

```
⚠️ STEP BUDGET ESGOTADO — {PHASE} ({used}/{max} steps)

Estado atual:
  Feature  : {feature}
  Fase     : {phase}
  Progresso: {completed_steps}

Ações pendentes que não foram concluídas:
  - {pending_step_1}
  - {pending_step_2}

  [A] "/hes checkpoint" → salvar estado + continuar na próxima sessão
  [B] "/hes unlock --force" → aumentar budget para {max + 10} (loga risco)
  [C] "continuar" → o LLM tenta concluir com as informações atuais

💡 Budget esgotado não é falha — é sinal de que a tarefa precisa ser
   dividida em sub-tarefas menores (/hes start {feature}-part-2).
```

---

## ◈ TOKEN TRACKING (estimativa)

O LLM ESTIMA tokens consumidos por ação:

| Tipo de ação         | Tokens estimados (média) |
|----------------------|--------------------------|
| Leitura de arquivo   | tamanho_chars / 4         |
| Execução de comando  | 200 (output) + 100 (análise) |
| Geração de artefato  | 800 (spec) / 1500 (ADR)   |
| Decisão arquitetural | 1200                      |
| Scan de segurança    | 500 (análise findings)    |

Ao final de cada fase, loga no events.log:
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

## ◈ ANNOUNCE BLOCK ATUALIZADO (PASSO 3 do SKILL.md)

```
📍 HES v3.5.0 — {PROJECT}
Feature  : {feature} | Phase: {phase}
Agent    : {agent}
Budget   : {used}/{max} steps remaining
Tokens   : ~{tokens_estimated} (~${cost_usd_estimated:.3f})
```

---

## ◈ RULE-26 (adicionada ao SKILL.md)

```
RULE-26  LLM DECREMENTS step_budget[phase].used on each reasoning call
         At 80% → warn user of approaching limit
         At 100% → CHECKPOINT + ESCALATE (never doom loop, never silent continue)
         Reset step_budget when phase advances to next phase
```
