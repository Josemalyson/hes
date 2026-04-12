# HES Skill — 01: Discovery

> Skill carregada quando: feature.estado = DISCOVERY
> Pré-condição: `.hes/state/current.json` existe com active_feature definida.

---

## ◈ CONTEXTO A CARREGAR ANTES DE AGIR

```
1. Ler .hes/state/current.json → obter active_feature
2. Verificar se existe .hes/domains/{{domain}}/context.md → se sim, ler
3. Verificar se existe .hes/tasks/lessons.md → checar lições relevantes
4. Verificar se existe .hes/specs/{{feature}}/01-discovery.md
   → Se existe: retomar e apresentar ao usuário para revisão
   → Se não existe: iniciar discovery do zero
```

---

## ◈ PASSO 1 — IDENTIFICAR FEATURE

Se chamado via `/hes start <feature>`:
- Extrair o nome da feature do comando
- Criar slug: `{{nome-em-kebab-case}}`
- Criar diretório: `.hes/specs/{{feature-slug}}/`

Se chamado sem nome de feature:
```
Qual é a feature que você quer desenvolver?
(Ex: autenticação JWT, endpoint de pagamento PIX, módulo de relatórios)
```

---

## ◈ PASSO 2 — PERGUNTAS DE DISCOVERY (máximo 6)

```
🔍 Discovery — {{NOME_FEATURE}}

Para especificar corretamente, preciso entender:

1. Quem usa esta feature? (persona/papel do usuário)
2. Qual problema ela resolve? (em 1–2 frases, linguagem de negócio)
3. Quais são as regras de negócio não-óbvias?
   (restrições, limites, exceções, casos especiais)
4. O que define "sucesso" para esta feature?
   (critério de aceite em linguagem de negócio)
5. Existem integrações externas envolvidas?
   (APIs de terceiros, sistemas legados, filas, eventos)
6. Há restrições técnicas ou de prazo que devo saber?
```

**Anti-alucinação:** Não assuma nenhuma regra de negócio.
Se a resposta for ambígua, peça esclarecimento antes de prosseguir.

---

## ◈ PASSO 3 — GERAR `.hes/specs/{{FEATURE_SLUG}}/01-discovery.md`

```markdown
# Discovery — {{NOME_FEATURE}}

Data: {{DATA_ATUAL}} | Versão: 1.0 | Status: RASCUNHO
Feature: {{FEATURE_SLUG}} | Domínio: {{DOMINIO_SE_APLICAVEL}}

---

## Contexto
{{PROBLEMA_EM_LINGUAGEM_DE_NEGOCIO}}

## Stakeholders
| Persona | Papel | Interesse Principal |
|---------|-------|-------------------|
| {{PERSONA_1}} | {{PAPEL}} | {{INTERESSE}} |

## Casos de Uso
| ID   | Nome | Ator | Ação | Resultado Esperado |
|------|------|------|------|--------------------|
| UC-01 | {{NOME_CASO_DE_USO}} | {{PERSONA}} | {{ACAO}} | {{RESULTADO}} |

## Regras de Negócio
| ID    | Regra | Fonte | Verificável? |
|-------|-------|-------|-------------|
| RN-01 | {{REGRA_EXPLICITA}} | Usuário | Sim |

> ⚠️ Toda regra vem do usuário. Nunca inventar regras de negócio.

## Integrações Externas
| Sistema | Protocolo | Direção | Contrato Formal? |
|---------|-----------|---------|----------------|
| {{SISTEMA}} | REST/gRPC/Event | Entrada/Saída | Sim/Não |

## Restrições
- Técnicas: {{RESTRICOES_TECNICAS_OU_NENHUMA}}
- Negócio: {{RESTRICOES_NEGOCIO_OU_NENHUMA}}
- Prazo: {{PRAZO_SE_INFORMADO}}

## Critério de Aceite de Negócio
{{O_QUE_DEFINE_SUCESSO_EM_LINGUAGEM_DE_NEGOCIO}}

## Perguntas em Aberto
- [ ] {{PERGUNTA_SE_HOUVER — ou "Nenhuma" se tudo foi esclarecido}}

## Aprovação
- [ ] Aprovado pelo usuário para avançar à Etapa 2 (SPEC)
```

---

## ◈ PASSO 4 — ATUALIZAR ESTADO

### Atualizar `.hes/state/current.json`:

```json
{
  ...
  "active_feature": "{{FEATURE_SLUG}}",
  "features": {
    "{{FEATURE_SLUG}}": "DISCOVERY"
  },
  "last_updated": "{{DATA_ATUAL_ISO}}"
}
```

### Registrar evento em `.hes/state/events.log`:

```json
{
  "timestamp": "{{DATA_ATUAL_ISO}}",
  "feature": "{{FEATURE_SLUG}}",
  "from": "ZERO",
  "to": "DISCOVERY",
  "agent": "hes-v3",
  "metadata": {
    "artifacts": ["01-discovery.md"]
  }
}
```

---

▶ PRÓXIMA AÇÃO — APROVAÇÃO DO DISCOVERY

```
📋 Discovery gerado: .hes/specs/{{FEATURE_SLUG}}/01-discovery.md

Revise o documento e:

  [A] "aprovar discovery" ou "ok"
      → Gero a SPEC com cenários BDD (skills/02-spec.md)

  [B] "ajustar [o quê]"
      → Corrijo e reapresento para aprovação

  [C] "tenho mais uma regra de negócio: [regra]"
      → Incorporo e reapresento

📄 Skill-file próximo: skills/02-spec.md
💡 Dica: preste atenção especial nas Regras de Negócio (RN-xx).
   Cada RN não capturada aqui vai exigir retrabalho na spec e nos testes.
```
