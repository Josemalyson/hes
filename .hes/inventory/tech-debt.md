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
| No test suite for hooks | scripts/hooks/ | Hooks could break silently | M | Add pytest to scripts/ |
| No CI/CD pipeline | root | No automated validation | S | Add GitHub Actions |

## 🟢 MEDIUM — desirable improvement without urgency

| Debt | Location | Impact | Effort | Strategy |
|--------|------------|---------|---------|-----------|
| Python type hints | scripts/hooks/*.py | Better maintainability | M | Add type annotations |
| Unit test for safety_validator | scripts/hooks/safety_validator.py | Prevent regressions | M | Add pytest |

---

## Module Strategy Decision

| Module | Coverage | Harnessability | Recommended Strategy |
|--------|----------|---------------|----------------------|
| skills/ | N/A | High | Immediate use |
| scripts/hooks/ | Low | High | Add tests |
| .hes/state/ | N/A | High | Already operational |
