# HES Skill — Error Recovery

> Skill carregada quando: usuário reporta erro em qualquer fase do pipeline.
> Objetivo: diagnóstico cirúrgico + correção mínima + prevenção sistêmica.
>
> Princípio (Fowler, 2026): "An issue that happens multiple times should trigger
> improvement to the harness, not just correction of the instance."

---

## ◈ PROTOCOLO DE DIAGNÓSTICO

```
1. Pedir erro completo se não fornecido
   → "Cole o stack trace / mensagem de erro completa"

2. Identificar CATEGORIA:
   A → Violação de regra HES (código antes da spec, etc.)
   B → Erro técnico recorrente (import inválido, tipo errado)
   C → Gap de guide (agente não foi orientado sobre algo)
   D → Gap de sensor (o problema não foi detectado antes de chegar aqui)
   E → Processo (aprovação pulada, comunicação falhou)

3. Identificar CAUSA-RAIZ (não o sintoma):
   - O erro está no código de produção ou no teste?
   - É consequência de violação de etapa HES?
   - É problema de configuração de ambiente?
   - É um gap do harness que permitiu o problema chegar até aqui?

4. Propor correção MÍNIMA e CIRÚRGICA:
   - Menor mudança que resolve o problema
   - Não refatorar durante debugging
   - Não adicionar funcionalidade durante debugging

5. Verificar impacto no harness:
   - Categoria D → propor novo sensor ou fortalecer sensor existente
   - Categoria C → propor melhoria no skill-file correspondente
   - Categoria A → reforçar regra no CLAUDE.md
   - N ≥ 2 ocorrências → OBRIGATÓRIO melhorar o harness

6. Registrar em lessons.md após resolução
```

---

## ◈ DIAGNÓSTICO POR CATEGORIA

### Categoria A — Violação de Regra HES

```
Sintoma: código implementado antes da spec / lib não verificada / etapa pulada

Ação imediata:
  → Reverter o que foi feito fora de ordem
  → Completar a etapa que foi pulada

Ação no harness (se N ≥ 2):
  → Reforçar REGRA-xx no .claude/CLAUDE.md
  → Adicionar alerta no skill-file da fase onde ocorreu
```

### Categoria B — Erros de Compilação

```
Causa mais comum: import de classe que não existe ainda

Diagnóstico:
  → Verificar se a classe existe em src/
  → Verificar se o pacote está correto
  → Verificar se a dependência está no manifesto

Correção:
  → Criar a classe faltante (mínima, sem lógica)
  → Corrigir o import
  → Adicionar a dependência (com aprovação — REGRA-03)

Ação no harness (se recorrente):
  → Reforçar anti-alucinação checklist em 06-implementation.md
```

### Categoria B — Injeção de Dependência (Spring)

```
BeanCreationException / NoSuchBeanDefinitionException

Diagnóstico:
  → Verificar: @Service, @Repository, @Component, @Bean
  → Verificar se o pacote está no @ComponentScan
  → Verificar perfil ativo (prod vs test)

Correção mínima:
  → Adicionar anotação faltante
  → Corrigir qualifier se necessário
```

### Categoria B — Erros de Migration (Flyway)

```
Checksum mismatch:
  → NUNCA alterar migration aplicada em produção (REGRA-04)
  → Criar NOVA migration com a correção

Column already exists:
  → Usar CREATE TABLE IF NOT EXISTS
  → Verificar se migration já foi aplicada

FK violation:
  → Verificar ordem de criação de tabelas
  → Verificar ON DELETE behavior
```

### Categoria B — Erros de Teste

```
Expected X but was Y:
  → NÃO mudar o teste para fazer passar
  → Verificar: a lógica implementada está correta?
  → Verificar: a mensagem bate EXATAMENTE com o 02-spec.md?
  → Verificar: o mock está configurado corretamente?

NullPointerException em teste:
  → Verificar se o mock está injetado
  → Verificar se @BeforeEach inicializa o subject
```

### Categoria C — Gap de Guide (feedforward insuficiente)

```
Sintoma: agente fez algo incorreto por falta de orientação

Exemplos:
  → Usou biblioteca não catalogada
  → Escolheu padrão diferente do projeto
  → Não seguiu convenção de nomenclatura

Ação no harness (SEMPRE — é um gap de guide):
  → Identificar qual skill-file deveria ter orientado o agente
  → Propor adição ao skill-file:
     "Adicionar em skills/0X.md → seção Anti-Alucinação:
      [✅ NOVO] Antes de {{ACAO}}, verificar {{CONDICAO}}"
```

### Categoria D — Gap de Sensor (feedback não detectou)

```
Sintoma: problema chegou ao usuário que o harness deveria ter detectado

Exemplos:
  → Violação de boundary chegou ao review sem ser detectada
  → Secret foi commitado (hook falhou)
  → Boundary entre módulos foi violado silenciosamente

Ação no harness (SEMPRE — é um gap de sensor):
  → Identificar qual sensor deveria ter detectado
  → Se sensor computacional: fortalecer a regra ou adicionar novo sensor
    Exemplos: nova ArchUnit rule, nova regex no safety_validator
  → Se sensor inferencial: adicionar ao checklist do 07-review.md
  → Registrar como Categoria D em lessons.md

  Perguntar ao usuário:
  "Este problema chegou ao review sem ser detectado automaticamente.
   Quer que eu configure um sensor para detectar isso mais cedo?
   [A] Sim — proponho a configuração agora
   [B] Registrar no harness backlog — implementar depois"
```

---

## ◈ TEMPLATE DE REGISTRO EM LESSONS.MD

```markdown
### ❌ Erro Resolvido — {{DATA}} — {{FEATURE_SLUG}}

- **Sintoma:** {{MENSAGEM_DE_ERRO_RESUMIDA}}
- **Categoria:** A / B / C / D / E
- **Causa-raiz:** {{CAUSA_REAL}}
- **Regra HES violada?** {{SIM/NÃO}} → {{QUAL}}
- **Correção aplicada:** {{O_QUE_FOI_FEITO}}
- **Gap de harness?** {{SIM/NÃO}}
  - Tipo: Guide (C) / Sensor (D) / Regra (A)
  - Ação no harness: {{O_QUE_MELHORAR}}
- **Ocorrência anterior?** {{SIM → PROMOVER AO SKILL-FILE / NÃO → 1ª vez}}
```

---

▶ PRÓXIMA AÇÃO — RETORNAR AO PIPELINE

```
Após resolução do erro:

  [A] "erro resolvido, build verde"
      → Retorno ao skill-file da fase atual: skills/{{FASE_ATUAL}}.md

  [B] "erro persiste: [nova mensagem]"
      → Continuo o diagnóstico com o novo contexto

  [C] "quero configurar um sensor para evitar isso"
      → Carrego skills/harness-health.md → seção de proposta de sensor

  [D] "precisei mudar a spec/design por causa do erro"
      → Registramos como ADR ou nota no documento afetado
         e atualizamos os testes antes de reimplementar

💡 Dica (Fowler): "Whenever an issue happens multiple times, the feedforward
   and feedback controls should be improved to make the issue less probable."
   Todo erro recorrente é uma oportunidade de melhoria sistêmica do harness.
```
