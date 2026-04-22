# plan.md — HES Install Failure Analysis + Resolution

> Gerado em: 2026-04-22  
> Versão analisada: HES v3.5.0  
> Branch: fix/plan-md-install-failures

---

## 🎯 Objetivo

Documentar o que **falhou**, o que foi **resolvido diferente do plano**, e o que **ainda precisa ser corrigido**
no processo de instalação do HES — com verificação por CLI.

---

## 📊 Status por Item do Plan Original

### FASE 1 — Stabilization

#### 1.1 Remover conflito de skills (`.gemini/skills/hes` vs `.agents/skills/hes`)

| Status | Detalhe |
|--------|---------|
| ⚠️ PARCIALMENTE RESOLVIDO | `.gemini/skills/` existe no repo mas está vazio (sem `SKILL.md` rastreado). O conflito ocorre em runtime após `./setup --tools gemini`: cria `.gemini/skills/hes/SKILL.md` E `.agents/skills/hes/SKILL.md` com conteúdo idêntico. |

**Root cause confirmado**: `inst_gemini_p` usa `SKILL_SRC="$HES_DIR/.agents/skills/hes"` e copia para dois destinos.
O mesmo padrão acontece com OpenCode (`inst_opencode_p`) e Windsurf (`inst_windsurf_p`) — todos usam `.agents/skills/hes/`.

**Impacto por CLI**:

| CLI | Diretório próprio | Usa `.agents/` também? | Conflito potencial |
|-----|-------------------|------------------------|--------------------|
| Claude Code | `.claude/skills/hes/` | ❌ | ✅ Limpo |
| Codex CLI | — | `.agents/skills/hes/` | ✅ Limpo |
| Gemini CLI | `.gemini/skills/hes/` | `.agents/skills/hes/` | ⚠️ Duplicata |
| OpenCode | `.opencode/skills/hes/` | `.agents/skills/hes/` | ⚠️ Duplicata |
| Windsurf | — | `.agents/skills/hes/` | ✅ (single source) |
| Cursor | `.cursor/skills/hes/` | ❌ | ✅ Limpo |
| Kiro | `.kiro/skills/hes/` | ❌ | ✅ Limpo |
| GitHub Copilot | `.github/copilot-instructions.md` | ❌ | ✅ Limpo |

**Correção**: Mover `.gemini/skills/hes/SKILL.md` para ser gerenciado pelo setup (não pela cópia manual).
Adicionar validação no `setup` para evitar sobrescrever `.agents/` se já instalado por outro CLI.

---

#### 1.2 Validar carregamento da skill (`/skills list`)

| Status | Detalhe |
|--------|---------|
| ✅ RESOLVIDO (v3.5 design) | v3.5 não depende de `/skills list`. O LLM descobre a skill via contexto nativo de cada CLI (CLAUDE.md, AGENTS.md, `.cursor/rules/`, `.kiro/steering/`). |

---

### FASE 2 — State Reliability

#### 2.1 Corrigir `.gitignore`

| Status | Detalhe |
|--------|---------|
| ✅ RESOLVIDO | `.gitignore` atual ignora apenas os 3 arquivos de estado volátil (`current.json`, `events.log`, `session-checkpoint.json`). Não ignora `.hes/` inteiro. Correto. |

---

#### 2.2 Garantir acesso ao estado (sem `Shell cat`)

| Status | Detalhe |
|--------|---------|
| ✅ RESOLVIDO (v3.5 design) | SKILL.md v3.5 instrui o LLM a usar ferramentas nativas de filesystem (Read/Write/Edit). Fallback para Shell foi removido do protocolo. |

---

#### 2.3 Remover fallback inseguro (`Shell cat`)

| Status | Detalhe |
|--------|---------|
| ✅ RESOLVIDO | v3.5 introduz "LLM Execution Mandate" — LLM executa via tools nativas, não via Shell. |

---

#### 2.4 Corrigir estado inicial (ZERO → LEGACY)

| Status | Detalhe |
|--------|---------|
| ⚠️ RESOLVIDO DIFERENTE | O plano original propunha salvar `"phase":"LEGACY"` em `current.json`. v3.5 adotou uma abordagem melhor: **ORPHAN state** — quando `.hes/` existe mas `current.json` não existe (clone/repo corrompido), o LLM carrega `skills/legacy.md` automaticamente. LEGACY não é um valor de fase persistido — é um estado derivado. |

---

#### 2.5 `current.json` template incompleto — **NOVO FAILURE**

| Status | Detalhe |
|--------|---------|
| ❌ FALHA NÃO IDENTIFICADA NO PLANO ORIGINAL | O `setup` gera um `current.json` mínimo (4 campos). O SKILL.md v3.5 espera 15+ campos: `user_language`, `audience_mode`, `session`, `security`, `step_budget`, `token_tracking`, `model`, `stack`, `ide`, etc. |

**Template gerado pelo setup**:
```json
{"phase":"ZERO","active_feature":null,"features":{},"harness_version":"3.5.0"}
```

**Schema esperado pelo SKILL.md v3.5** (campos adicionais ausentes):
```json
{
  "user_language": null,
  "audience_mode": "expert",
  "session": { "checkpoint": null, "phase_lock": null, "messages_in_session": 0 },
  "security": { "last_scan": null, "last_gate_result": null, "exceptions_count": 0 },
  "step_budget": {
    "DISCOVERY": { "max": 15, "used": 0 },
    "SPEC":      { "max": 20, "used": 0 },
    "DESIGN":    { "max": 20, "used": 0 },
    "DATA":      { "max": 15, "used": 0 },
    "RED":       { "max": 25, "used": 0 },
    "GREEN":     { "max": 30, "used": 0 },
    "SECURITY":  { "max": 10, "used": 0 },
    "REVIEW":    { "max": 15, "used": 0 }
  },
  "token_tracking": { "tokens_estimated": 0, "cost_usd_estimated": 0.0 },
  "model": null,
  "stack": null,
  "ide": null,
  "domains": [],
  "dependency_graph": {}
}
```

**Impacto**: Ao tentar avançar para SPEC ou DESIGN, o LLM acessa `step_budget.SPEC.used` e recebe `undefined`. 
Isso causa comportamento não-determinístico — o LLM pode ou ignorar o budget, ou travar tentando inicializar o campo.

**Correção**: Atualizar `install_core_project` no `setup` para gerar o template completo.

---

### FASE 3 — Architecture Decoupling

#### 3.1-3.6 Core Python + Adapter Layer

| Status | Detalhe |
|--------|---------|
| ❌ NÃO IMPLEMENTADO (design abandonado) | O plano propunha um core Python (`state_manager.py`, `skill_engine.py`, `FileAccessService`). v3.5 adotou uma arquitetura radicalmente diferente: **o LLM é o adapter**. Cada CLI lê seu contexto nativo (CLAUDE.md, AGENTS.md, `.kiro/steering/`) e o LLM executa via tools nativas. Não há código Python de orquestração. |

**Decisão arquitetural v3.5**: "Agent = Model + Harness" (LangChain, 2026). O harness é o conjunto de documentos — não código. Adapter layer = arquivos de contexto por CLI.

---

### FASE 4 — Runtime Evolution

#### 4.1-4.3 Auto-bootstrap + Fluxo controlado pelo HES

| Status | Detalhe |
|--------|---------|
| ✅ RESOLVIDO (v3.5 design) | SKILL.md v3.5, step 0: LLM detecta ZERO → executa auto-install. LLM detecta ORPHAN → carrega legacy.md. O HES (via SKILL.md) controla o fluxo — o CLI apenas provê as tools. |

#### 4.4 Multi-LLM (multi-adapter)

| Status | Detalhe |
|--------|---------|
| ✅ RESOLVIDO (diferente do plano) | Ao invés de adapters Python, o multi-LLM é resolvido via arquivos de contexto por CLI: `.hes/models/claude.md`, `.hes/models/gpt-4o.md`, `.hes/models/default.md`. Cada modelo tem quirks documentados. |

---

## 🔴 Falhas Abertas (não cobertas pelo plano original)

### F-01 — `current.json` template incompleto no `setup`

**Severidade**: Alta  
**Afeta**: Todos os CLIs  
**Sintoma**: LLM tenta acessar `step_budget.DISCOVERY.used` → undefined → comportamento não-determinístico na transição de fase  
**Fix**: Atualizar template em `install_core_project` no `setup` ← **este PR**

---

### F-02 — `.gemini/skills/` vazio no repo (estado fantasma)

**Severidade**: Baixa  
**Afeta**: Gemini CLI  
**Sintoma**: Diretório `.gemini/skills/` rastreado no git mas sem arquivos. Após `./setup --tools gemini`, dois SKILL.md idênticos coexistem.  
**Fix**: Adicionar `hes/SKILL.md` em `.gemini/skills/hes/` no repo OU remover `.gemini/skills/` e deixar o setup gerenciar ← **avaliação pendente**

---

### F-03 — SECURITY phase ausente em skills instaladas via skill-versions.json

**Severidade**: Média  
**Afeta**: CLIs que usam a skill local do usuário (ex: Claude.ai com skill v3.1)  
**Sintoma**: `skill-versions.json` registra `"10-security": "3.4.0"` mas a skill instalada externamente pode não incluir SECURITY na state machine  
**Fix**: Atualizar skill instalada para v3.5 ← fora do escopo deste PR

---

### F-04 — `setup` não valida `chmod +x`

**Severidade**: Baixa  
**Afeta**: Unix/Linux (git clone sem preservar permissões)  
**Sintoma**: `./setup` falha com "permission denied" em alguns ambientes  
**Fix**: Adicionar `chmod +x setup` na seção INSTALL.md ← **este PR**

---

## ✅ Verificação por CLI — Estado Atual

| CLI | Context File | Skills Path | ORPHAN OK? | Estado |
|-----|-------------|-------------|------------|--------|
| Claude Code | `CLAUDE.md` + `.claude/CLAUDE.md` | `.claude/skills/hes/` | ✅ | Funcional |
| Codex CLI | `AGENTS.md` | `.agents/skills/hes/` | ✅ | Funcional |
| Gemini CLI | `GEMINI.md` | `.gemini/skills/hes/` + `.agents/skills/hes/` | ✅ | ⚠️ Duplicata pós-install |
| OpenCode | `AGENTS.md` | `.opencode/skills/hes/` + `.agents/skills/hes/` | ✅ | ⚠️ Duplicata pós-install |
| Cursor | `.cursor/rules/hes.mdc` | `.cursor/skills/hes/` | ✅ | Funcional |
| Windsurf | `.windsurfrules` | `.agents/skills/hes/` | ✅ | Funcional |
| GitHub Copilot | `.github/copilot-instructions.md` | — | N/A | Funcional |
| Kiro | `.kiro/steering/hes.md` | `.kiro/skills/hes/` | ✅ | Funcional |

---

## 🔧 Correções neste PR

1. `plan.md` — este arquivo (documentação das falhas)
2. `setup` — template completo de `current.json` (F-01)
3. `INSTALL.md` — nota sobre `chmod +x setup` (F-04)

---

## 💡 Decisão arquitetural chave (insight do plano original)

> O plano original propunha: "fazer qualquer LLM rodar dentro do HES".  
> v3.5 implementou exatamente isso — mas não via Python adapters.  
> Via **documentos como harness**: o LLM lê SKILL.md e SE TORNA o harness.  
> Adapter layer = contexto por CLI. Core = o próprio LLM.  
> **"Agent = Model + Harness" é literal — você não instala o adapter, você escreve o harness.**
