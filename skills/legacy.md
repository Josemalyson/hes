# HES Skill — Legacy / Orphan: Automated Inventory + Auto-Bootstrap

> **Loaded when:** ORPHAN (.hes/ without current.json) OR LEGACY (existing src/ without .hes/).
> **Execution mode: FULLY AUTOMATED** — same convergence target as ZERO: HARNESS_READY.
> **No user menus.** Run inventory, assess, install, announce HARNESS_READY, ask first feature.
>
> "Legacy teams face the harder problem: the harness is most needed where it is hardest to build."
> — Fowler, 2026

---

## ◈ CONVERGENCE CONTRACT

ORPHAN, LEGACY, and ZERO are **three parallel paths to the same destination**:

```
ZERO    ──────────────────────────────────────────────────────► HARNESS_READY
ORPHAN  → auto-detect artifacts → fill gaps → rebuild state  ► HARNESS_READY
LEGACY  → auto-inventory → harnessability → full bootstrap   ► HARNESS_READY
```

Every path MUST terminate at HARNESS_READY before the first feature starts.
User confirmation is required **once**: the name of the first feature.

---

## ◈ STEP 0 — DETECT SUBTYPE (automated)

```
1. Check .hes/state/current.json:
   → EXISTS    → ORPHAN path (state file missing, reconstruct from artifacts)
   → MISSING   → LEGACY path (no .hes/ at all, full install)

2. Log detection:
   bash scripts/hooks/log-action.sh LLM_DECISION STARTED \
     "legacy-detect" "detecting subtype: ORPHAN or LEGACY"
```

---

## ◈ PATH A — ORPHAN (automated recovery)

> .hes/ exists but current.json is missing or corrupt.
> Reconstruct state from existing artifacts — do NOT overwrite real work.

### A1 — Reconstruct state from artifacts

```bash
bash scripts/hooks/log-action.sh READ_FILE STARTED ".hes/" "scanning orphan artifacts"

# Scan existing artifacts
find .hes/specs/ -name "*.md" 2>/dev/null | sort
find .hes/decisions/ -name "*.md" 2>/dev/null | sort
ls .hes/state/ 2>/dev/null || true
```

Infer from artifacts:
- `features` map → scan `.hes/specs/{feature}/` directories
- `domains` → scan `.hes/domains/` directories
- `stack` → detect from pom.xml / package.json / pyproject.toml
- `project` → git remote or directory name

### A2 — Rebuild current.json

Generate current.json with inferred values:

```json
{
  "project": "{{INFERRED}}",
  "stack": "{{INFERRED}}",
  "ide": "{{DETECTED}}",
  "active_feature": null,
  "features": { "{{RECOVERED_FEATURE}}": "{{LAST_KNOWN_PHASE}}" },
  "domains": ["{{RECOVERED}}"],
  "dependency_graph": {},
  "harness_version": "3.5.0",
  "user_language": "{{DETECTED}}",
  "audience_mode": "expert",
  "completed_cycles": 0,
  "last_updated": "{{NOW}}",
  "security": { "last_scan": null, "last_gate_result": null, "exceptions_count": 0 },
  "session": { "checkpoint": null, "phase_lock": null, "messages_in_session": 0 }
}
```

### A3 — Fill missing artifacts

Run INSTALLED_INCOMPLETE check (same as SKILL.md Step 0):

```
REQUIRED = [
  ".hes/tasks/lessons.md",
  ".hes/tasks/backlog.md",
  ".hes/state/session-checkpoint.json",
  ".hes/state/setup-validation.json",
  ".hes/state/session-id",
  "<IDE_CONFIG>"
]
→ Generate each missing artifact silently
```

### A4 — Log recovery event

```json
{
  "timestamp": "{{NOW}}",
  "feature": "global",
  "from": "ORPHAN",
  "to": "HARNESS_READY",
  "agent": "hes-legacy-agent",
  "metadata": {
    "subtype": "ORPHAN",
    "recovered_features": ["{{LIST}}"],
    "artifacts_rebuilt": ["{{LIST}}"]
  }
}
```

---

## ◈ PATH B — LEGACY (automated full install)

> No .hes/ exists. Project has src/ code. Run inventory then bootstrap.

### B1 — Auto-inventory (no questions asked)

```bash
bash scripts/hooks/log-action.sh EXEC_CMD STARTED "auto-inventory" "scanning project"

# Project name
PROJECT=$(git remote get-url origin 2>/dev/null | sed 's/.*\///' | sed 's/\.git//' || basename "$(pwd)")

# Stack detection
STACK=""
[ -f "pom.xml" ]          && STACK="Java + Maven"
[ -f "build.gradle" ]     && STACK="Java + Gradle"
[ -f "package.json" ]     && STACK="Node.js + $(node -e "console.log(require('./package.json').dependencies?.express ? 'Express' : 'Unknown')" 2>/dev/null || echo 'npm')"
[ -f "pyproject.toml" ]   && STACK="Python + $(grep 'fastapi\|django\|flask' pyproject.toml -i -m1 | awk -F'[=^~]' '{print $1}' | tr -d '\" ' || echo 'Python')"
[ -f "requirements.txt" ] && STACK="Python + pip"
[ -f "go.mod" ]           && STACK="Go"
[ -f "Cargo.toml" ]       && STACK="Rust + Cargo"
[ -z "$STACK" ]           && STACK="Unknown (set manually in current.json)"

# IDE detection
IDE="generic"
[ -d ".claude" ]   && IDE="claude-code"
[ -d ".cursor" ]   && IDE="cursor"
[ -d ".vscode" ]   && IDE="vscode"
[ -d ".windsurf" ] && IDE="windsurf"
[ -d ".kiro" ]     && IDE="kiro"

# Domain scan
DOMAINS=$(find src -maxdepth 3 -type d 2>/dev/null | grep -E 'domain|module|bounded' | sed 's/.*\///' | sort -u | paste -sd ',' || echo "")
```

### B2 — Harnessability assessment (LLM auto-scores)

Assess silently and store in setup-validation.json:

```
TYPING:      strongly_typed? (Java/TS/Go/Kotlin = HIGH, Python = MEDIUM, JS = LOW)
MODULARITY:  clear src/domain|module|service structure? (HIGH/MEDIUM/LOW)
TESTABILITY: test suite present? coverage >= 60%? DI used? (HIGH/MEDIUM/LOW)

OVERALL_SCORE = min(TYPING, MODULARITY, TESTABILITY)
```

Record to `.hes/state/setup-validation.json`:
```json
{
  "timestamp": "{{NOW}}",
  "subtype": "LEGACY",
  "harnessability": { "typing": "...", "modularity": "...", "testability": "...", "score": "HIGH|MEDIUM|LOW" },
  "project": "{{PROJECT}}", "stack": "{{STACK}}", "ide": "{{IDE}}",
  "structure_valid": true,
  "issues": []
}
```

### B3 — Generate full .hes/ structure (mirrors 00-bootstrap.md)

```bash
bash scripts/hooks/log-action.sh EXEC_CMD STARTED "mkdir .hes" "creating harness structure"

mkdir -p .hes/state .hes/specs .hes/decisions .hes/tasks .hes/inventory .hes/context/tool-outputs

python3 -c "import uuid; print(str(uuid.uuid4()))" > .hes/state/session-id

bash scripts/hooks/log-action.sh EXEC_CMD SUCCESS "mkdir .hes" "structure created"
```

Generate `current.json`, `events.log`, `session-checkpoint.json`, `lessons.md`, `backlog.md` —
all using the same templates as `00-bootstrap.md` Steps 3–7.

### B4 — Install IDE config (mirrors 00-bootstrap.md Step 5)

Load and apply `skills/reference/templates/agent-identity.md` for detected IDE.

### B5 — Generate inventory files

Generate `.hes/inventory/architecture.md` and `.hes/inventory/tech-debt.md`
with auto-filled values from B1 scan (no user input required).

### B6 — Configure fitness sensors proportional to harnessability score

```
HIGH   → Full ArchUnit/dep-cruiser/import-linter + coverage ≥ 80%
MEDIUM → Linter + git hooks + coverage ≥ 60% (evolve to 80%)
LOW    → Git hooks only (LLM-executed) + note in CLAUDE.md
```

### B7 — Log install event

```json
{
  "timestamp": "{{NOW}}",
  "feature": "global",
  "from": "LEGACY",
  "to": "HARNESS_READY",
  "agent": "hes-legacy-agent",
  "metadata": {
    "subtype": "LEGACY",
    "stack": "{{STACK}}",
    "harnessability_score": "{{SCORE}}",
    "ide": "{{IDE}}",
    "harness_version": "3.5.0"
  }
}
```

---

## ◈ STEP FINAL — ANNOUNCE HARNESS_READY (both paths)

```
✅ HES Harness Ready — {{PROJECT_NAME}}
   Path     : {{ORPHAN | LEGACY}} → HARNESS_READY
   Stack    : {{STACK}}
   IDE      : {{IDE}}
   Score    : {{HARNESSABILITY or N/A for ORPHAN}}
   State    : current.json ✅ | events.log ✅ | lessons.md ✅
```

Then immediately:

```
What is the first feature you want to develop?
```

→ On answer: set `active_feature`, transition to DISCOVERY, load `skills/01-discovery.md`.

---

▶ NEXT ACTION — DISCOVERY

```
  → "I want to implement [feature name]"
    ✓ Updates current.json: active_feature + features[name] = "DISCOVERY"
    ✓ Logs HARNESS_READY → DISCOVERY transition
    ✓ Loads skills/01-discovery.md

📄 Next skill-file: skills/01-discovery.md
💡 Tip: ORPHAN/LEGACY → HARNESS_READY is automatic. You never need to run it manually.
   It self-heals the harness and converges to the same state as a clean install.
```
