# HES Skill — Session Manager

> Skill invoked via: `/hes status`, context bloat detection, phase lock violation, `/clear`, `/new`
> Objective: manage session lifecycle — checkpoint, recovery, context bloat, phase isolation.
> When to use: when context is heavy, when clearing session, or when resuming after `/clear`.

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

## ◈ STEP 1 — CHECKPOINT (Save Session State)

Before `/clear` or `/new`, save a checkpoint:

### Checkpoint Schema (`.hes/state/session-checkpoint.json`)

```json
{
  "timestamp": "{{CURRENT_ISO_DATE}}",
  "feature": "{{ACTIVE_FEATURE}}",
  "phase": "{{CURRENT_PHASE}}",
  "agent": "{{CURRENT_AGENT}}",
  "last_action": "{{LAST_ACTION_PERFORMED}}",
  "completed_steps": ["{{STEP_1}}", "{{STEP_2}}"],
  "pending_steps": ["{{STEP_3}}", "{{STEP_4}}"],
  "context_summary": "{{CURRENT_CONTEXT_SUMMARY}}",
  "artifacts_created": ["{{FILE_1}}", "{{FILE_2}}"],
  "context_tokens_remaining": {{N}}
}
```

**When executing checkpoint:**

```
📝 Checkpoint saved:
  Feature : {{feature}}
  Phase   : {{phase}}
  Last    : {{last_action}}

To resume: run /hes status after /clear
```

---

## ◈ STEP 2 — RECOVERY (Restore Session)

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

**When executing recovery:**

```
🔄 Session Recovery

Checkpoint says  : Feature={{X}}, Phase={{Y}}
Current state    : Feature={{X}}, Phase={{Y}}
Status           : ✅ Consistent

Loading: skills/{{XX-current-phase}}.md
Pending steps:
  - [ ] {{pending_step_1}}
  - [ ] {{pending_step_2}}

Last action: {{last_action}}
Ready to continue.
```

**If inconsistency detected:**

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

## ◈ STEP 3 — CONTEXT BLOAT DETECTION

Detect when context is heavy and suggest `/clear`:

### Heuristics

| Heuristic | Threshold | Action |
|-----------|-----------|--------|
| Messages in session | > 50 | Suggest checkpoint + clear |
| User says "start from scratch", "start fresh", "too much context" | 1 match | Suggest checkpoint + clear |
| Agent re-reads the same file | 3+ times | Suggest checkpoint + clear |
| Skill-file references previous messages ("as we discussed before...") | 1 match | Suggest checkpoint + clear |

### When to trigger:

```
⚠ Context is getting heavy ({{N}} messages in session).

Suggested action:
  1. I'll save a checkpoint with current progress
  2. You run /clear (or /new)
  3. I'll resume from checkpoint with clean context

  [A] Save checkpoint + clear now
  [B] Continue for now (warn me again at {{N+25}} messages)
```

### After user chooses [A]:

1. Execute STEP 1 (checkpoint)
2. Confirm checkpoint saved
3. "Session cleared. Run `/hes status` to resume."

---

## ◈ STEP 4 — PHASE LOCK ENFORCEMENT

Each phase has an explicit gate that prevents premature advancement:

### Phase Lock Gates

| Transition | Gate | Blocking Message |
|------------|------|------------------|
| DISCOVERY → SPEC | RN list approved by user | "BLOCKED: Complete RN discovery first" |
| SPEC → DESIGN | BDD scenarios + API contract approved | "BLOCKED: Write and approve spec first" |
| DESIGN → DATA | ADRs approved | "BLOCKED: Finalize design decisions" |
| DATA → RED | Migrations reviewed | "BLOCKED: Review migration safety" |
| RED → GREEN | >=1 test failing (proof of RED) | "BLOCKED: Tests must fail first" |
| GREEN → REVIEW | Build + all tests passing | "BLOCKED: Fix build failures" |
| REVIEW → DONE | 5-dimension checklist complete | "BLOCKED: Complete review checklist" |

### When violation detected:

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

### If user chooses [B] (`/hes unlock --force`):

1. Register risk event in `events.log`:

```json
{
  "timestamp": "{{CURRENT_ISO_DATE}}",
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

## ◈ STEP 5 — SESSION COMMANDS

| Command | Action |
|---------|--------|
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

▶ NEXT ACTION — AFTER SESSION MANAGED

```
Session lifecycle handled.

  [A] "continue feature [name]"
      → Return to current phase skill-file: skills/{{XX-phase}}.md

  [B] "save checkpoint and clear"
      → Execute STEP 1 + confirm clear

  [C] "view full status"
      → Execute STEP 5 (/hes status output)

  [D] "rollback to {{phase}}"
      → Revert state in current.json + log rollback event

📄 Skill-file: skills/session-manager.md (you are here)
💡 Tip: clean sessions = focused context = more accurate agent.
   Do not wait for context to overflow — clear preventively every 30-40 messages.
```
