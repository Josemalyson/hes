# HES Skill — 06: Implementation (Fase GREEN — TDD)

> Skill carregada quando: feature.estado = GREEN
> Pré-condição: testes escritos (RED) e confirmados falhando pelo motivo certo.
>
> Papel no harness: **Execução guiada pelo Behaviour + Maintainability Harness**
> O código produzido aqui é regulado pelos sensors: testes (behaviour),
> linter (maintainability) e ArchUnit/dep-cruiser (architecture fitness).
> "Keep quality left" — os sensors rodam durante e após cada mudança, não só no final.

---

## ◈ CONTEXTO A CARREGAR ANTES DE AGIR

```
1. Ler .hes/specs/{{feature}}/03-design.md → componentes a implementar
2. Ler .hes/specs/{{feature}}/02-spec.md   → regras de negócio (RN-xx)
3. Ler .hes/specs/{{feature}}/04-data.md   → DTOs e schema
4. Para CADA arquivo que será modificado → lê-lo integralmente primeiro
5. Verificar pom.xml / package.json → confirmar dependências
```

---

## ◈ ANTI-ALUCINAÇÃO — OBRIGATÓRIO ANTES DE QUALQUER CÓDIGO

```
[ ] Listei todas as classes/interfaces que serão criadas ou modificadas?
[ ] Para cada import: a classe existe no projeto? (não importar o que não existe)
[ ] Verifiquei pom.xml / package.json — as dependências estão lá?
[ ] Li o arquivo existente que será modificado (se aplicável)?
[ ] A implementação está limitada ao escopo da spec aprovada?
```

Se qualquer item estiver incerto → verificar antes de continuar.

---

## ◈ PRINCÍPIO DO GREEN: MÍNIMO VIÁVEL

> Implemente APENAS o mínimo para os testes passarem.
> Sem otimizações prematuras. Sem features extras. Sem "já que estou aqui".
> Código elegante é refactoring — não é Green.

---

## ◈ PASSO 1 — ORDEM DE IMPLEMENTAÇÃO

Implementar de dentro para fora (dependências primeiro):

```
1. Exception classes        (sem dependências)
2. Entidade / Model         (sem dependências)
3. Repository interface     (define o contrato)
4. DTOs (Request / Response)
5. Mapper (DTO ↔ Entidade)
6. Repository implementation (acesso a dados)
7. Service / UseCase        (regra de negócio)
8. Controller / Router      (entrada HTTP)
```

---

## ◈ PASSO 2 — REGRAS POR CAMADA

### Controller / Router

```
✅ Recebe request → valida → delega ao Service → retorna response
✅ Status HTTP = exatamente os definidos no 02-spec.md
✅ Sem lógica de negócio
❌ Sem acesso direto ao Repository
```

### Service / UseCase

```
✅ Implementa RN-xx com mensagens EXATAS da spec
✅ Lança exceções de domínio tipadas
✅ Sem conhecimento de HTTP
❌ Sem SQL direto
```

### Repository

```
✅ SQL parametrizado (zero concatenação de string)
✅ Sem lógica de negócio
❌ Sem chamadas a outros Services
```

---

## ◈ PASSO 3 — SENSOR LOOP (Fowler: "keep quality left")

Após cada componente implementado, rodar os sensors disponíveis:

```bash
# Sensor mais rápido primeiro (computacional)
# Java
mvn compile                     # type check — segundos
mvn test -Dtest={{NomeService}}Test   # testes unitários do componente

# Node
npx tsc --noEmit                # type check
npx jest {{nome-service}}.test  # testes do componente

# Python
mypy src/                       # type check
pytest tests/unit/{{feature}}/  # testes unitários
```

**Não aguardar a suite completa para descobrir erros de compilação.**
Sensors rápidos rodam a cada componente — sensors lentos (integração, ArchUnit) rodam ao final.

---

## ◈ PASSO 4 — SELF-REFINEMENT LOOP (máx. 5 tentativas)

```
Tentativa {{N}}/5:

1. Executar suite de testes
2. Analisar falhas:
   → Erro de compilação?      → Corrigir import/tipo
   → Assertion falhou?        → Verificar lógica vs spec (NÃO mudar o teste)
   → Exceção inesperada?      → Analisar stack trace completo
3. Fazer a correção mínima
4. Rodar sensor correspondente
5. Repetir

Após 5 tentativas sem passar:
  → Registrar em lessons.md (Categoria B — erro técnico recorrente)
  → Apresentar análise ao usuário
  → Carregar skills/error-recovery.md
```

**Regra de ouro:** Nunca ajustar o teste para fazer o código passar.
Se o teste falha e o código parece correto → o código está errado.

---

## ◈ PASSO 5 — CHECKLIST DE IMPLEMENTAÇÃO

```
[ ] Controller implementado (status HTTP corretos da spec)
[ ] Service com todas as RN-xx implementadas
[ ] Repository com queries parametrizadas
[ ] Mapper DTO ↔ Entidade funcionando
[ ] Exceções com mensagens EXATAS do 02-spec.md
[ ] Nenhum TODO / FIXME / HACK no código
[ ] Nenhum número mágico (constantes nomeadas)
[ ] Nenhum dado sensível logado
[ ] Logs estruturados com contexto (feature, operação, IDs)
[ ] Build verde: TODOS os testes passando
[ ] Coverage ≥ 80% no módulo novo
[ ] Linter sem erros (se configurado)
[ ] ArchUnit passando (se configurado)
```

---

## ◈ PASSO 6 — VALIDAÇÃO FINAL

```bash
# Java — suite completa + coverage + architecture fitness
mvn clean test jacoco:report
# → BUILD SUCCESS
# → target/site/jacoco/index.html: verificar coverage ≥ 80%
# → ArchitectureTest: verificar que boundaries não foram violados

# Node.js
npm test -- --coverage
# → All tests passed | Coverage ≥ 80%
# npm run check:arch (se dep-cruiser configurado)

# Python
pytest --cov=src --cov-report=term-missing -v
# → passed, 0 failed | TOTAL coverage ≥ 80%
```

---

## ◈ PASSO 7 — ATUALIZAR ESTADO

### `.hes/state/current.json`: `"{{FEATURE}}": "GREEN"`

### `.hes/state/events.log`:

```json
{
  "timestamp": "{{DATA_ATUAL_ISO}}",
  "feature": "{{FEATURE_SLUG}}",
  "from": "RED",
  "to": "GREEN",
  "agent": "hes-v3.1",
  "metadata": {
    "tests_passing": {{N}},
    "coverage": "{{X}}%",
    "archunit_passing": {{true/false}},
    "refinement_iterations": {{N}},
    "lessons_added": {{N}}
  }
}
```

---

▶ PRÓXIMA AÇÃO — REVIEW

```
🟢 Implementação concluída?

Confirme antes de avançar:
  1. Build verde (todos os testes passando)?
  2. Coverage ≥ 80%?
  3. Nenhum TODO/FIXME?
  4. ArchUnit passando (se configurado)?

  [A] "build verde, coverage ok"
      → Inicio o Review estruturado (skills/07-review.md)

  [B] "teste X falhando: [erro]"
      → Self-refinement tentativa {{N}} — analiso o problema

  [C] "coverage em {{X}}%"
      → Avaliamos se é aceitável ou adicionamos testes para os gaps

📄 Skill-file próximo: skills/07-review.md
💡 Dica: coverage mede quantidade de linhas executadas, não qualidade.
   Um teste sem assertions não protege nada.
   Prefira testes que falham quando a lógica está errada (sensor efetivo).
```
