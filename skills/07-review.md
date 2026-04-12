# HES Skill — 07: Review + Fechamento do Ciclo

> Skill carregada quando: feature.estado = REVIEW
> Pré-condição: todos os testes passando (GREEN), coverage ≥ 80%.
> Esta é a etapa de regulação final antes de DONE. Combina sensors inferenciais e computacionais.

---

## ◈ CONTEXTO A CARREGAR ANTES DE AGIR

```
1. Ler .hes/specs/{{feature}}/02-spec.md   → cenários BDD (baseline)
2. Ler .hes/specs/{{feature}}/03-design.md → componentes (aderência ao design)
3. Ler .hes/decisions/ADR-{{NNN}}.md       → decisão arquitetural (verificar implementação)
4. Ler .hes/tasks/lessons.md               → padrões de erro anteriores para checar
5. Verificar resultados dos sensors computacionais:
   → Último build: coverage % e número de testes
   → Output do linter (se configurado)
   → ArchUnit / dep-cruiser (se configurado)
```

---

## ◈ DIMENSÃO 1 — ADERÊNCIA AO BEHAVIOUR HARNESS (Spec)

```
[ ] Todos os cenários BDD do 02-spec.md têm cobertura de teste?
[ ] Rastreabilidade RN → cenário: cada RN-xx tem ao menos 1 teste?
[ ] Mensagens de erro implementadas = EXATAMENTE as definidas na spec?
[ ] Contrato de API (rota, método, campos, status codes) = implementado?
[ ] Há código implementado além do escopo da spec? (feature creep)
    → Se sim: registrar como débito ou propor spec complementar
```

---

## ◈ DIMENSÃO 2 — MAINTAINABILITY HARNESS (Qualidade Interna)

```
[ ] Sem lógica de negócio no Controller/Router
[ ] Sem acesso a dados direto no Service
[ ] Sem regra de negócio no Repository
[ ] Nomes descritivos — sem abreviações obscuras, sem variáveis tipo "data", "info"
[ ] Sem números mágicos (usar constantes nomeadas)
[ ] Sem comentários óbvios (o código deve ser autoexplicativo)
[ ] Sem código morto (métodos não usados, imports desnecessários)
[ ] Sem duplicação — se há 2+ cópias, extrair
[ ] Complexidade ciclomática ≤ 10 por método
[ ] Todos os erros de domínio mapeados para HTTP responses corretos
```

---

## ◈ DIMENSÃO 3 — SEGURANÇA

```
[ ] Nenhum dado sensível logado (senhas, tokens, CPF, PAN, dados pessoais)
[ ] Inputs validados ANTES de persistir (DTO validation)
[ ] Nenhum secret hardcoded — zero strings de credential no código
[ ] SQL parametrizado — zero concatenação em queries
[ ] Autorização verificada antes de acessar recursos
[ ] Headers de segurança mantidos (não removidos)
[ ] Dados de APIs externas sanitizados antes de usar internamente
```

---

## ◈ DIMENSÃO 4 — OBSERVABILIDADE

```
[ ] Logs estruturados com contexto:
    - feature / operação sendo executada
    - IDs relevantes (userId, entityId, correlationId/traceId)
    - resultado (sucesso / erro + motivo)
[ ] Nível de log correto:
    DEBUG → detalhes de execução (não em produção)
    INFO  → eventos de negócio relevantes
    WARN  → situações inesperadas mas recuperáveis
    ERROR → falhas que precisam de atenção (com stack trace)
[ ] Exceções logadas com stack trace completo no ERROR
[ ] Nenhum dado sensível nos logs
[ ] Trace ID propagado (se distributed tracing está em uso)
[ ] Métricas críticas instrumentadas (se Prometheus/Datadog/CloudWatch ativo)
```

---

## ◈ DIMENSÃO 5 — ARCHITECTURE FITNESS HARNESS (NOVO em v3.1)

> "The agent harness acts like a cybernetic governor, combining feedforward and
>  feedback to regulate the codebase towards its desired state." — Fowler, 2026

```
[ ] A implementação segue o fluxo definido em 03-design.md?
[ ] A decisão do ADR-{{NNN}} foi respeitada?
[ ] Nenhuma dependência circular introduzida?
[ ] Boundaries de módulo respeitados (Controller → Service → Repository):
    → Se ArchUnit configurado: verificar output do último teste de arquitetura
    → Se não configurado: revisar manualmente imports e dependências
[ ] Nenhuma violação de bounded context DDD (se domínios definidos)?
[ ] Migration é reversível — rollback possível sem perda de dados?
[ ] Feature nova não criou acoplamento não intencional com outro módulo?

DRIFT CHECK (executar se há ArchUnit/dep-cruiser):
  java:   mvn test -Dtest=ArchitectureTest
  node:   npm run check:arch
  python: python -m import-linter
```

---

## ◈ GERAR TEMPLATE DE PR

```markdown
## {{NOME_FEATURE}} — {{tipo}}: {{descricao_resumida}}

### Contexto
{{PROBLEMA_QUE_RESOLVE_em_linguagem_de_negocio}}

### O que foi feito
- {{MUDANCA_1}}
- {{MUDANCA_2}}

### Referências HES
- 📋 Discovery   : `.hes/specs/{{feature}}/01-discovery.md`
- 📐 Spec        : `.hes/specs/{{feature}}/02-spec.md`
- 🏗  Design     : `.hes/specs/{{feature}}/03-design.md`
- 🏛  ADR        : `.hes/decisions/ADR-{{NNN}}.md`
- 💾 Data Layer  : `.hes/specs/{{feature}}/04-data.md`

### Checklist
- [ ] Cenários BDD cobertos (rastreabilidade RN → cenário → teste)
- [ ] Coverage ≥ 80%
- [ ] Architecture fitness: ArchUnit/dep-cruiser verde (se configurado)
- [ ] Migration testada (up + rollback)
- [ ] Sem secrets no código
- [ ] Logs estruturados com contexto
- [ ] Sem TODO/FIXME

### Como testar
```bash
{{COMANDO_PARA_SUBIR_AMBIENTE}}

curl -X {{METODO}} {{URL}} \
  -H "Authorization: Bearer {{TOKEN}}" \
  -d '{{PAYLOAD}}'

# Esperado: HTTP {{STATUS}} — {{DESCRICAO_DO_RESPONSE}}
```
```

---

## ◈ LEARNING LOOP — ATUALIZAR LESSONS.MD (hot path)

```markdown
## Sessão: {{DATA}} — {{FEATURE_SLUG}}

### ✅ O que funcionou
- {{APRENDIZADO_POSITIVO}}

### ❌ O que falhou / exigiu retrabalho
- {{ERRO_COMETIDO}}
  - Causa-raiz: {{CAUSA}}
  - Impacto: {{TEMPO_PERDIDO_OU_RETRABALHO}}
  - Prevenção futura: {{COMO_EVITAR}}

### 🔄 Mudança de comportamento adotada
- {{NOVO_COMPORTAMENTO}}

### 📌 Promover ao skill-file? (Fowler: "issue recorrente → melhorar o harness")
- [ ] {{LICAO}} → skills/{{XX-arquivo}}.md
      (marcar se já apareceu antes — promoção automática na 2ª ocorrência)
```

**Verificar:** se alguma lição nesta sessão já aparece em lessons.md anterior → promover agora.

---

## ◈ FECHAR O CICLO — ATUALIZAR ESTADO

### `.hes/state/current.json`:

```json
{
  ...
  "features": {
    "{{FEATURE_SLUG}}": "DONE"
  },
  "active_feature": null,
  "completed_cycles": {{N + 1}},
  "last_updated": "{{DATA_ATUAL_ISO}}"
}
```

### `.hes/tasks/backlog.md`: mover para `✅ Concluídas`

### `.hes/state/events.log`:

```json
{
  "timestamp": "{{DATA_ATUAL_ISO}}",
  "feature": "{{FEATURE_SLUG}}",
  "from": "REVIEW",
  "to": "DONE",
  "agent": "hes-v3.1",
  "metadata": {
    "review_dimensions_passed": 5,
    "architecture_fitness_checked": true,
    "lessons_added": {{N}},
    "pr_ready": true,
    "cycle_number": {{completed_cycles}}
  }
}
```

---

▶ PRÓXIMA AÇÃO — APÓS DONE

```
🏁 Ciclo {{completed_cycles}} completo! {{NOME_FEATURE}} entregue.

Resumo:
  📋 Specs    : .hes/specs/{{FEATURE_SLUG}}/
  🏛  ADR     : .hes/decisions/ADR-{{NNN}}.md
  📚 Lições   : .hes/tasks/lessons.md (atualizado)
  🔀 PR       : pronto para revisão humana

  [A] "próxima feature: [nome]"
      → Inicio Discovery (skills/01-discovery.md)

  [B] "quero ver o backlog"
      → Mostro .hes/tasks/backlog.md priorizado

  [C] "/hes report"  (recomendado se completed_cycles % 3 == 0)
      → Batch learning sobre events.log → melhoria do harness

  [D] "/hes harness"
      → Diagnóstico de saúde do harness nas 3 dimensões

📄 Skill-file próximo: skills/01-discovery.md ou skills/report.md
💡 Dica: o review é um sensor inferencial — complementa, não substitui,
   os sensors computacionais (linter, ArchUnit, coverage).
   Os dois juntos formam o behaviour + architecture fitness harness.
```
