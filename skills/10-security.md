# HES Skill — 10: Security Scan (SECURITY Phase)

> Skill loaded when: feature.state = SECURITY
> Pre-condition: GREEN phase complete (build + all tests passing)
> Invocação manual: /hes security
>
> Role no harness: **Computational Sensor — Security Fitness**
> Executa ferramentas open source de mercado (Bandit + Semgrep) que rodam na máquina do dev.
> O LLM lê o output, corrige os findings e re-executa até gate ser satisfeito.

---

## ◈ FERRAMENTAS

| Tool | Escopo | Instalação | Output |
|---|---|---|---|
| Bandit | Python (primário — 82.9% do projeto) | `pip install bandit` | JSON |
| Semgrep | Shell/Multi (secundário — 17.1%) | `pip install semgrep` | JSON |

---

## ◈ CONTEXT TO LOAD BEFORE ACTING

```
1. Read .hes/state/current.json → active_feature, session_id
2. Verify build is green (GREEN gate must be satisfied)
3. Identify file types in project (Python vs Shell ratio)
```

---

## ◈ STEP 0 — LOG INÍCIO

```bash
bash scripts/hooks/log-action.sh TOOL_CALL STARTED "security-scan" "iniciando SECURITY phase"
```

---

## ◈ STEP 1 — PRE-FLIGHT: VERIFICAR FERRAMENTAS

```bash
# Verificar Bandit
if ! pip show bandit &>/dev/null 2>&1; then
  bash scripts/hooks/log-action.sh TOOL_CALL STARTED "pip install bandit" "instalando"
  pip install bandit --break-system-packages -q
  bash scripts/hooks/log-action.sh TOOL_CALL SUCCESS "pip install bandit" "instalado"
fi

# Detectar Shell files
SHELL_FILES=$(find . -name "*.sh" \
  -not -path "./.git/*" \
  -not -path "./.hes/*" \
  -not -path "./venv/*" \
  -not -path "./node_modules/*" | wc -l | tr -d ' ')

# Verificar Semgrep (apenas se há Shell files)
if [ "$SHELL_FILES" -gt 0 ] && ! pip show semgrep &>/dev/null 2>&1; then
  bash scripts/hooks/log-action.sh TOOL_CALL STARTED "pip install semgrep" "instalando"
  pip install semgrep --break-system-packages -q
  bash scripts/hooks/log-action.sh TOOL_CALL SUCCESS "pip install semgrep" "instalado"
fi
```

---

## ◈ STEP 2 — EXECUTAR BANDIT (Python)

```bash
bash scripts/hooks/log-action.sh EXEC_CMD STARTED "bandit -r ." "executando scan Python"

bandit -r . \
  --exclude ./.hes,./venv,./.git,./node_modules,./dist,./build \
  -f json \
  -o .hes/state/security-report.json \
  --exit-zero

BANDIT_VERSION=$(pip show bandit | grep Version | awk '{print $2}')
bash scripts/hooks/log-action.sh EXEC_CMD SUCCESS "bandit -r ." "report gerado (bandit v$BANDIT_VERSION)"
```

---

## ◈ STEP 3 — EXECUTAR SEMGREP (Shell), se aplicável

```bash
if [ "$SHELL_FILES" -gt 0 ]; then
  bash scripts/hooks/log-action.sh EXEC_CMD STARTED "semgrep p/shell-hardening" "scan Shell"

  semgrep --config=p/shell-hardening \
    --exclude=".hes" --exclude="venv" --exclude=".git" \
    --json \
    --output .hes/state/semgrep-report.json \
    . 2>/dev/null || true

  bash scripts/hooks/log-action.sh EXEC_CMD SUCCESS "semgrep p/shell-hardening" "report gerado"
else
  bash scripts/hooks/log-action.sh EXEC_CMD SKIPPED "semgrep" "sem arquivos Shell detectados"
fi
```

---

## ◈ STEP 4 — PARSEAR E TRIAR FINDINGS

O LLM executa este script para extrair e classificar findings:

```python
import json

with open(".hes/state/security-report.json") as f:
    report = json.load(f)

by_severity = {"HIGH": [], "MEDIUM": [], "LOW": []}

for r in report.get("results", []):
    sev = r.get("issue_severity", "LOW").upper()
    by_severity.setdefault(sev, []).append({
        "test_id":    r["test_id"],
        "file":       r["filename"],
        "line":       r["line_number"],
        "issue":      r["issue_text"],
        "confidence": r.get("issue_confidence", "MEDIUM"),
        "code":       r.get("code", "")
    })

print(json.dumps(by_severity, indent=2))
```

**Regras de triagem:**

| Severidade | Ação do LLM |
|---|---|
| HIGH | Bloqueia avanço. LLM corrige IMEDIATAMENTE. |
| MEDIUM | LLM analisa contexto. Corrige OU documenta exceção com justificativa. |
| LOW | LLM documenta em `security-exceptions.json`. Não bloqueia. |

---

## ◈ STEP 5 — AUTO-CORREÇÃO (HIGH e MEDIUM selecionados)

Para cada finding a corrigir, o LLM executa o loop:

```
1. bash scripts/hooks/log-action.sh WRITE_FILE STARTED "{file}:{line}" "corrigindo {test_id}"

2. LLM lê o arquivo com contexto (±15 linhas ao redor)

3. LLM aplica correção conforme guia abaixo

4. LLM escreve arquivo corrigido

5. LLM re-executa bandit SOMENTE no arquivo:
   bandit {file} -f json --exit-zero

6. Se finding sumiu:
   bash scripts/hooks/log-action.sh WRITE_FILE SUCCESS "{file}:{line}" "{test_id} corrigido"

7. Se persistir (tentativa 1 → 2):
   → LLM tenta abordagem alternativa

8. Se ainda persistir após 2 tentativas:
   bash scripts/hooks/log-action.sh WRITE_FILE FAILED "{file}:{line}" "{test_id} requer intervenção manual"
   → LLM documenta como exceção com justificativa técnica detalhada
   → LLM escala para usuário se for HIGH
```

### Guia de correção por test_id

| test_id | Problema | Correção padrão |
|---|---|---|
| B101 | assert em prod | Substituir por `raise ValueError` ou `if/raise` explícito |
| B105/B106/B107 | Hardcoded credential | `os.environ.get('VAR_NAME')` ou `secrets` manager |
| B301/B302 | pickle inseguro | Substituir por `json.loads()` ou `orjson` |
| B311 | random para segurança | `secrets.token_hex(16)` ou `secrets.randbelow(n)` |
| B324 | MD5/SHA1 | `hashlib.sha256(data).hexdigest()` |
| B501/B502/B503 | TLS/SSL fraco | `ssl.PROTOCOL_TLS_CLIENT` + `check_hostname=True` |
| B601/B602/B603 | Shell injection | `subprocess.run([cmd, arg], shell=False)` |
| B608 | SQL injection | Parâmetros preparados: `cursor.execute(sql, (param,))` |
| B701/B702 | Jinja2 sem autoescape | `Environment(autoescape=True)` |

---

## ◈ STEP 6 — DOCUMENTAR EXCEÇÕES

Para MEDIUM/LOW não corrigidos (ou HIGH não auto-corrigíveis):

```python
import json
from datetime import datetime, timezone

exceptions = [
    {
        "test_id": "B311",
        "file": "path/to/file.py",
        "line": 42,
        "severity": "MEDIUM",
        "justification": "random() usado apenas para mock em testes, não em produção",
        "decided_by": "LLM",
        "timestamp": datetime.now(timezone.utc).isoformat()
    }
]

with open(".hes/state/security-exceptions.json", "w") as f:
    json.dump(exceptions, f, indent=2)
```

```bash
bash scripts/hooks/log-action.sh GENERATE_ARTIFACT SUCCESS "security-exceptions.json" \
  "$(python3 -c "import json; e=json.load(open('.hes/state/security-exceptions.json')); print(f'{len(e)} exceções documentadas')")"
```

---

## ◈ STEP 7 — RE-SCAN FINAL COMPLETO

```bash
bash scripts/hooks/log-action.sh EXEC_CMD STARTED "bandit final re-scan" "validando correções"

bandit -r . \
  --exclude ./.hes,./venv,./.git,./node_modules,./dist,./build \
  -f json \
  -o .hes/state/security-report-final.json \
  --exit-zero

bash scripts/hooks/log-action.sh EXEC_CMD SUCCESS "bandit final re-scan" \
  "report final gerado em .hes/state/security-report-final.json"
```

---

## ◈ STEP 8 — GATE CHECK

```python
import json, sys

with open(".hes/state/security-report-final.json") as f:
    report = json.load(f)

high = [r for r in report.get("results", []) if r["issue_severity"] == "HIGH"]

if high:
    print(f"GATE FAILED: {len(high)} HIGH finding(s) restantes")
    for h in high:
        print(f"  [{h['test_id']}] {h['filename']}:{h['line_number']} — {h['issue_text']}")
    sys.exit(1)
else:
    print("GATE PASSED: zero HIGH findings")
```

```bash
if python3 .hes/scripts/check-security-gate.py; then
  bash scripts/hooks/log-action.sh GATE_CHECK SUCCESS "security-gate" "zero HIGH findings — avançando para REVIEW"
  GATE_PASSED=true
else
  bash scripts/hooks/log-action.sh GATE_CHECK FAILED "security-gate" "HIGH findings restantes — bloqueado"
  GATE_PASSED=false
fi
```

---

## ◈ STEP 9 — REGISTRAR EVENTO DE FASE NO EVENTS.LOG

```python
import json
from datetime import datetime, timezone

with open(".hes/state/security-report-final.json") as f:
    final = json.load(f)

results = final.get("results", [])
by_sev = {"HIGH": 0, "MEDIUM": 0, "LOW": 0}
for r in results:
    by_sev[r["issue_severity"]] = by_sev.get(r["issue_severity"], 0) + 1

with open(".hes/state/security-exceptions.json") as f:
    exceptions = json.load(f)

# Ler current state
with open(".hes/state/current.json") as f:
    state = json.load(f)
feature = state.get("active_feature", "unknown")

event = {
    "timestamp": datetime.now(timezone.utc).isoformat(),
    "session_id": open(".hes/state/session-id").read().strip(),
    "feature": feature,
    "from": "SECURITY",
    "to": "REVIEW" if by_sev["HIGH"] == 0 else "SECURITY",
    "agent": "security-agent",
    "metadata": {
        "tool": "bandit+semgrep",
        "findings_final": by_sev,
        "exceptions_documented": len(exceptions),
        "gate_passed": by_sev["HIGH"] == 0
    }
}

with open(".hes/state/events.log", "a") as f:
    f.write(json.dumps(event) + "\n")
```

---

## ◈ STEP 10 — ATUALIZAR ESTADO

Se gate passou:

```python
import json
from datetime import datetime, timezone

with open(".hes/state/current.json") as f:
    state = json.load(f)

feature = state.get("active_feature")
state["features"][feature] = "REVIEW"
state["last_updated"] = datetime.now(timezone.utc).isoformat()

with open(".hes/state/current.json", "w") as f:
    json.dump(state, f, indent=2)
```

```bash
bash scripts/hooks/log-action.sh WRITE_FILE SUCCESS "current.json" "state → REVIEW"
```

---

## ◈ REPORT FORMAT (exibir ao usuário)

```
🔐 HES Security Scan — {feature}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Ferramentas  : bandit v{version} | semgrep v{version}
Arquivos     : {N} Python | {M} Shell

FINDINGS (pré-correção):
  🔴 HIGH   : {N_h} → {fixed_h} auto-corrigidos
  🟡 MEDIUM : {N_m} → {fixed_m} corrigidos, {exc_m} com exceção
  🟢 LOW    : {N_l} → documentados

RESULTADO FINAL:
  🔴 HIGH   : 0  ← obrigatório para gate
  🟡 MEDIUM : {remaining_m}
  🟢 LOW    : {remaining_l}

GATE: ✅ PASSOU — avançando para REVIEW
      ❌ BLOQUEADO — corrigir findings HIGH antes de continuar
```

---

## ◈ GATE DE AVANÇO (obrigatório)

O LLM SÓ avança para REVIEW se TODAS as condições forem atendidas:

```
[ ] security-report-final.json gerado
[ ] zero findings HIGH no report final
[ ] todos MEDIUM com decisão: corrigido OU exceção documentada
[ ] security-exceptions.json existe (pode ser [])
[ ] evento de fase registrado no events.log
[ ] current.json atualizado: features[feature] = "REVIEW"
```

---

## ◈ INVOCAÇÃO MANUAL

```
/hes security           → executa scan completo na feature atual
/hes security --report  → exibe último report sem re-executar scan
```

---

▶ NEXT ACTION — REVIEW

```
🔐 Security scan completo.

  [A] "gate passou, zero HIGH"
      → Avançando para REVIEW (skills/07-review.md)

  [B] "HIGH finding {test_id} em {file}:{line}"
      → Loop de auto-correção (STEP 5) — tentativa {N}/2

  [C] "gate falhou após 2 tentativas"
      → Escalar para usuário — listar findings bloqueantes

📄 Próximo skill-file: skills/07-review.md
🤖 Agente: review-agent
💡 Tip: Security scan executa ANTES de code review.
   Não faz sentido revisar código que contém vulnerabilidades conhecidas.
   Tool-first, human-review-second.
```
