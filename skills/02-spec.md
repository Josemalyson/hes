# HES Skill — 02: Spec (BDD + Contrato de API)

> Skill carregada quando: feature.estado = SPEC
> Pré-condição: `01-discovery.md` aprovado pelo usuário.

---

## ◈ CONTEXTO A CARREGAR ANTES DE AGIR

```
1. Ler .hes/specs/{{feature}}/01-discovery.md integralmente
2. Identificar: todas as RN-xx, UC-xx, integrações, critério de aceite
3. Verificar se existe 02-spec.md (retomada de sessão)
4. Verificar .hes/tasks/lessons.md para lições sobre especificação
```

---

## ◈ REGRA DE OURO DA SPEC

> Cada cenário BDD deve ser rastreável a uma RN ou UC do discovery.
> Cada RN deve ter ao menos 1 cenário BDD que a valide.
> Mensagens de erro devem ser ESPECÍFICAS — nunca genéricas.

---

## ◈ PASSO 1 — GERAR `.hes/specs/{{FEATURE_SLUG}}/02-spec.md`

```markdown
# Especificação — {{NOME_FEATURE}}

Data: {{DATA_ATUAL}} | Versão: 1.0
Derivado de: 01-discovery.md | Feature: {{FEATURE_SLUG}}

---

## Cenários BDD

Feature: {{NOME_FEATURE}}
  Como {{PERSONA}}
  Quero {{ACAO}}
  Para {{RESULTADO_DE_NEGOCIO}}

  # ─── Caminho Feliz ───────────────────────────────────────

  Scenario: {{NOME_CENARIO_PRINCIPAL}}
    Given {{PRE_CONDICAO_ESPECIFICA}}
    When {{ACAO_DO_USUARIO_OU_SISTEMA}}
    Then {{RESULTADO_ESPERADO}}
    And {{VALIDACAO_ADICIONAL_SE_HOUVER}}
    # Cobre: UC-01, RN-01

  # ─── Validações de Entrada ────────────────────────────────

  Scenario: campo obrigatório ausente — {{CAMPO}}
    Given {{PRE_CONDICAO}}
    When a requisição é enviada sem o campo "{{CAMPO}}"
    Then o sistema retorna HTTP 400
    And o corpo contém {"error": "{{CAMPO}} é obrigatório"}
    # Cobre: RN-0x

  Scenario: formato inválido — {{CAMPO}}
    Given {{PRE_CONDICAO}}
    When o campo "{{CAMPO}}" contém "{{VALOR_INVALIDO}}"
    Then o sistema retorna HTTP 422
    And o corpo contém {"error": "{{CAMPO}} deve ser {{FORMATO_ESPERADO}}"}

  # ─── Regras de Negócio ────────────────────────────────────

  Scenario: violação de RN-01 — {{NOME_DA_REGRA}}
    Given {{PRE_CONDICAO_QUE_VIOLA_RN}}
    When {{ACAO}}
    Then o sistema retorna HTTP {{STATUS_CODE}}
    And o corpo contém {"error": "{{MENSAGEM_ESPECIFICA_DA_RN}}"}
    # Cobre: RN-01

  # ─── Casos de Borda ───────────────────────────────────────

  Scenario: {{CASO_DE_BORDA_IDENTIFICADO_NO_DISCOVERY}}
    Given {{PRE_CONDICAO}}
    When {{ACAO}}
    Then {{RESULTADO}}
    # Cobre: RN-0x

---

## Contrato de API

### {{METODO_HTTP}} {{ROTA}}

**Headers obrigatórios:**
```
Authorization: Bearer {{TOKEN}}
Content-Type: application/json
```

**Request Body:**
```json
{
  "{{campo_1}}": "{{tipo}} — {{descricao}} — {{obrigatorio|opcional}}",
  "{{campo_2}}": "{{tipo}} — {{descricao}} — {{obrigatorio|opcional}}"
}
```

**Response 200/201:**
```json
{
  "{{campo}}": "{{tipo}} — {{descricao}}"
}
```

**Mapa de Erros:**
| HTTP | Código de Erro | Mensagem ao Cliente | Quando Ocorre |
|------|---------------|---------------------|---------------|
| 400  | MISSING_FIELD  | "{{campo}} é obrigatório" | Campo obrigatório ausente |
| 422  | INVALID_FORMAT | "{{campo}} deve ser {{formato}}" | Formato inválido |
| 409  | ALREADY_EXISTS | "{{entidade}} já existe" | Duplicidade |
| 404  | NOT_FOUND      | "{{entidade}} não encontrada" | Recurso inexistente |
| 403  | FORBIDDEN      | "Sem permissão para {{acao}}" | Autorização negada |
| 500  | INTERNAL_ERROR | "Erro interno. Contate o suporte." | Exceção não tratada |

---

## Modelo de Domínio

### Entidade: {{NOME_ENTIDADE}}
| Campo | Tipo | Obrigatório | Regra de Validação | RN |
|-------|------|------------|-------------------|-----|
| id | UUID | Sim | Auto-gerado | — |
| {{campo}} | {{tipo}} | {{sim/não}} | {{regra}} | RN-0x |
| created_at | ISO 8601 | Sim | Auto-gerado | — |
| updated_at | ISO 8601 | Sim | Auto-gerado | — |

---

## Rastreabilidade: Cenários × Regras de Negócio

| Regra de Negócio | Cenário(s) que cobrem | Status |
|------------------|----------------------|--------|
| RN-01 — {{REGRA}} | Scenario: {{nome}} | ✅ Coberto |
| RN-02 — {{REGRA}} | Scenario: {{nome}} | ✅ Coberto |

> Regras sem cobertura = spec incompleta. Não avançar sem cobertura 100%.

---

## Aprovação
- [ ] Todos os UC e RN do discovery têm cobertura de cenário?
- [ ] Mensagens de erro são específicas (não genéricas)?
- [ ] Contrato de API cobre todos os campos da entidade?
- [ ] Aprovado pelo usuário para avançar à Etapa 3 (DESIGN)
```

---

## ◈ PASSO 2 — ATUALIZAR ESTADO

### `.hes/state/current.json`: alterar `"{{FEATURE}}": "SPEC"`

### `.hes/state/events.log`:

```json
{
  "timestamp": "{{DATA_ATUAL_ISO}}",
  "feature": "{{FEATURE_SLUG}}",
  "from": "DISCOVERY",
  "to": "SPEC",
  "agent": "hes-v3",
  "metadata": {
    "artifacts": ["02-spec.md"],
    "scenarios_count": {{N}},
    "rn_coverage": "100%"
  }
}
```

---

▶ PRÓXIMA AÇÃO — APROVAÇÃO DA SPEC

```
📐 Spec gerada: .hes/specs/{{FEATURE_SLUG}}/02-spec.md

Valide especialmente:
  • Cada RN do discovery tem ao menos 1 cenário BDD?
  • As mensagens de erro são específicas (não "Erro inválido")?
  • O contrato de API cobre todos os campos da entidade?

  [A] "aprovar spec"
      → Gero o Design e o ADR (skills/03-design.md)

  [B] "ajustar [o quê]"
      → Corrijo e reapresento

  [C] "faltou o cenário de [situação]"
      → Adiciono e reapresento com rastreabilidade atualizada

📄 Skill-file próximo: skills/03-design.md
💡 Dica: as mensagens de erro da spec viram strings literais nos testes.
   Qualquer mudança depois do RED exige reescrever os testes.
```
