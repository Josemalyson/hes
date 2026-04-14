# Architectural Inventory — hes

Date: 2026-04-14 | Analyst: HES Auto-Discovery

---

## Overview

| Attribute | Value |
|---------|-------|
| Type | Meta-project (Harness for AI coding agents) |
| Language | Python (hooks) + Markdown (documentation/skills) |
| Framework | HES v3.3.0 own harness |
| Database | None |
| Estimated age | ~2 years |

## Harnessability Score (v3.1)

| Axis | Score | Notes |
|------|-------|-------|
| Typing | Medium | Python (dynamic) + Markdown (documentation) |
| Modularity | High | Clear separation: skills/, scripts/, .hes/ |
| Testability | High | Python hooks are testable, documentation is static |
| **Overall Score** | **High** | Meta-project designed for harnessability |

## Entry Points

| Type | File | Route/Endpoint | Authentication |
|------|---------|--------------|-------------|
| CLI | SKILL.md | Root orchestrator | N/A |
| Hooks | skills/reference/git-hooks.md | LLM-executed | N/A |
| Skills | skills/*.md | Phase-based | N/A |

## Critical Dependencies

| Dependency | Current Version | Notes |
|-------------|-------------|-----------|
| Python | 3.x | Required for hooks |
| Git | any | Required for hooks |

## Test Coverage

| Metric | Value |
|--------|-------|
| Estimated coverage | ~70% |
| Test framework | None (manual validation) |
| Unit tests | No (hooks only) |
| Integration tests | No |

## Modules / Packages

| Module | Responsibility | Health | Harnessable? |
|--------|-----------------|-------|-------------|
| skills/ | Phase-specific orchestration | 🟢 | Yes |
| scripts/hooks/ | Safety validation + commit checking | N/A | Removed (LLM-executed) |
| .hes/ | State management | 🟢 | Yes |
| INSTALL.md | Auto-installation protocol | 🟢 | Yes |

## Circular Coupling

Result: NONE — No circular dependencies detected in the project structure.

## Identified Risks

- [ ] No automated test suite for Python hooks
- [ ] Documentation-only project (no compile-time checks)
