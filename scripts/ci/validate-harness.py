#!/usr/bin/env python3
"""
HES v3.5.0 — Harness Validation Script
Valida estrutura, consistência e versions do HES.

Uso:
  python3 scripts/ci/validate-harness.py --check skills
  python3 scripts/ci/validate-harness.py --check versions
  python3 scripts/ci/validate-harness.py --check state-machine
  python3 scripts/ci/validate-harness.py --check skill-headers
  python3 scripts/ci/validate-harness.py --report
  python3 scripts/ci/validate-harness.py  (roda all os checks)
"""
import json
import os
import re
import sys
import argparse
from pathlib import Path

ROOT = Path(__file__).parent.parent.parent
REGISTRY = ROOT / ".hes/agents/registry.json"
SKILL_MD = ROOT / "SKILL.md"

errors = []
warnings = []

def err(msg): errors.append(f"❌ {msg}"); print(f"❌ {msg}")
def warn(msg): warnings.append(f"⚠️  {msg}"); print(f"⚠️  {msg}")
def ok(msg): print(f"✅ {msg}")


def check_skills():
    """Verifica que all os skill-files referenciados no registry existem."""
    print("\n── CHECK: Skill files ──")
    with open(REGISTRY) as f:
        registry = json.load(f)

    all_agents = registry.get("agents", []) + registry.get("system_agents", [])
    for agent in all_agents:
        skill_file = ROOT / agent.get("skill_file", "")
        if not skill_file.exists():
            err(f"Skill file missing: {agent['skill_file']} (agent: {agent['agent']})")
        else:
            ok(f"  {agent['skill_file']}")


def check_versions():
    """Verifica consistência de versions between SKILL.md, registry e CHANGELOG."""
    print("\n── CHECK: Version consistency ──")
    with open(REGISTRY) as f:
        registry = json.load(f)

    registry_version = registry.get("harness_version", "unknown")

    skill_version = "unknown"
    if SKILL_MD.exists():
        content = SKILL_MD.read_text()
        m = re.search(r"^version:\s*(\S+)", content, re.MULTILINE)
        if m:
            skill_version = m.group(1)

    changelog_version = "unknown"
    changelog = ROOT / "CHANGELOG.md"
    if changelog.exists():
        m = re.search(r"^## v(\S+)", changelog.read_text(), re.MULTILINE)
        if m:
            changelog_version = m.group(1)

    print(f"  SKILL.md:       v{skill_version}")
    print(f"  registry.json:  v{registry_version}")
    print(f"  CHANGELOG.md:   v{changelog_version}")

    if skill_version != registry_version:
        err(f"Version mismatch: SKILL.md={skill_version} vs registry={registry_version}")
    else:
        ok(f"  Versions consistent: {skill_version}")

    if changelog_version and not changelog_version.startswith(skill_version.split(".")[0]):
        warn(f"CHANGELOG major version differs from SKILL.md ({changelog_version} vs {skill_version})")


def check_state_machine():
    """Verifica que o state machine no SKILL.md inclui all as phases do registry."""
    print("\n── CHECK: State machine ──")
    if not SKILL_MD.exists():
        err("SKILL.md not found")
        return

    content = SKILL_MD.read_text()
    phases_in_skill = re.findall(r"\bZERO → .+? → DONE\b", content)

    expected_phases = ["ZERO", "DISCOVERY", "SPEC", "DESIGN", "DATA",
                       "RED", "GREEN", "SECURITY", "REVIEW", "DONE"]

    with open(REGISTRY) as f:
        registry = json.load(f)

    registry_phases = [a["phase"] for a in registry.get("agents", [])]

    for phase in registry_phases:
        if phase not in expected_phases:
            warn(f"Phase {phase} in registry but not in expected list")

    if phases_in_skill:
        sm = phases_in_skill[0]
        for phase in expected_phases:
            if phase not in sm:
                err(f"Phase {phase} missing from state machine: {sm}")
        ok(f"  State machine: {sm}")
    else:
        warn("State machine pattern not found in SKILL.md")


def check_skill_headers():
    """Verifica que skill-files têm headers de version."""
    print("\n── CHECK: Skill headers ──")
    skills_dir = ROOT / "skills"
    missing_headers = []

    for skill_file in sorted(skills_dir.glob("*.md")):
        content = skill_file.read_text()
        has_version = ("version:" in content[:500] or
                       "v3." in content[:200] or
                       "HES Skill" in content[:100])
        if not has_version:
            missing_headers.append(skill_file.name)
            warn(f"  No version header: {skill_file.name}")
        else:
            ok(f"  {skill_file.name}")

    if not missing_headers:
        ok("  All skill files have headers")


def report():
    """Exibe report end."""
    print("\n" + "="*50)
    print("HES HARNESS VALIDATION REPORT")
    print("="*50)
    print(f"Errors:   {len(errors)}")
    print(f"Warnings: {len(warnings)}")
    if errors:
        print("\nErrors:")
        for e in errors:
            print(f"  {e}")
    if warnings:
        print("\nWarnings:")
        for w in warnings:
            print(f"  {w}")
    print("="*50)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", choices=["skills", "versions", "state-machine", "skill-headers"])
    parser.add_argument("--report", action="store_true")
    args = parser.parse_args()

    if args.report:
        report()
        sys.exit(0)

    if args.check == "skills":
        check_skills()
    elif args.check == "versions":
        check_versions()
    elif args.check == "state-machine":
        check_state_machine()
    elif args.check == "skill-headers":
        check_skill_headers()
    else:
        check_skills()
        check_versions()
        check_state_machine()
        check_skill_headers()
        report()

    if errors:
        sys.exit(1)

if __name__ == "__main__":
    main()
