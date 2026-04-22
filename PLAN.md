# HES — Improvement Plan v1.0
# O que existe, o que falta, e o que o mercado exige em 2026
# Autor: analysis técnica baseada em Fowler (2026), LangChain (2026), OpenAI (2026), Anthropic (2026)
# Data: 2026-04-18

---

## ◈ state current DO HES (inventário honesto)

### O que o HES já tem (pontos fortes)
```
✅ Phase-locked state machine (10 fases: ZERO → DONE)
✅ Event sourcing com events.log (transições de fase)
✅ Action Event Protocol (intra-fase, v3.4.0)
✅ Learning loop hot-path + offline (lessons.md → skill-file promotion)
✅ Session management com checkpoints e context compaction
✅ Self-refinement loop com doom loop prevention (max attempts)
✅ Reasoning sandwich (high→medium→high reasoning budget)
✅ Security scan automatizado (Bandit + Semgrep, v3.4.0)
✅ Agent registry com routing dinâmico
✅ Error recovery com categorias A-E
✅ Legacy project support com harnessability assessment
✅ Progressive analysis para codebases > 50 arquivos
✅ Multi-language detection (pt-BR, en, es, fr, de)
✅ Audience mode (beginner | expert)
✅ Harness health diagnostics (/hes harness)
✅ DDD domain support com bounded contexts
✅ Architecture fitness via ArchUnit / dep-cruiser / import-linter
✅ Git hooks (LLM-executed, computational sensors)
✅ TDD enforcement (RED antes de GREEN)
✅ 5-dimension code review
✅ Batch learning via /hes report
```

### O que falta (gaps identificados vs. padrões de mercado 2026)
```
❌ Eval harness (offline evals + regression suite)
❌ LLM-as-judge para avaliação qualitativa
❌ Context engineering no nível de ferramenta (tool output summarization)
❌ Telemetria estruturada (OpenTelemetry-style: spans, latência, custo)
❌ Step budget por fase (hard limit em chamadas ao LLM)
❌ Token budget + cost tracking por sessão
❌ Typed handoff schemas entre agents
❌ CI/CD integration (GitHub Actions para harness validation)
❌ Harness self-testing (testes automatizados dos próprios skill-files)
❌ Multi-model support (HES só funciona bem com Claude)
❌ Synthetic golden dataset para regression testing
❌ HITL protocol explícito (human-in-the-loop async)
❌ Skill versioning por arquivo (compatibility matrix)
❌ MCP integration (ferramentas externas via Model Context Protocol)
❌ Sub-agent tool isolation (cada sub-agent com tool set restrito)
❌ Harness entropy monitor (drift detection em projetos longos)
```

---

## ◈ PRIORIZAÇÃO (Impacto × Esforço)

```
TIER 1 — CRÍTICO (resolve dores reais, alto impacto imediato)
  P1-A  Eval Harness + LLM-as-judge
  P1-B  Telemetria Estruturada (spans, latência, custo)
  P1-C  Step Budget + Token Tracking por fase

TIER 2 — ALTO VALOR (eleva qualidade arquitetural)
  P2-A  CI/CD Integration (GitHub Actions)
  P2-B  Typed Handoff Schemas (multi-agent)
  P2-C  Context Engineering no nível de ferramenta

TIER 3 — DIFERENCIAÇÃO (torna o HES referência de mercado)
  P3-A  Multi-model Support
  P3-B  MCP Integration
  P3-C  Skill Versioning + Compatibility Matrix
  P3-D  Harness Self-Testing
  P3-E  Synthetic Golden Dataset
```

---

## ◈ TIER 1 — CRÍTICO

---

### P1-A | Eval Harness + LLM-as-judge

**Por que falta:**
O HES valida comportamento via tests de produção (RED/GREEN) e review manual (DIMENSION 1-5).
but not tem **eval automatizada**: um conjunto de tasks curados que medem se o harness
*still funciona* after mudanças nos skill-files. Segundo LangChain (2026), only 52% dos
times têm evals — but esses times detectam regressões before dos usuários.

**O que o mercado faz (2026):**
- **Offline evals**: tasks curadas + graders determinísticos. Rápidos, gratuitos, reproduzíveis.
  Ex: "data this prompt de discovery, o LLM gera ≥3 business rules?" → boolean check.
- **LLM-as-judge**: grader not-determinístico for dimensões qualitativas.
  Ex: "o ADR gerado explica o trade-off arquitetural de forma clara?" → 1–5 score.
- **pass@k**: each task roda k vezes. pass@k = ≥1 sucesso em k tentativas (capacidade).
  pass^k = all k sucessos (confiabilidade). High pass@k + low pass^k = instabilidade.
- **Regression gate**: PR que degrada score abaixo do baseline is bloqueado automaticamente.

**Referências:**
- Anthropic: "Demystifying evals for AI agents" (2026)
- LangChain: "Agent Evaluation Readiness Checklist" (2026)
- DeepEval / Confident AI: framework open source for unit testing de LLMs

**O que implementar no HES:**

```
skills/11-eval.md — Eval Harness Skill
  ├── Dataset de tarefas por fase (.hes/evals/tasks/)
  │     ├── discovery-tasks.json   (10 casos: prompt → expected BRs)
  │     ├── spec-tasks.json        (10 casos: BRs → BDD scenarios)
  │     ├── design-tasks.json      (10 casos: spec → ADR)
  │     └── review-tasks.json     (10 casos: código → checklist result)
  ├── Graders determinísticos por dimensão
  │     ├── has_minimum_brs(n=3)     → boolean
  │     ├── bdd_format_valid()       → boolean
  │     ├── no_hardcoded_secrets()   → boolean
  │     └── coverage_above(80)       → boolean
  ├── LLM-as-judge para dimensões qualitativas
  │     ├── adr_explains_tradeoff()  → score 1-5
  │     ├── spec_is_testable()       → score 1-5
  │     └── implementation_minimal() → score 1-5
  └── Métricas de saída
        ├── pass@k (k=3 por default)
        ├── pass^k (confiabilidade)
        └── phase_score (média por fase)

Comando: /hes eval [--phase <nome>] [--k 3] [--llm-judge]
Saída: .hes/evals/results/eval-report-{timestamp}.json
```

**Schema de task eval:**
```json
{
  "task_id": "disc-001",
  "phase": "DISCOVERY",
  "description": "Dado prompt de feature 'login com JWT', gerar business rules",
  "input": "Quero implementar autenticação com JWT para minha API REST",
  "graders": [
    { "type": "deterministic", "check": "count_items(output, 'RN-') >= 3" },
    { "type": "llm-judge", "rubric": "As regras capturam caso de expiração de token?" }
  ],
  "baseline_score": 0.8
}
```

---

### P1-B | Telemetria Estruturada (OpenTelemetry-style)

**Por que falta:**
O events.log current registra eventos, but not tem:
- **Latência por phase** (quanto tempo GREEN levou?)
- **Custo por sessão** (quantos tokens foram usados?)
- **Span hierarchy** (qual ação inside de GREEN demorou more?)

OpenAI (2026) constrói a stack de observabilidade local efêmera por worktree.
O Codex can do queries with LogQL e PromQL no próprio contexto de execution.

**O que o mercado faz (2026):**
```
Span hierarchy (OpenTelemetry):
  Trace: feature "payment" (45 min)
    └── Span: DISCOVERY (8 min)
    └── Span: SPEC (12 min)
    └── Span: GREEN (18 min)
          └── Span: EXEC_CMD "pytest" (2.3s)
          └── Span: WRITE_FILE "service.py" (0.1s)
          └── Span: EXEC_CMD "bandit" (1.1s)
    └── Span: SECURITY (7 min)
```

**Tools open source relevantes:**
- **LangFuse** (open source self-hosted) — tracing nativo for LLMs
- **Arize Phoenix** (open source) — observabilidade for agents
- **OpenTelemetry** — padrão de spans for sistemas distribuídos

**O que implementar no HES:**

```
skills/reference/telemetry-protocol.md
  ├── Schema de span (estende o action event)
  │     ├── trace_id       (por feature, imutável)
  │     ├── span_id        (por ação, único)
  │     ├── parent_span_id (hierarquia)
  │     ├── duration_ms    (calculado: end - start)
  │     ├── tokens_used    (estimado pelo LLM se disponível)
  │     └── cost_usd       (tokens × price_per_token)
  ├── .hes/state/telemetry.jsonl (formato JSONL, um span por linha)
  └── Query helpers:
        /hes telemetry --feature payment   → timeline de spans
        /hes telemetry --phase GREEN       → agregado de todas as sessões
        /hes telemetry --cost              → custo estimado por sessão

scripts/hooks/telemetry-span.sh  → extensão do log-action.sh com timing
```

**Schema de span:**
```json
{
  "trace_id": "uuid-da-feature",
  "span_id": "uuid-da-acao",
  "parent_span_id": "uuid-pai",
  "name": "EXEC_CMD:pytest",
  "phase": "GREEN",
  "feature": "payment",
  "start_time": "ISO8601",
  "end_time": "ISO8601",
  "duration_ms": 2340,
  "tokens_estimated": 1200,
  "status": "SUCCESS",
  "attributes": { "target": "pytest tests/unit/", "result": "42 passed" }
}
```

---

### P1-C | Step Budget + Token Tracking por phase

**Por que falta:**
HES tem time warnings (5/10/15 min) e doom loop prevention (max N tentativas),
but not tem **hard limit em chamadas ao LLM** por phase nem **rastreamento de tokens**.
Sistemas de produção (OpenAI, Anthropic 2026) definem step budgets between 20–50 por task.

**O que o mercado faz:**
```
Step budget:
  DISCOVERY: max 15 LLM calls
  SPEC:      max 20 LLM calls
  GREEN:     max 30 LLM calls (mais complexo)
  SECURITY:  max 10 LLM calls
  REVIEW:    max 15 LLM calls

Quando step budget esgota:
  → LLM apresenta estado atual
  → Salva checkpoint
  → Escala para usuário com contexto completo
```

**O que implementar no HES:**

```
Adicionar ao schema de current.json:
  "step_budget": {
    "DISCOVERY": { "max": 15, "used": 0 },
    "SPEC":      { "max": 20, "used": 0 },
    "DESIGN":    { "max": 20, "used": 0 },
    "DATA":      { "max": 15, "used": 0 },
    "RED":       { "max": 25, "used": 0 },
    "GREEN":     { "max": 30, "used": 0 },
    "SECURITY":  { "max": 10, "used": 0 },
    "REVIEW":    { "max": 15, "used": 0 }
  }

RULE-26 (adicionar ao SKILL.md):
  LLM DECREMENTS step_budget[phase].used on each LLM call
  If used >= max → CHECKPOINT + ESCALATE (não doom loop)

Adicionar ao ANNOUNCE block (PASSO 3):
  Step budget: {{used}}/{{max}} remaining
```

---

## ◈ TIER 2 — ALTO value

---

### P2-A | CI/CD Integration (GitHub Actions)

**Por que falta:**
HES is executado manualmente. not há validation automática when skill-files are modificados.
Um PR que quebra o routing do SKILL.md ou invalida o registry.json passa despercebido.

**O que o mercado faz (2026):**
> "CI quality gate so PRs that degrade an agent are automatically flagged" — LangSmith (2026)

**O que implementar:**

```
.github/
  └── workflows/
        ├── harness-validation.yml    → valida estrutura e JSON em todo PR
        └── eval-regression.yml       → roda /hes eval em PRs para main (futuro P1-A)

harness-validation.yml:
  - trigger: push e pull_request
  - steps:
      1. Verificar todos os skill-files referenciados no registry.json existem
      2. Validar registry.json é JSON válido
      3. Verificar SKILL.md referencia versão consistente com registry
      4. Verificar que a state machine no SKILL.md e no README estão em sync
      5. Verificar log-action.sh é executável (chmod +x)
      6. Verificar check-security-gate.py é Python válido (python -m py_compile)

scripts/ci/validate-harness.py  → script Python do CI
```

**YAML mínimo:**
```yaml
# .github/workflows/harness-validation.yml
name: HES Harness Validation
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate registry.json
        run: python3 -m json.tool .hes/agents/registry.json > /dev/null
      - name: Check all skill files exist
        run: python3 scripts/ci/validate-harness.py
      - name: Validate Python scripts
        run: |
          python3 -m py_compile .hes/scripts/check-security-gate.py
          python3 -m py_compile scripts/ci/validate-harness.py
```

---

### P2-B | Typed Handoff Schemas (Multi-Agent)

**Por que falta:**
HES tem agent delegation (`tool-dispatch.md`) but os handoffs between agents are
definidos em prosa Markdown — not há schema tipado. Segundo GitHub (2026):
> "Multi-agent systems behave like distributed systems, so every handoff needs
>  typed schemas, constrained action schemas, and explicit boundary validation."

**O que implementar:**

```
skills/reference/handoff-schemas.md  → spec dos schemas
.hes/schemas/
  ├── discovery-output.schema.json   → o que discovery-agent entrega
  ├── spec-output.schema.json        → o que spec-agent entrega
  ├── design-output.schema.json      → o que design-agent entrega
  ├── security-output.schema.json    → o que security-agent entrega
  └── review-output.schema.json      → o que review-agent entrega

Cada schema define:
  - artifacts_required: arquivos que DEVEM existir antes do handoff
  - gate_fields: campos do events.log que DEVEM estar presentes
  - validation_command: script Python que valida o output antes do handoff

Exemplo — security-output.schema.json:
{
  "phase": "SECURITY",
  "artifacts_required": [
    ".hes/state/security-report-final.json",
    ".hes/state/security-exceptions.json"
  ],
  "gate_fields": {
    "findings_final.HIGH": { "operator": "==", "value": 0 },
    "gate_passed": { "operator": "==", "value": true }
  },
  "validation_command": "python3 .hes/scripts/check-security-gate.py"
}
```

---

### P2-C | Context Engineering no Nível de Ferramenta

**Por que falta:**
HES lida with context bloat no nível de sessão (session-manager.md).
but not trata context bloat no nível de **output de ferramentas**.
Segundo pesquisa (2026): "A single long-running test suite could consume
30,000 tokens of context in one tool call." — e sem tratamento, o LLM degrada.

**O que o mercado faz:**
LangChain (2026): tool call offloading — mantém head + tail do output acima de threshold,
offloada o restante for filesystem. O LLM can acessar o file complete se necessário.

**O que implementar:**

```
skills/reference/context-engineering.md
  ├── Tool output threshold: 2000 tokens (~8KB texto) por default
  ├── Se output > threshold:
  │     → Salva output completo em .hes/context/tool-outputs/{action_id}.txt
  │     → Injeta no contexto: head (500 tokens) + "... [OFFLOADED: {path}] ..." + tail (500 tokens)
  │     → LLM pode ler .hes/context/tool-outputs/{action_id}.txt se precisar do meio
  ├── Candidatos óbvios para offloading:
  │     → pytest output (pode ser enorme em caso de falhas)
  │     → bandit scan output (muitos findings)
  │     → git diff (PRs grandes)
  │     → grep em codebase grande
  └── RULE-27 (adicionar ao SKILL.md):
        For tool outputs > 2000 tokens, LLM offloads to .hes/context/
        and injects head+path+tail summary into working context

scripts/hooks/context-offload.sh  → offloading helper
```

---

## ◈ TIER 3 — DIFERENCIAÇÃO

---

### P3-A | Multi-Model Support

**Por que falta:**
HES assume Claude how executor. Referências a `CLAUDE.md`, formatação Claude-específica,
e ausência de adaptações for outros modelos limitam adoção e resilência.

**O que o mercado faz:**
> "Multi-provider harness design: works with Claude, GPT, and Gemini" — NxCode (2026)
> "HES should work regardless of which model executes it" — principio de harness puro

**O que implementar:**

```
.hes/models/
  ├── claude.md       → quirks Claude (thinking, tool use format, context limits)
  ├── gpt-4o.md       → quirks GPT-4o (function calling, system prompt behavior)
  ├── gemini.md       → quirks Gemini 2.0 (tool routing, context window)
  └── default.md      → comportamento padrão (model-agnostic)

Adicionar ao current.json:
  "model": "claude-sonnet-4-6" | "gpt-4o" | "gemini-2.0-flash" | null

Adicionar ao PASSO 0-C (SKILL.md):
  → Detect executing model
  → Load .hes/models/{model}.md for model-specific adaptations
  → Apply context limit, tool format, and output quirks

Adicionar ao skills/00-bootstrap.md (STEP 1.5):
  → Ask: "Which model/agent will execute this harness?"
  → Generate model-specific agent identity file
```

---

### P3-B | MCP Integration

**Por que falta:**
HES invoca ferramentas via shell (`bandit`, `pytest`, `git`).
MCP (Model Context Protocol, padrão universal de 2025-2026) permite que o LLM
invoque ferramentas externas de forma padronizada, tipada e auditável.

**O que o mercado faz:**
- Claude Code, Cursor, e all os IDEs 2026 suportam MCP natively
- LangChain deepagents usa MCP for tool dispatch padronizado
- HES poderia expor its skills how MCP tools

**O que implementar:**

```
skills/reference/mcp-integration.md
  ├── Conceito: cada ferramenta do HES como MCP server
  ├── Candidatos imediatos:
  │     → hes-security-scan (bandit + semgrep via MCP)
  │     → hes-log-action    (events.log via MCP)
  │     → hes-state-reader  (current.json via MCP)
  └── Configuração no .claude/CLAUDE.md:
        mcpServers:
          hes-tools:
            command: python3
            args: [".hes/mcp/server.py"]

.hes/mcp/
  ├── server.py          → MCP server Python (FastMCP ou mcp-python)
  └── tools/
        ├── security.py  → bandit + semgrep tool
        ├── state.py     → read/write current.json
        └── events.py    → append to events.log
```

---

### P3-C | Skill Versioning + Compatibility Matrix

**Por que falta:**
Skill-files are atualizados sem version explícita por file.
when `07-review.md` is atualizado na v3.4 but um project usa `SKILL.md` v3.3,
not há forma automática de detectar incompatibilidade.

**O que implementar:**

```
Header obrigatório em cada skill-file:
  ---
  skill: 07-review
  version: 3.4.0
  requires_skill_version: ">=3.4.0"
  breaking_changes: ["DIMENSION 3 agora usa scan automatizado"]
  ---

.hes/state/skill-versions.json  → versões instaladas por skill
scripts/ci/check-compatibility.py → valida que todas as skills são compatíveis entre si

Regra: se skill.version > SKILL.md.version → warn + link para migration guide
Migration guides: docs/migrations/v3.3-to-v3.4.md
```

---

### P3-D | Harness Self-Testing

**Por que falta:**
HES tem `/hes harness` (diagnóstico), but not tem **tests automatizados
dos próprios skill-files**. Se `SKILL.md` tem um bug no routing (ex: typo na phase),
ninguém sabe até o LLM falhar em produção.

**O que implementar:**

```
skills/12-harness-tests.md — skill de self-testing

Testes mínimos por tipo:
  Structural tests (determinísticos, fast):
    → registry.json válido e todos skill-files existem
    → state machine em SKILL.md consistente com registry
    → gate table completa (sem transições ausentes)
    → comandos referenciados no README existem no SKILL.md
    → versões consistentes entre SKILL.md, registry, CHANGELOG

  Behavioral tests (LLM-as-judge, slow):
    → dado "feature = GREEN", SKILL.md roteia para impl-agent?
    → dado "feature = SECURITY", routing carrega 10-security.md?
    → dado erro category B, error-recovery.md propõe lesson?

Comando: /hes test [--structural] [--behavioral] [--all]
Output: .hes/state/harness-test-results.json
```

---

### P3-E | Synthetic Golden Dataset

**Por que falta:**
HES aprende with erros reais (lessons.md), but not tem casos de test
curados que representem comportamento correto esperado.
Sem golden dataset, not is possível medir regressão quantitativamente.

**O que o mercado faz:**
- Anthropic (2026): each task eval começa de ambiente limpo e isolado
- DeepEval: "golden datasets" with expected outputs for each dimensão
- Braintrust: rastreia score ao longo do tempo about o mesmo dataset

**O que implementar:**

```
.hes/evals/
  ├── golden/
  │     ├── discovery/
  │     │     ├── task-001.json   (input prompt + expected output schema)
  │     │     └── task-002.json
  │     ├── spec/
  │     ├── design/
  │     ├── security/
  │     └── review/
  └── baselines/
        └── scores-{date}.json  (scores de referência para comparação)

Formato de golden task:
{
  "task_id": "disc-001",
  "description": "Feature: user auth com JWT",
  "input": "Quero autenticação JWT na minha API",
  "expected": {
    "min_business_rules": 5,
    "required_topics": ["expiração", "refresh", "401"],
    "forbidden": ["implementar", "código", "função"]
  },
  "graders": ["count_brs", "topic_coverage", "no_implementation_in_discovery"]
}
```

---

## ◈ ROADMAP DE execution

```
Q2 2026 (Agora → Junho)
  [x] v3.4.0 — Security scan + Action Event Protocol (DONE)
  [ ] P1-C   — Step budget + token tracking
  [ ] P2-A   — CI/CD GitHub Actions (harness validation)
  [ ] P2-B   — Typed handoff schemas

Q3 2026 (Julho → Setembro)
  [ ] P1-A   — Eval harness (fase 1: graders determinísticos)
  [ ] P1-B   — Telemetria estruturada (spans + latência)
  [ ] P2-C   — Context engineering no nível de ferramenta
  [ ] P3-C   — Skill versioning + compatibility matrix

Q4 2026 (Outubro → Dezembro)
  [ ] P1-A   — Eval harness fase 2 (LLM-as-judge + pass@k)
  [ ] P3-D   — Harness self-testing
  [ ] P3-E   — Synthetic golden dataset (10 tasks/fase)
  [ ] P3-A   — Multi-model support (GPT-4o + Gemini)

2027
  [ ] P3-B   — MCP integration
  [ ] Eval CI gate (bloqueia PR que degrada score)
  [ ] Online evals (monitoramento de produção)
```

---

## ◈ REFERÊNCIAS

| Fonte | O que influenciou |
|---|---|
| Fowler (2026) — Harness Engineering for Coding Agent Users | Taxonomia Guide/Sensor, harnessability |
| LangChain (2026) — The Anatomy of an Agent Harness | Componentes do harness, skill skills |
| LangChain (2026) — Agent Evaluation Readiness Checklist | Eval harness, LLM-as-judge, regression gates |
| OpenAI (2026) — Harness Engineering with Codex | Observabilidade local, step budget, CI/CD gates |
| Anthropic (2026) — Demystifying Evals for AI Agents | pass@k, isolamento de ambiente, graders |
| Anthropic (2026) — Effective Harnesses for Long-Running Agents | Cross-session handoffs, context bridging |
| GitHub (2026) — Multi-Agent Workflows Often Fail | Typed schemas, boundary validation |
| HumanLayer (2026) — Skill Issue: Harness Engineering | Context engineering, sub-agent isolation, MCP |
| arxiv:2603.05344 (2026) — Building AI Coding Agents for the Terminal | ReAct loop, tool output offloading, context management |
| LangSmith (2026) — State of Agent Engineering | 89% observability, 52% evals, production stats |
