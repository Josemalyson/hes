# HES Skill — 10: Security Scan (SECURITY Phase)

> Skill loaded when: feature.state = SECURITY
> Pre-condition: GREEN phase complete (build + all tests passing)
> Manual invocation: /hes security
>
> Role in harness: **Computational Sensor — Security Fitness**
> Runs open-source security tools (Bandit + Semgrep) on the developer's machine.
> The LLM reads the output, fixes findings, and re-runs until the gate is satisfied.

---

## ◈ TOOLS

| Tool | Scope | Installation | Output |
|---|---|---|---|
| Bandit | Python (primary — 82.9% of the project) | `pip install bandit` | JSON |
| Semgrep | Shell/Multi (secondary — 17.1%) | `pip install semgrep` | JSON |

---

## ◈ CONTEXT TO LOAD BEFORE ACTING

```
1. Read .hes/state/current.json → active_feature, session_id
2. Verify build is green (GREEN gate must be satisfied)
3. Identify file types in project (Python vs Shell ratio)
```

---

## ◈ STEP 0 — LOG START

```bash
bash scripts/hooks/log-action.sh TOOL_CALL STARTED "security-scan" "starting SECURITY phase"
```

---

## ◈ STEP 1 — PRE-FLIGHT: VERIFY TOOLS

```bash
# Verify Bandit
if ! pip show bandit &>/dev/null 2>&1; then
  bash scripts/hooks/log-action.sh TOOL_CALL STARTED "pip install bandit" "installing"
  pip install bandit --break-system-packages -q
  bash scripts/hooks/log-action.sh TOOL_CALL SUCCESS "pip install bandit" "installed"
fi

# Detect Shell files
SHELL_FILES=$(find . -name "*.sh" \
  -not -path "./.git/*" \
  -not -path "./.hes/*" \
  -not -path "./venv/*" \
  -not -path "./node_modules/*" | wc -l | tr -d ' ')

# Verify Semgrep (only if Shell files exist)
if [ "$SHELL_FILES" -gt 0 ] && ! pip show semgrep &>/dev/null 2>&1; then
  bash scripts/hooks/log-action.sh TOOL_CALL STARTED "pip install semgrep" "installing"
  pip install semgrep --break-system-packages -q
  bash scripts/hooks/log-action.sh TOOL_CALL SUCCESS "pip install semgrep" "installed"
fi
```

---

## ◈ STEP 2 — RUN BANDIT (Python)

```bash
bash scripts/hooks/log-action.sh EXEC_CMD STARTED "bandit -r ." "running Python scan"

bandit -r . \
  --exclude ./.hes,./venv,./.git,./node_modules,./dist,./build \
  -f json \
  -o .hes/state/security-report.json \
  --exit-zero

BANDIT_VERSION=$(pip show bandit | grep Version | awk '{print $2}')
bash scripts/hooks/log-action.sh EXEC_CMD SUCCESS "bandit -r ." "report generated (bandit v$BANDIT_VERSION)"
```

---

## ◈ STEP 3 — RUN SEMGREP (Shell), if applicable

```bash
if [ "$SHELL_FILES" -gt 0 ]; then
  bash scripts/hooks/log-action.sh EXEC_CMD STARTED "semgrep p/shell-hardening" "scanning shell files"

  semgrep --config=p/shell-hardening \
    --exclude=".hes" --exclude="venv" --exclude=".git" \
    --json \
    --output .hes/state/semgrep-report.json \
    . 2>/dev/null || true

  bash scripts/hooks/log-action.sh EXEC_CMD SUCCESS "semgrep p/shell-hardening" "report generated"
else
  bash scripts/hooks/log-action.sh EXEC_CMD SKIPPED "semgrep" "no Shell files detected"
fi
```

---

## ◈ STEP 4 — PARSE AND TRIAGE FINDINGS

The LLM runs this script to extract and classify findings:

```python
import json

with open(".hes/state/security-report.json") as f:
    report = json.load(f)

by_severity = {"HIGH": [], "MEDIUM": [], "LOW": []}

for r in report.get("results", []):
    sev = r.get("issue_severity", "LOW").upper()
    by_severity.setdefault(sev, []).append({
        "test_id":    r["test_id"],
        "file":       r["filename"],
        "line":       r["line_number"],
        "issue":      r["issue_text"],
        "confidence": r.get("issue_confidence", "MEDIUM"),
        "code":       r.get("code", "")
    })

print(json.dumps(by_severity, indent=2))
```

**Triage rules:**

| Severity | LLM Action |
|---|---|
| HIGH | Blocks advancement. LLM fixes IMMEDIATELY. |
| MEDIUM | LLM analyzes context. Fixes OR documents exception with justification. |
| LOW | LLM documents in `security-exceptions.json`. Does not block. |

---

## ◈ STEP 5 — AUTO-FIX (HIGH and selected MEDIUM)

For each finding to fix, the LLM runs the loop:

```
1. bash scripts/hooks/log-action.sh WRITE_FILE STARTED "{file}:{line}" "fixing {test_id}"

2. LLM reads the file with context (±15 surrounding lines)

3. LLM applies fix according to the guide below

4. LLM writes the corrected file

5. LLM re-runs bandit on the file only:
   bandit {file} -f json --exit-zero

6. If finding is gone:
   bash scripts/hooks/log-action.sh WRITE_FILE SUCCESS "{file}:{line}" "{test_id} fixed"

7. If persists (attempt 1 → 2):
   → LLM tries alternative approach

8. If still persists after 2 attempts:
   bash scripts/hooks/log-action.sh WRITE_FILE FAILED "{file}:{line}" "{test_id} — requires manual intervention"
   → LLM documents as exception with detailed technical justification
   → LLM escalates to user if HIGH
```

### Fix guide by test_id

| test_id | Problem | Default fix |
|---|---|---|
| B101 | assert in prod | Replace with `raise ValueError` or explicit `if/raise` |
| B105/B106/B107 | Hardcoded credential | `os.environ.get('VAR_NAME')` or `secrets` manager |
| B301/B302 | pickle inseguro | Replace with `json.loads()` ou `orjson` |
| B311 | random for security | `secrets.token_hex(16)` ou `secrets.randbelow(n)` |
| B324 | MD5/SHA1 | `hashlib.sha256(data).hexdigest()` |
| B501/B502/B503 | TLS/SSL fraco | `ssl.PROTOCOL_TLS_CLIENT` + `check_hostname=True` |
| B601/B602/B603 | Shell injection | `subprocess.run([cmd, arg], shell=False)` |
| B608 | SQL injection | Prepared parameters: `cursor.execute(sql, (param,))` |
| B701/B702 | Jinja2 without autoescape | `Environment(autoescape=True)` |

---

## ◈ STEP 6 — DOCUMENT EXCEPTIONS

For unresolved MEDIUM/LOW (or non-auto-fixable HIGH):

```python
import json
from datetime import datetime, timezone

exceptions = [
    {
        "test_id": "B311",
        "file": "path/to/file.py",
        "line": 42,
        "severity": "MEDIUM",
        "justification": "random() used only for mocks in tests, not in production",
        "decided_by": "LLM",
        "timestamp": datetime.now(timezone.utc).isoformat()
    }
]

with open(".hes/state/security-exceptions.json", "w") as f:
    json.dump(exceptions, f, indent=2)
```

```bash
bash scripts/hooks/log-action.sh GENERATE_ARTIFACT SUCCESS "security-exceptions.json" \
  "$(python3 -c "import json; e=json.load(open('.hes/state/security-exceptions.json')); print(f'{len(e)} exceções documentadas')")"
```

---

## ◈ STEP 7 — FULL RE-SCAN

```bash
bash scripts/hooks/log-action.sh EXEC_CMD STARTED "bandit final re-scan" "validating fixes"

bandit -r . \
  --exclude ./.hes,./venv,./.git,./node_modules,./dist,./build \
  -f json \
  -o .hes/state/security-report-final.json \
  --exit-zero

bash scripts/hooks/log-action.sh EXEC_CMD SUCCESS "bandit final re-scan" \
  "final report generated at .hes/state/security-report-final.json"
```

---

## ◈ STEP 8 — GATE CHECK

```python
import json, sys

with open(".hes/state/security-report-final.json") as f:
    report = json.load(f)

high = [r for r in report.get("results", []) if r["issue_severity"] == "HIGH"]

if high:
    print(f"GATE FAILED: {len(high)} HIGH finding(s) remaining")
    for h in high:
        print(f"  [{h['test_id']}] {h['filename']}:{h['line_number']} — {h['issue_text']}")
    sys.exit(1)
else:
    print("GATE PASSED: zero HIGH findings")
```

```bash
if python3 .hes/scripts/check-security-gate.py; then
  bash scripts/hooks/log-action.sh GATE_CHECK SUCCESS "security-gate" "zero HIGH findings — advancing to REVIEW"
  GATE_PASSED=true
else
  bash scripts/hooks/log-action.sh GATE_CHECK FAILED "security-gate" "HIGH findings remaining — blocked"
  GATE_PASSED=false
fi
```

---

## ◈ STEP 9 — LOG PHASE TRANSITION EVENT

```python
import json
from datetime import datetime, timezone

with open(".hes/state/security-report-final.json") as f:
    final = json.load(f)

results = final.get("results", [])
by_sev = {"HIGH": 0, "MEDIUM": 0, "LOW": 0}
for r in results:
    by_sev[r["issue_severity"]] = by_sev.get(r["issue_severity"], 0) + 1

with open(".hes/state/security-exceptions.json") as f:
    exceptions = json.load(f)

# Read current state
with open(".hes/state/current.json") as f:
    state = json.load(f)
feature = state.get("active_feature", "unknown")

event = {
    "timestamp": datetime.now(timezone.utc).isoformat(),
    "session_id": open(".hes/state/session-id").read().strip(),
    "feature": feature,
    "from": "SECURITY",
    "to": "REVIEW" if by_sev["HIGH"] == 0 else "SECURITY",
    "agent": "security-agent",
    "metadata": {
        "tool": "bandit+semgrep",
        "findings_final": by_sev,
        "exceptions_documented": len(exceptions),
        "gate_passed": by_sev["HIGH"] == 0
    }
}

with open(".hes/state/events.log", "a") as f:
    f.write(json.dumps(event) + "\n")
```

---

## ◈ STEP 10 — UPDATE STATE

If gate passed:

```python
import json
from datetime import datetime, timezone

with open(".hes/state/current.json") as f:
    state = json.load(f)

feature = state.get("active_feature")
state["features"][feature] = "REVIEW"
state["last_updated"] = datetime.now(timezone.utc).isoformat()

with open(".hes/state/current.json", "w") as f:
    json.dump(state, f, indent=2)
```

```bash
bash scripts/hooks/log-action.sh WRITE_FILE SUCCESS "current.json" "state → REVIEW"
```

---

## ◈ REPORT FORMAT (display to user)

```
🔐 HES Security Scan — {feature}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tools        : bandit v{version} | semgrep v{version}
Files        : {N} Python | {M} Shell

FINDINGS (pre-fix):
  🔴 HIGH   : {N_h} → {fixed_h} auto-fixed
  🟡 MEDIUM : {N_m} → {fixed_m} fixed, {exc_m} excepted
  🟢 LOW    : {N_l} → documented

FINAL RESULT:
  🔴 HIGH   : 0  ← required for gate
  🟡 MEDIUM : {remaining_m}
  🟢 LOW    : {remaining_l}

GATE: ✅ PASSED — advancing to REVIEW
      ❌ BLOCKED — fix HIGH findings before continuing
```

---

## ◈ ADVANCEMENT GATE (mandatory)

The LLM ONLY advances to REVIEW if ALL conditions are met:

```
[ ] security-report-final.json generated
[ ] zero HIGH findings in final report
[ ] all MEDIUM with decision: fixed OR exception documented
[ ] security-exceptions.json exists (may be [])
[ ] phase event logged in events.log
[ ] current.json updated: features[feature] = "REVIEW"
```

---

## ◈ MANUAL INVOCATION

```
/hes security           → runs full scan on current feature
/hes security --report  → displays last report without re-running scan
```

---

▶ NEXT ACTION — REVIEW

```
🔐 Security scan complete.

  [A] "gate passed, zero HIGH"
      → Advancing to REVIEW (skills/07-review.md)

  [B] "HIGH finding {test_id} in {file}:{line}"
      → Auto-fix loop (STEP 5) — attempt {N}/2

  [C] "gate failed after 2 attempts"
      → Escalate to user — list blocking findings

📄 Next skill-file: skills/07-review.md
🤖 Agent: review-agent
💡 Tip: Security scan runs BEFORE code review.
   It makes no sense to review code containing known vulnerabilities.
   Tool-first, human-review-second.
```
