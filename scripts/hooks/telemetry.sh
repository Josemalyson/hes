#!/usr/bin/env bash
# HES v3.5.0 — Telemetry Span Manager
# Uso: bash scripts/hooks/telemetry.sh <cmd> [args...]
set -euo pipefail

CMD="${1:-help}"
TELEMETRY=".hes/state/telemetry.jsonl"
mkdir -p .hes/state

ts() { python3 -c "from datetime import datetime,timezone; print(datetime.now(timezone.utc).isoformat())"; }
uuid8() { python3 -c "import uuid; print(str(uuid.uuid4())[:8])"; }

case "$CMD" in
  start_phase)
    PHASE="${2:-UNKNOWN}"; FEATURE="${3:-unknown}"
    SPAN_ID=$(uuid8)
    echo "$SPAN_ID"  # returns span_id for later use
    python3 << PYEOF
import json
from datetime import datetime, timezone
span = {
    "span_id": "$SPAN_ID",
    "parent_span_id": None,
    "name": "PHASE:$PHASE",
    "phase": "$PHASE",
    "feature": "$FEATURE",
    "session_id": open(".hes/state/session-id").read().strip() if __import__("os").path.exists(".hes/state/session-id") else "unknown",
    "start_time": datetime.now(timezone.utc).isoformat(),
    "end_time": None,
    "duration_ms": None,
    "status": "RUNNING",
    "type": "phase"
}
with open("$TELEMETRY", "a") as f:
    f.write(json.dumps(span) + "\n")
PYEOF
    ;;

  end_phase)
    SPAN_ID="${2:-}"; STATUS="${3:-SUCCESS}"
    python3 << PYEOF
import json, os
from datetime import datetime, timezone

lines = []
found = False
with open("$TELEMETRY") as f:
    for line in f:
        span = json.loads(line)
        if span.get("span_id") == "$SPAN_ID" and span.get("end_time") is None:
            start = datetime.fromisoformat(span["start_time"])
            end = datetime.now(timezone.utc)
            dur_ms = int((end - start).total_seconds() * 1000)
            span["end_time"] = end.isoformat()
            span["duration_ms"] = dur_ms
            span["status"] = "$STATUS"
            found = True
        lines.append(json.dumps(span))

with open("$TELEMETRY", "w") as f:
    f.write("\n".join(lines) + "\n")

if found:
    print(f"  Phase span closed: $SPAN_ID | {dur_ms}ms")
PYEOF
    ;;

  timeline)
    FEATURE="${2:-}"
    python3 << PYEOF
import json, sys
from pathlib import Path

telem = Path("$TELEMETRY")
if not telem.exists():
    print("No telemetry data yet.")
    sys.exit(0)

spans = [json.loads(l) for l in telem.read_text().strip().split("\n") if l.strip()]
if "$FEATURE":
    spans = [s for s in spans if s.get("feature") == "$FEATURE"]

total_ms = sum(s.get("duration_ms") or 0 for s in spans if s.get("type") == "phase")
print(f"\nFeature: $FEATURE | Total: {total_ms/60000:.1f} min")
print(f"{'Phase':<14} {'Duration':>10} {'Status':>10}")
print("-" * 38)
for s in spans:
    if s.get("type") == "phase":
        dur = s.get("duration_ms") or 0
        print(f"{s['name']:<14} {dur/1000:>8.1f}s {s.get('status','?'):>10}")
PYEOF
    ;;

  cost)
    python3 << PYEOF
import json
from pathlib import Path

telem = Path("$TELEMETRY")
if not telem.exists():
    print("No telemetry data.")
    exit(0)

spans = [json.loads(l) for l in telem.read_text().strip().split("\n") if l.strip()]
total_tokens = sum(s.get("tokens_estimated") or 0 for s in spans)
total_cost = total_tokens / 1000 * 0.009  # avg price
print(f"Total tokens: ~{total_tokens:,}")
print(f"Estimated cost: ~\${total_cost:.4f}")
PYEOF
    ;;
esac
