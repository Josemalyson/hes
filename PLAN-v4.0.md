# HES — Improvement Plan v4.0
# Da Orquestração Sequencial à Fábrica de Software Autônoma
# Autor: analysis técnica — Megatendências 2026 (OpenAI, Google, LangChain, AWS Kiro)
# Data: 2026-04-20
# Base: HES v3.5.0 (feat/hes-v3.5-full-plan-implementation)

---

## ◈ validation DO state current (v3.5.0)

### Inventário confirmado contra o repositório real

```
ARQUITETURA CORE
✅ State machine: ZERO → DISCOVERY → SPEC → DESIGN → DATA → RED → GREEN → SECURITY → REVIEW → DONE
✅ 13 skill-files especializados (00-bootstrap → 12-harness-tests)
✅ Agent registry com 9 agents de fase + 14 system_agents
✅ harness_version: 3.5.0 em registry.json e SKILL.md

OBSERVABILIDADE (implementado em v3.5.0)
✅ Telemetria OpenTelemetry-compatible (scripts/hooks/telemetry.sh)
✅ Step budget por fase (scripts/hooks/step-budget.sh)
✅ Token tracking + cost_usd por sessão
✅ Typed handoff schemas: 6 JSON schemas (.hes/schemas/)
✅ Context offloading > 8000 chars (scripts/hooks/context-offload.sh)

QUALIDADE E SEGURANÇA (implementado em v3.4.0 e v3.5.0)
✅ Fase SECURITY com Bandit + Semgrep (skills/10-security.md)
✅ Eval harness com pass@k + LLM-as-judge (skills/11-eval.md)
✅ Golden dataset para regression testing (.hes/evals/tasks/)
✅ Harness self-testing — 10 structural + 5 behavioral (skills/12-harness-tests.md)
✅ CI/CD via GitHub Actions (.github/workflows/harness-validation.yml)
✅ Skill versioning com compatibility matrix

SUPORTE E EXTENSIBILIDADE
✅ Multi-model support: claude.md, gpt-4o.md, default.md
✅ Legacy project support com harnessability assessment
✅ DDD domain support com bounded contexts
✅ Progressive analysis para codebases > 50 arquivos
✅ Error recovery com categorias A-E

GAPS CONFIRMADOS — O QUE AINDA NÃO EXISTE (v3.5.0 → v4.0)
❌ Orquestração multi-agente (planner + orchestrator fleet)
❌ Execução paralela em Git worktrees
❌ Agente de auto-evolução do harness (harness-evolver.md)
❌ Sistema de confiança para auto-modificação de skill-files
❌ Comando /hes review (revisão autônoma de PR)
❌ Comando /hes optimize (otimização para legibilidade de agente)
❌ Comando /hes insights (dashboard de aprendizado e métricas)
❌ Políticas de segurança como código (security-policy.yml)
❌ Sandbox por padrão para ações de agente
❌ Verificação criptográfica de transições de fase
❌ Integração MCP como protocolo padrão de ferramentas
❌ Integração nativa com LangSmith (observabilidade de grafo)
❌ /hes init para onboarding de projetos legados (melhoria do legacy.md)
```

---

## ◈ CONTEXTO: AS MEGATENDÊNCIAS DE 2026

O consenso da indústria em 2026 solidificou-se em torno da equação:

```
Agent = Model + Harness
```

| lesson da Indústria | Fonte | Implicação for o HES |
|---|---|---|
| O gargalo is a atenção humana, not os tokens | OpenAI Codex (1M linhas, zero revisão humana) | HES precisa de agents de revisão e merge autônomos |
| O Harness faz o modelo saltar no ranking sem alterar pesos | LangChain deepagents: 52.8% → 66.5% Terminal Bench 2.0 | O harness is multiplicador de performance tão importante quanto o modelo |
| Multi-agents brilham em paralelo, degradam em sequencial | Google Research (180 configurations testadas) | A escolha single vs. multi-agent must ser dinâmica e baseada no tipo de task |
| code must ser otimizado for legibilidade do Agent | arXiv:2604.07502 | HES can se tornar guia for this transição no code do usuário |

O HES v3.5.0 já internaliza esses princípios no flow sequencial. O plano v4.0 estende this paradigma for orquestração multi-Agent e autonomia evolutiva.

---

## ◈ improvement 1 — ORQUESTRAÇÃO MULTI-Agent

### Status: ❌ not implementado

### Problema
O HES guia um único Agent LLM através de um flow sequencial de 10 phases. tasks how analysis de security, revisão de code e generation de tests poderiam ser executadas em paralelo, reduzindo o tempo total de desenvolvimento.

### Solução

**1.1 — phase 0.5: analysis e Decomposição de task**

before das phases principais, um Agent `planner.md` analisa o Scope da feature:
- Identifica subtarefas paralelizáveis (ex: DESIGN e DATA can evoluir juntos)
- Gera um `execution-plan.json` with grafo de dependências
- Decide dinamicamente: `single-agent mode` vs `multi-agent mode`

```json
// .hes/state/execution-plan.json
{
  "feature": "payment-gateway",
  "mode": "multi-agent",
  "parallel_groups": [
    { "group": 1, "tasks": ["DESIGN", "DATA"], "agents": ["designer", "data-modeler"] },
    { "group": 2, "tasks": ["SPEC"], "agents": ["spec-writer"], "depends_on": [1] }
  ]
}
```

**1.2 — new Agent: `orchestrator.md` (O Maestro)**

Responsável por despachar tasks for um "Agent Fleet" especializado:
- `planner.md` → define o plano de execution
- `orchestrator.md` → despacha e monitora agents em paralelo
- `designer.md` → cria ADRs e decisões arquiteturais
- `data-modeler.md` → gera migrações SQL e schema de data
- `spec-writer.md` → finaliza cenários BDD

**1.3 — execution em Git Worktrees Isoladas**

Inspirado no Codex (OpenAI), agents especializados operam em worktrees Git isoladas:
```bash
git worktree add .worktrees/designer feat/design-agent
git worktree add .worktrees/data-modeler feat/data-agent
# orchestrator.md gerencia integração e resolve conflitos
```

### Files new
```
skills/planner.md           — agente de decomposição de tarefas
skills/orchestrator.md      — maestro da frota de agentes
skills/agents/designer.md   — agente especialista em ADRs
skills/agents/data-modeler.md — agente especialista em migrações
skills/agents/spec-writer.md  — agente especialista em BDD
```

### Comando new
```
/hes start --parallel <feature>   — inicia orquestração multi-agente
/hes fleet status                  — estado da frota de agentes
```

---

## ◈ improvement 2 — APRENDIZADO CONTÍNUO E AUTO-EVOLUÇÃO DO HARNESS

### Status: ❌ not implementado (cycle de lessons existe, but is reativo)

### Problema
O processo de "promoção" de lessons a improvements requer triggers manuais (`/hes report`). for se tornar a fábrica autônoma, o HES must evoluir its próprio Harness de forma proativa.

### Solução

**2.1 — Agent de improvement Contínua: `harness-evolver.md`**

Runs in background analyzing `events.log` e identifying failure patterns:
- Analisa frequência de erros por phase e tipo de ação
- Identifica skill-files with taxa de rejeição elevada
- Propõe edições nos próprios Files `.md` de habilidade

**2.2 — Modelo de Confiança for Auto-Modificação**

```yaml
# .hes/state/trust-policy.yml
trust_levels:
  LOW_RISK:   # auto-apply
    - "prompt text adjustments in skill-files"
    - "adding examples to skill-files"
    - "updating documentation comments"
  HIGH_RISK:  # human approval required
    - "changing phase order in state machine"
    - "modifying gate conditions"
    - "adding or removing phases"
```

**2.3 — Comando `/hes insights`**

Gera report visual de evolução do Harness:
```
Métricas:
- Lições promovidas a melhorias: N
- Redução no MTTC (Mean Time To Completion): -X%
- Taxa de sucesso por fase
- Skill-files mais modificados
- Padrões de falha recorrentes
```

### Files new
```
skills/harness-evolver.md       — agente de auto-evolução
.hes/state/trust-policy.yml     — política de confiança para auto-modificação
docs/harness-evolution-log.md   — histórico de auto-modificações aprovadas
```

### Comando new
```
/hes insights   — dashboard de aprendizado e métricas de evolução
```

---

## ◈ improvement 3 — security, GOVERNANÇA E CONFIABILIDADE ENTERPRISE

### Status: ⚠️ Parcialmente implementado (phase SECURITY existe, but sem sandbox e auditoria criptográfica)

### Solução

**3.1 — execution em Sandbox por Padrão**

Integração with ambiente sandbox isolado for all as ações de Agent:
- Previne danos acidentais ao sistema de Files do host
- Mitiga riscos de injeção de prompt
- Rollback automático em caso de falha de gate

**3.2 — Trilha de Auditoria Imutável**

Extensão do current `telemetry.jsonl` with verificação criptográfica:
```jsonl
{
  "trace_id": "abc-123",
  "event": "PHASE_TRANSITION",
  "from": "GREEN",
  "to": "SECURITY",
  "timestamp": "2026-04-20T10:00:00Z",
  "signature": "sha256:...",  // NOVO — integridade criptográfica
  "approved_by": "human|auto"
}
```

**3.3 — Políticas de security how code**

```yaml
# security-policy.yml
version: "1.0"
gates:
  security_scan:
    block_on_severity: ["HIGH", "CRITICAL"]  # default
    warn_on_severity: ["MEDIUM"]
    allow_exceptions: true
    exception_requires_approval: true
  enterprise_mode:
    block_on_severity: ["HIGH", "CRITICAL", "MEDIUM"]  # mais restritivo
    allow_exceptions: false
```

### Files new
```
security-policy.yml             — políticas de segurança como código
docs/audit-trail-spec.md        — spec da trilha de auditoria criptográfica
```

---

## ◈ improvement 4 — new FEATURES

### 4.1 — `/hes review` — Revisão de code Autônoma

**Descrição:** Agent dedicado for revisão de PRs, análogo a um desenvolvedor sênior.

**how funciona:**
- `reviewer.md` analisa o `git diff` da PR
- Executa verificações de estilo, security e boas práticas
- Gera report estruturado postável no GitHub/GitLab

```markdown
## HES Review Report — feat/payment-gateway

### Summary
- Files changed: 12 | Lines added: +340 | Lines removed: -45
- Overall Score: 8.2/10

### Critical Issues (0)
_Nenhum_

### Warnings (2)
- `src/payment/gateway.ts:45` — Missing input validation on `amount` field
- `src/payment/retry.ts:12` — Retry logic without exponential backoff

### Suggestions (5)
...
```

**Files new:**
```
skills/reviewer.md   — agente de revisão autônoma de PR
```

**Comando new:**
```
/hes review <PR_URL|branch>   — inicia revisão autônoma
```

### 4.2 — `/hes optimize` — Otimização for Legibilidade de Agent

**Descrição:** Refatora code aplicando princípios de "agent-readable code" (arXiv:2604.07502).

**Applied transformations:**
```
- Variáveis enigmáticas → termos semânticos em inglês (reduz tokens)
- Logs de texto livre → JSON estruturado
- Comentários → formato estruturado que serve de "hint" para agentes
- Magic numbers → constantes nomeadas
- Functions God → funções focadas com nomes descritivos
```

**Files new:**
```
skills/optimizer.md   — agente de otimização para agentes
```

**Comando new:**
```
/hes optimize [--dry-run] [path]   — otimiza código para legibilidade de agente
```

### 4.3 — `/hes init` — Onboarding Aprimorado de projects Legados

**Descrição:** improvement do `legacy.md` existente for generation automática de documentation inicial.

**O que o Agent faz além do current:**
- Varre a estrutura de pastas e infere arquitetura
- Gera ADRs retrospectivos baseados no code existente
- Cria `discovery-output.json` e `design-output.json` iniciais
- Avalia harnessability e sugere ordem de migração por módulo

---

## ◈ improvement 5 — INTEGRAÇÃO with ECOSSISTEMA

### 5.1 — MCP how Protocolo Padrão de Integração

Adoção do Model Context Protocol how protocolo nativo do HES:
- Conexão padronizada a DBs, APIs, CI/CD, knowledge bases
- Sem code de integração customizado por serviço
- Compatível with o ecossistema MCP de Claude, Cursor, etc.

```json
// .hes/mcp-servers.json
{
  "servers": [
    { "name": "github", "url": "mcp://github.com/api/v4" },
    { "name": "postgres", "url": "mcp://localhost:5432" },
    { "name": "sonarqube", "url": "mcp://sonar.internal/api" }
  ]
}
```

### 5.2 — Integração with LangSmith for Observabilidade de Grafo

each phase e ação registrada how "span" no LangSmith:
- Visualização do workflow how grafo de decisão
- Identificação de gargalos por phase
- Debug de comportamentos inesperados do Agent
- Integração via API with o `telemetry.jsonl` existente

---

## ◈ ROADMAP PROPOSTO (v3.6 → v4.0)

```
v3.6 (Q2 2026) — Fundação para Multi-Agente
├── planner.md — análise e decomposição de tarefas
├── Suporte a Git worktrees para execução paralela
├── security-policy.yml — políticas de segurança como código
└── Verificação criptográfica de transições de fase

v3.7 (Q3 2026) — O Maestro e a Frota de Agentes
├── orchestrator.md — maestro da frota
├── skills/agents/designer.md
├── skills/agents/data-modeler.md
├── skills/agents/spec-writer.md
└── /hes start --parallel <feature>

v3.8 (Q4 2026) — Autonomia e Auto-Evolução
├── harness-evolver.md — agente de auto-evolução
├── trust-policy.yml — sistema de confiança para auto-modificação
└── /hes insights — dashboard de aprendizado

v3.9 (Q1 2027) — Otimização e Ecossistema
├── optimizer.md — /hes optimize
├── mcp-servers.json — MCP como protocolo nativo
└── Integração com LangSmith

v4.0 (Q2 2027) — Lançamento da Fábrica Autônoma
├── reviewer.md — /hes review
├── Sandbox por padrão para ações de agente
├── Trilha de auditoria imutável com assinatura criptográfica
└── Documentação completa e casos de uso
```

---

## ◈ IMPACTO ARQUITETURAL ESTIMADO

| Métrica | v3.5.0 (current) | v4.0 (projetado) |
|---|---|---|
| Modo de execution | Single-agent sequencial | Multi-agent paralelo + single-agent sequencial |
| agents disponíveis | 23 (9 phase + 14 sistema) | 30+ (+ planner, orchestrator, fleet, evolver) |
| Autonomia de revisão | Manual (humano) | Autônoma via `/hes review` |
| Evolução do harness | Reativa (`/hes report`) | Proativa (harness-evolver em background) |
| Integrações externas | Git + GitHub Actions | Git + GitHub Actions + MCP + LangSmith |
| Conformidade enterprise | Gate binário (HIGH block) | Políticas how code (security-policy.yml) |

---

## ◈ CONCLUSÃO

O HES v3.5.0 is um produto maduro que já internalizou os princípios de Harness Engineering. this plano v4.0 not substitui o que existe — ele **estende** a arquitetura sequencial comprovada with:

1. **Paralelismo inteligente** — o planner decide when use multi-agent
2. **Auto-evolução controlada** — o harness melhora a si mesmo with supervisão humana
3. **Governança enterprise** — políticas, auditoria e sandbox por padrão
4. **Ecossistema aberto** — MCP + LangSmith how primeiros cidadãos

> O futuro do desenvolvimento not is about modelos maiores, but about Harnesses more inteligentes.
> O HES is posicionado for liderar this transição.
