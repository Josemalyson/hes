# HES Skill — 12: Harness Self-Testing
# Invocação: /hes test [--structural] [--behavioral] [--all]
# Testa o harness em si — não o código do projeto

---

## ◈ POR QUE TESTAR O HARNESS

> "CI quality gate so PRs that degrade an agent are automatically flagged"
> — LangSmith (2026)

Um bug no routing do SKILL.md ou uma inconsistência no registry.json
pode fazer o LLM falhar silenciosamente. Os testes do harness detectam
isso antes que chegue à produção.

---

## ◈ TIPO 1 — STRUCTURAL TESTS (determinísticos, rápidos)

Executar via `scripts/ci/validate-harness.py --check all`:

```
TEST-S01: registry.json é JSON válido
TEST-S02: todos skill-files no registry existem no filesystem
TEST-S03: versão do SKILL.md == versão no registry
TEST-S04: state machine no SKILL.md contém todas as fases: ZERO → DONE
TEST-S05: CHANGELOG.md tem entry para versão atual
TEST-S06: scripts/hooks/*.sh são executáveis (chmod +x)
TEST-S07: .hes/scripts/*.py compilam sem erro (python -m py_compile)
TEST-S08: .hes/schemas/*.json são JSON válidos
TEST-S09: .hes/evals/tasks/**/*.json são JSON válidos
TEST-S10: todos os comandos /hes documentados no README existem no SKILL.md
```

---

## ◈ TIPO 2 — BEHAVIORAL TESTS (LLM-as-judge, mais lentos)

```
TEST-B01: dado feature=GREEN, SKILL.md roteia para impl-agent?
  Input: current.json com features.payment = "GREEN"
  Expected: routing table retorna skills/06-implementation.md

TEST-B02: dado feature=SECURITY, routing carrega 10-security.md?
  Input: current.json com features.payment = "SECURITY"
  Expected: routing table retorna skills/10-security.md

TEST-B03: dado erro categoria B, error-recovery.md propõe lesson?
  Input: descrição de erro técnico recorrente
  Expected: output contém entrada para lessons.md (categoria B)

TEST-B04: dado session > 100 mensagens, session-manager detecta bloat?
  Input: session.messages_in_session = 105
  Expected: output menciona context compaction protocol

TEST-B05: dado HIGH finding no bandit, gate SECURITY bloqueia?
  Input: security-report-final.json com HIGH finding
  Expected: check-security-gate.py retorna exit code 1
```

---

## ◈ FLUXO DE EXECUÇÃO

### STEP 1 — Structural tests
```bash
bash scripts/hooks/log-action.sh TOOL_CALL STARTED "harness-tests" "structural"
python3 scripts/ci/validate-harness.py --check all
bash scripts/hooks/log-action.sh TOOL_CALL SUCCESS "harness-tests" "structural: {N} passed"
```

### STEP 2 — Behavioral tests (se --behavioral ou --all)
```
Para cada TEST-B:
  1. Preparar input (mock de current.json ou output de ferramenta)
  2. LLM executa o comportamento esperado
  3. LLM-as-judge avalia: o comportamento foi correto?
  4. Log resultado
```

### STEP 3 — Report
```
🧪 HES Self-Test Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Structural: {N}/{total} passed
Behavioral: {N}/{total} passed

Failures:
  [TEST-S04] State machine missing phase SECURITY
  ...

GATE: ✅ All tests passed
      ❌ {N} failure(s) — fix before merging
```

---

## ◈ COMANDOS

```
/hes test                   → roda structural (rápido)
/hes test --structural      → apenas structural tests
/hes test --behavioral      → apenas behavioral tests (LLM-as-judge)
/hes test --all             → structural + behavioral
```

---

▶ NEXT ACTION

```
🧪 Harness self-tests executados.

  [A] "todos os testes passaram"
      → Harness está saudável — pode mergear

  [B] "TEST-S{N} falhou: {descrição}"
      → Corrigir antes de continuar: {instrução de fix}

  [C] "/hes harness"
      → Diagnóstico de cobertura das 3 dimensões (complementar)

📄 Skill-file: skills/12-harness-tests.md
```
