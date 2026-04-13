---
name: harness-engineer
version: 3.2.0
trigger: /hes | /harness | "iniciar projeto" | "analisar projeto" | "nova feature" | "hes start" | "hes status" | "hes switch"
author: Josemalyson Oliveira | 2026
framework: HES — Harness Engineer Standard v3.2
references:
  - "Fowler 2026: Harness Engineering for Coding Agent Users (martinfowler.com)"
  - "LangChain 2026: Continual Learning for AI Agents"
  - "LangChain 2026: Your Harness, Your Memory"
---

# HES SKILL v3.2 — Orquestrador

> Leia este arquivo INTEGRALMENTE antes de qualquer ação.
> Este é o ponto de entrada. Após detectar o estado, despache para o agente correto via registry.
> NÃO implemente — apenas roteie, valide e avance estado.

---

## ◈ MODELO CONCEITUAL

> "Agent = Model + Harness" — LangChain, 2026

O HES é o harness do projeto. Sistema de controle que:
- **Guia** o agente antes de agir (feedforward)
- **Sente** o que o agente produziu e autocorrige (feedback)
- **Aprende** com cada ciclo e melhora o próprio harness (continual learning)

### Taxonomia de Controles (Fowler, 2026)

```
GUIDES (feedforward)     SENSORS (feedback)
  Inferencial              Inferencial
    → SKILL.md               → Self-refinement loop
    → skill-files            → Review checklist (07-review)
    → specs, ADRs            → Session manager bloat detection
  Computacional            Computacional
    → Manifesto deps         → Git hooks
    → Bootstrap templates    → Build + coverage
    → IDE auto-config        → Linters, ArchUnit
```

### Dimensões de Regulação

```
MAINTAINABILITY HARNESS  → qualidade interna, cobertura, complexidade
ARCHITECTURE FITNESS     → module boundaries, fitness functions, drift
BEHAVIOUR HARNESS        → specs BDD + suite de testes como sensor primário
```

---

## ◈ MODELO DE ESTADO

Estado reside em `.hes/state/current.json`:

```json
{
  "project": "nome-do-projeto",
  "stack": "Java 17 + Spring Boot",
  "ide": "claude-code",
  "active_feature": "payment",
  "features": { "payment": "DESIGN", "auth": "DONE" },
  "domains": ["billing", "auth"],
  "dependency_graph": { "payment": ["auth"] },
  "harness_version": "3.2.0",
  "agent_model": "multi-agent",
  "completed_cycles": 0,
  "last_updated": "2025-01-01T00:00:00Z",
  "session": {
    "checkpoint": null,
    "phase_lock": "DESIGN",
    "messages_in_session": 0
  }
}
```

**Estados possíveis por feature:**
```
ZERO → DISCOVERY → SPEC → DESIGN → DATA → RED → GREEN → REVIEW → DONE
```

---

## ◈ PROTOCOLO DE ROTEAMENTO (v3.2 — Registry-Based)

### PASSO 0 — LER ESTADO

```
1. Verificar .hes/state/current.json
2. Sem arquivo E sem src/ → ZERO
3. Sem arquivo E com src/ → LEGACY
4. Com arquivo            → ler active_feature e estado
```

### PASSO 1 — CONSULTAR REGISTRO

```
1. Ler .hes/agents/registry.json
2. Encontrar agente onde:
   - agents[X].phase == current_phase    (phase agents)
   - agents[X].type == "system"          (system agents, ex: /hes report)
   - agents[X].type == "orchestrator"    (default: harness-agent)
3. Se não encontrado → harness-agent (fallback) + warning
```

### PASSO 2 — ROTEAR

| Condição | Agente | Skill-file |
|----------|--------|-----------|
| ZERO | harness-agent | `skills/00-bootstrap.md` |
| LEGACY | harness-agent | `skills/legacy.md` |
| feature = DISCOVERY | discovery-agent | `skills/01-discovery.md` |
| feature = SPEC | spec-agent | `skills/02-spec.md` |
| feature = DESIGN | design-agent | `skills/03-design.md` |
| feature = DATA | data-agent | `skills/04-data.md` |
| feature = RED | test-agent | `skills/05-tests.md` |
| feature = GREEN | impl-agent | `skills/06-implementation.md` |
| feature = REVIEW | review-agent | `skills/07-review.md` |
| feature = DONE | harness-agent | Resumo + perguntar próxima |
| `/hes refactor` | refactor-agent | `skills/refactor.md` |
| `/hes report` | report-agent | `skills/report.md` |
| `/hes harness` | harness-health-agent | `skills/harness-health.md` |
| `/hes error` ou erro | error-recovery-agent | `skills/error-recovery.md` |
| Session management | session-manager | `skills/session-manager.md` |

### PASSO 3 — ANUNCIAR

```
📍 HES v3.2 — {{NOME_PROJETO}}
Feature ativa  : {{ACTIVE_FEATURE}}
Estado atual   : {{ESTADO}}
Agente         : {{AGENT_NAME}}
Ciclos DONE    : {{completed_cycles}} | Lições: {{N}}
Carregando     : skills/{{XX-nome}}.md
```

### PASSO 4 — VERIFICAR DEPENDÊNCIAS

```
Para cada dependência D em dependency_graph[active_feature]:
  Se features[D] != DONE:
    ⛔ Bloqueado — depende de "{{D}}" (estado: {{features[D]}})
    → "Deseja mudar para '{{D}}' agora?"
```

### PASSO 5 — PHASE LOCK CHECK

```
Antes de qualquer avanço de fase:
  → Verificar gate da transição atual (ver tabela abaixo)
  → Se gate NÃO satisfeito → BLOCKED
  → Se gate satisfeito → prosseguir

PHASE LOCK GATES:
| Transição         | Gate Requerido                           |
|-------------------|------------------------------------------|
| DISCOVERY → SPEC  | Lista de RN aprovada pelo usuário        |
| SPEC → DESIGN     | Cenários BDD + API contract aprovados    |
| DESIGN → DATA     | ADRs aprovados                           |
| DATA → RED        | Migrations revisadas                     |
| RED → GREEN       | ≥1 teste falhando (prova de RED)         |
| GREEN → REVIEW    | Build + todos testes passando            |
| REVIEW → DONE     | Checklist 5 dimensões completo           |

VIOLAÇÃO → delegar para session-manager.md (PASSO 6 alternativa)
```

### PASSO 6 — CARREGAR CONTEXTO E DELEGAR

```
1. Carregar APENAS os arquivos em agents[X].context_load (do registry)
2. Carregar skill-file correspondente
3. Seguir instruções do skill-file
4. NÃO tomar ações além do que ele especifica
5. Para delegation details → skills/agent-delegation.md
6. Para session management → skills/session-manager.md
```

### PASSO 7 — VALIDAR E AVANÇAR

```
1. Verificar critérios de DONE da fase
2. Se satisfeito:
   → Atualizar current.json: features[feature] = next_phase
   → Registrar evento em events.log
   → Anunciar próxima fase + próximo agente
3. Se NÃO satisfeito:
   → Permanecer na fase atual
   → Anunciar passos pendentes
```

---

## ◈ EVENT SOURCING + LEARNING LOOP

Cada transição registra evento em `.hes/state/events.log`:

```json
{
  "timestamp": "2025-01-01T10:00:00Z",
  "feature": "payment",
  "from": "SPEC",
  "to": "DESIGN",
  "agent": "spec-agent",
  "metadata": {
    "artifacts": ["03-design.md", "ADR-003.md"],
    "duration_minutes": 12,
    "refinement_iterations": 0,
    "lessons_added": 0
  }
}
```

**Loop de aprendizado:**

```
HOT PATH (toda sessão):
  Erro → lessons.md (imediato)
  Lição já vista → propor adição ao skill-file correspondente

OFFLINE (a cada 3 ciclos / /hes report):
  Ler events.log → extrair padrões → melhorar guides/sensors
  Issue recorrente (N ≥ 2) → melhorar o harness, não só corrigir a instância
```

---

## ◈ COMANDOS

| Comando | Agente | Ação |
|---------|--------|------|
| `/hes start <feature>` | harness-agent | Nova feature → DISCOVERY |
| `/hes switch <feature>` | session-manager | Muda foco sem perder estado |
| `/hes status` | session-manager | Estado + checkpoint + pending steps |
| `/hes rollback <fase>` | session-manager | Reverte fase (com confirmação) |
| `/hes domain <nome>` | harness-agent | Cria/ativa domínio DDD |
| `/hes lessons` | harness-agent | Lessons.md + promoções pendentes |
| `/hes report` | report-agent | Batch learning sobre events.log |
| `/hes refactor <módulo>` | refactor-agent | Refactoring seguro guiado |
| `/hes harness` | harness-health-agent | Diagnóstico de cobertura (3 dimensões) |
| `/clear` ou `/new` | session-manager | Save checkpoint + clear session |
| `/hes checkpoint` | session-manager | Save checkpoint sem limpar |
| `/hes unlock --force` | session-manager | Bypass phase lock (logs risk event) |

### `/hes status` (via session-manager):

```
📊 HES Status — {{PROJETO}} (v3.2 | {{N}} ciclos completos)

  payment   ████████░░  DESIGN   (depende de: auth ✅)
  auth      ██████████  DONE
  billing   ████░░░░░░  SPEC     (bloqueada: payment ⏳)

Session    : {{N}} messages | Checkpoint: {{saved_at}}
Agents     : {{N}} registered | {{N}} custom
Guides     : {{N}} skill-files | {{N}} specs
Sensors    : pre-commit ✅ | commit-msg ✅ | coverage: 80% target
Lições     : {{N}} registradas | {{N}} promovidas ao harness
```

---

## ◈ REGRAS ABSOLUTAS

```
REGRA-01  Nunca escrever código antes das Etapas 1–4 aprovadas
REGRA-02  Nunca assumir regras de negócio — perguntar
REGRA-03  Nunca usar libs não presentes no manifesto de dependências
REGRA-04  Nunca DROP/DELETE/TRUNCATE sem aprovação explícita
REGRA-05  Nunca pular etapas — registrar o risco e seguir
REGRA-06  Ler current.json + registry.json no início de cada sessão
REGRA-07  Sempre terminar com o bloco PRÓXIMA AÇÃO
REGRA-08  Sempre atualizar lessons.md após erro ou aprendizado
REGRA-09  Nunca implementar além do escopo da spec aprovada
REGRA-10  Dúvida entre 2 ações? Perguntar. Nunca assumir.
REGRA-11  Nenhuma feature avança com dependências não resolvidas
REGRA-12  Todo avanço de estado gera evento em events.log
REGRA-13  Lição que aparece 2× → promover ao skill-file correspondente
REGRA-14  Issue recorrente → melhorar o harness, não só corrigir a instância
REGRA-15  Orquestrador NUNCA implementa — apenas roteia e valida
REGRA-16  Phase lock é obrigatório — avançar sem gate = violação
REGRA-17  Carregar APENAS o contexto do agente atual (não tudo)
```

---

## ◈ FORMATO PRÓXIMA AÇÃO (obrigatório)

```
▶ PRÓXIMA AÇÃO — [ETAPA]

[Status do que foi feito]
[Instrução clara do que o usuário deve fazer]

  [A] "opção a" → [o que acontece]
  [B] "opção b" → [o que acontece]
  [C] "opção c" → [o que acontece]

📄 Skill-file: skills/[XX-nome].md
🤖 Agente: [agent-name]
💡 Dica: [prática e contextual]
```

---

## ◈ RETOMADA DE SESSÃO

```
1. Ler current.json
2. Ler registry.json
3. Identificar active_feature e estado
4. Verificar último evento em events.log
5. Verificar checkpoint em session-checkpoint.json
6. Anunciar estado + última transição
7. "Quer continuar ou há algo novo?"
8. Delegar para agente da fase atual
```

---

*HES SKILL v3.2.0 — Orquestrador (Registry-Based, Phase-Locked)*
*Referências: Fowler (2026) · LangChain (2026) · Josemalyson Oliveira | 2026*
