# HES Skill — Report: Batch Learning + Harness Improvement

> Skill invocada via: `/hes report`
> Objetivo: transformar events.log + lessons.md em melhorias concretas do harness.
>
> "If you want to improve the harness, give a coding agent access to these traces.
>  This pattern is how we improved our base harness." — LangChain, 2026
>
> "An issue that happens multiple times should trigger improvement of the harness,
>  not just correction of the instance." — Fowler, 2026
>
> Executar: a cada 3 ciclos DONE (completed_cycles % 3 == 0)

---

## ◈ CONTEXTO A CARREGAR ANTES DE AGIR

```
1. Ler .hes/state/current.json → listar features com estado DONE + completed_cycles
2. Ler .hes/state/events.log   → histórico completo de transições
3. Ler .hes/tasks/lessons.md   → consolidar aprendizados
4. Ler .hes/tasks/backlog.md   → avaliar entregue vs planejado
```

---

## ◈ PASSO 1 — EXTRAIR MÉTRICAS DOS TRACES (events.log)

Para cada feature com estado DONE:

```
Tempo por fase = timestamp(to) - timestamp(from)

Feature: {{FEATURE_SLUG}}
  ZERO      → DISCOVERY : {{T}} min
  DISCOVERY → SPEC      : {{T}} min
  SPEC      → DESIGN    : {{T}} min
  DESIGN    → DATA      : {{T}} min
  DATA      → RED       : {{T}} min
  RED       → GREEN     : {{T}} min  [refinement_iterations: {{N}}]
  GREEN     → REVIEW    : {{T}} min
  REVIEW    → DONE      : {{T}} min
  ─────────────────────────────────
  Total: {{T}} min | Iterações de self-refinement: {{total_N}}
```

Extrair também por evento:
- Quantos rollbacks ocorreram? Por qual fase?
- Quantas iterações de self-refinement por feature?
- Qual fase tem mais variância de tempo entre features?

---

## ◈ PASSO 2 — IDENTIFICAR PADRÕES NAS LESSONS (hot path → offline consolidation)

```
Classificar lições do lessons.md em categorias:

CATEGORIA A — Violação de regra HES
  → Exemplo: "implementei antes de ter spec aprovada"
  → Ação: reforçar REGRA-xx no CLAUDE.md e no skill-file correspondente

CATEGORIA B — Erro técnico recorrente
  → Exemplo: "import de classe que não existia"
  → Ação: reforçar checklist anti-alucinação em 06-implementation.md

CATEGORIA C — Gap de guide (feedforward insuficiente)
  → Exemplo: "agente escolheu lib não catalogada"
  → Ação: melhorar o contexto carregado no skill-file correspondente

CATEGORIA D — Gap de sensor (feedback não detectou)
  → Exemplo: "violação de boundary passou despercebida"
  → Ação: propor novo sensor computacional (ArchUnit rule, linter rule)

CATEGORIA E — Processo (fluxo de aprovação, comunicação)
  → Exemplo: "usuário aprovou spec sem ler as RNs"
  → Ação: adicionar alerta no PRÓXIMA AÇÃO da spec

Lições por categoria: A={{N}} B={{N}} C={{N}} D={{N}} E={{N}}
```

---

## ◈ PASSO 3 — GERAR RELATÓRIO

Gerar `.hes/tasks/report-{{DATA}}.md`:

```markdown
# Relatório de Evolução HES — {{DATA}}

Projeto: {{NOME_PROJETO}} | HES v3.1
Período: {{DATA_INICIO}} → {{DATA_FIM}}
Ciclos analisados: {{N}} (ciclos {{X}} a {{Y}})

---

## Velocidade por Fase (minutos — média entre ciclos)

| Fase | {{Feature 1}} | {{Feature 2}} | {{Feature N}} | Média | Tendência |
|------|--------------|--------------|--------------|-------|----------|
| ZERO → DISCOVERY | | | | | ↓/→/↑ |
| DISCOVERY → SPEC | | | | | |
| SPEC → DESIGN | | | | | |
| DESIGN → DATA | | | | | |
| DATA → RED | | | | | |
| RED → GREEN | | | | | |
| GREEN → REVIEW | | | | | |
| **TOTAL** | | | | | |

## Fase mais lenta (gargalo principal)

**{{FASE_COM_MAIOR_TEMPO_MEDIO}}** — média: {{T}} min

Hipótese: {{BASEADO_EM_LESSONS_E_CATEGORIAS}}
Tipo de gap: Guide (feedforward) / Sensor (feedback) / Processo

---

## Self-Refinement Analysis

| Feature | Iterações RED→GREEN | Causa das Iterações |
|---------|--------------------|--------------------|
| {{feature}} | {{N}} | {{CATEGORIA_DO_ERRO}} |

Média de iterações: {{N}}
Tendência: {{diminuindo / estável / aumentando}}

---

## Lições por Categoria

| Categoria | Ocorrências | Distribuição |
|-----------|------------|-------------|
| A — Violação de regra HES | {{N}} | {{%}} |
| B — Erro técnico recorrente | {{N}} | {{%}} |
| C — Gap de guide | {{N}} | {{%}} |
| D — Gap de sensor | {{N}} | {{%}} |
| E — Processo | {{N}} | {{%}} |

---

## Lições Recorrentes → Candidatas ao Skill-File

| Lição | Ocorrências | Categoria | Skill-file alvo | Ação |
|-------|------------|-----------|----------------|------|
| {{LICAO}} | {{N}} | {{CAT}} | skills/{{XX}}.md | Adicionar checklist / Reforçar regra |

> Regra (Fowler + LangChain): lição com N ≥ 2 → melhorar o harness, não só corrigir instâncias.

---

## Gaps de Harness Identificados

### Novos sensores computacionais recomendados

| Gap | Tipo | Sensor Proposto | Esforço |
|-----|------|----------------|---------|
| {{BOUNDARY_VIOLATION}} | Architecture Fitness | ArchUnit rule | P |
| {{STYLE_ISSUE}} | Maintainability | Linter rule custom | P |

### Guides a melhorar

| Skill-file | Melhoria | Justificativa (baseada em traces) |
|-----------|----------|----------------------------------|
| skills/{{XX}}.md | {{O_QUE_ADICIONAR}} | {{FREQUENCIA_DO_PROBLEMA}} |

---

## Harness Backlog (priorizado por impacto em velocidade)

1. {{MELHORIA_1}} — impacto estimado: {{T}} min/ciclo — Tipo: Guide/Sensor
2. {{MELHORIA_2}}
3. {{MELHORIA_3}}

---

## Saúde do Processo

| Indicador | Status | Observação |
|-----------|--------|-----------|
| Etapas puladas | 🟢/🔴 | {{N}} vezes |
| Specs antes do código | 🟢/🔴 | {{N}} violações |
| Coverage médio | 🟢/🟡 | {{X}}% |
| Rollbacks | 🟢/🟡 | {{N}} rollbacks |
| ADRs gerados | ✅ | {{N}} ADRs |
| Architecture fitness checks | ✅/❌ | configurado/ausente |

---

*HES Report | Ciclos {{X}}–{{Y}} | v3.1.0 | {{DATA_ATUAL}}*
```

---

## ◈ PASSO 4 — EXECUTAR MELHORIAS DO HARNESS

Para cada gap identificado em Categoria C (guide) ou D (sensor):

### Melhorar guides inferenciais (skill-files):

```
Para gaps de Categoria C — Guide insuficiente:

1. Identificar qual skill-file não guiou o agente adequadamente
2. Propor adição ao skill-file:
   "Adicionar em skills/{{XX}}.md → seção Anti-Alucinação:
    [✅ NOVO] Antes de {{ACAO}}, verificar {{CONDICAO}}"
3. Confirmar com usuário antes de modificar o skill-file

Para gaps de Categoria A — Violação de regra HES:
1. Identificar qual REGRA-XX foi violada
2. Propor reforço no CLAUDE.md do projeto:
   "Adicionar em .claude/CLAUDE.md:
    ATENÇÃO: Regra-XX violada em {{FEATURE}}. Verificar {{O_QUE}} antes de {{ACAO}}"
```

### Propor novos sensores computacionais:

```
Para gaps de Categoria D — Sensor ausente:

Exemplo: violação de module boundary não detectada

Proposta de novo sensor:
  → ArchUnit rule: "{{NOME_REGRA}}"
  → Arquivo: src/test/java/.../ArchitectureTest.java
  → Regra: {{DESCRICAO_DA_REGRA_EM_CODIGO}}
  → Adicionar em .hes/domains/{{domain}}/fitness/

[A] "aprovar e implementar" → código do sensor gerado
[B] "implementar depois" → registrado em harness backlog
[C] "não aplicável" → registrado com justificativa
```

---

## ◈ PASSO 5 — ATUALIZAR ESTADO

Atualizar `current.json` — `completed_cycles` já foi incrementado no DONE.

Registrar em `events.log`:

```json
{
  "timestamp": "{{DATA_ATUAL_ISO}}",
  "feature": "global",
  "from": "ACTIVE",
  "to": "REPORT_GENERATED",
  "agent": "hes-v3.1",
  "metadata": {
    "report_file": ".hes/tasks/report-{{DATA}}.md",
    "cycles_analyzed": {{N}},
    "lessons_promoted": {{N}},
    "new_sensors_proposed": {{N}},
    "guides_improved": {{N}},
    "gargalo_identificado": "{{FASE}}"
  }
}
```

---

▶ PRÓXIMA AÇÃO — APÓS RELATÓRIO

```
📊 Relatório gerado: .hes/tasks/report-{{DATA}}.md

Harness Backlog: {{N}} melhorias identificadas

  [A] "implementar [melhoria X]"
      → Executo os passos de melhoria do guide ou sensor

  [B] "aprovar todas as lições para o skill-file"
      → Adiciono as lições recorrentes no skill-file correspondente

  [C] "/hes harness"
      → Diagnóstico detalhado das 3 dimensões de regulação

  [D] "próxima feature: [nome]"
      → Inicio Discovery com harness já melhorado

📄 Skill-file: skills/report.md (você está aqui)
💡 Dica (LangChain): "Traces são o core de todo loop de aprendizado."
   events.log + lessons.md = o flywheel de melhoria do HES.
   A cada ciclo, o harness fica mais forte que o projeto.
```
