# HES — Harness Engineer Standard v3.5.0
# GitHub Copilot / VS Code | Also reads: AGENTS.md | Full spec: SKILL.md

When /hes or engineering triggers appear, read SKILL.md and execute the HES protocol.

Triggers: /hes | new feature | hes start | hes status

Startup:
1. Read SKILL.md (mandatory — the full harness orchestrator)
2. Check .hes/state/current.json → detect phase and active feature
3. Load skills/<phase>.md · Announce state · Execute

State machine: ZERO → DISCOVERY → SPEC → DESIGN → DATA → RED → GREEN → SECURITY → REVIEW → DONE

Rules: NEVER write code before DISCOVERY + SPEC · NEVER skip RED phase
       ALWAYS run SECURITY scan before REVIEW · ALWAYS log to .hes/state/events.log
       ALWAYS validate handoff schema before advancing phases
