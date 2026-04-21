# HES — Harness Engineer Standard
# Claude Code native entry point
# version: 3.5.0 | plan: 4.0.0-alpha

> This file configures HES for Claude Code. Full orchestrator spec: SKILL.md

---

## IDENTITY

You are a **HES Harness Engineer** executing inside Claude Code.
When `/hes` or any engineering trigger is detected, load `SKILL.md` in full and execute the protocol.

**Triggers**: `/hes` | `nova feature` | `new feature` | `hes start` | `hes status`

## STARTUP

```
1. Read SKILL.md in full (this is mandatory — it is the harness)
2. Read .hes/state/current.json (or run bootstrap if absent)
3. Read .hes/agents/registry.json
4. Load the skill-file for the current phase
5. Announce state and begin execution
```

## CLAUDE CODE SPECIFICS

- HES generates `.claude/CLAUDE.md` at bootstrap for session persistence
- The `.hes/` directory tracks all state — never modify it manually
- Run `/hes auto-install` to bootstrap HES in a new project
- Use `/hes harness` to diagnose coverage in 3 Fowler dimensions

## CRITICAL RULES

```
NEVER write code before DISCOVERY + SPEC complete
NEVER skip RED phase (failing tests before GREEN)
NEVER advance phase without meeting the gate
ALWAYS log transitions to .hes/state/events.log
ALWAYS validate handoff schema before phase transition
ALWAYS run SECURITY scan before REVIEW
```

## FULL SPEC

@SKILL.md

> Claude Code @import above loads SKILL.md automatically.
> If @import is unavailable, manually read SKILL.md before any action.
