# HES — Action Event Protocol (v3.4.0)
# Mandatory intra-phase traceability protocol
# Resolves: debug/tracking gap inside each phase of the workflow

---

## ◈ PROBLEM SOLVED

The original `events.log` recorded only phase transitions (e.g., `SPEC → DESIGN`).
Inside each phase, LLM actions were invisible. This protocol covers that gap.

---

## ◈ EVENT CONTRACT

```json
{
  "timestamp":      "2026-04-18T10:30:00.000000+00:00",
  "session_id":     "uuid-gerado-no-bootstrap-imutável-na-sessão",
  "action_id":      "abc12345",
  "feature":        "payment",
  "phase":          "GREEN",
  "action_type":    "EXEC_CMD",
  "status":         "SUCCESS",
  "details": {
    "target":          "pytest tests/unit/",
    "result_summary":  "42 passed, 0 failed"
  }
}
```

### Required fields

| Field | Type | Description |
|---|---|---|
| timestamp | ISO8601 | Exact moment of the action |
| session_id | UUID | Generated at bootstrap, immutable during session |
| action_id | string | Short UUID (8 chars) — identifies a unique action |
| feature | string | Active feature (from current.json.active_feature) |
| phase | string | Current phase (from current.json.features[feature]) |
| action_type | enum | Action type (see table below) |
| status | enum | STARTED \| SUCCESS \| FAILED \| SKIPPED |
| details.target | string | File, command, or action target |
| details.result_summary | string | Result summary (1 line) |

---

## ◈ ACTION TYPES

| action_type | When to use |
|---|---|
| READ_FILE | When reading any project file |
| WRITE_FILE | When creating or modifying any file |
| EXEC_CMD | When executing any shell command |
| GENERATE_ARTIFACT | When generating spec, ADR, migration, test suite, etc. |
| LLM_DECISION | When making an architectural or design decision |
| TOOL_CALL | When invoking an external tool (bandit, semgrep, etc.) |
| GATE_CHECK | When verifying a phase advancement gate |
| SECURITY_SCAN | Specific for security scans (alias of TOOL_CALL) |

---

## ◈ HOW TO USE (LLM)

Every significant action MUST be wrapped by two log calls: `STARTED` and `SUCCESS`/`FAILED`.

```bash
# STANDARD — every action executed by the LLM:
bash scripts/hooks/log-action.sh EXEC_CMD STARTED "pytest tests/" "running suite"

# ... executa a ação ...

bash scripts/hooks/log-action.sh EXEC_CMD SUCCESS "pytest tests/" "42 passed, 0 failed"
```

### Pattern for errors

```bash
bash scripts/hooks/log-action.sh EXEC_CMD STARTED "mvn compile" "compiling"

# ... ação falha ...

bash scripts/hooks/log-action.sh EXEC_CMD FAILED "mvn compile" "BUILD FAILURE: ClassNotFound XyzService"
```

---

## ◈ SESSION ID

Generated automatically at bootstrap (`00-bootstrap.md` STEP 2):

```bash
python3 -c "import uuid; print(str(uuid.uuid4()))" > .hes/state/session-id
```

- **Immutable** during the session
- **Regenerated** on each new bootstrap
- **Used** by `log-action.sh` to group events from the same session

---

## ◈ QUERYING THE LOG

```bash
# View all actions of the current session
SESSION=$(cat .hes/state/session-id)
grep "$SESSION" .hes/state/events.log | python3 -m json.tool

# Timeline of a feature
python3 -c "
import json
feature = 'payment'
events = [json.loads(l) for l in open('.hes/state/events.log') if l.strip()]
for e in events:
    if e.get('feature') == feature:
        print(f\"{e['timestamp'][:19]} [{e['phase']:10}] {e['action_type']:20} {e['status']:8} — {e['details']['target']}\")
"

# View failures only
python3 -c "
import json
events = [json.loads(l) for l in open('.hes/state/events.log') if l.strip()]
failures = [e for e in events if e.get('status') == 'FAILED']
for f in failures:
    print(json.dumps(f, indent=2))
"

# Statistics by type
python3 -c "
import json
from collections import Counter
events = [json.loads(l) for l in open('.hes/state/events.log') if l.strip()]
print(Counter(e['action_type'] for e in events))
"
```

---

## ◈ REQUIRED ACTIONS PER PHASE

| Phase | Minimum actions to log |
|---|---|
| ZERO | GENERATE_ARTIFACT (.hes/ structure), WRITE_FILE |
| DISCOVERY | LLM_DECISION (each captured business rule) |
| SPEC | GENERATE_ARTIFACT (BDD scenarios, API contracts) |
| DESIGN | GENERATE_ARTIFACT (ADRs), LLM_DECISION (arch decisions) |
| DATA | WRITE_FILE (migrations, DTOs) |
| RED | WRITE_FILE (test files), EXEC_CMD (test runner) |
| GREEN | WRITE_FILE (impl files), EXEC_CMD (build, tests) |
| SECURITY | TOOL_CALL (bandit/semgrep), WRITE_FILE (fixes), GATE_CHECK |
| REVIEW | GATE_CHECK (5 dimensions), LLM_DECISION |

---

## ◈ RULE-24 (added to SKILL.md)

```
RULE-24  LLM LOGS every significant action via scripts/hooks/log-action.sh
         YOU call log-action.sh BEFORE (STARTED) and AFTER (SUCCESS|FAILED) each action
         Actions without logs = invisible to the harness = NOT executed per protocol
         Minimum: every EXEC_CMD, WRITE_FILE, GENERATE_ARTIFACT, GATE_CHECK must be logged
```
