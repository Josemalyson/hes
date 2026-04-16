# HES Skill — 00: Bootstrap

> **Skill loaded when:** global state = ZERO (new project) or HARNESS_INSTALLED (no active feature).
> **Execute in full** before any action.
> **Best practice:** This file is a workflow index. Templates are in `skills/reference/`.

---

## ◈ EXPECTED CONTEXT

Invoked when:
- `.hes/state/current.json` does not exist (new project)
- Project exists but without HES structure
- Harness installed but without an active feature defined

---

## ◈ STEP 1 — COLLECT INFORMATION (max 4 questions)

```
🚀 HES Bootstrap v3.3 — I'll configure the project harness.

I need 4 pieces of information:

1. Project name (e.g., livehome, payment-service): [AUTO-GENERATE]
2. Primary stack (e.g., Java 17 + Spring Boot / Node + NestJS / Python + FastAPI): [AUTO-GENERATE]
3. Is this a new project or integrate existing code? [AUTO-GENERATE]
4. Does the system have defined DDD domains? List them or "no": [AUTO-GENERATE]
```

Try to auto-generate answers; if unable, wait for user response.
With answers, execute steps below.

---

## ◈ STEP 1.5 — VALIDATE SETUP STRUCTURE

### 0. Pre-check — Hidden Directory

```bash
if [ -d ".skills" ] && [ ! -d "skills" ]; then
  echo "⚠ Hidden '.skills/' folder detected. Rename: mv .skills skills"
fi
```

### 1. Validation Checklist

Check all files exist:

```
SKILL.md, skills/00-bootstrap.md, skills/01-discovery.md, skills/02-spec.md,
skills/03-design.md, skills/04-data.md, skills/05-tests.md,
skills/06-implementation.md, skills/07-review.md, skills/legacy.md,
skills/error-recovery.md, skills/refactor.md, skills/report.md, skills/harness-health.md
```

**If any missing:** Display error with missing files → stop and ask user to fix.

### 2. Installation Type

Ask user:

```
📦 Installation Type:

  [A] Local (project-only, versioned with git)
  [B] Global (~/.hes/skills/ with symlinks)
```

- **[A] Local:** register `"installation_type": "local"`, proceed.
- **[B] Global:** copy to `~/.hes/skills/`, create symlink, register `"installation_type": "global"`, proceed.

### 3. Save Validation Report

**File:** `.hes/state/setup-validation.json`

```json
{
  "timestamp": "{{CURRENT_ISO_DATE}}",
  "installation_type": "local|global",
  "structure_valid": true|false,
  "files_expected": ["SKILL.md", "skills/00-bootstrap.md", "skills/01-discovery.md", "skills/02-spec.md", "skills/03-design.md", "skills/04-data.md", "skills/05-tests.md", "skills/06-implementation.md", "skills/07-review.md", "skills/legacy.md", "skills/error-recovery.md", "skills/refactor.md", "skills/report.md", "skills/harness-health.md"],
  "files_missing": [],
  "issues": []
}
```

---

## ◈ STEP 1.5.1 — IDE AUTO-DETECTION

### Detection Order

1. Check for markers: `.vscode/`, `.cursor/`, `.claude/`, `.gemini/`, `.openhands/`, `.windsurf/`
2. If multiple → ask user to select primary IDE
3. If none → ask: "What IDE/editor?" [A] Claude Code [B] Cursor [C] VS Code [D] Windsurf [E] Copilot [F] OpenHands [G] Other

### Generate Config

Load template from `skills/reference/templates/agent-identity.md` and generate the appropriate file:

| IDE | File | Template Section |
|-----|------|------------------|
| Claude Code | `.claude/CLAUDE.md` | Agent Identity |
| Cursor | `.cursorrules` | Cursor variant |
| VS Code | `.vscode/hes-agent.md` | VS Code variant |
| Windsurf | `.windsurfrules` | Cursor variant |
| Generic | `AGENTS.md` | Generic variant |

Register `"ide": "{{detected_ide}}"` in `current.json` (Step 3).

---

## ◈ STEP 1.6 — AGENT REGISTRY INIT

```bash
mkdir -p .hes/agents
```

Verify `.hes/agents/registry.json` exists. If not → warn user.

Validate:
```bash
python3 -c "import json; r=json.load(open('.hes/agents/registry.json')); assert r['version'] == '3.2.0'; print('Registry OK')"
```

If version < 3.2.0 → prompt for upgrade.

---

## ◈ STEP 1.7 — SESSION MANAGER INIT

1. Verify `skills/session-manager.md` exists. If not → warn user.
2. Generate `.hes/state/session-checkpoint.json` with null values (see schema below).
3. Verify session-manager entry exists in `registry.json`.

**Checkpoint schema:**
```json
{
  "timestamp": null, "feature": null, "phase": null, "agent": null,
  "last_action": null, "completed_steps": [], "pending_steps": [],
  "context_summary": "", "artifacts_created": [], "context_tokens_remaining": null
}
```

---

## ◈ STEP 2 — GENERATE DIRECTORY STRUCTURE

```bash
# Base structure
mkdir -p .claude/commands .hes/state .hes/specs .hes/decisions .hes/tasks .hes/inventory

# DDD domains (if provided)
for domain in {{PROVIDED_DOMAINS}}; do
  mkdir -p .hes/domains/$domain/{decisions,fitness}
done
```

---

## ◈ STEP 3 — GENERATE `.hes/state/current.json`

```json
{
  "project": "{{PROJECT_NAME}}",
  "stack": "{{STACK}}",
  "active_feature": null,
  "features": {},
  "domains": [{{DOMAINS_OR_EMPTY_ARRAY}}],
  "dependency_graph": {},
  "harness_version": "3.3.0",
  "completed_cycles": 0,
  "last_updated": "{{CURRENT_ISO_DATE}}"
}
```

---

## ◈ STEP 4 — GENERATE `.hes/state/events.log`

```json
[
  {
    "timestamp": "{{CURRENT_ISO_DATE}}",
    "feature": "global",
    "from": "NONE",
    "to": "HARNESS_INSTALLED",
    "agent": "hes-v3.3",
    "metadata": {
      "project": "{{PROJECT_NAME}}",
      "stack": "{{STACK}}",
      "harness_version": "3.3.0"
    }
  }
]
```

---

## ◈ STEP 5 — GENERATE AGENT IDENTITY

Load template from `skills/reference/templates/agent-identity.md` and generate IDE-specific config file (determined in Step 1.5.1).

---

## ◈ STEP 6 — GENERATE `.hes/tasks/lessons.md`

```markdown
# Lessons Learned — {{PROJECT_NAME}}

> Updated after each session (hot path) and consolidated via /hes report (offline).
> Lessons that appear 2x are promoted to the corresponding skill-file.
> Recurring issue → improve the harness, not just the instance (Fowler, 2026).

## Categories
A — HES rule violation
B — Recurring technical error
C — Guide gap (insufficient feedforward)
D — Sensor gap (feedback did not detect)
E — Process (approval flow, communication)

## Consolidated Lessons (promoted to SKILL.md or skill-file)
_none yet_
```

---

## ◈ STEP 7 — GENERATE `.hes/tasks/backlog.md`

```markdown
# Backlog — {{PROJECT_NAME}}

## 🔴 High Priority
_add via /hes start [feature-name]_

## 🟡 Medium Priority

## 🟢 Low Priority

## ✅ Completed
```

---

## ◈ STEP 8 — GENERATE DOMAINS (if provided)

For each domain in `{{PROVIDED_DOMAINS}}`:

Load templates from `skills/reference/domain-templates.md` and generate:
- `.hes/domains/{{domain}}/context.md`
- `.hes/domains/{{domain}}/fitness/README.md`

---

## ◈ STEP 9 — CONFIGURE ARCHITECTURE FITNESS SENSORS

Ask user:

```
🏗 Configure Architecture Fitness sensors?

  [A] "yes, configure now" → run setup for {{STACK}}
  [B] "later" → register in harness backlog and proceed
```

If **[A]**, load templates from `skills/reference/fitness-sensors.md` and generate:

| Stack | Tool | Command |
|-------|------|---------|
| Java/Spring Boot | ArchUnit 1.3.0 | `mvn test -Dtest=ArchitectureTest` |
| Node.js/NestJS | dependency-cruiser | `npm run check:arch` |
| Python/FastAPI | import-linter | `lint-imports` |

---

## ◈ STEP 10 — GENERATE GIT HOOKS

Load `skills/reference/git-hooks.md` which contains LLM-executable sensors.
The LLM will run these checks autonomously before each commit.
No Python scripts to install — the LLM IS the sensor.

**Reference:** `skills/reference/git-hooks.md`

---

## ◈ STEP 11 — DISPLAY BOOTSTRAP SUMMARY

```
✅ HES Bootstrap v3.3 Completed — {{PROJECT_NAME}}

Guides installed (feedforward):
  .claude/CLAUDE.md (or equivalent)   ← agent identity
  .hes/state/current.json              ← project state (v3.3 schema)
  .hes/state/events.log                ← transition log (traces)
  .hes/state/session-checkpoint.json   ← session checkpoint
  .hes/agents/registry.json            ← agent registry
  .hes/tasks/lessons.md                ← learning memory
  .hes/tasks/backlog.md                ← feature backlog
  {{.hes/domains/*/context.md}}        ← bounded contexts (if domains)
  {{.hes/domains/*/fitness/}}          ← architecture fitness sensors

Sensors installed (LLM-executed):
  skills/reference/git-hooks.md     ← pre-commit (LLM-executed)
  skills/reference/git-hooks.md   ← commit-msg (LLM-executed)
  {{fitness sensor per stack}}         ← architecture validation

IDE detected: {{IDE}} → config: {{CONFIG_FILE}}

Git hooks are LLM-executed (skills/reference/git-hooks.md) — no install needed.
```

---

▶ NEXT ACTION — DISCOVERY

```
The harness is installed. What is the first feature you want to develop?

  [A] "I want to implement [feature name]"
      → Start Discovery (skills/01-discovery.md)

  [B] "I want to see the backlog first"
      → Show .hes/tasks/backlog.md

  [C] "the project has existing code to analyze"
      → Load skills/legacy.md for inventory + harnessability assessment

  [D] "/hes harness"
      → Initial harness coverage diagnosis

📄 Next skill-file: skills/01-discovery.md
💡 Tip: Discovery captures Business Rules (RN-xx).
   Anything not captured here causes rework in subsequent steps.
   It is the most important inferential guide in the behaviour harness.
```
