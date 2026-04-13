# HES Skill — Agent Delegation

> Skill invocada pelo orquestrador (SKILL.md) quando precisa delegar para agentes especializados.
> Objetivo: padrão de delegação multi-agent, sub-agent spawning, dispatch protocol.
> Referência: HES v3.2 Agent Registry (.hes/agents/registry.json)

---

## ◈ MODELO DE DELEGAÇÃO

O orquestrador (harness-agent) NUNCA implementa — apenas dispatch, valida e avança estado.

```
ORQUESTRADOR (SKILL.md)
  → Lê current.json
  → Consulta registry.json
  → Identifica agente da fase atual
  → Carrega contexto necessário
  → Delega para skill-file do agente
  → Valida critérios de DONE
  → Avança estado + log evento
```

---

## ◈ DISPATCH PROTOCOL

```
PASSO 1 — LER ESTADO
  → .hes/state/current.json
  → Identificar: active_feature, features[feature], session.phase_lock

PASSO 2 — CONSULTAR REGISTRO
  → .hes/agents/registry.json
  → Encontrar agente onde: agents[X].phase == current_phase
     OU agents[X].type == "system" (para comandos como /hes report)

PASSO 3 — IDENTIFICAR AGENTE
  → Se feature = DISCOVERY → discovery-agent
  → Se feature = SPEC     → spec-agent
  → Se feature = DESIGN   → design-agent
  → Se feature = DATA     → data-agent
  → Se feature = RED      → test-agent
  → Se feature = GREEN    → impl-agent
  → Se feature = REVIEW   → review-agent
  → Se comando sistema   → session-manager | report-agent | etc.
  → Se não encontrado    → usar harness-agent (fallback) + warning

PASSO 4 — CARREGAR CONTEXTO
  → Carregar APENAS os arquivos em agents[X].context_load
  → NÃO carregar skill-files de outras fases

PASSO 5 — DELEGAR
  → Carregar skill-file correspondente
  → Seguir instruções do skill-file
  → NÃO tomar ações além do que o skill-file especifica

PASSO 6 — VALIDAR
  → Verificar critérios de DONE da fase
  → Se NÃO satisfeito → permanecer na fase atual

PASSO 7 — AVANÇAR
  → Atualizar current.json: features[feature] = next_phase
  → Registrar evento em events.log
  → Anunciar próxima fase + próximo agente
```

---

## ◈ SUB-AGENT SPAWNING

Sub-agents são agentes filhos executados dentro do contexto de um agente pai.

### Sub-Agent Registry (em registry.json)

```json
{
  "sub_agents": {
    "test-runner": {
      "parent": "impl-agent",
      "trigger": "after code change",
      "scope": ["tests/", "build output"]
    },
    "linter": {
      "parent": "impl-agent",
      "trigger": "before commit",
      "scope": ["*.java", "*.ts", "*.py"]
    },
    "arch-check": {
      "parent": "impl-agent",
      "trigger": "before commit",
      "scope": ["architecture rules"]
    }
  }
}
```

### Sub-Agent Execution Protocol

```
Quando impl-agent gera código:

1. Spawn test-runner:
   → Executar testes da feature
   → Se falha → loop de correção (máx 3 iterações)
   → Se passa → prosseguir

2. Spawn linter:
   → Rodar linter no código gerado
   → Se violação → corrigir automaticamente
   → Se limpo → prosseguir

3. Spawn arch-check:
   → Validar boundaries arquiteturais
   → Se violação → BLOCKED + explicar violação
   → Se ok → prosseguir para commit

REGRAS:
- Sub-agents rodam SEQUENCIALMENTE (não concorrente)
- Máximo 3 iterações de self-refinement por sub-agent
- Se falhar após 3 tentativas → escalonar para usuário
```

### Sub-Agent Failure Escalation

```
⚠ SUB-AGENT FAILURE — {{SUB_AGENT_NAME}}

{{sub_agent}} failed after 3 self-refinement iterations.
Last error: {{ERROR_MESSAGE}}

Options:
  [A] Show me the error — I'll fix manually
  [B] Skip this check (NOT recommended)
  [C] Retry with different approach
```

---

## ◈ MULTI-FEATURE PARALLEL SUPPORT

Features diferentes podem ter agentes diferentes ativos simultaneamente via `/hes switch`:

```json
{
  "active_feature": "payment",
  "features": {
    "payment": "GREEN",    ← impl-agent ativo
    "auth": "DONE",
    "billing": "SPEC"      ← spec-agent ativo (quando switchado)
  }
}
```

### `/hes switch <feature>` Protocol

```
1. Salvar checkpoint da feature atual (opcional mas recomendado)
2. Atualizar current.json: active_feature = <feature>
3. Verificar dependências em dependency_graph
   → Se dependência não-DONE → warning + suger mudar para dependência
4. Carregar agente da nova fase
5. Anunciar: "Switched to {{feature}}. Phase: {{phase}}. Agent: {{agent}}"
```

---

## ◈ CUSTOM AGENTS

Usuários podem estender o sistema com agentes customizados.

### Registry Entry

Adicionar em `.hes/agents/registry.json`:

```json
{
  "custom_agents": {
    "meu-agente": {
      "description": "Descrição do que o agente faz",
      "type": "custom",
      "triggers": ["/hes run meu-agente", "evento automático"],
      "context_load": ["skills/custom/meu-agente.md"],
      "output": ".hes/tasks/meu-agente-output.md"
    }
  }
}
```

### Criação de Custom Agent

1. Adicionar entrada em `custom_agents` no registry
2. Criar `skills/custom/<agent-name>.md` com definição do comportamento
3. Disparar via `/hes run <agent-name>` ou dispatch automático do agente pai

### Exemplo: Graphify Agent

```json
{
  "custom_agents": {
    "graphify-agent": {
      "description": "Analyzes dependency graphs, suggests module boundaries",
      "reference": "https://github.com/safishamsi/graphify",
      "type": "custom",
      "triggers": ["/hes analyze", "design-agent requests analysis"],
      "context_load": ["skills/custom/graphify-agent.md"],
      "output": ".hes/domains/{{domain}}/analysis.md"
    }
  }
}
```

---

## ◈ ERROR HANDLING

### Agent Not Found

```
⚠ AGENT NOT FOUND

Phase: {{PHASE}}
Expected agent: {{AGENT_NAME}}
Status: Not found in registry

Fallback: Using harness-agent (default orchestrator)

  [A] Proceed with harness-agent
  [B] Register agent in .hes/agents/registry.json
```

### Context Load Failure

```
⚠ CONTEXT LOAD ERROR

Agent "{{agent_name}}" requires: {{missing_file}}
Status: File not found

  [A] Skip missing file — load what's available
  [B] Create missing file now
  [C] Abort and fix registry
```

---

▶ PRÓXIMA AÇÃO — DELEGAÇÃO CONCLUÍDA

```
Agent delegation handled.

  [A] "delegar para próximo agente"
      → Executar DISPATCH PROTOCOL → avançar para próxima fase

  [B] "spawn sub-agent {{nome}}"
      → Executar Sub-Agent Execution Protocol

  [C] "switch para feature {{nome}}"
      → Executar /hes switch protocol

  [D] "adicionar custom agent"
      → Seguir Custom Agents creation flow

📄 Skill-file: skills/agent-delegation.md (você está aqui)
💡 Dica: cada agente carrega APENAS seu contexto necessário.
   Isso mantém a sessão limpa e focada na tarefa atual.
```
