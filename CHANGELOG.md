# HES — Changelog

## v3.5.1 (2026-04-24)

### fix: interaction_tool consistency — UI mode no longer changes mid-session

**Root cause:** The harness had no mechanism to detect, persist, or enforce a
consistent interaction mode across phases. IDEs like OpenCode expose a native
`question` tool (structured UI with buttons), but the NEXT ACTION FORMAT in
SKILL.md hardcoded the text-based `[A]/[B]/[C]` pattern — causing the agent
to use the interactive tool at bootstrap and revert to plain text at every
phase-end choice.

**Changes:**

- `SKILL.md` — added `interaction_tool` field to `current.json` schema;
  added **Step 0-C** (interaction tool detection, runs once at session start);
  added **R34** (never fall back to text when a tool is available);
  updated **NEXT ACTION FORMAT** to dual-mode (tool-primary / text-fallback)
  with explicit warning: *never mix modes within a session*.

- `skills/00-bootstrap.md` — Step 1 detects IDE and maps to `interaction_tool`
  (`opencode → "question"`, all others → `null`); persists in `current.json`;
  Step 1 "Ask the user" block replaced with dual-mode protocol.

- `skills/01-discovery.md`, `02-spec.md`, `03-design.md`, `04-data.md`,
  `06-implementation.md`, `10-security.md`, `07-review.md` — all phase-end
  closure blocks updated: if `interaction_tool = "question"`, call the tool;
  else render text fallback. Mode is read from `current.json`, not inferred.

---

## v3.5.0 (2026-04-18)

Complete implementation of PLAN.md — 15 gaps vs. 2026 market standards.

### TIER 1 — Critical

**P1-A: Eval Harness + LLM-as-judge**
- `skills/11-eval.md` — skill complete de eval with pass@k e pass^k
- `.hes/evals/tasks/` — golden dataset (discovery, spec, security, review)
- `.hes/evals/baselines/` — baseline scores for regression comparison
- Graders: deterministic (fast) + LLM-as-judge (qualitative)
- Comandos: `/hes eval`, `/hes eval --phase`, `/hes eval --llm-judge`

**P1-B: Telemetria Estruturada**
- `skills/reference/telemetry-protocol.md` — spec OpenTelemetry-compatible
- `scripts/hooks/telemetry.sh` — span manager (start_phase, end_phase, timeline, cost)
- `.hes/state/telemetry.jsonl` — file de spans (JSONL)
- Schema: trace_id, span_id, parent_span_id, duration_ms, tokens_estimated, cost_usd

**P1-C: Step Budget + Token Tracking**
- `skills/reference/step-budget-protocol.md` — protocolo complete
- `scripts/hooks/step-budget.sh` — manager (decrement, status, reset, set-tokens)
- Schema em current.json: step_budget por phase + token_tracking
- RULE-26: LLM decrementa budget a each chamada, escalona ao esgotar

### TIER 2 — Alto value

**P2-A: CI/CD GitHub Actions**
- `.github/workflows/harness-validation.yml` — validation em todo PR/push
- `scripts/ci/validate-harness.py` — validator (skills, versions, state-machine, headers)
- Checks: valid registry, skill-files exist, consistent versions, Python compiles

**P2-B: Typed Handoff Schemas**
- `skills/reference/handoff-schemas.md` — spec complete
- `.hes/schemas/discovery-output.schema.json`
- `.hes/schemas/spec-output.schema.json`
- `.hes/schemas/design-output.schema.json`
- `.hes/schemas/security-output.schema.json`
- `.hes/schemas/review-output.schema.json`
- RULE-27: LLM validates schema before every phase transition

**P2-C: Context Engineering (Tool Output Offloading)**
- `skills/reference/context-engineering.md` — spec + thresholds + patterns by tool
- `scripts/hooks/context-offload.sh` — save, summary, clean
- Threshold: > 8.000 chars → offload for `.hes/context/tool-outputs/`
- RULE-28: LLM offloads tool outputs grandes, usa head+tail no contexto

### TIER 3 — Differentiation

**P3-A: Multi-Model Support**
- `.hes/models/claude.md` — quirks Claude (context window, tools, CLAUDE.md)
- `.hes/models/gpt-4o.md` — quirks GPT-4o (function_calling, AGENTS.md)
- `.hes/models/default.md` — defaults model-agnostic
- `model` field added ao schema de current.json

**P3-C: Skill Versioning**
- `skills/reference/skill-versioning.md` — guide complete
- Schema de header required for skill-files
- `.hes/state/skill-versions.json` for rastreio de versions instaladas

**P3-D: Harness Self-Testing**
- `skills/12-harness-tests.md` — 10 structural tests + 5 behavioral tests
- Comandos: `/hes test`, `/hes test --structural`, `/hes test --behavioral`
- Integrado ao CI via `validate-harness.py`

### Core updates

**SKILL.md v3.4.0 → v3.5.0:**
- RULE-26, RULE-27, RULE-28 addeds
- Commands: `/hes eval`, `/hes test`
- Routing: eval-agent, harness-test-agent
- Schema current.json: step_budget, token_tracking, model
- ANNOUNCE block: step budget + telemetria

**.hes/agents/registry.json:**
- eval-agent + harness-test-agent
- harness_version: 3.5.0

### Rules added ao SKILL.md

```
RULE-26  LLM MANAGES step budget per phase via step-budget.sh
RULE-27  LLM VALIDATES handoff schema before every phase transition
RULE-28  LLM OFFLOADS tool outputs > 8000 chars to .hes/context/
```

---

## v3.4.0 (2026-04-18)

Foco em security automatizada e rastreabilidade de execution intra-phase.

### Added

**new phase SECURITY (between GREEN e REVIEW):**
- `skills/10-security.md` — skill complete de security scan
- Integra **Bandit** (Python, primary) + **Semgrep** (Shell, secondary)
- Auto-fix loop por test_id (B105, B301, B311, B324, B601, B608...)
- Blocking gate: zero HIGH findings required to advance to REVIEW
- MEDIUM/LOW exceptions documented in `.hes/state/security-exceptions.json`
- Comando `/hes security` added

**Action Event Protocol — debug tracking intra-phase:**
- `scripts/hooks/log-action.sh` — LLM action logger to events.log
- `skills/reference/action-event-protocol.md` — specification complete do protocolo
- `session-id` UUID generated no bootstrap (`00-bootstrap.md` STEP 2)
- Schema de evento expandido: session_id, action_id, action_type, status por ação

**Infraestrutura:**
- `.hes/scripts/check-security-gate.py` — gate checker de security
- `docs/HES-v3.4-SPEC.md` — spec complete da implementation

### Updated

**State machine:**
- `ZERO → DISCOVERY → SPEC → DESIGN → DATA → RED → GREEN → SECURITY → REVIEW → DONE`
- Dois new gates: `GREEN → SECURITY` e `SECURITY → REVIEW`

**SKILL.md (v3.3.0 → v3.4.0):**
- Routing table: `feature = SECURITY → security-agent → skills/10-security.md`
- Phase lock gates: `GREEN → SECURITY` e `SECURITY → REVIEW`
- RULE-24: obrigatoriedade de logging de ações via log-action.sh
- RULE-25: obrigatoriedade de phase SECURITY before de REVIEW
- Schema `current.json`: field `security` with last_scan, last_gate_result
- version bumped: 3.3.0 → 3.4.0

**skills/00-bootstrap.md:**
- STEP 2: creation de `.hes/state/session-id` (UUID único per session)
- STEP 2: creation de `.hes/scripts/` directory
- STEP 3: schema current.json with field `security`

**skills/06-implementation.md:**
- NEXT ACTION aponta for SECURITY (not more diretamente for REVIEW)
- Gate explícito: GREEN → SECURITY → REVIEW

**skills/07-review.md:**
- DIMENSION 3 (Security manual) substituída por verificação do scan automatizado
- Referencia `.hes/state/security-report-end.json` e `security-exceptions.json`
- Checklist de revisão complementar (aspectos not cobertos por Bandit/Semgrep)

**.hes/agents/registry.json:**
- `security-agent` added ao array principal (between GREEN e REVIEW)
- `security-agent` added ao system_agents (trigger: `/hes security`)
- `harness_version` bumped: 3.3.0 → 3.4.0

### Rules added ao SKILL.md

```
RULE-24  LLM LOGS every significant action via scripts/hooks/log-action.sh
RULE-25  LLM EXECUTES security scan before REVIEW — no exceptions
```

---

## v3.3.0 (2026)

Refactoring focused on consistency e modernização técnica:

### Added

**Conceitual:**
- Sistema de auto-install automatizado via `skills/auto-install.md` (agentic tools)
- Detecção automática de linguagem + Audience Mode (beginner/expert)
- fields `agent_model`, `user_language`, `audience_mode` em current.json
- field `session.phase_lock` for enforcement de phase
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

**improvements:**
- Clarificação do mandato: LLM harness assume responsabilidade total de execution
- Sistema de phase lock more rigoroso
- Agent registry with versionamento explícito
- Habilidate de multi-agent orchestration via registry

### Updated

**Version consistency:**
- SKILL.md: v3.3.0 ✅
- ARCHITECTURE.md: v3.1 → v3.3.0
- 00-bootstrap.md: v3.2 → v3.3.0
- agent-registry.md: v3.2+ → v3.3+
- agent-identity template: v3.2 → v3.3
- CHANGELOG.md: added entry v3.3.0

**Files updated:**
- `SKILL.md` — execution mandate, language detection, audience mode, auto-install
- `ARCHITECTURE.md` — version + modernization of references
- `skills/00-bootstrap.md` — auto-install integration, v3.3 schema
- `skills/agent-registry.md` — v3.3+, validation command update
- `skills/reference/templates/agent-identity.md` — v3.3 references

**Removed inconsistencies:**
- ghost files que not existiam no skills/
- SETUP.md redundante (INSTALL.md cobre o mesmo)
- Referências a Files not existentes em bootstrap

## v3.1.0 (2025)

Refatoração based em leitura de literatura técnica:
- Fowler, Birgitta Böckeler (2026) — "Harness Engineering for Coding Agent Users" (martinfowler.with)
- LangChain / Harrison Chase (2026) — "Continual Learning for AI Agents"
- LangChain / Harrison Chase (2026) — "Your Harness, Your Memory"
- LangChain / Harrison Chase (2026) — "How Coding Agents Are Reshaping Engineering, Product and Design"

### Added

**Conceitual:**
- Taxonomia Guide/Sensor (feedforward/feedback) how modelo organizador of the harness
- Dimensões de regulação: Maintainability | Architecture Fitness | Behaviour Harness
- Camadas de aprendizado: Harness Layer / Context Layer / Memory Hot Path / Offline
- Harnessability how conceito explícito for avaliação de projects legados
- Context Compaction Protocol — o que preservar when o contexto enche
- Learning Loop formal — hot path (durante sessão) + offline (batch via /hes report)

**new Files:**
- `skills/harness-health.md` — diagnóstico das 3 dimensões de regulação (Fowler)

**Files updateds:**
- `SKILL.md` — modelo conceitual, protocol de roteamento, context compaction, REGRA-13 e REGRA-14
- `ARCHITECTURE.md` — completemente reescrito with taxonomia Fowler how estrutura organizadora
- `SETUP.md` — updated for v3.1, new comandos, tabela de novidades
- `skills/00-bootstrap.md` — `fitness/` folder, ArchUnit setup, updated current.json schema
- `skills/01-discovery.md` — papel explícito how guide inferencial do behaviour harness
- `skills/02-spec.md` — spec how "structured versioned prompt" (LangChain), rastreabilidade reforçada
- `skills/03-design.md` — harnessability por componente, ADR with impacto em harnessability, fitness/ update
- `skills/04-data.md` — alinhamento with v3.1
- `skills/05-tests.md` — "keep quality left" (Fowler), ArchUnit template, sensor loop por componente
- `skills/06-implementation.md` — sensor loop durante implementation, checklist with ArchUnit
- `skills/07-review.md` — Dimensão 5: Architecture Fitness Harness (ArchUnit/dep-cruiser)
- `skills/legacy.md` — step 3: Harnessability Assessment (tipagem, modularidade, testabilidade)
- `skills/error-recovery.md` — categorias A-E, Categoria D (gap de sensor), link ao harness improvement
- `skills/refactor.md` — Tipo I: Melhorar Harnessability; /hes harness no end
- `skills/report.md` — learning loop formal, categorias de lessons, propostas de new sensors

**Schema current.json:**
- Added: `harness_version`, `completed_cycles`

**Git hooks:**
- Addeds tipos `harness` e `fitness` ao commit checker (LLM-executed)

---

## v3.0.0 (2025)

Refatoração de monolito (v2: 1 file, ~1200 linhas) for sistema multi-file.

### Added
- Arquitetura multi-file: SKILL.md (orquestrador) + 12 skill-files especializados
- Event sourcing: `events.log` how fonte primária de rastreabilidade
- state explícito: `current.json` (substitui detecção frágil por existência de Files)
- Multi-feature with `dependency_graph`
- Suporte a domínios DDD with `.hes/domains/`
- Self-refinement loop with limite máximo de tentativas
- Skills: `harness-health.md`, `refactor.md`, `report.md`, `legacy.md`, `error-recovery.md`
- Comandos: `/hes start`, `/hes switch`, `/hes status`, `/hes rollback`, `/hes report`, `/hes refactor`

### Removed (vs v2)
- CLI executável (outside do Scope de skill)
- `runtime/executor.sh` e `feedback_parser.py` (infraestrutura separada)

---

## v2.0.0 (2025)

HES how file monolítico (~1200 linhas).

### Added
- Pipeline SDD+TDD de 7 steps
- Git hooks: LLM-executed safety checks (v3.4+)
- Template de discovery, spec, design, data, tests, review
- lessons.md e context.md
- Protocolo de retomada de sessão
- Bloco next AÇÃO required
- Detecção de state por existência de Files
- REGRAS ABSOLUTAS (01–10)


---

## v4.0.0-alpha (2026-04-20)

Plano arquitetural for transformação do HES de orquestrador sequencial em fábrica de software autônoma. this version contém os **stubs e especificações** for os agents e features do roadmap v3.6 → v4.0.

### Added

**PLAN-v4.0.md — Plano Arquitetural complete**
- validation do state current do v3.5.0 contra o repositório real
- 5 improvements maiores with impacto arquitetural documentado
- Roadmap v3.6 (Q2 2026) → v4.0 (Q2 2027)
- Tabela de impacto: single-agent → multi-agent, 23 → 30+ agents

**new Skill-File Stubs (planejados for v3.6 → v4.0)**
- `skills/planner.md` — Agent de decomposição de tasks (target: v3.6)
- `skills/orchestrator.md` — Maestro da frota de agents (target: v3.7)
- `skills/harness-evolver.md` — Auto-evolução of the harness (target: v3.8)
- `skills/optimizer.md` — Otimização for legibilidade de Agent (target: v3.9)
- `skills/reviewer.md` — Revisão autônoma de PR (target: v4.0)

**New Configuration Files (planned for v3.6)**
- `security-policy.yml` — Políticas de security how code (3 modos: default, enterprise, relaxed)
- `.hes/state/trust-policy.yml` — Política de confiança for auto-modificação of the harness

**Registry Updated**
- 5 new agents stub addeds ao system_agents
- field `status: stub` e `target_version` for each new Agent
- `plan_version: 4.0.0-alpha` added ao registry

### Comandos Planejados (not implementeds — stubs only)

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

### Próximos steps (v3.6 — Q2 2026)

1. Full implementation of `skills/planner.md` with `execution-plan.json` generation
2. Suporte a Git worktrees no SKILL.md (RULE-29 proposta)
3. Ativação de `security-policy.yml` na phase SECURITY (skills/10-security.md)
4. Verificação criptográfica de transições de phase no telemetry.jsonl
