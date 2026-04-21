---
title: HES Phase Reference
inclusion: always
---

# HES Phase Reference for Kiro

| Phase      | Skill File                    | Gate Condition                  | Purpose                              |
|------------|-------------------------------|---------------------------------|--------------------------------------|
| ZERO       | skills/00-bootstrap.md        | Bootstrap complete              | Project setup + .hes/ structure      |
| DISCOVERY  | skills/01-discovery.md        | Business rules list approved    | Capture BRs, use cases, domain model |
| SPEC       | skills/02-spec.md             | BDD scenarios + contracts OK    | BDD scenarios, API contracts         |
| DESIGN     | skills/03-design.md           | ADRs approved by user           | Component design, ADRs, architecture |
| DATA       | skills/04-data.md             | Migrations reviewed             | Schema, SQL migrations, DTOs         |
| RED        | skills/05-tests.md            | ≥1 failing test exists          | Test-first (TDD red phase)           |
| GREEN      | skills/06-implementation.md   | All tests passing, build green  | Minimal implementation to pass tests |
| SECURITY   | skills/10-security.md         | 0 HIGH findings (per policy)    | Bandit + Semgrep auto-fix + gate     |
| REVIEW     | skills/07-review.md           | 5-dimension checklist done      | Final review before DONE             |
| DONE       | —                             | Summary presented               | Feature complete, next feature       |

## Phase Lock Gates

Advancing between phases requires explicit gate satisfaction. The LLM evaluates each gate
before transitioning. Gates cannot be bypassed without `/hes unlock --force` (which logs a risk event).

## System Agents (always available)

| Command           | Skill                         |
|-------------------|-------------------------------|
| `/hes report`     | skills/report.md              |
| `/hes harness`    | skills/harness-health.md      |
| `/hes security`   | skills/10-security.md         |
| `/hes eval`       | skills/11-eval.md             |
| `/hes test`       | skills/12-harness-tests.md    |
| `/hes refactor`   | skills/refactor.md            |
| `/hes review`     | skills/reviewer.md *(stub)*   |
| `/hes optimize`   | skills/optimizer.md *(stub)*  |
| `/hes insights`   | skills/harness-evolver.md *(stub)* |
