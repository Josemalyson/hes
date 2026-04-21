# HES — Changelog

## v3.5.0 (2026-04-18)

Implementação completa do PLAN.md — 15 gaps vs. padrões de mercado 2026.

### TIER 1 — Crítico

**P1-A: Eval Harness + LLM-as-judge**
- `skills/11-eval.md` — skill completa de eval com pass@k e pass^k
- `.hes/evals/tasks/` — golden dataset (discovery, spec, security, review)
- `.hes/evals/baselines/` — baseline scores para comparação de regressão
- Graders: determinísticos (rápidos) + LLM-as-judge (qualitativos)
- Comandos: `/hes eval`, `/hes eval --phase`, `/hes eval --llm-judge`

**P1-B: Telemetria Estruturada**
- `skills/reference/telemetry-protocol.md` — spec OpenTelemetry-compatible
- `scripts/hooks/telemetry.sh` — span manager (start_phase, end_phase, timeline, cost)
- `.hes/state/telemetry.jsonl` — arquivo de spans (JSONL)
- Schema: trace_id, span_id, parent_span_id, duration_ms, tokens_estimated, cost_usd

**P1-C: Step Budget + Token Tracking**
- `skills/reference/step-budget-protocol.md` — protocolo completo
- `scripts/hooks/step-budget.sh` — manager (decrement, status, reset, set-tokens)
- Schema em current.json: step_budget por fase + token_tracking
- RULE-26: LLM decrementa budget a cada chamada, escalona ao esgotar

### TIER 2 — Alto Valor

**P2-A: CI/CD GitHub Actions**
- `.github/workflows/harness-validation.yml` — validação em todo PR/push
- `scripts/ci/validate-harness.py` — validator (skills, versions, state-machine, headers)
- Checks: registry válido, skill-files existem, versões consistentes, Python compila

**P2-B: Typed Handoff Schemas**
- `skills/reference/handoff-schemas.md` — spec completo
- `.hes/schemas/discovery-output.schema.json`
- `.hes/schemas/spec-output.schema.json`
- `.hes/schemas/design-output.schema.json`
- `.hes/schemas/security-output.schema.json`
- `.hes/schemas/review-output.schema.json`
- RULE-27: LLM valida schema antes de toda transição de fase

**P2-C: Context Engineering (Tool Output Offloading)**
- `skills/reference/context-engineering.md` — spec + threshold + padrões por ferramenta
- `scripts/hooks/context-offload.sh` — save, summary, clean
- Threshold: > 8.000 chars → offload para `.hes/context/tool-outputs/`
- RULE-28: LLM offloads tool outputs grandes, usa head+tail no contexto

### TIER 3 — Diferenciação

**P3-A: Multi-Model Support**
- `.hes/models/claude.md` — quirks Claude (context window, tools, CLAUDE.md)
- `.hes/models/gpt-4o.md` — quirks GPT-4o (function_calling, AGENTS.md)
- `.hes/models/default.md` — defaults model-agnostic
- `model` field adicionado ao schema de current.json

**P3-C: Skill Versioning**
- `skills/reference/skill-versioning.md` — guide completo
- Schema de header obrigatório para skill-files
- `.hes/state/skill-versions.json` para rastreio de versões instaladas

**P3-D: Harness Self-Testing**
- `skills/12-harness-tests.md` — 10 structural tests + 5 behavioral tests
- Comandos: `/hes test`, `/hes test --structural`, `/hes test --behavioral`
- Integrado ao CI via `validate-harness.py`

### Atualizações core

**SKILL.md v3.4.0 → v3.5.0:**
- RULE-26, RULE-27, RULE-28 adicionadas
- Commands: `/hes eval`, `/hes test`
- Routing: eval-agent, harness-test-agent
- Schema current.json: step_budget, token_tracking, model
- ANNOUNCE block: step budget + telemetria

**.hes/agents/registry.json:**
- eval-agent + harness-test-agent
- harness_version: 3.5.0

### Regras adicionadas ao SKILL.md

```
RULE-26  LLM MANAGES step budget per phase via step-budget.sh
RULE-27  LLM VALIDATES handoff schema before every phase transition
RULE-28  LLM OFFLOADS tool outputs > 8000 chars to .hes/context/
```

---

## v3.4.0 (2026-04-18)

Foco em segurança automatizada e rastreabilidade de execução intra-fase.

### Adicionado

**Nova fase SECURITY (entre GREEN e REVIEW):**
- `skills/10-security.md` — skill completa de security scan
- Integra **Bandit** (Python, primário) + **Semgrep** (Shell, secundário)
- Auto-fix loop por test_id (B105, B301, B311, B324, B601, B608...)
- Gate bloqueante: zero HIGH findings obrigatório para avançar para REVIEW
- Exceções MEDIUM/LOW documentadas em `.hes/state/security-exceptions.json`
- Comando `/hes security` adicionado

**Action Event Protocol — debug tracking intra-fase:**
- `scripts/hooks/log-action.sh` — logger de ações do LLM no events.log
- `skills/reference/action-event-protocol.md` — especificação completa do protocolo
- `session-id` UUID gerado no bootstrap (`00-bootstrap.md` STEP 2)
- Schema de evento expandido: session_id, action_id, action_type, status por ação

**Infraestrutura:**
- `.hes/scripts/check-security-gate.py` — gate checker de segurança
- `docs/HES-v3.4-SPEC.md` — spec completo da implementação

### Atualizado

**State machine:**
- `ZERO → DISCOVERY → SPEC → DESIGN → DATA → RED → GREEN → SECURITY → REVIEW → DONE`
- Dois novos gates: `GREEN → SECURITY` e `SECURITY → REVIEW`

**SKILL.md (v3.3.0 → v3.4.0):**
- Routing table: `feature = SECURITY → security-agent → skills/10-security.md`
- Phase lock gates: `GREEN → SECURITY` e `SECURITY → REVIEW`
- RULE-24: obrigatoriedade de logging de ações via log-action.sh
- RULE-25: obrigatoriedade de fase SECURITY antes de REVIEW
- Schema `current.json`: campo `security` com last_scan, last_gate_result
- Versão bumped: 3.3.0 → 3.4.0

**skills/00-bootstrap.md:**
- STEP 2: criação de `.hes/state/session-id` (UUID único por sessão)
- STEP 2: criação de `.hes/scripts/` directory
- STEP 3: schema current.json com campo `security`

**skills/06-implementation.md:**
- NEXT ACTION aponta para SECURITY (não mais diretamente para REVIEW)
- Gate explícito: GREEN → SECURITY → REVIEW

**skills/07-review.md:**
- DIMENSION 3 (Security manual) substituída por verificação do scan automatizado
- Referencia `.hes/state/security-report-final.json` e `security-exceptions.json`
- Checklist de revisão complementar (aspectos não cobertos por Bandit/Semgrep)

**.hes/agents/registry.json:**
- `security-agent` adicionado ao array principal (entre GREEN e REVIEW)
- `security-agent` adicionado ao system_agents (trigger: `/hes security`)
- `harness_version` bumped: 3.3.0 → 3.4.0

### Regras adicionadas ao SKILL.md

```
RULE-24  LLM LOGS every significant action via scripts/hooks/log-action.sh
RULE-25  LLM EXECUTES security scan before REVIEW — no exceptions
```

---

## v3.3.0 (2026)

Refatoração focada em consistência e modernização técnica:

### Adicionado

**Conceitual:**
- Sistema de auto-install automatizado via `skills/auto-install.md` (agentic tools)
- Detecção automática de linguagem + Audience Mode (beginner/expert)
- Campos `agent_model`, `user_language`, `audience_mode` em current.json
- Campo `session.phase_lock` para enforcement de fase
- Comando `/hes auto-install` e `/hes language`
- Multi-agent delegation via `skills/agent-delegation.md`

**Padrões 2026 (LangChain/Harrison Chase):**
- PreCompletionChecklistMiddleware pattern (self-verification before exit)
- LoopDetectionMiddleware (prevenção de doom loops)
- Time budgeting warnings in skill-files
- Reasoning sandwich pattern (high→medium→high reasoning budgets)
- Context compaction protocol for long sessions
- Modular Skills loading (dynamic, not monolithic prompts)
- Trace Analyzer pattern for batch learning

**Melhorias:**
- Clarificação do mandato: LLM harness assume responsabilidade total de execução
- Sistema de phase lock mais rigoroso
- Agent registry com versionamento explícito
- Habilidate de multi-agent orchestration via registry

### Atualizado

**Version consistency:**
- SKILL.md: v3.3.0 ✅
- ARCHITECTURE.md: v3.1 → v3.3.0
- 00-bootstrap.md: v3.2 → v3.3.0
- agent-registry.md: v3.2+ → v3.3+
- agent-identity template: v3.2 → v3.3
- CHANGELOG.md: adicionado entry v3.3.0

**Files updated:**
- `SKILL.md` — execution mandate, language detection, audience mode, auto-install
- `ARCHITECTURE.md` — version + modernization of references
- `skills/00-bootstrap.md` — auto-install integration, v3.3 schema
- `skills/agent-registry.md` — v3.3+, validation command update
- `skills/reference/templates/agent-identity.md` — v3.3 references

**Removed inconsistencies:**
- ghost files que não existiam no skills/
- SETUP.md redundante (INSTALL.md cobre o mesmo)
- Referências a arquivos não existentes em bootstrap

## v3.1.0 (2025)

Refatoração baseada em leitura de literatura técnica:
- Fowler, Birgitta Böckeler (2026) — "Harness Engineering for Coding Agent Users" (martinfowler.com)
- LangChain / Harrison Chase (2026) — "Continual Learning for AI Agents"
- LangChain / Harrison Chase (2026) — "Your Harness, Your Memory"
- LangChain / Harrison Chase (2026) — "How Coding Agents Are Reshaping Engineering, Product and Design"

### Adicionado

**Conceitual:**
- Taxonomia Guide/Sensor (feedforward/feedback) como modelo organizador do harness
- Dimensões de regulação: Maintainability | Architecture Fitness | Behaviour Harness
- Camadas de aprendizado: Harness Layer / Context Layer / Memory Hot Path / Offline
- Harnessability como conceito explícito para avaliação de projetos legados
- Context Compaction Protocol — o que preservar quando o contexto enche
- Learning Loop formal — hot path (durante sessão) + offline (batch via /hes report)

**Novos arquivos:**
- `skills/harness-health.md` — diagnóstico das 3 dimensões de regulação (Fowler)

**Arquivos atualizados:**
- `SKILL.md` — modelo conceitual, protocol de roteamento, context compaction, REGRA-13 e REGRA-14
- `ARCHITECTURE.md` — completamente reescrito com taxonomia Fowler como estrutura organizadora
- `SETUP.md` — atualizado para v3.1, novos comandos, tabela de novidades
- `skills/00-bootstrap.md` — `fitness/` folder, ArchUnit setup, updated current.json schema
- `skills/01-discovery.md` — papel explícito como guide inferencial do behaviour harness
- `skills/02-spec.md` — spec como "structured versioned prompt" (LangChain), rastreabilidade reforçada
- `skills/03-design.md` — harnessability por componente, ADR com impacto em harnessability, fitness/ update
- `skills/04-data.md` — alinhamento com v3.1
- `skills/05-tests.md` — "keep quality left" (Fowler), ArchUnit template, sensor loop por componente
- `skills/06-implementation.md` — sensor loop durante implementação, checklist com ArchUnit
- `skills/07-review.md` — Dimensão 5: Architecture Fitness Harness (ArchUnit/dep-cruiser)
- `skills/legacy.md` — Passo 3: Harnessability Assessment (tipagem, modularidade, testabilidade)
- `skills/error-recovery.md` — categorias A-E, Categoria D (gap de sensor), link ao harness improvement
- `skills/refactor.md` — Tipo I: Melhorar Harnessability; /hes harness no final
- `skills/report.md` — learning loop formal, categorias de lições, propostas de novos sensors

**Schema current.json:**
- Adicionado: `harness_version`, `completed_cycles`

**Git hooks:**
- Adicionados tipos `harness` e `fitness` ao commit checker (LLM-executed)

---

## v3.0.0 (2025)

Refatoração de monolito (v2: 1 arquivo, ~1200 linhas) para sistema multi-file.

### Adicionado
- Arquitetura multi-file: SKILL.md (orquestrador) + 12 skill-files especializados
- Event sourcing: `events.log` como fonte primária de rastreabilidade
- Estado explícito: `current.json` (substitui detecção frágil por existência de arquivos)
- Multi-feature com `dependency_graph`
- Suporte a domínios DDD com `.hes/domains/`
- Self-refinement loop com limite máximo de tentativas
- Skills: `harness-health.md`, `refactor.md`, `report.md`, `legacy.md`, `error-recovery.md`
- Comandos: `/hes start`, `/hes switch`, `/hes status`, `/hes rollback`, `/hes report`, `/hes refactor`

### Removido (vs v2)
- CLI executável (fora do escopo de skill)
- `runtime/executor.sh` e `feedback_parser.py` (infraestrutura separada)

---

## v2.0.0 (2025)

HES como arquivo monolítico (~1200 linhas).

### Adicionado
- Pipeline SDD+TDD de 7 etapas
- Git hooks: LLM-executed safety checks (v3.4+)
- Template de discovery, spec, design, data, tests, review
- lessons.md e context.md
- Protocolo de retomada de sessão
- Bloco PRÓXIMA AÇÃO obrigatório
- Detecção de estado por existência de arquivos
- REGRAS ABSOLUTAS (01–10)


---

## v4.0.0-alpha (2026-04-20)

Plano arquitetural para transformação do HES de orquestrador sequencial em fábrica de software autônoma. Esta versão contém os **stubs e especificações** para os agentes e features do roadmap v3.6 → v4.0.

### Adicionado

**PLAN-v4.0.md — Plano Arquitetural Completo**
- Validação do estado atual do v3.5.0 contra o repositório real
- 5 melhorias maiores com impacto arquitetural documentado
- Roadmap v3.6 (Q2 2026) → v4.0 (Q2 2027)
- Tabela de impacto: single-agent → multi-agent, 23 → 30+ agentes

**Novos Skill-File Stubs (planejados para v3.6 → v4.0)**
- `skills/planner.md` — Agente de decomposição de tarefas (target: v3.6)
- `skills/orchestrator.md` — Maestro da frota de agentes (target: v3.7)
- `skills/harness-evolver.md` — Auto-evolução do harness (target: v3.8)
- `skills/optimizer.md` — Otimização para legibilidade de agente (target: v3.9)
- `skills/reviewer.md` — Revisão autônoma de PR (target: v4.0)

**Novos Arquivos de Configuração (planejados para v3.6)**
- `security-policy.yml` — Políticas de segurança como código (3 modos: default, enterprise, relaxed)
- `.hes/state/trust-policy.yml` — Política de confiança para auto-modificação do harness

**Registry Atualizado**
- 5 novos agentes stub adicionados ao system_agents
- Campo `status: stub` e `target_version` para cada novo agente
- `plan_version: 4.0.0-alpha` adicionado ao registry

### Comandos Planejados (não implementados — stubs apenas)

```
/hes start --parallel <feature>   — orquestração multi-agente (v3.7)
/hes fleet status                  — estado da frota de agentes (v3.7)
/hes insights [--evolve]           — dashboard de aprendizado (v3.8)
/hes optimize [--dry-run] [path]   — otimização para agentes (v3.9)
/hes review <PR_URL|branch>        — revisão autônoma de PR (v4.0)
```

### Impacto Arquitetural

```
Estado atual (v3.5.0):   Single-agent sequencial | 23 agentes
Estado alvo (v4.0):      Multi-agent paralelo + sequencial | 30+ agentes
```

### Próximos Passos (v3.6 — Q2 2026)

1. Implementação completa de `skills/planner.md` com geração de `execution-plan.json`
2. Suporte a Git worktrees no SKILL.md (RULE-29 proposta)
3. Ativação de `security-policy.yml` na fase SECURITY (skills/10-security.md)
4. Verificação criptográfica de transições de fase no telemetry.jsonl
