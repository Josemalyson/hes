# Domain Templates Reference

> Used in: Step 8 — Generate domain files (if DDD domains provided)

---

## Domain Context

**File:** `.hes/domains/{{domain}}/context.md`

```markdown
# Bounded Context — {{DOMAIN}}

Domain: {{DOMAIN}} | Project: {{PROJECT_NAME}}

## Ubiquitous Language
| Term | Definition in domain | Difference from other domains |
|------|---------------------|-------------------------------|
| _to fill_ | | |

## Domain Responsibilities
_what belongs to this context_

## Explicit Boundaries
_what does NOT belong to this context_

## Integrations with Other Domains
| Domain | Integration Type | Protocol |
|--------|-----------------|----------|
| | | |
```

---

## Domain Fitness README

**File:** `.hes/domains/{{domain}}/fitness/README.md`

```markdown
# Fitness Functions — {{DOMAIN}}

Computational architecture fitness sensors for the {{DOMAIN}} domain.
Reference: Fowler (2026) — Architecture Fitness Harness.

## Installed sensors
_to fill after setup in Step 9_

## Defined boundary rules
_to fill after setup_

## How to run
_to fill after setup_
```
