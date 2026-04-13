# HES Skill — Session Manager

> Skill invocada via: `/hes status`, context bloat detection, phase lock violation, `/clear`, `/new`
> Objetivo: gerenciar ciclo de vida da sessão — checkpoint, recovery, context bloat, phase isolation.
> Quando usar: quando contexto está pesado, ao limpar sessão, ou ao retomar após `/clear`.

---

## ◈ SESSION LIFECYCLE

```
┌──────────────┐
│   ACTIVE     │ ← Normal session running
└──────┬───────┘
       │
       ├─ Context bloat detected (> threshold)
       │     ▼
       │  ⚠️ WARNING: Context approaching limit
       │     → Suggest: /hes checkpoint + /clear
       │
       ├─ Phase lock violation (agent tries to skip ahead)
       │     ▼
       │  🚫 BLOCKED: Cannot advance past current phase
       │     → "Complete phase requirements first, or /hes unlock --force"
       │
       ├─ /clear or /new
       │     ▼
       │  📝 Save checkpoint → .hes/state/session-checkpoint.json
       │     → "Cleared. Run /hes status to resume from checkpoint."
       │
       └─ /hes status (recovery)
             ▼
          Read checkpoint → Restore exact state
             → "Session restored. Feature: X | Phase: Y | Last action: Z"
```

---

## ◈ PASSO 1 — CHECKPOINT (Save Session State)

Before `/clear` or `/new`, save a checkpoint:

### Checkpoint Schema (`.hes/state/session-checkpoint.json`)

```json
{
  "timestamp": "{{DATA_ATUAL_ISO}}",
  "feature": "{{ACTIVE_FEATURE}}",
  "phase": "{{CURRENT_PHASE}}",
  "agent": "{{CURRENT_AGENT}}",
  "last_action": "{{ÚLTIMA_AÇÃO_REALIZADA}}",
  "completed_steps": ["{{STEP_1}}", "{{STEP_2}}"],
  "pending_steps": ["{{STEP_3}}", "{{STEP_4}}"],
  "context_summary": "{{RESUMO_DO_CONTEXTO_ATUAL}}",
  "artifacts_created": ["{{ARQUIVO_1}}", "{{ARQUIVO_2}}"],
  "context_tokens_remaining": {{N}}
}
```

**Ao executar checkpoint:**

```
📝 Checkpoint saved:
  Feature : {{feature}}
  Phase   : {{phase}}
  Last    : {{last_action}}

To resume: run /hes status after /clear
```

---

## ◈ PASSO 2 — RECOVERY (Restore Session)

After `/clear` or `/new`, recover from checkpoint:

```
1. Read .hes/state/session-checkpoint.json
2. Read .hes/state/current.json
3. Compare consistency:
   - Checkpoint.feature == current.json.active_feature?
   - Checkpoint.phase == current.json.features[feature]?
   - If YES → "Checkpoint valid. Resuming from {{phase}} of {{feature}}"
   - If NO  → "⚠ Checkpoint inconsistency detected."
              "Using current.json as source of truth."
4. Load ONLY the skill-file for current phase
5. Show pending steps from checkpoint
6. "Ready to continue. Last action: {{last_action}}"
```

**Ao executar recovery:**

```
🔄 Session Recovery

Checkpoint says  : Feature={{X}}, Phase={{Y}}
Current state    : Feature={{X}}, Phase={{Y}}
Status           : ✅ Consistent

Loading: skills/{{XX-fase_atual}}.md
Pending steps:
  - [ ] {{pending_step_1}}
  - [ ] {{pending_step_2}}

Last action: {{last_action}}
Ready to continue.
```

**Se inconsistência detectada:**

```
⚠ CHECKPOINT INCONSISTENCY DETECTED

Checkpoint says : Feature={{X}}, Phase={{Y}}
Current state   : Feature={{X}}, Phase={{Z}}

Using current.json as source of truth.
Last consistent action: {{LAST_ACTION_FROM_EVENTS_LOG}}

  [A] Continue from current.json state
  [B] Restore from checkpoint (may lose recent work)
```

---

## ◈ PASSO 3 — CONTEXT BLOAT DETECTION

Detectar quando o contexto está pesado e sugerir `/clear`:

### Heurísticas

| Heurística | Threshold | Ação |
|-----------|-----------|------|
| Mensagens na sessão | > 50 | Sugerir checkpoint + clear |
| Usuário diz "começar do zero", "start fresh", "too much context" | 1 match | Sugerir checkpoint + clear |
| Agente relê o mesmo arquivo | 3+ vezes | Sugerir checkpoint + clear |
| Skill-file referencia mensagens anteriores ("como discutimos antes...") | 1 match | Sugerir checkpoint + clear |

### Quando disparar:

```
⚠ Context is getting heavy ({{N}} messages in session).

Suggested action:
  1. I'll save a checkpoint with current progress
  2. You run /clear (or /new)
  3. I'll resume from checkpoint with clean context

  [A] Save checkpoint + clear now
  [B] Continue for now (warn me again at {{N+25}} messages)
```

### Após usuário escolher [A]:

1. Execute PASSO 1 (checkpoint)
2. Confirm checkpoint saved
3. "Session cleared. Run `/hes status` to resume."

---

## ◈ PASSO 4 — PHASE LOCK ENFORCEMENT

Cada fase tem um gate explícito que impede avanço prematuro:

### Phase Lock Gates

| Transição | Gate | Mensagem de Bloqueio |
|-----------|------|---------------------|
| DISCOVERY → SPEC | Lista de RN aprovada pelo usuário | "BLOCKED: Complete RN discovery first" |
| SPEC → DESIGN | Cenários BDD + API contract aprovados | "BLOCKED: Write and approve spec first" |
| DESIGN → DATA | ADRs aprovados | "BLOCKED: Finalize design decisions" |
| DATA → RED | Migrations revisadas | "BLOCKED: Review migration safety" |
| RED → GREEN | ≥1 teste falhando (prova de RED) | "BLOCKED: Tests must fail first" |
| GREEN → REVIEW | Build + todos os testes passando | "BLOCKED: Fix build failures" |
| REVIEW → DONE | Checklist 5 dimensões completo | "BLOCKED: Complete review checklist" |

### Quando violação detectada:

```
🚫 PHASE LOCK VIOLATION

You attempted to {{ACTION}} but the current phase is {{PHASE}}.
Required to advance:
  - [ ] {{missing_requirement_1}}
  - [ ] {{missing_requirement_2}}

Options:
  [A] Complete the missing requirements (recommended)
  [B] /hes unlock --force (bypass — logs risk event, NOT recommended)

Risk: Advancing without completing requirements may cause rework or missed edge cases.
```

### Se usuário escolher [B] (`/hes unlock --force`):

1. Registrar evento de risco em `events.log`:

```json
{
  "timestamp": "{{DATA_ATUAL_ISO}}",
  "feature": "{{FEATURE}}",
  "from": "{{PHASE}}",
  "to": "{{NEXT_PHASE}}",
  "agent": "{{AGENT}}",
  "metadata": {
    "event": "PHASE_LOCK_BYPASS",
    "risk": "HIGH",
    "bypassed_requirements": ["{{req_1}}", "{{req_2}}"]
  }
}
```

2. Confirm: "⚠ Phase lock bypassed. Risk event logged. Proceed with caution."

---

## ◈ PASSO 5 — COMANDOS DE SESSÃO

| Comando | Ação |
|---------|------|
| `/hes status` | Show session state + checkpoint status + pending steps |
| `/clear` | Save checkpoint + clear session context |
| `/new` | Save checkpoint + start fresh session (same as /clear) |
| `/hes checkpoint` | Save checkpoint without clearing |
| `/hes unlock --force` | Bypass phase lock (logs risk event) |
| `/hes rollback <phase>` | Revert to previous phase (with confirmation) |

### `/hes status` output:

```
📊 Session Status

Feature : {{active_feature}}
Phase   : {{current_phase}}
Agent   : {{current_agent}}
IDE     : {{ide_type}}

Checkpoint: {{saved_at}} | {{feature}}:{{phase}}
  Last action: {{last_action}}

Pending steps:
  - [ ] {{step_1}}
  - [ ] {{step_2}}

Messages in session: {{N}}
Context tokens remaining: {{N}}

  [A] Continue  [B] Save checkpoint + /clear  [C] Switch feature
```

---

▶ PRÓXIMA AÇÃO — APÓS SESSÃO GERENCIADA

```
Session lifecycle handled.

  [A] "continuar feature [nome]"
      → Retornar ao skill-file da fase atual: skills/{{XX-fase}}.md

  [B] "salvar checkpoint e limpar"
      → Executar PASSO 1 + confirmar clear

  [C] "ver status completo"
      → Executar PASSO 5 (/hes status output)

  [D] "fazer rollback para {{fase}}"
      → Reverter estado em current.json + registrar evento de rollback

📄 Skill-file: skills/session-manager.md (você está aqui)
💡 Dica: sessões limpas = contexto focado = agente mais preciso.
   Não espere o contexto lotar — limpe preventivamente a cada 30-40 mensagens.
```
