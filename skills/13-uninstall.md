# HES Skill — 13: Uninstall

> **Trigger:** `/hes uninstall` | `/hes remove` | `/hes clean`
> **Objective:** Remove everything HES created, leaving the project in its pre-HES state.
> **Safety contract:** requires explicit double confirmation before any deletion.
> **Principle:** the harness must be removable cleanly — no residue, no side effects.

---

## ◈ AGENT EXECUTION CONTRACT

> **YOU ARE THE EXECUTOR. NOT THE NARRATOR.**
> Every step marked with `→ EXECUTE` requires you to run the bash commands using your tools.
> Do NOT describe what you would do. Do NOT show commands and wait.
> Read a step → run the tool call → proceed to next step.
> The user has already confirmed. Waiting again is a protocol violation.

---

## ◈ STEP 1 — INVENTORY (→ EXECUTE)

Run these commands immediately to build the removal manifest:

```bash
# Show what exists in the project root
ls -la | grep -E "SKILL\.md|AGENTS\.md|ARCHITECTURE\.md|INSTALL\.md|CHANGELOG\.md|security-policy\.yml|setup$"

# Show HES directories
ls -d .hes/ skills/ 2>/dev/null && echo "HES dirs present" || echo "HES dirs not found"

# Show IDE config files created by HES
ls .claude/CLAUDE.md .claude/commands/ \
   .cursor/skills/ .cursor/rules/hes.mdc \
   .kiro/skills/ .kiro/steering/hes.md \
   .agents/skills/ \
   .github/copilot-instructions.md \
   .github/workflows/harness-validation.yml \
   .windsurfrules \
   .gemini/ 2>/dev/null || true
```

After running: populate the manifest with real findings (only items that actually exist).

---

## ◈ STEP 2 — DISPLAY MANIFEST AND ASK CONFIRMATION #1

Show only files/dirs that were found in Step 1. Then ask:

```
⚠️  HES UNINSTALL — {{PROJECT_NAME}}

The following will be permanently removed:

  DIRECTORIES (found):
    {{list from Step 1}}

  ROOT FILES (found):
    {{list from Step 1}}

  IDE CONFIG (found):
    {{list from Step 1}}

  NOT removed (user-owned):
    src/, app/, tests/ — application code
    package.json, pom.xml, pyproject.toml, .env

  This action is IRREVERSIBLE.

[A] "yes, uninstall HES"  → proceed to final confirmation
[B] "cancel"              → abort immediately
```

If [B] → log `UNINSTALL CANCELLED`, stop. No files touched.

---

## ◈ STEP 3 — FINAL CONFIRMATION #2

Ask exactly this:

```
🔴 FINAL CONFIRMATION

Type exactly: REMOVE HES
```

**Wait for user input.**

- If input IS exactly `REMOVE HES` → proceed immediately to STEP 4, no further questions.
- If input is anything else → respond: `❌ Uninstall aborted — no files were removed.` → stop.

---

## ◈ STEP 4 — LOG FAREWELL EVENT (→ EXECUTE)

Write to events.log BEFORE deleting anything:

```bash
python3 << 'PYEOF'
import json
from datetime import datetime, timezone

try:
    state = json.load(open('.hes/state/current.json'))
    session_id = open('.hes/state/session-id').read().strip()
    project = state.get('project', 'unknown')
    version = state.get('harness_version', 'unknown')
    cycles  = state.get('completed_cycles', 0)
    features = len(state.get('features', {}))
except Exception:
    session_id = 'unknown'
    project = 'unknown'
    version = 'unknown'
    cycles = 0
    features = 0

now = datetime.now(timezone.utc).isoformat()

event = {
    "timestamp": now,
    "session_id": session_id,
    "feature": "global",
    "from": "HARNESS_INSTALLED",
    "to": "UNINSTALLED",
    "agent": "hes-uninstall",
    "metadata": {
        "project": project,
        "harness_version": version,
        "completed_cycles": cycles,
        "total_features": features,
        "uninstalled_at": now,
        "operator": "user-confirmed"
    }
}

with open('.hes/state/events.log', 'a') as f:
    f.write(json.dumps(event) + '\n')

print(f"✓ Farewell event written — project: {project}, cycles: {cycles}")
PYEOF
```

Then export history before it's gone:

```bash
DATE=$(date +%Y-%m-%d)
cp .hes/state/events.log  "hes-history-export-${DATE}.jsonl"  2>/dev/null && echo "✓ Exported: hes-history-export-${DATE}.jsonl"
cp .hes/tasks/lessons.md  "hes-lessons-export-${DATE}.md"     2>/dev/null && echo "✓ Exported: hes-lessons-export-${DATE}.md" || true
```

---

## ◈ STEP 5 — EXECUTE REMOVAL (→ EXECUTE EACH BLOCK IN ORDER)

**Run each block separately. Do not skip any.**

**Block 1 — remove harness core:**
```bash
rm -rf .hes/ && echo "✓ removed: .hes/"
rm -rf skills/ && echo "✓ removed: skills/"
rm -f SKILL.md && echo "✓ removed: SKILL.md"
```

**Block 2 — remove HES root files:**
```bash
for f in AGENTS.md ARCHITECTURE.md INSTALL.md CHANGELOG.md CONTRIBUTING.md security-policy.yml setup; do
  [ -f "$f" ] && rm -f "$f" && echo "  ✓ removed: $f"
done
```

**Block 3 — remove IDE config files:**
```bash
rm -f  .claude/CLAUDE.md         && echo "  ✓ .claude/CLAUDE.md" || true
rm -rf .claude/commands/          && echo "  ✓ .claude/commands/" || true
rm -f  .cursor/rules/hes.mdc     && echo "  ✓ .cursor/rules/hes.mdc" || true
rm -rf .cursor/skills/            && echo "  ✓ .cursor/skills/" || true
rm -f  .kiro/steering/hes.md     && echo "  ✓ .kiro/steering/hes.md" || true
rm -rf .kiro/skills/              && echo "  ✓ .kiro/skills/" || true
rm -f  .github/copilot-instructions.md                 && echo "  ✓ .github/copilot-instructions.md" || true
rm -f  .github/workflows/harness-validation.yml        && echo "  ✓ harness-validation.yml" || true
rm -rf .agents/skills/            && echo "  ✓ .agents/skills/" || true
rm -f  .windsurfrules             && echo "  ✓ .windsurfrules" || true
rm -rf .gemini/                   && echo "  ✓ .gemini/" || true
```

**Block 4 — remove empty IDE dirs:**
```bash
for d in .claude .cursor .kiro .agents .github/workflows .github; do
  [ -d "$d" ] && [ -z "$(ls -A "$d" 2>/dev/null)" ] && rmdir "$d" && echo "  ✓ removed empty dir: $d/" || true
done
```

**Block 5 — remove scripts/ if HES-generated only:**
```bash
NON_HES=$(find scripts/ -type f 2>/dev/null \
  | grep -v -E "scripts/hooks/(log-action|step-budget|context-offload|telemetry)\.sh|scripts/ci/validate-harness\.py" \
  | wc -l)
if [ "$NON_HES" -eq "0" ] && [ -d "scripts/" ]; then
  rm -rf scripts/ && echo "  ✓ removed: scripts/ (HES-generated only)"
else
  echo "  ⏭  scripts/ kept — contains user files"
fi
```

**Block 6 — remove git hooks if HES-installed:**
```bash
rm -f .git/hooks/pre-commit.hes && echo "  ✓ git hook removed" || true
rm -f .git/hooks/commit-msg.hes && echo "  ✓ git hook removed" || true
```

---

## ◈ STEP 6 — VALIDATE CLEAN STATE (→ EXECUTE)

```bash
REMAINING=""
[ -d ".hes" ]     && REMAINING="$REMAINING .hes/"
[ -d "skills" ]   && REMAINING="$REMAINING skills/"
[ -f "SKILL.md" ] && REMAINING="$REMAINING SKILL.md"

if [ -z "$REMAINING" ]; then
  echo "✅ Clean — no HES artifacts remaining"
else
  echo "⚠️  Still present: $REMAINING"
fi

# Show what's left in the project root
echo "--- project root after uninstall ---"
ls -la
```

---

## ◈ STEP 7 — ANNOUNCE COMPLETION

After Step 6 output, display:

```
✅ HES Uninstalled — {{PROJECT_NAME}}

  Removed:
    ✓ .hes/         (harness state, specs, decisions, events)
    ✓ skills/       (all skill-files)
    ✓ SKILL.md      (orchestrator)
    ✓ IDE configs   (.claude/, .cursor/, .kiro/, .agents/ — HES-only)
    ✓ scripts/      (if HES-generated)

  Preserved:
    → Application code (src/, app/, tests/)
    → Dependency manifests (package.json, pom.xml, pyproject.toml)
    → Environment files (.env)

  Exports in project root (if they existed):
    → hes-history-export-{{DATE}}.jsonl
    → hes-lessons-export-{{DATE}}.md

The project is clean. HES has been fully removed.
To reinstall: clone https://github.com/Josemalyson/hes and run ./setup
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
💡 Tip: hes-history-export-*.jsonl and hes-lessons-export-*.md are in the project root.
```
