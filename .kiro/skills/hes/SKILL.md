---
name: hes
description: "HES — Harness Engineer Standard. Structured AI software development workflow. Use when: /hes is invoked, user says 'start feature', 'new feature', 'nova feature', or asks to follow the engineering workflow."
---

# HES — Harness Engineer Standard

Read `SKILL.md` at the project root and execute the HES protocol.

## Startup

1. Read `SKILL.md` in full — this is the harness orchestrator
2. Read `.hes/state/current.json` → detect current phase and active feature
3. Load `skills/<phase>.md` for the current phase
4. Announce state and begin execution

## Triggers

`/hes` · `nova feature` · `new feature` · `hes start` · `hes status` · `hes switch`

## State Machine

```
ZERO → DISCOVERY → SPEC → DESIGN → DATA → RED → GREEN → SECURITY → REVIEW → DONE
```

## Core Rules

- NEVER write code before DISCOVERY + SPEC complete
- NEVER skip RED phase — failing tests must precede implementation  
- NEVER advance phase without meeting the gate condition
- ALWAYS run SECURITY scan before REVIEW — no exceptions
- ALWAYS log every transition to `.hes/state/events.log`

> Full protocol: `SKILL.md` · Quick reference: `AGENTS.md`
