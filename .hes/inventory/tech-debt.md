# Tech Debt — hes

Date: 2026-04-14

---

## 🔴 CRITICAL — blocks delivery or causes risk in production

| Debt | Location | Impact | Effort | Strategy |
|--------|------------|---------|---------|-----------|
| None identified | | | | |

## 🟡 HIGH — degrades quality, complicates maintenance

| Debt | Location | Impact | Effort | Strategy |
|--------|------------|---------|---------|-----------|
| No CI/CD pipeline | root | No automated validation | S | Add GitHub Actions |

## 🟢 MEDIUM — desirable improvement without urgency

| Debt | Location | Impact | Effort | Strategy |
|--------|------------|---------|---------|-----------|
| Python hooks removed in v3.4 | scripts/hooks/ | Hooks now LLM-executed | N/A | No action needed |
| Python type hints | scripts/hooks/*.py | Better maintainability | M | Add type annotations (if hooks added back) |

---

## Module Strategy Decision

| Module | Coverage | Harnessability | Recommended Strategy |
|--------|----------|---------------|----------------------|
| skills/ | N/A | High | Immediate use |
| .hes/state/ | N/A | High | Already operational |
