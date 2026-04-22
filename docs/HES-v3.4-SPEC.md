# HES v3.4.0 — Implementation Spec
# Security Scan + Intra-Phase Debug Tracking
# Status: APPROVED | Autor: HES Bot | Data: 2026-04-18

---

## ◈ PLANO DE execution

```
FASE 1 — Infraestrutura de Tracking
  ├── Criar scripts/hooks/log-action.sh
  ├── Criar skills/reference/action-event-protocol.md
  └── Atualizar 00-bootstrap.md (session-id generation)

FASE 2 — Security Skill
  └── Criar skills/10-security.md (Bandit + Semgrep, auto-fix loop, gate)

FASE 3 — Integração no Workflow
  ├── Atualizar SKILL.md (state machine, routing, rules, schema)
  ├── Atualizar skills/06-implementation.md (gate → SECURITY antes de REVIEW)
  ├── Atualizar skills/07-review.md (substituir DIMENSION 3 por verificação de scan)
  └── Atualizar .hes/agents/registry.json (security-agent entry)

FASE 4 — Documentação
  ├── Atualizar README.md (nova fase, novo skill, novos comandos)
  ├── Atualizar ARCHITECTURE.md (state machine + action logging)
  └── Atualizar CHANGELOG.md (v3.4.0)
```

---

## ◈ PROBLEMA 1 — Security Scan Ausente

### Diagnóstico
`07-review.md` DIMENSION 3 (Security) is puramente **inferencial**: o LLM raciocina about
security sem executar nenhuma ferramenta. Falhas reais passam despercebidas.

### Solução
new phase obrigatória `SECURITY` between `GREEN` e `REVIEW`.

**Bandit** (primary — Python 82.9% of the project):
- PyCQA/bandit | pip install bandit | output JSON | auto-fix por test_id

**Semgrep** (secondary — Shell 17.1%):
- semgrep/semgrep | pip install semgrep | p/shell-hardening

### Gate
`SECURITY → REVIEW` only se `HIGH findings == 0`

---

## ◈ PROBLEMA 2 — Debug/Tracking Intra-phase Ausente

### Diagnóstico
`events.log` registra only transições de phase. Ações do LLM inside de each phase
(reads, writes, exec_cmds, decisions) are invisíveis — impossível rastrear execution real.

### Solução
**Action Event Protocol** with `scripts/hooks/log-action.sh` e session_id por sessão.

**Schema do evento:**
```json
{
  "timestamp": "ISO8601",
  "session_id": "uuid-gerado-no-bootstrap",
  "action_id": "8char-uuid",
  "feature": "feature-name",
  "phase": "GREEN",
  "action_type": "EXEC_CMD",
  "status": "SUCCESS | STARTED | FAILED | SKIPPED",
  "details": { "target": "...", "result_summary": "..." }
}
```

---

## ◈ new STATE MACHINE

```
ZERO → DISCOVERY → SPEC → DESIGN → DATA → RED → GREEN → SECURITY → REVIEW → DONE
```

| Transição | Gate |
|---|---|
| GREEN → SECURITY | Build + all tests passing |
| SECURITY → REVIEW | 0 HIGH findings + security-report-end.json generated |

---

## ◈ MUDANÇAS POR file

| file | Tipo | Impacto |
|---------|------|---------|
| `scripts/hooks/log-action.sh` | new | Tracking intra-phase |
| `skills/10-security.md` | new | phase SECURITY complete |
| `skills/reference/action-event-protocol.md` | new | Protocolo documentado |
| `docs/HES-v3.4-SPEC.md` | new | this file |
| `SKILL.md` | ATUALIZADO | State machine, routing, schema |
| `skills/00-bootstrap.md` | ATUALIZADO | Session-id generation |
| `skills/06-implementation.md` | ATUALIZADO | Gate SECURITY before de REVIEW |
| `skills/07-review.md` | ATUALIZADO | DIMENSION 3 vira verificação de scan |
| `.hes/agents/registry.json` | ATUALIZADO | security-agent |
| `README.md` | ATUALIZADO | Docs |
| `ARCHITECTURE.md` | ATUALIZADO | Docs |
| `CHANGELOG.md` | ATUALIZADO | v3.4.0 |

---

## ◈ CRITÉRIOS DE ACEITAÇÃO

- [ ] bandit executa e gera report parseável por LLM
- [ ] HIGH findings bloqueam avanço for REVIEW
- [ ] Auto-fix loop (max 2 tentativas por finding)
- [ ] log-action.sh loga STARTED/SUCCESS/FAILED de toda ação
- [ ] session_id UUID único por sessão gerado no bootstrap
- [ ] security-agent presente no registry.json
- [ ] /hes security resolve for security-agent
- [ ] README documenta new phase SECURITY
