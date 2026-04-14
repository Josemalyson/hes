#!/usr/bin/env python3
"""HES SDD Commit Checker v3.3 — commit-msg hook
Computational sensor: validates Conventional Commits and HES stage."""
import sys, re

VALID_TYPES = [
    'feat', 'fix', 'docs', 'test', 'refactor',
    'chore', 'spec', 'design', 'data', 'discovery', 'review',
    'harness',   # ← HES harness improvement commits
    'fitness',   # ← fitness function commits
]
PATTERN = re.compile(
    r'^(' + '|'.join(VALID_TYPES) + r')(\(\w[\w-]*\))?!?: .{10,}$'
)

msg_file = sys.argv[1]
with open(msg_file) as f:
    msg = f.read().strip()

first_line = msg.split('\n')[0]

if not PATTERN.match(first_line):
    print('\n🚨 HES Commit Checker v3.3 — Invalid message\n')
    print(f'  Received : {first_line}')
    print(f'  Expected : <type>(<scope>): <description with 10+ chars>')
    print(f'  Types    : {", ".join(VALID_TYPES)}')
    print(f'  Examples : feat(payment): implement PIX endpoint')
    print(f'             harness(arch): add ArchUnit rules for service layer\n')
    sys.exit(1)

print('✅ HES Commit Checker v3.3 — OK')
