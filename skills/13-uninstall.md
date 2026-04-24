# HES Skill — 13: Uninstall

> **Trigger:** `/hes uninstall` | `/hes remove` | `/hes clean`
> **Objective:** Remove everything HES created, leaving the project in its pre-HES state.
> **Safety contract:** requires explicit double confirmation before any deletion.
> **Principle:** the harness must be removable cleanly — no residue, no side effects.

---

## ◈ AGENT EXECUTION CONTRACT

> **YOU ARE THE EXECUTOR. NOT THE NARRATOR.**
> Every step marked with `→ EXECUTE` requires you to run bash commands using your tools.
> Do NOT describe what you would do. Do NOT show commands and wait.
> Read a step → run the tool call → proceed to the next step immediately.
> The user has already confirmed. Waiting again after confirmation is a protocol violation.

---

## ◈ STEP 1 — INVENTORY (→ EXECUTE)

Run this to discover what actually exists — show only what is found:

```bash
echo "=== HES ARTIFACT SCAN ==="

echo "-- Core dirs --"
ls -d .hes/ skills/ 2>/dev/null || echo "(none)"

echo "-- Root files --"
ls SKILL.md AGENTS.md ARCHITECTURE.md INSTALL.md CHANGELOG.md \
   CONTRIBUTING.md CLAUDE.md GEMINI.md security-policy.yml setup \
   2>/dev/null || echo "(none)"

echo "-- IDE configs --"
ls -d \
  .claude/ .cursor/ .kiro/ .agents/ .opencode/ .gemini/ \
  2>/dev/null || echo "(none)"
ls \
  .github/copilot-instructions.md \
  .github/workflows/harness-validation.yml \
  .windsurfrules \
  2>/dev/null || echo "(none)"

echo "-- scripts/ --"
ls -d scripts/ 2>/dev/null || echo "(none)"
```

---

## ◈ STEP 2 — DISPLAY MANIFEST AND ASK CONFIRMATION #1

Using the scan results from Step 1, show the manifest — only items actually found.
Then display exactly:

```
⚠️  HES UNINSTALL — {{PROJECT_NAME}}

The following will be permanently removed:

  {{list from Step 1 scan — only found items}}

  NOT removed (user-owned):
    src/, app/, tests/   → application code
    package.json, pom.xml, pyproject.toml, .env

  This action is IRREVERSIBLE.

[A] yes  →  proceed to final confirmation
[B] no   →  abort, no files touched
```

**Accept any of these as confirmation #1:** `A`, `a`, `yes`, `y`, `[A]`, `yes uninstall`, `yes, uninstall HES`
→ Any affirmative proceeds. Anything else or `[B]` aborts with `❌ Uninstall cancelled.`

---

## ◈ STEP 3 — FINAL CONFIRMATION #2

Display exactly:

```
🔴 FINAL CONFIRMATION — type exactly:  REMOVE HES
```

**Wait for user input.**
- Input IS exactly `REMOVE HES` → proceed immediately to STEP 4. No further questions.
- Input is anything else → `❌ Uninstall aborted — confirmation not matched. No files removed.` → stop.

---

## ◈ STEP 4 — EXPORT + LOG FAREWELL EVENT (→ EXECUTE)

Export before anything is deleted:

```bash
DATE=$(date +%Y-%m-%d)

# Export history
cp .hes/state/events.log "hes-history-export-${DATE}.jsonl" 2>/dev/null \
  && echo "✓ Exported: hes-history-export-${DATE}.jsonl" || true

# Export lessons (may be in either location)
cp .hes/tasks/lessons.md "hes-lessons-export-${DATE}.md" 2>/dev/null \
  || cp .hes/lessons.md "hes-lessons-export-${DATE}.md" 2>/dev/null \
  && echo "✓ Exported: hes-lessons-export-${DATE}.md" || true
```

Write farewell event before `.hes/` is removed:

```python
python3 << 'PYEOF'
import json
from datetime import datetime, timezone

try:
    state = json.load(open('.hes/state/current.json'))
    session_id = open('.hes/state/session-id').read().strip()
    project  = state.get('project', 'unknown')
    version  = state.get('harness_version', 'unknown')
    cycles   = state.get('completed_cycles', 0)
    features = len(state.get('features', {}))
except Exception:
    session_id = 'unknown'; project = 'unknown'
    version = 'unknown'; cycles = 0; features = 0

now = datetime.now(timezone.utc).isoformat()
event = {
    "timestamp": now, "session_id": session_id,
    "feature": "global", "from": "HARNESS_INSTALLED", "to": "UNINSTALLED",
    "agent": "hes-uninstall",
    "metadata": { "project": project, "harness_version": version,
                  "completed_cycles": cycles, "total_features": features,
                  "uninstalled_at": now, "operator": "user-confirmed" }
}
with open('.hes/state/events.log', 'a') as f:
    f.write(json.dumps(event) + '\n')
print(f"✓ Farewell event written — {project}, {cycles} cycles, {features} features")
PYEOF
```

---

## ◈ STEP 5 — EXECUTE REMOVAL (→ EXECUTE EACH BLOCK IN ORDER)

Run each block as a separate tool call. Do not combine them.

**Block 1 — harness core:**
```bash
rm -rf .hes/   && echo "✓ .hes/ removed"   || echo "⚠ .hes/ not found"
rm -rf skills/ && echo "✓ skills/ removed" || echo "⚠ skills/ not found"
rm -f  SKILL.md && echo "✓ SKILL.md removed" || true
```

**Block 2 — HES root files:**
```bash
for f in AGENTS.md ARCHITECTURE.md INSTALL.md CHANGELOG.md CONTRIBUTING.md \
          CLAUDE.md GEMINI.md security-policy.yml setup; do
  [ -f "$f" ] && rm -f "$f" && echo "  ✓ $f" || true
done
```

**Block 3 — IDE config files:**
```bash
# File targets
rm -f .claude/CLAUDE.md                        && echo "  ✓ .claude/CLAUDE.md"          || true
rm -f .cursor/rules/hes.mdc                    && echo "  ✓ .cursor/rules/hes.mdc"      || true
rm -f .kiro/steering/hes.md                    && echo "  ✓ .kiro/steering/hes.md"      || true
rm -f .github/copilot-instructions.md          && echo "  ✓ .github/copilot-instructions.md" || true
rm -f .github/workflows/harness-validation.yml && echo "  ✓ harness-validation.yml"     || true
rm -f .windsurfrules                           && echo "  ✓ .windsurfrules"             || true

# Directory targets
rm -rf .claude/commands/   && echo "  ✓ .claude/commands/" || true
rm -rf .claude/skills/     && echo "  ✓ .claude/skills/"   || true
rm -rf .cursor/skills/     && echo "  ✓ .cursor/skills/"   || true
rm -rf .kiro/skills/       && echo "  ✓ .kiro/skills/"     || true
rm -rf .agents/skills/     && echo "  ✓ .agents/skills/"   || true
rm -rf .opencode/skills/   && echo "  ✓ .opencode/skills/" || true
rm -rf .gemini/            && echo "  ✓ .gemini/"          || true
```

**Block 4 — clean up empty parent dirs:**
```bash
for d in \
  .claude/commands .claude/skills .claude/rules .claude \
  .cursor/skills .cursor/rules .cursor \
  .kiro/skills .kiro/steering .kiro \
  .agents/skills .agents \
  .opencode/skills .opencode \
  .github/workflows .github; do
    [ -d "$d" ] && [ -z "$(ls -A "$d" 2>/dev/null)" ] \
      && rmdir "$d" && echo "  ✓ removed empty: $d" || true
done
```

**Block 5 — scripts/ if HES-generated only:**
```bash
if [ -d "scripts/" ]; then
  NON_HES=$(find scripts/ -type f 2>/dev/null \
    | grep -v -E "scripts/hooks/(log-action|step-budget|context-offload|telemetry)\.sh|scripts/ci/validate-harness\.py" \
    | wc -l)
  if [ "$NON_HES" -eq "0" ]; then
    rm -rf scripts/ && echo "  ✓ scripts/ removed (HES-only)"
  else
    echo "  ⏭  scripts/ kept — contains $NON_HES non-HES file(s)"
  fi
fi
```

**Block 6 — git hooks:**
```bash
rm -f .git/hooks/pre-commit.hes  && echo "  ✓ pre-commit.hes hook" || true
rm -f .git/hooks/commit-msg.hes  && echo "  ✓ commit-msg.hes hook" || true
```

---

## ◈ STEP 6 — VALIDATE CLEAN STATE (→ EXECUTE)

```bash
echo "=== POST-UNINSTALL VALIDATION ==="

REMAINING=""
[ -d ".hes" ]     && REMAINING="$REMAINING .hes/"
[ -d "skills" ]   && REMAINING="$REMAINING skills/"
[ -f "SKILL.md" ] && REMAINING="$REMAINING SKILL.md"
[ -d ".gemini" ]  && REMAINING="$REMAINING .gemini/"
[ -d ".claude" ]  && REMAINING="$REMAINING .claude/"
[ -d ".cursor" ]  && REMAINING="$REMAINING .cursor/"
[ -d ".kiro" ]    && REMAINING="$REMAINING .kiro/"
[ -d ".agents" ]  && REMAINING="$REMAINING .agents/"
[ -d ".opencode" ] && REMAINING="$REMAINING .opencode/"

if [ -z "$REMAINING" ]; then
  echo "✅ Clean — no HES artifacts remaining"
else
  echo "⚠️  Still present: $REMAINING"
  echo "(manual: rm -rf $REMAINING)"
fi

echo ""
echo "--- project root ---"
ls -la
```

---

## ◈ STEP 7 — ANNOUNCE COMPLETION

```
✅ HES Uninstalled — {{PROJECT_NAME}}

  Removed:
    ✓ .hes/         (harness state, specs, decisions, events)
    ✓ skills/       (all skill-files)
    ✓ SKILL.md      (orchestrator)
    ✓ IDE configs   (.claude, .cursor, .kiro, .agents, .opencode, .gemini — HES-only)
    ✓ Root files    (AGENTS.md, INSTALL.md, CLAUDE.md, GEMINI.md — HES-generated)
    ✓ scripts/      (if HES-generated only)

  Preserved:
    → Application code (src/, app/, tests/)
    → Dependency manifests (package.json, pom.xml, pyproject.toml)
    → Environment files (.env)

  Exports in project root:
    → hes-history-export-{{DATE}}.jsonl  (if events existed)
    → hes-lessons-export-{{DATE}}.md    (if lessons existed)

To reinstall: git clone https://github.com/Josemalyson/hes /tmp/hes && /tmp/hes/setup
```

---

▶ NEXT ACTION — POST-UNINSTALL

```
  [A] "reinstall HES"
      → git clone https://github.com/Josemalyson/hes /tmp/hes
      → cd <project> && /tmp/hes/setup

  [B] "nothing, I'm done"
      → Session ends here

📄 Skill-file: (terminal state)
💡 Tip: hes-history-export-*.jsonl and hes-lessons-export-*.md stay in the project root.
```
