---
title: HES Commands Reference
inclusion: manual
---

# HES Commands Reference

## Core Workflow Commands

```bash
/hes                        # Start HES — auto-detects state and routes
/hes start <feature>        # Start new feature → DISCOVERY phase
/hes start --parallel <f>   # Multi-agent mode (stub v3.6)
/hes switch <feature>       # Change active feature (saves state)
/hes status                 # Current state of all features
/hes rollback <phase>       # Revert to previous phase
/hes checkpoint             # Save session checkpoint
```

## Learning & Quality

```bash
/hes report                 # Batch learning from events.log
/hes harness                # Harness health diagnostics (3 Fowler dimensions)
/hes eval                   # Eval harness — pass@k + LLM-as-judge
/hes test                   # Harness self-tests (structural + behavioral)
/hes lessons                # Show lessons.md + pending skill-file promotions
```

## Code Operations

```bash
/hes security               # Manual security scan (Bandit + Semgrep)
/hes refactor <module>      # Guided safe refactoring
/hes review <PR|branch>     # Autonomous PR review — 5 dimensions (stub v4.0)
/hes optimize [path]        # Agent-readable code optimization (stub v3.9)
/hes insights [--evolve]    # Learning dashboard + harness auto-evolution (stub v3.8)
```

## Project Management

```bash
/hes domain <name>          # Create/activate DDD domain
/hes language <code>        # Override language (pt-BR, en, es, fr, de)
/hes mode <beginner|expert> # Set audience mode
/hes unlock --force         # Bypass phase lock (logs risk event)
/hes fleet status           # Multi-agent fleet state (stub v3.7)
```

## State Machine Reference

```
ZERO → DISCOVERY → SPEC → DESIGN → DATA → RED → GREEN → SECURITY → REVIEW → DONE
```
