# HES — Skill Versioning Guide (v3.5.0)
# Ensures compatibility between skill-files and SKILL.md versions

---

## ◈ REQUIRED HEADER IN EACH SKILL-FILE

Add to the top of each skill-file (after the title):

```
---
skill_id: 07-review
skill_version: 3.5.0
requires_harness: ">=3.4.0"
breaking_changes_from:
  - "3.3.0: DIMENSION 3 now uses automated scan (not manual)"
  - "3.4.0: session_id required in events.log"
---
```

## ◈ SEMANTIC VERSIONING

| Version | When to use |
|---|---|
| MAJOR (X.0.0) | Breaking change incompatible with previous harness        |
| MINOR (x.Y.0) | New functionality without breaking compatibility          |
| PATCH (x.y.Z) | Bug fix or clarification without behavior change          |

## ◈ INSTALLED VERSIONS FILE

`.hes/state/skill-versions.json`:
```json
{
  "harness_version": "3.5.0",
  "skills": {
    "00-bootstrap": "3.5.0",
    "01-discovery": "3.4.0",
    "10-security": "3.4.0",
    "11-eval": "3.5.0"
  },
  "last_check": "ISO8601"
}
```

## ◈ COMPATIBILITY CHECK

```bash
python3 scripts/ci/validate-harness.py --check versions
```

Rules:
- If `skill.requires_harness > SKILL.md.version` → ERROR (harness outdated)
- If `skill.skill_version > SKILL.md.version` → WARN (skill newer than harness)

## ◈ MIGRATION GUIDES

Location: `docs/migrations/vX.Y-to-vX.Z.md`
Format:
```markdown
# Migration Guide: v3.4.0 → v3.5.0

## Breaking Changes
- 07-review.md DIMENSION 3: [what changed]

## Migration Steps
1. [Step 1]
2. [Step 2]
```
