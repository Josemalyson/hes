# HES — Action Event Protocol (v3.4.0)
# Protocolo obrigatório de rastreabilidade intra-phase
# Resolve: gap de debug/tracking inside de each phase do workflow

---

## ◈ PROBLEMA RESOLVIDO

O `events.log` original registrava only transições de phase (ex: `SPEC → DESIGN`).
inside de each phase, as ações do LLM eram invisíveis. this protocolo cobre this gap.

---

## ◈ CONTRATO DE EVENTO

```json
{
  "timestamp":      "2026-04-18T10:30:00.000000+00:00",
  "session_id":     "uuid-gerado-no-bootstrap-imutável-na-sessão",
  "action_id":      "abc12345",
  "feature":        "payment",
  "phase":          "GREEN",
  "action_type":    "EXEC_CMD",
  "status":         "SUCCESS",
  "details": {
    "target":          "pytest tests/unit/",
    "result_summary":  "42 passed, 0 failed"
  }
}
```

### fields obrigatórios

| field | Tipo | Descrição |
|---|---|---|
| timestamp | ISO8601 | Momento exato da ação |
| session_id | UUID | Gerado no bootstrap, imutável na sessão |
| action_id | string | UUID curto (8 chars) — identifica ação única |
| feature | string | Feature ativa (de current.json.active_feature) |
| phase | string | phase current (de current.json.features[feature]) |
| action_type | enum | Tipo da ação (see tabela abaixo) |
| status | enum | STARTED | SUCCESS | FAILED | SKIPPED |
| details.target | string | file, comando, ou alvo da ação |
| details.result_summary | string | Resumo do resultado (1 linha) |

---

## ◈ TIPOS DE AÇÃO

| action_type | when use |
|---|---|
| READ_FILE | Ao ler any file of the project |
| WRITE_FILE | Ao criar ou modificar any file |
| EXEC_CMD | Ao executar any comando shell |
| GENERATE_ARTIFACT | Ao gerar spec, ADR, migration, test suite, etc. |
| LLM_DECISION | Ao tomar decisão arquitetural ou de design |
| TOOL_CALL | Ao invocar ferramenta externa (bandit, semgrep, etc.) |
| GATE_CHECK | Ao verificar gate de avanço de phase |
| SECURITY_SCAN | Específico for scans de security (alias de TOOL_CALL) |

---

## ◈ how use (LLM)

Toda ação significativa must ser envolvida por dois logs: `STARTED` e `SUCCESS`/`FAILED`.

```bash
# PADRÃO — toda ação executada pelo LLM:
bash scripts/hooks/log-action.sh EXEC_CMD STARTED "pytest tests/" "executando suite"

# ... executa a ação ...

bash scripts/hooks/log-action.sh EXEC_CMD SUCCESS "pytest tests/" "42 passed, 0 failed"
```

### Padrão for erros

```bash
bash scripts/hooks/log-action.sh EXEC_CMD STARTED "mvn compile" "compilando"

# ... ação falha ...

bash scripts/hooks/log-action.sh EXEC_CMD FAILED "mvn compile" "BUILD FAILURE: ClassNotFound XyzService"
```

---

## ◈ SESSION-ID

Gerado automaticamente no bootstrap (`00-bootstrap.md` STEP 2):

```bash
python3 -c "import uuid; print(str(uuid.uuid4()))" > .hes/state/session-id
```

- **Imutável** durante a sessão
- **Regenerado** a each new bootstrap
- **Usado** by the `log-action.sh` for agrupar eventos da mesma sessão

---

## ◈ QUERYING O LOG

```bash
# Ver todas as ações da sessão atual
SESSION=$(cat .hes/state/session-id)
grep "$SESSION" .hes/state/events.log | python3 -m json.tool

# Timeline de uma feature
python3 -c "
import json
feature = 'payment'
events = [json.loads(l) for l in open('.hes/state/events.log') if l.strip()]
for e in events:
    if e.get('feature') == feature:
        print(f\"{e['timestamp'][:19]} [{e['phase']:10}] {e['action_type']:20} {e['status']:8} — {e['details']['target']}\")
"

# Ver apenas falhas
python3 -c "
import json
events = [json.loads(l) for l in open('.hes/state/events.log') if l.strip()]
failures = [e for e in events if e.get('status') == 'FAILED']
for f in failures:
    print(json.dumps(f, indent=2))
"

# Estatísticas por tipo
python3 -c "
import json
from collections import Counter
events = [json.loads(l) for l in open('.hes/state/events.log') if l.strip()]
print(Counter(e['action_type'] for e in events))
"
```

---

## ◈ OBRIGATORIEDADE POR phase

| phase | Ações mínimas a logar |
|---|---|
| ZERO | GENERATE_ARTIFACT (estrutura .hes/), WRITE_FILE |
| DISCOVERY | LLM_DECISION (each business rule capturada) |
| SPEC | GENERATE_ARTIFACT (BDD scenarios, API contracts) |
| DESIGN | GENERATE_ARTIFACT (ADRs), LLM_DECISION (arch decisions) |
| DATA | WRITE_FILE (migrations, DTOs) |
| RED | WRITE_FILE (test files), EXEC_CMD (test runner) |
| GREEN | WRITE_FILE (impl files), EXEC_CMD (build, tests) |
| SECURITY | TOOL_CALL (bandit/semgrep), WRITE_FILE (correções), GATE_CHECK |
| REVIEW | GATE_CHECK (5 dimensões), LLM_DECISION |

---

## ◈ RULE-24 (adicionada ao SKILL.md)

```
RULE-24  LLM LOGS every significant action via scripts/hooks/log-action.sh
         YOU call log-action.sh BEFORE (STARTED) and AFTER (SUCCESS|FAILED) each action
         Actions without logs = invisible to the harness = NOT executed per protocol
         Minimum: every EXEC_CMD, WRITE_FILE, GENERATE_ARTIFACT, GATE_CHECK must be logged
```
