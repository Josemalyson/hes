# HES Skill — Refactor: Protocolo de Refactoring Guiado

> Skill invocada via: "quero refatorar [módulo]" ou `/hes refactor <módulo>`
> Objetivo: refactoring seguro, orientado a evidências, sem regressões.
>
> Princípio: refactoring não muda comportamento — muda estrutura.
> "Legacy teams face the harder problem: the harness is most needed
>  where it is hardest to build." — Fowler, 2026

---

## ◈ REGRA FUNDAMENTAL

> **Antes de qualquer refactoring: a suite de testes deve estar verde.**
> Sem testes cobrindo o módulo → escrever testes ANTES de refatorar.
> Refactoring sem testes é reescrita às cegas.

---

## ◈ CONTEXTO A CARREGAR ANTES DE AGIR

```
1. Ler .hes/state/current.json → verificar feature ativa (não interromper)
2. Identificar o módulo a refatorar (usuário fornece)
3. Listar arquivos do módulo: ls src/...{{modulo}}/
4. Verificar cobertura de testes atual do módulo
5. Ler .hes/tasks/lessons.md → padrões de erro neste módulo
6. Se harnessability é o objetivo → avaliar o score atual do módulo
```

---

## ◈ PASSO 1 — CLASSIFICAR O TIPO

```
Qual é o objetivo principal do refactoring?

  [A] Separação de responsabilidades (Service com lógica de Controller)
  [B] Eliminar duplicação de código (DRY)
  [C] Melhorar nomes (variáveis, métodos, classes)
  [D] Simplificar lógica complexa (CC > 10)
  [E] Extrair componente reutilizável
  [F] Melhorar tratamento de exceções
  [G] Remover código morto
  [H] Melhorar testabilidade (DI, interfaces) ← melhora harnessability
  [I] Melhorar harnessability (NOVO em v3.1)
      → Adicionar DI, clarificar boundaries, habilitar sensors
```

---

## ◈ PASSO 2 — GERAR SPEC DE REFACTORING

Criar `.hes/specs/refactor-{{MODULO}}-{{DATA}}/refactor-spec.md`:

```markdown
# Spec de Refactoring — {{MODULO}}

Data: {{DATA_ATUAL}} | Tipo: {{TIPO_SELECIONADO}}

---

## Estado Atual (AS-IS)

### Problemas identificados
| Problema | Localização | Impacto | Evidência |
|---------|------------|---------|----------|
| {{PROBLEMA}} | `src/{{arquivo}}:{{linha}}` | {{IMPACTO}} | {{SINTOMA}} |

### Métricas atuais
| Métrica | Valor Atual | Meta |
|---------|------------|------|
| Complexidade ciclomática | {{N}} | ≤ 10 |
| Linhas por método | {{N}} | ≤ 20 |
| Coverage do módulo | {{X}}% | ≥ 80% |
| Harnessability | Alto/Médio/Baixo | Alto |
| Boundaries verificáveis por ArchUnit? | Sim/Não | Sim |

---

## Estado Alvo (TO-BE)

### O que muda
| Antes | Depois | Justificativa |
|-------|--------|--------------|
| {{ESTRUTURA_ATUAL}} | {{ESTRUTURA_NOVA}} | {{POR_QUE}} |

### O que NÃO muda
- Comportamento externo (contratos de API, respostas, status HTTP)
- Regras de negócio (RN-xx)
- Schema do banco

### Ganho de harnessability (se Tipo H ou I)
- Sensor habilitado: {{ArchUnit rule / linter / coverage}}
- Como: {{DI via construtor / interface extraída / boundary explícito}}

### Plano de execução (passos atômicos)
1. {{PASSO_1}} → Verificar: {{COMO_CONFIRMAR}}
2. {{PASSO_2}} → Verificar: {{COMO_CONFIRMAR}}

---

## Critério de Conclusão
- [ ] Todos os testes existentes passando após cada passo
- [ ] Nenhum novo comportamento introduzido
- [ ] Coverage mantido ou melhorado
- [ ] Harnessability aumentada (se objetivo era esse)
```

---

## ◈ PASSO 3 — PROTOCOLO DE EXECUÇÃO SEGURA

```
Antes de cada mudança:
  1. Confirmar: suite verde
  2. Checkpoint: git add -A && git commit -m "refactor({{modulo}}): checkpoint"
  3. Executar a mudança mínima
  4. Rodar sensor: se verde → prosseguir | se vermelho → reverter

Regras:
  ✅ Um tipo de mudança por vez
  ✅ Commits pequenos e frequentes
  ✅ Testes antes, durante e depois
  ❌ Nunca refatorar + adicionar feature no mesmo commit
  ❌ Nunca refatorar sem testes cobrindo
```

---

## ◈ PASSO 4 — RECEITAS POR TIPO

### A — Separação de Responsabilidades

```
1. Identificar o trecho fora do lugar
2. Criar método privado com nome descritivo (sem mover ainda)
3. Extrair para a classe correta
4. Atualizar chamadas → rodar testes
5. Remover o método original
```

### B — Eliminar Duplicação (DRY)

```
1. Identificar os 2+ trechos duplicados
2. Criar método compartilhado com nome que expressa o conceito
3. Substituir o primeiro uso → rodar testes
4. Substituir o segundo → rodar testes
5. Nunca criar abstração prematura (extrair só com 2+ usos reais)
```

### H — Melhorar Testabilidade (melhora harnessability)

```
Objetivo: remover impedimentos para mocking e sensors

Receita:
1. Identificar dependência que impede mock (new interno, static, singleton)
2. Extrair interface se não existir
3. Injetar via construtor (constructor injection)
4. Atualizar testes para usar mock da interface
5. Verificar: agora é possível adicionar ArchUnit rule para este componente?
```

### I — Melhorar Harnessability (NOVO em v3.1)

```
Objetivo: tornar o módulo governável por sensors computacionais

Receita:
1. Avaliar harnessability atual (Passo 3 do legacy.md como referência)
2. Identificar o impedimento principal:
   → Sem DI → aplicar receita H
   → Sem package boundaries claros → extrair pacotes
   → Sem tipagem → adicionar tipos (TypeScript, type hints Python)
   → Acoplamento circular → detectar e quebrar

3. Para acoplamento circular (Java):
   mvn dependency:analyze
   → Identificar o ciclo: A → B → A
   → Extrair interface em módulo separado
   → A e B dependem da interface, não um do outro

4. Para package boundaries (Java):
   → Criar pacote com responsabilidade clara
   → Mover classes para pacotes corretos
   → Adicionar ArchUnit rule para o novo boundary
   → Verificar: mvn test -Dtest=ArchitectureTest

5. Ao final: executar /hes harness para validar ganho de harnessability
```

### D — Simplificar Lógica Complexa (CC > 10)

```
Receitas:
  Early return:   if (!condition) throw/return — elimina else
  Guard clause:   validações no topo, lógica principal sem aninhamento
  Extração:       bloco 5+ linhas → método com nome descritivo
  Strategy:       múltiplos if/else por tipo → interface + implementações
```

---

## ◈ PASSO 5 — VERIFICAR GANHO DE HARNESSABILITY

Se refactoring era do tipo H ou I, verificar após conclusão:

```
[ ] DI via construtor implementada → mocking agora possível?
[ ] Package boundaries explícitos → ArchUnit rule aplicável?
[ ] Interface extraída → sensor computacional agora detecta violações?
[ ] Acoplamento circular removido → dep-cruiser sem circulares?
[ ] Coverage aumentou ou manteve ≥ 80%?

Se ganho confirmado → /hes harness para atualizar score do projeto
```

---

## ◈ PASSO 6 — CHECKLIST FINAL

```
[ ] Todos os testes existentes passando?
[ ] Coverage mantido ou melhorado?
[ ] Nenhum comportamento externo alterado?
[ ] Métricas-alvo atingidas?
[ ] Commits atômicos com mensagens descritivas?
[ ] Harnessability melhorada (se objetivo)?
```

---

## ◈ REGISTRAR EM LESSONS.MD

```markdown
## Refactoring: {{MODULO}} — {{DATA}}

- Tipo: {{TIPO}}
- Problema resolvido: {{DESCRICAO}}
- Técnica: {{TECNICA}}
- Resultado: {{METRICA_ANTES}} → {{METRICA_DEPOIS}}
- Ganho de harnessability: {{SIM/NÃO}} — {{DESCRICAO}}
- Sensor habilitado: {{ArchUnit rule / linter / coverage}}
- Tempo gasto: {{ESTIMATIVA}}
```

---

▶ PRÓXIMA AÇÃO

```
🔧 Refactoring de {{MODULO}} concluído.

  [A] "continuar feature [nome]"
      → Retorno ao skill-file da feature ativa

  [B] "/hes harness"
      → Diagnóstico do ganho de harnessability após o refactoring

  [C] "refatorar outro módulo: [nome]"
      → Inicio novo protocolo

  [D] "quero adicionar testes antes de refatorar"
      → Carrego skills/05-tests.md para escrever testes primeiro

💡 Dica (Fowler): "Greenfield teams can bake harnessability in from day one.
   Legacy teams face the harder problem."
   Refactoring de harnessability (Tipo I) é o investimento de maior ROI
   em projetos legados — cada melhoria habilita sensors que evitam
   regressões futuras.
```
