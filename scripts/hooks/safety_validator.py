#!/usr/bin/env python3
"""HES Safety Validator v3.3 — pre-commit hook
Computational sensor: blocks secrets, destructive SQL, and pending tasks."""
import subprocess, sys, re

BLOCKED_PATTERNS = [
    (r'(?i)(password|secret|api_key|token)\s*=\s*["\'][^"\']{4,}', 'Hardcoded secret detected'),
    (r'(?i)DROP\s+TABLE', 'DROP TABLE without explicit approval (HES RULE-04)'),
    (r'(?i)DELETE\s+FROM\s+\w+\s*;', 'DELETE without WHERE clause'),
    (r'(?i)TRUNCATE\s+TABLE', 'TRUNCATE without explicit approval (HES RULE-04)'),
    (r'\bTODO\b|\bFIXME\b|\bHACK\b', 'Unresolved pending task in code'),
]
SKIP_EXTENSIONS = {'.lock', '.sum', '.mod', '.png', '.jpg', '.svg', '.ico'}

def get_staged_files():
    result = subprocess.run(['git', 'diff', '--cached', '--name-only'],
                            capture_output=True, text=True)
    return [f for f in result.stdout.strip().split('\n') if f]

def check_file(filepath):
    import os
    ext = os.path.splitext(filepath)[1]
    if ext in SKIP_EXTENSIONS:
        return []
    violations = []
    try:
        with open(filepath, 'r', errors='ignore') as f:
            for i, line in enumerate(f, 1):
                for pattern, msg in BLOCKED_PATTERNS:
                    if re.search(pattern, line):
                        violations.append(
                            f'  ⚠  {msg}\n     {filepath}:{i} → {line.strip()[:80]}'
                        )
    except Exception:
        pass
    return violations

violations = []
for f in get_staged_files():
    violations.extend(check_file(f))

if violations:
    print('\n🚨 HES Safety Validator v3.3 — COMMIT BLOCKED\n')
    for v in violations:
        print(v)
    print('\nFix the issues above before committing.')
    print('Override (not recommended): git commit --no-verify\n')
    sys.exit(1)

print('✅ HES Safety Validator v3.3 — OK')
