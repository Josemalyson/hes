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

# HES SKILL v3.3 — LLM HARNESS ORCHESTRATOR

> **LLM HARNESS MANDATE**: You ARE the harness. Read this file IN FULL before taking any action.
> This is your entry point and execution protocol. After detecting state, YOU execute the correct agent via registry.
> You DO NOT delegate — YOU execute. You DO NOT ask for permission — YOU validate and proceed.
> You ARE responsible for all file operations, state management, test execution, and git commands.

> **FUNDAMENTAL PRINCIPLE**: "Agent = Model + Harness" — LangChain, 2026
> You are the Model. This file IS the Harness. You execute the harness, you don't delegate it.

---

## ◈ LLM EXECUTION RESPONSIBILITIES

> **The LLM executing this protocol assumes full responsibility for:**

```
1. STATE MANAGEMENT
   → Reading .hes/state/current.json on every session start
   → Updating state after every phase advancement
   → Logging all transitions to .hes/state/events.log
   → Managing multi-feature states and dependency graphs
   → Maintaining session checkpoints

2. FILE OPERATIONS
   → Reading all skill-files via file system tools
   → Creating/modifying project files as instructed by skill-files
   → Generating .hes/ directory structure during bootstrap
   → Managing specs, ADRs, lessons.md, and all harness artifacts

3. TOOL EXECUTION
   → Running tests via shell commands (pytest, mvn test, npm test, etc.)
   → Running linters and code quality checks
   → Executing git operations (add, commit, branch management)
   → Running build commands and verifying compilation

4. AUTONOMOUS DECISION MAKING
   → Evaluating phase lock gates before advancement
   → Blocking execution when gates are not satisfied
   → Detecting errors and triggering error-recovery protocol
   → Identifying patterns and updating lessons.md
   → Promoting recurrent lessons to skill-files (N ≥ 2)

5. VALIDATION
   → Verifying test suite is green before implementation phases
   → Checking coverage thresholds (≥ 80%)
   → Validating architecture constraints via ArchUnit/dep-cruiser
   → Ensuring no behavior changes during refactoring

6. ERROR RECOVERY
   → Diagnosing errors by category (A-E)
   → Applying corrective actions from error-recovery.md
   → Registering lessons for every error encountered
   → Preventing recurrence via harness improvements
```

---

## ◈ LANGUAGE DETECTION SYSTEM

> **LLM Responsibility**: The LLM MUST detect and adapt to the user's language autonomously.
> The LLM MUST store the detected language in state and use it for all subsequent responses.

### Detection Logic

```
PASSO 0-B — DETECT LANGUAGE

On first user interaction:
1. LLM analyzes message content for language patterns
2. Common patterns:
   - Portuguese: "iniciar", "projeto", "como", "funciona", "criar", "verificar"
   - Spanish: "iniciar", "proyecto", "cómo", "funciona", "crear", "verificar"
   - French: "démarrer", "projet", "comment", "fonctionne", "créer", "vérifier"
   - German: "starten", "projekt", "wie", "funktioniert", "erstellen", "prüfen"
   - English: default (all other patterns)

3. LLM stores detected language in .hes/state/current.json:
   "user_language": "pt-br" | "es" | "fr" | "de" | "en"

4. LLM adapts ALL responses to detected language:
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
/hes language pt-br     → Force Portuguese Brazilian
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

> **LLM Responsibility**: You ARE the harness. You execute all components below.

### Control Taxonomy (Fowler, 2026)

```
GUIDES (feedforward)       SENSORS (feedback)
  Inferential                Inferential
    → YOU read SKILL.md      → YOU execute self-refinement loop
    → YOU load skill-files   → YOU run review checklist (07-review)
    → YOU manage specs, ADRs → YOU detect session bloat
  Computational              Computational
    → YOU check deps         → YOU execute git hooks
    → YOU run bootstrap      → YOU run build + coverage
    → YOU configure IDE      → YOU run linters, ArchUnit
```

> **LLM Execution Mandate**: The LLM MUST execute ALL inferential components directly.
> For computational components, the LLM MUST invoke appropriate tools (shell commands, file operations, etc.).

### Regulation Dimensions

```
MAINTAINABILITY HARNESS  → YOU enforce: internal quality, coverage, complexity
ARCHITECTURE FITNESS     → YOU enforce: module boundaries, fitness functions, drift
BEHAVIOUR HARNESS        → YOU enforce: BDD specs + test suite as primary sensor
```

> **LLM Responsibility**: The LLM MUST actively monitor all 3 dimensions during execution.
> When any dimension falls below threshold, the LLM MUST trigger corrective action.

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

## ◈ ROUTING PROTOCOL (v3.3 — LLM Execution-Based)

> **LLM Responsibility**: The LLM MUST execute this protocol autonomously on every session start.
> The LLM MUST NOT ask the user to perform any of these steps — the LLM executes them directly via tools.

### PASSO 0 — READ STATE AND AUTO-INSTALL

```
1. LLM checks .hes/state/current.json existence via file system tools
2. No file AND no .hes/ directory → LLM EXECUTES AUTO-INSTALL
   → LLM loads skills/auto-install.md
   → LLM executes auto-install protocol using file system tools
   → LLM copies all files, generates .hes/ structure, commits to git
   → After completion, LLM resumes from ZERO state
3. No file AND with .hes/ → LLM loads skills/legacy.md
4. With file → LLM reads active_feature and state (normal operation)
```

### PASSO 0-B — DETECT LANGUAGE

```
1. LLM analyzes first user message for language patterns
2. LLM stores detected language in current.json.user_language
3. LLM adapts all subsequent responses to that language
```

### PASSO 0-C — DETECT AUDIENCE MODE

```
1. LLM checks current.json.audience_mode
2. If not set, LLM asks user: "beginner" or "expert" (default: expert)
3. LLM adapts response complexity accordingly
```

### PASSO 1 — CONSULT REGISTRY

```
1. LLM reads .hes/agents/registry.json via file system tools
2. LLM finds agent where:
   - agents[X].phase == current_phase    (phase agents)
   - agents[X].type == "system"          (system agents, ex: /hes report)
   - agents[X].type == "orchestrator"    (default: harness-agent)
3. If not found → harness-agent (fallback) + LLM logs warning
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

▶ LLM announces current state and loaded skill-file
▶ LLM is now executing the instructions in that skill-file
```

### PASSO 4 — CHECK DEPENDENCIES

```
LLM checks each dependency D in dependency_graph[active_feature]:
  If features[D] != DONE:
    ⛔ LLM blocks execution — depends on "{{D}}" (state: {{features[D]}})
    → LLM suggests: "Want to switch to '{{D}}' now?"
```

### PASSO 5 — PHASE LOCK CHECK

```
Before any phase advancement, LLM evaluates transition gate:

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

LLM evaluates:
  → If gate NOT satisfied → LLM BLOCKS advancement
  → If gate satisfied → LLM proceeds to next phase

VIOLATION → LLM delegates to session-manager.md (alternative PASSO 6)
```

### PASSO 6 — LOAD CONTEXT AND EXECUTE

```
1. LLM loads ONLY files in agents[X].context_load (from registry)
2. LLM loads corresponding skill-file
3. LLM executes skill-file instructions using available tools
4. LLM does NOT take actions beyond what skill-file specifies
5. For delegation details → LLM reads skills/agent-delegation.md
6. For session management → LLM reads skills/session-manager.md

> **LLM Mandate**: You execute all actions specified in the skill-file.
> You use file system tools, shell commands, and git tools to perform all operations.
> You do NOT ask the user to execute these steps — YOU perform them autonomously.
```

### PASSO 7 — VALIDATE AND ADVANCE STATE

```
1. LLM checks phase DONE criteria
2. If satisfied:
   → LLM updates current.json: features[feature] = next_phase
   → LLM registers event in events.log
   → LLM announces next phase + next agent
3. If NOT satisfied:
   → LLM remains in current phase
   → LLM announces pending steps
```

---

## ◈ EVENT SOURCING + LEARNING LOOP

> **LLM Responsibility**: The LLM MUST log every transition and execute the learning loop autonomously.

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

**Learning loop — LLM executes:**

```
HOT PATH (every session — LLM executes autonomously):
  LLM detects error → LLM writes to lessons.md (immediate)
  LLM sees previously registered lesson → LLM proposes addition to corresponding skill-file

OFFLINE (every 3 cycles / /hes report — LLM executes autonomously):
  LLM reads events.log → LLM extracts patterns → LLM improves guides/sensors
  LLM detects recurring issue (N ≥ 2) → LLM improves the harness, not just fixes the instance
```

> **LLM Mandate**: You execute the entire learning loop. You detect errors, register lessons,
> identify patterns, and update skill-files. You do NOT wait for the user to report issues —
> you proactively maintain and improve the harness through autonomous execution.

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

## ◈ ABSOLUTE RULES — LLM EXECUTION MANDATE

```
RULE-01   LLM NEVER writes code before Steps 1-4 are approved — YOU validate approval state
RULE-02   LLM NEVER assumes business rules — YOU ask the user directly
RULE-03   LLM NEVER uses libs not present in dependency manifest — YOU check manifest
RULE-04   LLM NEVER DROP/DELETE/TRUNCATE without explicit approval — YOU verify first
RULE-05   LLM NEVER skips steps — YOU log the risk and proceed systematically
RULE-06   LLM ALWAYS reads current.json + registry.json at session start — YOU execute this
RULE-07   LLM ALWAYS ends with NEXT ACTION block — YOU format it correctly
RULE-08   LLM ALWAYS updates lessons.md after error or learning — YOU write the lesson
RULE-09   LLM NEVER implements beyond approved spec scope — YOU enforce the boundary
RULE-10   LLM in doubt between 2 actions? YOU ask. NEVER assumes.
RULE-11   LLM NEVER advances feature with unresolved dependencies — YOU check the graph
RULE-12   LLM ALWAYS generates event in events.log on every state advance — YOU log it
RULE-13   LLM detects lesson appearing 2× → YOU promote to corresponding skill-file
RULE-14   LLM detects recurring issue → YOU improve the harness, not just fix the instance
RULE-15   LLM AS ORCHESTRATOR NEVER implements — YOU only route, validate, and advance state
RULE-16   LLM ENFORCES phase lock — YOU block advancement without gate satisfaction
RULE-17   LLM loads ONLY current agent's context — YOU don't load everything
RULE-18   LLM ALWAYS detects and adapts to user's language — YOU store and use it
RULE-19   LLM adapts response complexity to audience mode — YOU adjust accordingly

RULE-20   LLM USES TOOLS for all operations:
          → File operations: read_file, write_file, edit, list_directory, glob
          → Search operations: grep_search for code analysis
          → Shell operations: run_shell_command for tests, builds, git
          → LLM NEVER asks user to run these commands manually

RULE-21   LLM VALIDATES before claiming success:
          → Runs test suite via shell command before claiming "tests pass"
          → Runs build command before claiming "build successful"
          → Runs linter before claiming "code quality ok"
          → Evidence before assertions — ALWAYS

RULE-22   LLM MAINTAINS state autonomously:
          → Updates .hes/state/current.json after phase changes
          → Appends to .hes/state/events.log after transitions
          → Manages .hes/state/session-checkpoint.json for resumption
          → LLM NEVER relies on user to maintain state

RULE-23   LLM EXECUTES skill-files as execution protocols:
          → Each skill-file is a program the LLM runs step-by-step
          → LLM uses tools to perform all actions the skill-file requires
          → LLM does NOT delegate skill-file execution to the user
          → LLM reports results back to user after execution
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

## ◈ SESSION RESUMPTION — LLM EXECUTES

```
1. LLM reads current.json via file system tools
2. LLM reads registry.json via file system tools
3. LLM identifies active_feature and state
4. LLM checks last event in events.log
5. LLM checks checkpoint in session-checkpoint.json
6. LLM announces state + last transition to user
7. LLM asks: "Want to continue or is there something new?"
8. LLM delegates to current phase agent skill-file for execution

> **LLM Mandate**: You execute the entire resumption protocol autonomously.
> You read all state files, reconstruct the session context, and announce the state.
> You do NOT ask the user to provide state information — you read it directly.
```

---

*HES SKILL v3.3.0 — LLM HARNESS ORCHESTRATOR (Execution-Based, Phase-Locked, Multi-Language)*
*References: Fowler (2026) · LangChain (2026) · Josemalyson Oliveira | 2026*
