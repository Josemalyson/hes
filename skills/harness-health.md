# HES Skill — Harness Health

> Skill invocada via: `/hes harness`
> Objetivo: diagnosticar a cobertura do harness nas 3 dimensões de regulação (Fowler, 2026).
> Quando usar: quando o time percebe degradação de qualidade, aumento de retrabalho,
> ou simplesmente ao iniciar um novo ciclo de melhoria do harness.

---

## ◈ MODELO DE REFERÊNCIA (Fowler, 2026)

Um harness bem construído combina:

```
GUIDES (feedforward)          SENSORS (feedback)
  Inferencial                   Inferencial
    → Skill-files                 → Self-refinement loop
    → Specs (discovery/spec)      → Review checklist (07-review.md)
    → CLAUDE.md / domain context  → AI code review
  Computacional                 Computacional
    → Manifesto de deps (pom.xml)  → Git hooks (pre-commit, commit-msg)
    → Bootstrap templates          → Build + coverage report
    → Codemods                     → Linters, ArchUnit, dep-cruiser

DIMENSÕES DE REGULAÇÃO:
  Maintainability   → qualidade interna do código
  Architecture Fit  → fitness functions, module boundaries, drift
  Behaviour         → specs BDD + suite de testes como sensor primário
```

---

## ◈ PASSO 1 — INVENTARIAR GUIDES EXISTENTES

```
Inferencial:
  [ ] SKILL.md existe e está atualizado (version = {{VERSAO_ATUAL}})
  [ ] skills/00-bootstrap.md ~ skills/07-review.md todos presentes
  [ ] .claude/CLAUDE.md instrui o agente a ler SKILL.md primeiro
  [ ] .hes/domains/*/context.md existe para cada domínio declarado
  [ ] Specs aprovadas existem para todas as features DONE (.hes/specs/*/02-spec.md)
  [ ] ADRs gerados para decisões arquiteturais (.hes/decisions/ADR-*.md)

Computacional:
  [ ] pom.xml / package.json / pyproject.toml presente e versionado
  [ ] scripts/hooks/install.sh presente
  [ ] Fitness functions definidas em .hes/domains/*/fitness/ (se domínios existem)
```

**Score de Guides:** {{N_OK}} / {{N_TOTAL}}

---

## ◈ PASSO 2 — INVENTARIAR SENSORS EXISTENTES

```
Inferencial:
  [ ] Self-refinement loop documentado em 05-tests.md e 06-implementation.md
  [ ] Review checklist em 07-review.md cobre as 5 dimensões (spec, qualidade, segurança, obs, arquitetura)
  [ ] Lessons.md atualizado com lições das últimas sessões

Computacional — Corretude:
  [ ] pre-commit hook (safety_validator.py) instalado e funcionando
  [ ] commit-msg hook (sdd_commit_checker.py) instalado e funcionando
  [ ] Suite de testes com coverage ≥ 80% (verificar no último build)

Computacional — Qualidade (NOVO em v3.1):
  [ ] Linter configurado (Checkstyle/PMD/ESLint/flake8/ruff)
  [ ] Complexity check configurado (cyclomatic complexity ≤ 10 por método)
  [ ] Dependency scanner ativo (OWASP dep-check / npm audit / safety)
  [ ] Dead code detector configurado (opcional mas recomendado)

Computacional — Architecture Fitness (NOVO em v3.1):
  [ ] ArchUnit (Java) / dep-cruiser (Node) / import-linter (Python) configurado
  [ ] Regras de módulo definidas (ex: Controller não depende de Repository)
  [ ] Pipeline CI tem etapa de architecture check
```

**Score de Sensors:** {{N_OK}} / {{N_TOTAL}}

---

## ◈ PASSO 3 — AVALIAR AS 3 DIMENSÕES DE REGULAÇÃO

### Dimensão 1 — Maintainability Harness

```
Objetivo: garantir qualidade interna do código gerado pelo agente.

Guides ativos:
  [✅/❌] CLAUDE.md com regras de qualidade (sem número mágico, SRP, etc.)
  [✅/❌] Skill-files com anti-alucinação checklist

Sensors ativos:
  [✅/❌] Coverage ≥ 80% (sensor computacional)
  [✅/❌] Linter com regras de estilo (computacional)
  [✅/❌] Complexity check (computacional)
  [✅/❌] Review checklist — Dimensão "Qualidade do Código" (inferencial)

Gaps identificados:
  → {{LISTA_DE_GAPS_OU_NENHUM}}

Diagnóstico: 🟢 Coberto / 🟡 Parcial / 🔴 Descoberto
```

### Dimensão 2 — Architecture Fitness Harness

```
Objetivo: garantir que o agente não viola boundaries arquiteturais com o tempo.

Guides ativos:
  [✅/❌] ADRs documentando decisões de arquitetura
  [✅/❌] Domain context.md com bounded contexts definidos
  [✅/❌] Design (03-design.md) com fluxo e responsabilidades explícitos

Sensors ativos:
  [✅/❌] ArchUnit / dep-cruiser / import-linter (computacional — NOVO)
  [✅/❌] Review checklist — Dimensão "Design e Arquitetura" (inferencial)
  [✅/❌] Drift detection via /hes report (offline)

Gaps identificados:
  → {{LISTA_DE_GAPS_OU_NENHUM}}

Diagnóstico: 🟢 / 🟡 / 🔴

Se 🔴 → propor configuração de fitness function para o projeto
```

### Dimensão 3 — Behaviour Harness

```
Objetivo: garantir que o código faz o que a spec diz que deveria fazer.

Guides ativos:
  [✅/❌] Discovery (01) com RN explícitas
  [✅/❌] Spec (02) com cenários BDD e rastreabilidade RN → cenário
  [✅/❌] Cobertura de cenários: cada RN tem ≥ 1 cenário?

Sensors ativos:
  [✅/❌] Suite de testes unitários cobrindo regras de negócio (computacional)
  [✅/❌] Suite de testes de integração cobrindo fluxo HTTP → DB (computacional)
  [✅/❌] Mensagens de erro nos testes = mensagens na spec (rastreabilidade)

Gaps identificados:
  → {{LISTA_DE_GAPS_OU_NENHUM}}

ATENÇÃO (Fowler, 2026): "Esta é a dimensão mais difícil.
Cobertura de testes mede quantidade, não qualidade.
Tests gerados pelo agente não substituem a validação humana do comportamento."

Diagnóstico: 🟢 / 🟡 / 🔴
```

---

## ◈ PASSO 4 — GERAR RELATÓRIO DE SAÚDE

```markdown
# Harness Health Report — {{NOME_PROJETO}}

Data: {{DATA_ATUAL}} | HES v3.1

## Scores

| Dimensão | Score | Diagnóstico |
|---------|-------|------------|
| Guides (total) | {{N}}/{{N}} | 🟢/🟡/🔴 |
| Sensors (total) | {{N}}/{{N}} | 🟢/🟡/🔴 |
| Maintainability | {{N}}/{{N}} | 🟢/🟡/🔴 |
| Architecture Fit | {{N}}/{{N}} | 🟢/🟡/🔴 |
| Behaviour | {{N}}/{{N}} | 🟢/🟡/🔴 |

## Gaps Prioritários

### 🔴 Crítico (sensor ausente — risco de regressão silenciosa)
1. {{GAP}} → Ação: {{COMO_RESOLVER}}

### 🟡 Atenção (guide incompleto — agente sem guia suficiente)
1. {{GAP}} → Ação: {{COMO_RESOLVER}}

## Próximas melhorias recomendadas (em ordem de impacto)

1. {{MELHORIA_1}} — Dimensão: {{QUAL}} — Esforço: {{P/M/G}}
2. {{MELHORIA_2}}
3. {{MELHORIA_3}}
```

---

## ◈ PASSO 5 — PROPOSTAS DE MELHORIA ESPECÍFICAS

### Se Architecture Fitness Harness está descoberto (Java/Spring Boot):

```
Proposta: adicionar ArchUnit ao projeto

1. Adicionar dependência em pom.xml:
   <dependency>
     <groupId>com.tngtech.archunit</groupId>
     <artifactId>archunit-junit5</artifactId>
     <version>{{VERSAO_ESTAVEL}}</version>
     <scope>test</scope>
   </dependency>

2. Criar: src/test/java/.../ArchitectureTest.java

   @AnalyzeClasses(packages = "{{BASE_PACKAGE}}")
   class ArchitectureTest {

     @ArchTest
     static final ArchRule controllers_nao_dependem_de_repositories =
       noClasses().that().resideInAPackage("..controller..")
         .should().dependOnClassesThat()
         .resideInAPackage("..repository..")
         .because("Controller não deve acessar dados diretamente — viola SRP");

     @ArchTest
     static final ArchRule services_nao_dependem_de_controllers =
       noClasses().that().resideInAPackage("..service..")
         .should().dependOnClassesThat()
         .resideInAPackage("..controller..");
   }

3. Adicionar em .hes/domains/{{domain}}/fitness/archunit-rules.md
```

### Se Architecture Fitness Harness está descoberto (Node.js):

```
Proposta: adicionar dep-cruiser

1. npm install --save-dev dependency-cruiser
2. npx depcruise --init
3. Configurar .dependency-cruiser.js com regras de module boundaries
4. Adicionar ao package.json:
   "check:arch": "depcruise --validate src"
5. Adicionar em scripts/hooks/ como sensor de CI
```

### Se Behaviour Harness tem gaps de rastreabilidade:

```
Proposta: adicionar rastreabilidade RN → Teste

Em cada arquivo de teste, adicionar comentário:
  // @covers RN-01: {{NOME_DA_REGRA}}
  // @scenario {{NOME_DO_CENARIO_BDD}}

Isso permite auditoria: toda RN da spec deve ter ao menos 1 @covers
```

### Se Continuous Drift está ausente:

```
Proposta: adicionar sensor de drift contínuo ao pipeline CI

Opções (escolher 1):
  Java: SonarQube com quality gate no PR
  Node: CodeClimate ou SonarCloud
  Python: Ruff + radon para complexidade

Configurar threshold:
  - Complexity: rejeitar se CC > 10
  - Coverage: rejeitar se < 80%
  - Duplicação: avisar se > 5%
```

---

## ◈ ATUALIZAR ESTADO

Registrar em events.log:

```json
{
  "timestamp": "{{DATA_ATUAL_ISO}}",
  "feature": "global",
  "from": "ACTIVE",
  "to": "HARNESS_HEALTH_CHECKED",
  "agent": "hes-v3.1",
  "metadata": {
    "guides_score": "{{N}}/{{N}}",
    "sensors_score": "{{N}}/{{N}}",
    "maintainability": "{{VERDE/AMARELO/VERMELHO}}",
    "architecture_fitness": "{{VERDE/AMARELO/VERMELHO}}",
    "behaviour": "{{VERDE/AMARELO/VERMELHO}}",
    "gaps_found": {{N}}
  }
}
```

---

▶ PRÓXIMA AÇÃO — APÓS DIAGNÓSTICO

```
🔍 Harness health avaliado.

  [A] "implementar [melhoria X]"
      → Executo os passos de configuração para aquela melhoria

  [B] "gerar o relatório completo em arquivo"
      → Salvo em .hes/tasks/harness-health-{{DATA}}.md

  [C] "continuar feature [nome]"
      → Retorno ao skill-file da feature ativa

  [D] "/hes report"
      → Relatório de ciclos + lições para fechar o loop de aprendizado

📄 Skill-file: skills/harness-health.md (você está aqui)
💡 Dica (Fowler): "Building this outer harness is emerging as an ongoing
   engineering practice, not a one-time configuration."
   O harness nunca está "pronto" — ele evolui com o projeto.
```
