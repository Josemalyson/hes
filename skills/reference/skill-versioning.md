# HES — Skill Versioning Guide (v3.5.0)
# Garante compatibilidade entre skill-files e versões do SKILL.md

---

## ◈ HEADER OBRIGATÓRIO EM CADA SKILL-FILE

Adicionar ao topo de cada skill-file (após o title):

```
---
skill_id: 07-review
skill_version: 3.5.0
requires_harness: ">=3.4.0"
breaking_changes_from:
  - "3.3.0: DIMENSION 3 agora usa scan automatizado (não manual)"
  - "3.4.0: session_id obrigatório no events.log"
---
```

## ◈ VERSIONAMENTO SEMÂNTICO

| Major | Quando usar |
|---|---|
| MAJOR (X.0.0) | Mudança que quebra compatibilidade com harness anterior |
| MINOR (x.Y.0) | Nova funcionalidade sem quebrar compatibilidade |
| PATCH (x.y.Z) | Correção de bug ou clarificação sem mudança de comportamento |

## ◈ ARQUIVO DE VERSÕES INSTALADAS

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

## ◈ VERIFICAÇÃO DE COMPATIBILIDADE

```bash
python3 scripts/ci/validate-harness.py --check versions
```

Regras:
- Se `skill.requires_harness > SKILL.md.version` → ERROR (harness desatualizado)
- Se `skill.skill_version > SKILL.md.version` → WARN (skill mais nova que harness)

## ◈ MIGRATION GUIDES

Localização: `docs/migrations/vX.Y-to-vX.Z.md`
Formato:
```markdown
# Migration Guide: v3.4.0 → v3.5.0

## Breaking Changes
- 07-review.md DIMENSION 3: [o que mudou]

## Migration Steps
1. [Passo 1]
2. [Passo 2]
```
