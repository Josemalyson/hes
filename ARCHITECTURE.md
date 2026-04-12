# HES v3.1 — Arquitetura do Sistema

> Documento técnico de referência do HES — Harness Engineer Standard.
> Baseado em: Fowler (2026), LangChain/Harrison (2026).

---

## ◈ MODELO CONCEITUAL

### O que é um Harness (LangChain, 2026)

```
Agent = Model + Harness

O Harness é tudo ao redor do modelo:
  → Código que orquestra o agente
  → Instruções no contexto (SKILL.md, skill-files)
  → Ferramentas disponíveis (git hooks, scripts)
  → Memória (events.log, lessons.md, specs, ADRs)
```

> "Managing context, and therefore memory, is a core capability and responsibility
>  of the agent harness." — LangChain, 2026

O HES é o harness do projeto. Cada skill-file é um **guide inferencial**.
Cada git hook é um **sensor computacional**. As specs são o **behaviour harness**.

---

## ◈ TAXONOMIA DE CONTROLES (Fowler, 2026)

```
GUIDES (feedforward — antecipar e prevenir erros antes de agir)
┌─────────────────────────────────────────────────────────────┐
│ Inferencial (semântico — executado pelo LLM)                │
│   → SKILL.md (orquestrador)                                 │
│   → skills/01-discovery.md ~ skills/07-review.md           │
│   → .claude/CLAUDE.md (identidade do agente)                │
│   → .hes/domains/*/context.md (bounded context DDD)         │
│   → .hes/decisions/ADR-*.md (decisões arquiteturais)        │
│   → .hes/specs/*/0[1-4]-*.md (specs da feature)            │
│                                                             │
│ Computacional (determinístico — executado pela CPU)         │
│   → Verificação de pom.xml / package.json (pre-impl)        │
│   → Bootstrap templates (.hes/domains/*/fitness/)           │
│   → Anti-alucinação checklist (estruturado nos skill-files) │
└─────────────────────────────────────────────────────────────┘

SENSORS (feedback — observar após agir e autocorrigir)
┌─────────────────────────────────────────────────────────────┐
│ Inferencial (semântico)                                     │
│   → Self-refinement loop (05-tests + 06-implementation)     │
│   → Review checklist 5 dimensões (07-review)                │
│   → Harness health assessment (harness-health)              │
│                                                             │
│ Computacional (determinístico)                              │
│   → scripts/hooks/safety_validator.py (pre-commit)          │
│   → scripts/hooks/sdd_commit_checker.py (commit-msg)        │
│   → Build + coverage report (mvn/npm test)                  │
│   → Linters (Checkstyle/ESLint/ruff)                        │
│   → ArchUnit / dep-cruiser / import-linter                  │
│   → Dependency vulnerability scanner                        │
└─────────────────────────────────────────────────────────────┘
```

---

## ◈ DIMENSÕES DE REGULAÇÃO (Fowler, 2026)

```
┌──────────────────────────────────────────────────────────────┐
│ MAINTAINABILITY HARNESS                                      │
│   Objetivo: qualidade interna do código                      │
│   Guides:  CLAUDE.md com regras de qualidade                 │
│            Anti-alucinação checklists nos skill-files        │
│   Sensors: coverage ≥ 80%, linter, complexity check         │
│            Review checklist — Dimensão "Qualidade"           │
├──────────────────────────────────────────────────────────────┤
│ ARCHITECTURE FITNESS HARNESS                                 │
│   Objetivo: module boundaries + drift arquitetural           │
│   Guides:  03-design.md + ADRs + domain context.md          │
│            .hes/domains/*/fitness/ (regras de domínio)       │
│   Sensors: ArchUnit / dep-cruiser / import-linter           │
│            Review checklist — Dimensão "Arquitetura"         │
│            /hes report — drift detection offline             │
├──────────────────────────────────────────────────────────────┤
│ BEHAVIOUR HARNESS                                            │
│   Objetivo: o código faz o que a spec diz                    │
│   Guides:  01-discovery + 02-spec (cenários BDD)            │
│            Rastreabilidade RN → cenário → teste              │
│   Sensors: suite de testes unitários + integração            │
│            Self-refinement loop (05 + 06)                    │
│            Review humano (07-review)                         │
└──────────────────────────────────────────────────────────────┘
```

---

## ◈ CAMADAS DE APRENDIZADO (LangChain, 2026)

```
┌─────────────────────────────────────────────────────────────┐
│ HARNESS LAYER (skill-files, SKILL.md)                       │
│   → Evolui via self-improvement protocol                     │
│   → /hes report: batch learning sobre events.log            │
│   → Lição recorrente (N ≥ 2) → skill-file correspondente   │
│   → Muda para TODOS os projetos futuros                      │
├─────────────────────────────────────────────────────────────┤
│ CONTEXT LAYER (lessons.md, decisions/, context.md, specs)   │
│   → Evolui por ciclo/feature/projeto                        │
│   → Hot path: lessons registradas durante erros             │
│   → Offline: consolidação via /hes report                   │
│   → Muda para ESTE projeto                                   │
├─────────────────────────────────────────────────────────────┤
│ MEMORY = CONTEXT MANAGEMENT                                  │
│   → O harness É a memória (LangChain, 2026)                │
│   → events.log = traces = fonte primária do learning loop   │
│   → lessons.md = memória consolidada do projeto             │
│   → ADRs = memória arquitetural permanente                  │
└─────────────────────────────────────────────────────────────┘
```

---

## ◈ MÁQUINA DE ESTADOS

```
                    ZERO
                      │
          ┌───────────┴───────────┐
          │ (novo projeto)        │ (projeto existente)
          ▼                       ▼
     00-bootstrap.md          legacy.md
          │                       │
          │                  [Harnessability
          │                   Assessment]
          └───────────┬───────────┘
                      │
                      ▼
               01-discovery.md    ← Guide inferencial
                      │ aprovado
                      ▼
                 02-spec.md       ← Guide inferencial (behaviour harness)
                      │ aprovado
                      ▼
                 03-design.md     ← Guide inferencial (architecture fitness)
                      │ aprovado
                      ▼
                 04-data.md       ← Guide inferencial + computacional
                      │ migration ok
                      ▼
                 05-tests.md (RED) ← Sensor inferencial (behaviour)
                      │ testes falhando conforme esperado
                      ▼
             06-implementation.md (GREEN)
                      │ build verde
                      ▼
                 07-review.md     ← Sensor inferencial (5 dimensões)
                      │ ArchUnit + coverage + checklist ok
                      ▼
                    DONE
                      │
                      ├─ (a cada 3 ciclos)
                      ▼
                 report.md        ← Batch learning (offline)
                      │ melhorias identificadas
                      ▼
             harness-health.md    ← Diagnóstico das 3 dimensões
                      │
                      ▼
                 [harness melhorado]
                      │
                      ▼
               próxima feature ──→ loop
```

---

## ◈ EVENT SOURCING

```
events.log = traces = flywheel de aprendizado (LangChain, 2026)

Cada evento contém:
  timestamp, feature, from, to, agent, metadata
  metadata: artifacts, duration_minutes, refinement_iterations, lessons_added

Usos dos traces:
  → /hes report: batch analysis → harness improvement
  → /hes status: estado atual de todas as features
  → /hes rollback: identificar o estado alvo para reverter
  → Diagnóstico de gargalos por fase
```

---

## ◈ MULTI-FEATURE + DEPENDENCY GRAPH

```json
{
  "active_feature": "payment",
  "features": {
    "payment": "DESIGN",
    "auth":    "DONE",
    "billing": "SPEC"
  },
  "dependency_graph": {
    "billing": ["payment"]
  }
}
```

Regras:
- `active_feature` = foco da sessão atual
- `/hes switch` muda foco sem perder estado
- Feature bloqueada por dependência não-DONE → warning automático
- `/hes status` mostra o estado de todas + dependências

---

## ◈ HARNESSABILITY (Fowler, 2026)

> "Not every codebase is equally amenable to harnessing."

Codebase fortemente tipado + boundaries claros + DI + testes = harnessability alta.
O harness é instalado proporcionalmente ao score (veja `legacy.md`).

```
Alto   → Harness completo (todos os guides + sensors)
Médio  → Harness incremental (começar pelos guides + hooks)
Baixo  → Harness mínimo (só hooks + specs) + sprint de harnessability
```

---

## ◈ ESTRUTURA DE ARQUIVOS

```
projeto/
├── SKILL.md                      ← Orquestrador (ler sempre primeiro)
├── ARCHITECTURE.md               ← Este documento
├── SETUP.md                      ← Instalação por ambiente
│
└── skills/
    ├── 00-bootstrap.md           ← Estrutura HES + git hooks + domínios
    ├── 01-discovery.md           ← Entendimento + RN + UC [Guide Inf.]
    ├── 02-spec.md                ← BDD + API contract [Guide Inf.]
    ├── 03-design.md              ← Componentes + ADR [Guide Inf.]
    ├── 04-data.md                ← Schema + migration [Guide Comp.]
    ├── 05-tests.md               ← Fase RED [Sensor Inf.]
    ├── 06-implementation.md      ← Fase GREEN [Sensor Inf.]
    ├── 07-review.md              ← 5 dimensões + DONE [Sensor Inf.]
    ├── legacy.md                 ← Harnessability + inventário
    ├── error-recovery.md         ← Diagnóstico por categoria
    ├── refactor.md               ← Refactoring seguro por tipo
    ├── report.md                 ← Batch learning (offline)
    └── harness-health.md         ← Diagnóstico 3 dimensões [NOVO]
```

---

## ◈ DECISÕES DE DESIGN — O QUE FICOU DE FORA E POR QUÊ

| Proposta | Decisão | Justificativa |
|----------|---------|--------------|
| CLI executável (`hes-cli`) | ❌ Fora do escopo | Skill-file é LLM-agnóstico; CLI é infraestrutura separada |
| `runtime/executor.sh` | ❌ Removido | Idem — pertence à camada de infraestrutura |
| "RAG semântica" | 🔄 Adaptado | Context loading estruturado por convenção — funciona em qualquer LLM |
| Self-refinement ilimitado | 🔄 Limitado | Máx. 3–5 tentativas + escalação humana obrigatória |
| Event sourcing completo | ✅ Incluído | `events.log` com metadata rico — base do learning loop |
| Multi-feature | ✅ Incluído | `dependency_graph` + `/hes switch` |
| Domínios DDD | ✅ Incluído | `.hes/domains/*/context.md + fitness/` |
| Architecture Fitness | ✅ Novo em v3.1 | Dimensão de Fowler que estava ausente no v3 |
| Harnessability assessment | ✅ Novo em v3.1 | Essencial para projetos legados (Fowler) |
| Context compaction | ✅ Novo em v3.1 | Protocolo explícito para sessões longas |
| Learning loop formal | ✅ Novo em v3.1 | Hot path + offline (LangChain continual learning) |
| `/hes harness` | ✅ Novo em v3.1 | Diagnóstico das 3 dimensões de regulação |

---

*HES v3.1.0 — Architecture Document*
*Referências: Fowler (2026) · LangChain Harrison (2026)*
*Josemalyson Oliveira | 2026*
