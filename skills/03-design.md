# HES Skill — 03: Design + ADR

> Skill carregada quando: feature.estado = DESIGN
> Pré-condição: `02-spec.md` aprovado pelo usuário.
>
> Papel no harness: **Guide Inferencial (Architecture Fitness + Maintainability)**
> O design define os limites que os sensors computacionais irão verificar.
> Toda decisão de design determina a harnessability do módulo.

---

## ◈ CONTEXTO A CARREGAR ANTES DE AGIR

```
1. Ler .hes/specs/{{feature}}/02-spec.md integralmente
2. Ler .hes/state/current.json → domínio da feature
3. Se domínio existe → ler .hes/domains/{{domain}}/context.md
4. Se domínio existe → ler .hes/domains/{{domain}}/fitness/ (regras ativas)
5. Verificar src/ para manter consistência de padrões existentes:
   - Estrutura de pacotes atual
   - Padrões arquiteturais já adotados (Controller → Service → Repository)
   - Convenções de nomenclatura
6. Verificar pom.xml / package.json → libs disponíveis
```

**Anti-alucinação:** Nunca propor padrão ou biblioteca que não existe no projeto.
Sempre citar o arquivo `src/` de referência ao propor algo.

---

## ◈ PASSO 1 — GERAR `.hes/specs/{{FEATURE_SLUG}}/03-design.md`

```markdown
# Design — {{NOME_FEATURE}}

Data: {{DATA_ATUAL}} | Versão: 1.0
Derivado de: 02-spec.md | Feature: {{FEATURE_SLUG}}

---

## Componentes

| Componente | Tipo | Responsabilidade | Arquivo |
|-----------|------|-----------------|---------|
| {{NomeController}} | Controller | Receber request, validar entrada, delegar ao Service | `src/.../{{Arquivo}}` |
| {{NomeService}} | Service/UseCase | Regras de negócio (RN-xx), orquestração | `src/.../{{Arquivo}}` |
| {{NomeRepository}} | Repository | Acesso a dados — sem lógica de negócio | `src/.../{{Arquivo}}` |
| {{NomeRequestDTO}} | DTO (in) | Contrato de entrada, validações de campo | `src/.../{{Arquivo}}` |
| {{NomeResponseDTO}} | DTO (out) | Contrato de saída | `src/.../{{Arquivo}}` |
| {{NomeMapper}} | Mapper | Conversão DTO ↔ Entidade | `src/.../{{Arquivo}}` |
| {{NomeException}} | Exception | Exceções de domínio com mensagem da spec | `src/.../{{Arquivo}}` |

## Fluxo de Execução

```
HTTP Request
    │
    ▼
{{NomeController}}          [package: controller]
    │ valida {{NomeRequestDTO}}
    │ delega ao service
    ▼
{{NomeService}}             [package: service]
    │ aplica RN-01: {{regra}}
    │ aplica RN-02: {{regra}}
    │ lança {{NomeException}} se violação
    ▼
{{NomeRepository}}          [package: repository]
    │ query parametrizada — sem lógica de negócio
    ▼
  Database
    ▲ retorna entidade
{{NomeMapper}}
    │ converte entidade → {{NomeResponseDTO}}
    ▼
HTTP Response ({{STATUS_CODE}})
```

## Padrões Utilizados

| Padrão | Justificativa | Referência no Projeto |
|--------|--------------|----------------------|
| Repository | Separação de concerns, testabilidade | `src/.../ExistingRepo.java` |
| DTO/Mapper | Desacoplar domínio da API | `src/.../ExistingDTO.java` |
| {{OUTRO}} | {{JUSTIFICATIVA}} | `src/...` |

## Impacto em Módulos Existentes

| Módulo/Arquivo | Tipo de Impacto | Ação Necessária |
|----------------|----------------|----------------|
| {{modulo}} | Adição / Modificação / Sem impacto | {{o que fazer}} |

## Harnessability do Design (NOVO em v3.1)

> "Technology decisions and architecture choices determine how governable
>  the codebase will be." — Fowler, 2026

| Decisão de Design | Harnessability | Motivo |
|-------------------|---------------|--------|
| Package boundaries claros (controller/service/repository) | ✅ Alta | ArchUnit pode verificar automaticamente |
| DI via construtor (não new interno) | ✅ Alta | Mocking facilitado nos testes unitários |
| Exceções de domínio tipadas | ✅ Alta | Sensor de test pode verificar tipo + mensagem |
| {{OUTRA_DECISAO}} | ✅/⚠️ | {{MOTIVO}} |

## Sensors que Verificam Este Design

| Sensor | O que verifica | Quando roda |
|--------|---------------|------------|
| ArchUnit (se configurado) | Package boundaries, dependências unidirecionais | `mvn test` |
| Self-refinement loop | Implementação segue o fluxo definido aqui | Durante GREEN |
| Review Dimensão 5 | Design vs implementação | Fase REVIEW |

## Decisão Arquitetural
Ver: `.hes/decisions/ADR-{{NNN}}.md`

## Aprovação
- [ ] Componentes seguem padrões existentes no projeto?
- [ ] Fluxo cobre todos os cenários da spec?
- [ ] Decisões de design maximizam harnessability?
- [ ] Impacto em módulos existentes está mapeado?
- [ ] Aprovado para avançar à Etapa 4 (DATA)
```

---

## ◈ PASSO 2 — GERAR ADR

Determinar próximo número de ADR:
```bash
ls .hes/decisions/ADR-*.md 2>/dev/null | wc -l
# Próximo = count + 1, formato 3 dígitos: ADR-001
```

Gerar `.hes/decisions/ADR-{{NNN}}.md`:

```markdown
# ADR-{{NNN}} — {{TITULO_DA_DECISAO}}

Data: {{DATA_ATUAL}} | Status: Accepted | Feature: {{FEATURE_SLUG}}
Domínio: {{DOMINIO_SE_APLICAVEL}}

---

## Contexto

{{QUAL_PROBLEMA_PRECISAVA_SER_DECIDIDO}}
{{POR_QUE_ESTA_DECISAO_ERA_NECESSARIA_AGORA}}

## Força Motivadora

- {{DRIVER_1}} — ex: volume de leituras exige separação de queries
- {{DRIVER_2}} — ex: necessidade de auditoria de mudanças

## Impacto na Harnessability (NOVO em v3.1)

A decisão escolhida {{aumenta / mantém / reduz}} a harnessability porque:
- {{MOTIVO_DE_HARNESSABILITY}}
- Sensor impactado: {{ArchUnit rule / linter / coverage}} — {{como}}

## Opções Consideradas

### Opção A: {{NOME}}
- Prós: {{VANTAGENS}}
- Contras: {{DESVANTAGENS}}
- Harnessability: Alta / Média / Baixa

### Opção B: {{NOME}}
- Prós: {{VANTAGENS}}
- Contras: {{DESVANTAGENS}}
- Harnessability: Alta / Média / Baixa

## Decisão

**Escolhida: Opção {{X}} — {{NOME}}**
{{JUSTIFICATIVA_DIRETA}}

## Consequências

**Positivas:**
- {{GANHO_1}}

**Trade-offs aceitos:**
- {{CUSTO_ACEITAVEL}}

**Riscos e Mitigações:**
- {{RISCO}} → Mitigação: {{COMO}}

## Revisar se

{{TRIGGER — ex: "volume exceder X/s" ou "novo domínio precisar de isolamento"}}
```

---

## ◈ PASSO 3 — ATUALIZAR FITNESS/ (se domínio tem ArchUnit)

Se `.hes/domains/{{domain}}/fitness/` existe e a feature introduz novo boundary:

```
Verificar se o fluxo de execução define novos boundaries que devem ser capturados:
→ Nova regra de ArchUnit? → Adicionar em ArchitectureTest.java
→ Documentar em .hes/domains/{{domain}}/fitness/README.md
```

---

## ◈ PASSO 4 — ATUALIZAR ESTADO

### `.hes/state/current.json`: `"{{FEATURE}}": "DESIGN"`

### `.hes/state/events.log`:

```json
{
  "timestamp": "{{DATA_ATUAL_ISO}}",
  "feature": "{{FEATURE_SLUG}}",
  "from": "SPEC",
  "to": "DESIGN",
  "agent": "hes-v3.1",
  "metadata": {
    "artifacts": ["03-design.md", "ADR-{{NNN}}.md"],
    "harnessability": "{{ALTA/MEDIA/BAIXA}}",
    "archunit_updated": {{true/false}}
  }
}
```

---

▶ PRÓXIMA AÇÃO — APROVAÇÃO DO DESIGN

```
🏗  Design gerado:
    .hes/specs/{{FEATURE_SLUG}}/03-design.md
    .hes/decisions/ADR-{{NNN}}.md

Valide antes de aprovar:
  • Os componentes usam padrões já existentes no projeto?
  • O ADR explica por que as alternativas foram rejeitadas?
  • O fluxo de execução cobre todos os cenários BDD da spec?
  • As decisões de design maximizam harnessability?

  [A] "aprovar design"
      → Gero schema e migrations (skills/04-data.md)

  [B] "ajustar [o quê]"
      → Corrijo design e/ou ADR

  [C] "prefiro Opção B do ADR"
      → Atualizo a decisão e ajusto o design

📄 Skill-file próximo: skills/04-data.md
💡 Dica (Fowler): "Technology decisions determine how governable the codebase will be."
   DI via construtor, package boundaries claros e exceções tipadas são as 3 decisões
   que mais impactam a harnessability de um serviço Java/Spring Boot.
```
