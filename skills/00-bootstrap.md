# 00 · ZERO — Bootstrap

phase  ZERO  ·  next  DISCOVERY
gate   all required artifacts present + current.json written
skill  skills/00-bootstrap.md

> You are the executor. Read each step, run the tool call, proceed.
> Do not ask the user to run any command — you run them.

---

## ◈ CONTEXT

Loaded when: no `.hes/` directory and no `current.json` exist (ZERO state).
Objective: detect project, install harness structure, reach HARNESS_READY.

---

## ◈ STEP 0 — ORPHAN / INSTALLED_INCOMPLETE CHECK

Before full bootstrap, verify substate:

→ EXECUTE
```bash
if [ -d ".skills" ] && [ ! -d "skills" ]; then
  echo "⚠ Hidden .skills/ found — rename: mv .skills skills"
fi
[ -f ".hes/state/current.json" ] && echo "HAS_STATE" || echo "NO_STATE"
[ -d ".hes" ] && echo "HAS_HES_DIR" || echo "NO_HES_DIR"
```

Route:
- `HAS_STATE` + `features:{}` + missing artifacts → `INSTALLED_INCOMPLETE` → run Step 0-CHECK only
- `HAS_HES_DIR` + `NO_STATE` → ORPHAN → load `skills/legacy.md` Path A
- `NO_HES_DIR` + `NO_STATE` → ZERO → continue with Step 1

---

## ◈ STEP 0-CHECK — Auto-Complete (INSTALLED_INCOMPLETE only)

→ EXECUTE
```bash
MISSING=""
[ ! -f ".hes/tasks/lessons.md" ]             && MISSING="$MISSING lessons.md"
[ ! -f ".hes/tasks/backlog.md" ]             && MISSING="$MISSING backlog.md"
[ ! -f ".hes/state/session-checkpoint.json" ] && MISSING="$MISSING session-checkpoint.json"
[ ! -f ".hes/state/setup-validation.json" ]  && MISSING="$MISSING setup-validation.json"
echo "Missing: ${MISSING:-none}"
```

Generate each missing artifact silently. Log: `INSTALLED_INCOMPLETE → HARNESS_READY`.
Announce in 2 lines max. Point directly to DISCOVERY — no menu.

---

## ◈ STEP 1 — PROJECT DETECTION

→ EXECUTE
```bash
# Project name
PROJECT=$(git remote get-url origin 2>/dev/null \
  | sed 's/.*\///' | sed 's/\.git//' \
  || basename "$(pwd)")

# Stack detection
STACK=""
[ -f "pom.xml" ]          && STACK="Java + Maven"
[ -f "build.gradle" ]     && STACK="Java + Gradle"
[ -f "package.json" ]     && STACK="Node.js"
[ -f "pyproject.toml" ]   && STACK="Python"
[ -f "requirements.txt" ] && STACK="Python + pip"
[ -f "go.mod" ]           && STACK="Go"
[ -f "Cargo.toml" ]       && STACK="Rust"
[ -z "$STACK" ]           && STACK="Unknown"

# IDE detection
IDE="generic"
[ -d ".claude" ]   && IDE="claude-code"
[ -d ".cursor" ]   && IDE="cursor"
[ -d ".vscode" ]   && IDE="vscode"
[ -d ".windsurf" ] && IDE="windsurf"
[ -d ".kiro" ]     && IDE="kiro"

echo "project=$PROJECT stack=$STACK ide=$IDE"
```

Ask the user (once):
- Language preference (pt-BR / en / es / fr / de)?
- Domains (DDD bounded contexts) — if known

---

## ◈ STEP 2 — HARNESSABILITY SCORE

Assess silently and store in `setup-validation.json`:

```
TYPING      strongly typed? (HIGH: Java/TS/Go/Kotlin · MEDIUM: Python · LOW: JS)
MODULARITY  clear src/domain structure? (HIGH / MEDIUM / LOW)
TESTABILITY test suite + DI used? (HIGH / MEDIUM / LOW)

OVERALL = min(TYPING, MODULARITY, TESTABILITY)
```

---

## ◈ STEP 3 — GENERATE HARNESS STRUCTURE

→ EXECUTE
```bash
mkdir -p \
  .hes/state \
  .hes/specs \
  .hes/decisions \
  .hes/tasks \
  .hes/inventory \
  .hes/context/tool-outputs \
  .hes/domains \
  scripts/hooks \
  scripts/ci

python3 -c "import uuid; print(str(uuid.uuid4()))" > .hes/state/session-id
echo "✓ structure created · session-id: $(cat .hes/state/session-id)"
```

---

## ◈ STEP 4 — WRITE current.json

→ EXECUTE (write `.hes/state/current.json`):
```json
{
  "project": "{{PROJECT}}",
  "stack": "{{STACK}}",
  "ide": "{{IDE}}",
  "active_feature": null,
  "features": {},
  "domains": [],
  "dependency_graph": {},
  "harness_version": "3.5.0",
  "user_language": "{{LANG}}",
  "audience_mode": "expert",
  "completed_cycles": 0,
  "last_updated": "{{NOW}}",
  "model": null,
  "session": { "checkpoint": null, "phase_lock": null, "messages_in_session": 0 },
  "security": { "last_scan": null, "last_gate_result": null, "exceptions_count": 0 },
  "step_budget": {
    "DISCOVERY": {"max":15,"used":0}, "SPEC": {"max":20,"used":0},
    "DESIGN":    {"max":20,"used":0}, "DATA": {"max":15,"used":0},
    "RED":       {"max":25,"used":0}, "GREEN":{"max":30,"used":0},
    "SECURITY":  {"max":10,"used":0}, "REVIEW":{"max":15,"used":0}
  },
  "token_tracking": { "tokens_estimated": 0, "cost_usd_estimated": 0.0 }
}
```

---

## ◈ STEP 5 — IDE CONFIG

Write the appropriate context file based on detected IDE:
- `claude-code` → `.claude/CLAUDE.md` (reference: `skills/reference/templates/agent-identity.md`)
- `cursor`      → `.cursor/rules/hes.mdc`
- `kiro`        → `.kiro/steering/hes.md`
- `vscode`      → `.github/copilot-instructions.md`
- `generic`     → `AGENTS.md` only

---

## ◈ STEP 6 — BOOTSTRAP TASKS FILES

→ EXECUTE (write `.hes/tasks/lessons.md`):
```markdown
# lessons.md — {{PROJECT}}

> Lessons learned from HES sessions.
> Lesson repeated 2× → promote to corresponding skill-file.

---

## Template

### Lesson N: [Title]

- Context: [what were you doing?]
- Issue: [what went wrong?]
- Resolution: [how was it fixed?]
- Prevention: [how to prevent next time?]
- Repeat count: 1
```

→ EXECUTE (write `.hes/tasks/backlog.md`):
```markdown
# backlog.md — {{PROJECT}}

> Pending features and technical debt tracked by the harness.

---

| Priority | Feature | Status | Notes |
|----------|---------|--------|-------|
| — | — | — | — |
```

---

## ◈ STEP 7 — WRITE BOOTSTRAP EVENT

→ EXECUTE
```python
python3 << 'PYEOF'
import json
from datetime import datetime, timezone

now = datetime.now(timezone.utc).isoformat()
session_id = open('.hes/state/session-id').read().strip()

event = {
  "timestamp": now, "session_id": session_id,
  "feature": "global", "from": "ZERO", "to": "HARNESS_READY",
  "agent": "hes-bootstrap",
  "metadata": {"harness_version": "3.5.0", "bootstrapped_at": now}
}

with open('.hes/state/events.log', 'a') as f:
    f.write(json.dumps(event) + '\n')
print("✓ events.log initialized")
PYEOF
```

---

## ◈ STEP 8 — SETUP VALIDATION

→ EXECUTE
```bash
python3 << 'PYEOF'
import json
from datetime import datetime, timezone

required = [
  '.hes/state/current.json',
  '.hes/state/session-id',
  '.hes/state/events.log',
  '.hes/tasks/lessons.md',
  '.hes/tasks/backlog.md',
]

import os
missing = [f for f in required if not os.path.exists(f)]
state = {"timestamp": datetime.now(timezone.utc).isoformat(),
         "status": "PASS" if not missing else "FAIL",
         "missing": missing}

json.dump(state, open('.hes/state/setup-validation.json', 'w'), indent=2)
print("setup-validation:", state["status"], "| missing:", missing or "none")
PYEOF
```

---

────────────────────────────────────────────────────────────────
  ZERO complete
  Harness installed · {{PROJECT}} · {{STACK}} · score {{SCORE}}
────────────────────────────────────────────────────────────────
  → DISCOVERY                              skills/01-discovery.md

  What is the first feature you want to build?

  💡 Name the feature as a verb phrase: "user authentication", "property search".
────────────────────────────────────────────────────────────────
