# HES Skill — Legacy: Inventário + Harnessability Assessment

> Skill carregada quando: estado global = LEGACY
> (projeto com `src/` existente mas sem estrutura `.hes/`)
>
> "Legacy teams, especially with applications that have accrued a lot of technical debt,
>  face the harder problem: the harness is most needed where it is hardest to build."
>  — Fowler, 2026

---

## ◈ PROTOCOLO

```
1. Anunciar o protocolo de inventário
2. Coletar informações do projeto
3. Avaliar harnessability (NOVO em v3.1)
4. Gerar inventário arquitetural
5. Gerar mapa de tech debt
6. Executar bootstrap (skills/00-bootstrap.md — passos 2 em diante)
7. Retornar para skills/01-discovery.md com contexto do inventário
```

---

## ◈ PASSO 1 — ANUNCIAR

```
🔍 HES detectou um projeto existente sem harness instalado.

Antes de qualquer modificação, vou:
  1. Inventariar o que existe
  2. Avaliar a harnessability do projeto
  3. Instalar o harness com guias e sensores adequados ao nível de maturidade

Isso protege o projeto de mudanças inconsistentes com o estado atual.
```

---

## ◈ PASSO 2 — COLETAR INFORMAÇÕES (máximo 5 perguntas)

```
Preciso entender o projeto existente:

1. Nome e propósito principal do projeto:
2. Stack principal? (linguagem, framework, banco, versões)
3. Quantos anos de existência (aproximadamente)?
4. Existe suite de testes? Se sim: cobertura estimada e framework?
5. Qual problema ou feature motivou você a chamar o HES agora?
```

---

## ◈ PASSO 3 — HARNESSABILITY ASSESSMENT (NOVO em v3.1)

> "Not every codebase is equally amenable to harnessing." — Fowler, 2026
> "Greenfield teams can bake harnessability in from day one.
>  Legacy teams face the harder problem." — Fowler, 2026

Avaliar o projeto nos seguintes eixos:

### 3a — Linguagem e Tipagem

```
[ ] Linguagem fortemente tipada? (Java, TypeScript, Kotlin, Go, C#)
    → Sim: type checker disponível como sensor computacional gratuito
    → Não: sensores de qualidade dependem mais de linters (menos confiáveis)

[ ] Framework com convenções fortes? (Spring Boot, NestJS, Django)
    → Sim: módulo boundaries mais fáceis de definir e verificar
    → Não: harnessability mais baixa — boundaries precisam ser explicitados
```

### 3b — Modularidade

```
[ ] O código tem package/módulo boundaries claros?
    → Sim: ArchUnit/dep-cruiser podem verificar automaticamente
    → Não: alto risco de regressão arquitetural silenciosa

[ ] Existe separação clara de responsabilidades (Controller/Service/Repo)?
    → Sim: fitness functions de camada são imediatamente aplicáveis
    → Não: refactoring de estrutura necessário antes de harnessing efetivo

[ ] Há acoplamento circular entre módulos?
    → Execute: mvn dependency:analyze / npx madge --circular src/
    → Sim → risco alto, priorizar como tech debt crítico
```

### 3c — Testabilidade

```
[ ] O código tem injeção de dependência (DI)?
    → Sim: mocking facilitado, testes unitários viáveis
    → Não: difícil testar em isolamento — custo de testes alto

[ ] Existe suite de testes funcionando?
    → Sim: cobertura atual? framework?
    → Não: qualquer mudança é cega — prioridade máxima antes de features

[ ] Há objetos estáticos / singletons que dificultam testes?
    → Sim → harnessability baixa nessa área
```

### 3d — Score de Harnessability

```
Alto   → Tipagem forte + boundaries claros + DI + testes existentes
         → Harness completo pode ser instalado imediatamente

Médio  → Algumas características presentes mas não todas
         → Instalar harness incremental, começar pelos sensores mais simples

Baixo  → Sem tipagem forte OU sem testes OU acoplamento circular
         → Priorizar refactoring de harnessability ANTES de features novas
         → Instalar apenas git hooks e specs como primeiro passo
```

---

## ◈ PASSO 4 — GERAR `.hes/inventory/architecture.md`

```markdown
# Inventário Arquitetural — {{NOME_PROJETO}}

Data: {{DATA_ATUAL}} | Analista: HES Auto-Discovery

---

## Visão Geral

| Atributo | Valor |
|---------|-------|
| Tipo | Monolito / Microsserviço / Modular Monolith |
| Linguagem | {{LINGUAGEM}} + {{VERSAO}} |
| Framework | {{FRAMEWORK}} + {{VERSAO}} |
| Banco | {{BANCO}} |
| Idade estimada | {{ANOS}} anos |

## Harnessability Score (v3.1)

| Eixo | Score | Observação |
|------|-------|-----------|
| Tipagem | Alto/Médio/Baixo | |
| Modularidade | Alto/Médio/Baixo | |
| Testabilidade | Alto/Médio/Baixo | |
| **Score Geral** | **Alto/Médio/Baixo** | |

## Pontos de Entrada

| Tipo | Arquivo | Rota/Endpoint | Autenticação |
|------|---------|--------------|-------------|
| _a preencher_ | | | |

> Execute para identificar:
> Java:   `grep -r "@RestController\|@Controller" src/ --include="*.java" -l`
> Node:   `grep -r "router\.\|app\.\(get\|post\|put\|delete\)" src/ -l`
> Python: `grep -r "@app.route\|@router" src/ -l`

## Dependências Críticas

| Dependência | Versão Atual | Observação |
|-------------|-------------|-----------|
| _a preencher_ | | |

## Cobertura de Testes

| Métrica | Valor |
|---------|-------|
| Coverage estimado | {{X}}% |
| Framework de testes | |
| Testes unitários | Sim / Não |
| Testes de integração | Sim / Não |

## Módulos / Pacotes

| Módulo | Responsabilidade | Saúde | Harnessável? |
|--------|-----------------|-------|-------------|
| | | 🟢/🟡/🔴 | Sim/Não |

## Acoplamento Circular

[ ] Verificar: `mvn dependency:analyze` ou `npx madge --circular src/`
Resultado: {{NENHUM / LISTA_DE_CICLOS}}

## Riscos Identificados

- [ ] _a preencher após análise_
```

---

## ◈ PASSO 5 — GERAR `.hes/inventory/tech-debt.md`

```markdown
# Tech Debt — {{NOME_PROJETO}}

Data: {{DATA_ATUAL}}

---

## 🔴 CRÍTICO — bloqueia entrega ou causa risco em produção

| Débito | Localização | Impacto | Esforço | Estratégia |
|--------|------------|---------|---------|-----------|
| | | | P/M/G | Hotfix/Refactor/Rewrite |

## 🟡 ALTO — degrada qualidade, dificulta manutenção

| Débito | Localização | Impacto | Esforço | Estratégia |
|--------|------------|---------|---------|-----------|

## 🟢 MÉDIO — melhoria desejável sem urgência

| Débito | Localização | Impacto | Esforço | Estratégia |
|--------|------------|---------|---------|-----------|

---

## Decisão de Estratégia por Módulo

| Módulo | Coverage | Harnessability | Estratégia Recomendada |
|--------|----------|---------------|----------------------|
| | | Alto/Médio/Baixo | Harnessing imediato / Refactor primeiro / Rewrite |
```

---

## ◈ PASSO 6 — INSTALAR HARNESS PROPORCIONAL AO SCORE

```
Harnessability ALTO:
  → Executar bootstrap completo (skills/00-bootstrap.md)
  → Propor ArchUnit/dep-cruiser imediatamente (architecture fitness)
  → Instalar coverage target ≥ 80%

Harnessability MÉDIO:
  → Executar bootstrap (git hooks + specs)
  → Adiar ArchUnit até módulo principal ter boundaries claros
  → Instalar linter + coverage target ≥ 60% (evoluir para 80%)

Harnessability BAIXO:
  → Instalar APENAS git hooks (safety_validator + commit_checker)
  → Criar specs para a feature motivadora ANTES de qualquer código
  → Planejar sprint de harnessability antes de features novas
  → Nota em CLAUDE.md: "Codebase com harnessability baixa — revisar manualmente antes de implementar"
```

---

▶ PRÓXIMA AÇÃO

```
🔍 Inventário + Harnessability Assessment concluídos.

Score: {{ALTO/MÉDIO/BAIXO}} → Harness {{COMPLETO/INCREMENTAL/MÍNIMO}}

  [A] "instalar o harness e iniciar discovery de [feature]"
      → Executo bootstrap proporcional ao score e inicio Discovery

  [B] "quero ver o tech debt antes de decidir"
      → Mostro .hes/inventory/tech-debt.md e discutimos prioridades

  [C] "preciso melhorar a harnessability primeiro"
      → Carrego skills/refactor.md para protocolo de harnessability

📄 Skill-file próximo: skills/01-discovery.md
💡 Dica (Fowler): harnessability baixa não impede harness — apenas muda o ponto de partida.
   Comece pelos sensores mais simples (git hooks + specs) e evolua incrementalmente.
```
