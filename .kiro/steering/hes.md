---
title: HES — Harness Engineer Standard
inclusion: always
---

# HES — Harness Engineer Standard v3.5.0

> "Agent = Model + Harness" — LangChain, 2026

When engineering triggers appear, read `SKILL.md` and execute the HES protocol.

**Triggers**: `/hes` · `nova feature` · `new feature` · `hes start`

## Startup

1. Read `SKILL.md` in full (mandatory)
2. Check `.hes/state/current.json` → detect phase + feature
3. Load `skills/<phase>.md` · Announce · Execute

## State Machine

`ZERO → DISCOVERY → SPEC → DESIGN → DATA → RED → GREEN → SECURITY → REVIEW → DONE`

Each phase gates the next. Gates cannot be bypassed without `/hes unlock --force`.

## Core Rules

```
NEVER write code before DISCOVERY + SPEC complete
NEVER skip RED phase — failing tests must precede GREEN
NEVER advance without meeting the phase gate
ALWAYS run SECURITY scan before REVIEW
ALWAYS log transitions to .hes/state/events.log
```

> Full spec: SKILL.md · Commands + phase table: AGENTS.md
