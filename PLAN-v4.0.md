# HES — Improvement Plan v4.0
# Da Orquestração Sequencial à Fábrica de Software Autônoma
# Autor: análise técnica — Megatendências 2026 (OpenAI, Google, LangChain, AWS Kiro)
# Data: 2026-04-20
# Base: HES v3.5.0 (feat/hes-v3.5-full-plan-implementation)

---

## ◈ VALIDAÇÃO DO ESTADO ATUAL (v3.5.0)

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

| Lição da Indústria | Fonte | Implicação para o HES |
|---|---|---|
| O gargalo é a atenção humana, não os tokens | OpenAI Codex (1M linhas, zero revisão humana) | HES precisa de agentes de revisão e merge autônomos |
| O Harness faz o modelo saltar no ranking sem alterar pesos | LangChain deepagents: 52.8% → 66.5% Terminal Bench 2.0 | O harness é multiplicador de performance tão importante quanto o modelo |
| Multi-agentes brilham em paralelo, degradam em sequencial | Google Research (180 configurações testadas) | A escolha single vs. multi-agent deve ser dinâmica e baseada no tipo de tarefa |
| Código deve ser otimizado para legibilidade do agente | arXiv:2604.07502 | HES pode se tornar guia para essa transição no código do usuário |

O HES v3.5.0 já internaliza esses princípios no fluxo sequencial. O plano v4.0 estende esse paradigma para orquestração multi-agente e autonomia evolutiva.

---

## ◈ MELHORIA 1 — ORQUESTRAÇÃO MULTI-AGENTE

### Status: ❌ Não implementado

### Problema
O HES guia um único agente LLM através de um fluxo sequencial de 10 fases. Tarefas como análise de segurança, revisão de código e geração de testes poderiam ser executadas em paralelo, reduzindo o tempo total de desenvolvimento.

### Solução

**1.1 — Fase 0.5: Análise e Decomposição de Tarefa**

Antes das fases principais, um agente `planner.md` analisa o escopo da feature:
- Identifica subtarefas paralelizáveis (ex: DESIGN e DATA podem evoluir juntos)
- Gera um `execution-plan.json` com grafo de dependências
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

**1.2 — Novo Agente: `orchestrator.md` (O Maestro)**

Responsável por despachar tarefas para um "Agent Fleet" especializado:
- `planner.md` → define o plano de execução
- `orchestrator.md` → despacha e monitora agentes em paralelo
- `designer.md` → cria ADRs e decisões arquiteturais
- `data-modeler.md` → gera migrações SQL e schema de dados
- `spec-writer.md` → finaliza cenários BDD

**1.3 — Execução em Git Worktrees Isoladas**

Inspirado no Codex (OpenAI), agentes especializados operam em worktrees Git isoladas:
```bash
git worktree add .worktrees/designer feat/design-agent
git worktree add .worktrees/data-modeler feat/data-agent
# orchestrator.md gerencia integração e resolve conflitos
```

### Arquivos Novos
```
skills/planner.md           — agente de decomposição de tarefas
skills/orchestrator.md      — maestro da frota de agentes
skills/agents/designer.md   — agente especialista em ADRs
skills/agents/data-modeler.md — agente especialista em migrações
skills/agents/spec-writer.md  — agente especialista em BDD
```

### Comando Novo
```
/hes start --parallel <feature>   — inicia orquestração multi-agente
/hes fleet status                  — estado da frota de agentes
```

---

## ◈ MELHORIA 2 — APRENDIZADO CONTÍNUO E AUTO-EVOLUÇÃO DO HARNESS

### Status: ❌ Não implementado (ciclo de lições existe, mas é reativo)

### Problema
O processo de "promoção" de lições a melhorias requer gatilhos manuais (`/hes report`). Para se tornar uma fábrica autônoma, o HES deve evoluir seu próprio Harness de forma proativa.

### Solução

**2.1 — Agente de Melhoria Contínua: `harness-evolver.md`**

Roda em background analisando `events.log` e identificando padrões de falha:
- Analisa frequência de erros por fase e tipo de ação
- Identifica skill-files com taxa de rejeição elevada
- Propõe edições nos próprios arquivos `.md` de habilidade

**2.2 — Modelo de Confiança para Auto-Modificação**

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

Gera relatório visual de evolução do Harness:
```
Métricas:
- Lições promovidas a melhorias: N
- Redução no MTTC (Mean Time To Completion): -X%
- Taxa de sucesso por fase
- Skill-files mais modificados
- Padrões de falha recorrentes
```

### Arquivos Novos
```
skills/harness-evolver.md       — agente de auto-evolução
.hes/state/trust-policy.yml     — política de confiança para auto-modificação
docs/harness-evolution-log.md   — histórico de auto-modificações aprovadas
```

### Comando Novo
```
/hes insights   — dashboard de aprendizado e métricas de evolução
```

---

## ◈ MELHORIA 3 — SEGURANÇA, GOVERNANÇA E CONFIABILIDADE ENTERPRISE

### Status: ⚠️ Parcialmente implementado (fase SECURITY existe, mas sem sandbox e auditoria criptográfica)

### Solução

**3.1 — Execução em Sandbox por Padrão**

Integração com ambiente sandbox isolado para todas as ações de agente:
- Previne danos acidentais ao sistema de arquivos do host
- Mitiga riscos de injeção de prompt
- Rollback automático em caso de falha de gate

**3.2 — Trilha de Auditoria Imutável**

Extensão do atual `telemetry.jsonl` com verificação criptográfica:
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

**3.3 — Políticas de Segurança como Código**

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

### Arquivos Novos
```
security-policy.yml             — políticas de segurança como código
docs/audit-trail-spec.md        — spec da trilha de auditoria criptográfica
```

---

## ◈ MELHORIA 4 — NOVAS FEATURES

### 4.1 — `/hes review` — Revisão de Código Autônoma

**Descrição:** Agente dedicado para revisão de PRs, análogo a um desenvolvedor sênior.

**Como funciona:**
- `reviewer.md` analisa o `git diff` da PR
- Executa verificações de estilo, segurança e boas práticas
- Gera relatório estruturado postável no GitHub/GitLab

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

**Arquivos Novos:**
```
skills/reviewer.md   — agente de revisão autônoma de PR
```

**Comando Novo:**
```
/hes review <PR_URL|branch>   — inicia revisão autônoma
```

### 4.2 — `/hes optimize` — Otimização para Legibilidade de Agente

**Descrição:** Refatora código aplicando princípios de "agent-readable code" (arXiv:2604.07502).

**Transformações aplicadas:**
```
- Variáveis enigmáticas → termos semânticos em inglês (reduz tokens)
- Logs de texto livre → JSON estruturado
- Comentários → formato estruturado que serve de "hint" para agentes
- Magic numbers → constantes nomeadas
- Funções God → funções focadas com nomes descritivos
```

**Arquivos Novos:**
```
skills/optimizer.md   — agente de otimização para agentes
```

**Comando Novo:**
```
/hes optimize [--dry-run] [path]   — otimiza código para legibilidade de agente
```

### 4.3 — `/hes init` — Onboarding Aprimorado de Projetos Legados

**Descrição:** Melhoria do `legacy.md` existente para geração automática de documentação inicial.

**O que o agente faz além do atual:**
- Varre a estrutura de pastas e infere arquitetura
- Gera ADRs retrospectivos baseados no código existente
- Cria `discovery-output.json` e `design-output.json` iniciais
- Avalia harnessability e sugere ordem de migração por módulo

---

## ◈ MELHORIA 5 — INTEGRAÇÃO COM ECOSSISTEMA

### 5.1 — MCP como Protocolo Padrão de Integração

Adoção do Model Context Protocol como protocolo nativo do HES:
- Conexão padronizada a DBs, APIs, CI/CD, knowledge bases
- Sem código de integração customizado por serviço
- Compatível com o ecossistema MCP de Claude, Cursor, etc.

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

### 5.2 — Integração com LangSmith para Observabilidade de Grafo

Cada fase e ação registrada como "span" no LangSmith:
- Visualização do workflow como grafo de decisão
- Identificação de gargalos por fase
- Debug de comportamentos inesperados do agente
- Integração via API com o `telemetry.jsonl` existente

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

| Métrica | v3.5.0 (atual) | v4.0 (projetado) |
|---|---|---|
| Modo de execução | Single-agent sequencial | Multi-agent paralelo + single-agent sequencial |
| Agentes disponíveis | 23 (9 fase + 14 sistema) | 30+ (+ planner, orchestrator, fleet, evolver) |
| Autonomia de revisão | Manual (humano) | Autônoma via `/hes review` |
| Evolução do harness | Reativa (`/hes report`) | Proativa (harness-evolver em background) |
| Integrações externas | Git + GitHub Actions | Git + GitHub Actions + MCP + LangSmith |
| Conformidade enterprise | Gate binário (HIGH block) | Políticas como código (security-policy.yml) |

---

## ◈ CONCLUSÃO

O HES v3.5.0 é um produto maduro que já internalizou os princípios de Harness Engineering. Este plano v4.0 não substitui o que existe — ele **estende** a arquitetura sequencial comprovada com:

1. **Paralelismo inteligente** — o planner decide quando usar multi-agent
2. **Auto-evolução controlada** — o harness melhora a si mesmo com supervisão humana
3. **Governança enterprise** — políticas, auditoria e sandbox por padrão
4. **Ecossistema aberto** — MCP + LangSmith como primeiros cidadãos

> O futuro do desenvolvimento não é sobre modelos maiores, mas sobre Harnesses mais inteligentes.
> O HES está posicionado para liderar essa transição.
