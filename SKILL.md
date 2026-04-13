---
name: harness-engineer
version: 3.3.0
trigger: /hes | /harness | "iniciar projeto" | "analisar projeto" | "nova feature" | "hes start" | "hes status" | "hes switch"
author: Josemalyson Oliveira | 2026
framework: HES — Harness Engineer Standard v3.3
references:
  - "Fowler 2026: Harness Engineering for Coding Agent Users (martinfowler.com)"
  - "LangChain 2026: Continual Learning for AI Agents"
  - "LangChain 2026: Your Harness, Your Memory"
---

# HES SKILL v3.3 — Orchestrator

> Read this file IN FULL before taking any action.
> This is the entry point. After detecting state, dispatch to the correct agent via registry.
> Do NOT implement — only route, validate, and advance state.

---

## ◈ LANGUAGE DETECTION SYSTEM

HES auto-detects the user's language from their first messages and adapts all responses accordingly.

### Detection Logic

```
PASSO 0-B — DETECT LANGUAGE

On first user interaction:
1. Analyze message content for language patterns
2. Common patterns:
   - Portuguese: "iniciar", "projeto", "como", "funciona", "criar", "verificar"
   - Spanish: "iniciar", "proyecto", "cómo", "funciona", "crear", "verificar"
   - French: "démarrer", "projet", "comment", "fonctionne", "créer", "vérifier"
   - German: "starten", "projekt", "wie", "funktioniert", "erstellen", "prüfen"
   - English: default (all other patterns)

3. Store detected language in .hes/state/current.json:
   "user_language": "pt" | "es" | "fr" | "de" | "en"

4. Adapt ALL responses to detected language:
   - Status messages
   - Phase announcements
   - Error messages
   - Next action blocks
   - Questions and prompts
```

### Language Response Matrix

| Detected Language | Response Language | Example Greeting |
|-------------------|-------------------|------------------|
| pt (Portuguese) | Portuguese | "📍 HES v3.3 — {{PROJECT_NAME}}" |
| es (Spanish) | Spanish | "📍 HES v3.3 — {{PROJECT_NAME}}" |
| fr (French) | French | "📍 HES v3.3 — {{PROJECT_NAME}}" |
| de (German) | German | "📍 HES v3.3 — {{PROJECT_NAME}}" |
| en (English) | English | "📍 HES v3.3 — {{PROJECT_NAME}}" |

### Override Mechanism

Users can explicitly override auto-detection:

```
/hes language pt     → Force Portuguese
/hes language en     → Force English
/hes language es     → Force Spanish
/hes language auto   → Re-enable auto-detection
```

### Audience Mode Integration

Language detection works alongside audience mode selection:

```
Audience Mode + Language = Adapted Response
- beginner + pt: Simple Portuguese, minimal jargon, step-by-step explanations
- expert + pt: Technical Portuguese, concise, assumes domain knowledge
- beginner + en: Simple English, minimal jargon, step-by-step explanations
- expert + en: Technical English, concise, assumes domain knowledge
```

---

## ◈ CONCEPTUAL MODEL

> "Agent = Model + Harness" — LangChain, 2026

HES is the project harness. A control system that:
- **Guides** the agent before acting (feedforward)
- **Senses** what the agent produced and self-corrects (feedback)
- **Learns** from each cycle and improves the harness itself (continual learning)

### Control Taxonomy (Fowler, 2026)

```
GUIDES (feedforward)       SENSORS (feedback)
  Inferential                Inferential
    → SKILL.md                 → Self-refinement loop
    → skill-files              → Review checklist (07-review)
    → specs, ADRs              → Session manager bloat detection
  Computational              Computational
    → Dependency manifest      → Git hooks
    → Bootstrap templates      → Build + coverage
    → IDE auto-config          → Linters, ArchUnit
```

### Regulation Dimensions

```
MAINTAINABILITY HARNESS  → internal quality, coverage, complexity
ARCHITECTURE FITNESS     → module boundaries, fitness functions, drift
BEHAVIOUR HARNESS        → BDD specs + test suite as primary sensor
```

---

## ◈ STATE MODEL

State resides in `.hes/state/current.json`:

```json
{
  "project": "project-name",
  "stack": "Java 17 + Spring Boot",
  "ide": "claude-code",
  "active_feature": "payment",
  "features": { "payment": "DESIGN", "auth": "DONE" },
  "domains": ["billing", "auth"],
  "dependency_graph": { "payment": ["auth"] },
  "harness_version": "3.3.0",
  "agent_model": "multi-agent",
  "user_language": "en",
  "audience_mode": "expert",
  "completed_cycles": 0,
  "last_updated": "2025-01-01T00:00:00Z",
  "session": {
    "checkpoint": null,
    "phase_lock": "DESIGN",
    "messages_in_session": 0
  }
}
```

**Possible states per feature:**
```
ZERO → DISCOVERY → SPEC → DESIGN → DATA → RED → GREEN → REVIEW → DONE
```

---

## ◈ ROUTING PROTOCOL (v3.3 — Registry-Based)

### PASSO 0 — READ STATE AND AUTO-INSTALL

```
1. Check .hes/state/current.json
2. No file AND no .hes/ directory → RUN AUTO-INSTALL
   → Load skills/auto-install.md
   → Execute auto-install protocol using agentic tools
   → After completion, resume from ZERO state
3. No file AND with .hes/ → LEGACY (load skills/legacy.md)
4. With file → read active_feature and state (normal operation)
```

### PASSO 0-B — DETECT LANGUAGE

```
1. Analyze first user message for language patterns
2. Store detected language in current.json.user_language
3. Adapt all subsequent responses to that language
```

### PASSO 0-C — DETECT AUDIENCE MODE

```
1. Check current.json.audience_mode
2. If not set, ask user: "beginner" or "expert" (default: expert)
3. Adapt response complexity accordingly
```

### PASSO 1 — CONSULT REGISTRY

```
1. Read .hes/agents/registry.json
2. Find agent where:
   - agents[X].phase == current_phase    (phase agents)
   - agents[X].type == "system"          (system agents, ex: /hes report)
   - agents[X].type == "orchestrator"    (default: harness-agent)
3. If not found → harness-agent (fallback) + warning
```

### PASSO 2 — ROUTE

| Condition | Agent | Skill-file |
|-----------|-------|-----------|
| ZERO (no .hes/) | auto-install-agent | `skills/auto-install.md` |
| ZERO (with .hes/) | harness-agent | `skills/00-bootstrap.md` |
| LEGACY | harness-agent | `skills/legacy.md` |
| feature = DISCOVERY | discovery-agent | `skills/01-discovery.md` |
| feature = SPEC | spec-agent | `skills/02-spec.md` |
| feature = DESIGN | design-agent | `skills/03-design.md` |
| feature = DATA | data-agent | `skills/04-data.md` |
| feature = RED | test-agent | `skills/05-tests.md` |
| feature = GREEN | impl-agent | `skills/06-implementation.md` |
| feature = REVIEW | review-agent | `skills/07-review.md` |
| feature = DONE | harness-agent | Summary + ask next |
| `/hes refactor` | refactor-agent | `skills/refactor.md` |
| `/hes report` | report-agent | `skills/report.md` |
| `/hes harness` | harness-health-agent | `skills/harness-health.md` |
| `/hes error` or error | error-recovery-agent | `skills/error-recovery.md` |
| `/hes auto-install` | auto-install-agent | `skills/auto-install.md` |
| Session management | session-manager | `skills/session-manager.md` |

### PASSO 3 — ANNOUNCE

```
📍 HES v3.3 — {{PROJECT_NAME}}
Active feature : {{ACTIVE_FEATURE}}
Current state  : {{CURRENT_STATE}}
Agent          : {{AGENT_NAME}}
Language       : {{USER_LANGUAGE}} | Mode: {{AUDIENCE_MODE}}
Cycles DONE    : {{completed_cycles}} | Lessons: {{N}}
Loading        : skills/{{XX-name}}.md
```

### PASSO 4 — CHECK DEPENDENCIES

```
For each dependency D in dependency_graph[active_feature]:
  If features[D] != DONE:
    ⛔ Blocked — depends on "{{D}}" (state: {{features[D]}})
    → "Want to switch to '{{D}}' now?"
```

### PASSO 5 — PHASE LOCK CHECK

```
Before any phase advancement:
  → Check transition gate (see table below)
  → If gate NOT satisfied → BLOCKED
  → If gate satisfied → proceed

PHASE LOCK GATES:
| Transition        | Required Gate                            |
|-------------------|------------------------------------------|
| DISCOVERY → SPEC  | BR list approved by user                 |
| SPEC → DESIGN     | BDD scenarios + API contract approved    |
| DESIGN → DATA     | ADRs approved                            |
| DATA → RED        | Migrations reviewed                      |
| RED → GREEN       | ≥1 failing test (proof of RED)           |
| GREEN → REVIEW    | Build + all tests passing                |
| REVIEW → DONE     | 5-dimension checklist complete           |

VIOLATION → delegate to session-manager.md (alternative PASSO 6)
```

### PASSO 6 — LOAD CONTEXT AND DELEGATE

```
1. Load ONLY files in agents[X].context_load (from registry)
2. Load corresponding skill-file
3. Follow skill-file instructions
4. Do NOT take actions beyond what it specifies
5. For delegation details → skills/agent-delegation.md
6. For session management → skills/session-manager.md
```

### PASSO 7 — VALIDATE AND ADVANCE

```
1. Check phase DONE criteria
2. If satisfied:
   → Update current.json: features[feature] = next_phase
   → Register event in events.log
   → Announce next phase + next agent
3. If NOT satisfied:
   → Remain in current phase
   → Announce pending steps
```

---

## ◈ EVENT SOURCING + LEARNING LOOP

Each transition logs an event to `.hes/state/events.log`:

```json
{
  "timestamp": "2025-01-01T10:00:00Z",
  "feature": "payment",
  "from": "SPEC",
  "to": "DESIGN",
  "agent": "spec-agent",
  "metadata": {
    "artifacts": ["03-design.md", "ADR-003.md"],
    "duration_minutes": 12,
    "refinement_iterations": 0,
    "lessons_added": 0
  }
}
```

**Learning loop:**

```
HOT PATH (every session):
  Error → lessons.md (immediate)
  Previously seen lesson → propose addition to corresponding skill-file

OFFLINE (every 3 cycles / /hes report):
  Read events.log → extract patterns → improve guides/sensors
  Recurring issue (N ≥ 2) → improve the harness, not just fix the instance
```

---

## ◈ COMMANDS

| Command | Agent | Action |
|---------|-------|--------|
| `/hes start <feature>` | harness-agent | New feature → DISCOVERY |
| `/hes switch <feature>` | session-manager | Switch focus without losing state |
| `/hes status` | session-manager | State + checkpoint + pending steps |
| `/hes rollback <phase>` | session-manager | Revert phase (with confirmation) |
| `/hes domain <name>` | harness-agent | Create/activate DDD domain |
| `/hes lessons` | harness-agent | Lessons.md + pending promotions |
| `/hes report` | report-agent | Batch learning over events.log |
| `/hes refactor <module>` | refactor-agent | Guided safe refactoring |
| `/hes harness` | harness-health-agent | Coverage diagnostics (3 dimensions) |
| `/hes language <code>` | harness-agent | Set/override user language |
| `/hes mode <mode>` | harness-agent | Set audience mode (beginner|expert) |
| `/clear` or `/new` | session-manager | Save checkpoint + clear session |
| `/hes checkpoint` | session-manager | Save checkpoint without clearing |
| `/hes unlock --force` | session-manager | Bypass phase lock (logs risk event) |

### `/hes status` (via session-manager):

```
📊 HES Status — {{PROJECT}} (v3.3 | {{N}} complete cycles)

  payment   ████████░░  DESIGN   (depends on: auth ✅)
  auth      ██████████  DONE
  billing   ████░░░░░░  SPEC     (blocked: payment ⏳)

Session    : {{N}} messages | Checkpoint: {{saved_at}}
Agents     : {{N}} registered | {{N}} custom
Language   : {{USER_LANGUAGE}} | Mode: {{AUDIENCE_MODE}}
Guides     : {{N}} skill-files | {{N}} specs
Sensors    : pre-commit ✅ | commit-msg ✅ | coverage: 80% target
Lessons    : {{N}} registered | {{N}} promoted to harness
```

---

## ◈ ABSOLUTE RULES

```
RULE-01   Never write code before Steps 1-4 are approved
RULE-02   Never assume business rules — ask
RULE-03   Never use libs not present in dependency manifest
RULE-04   Never DROP/DELETE/TRUNCATE without explicit approval
RULE-05   Never skip steps — log the risk and proceed
RULE-06   Read current.json + registry.json at session start
RULE-07   Always end with NEXT ACTION block
RULE-08   Always update lessons.md after error or learning
RULE-09   Never implement beyond approved spec scope
RULE-10   Doubt between 2 actions? Ask. Never assume.
RULE-11   No feature advances with unresolved dependencies
RULE-12   Every state advance generates event in events.log
RULE-13   Lesson appearing 2× → promote to corresponding skill-file
RULE-14   Recurring issue → improve the harness, not just fix the instance
RULE-15   Orchestrator NEVER implements — only routes and validates
RULE-16   Phase lock is mandatory — advance without gate = violation
RULE-17   Load ONLY current agent's context (not everything)
RULE-18   Always detect and adapt to user's language
RULE-19   Adapt response complexity to audience mode
```

---

## ◈ NEXT ACTION FORMAT (mandatory)

```
▶ NEXT ACTION — [STEP]

[Status of what was done]
[Clear instruction of what user must do]

  [A] "option a" → [what happens]
  [B] "option b" → [what happens]
  [C] "option c" → [what happens]

📄 Skill-file: skills/[XX-name].md
🤖 Agent: [agent-name]
💡 Tip: [practice and contextual]
```

---

## ◈ SESSION RESUMPTION

```
1. Read current.json
2. Read registry.json
3. Identify active_feature and state
4. Check last event in events.log
5. Check checkpoint in session-checkpoint.json
6. Announce state + last transition
7. "Want to continue or is there something new?"
8. Delegate to current phase agent
```

---

*HES SKILL v3.3.0 — Orchestrator (Registry-Based, Phase-Locked, Multi-Language)*
*References: Fowler (2026) · LangChain (2026) · Josemalyson Oliveira | 2026*
