#!/usr/bin/env python3
"""
HES v3.4.0 — Security Gate Check
Verifica se há HIGH findings no relatório final do Bandit.
Usado pela skill 10-security.md no STEP 8.

Exit 0 = gate passou (zero HIGH)
Exit 1 = gate falhou (HIGH findings existem)
"""
import json
import sys
import os

FINAL_REPORT = ".hes/state/security-report-final.json"

if not os.path.exists(FINAL_REPORT):
    print(f"GATE ERROR: {FINAL_REPORT} não encontrado. Execute o re-scan primeiro.")
    sys.exit(1)

with open(FINAL_REPORT) as f:
    report = json.load(f)

all_results = report.get("results", [])
high = [r for r in all_results if r.get("issue_severity", "").upper() == "HIGH"]
medium = [r for r in all_results if r.get("issue_severity", "").upper() == "MEDIUM"]
low = [r for r in all_results if r.get("issue_severity", "").upper() == "LOW"]

print(f"Findings: HIGH={len(high)} | MEDIUM={len(medium)} | LOW={len(low)}")

if high:
    print(f"\nGATE FAILED: {len(high)} HIGH finding(s) bloqueando avanço para REVIEW:")
    for h in high:
        print(f"  [{h['test_id']}] {h['filename']}:{h['line_number']} — {h['issue_text']}")
    sys.exit(1)
else:
    print("\nGATE PASSED: zero HIGH findings — pode avançar para REVIEW ✅")
    sys.exit(0)
