# HES — Changelog

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
- Adicionados tipos `harness` e `fitness` ao sdd_commit_checker.py

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
- Git hooks: safety_validator.py, sdd_commit_checker.py
- Template de discovery, spec, design, data, tests, review
- lessons.md e context.md
- Protocolo de retomada de sessão
- Bloco PRÓXIMA AÇÃO obrigatório
- Detecção de estado por existência de arquivos
- REGRAS ABSOLUTAS (01–10)
