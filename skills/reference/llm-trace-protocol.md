# HES — LLM Trace Protocol (v3.5.0)
# Full execution tracing: one event BEFORE the LLM generates a response,
# one event AFTER, creating a complete request/response trace in events.log.
#
# This is the execution-level visibility layer:
#   events.log now contains BOTH intra-phase action events (action-event-protocol.md)
#   AND the surrounding LLM request/response envelope for every turn.

---

## ◈ PROBLEM SOLVED

`action-event-protocol.md` captures what the LLM *does* inside a phase
(WRITE_FILE, EXEC_CMD, GATE_CHECK, etc.).

But the LLM *decision boundary* itself — what was asked, what was answered,
how many tokens, how long it took — was invisible.

This protocol adds two new event types that wrap every LLM response:

```
USER MESSAGE arrives
  ↓
  [LLM_REQUEST  event written] ← BEFORE the LLM generates anything
  ↓
  LLM generates response (runs skill-file, calls tools, writes files...)
  ↓
  [LLM_RESPONSE event written] ← AFTER response is finalized
  ↓
USER sees response
```

The pair `(LLM_REQUEST, LLM_RESPONSE)` shares the same `trace_id`,
making it trivially joinable for debugging and analysis.

---

## ◈ NEW ACTION TYPES

Added to `action-event-protocol.md` ACTION TYPES table:

| action_type | When to use |
|---|---|
| `LLM_REQUEST` | Written at the START of processing any user message |
| `LLM_RESPONSE` | Written at the END of generating the response |

---

## ◈ LLM_REQUEST EVENT CONTRACT

Written **before** the LLM produces any output for the turn.

```json
{
  "timestamp":    "2026-04-23T14:00:00.000000+00:00",
  "session_id":   "{{SESSION_ID}}",
  "action_id":    "{{8-char-uuid}}",
  "trace_id":     "{{8-char-uuid — shared with paired LLM_RESPONSE}}",
  "feature":      "{{active_feature or 'global'}}",
  "phase":        "{{current phase or 'ROUTING'}}",
  "action_type":  "LLM_REQUEST",
  "status":       "STARTED",
  "details": {
    "target":          "user_message",
    "result_summary":  "{{first 120 chars of user message, sanitized}}",
    "message_index":   {{turn number in session}},
    "routing_target":  "{{skill-file that will be loaded, e.g. skills/02-spec.md}}"
  }
}
```

---

## ◈ LLM_RESPONSE EVENT CONTRACT

Written **after** the LLM finalizes its response (last thing before sending).

```json
{
  "timestamp":    "2026-04-23T14:00:04.123000+00:00",
  "session_id":   "{{SESSION_ID}}",
  "action_id":    "{{new 8-char-uuid}}",
  "trace_id":     "{{SAME trace_id as paired LLM_REQUEST}}",
  "feature":      "{{active_feature or 'global'}}",
  "phase":        "{{current phase or 'ROUTING'}}",
  "action_type":  "LLM_RESPONSE",
  "status":       "SUCCESS | FAILED | PARTIAL",
  "details": {
    "target":             "llm_output",
    "result_summary":     "{{first 120 chars of response or action summary}}",
    "message_index":      {{same turn number}},
    "actions_executed":   ["WRITE_FILE:.hes/specs/payment/02-spec.md", "EXEC_CMD:pytest"],
    "phase_advanced":     false,
    "phase_from":         "{{phase before this turn}}",
    "phase_to":           "{{phase after this turn — same if no transition}}",
    "artifacts_created":  ["{{list of files written}}"],
    "next_action_pointer": "{{[A] label — the primary pointer shown to user}}",
    "tokens_estimated":   {{estimated token count for this response, 0 if unknown}},
    "duration_ms":        {{wall-clock ms between LLM_REQUEST and LLM_RESPONSE}}
  }
}
```

---

## ◈ HOW THE LLM EXECUTES THIS (mandatory steps every turn)

### Turn start — write LLM_REQUEST

This is the FIRST thing written before generating any response.
Use the existing `log-action.sh` with the new action type:

```bash
TRACE_ID=$(python3 -c "import uuid; print(str(uuid.uuid4())[:8])")

bash scripts/hooks/log-action.sh LLM_REQUEST STARTED \
  "user_message" \
  "{{first 120 chars of user message}}"
```

Store `TRACE_ID` in working memory for the paired LLM_RESPONSE event.

### During turn — execute skill-file as usual

Run all actions, log each with `action-event-protocol.md` as normal:
```bash
bash scripts/hooks/log-action.sh WRITE_FILE STARTED ".hes/specs/..." "..."
bash scripts/hooks/log-action.sh WRITE_FILE SUCCESS ".hes/specs/..." "spec written"
```

### Turn end — write LLM_RESPONSE

This is the LAST thing appended before the response is sent to the user.

```bash
bash scripts/hooks/log-action.sh LLM_RESPONSE SUCCESS \
  "llm_output" \
  "phase={{PHASE}} | advanced={{true|false}} | artifacts={{N}} | next=[A]={{POINTER_LABEL}}"
```

The shell script does NOT have fields for `trace_id`, `actions_executed`, etc.
For the full LLM_RESPONSE envelope, the LLM appends a raw JSON line directly:

```python
# LLM executes this python inline to write full trace event
python3 << 'PYEOF'
import json, uuid
from datetime import datetime, timezone

session_id = open('.hes/state/session-id').read().strip()
state = json.load(open('.hes/state/current.json'))
feature = state.get('active_feature') or 'global'
features = state.get('features', {})
phase = features.get(feature, state.get('session', {}).get('phase_lock', 'ROUTING'))

event = {
  "timestamp": datetime.now(timezone.utc).isoformat(),
  "session_id": session_id,
  "action_id": str(uuid.uuid4())[:8],
  "trace_id": "{{TRACE_ID}}",               # from turn-start variable
  "feature": feature,
  "phase": phase,
  "action_type": "LLM_RESPONSE",
  "status": "SUCCESS",                       # or FAILED / PARTIAL
  "details": {
    "target": "llm_output",
    "result_summary": "{{120-char summary}}",
    "message_index": state.get('session', {}).get('messages_in_session', 0),
    "actions_executed": ["{{list of action_ids or summaries}}"],
    "phase_advanced": False,                  # True if phase changed
    "phase_from": phase,
    "phase_to": phase,                        # update if transitioned
    "artifacts_created": [],                  # list of files written
    "next_action_pointer": "{{[A] label}}",   # primary pointer shown
    "tokens_estimated": 0,
    "duration_ms": 0                          # best-effort
  }
}

with open('.hes/state/events.log', 'a') as f:
    f.write(json.dumps(event) + '\n')
PYEOF
```

---

## ◈ EVENTS.LOG STRUCTURE (visual)

A session now looks like this in events.log — each line is one JSON event:

```
{"action_type":"LLM_REQUEST",  "trace_id":"a1b2c3d4", "status":"STARTED",  ...}  ← turn 1 start
{"action_type":"READ_FILE",    "trace_id":null,        "status":"SUCCESS",  ...}  ← action inside turn
{"action_type":"WRITE_FILE",   "trace_id":null,        "status":"SUCCESS",  ...}  ← action inside turn
{"action_type":"LLM_RESPONSE", "trace_id":"a1b2c3d4", "status":"SUCCESS",  ...}  ← turn 1 end

{"action_type":"LLM_REQUEST",  "trace_id":"e5f6g7h8", "status":"STARTED",  ...}  ← turn 2 start
{"action_type":"EXEC_CMD",     "trace_id":null,        "status":"STARTED",  ...}
{"action_type":"EXEC_CMD",     "trace_id":null,        "status":"FAILED",   ...}
{"action_type":"LLM_RESPONSE", "trace_id":"e5f6g7h8", "status":"FAILED",   ...}  ← turn 2 end (fail)

{"action_type":"LLM_REQUEST",  "trace_id":"i9j0k1l2", "status":"STARTED",  ...}  ← turn 3 start
...phase transition...
{"action_type":"PHASE_TRANSITION", ...}                                            ← state change
{"action_type":"LLM_RESPONSE", "trace_id":"i9j0k1l2", "status":"SUCCESS",  ...}  ← turn 3 end
```

---

## ◈ QUERYING THE TRACE

```bash
# Full trace for a session — request/response pairs only
SESSION=$(cat .hes/state/session-id)
python3 -c "
import json
events = [json.loads(l) for l in open('.hes/state/events.log') if l.strip()]
turns = [e for e in events if e.get('session_id') == '$SESSION'
         and e.get('action_type') in ('LLM_REQUEST', 'LLM_RESPONSE')]
for e in turns:
    ts = e['timestamp'][11:19]
    tid = e.get('trace_id', '?')
    st = e['status']
    summary = e['details']['result_summary'][:80]
    print(f\"{ts} [{tid}] {e['action_type']:13} [{st:8}] {summary}\")
"

# Find all failed turns
python3 -c "
import json
events = [json.loads(l) for l in open('.hes/state/events.log') if l.strip()]
failed = [e for e in events if e.get('action_type') == 'LLM_RESPONSE'
          and e.get('status') == 'FAILED']
for e in failed:
    print(json.dumps(e, indent=2))
"

# Reconstruct a full turn by trace_id
python3 -c "
import json, sys
tid = sys.argv[1]
events = [json.loads(l) for l in open('.hes/state/events.log') if l.strip()]
turn = [e for e in events if e.get('trace_id') == tid
        or (e.get('action_type') not in ('LLM_REQUEST','LLM_RESPONSE')
            and any(t.get('trace_id') == tid for t in events
                    if t.get('action_type') == 'LLM_REQUEST'))]
for e in turn:
    print(json.dumps(e))
" {{TRACE_ID}}

# Average response duration
python3 -c "
import json
events = [json.loads(l) for l in open('.hes/state/events.log') if l.strip()]
durations = [e['details'].get('duration_ms', 0) for e in events
             if e.get('action_type') == 'LLM_RESPONSE' and e['details'].get('duration_ms')]
print(f'Avg LLM response: {sum(durations)/len(durations):.0f}ms' if durations else 'No duration data')
"

# Phase advancement rate
python3 -c "
import json
events = [json.loads(l) for l in open('.hes/state/events.log') if l.strip()]
responses = [e for e in events if e.get('action_type') == 'LLM_RESPONSE']
advanced = [e for e in responses if e['details'].get('phase_advanced')]
print(f'Phase transitions: {len(advanced)}/{len(responses)} turns')
"
```

---

## ◈ RULE ADDITIONS (to SKILL.md)

```
R34  WRITE LLM_REQUEST event as FIRST action of every turn (before any output)
R35  WRITE LLM_RESPONSE event as LAST action of every turn (after response finalized)
R34 and R35 together create a complete execution trace in events.log
```

---

## ◈ INTEGRATION IN SKILL-FILES

Every skill-file that executes actions must wrap its execution:

```
[at top of any skill execution]
→ Write LLM_REQUEST event (trace_id generated)

[... execute all skill steps ...]

[at bottom, before NEXT ACTION block]
→ Write LLM_RESPONSE event (same trace_id, summarize what happened)
```

Skill-files do NOT need to repeat these instructions — the LLM reads this
protocol once and applies it to every turn automatically per RULE-34/R35.

---

*HES LLM Trace Protocol v3.5.0 — Josemalyson Oliveira | 2026*
*Complements: action-event-protocol.md (intra-phase) + events.log (phase transitions)*
