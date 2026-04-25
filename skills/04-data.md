# 04 · DATA — Schema + Migrations

phase  DATA  ·  pre  DESIGN  ·  next  RED
gate   migration executed locally + user approval
skill  skills/04-data.md

> Migrations are always additive in production. Never DROP without explicit approval.

---

## ◈ CONTEXT TO LOAD BEFORE ACTING

```
1. Read .hes/specs/{{feature}}/02-spec.md → domain model (fields, types, rules)
2. Read .hes/specs/{{feature}}/03-design.md → components and entities
3. Check existing database schema:
   - Flyway: src/main/resources/db/migration/ → latest version V?
   - Liquibase: src/main/resources/db/changelog/
   - Prisma: prisma/schema.prisma
   - Alembic: alembic/versions/
4. Check naming conventions already used in existing migrations
```

**Anti-hallucination:**
- Migrations are ALWAYS additive in production
- Never DROP without explicit user approval (RULE-04)
- Check the highest migration version before numbering the new one

---

## ◈ STEP 1 — WRITE `.hes/specs/{{FEATURE_SLUG}}/04-data.md`

> **MANDATORY**: Use your file-write tool to create this file on disk.
> Displaying content in chat is NOT sufficient. The file must exist on disk.

→ EXECUTE: Write `.hes/specs/{{FEATURE_SLUG}}/04-data.md` with this content:

```markdown
# Data Layer — {{FEATURE_NAME}}

Date: {{CURRENT_DATE}} | Version: 1.0
Derived from: 03-design.md | Feature: {{FEATURE_SLUG}}

---

## Schema

### Table: `{{table_name}}`

| Column | SQL Type | Nullable? | Default | Constraint | Comment |
|--------|----------|-----------|---------|-----------|---------|
| id | UUID | NOT NULL | gen_random_uuid() | PK | Unique identifier |
| {{column_1}} | {{type}} | {{NOT NULL / NULL}} | {{default or —}} | {{FK / UNIQUE / CHECK}} | {{rule — e.g., RN-01}} |
| {{column_2}} | {{type}} | {{NOT NULL / NULL}} | — | — | |
| created_at | TIMESTAMPTZ | NOT NULL | NOW() | — | Audit |
| updated_at | TIMESTAMPTZ | NOT NULL | NOW() | — | Audit |
| deleted_at | TIMESTAMPTZ | NULL | — | — | Soft delete (if applicable) |

### Indexes

| Index Name | Columns | Type | Justification |
|------------|---------|------|---------------|
| `idx_{{table}}_{{column}}` | {{column}} | BTREE | Frequent filter by {{column}} |
| `idx_{{table}}_{{col1}}_{{col2}}` | {{col1}}, {{col2}} | BTREE | Query from {{UC-01}} |

### Relationships

| Source Table | Destination Table | Type | FK Column | On Delete |
|--------------|-------------------|------|-----------|-----------|
| {{table}} | {{ref_table}} | N:1 | {{fk_column}} | RESTRICT / CASCADE / SET NULL |

---

## Migration File

### Flyway

File: `src/main/resources/db/migration/V{{N}}__{{snake_case_description}}.sql`

```sql
-- V{{N}}__{{snake_case_description}}.sql
-- HES | Feature: {{FEATURE_SLUG}} | Date: {{CURRENT_DATE}}

CREATE TABLE IF NOT EXISTS {{table_name}} (
    id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    {{column}}  {{type}}     NOT NULL,
    created_at  TIMESTAMPTZ  NOT NULL    DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  NOT NULL    DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_{{table_name}}_{{indexed_column}}
    ON {{table_name}}({{indexed_column}});

-- FK (if applicable)
ALTER TABLE {{table_name}}
    ADD CONSTRAINT fk_{{table}}_{{ref}}
    FOREIGN KEY ({{fk_column}})
    REFERENCES {{ref_table}}(id)
    ON DELETE RESTRICT;

-- HES audit comment
COMMENT ON TABLE {{table_name}}
    IS '{{TABLE_DESCRIPTION}} | HES:{{FEATURE_SLUG}}';
```

### updated_at Trigger (if needed)

```sql
-- Function (create once per project, not per table)
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger per table
CREATE TRIGGER trg_{{table_name}}_updated_at
    BEFORE UPDATE ON {{table_name}}
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

---

## DTOs

### Request DTO — `{{FeatureName}}Request`

| Field | Type | Required | Validation | Description |
|-------|------|----------|-----------|-------------|
| {{field_1}} | String | Yes | @NotBlank | {{description}} |
| {{field_2}} | BigDecimal | Yes | @Positive | {{description}} |
| {{field_3}} | String | No | @Size(max=255) | {{description}} |

### Response DTO — `{{FeatureName}}Response`

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Generated identifier |
| {{field}} | {{type}} | {{description}} |
| createdAt | ISO 8601 | Creation date |

---

## Approval Checklist

- [ ] Is migration additive (no DROP, ALTER COLUMN, or TRUNCATE without approval)?
- [ ] Are indexes justified by BDD scenario queries?
- [ ] Are SQL types appropriate for business rules (e.g., NUMERIC for monetary values)?
- [ ] Is soft delete planned if needed?
- [ ] Was migration tested locally (execution + rollback)?
- [ ] Approved to advance to Step 5 (TESTS)
```

→ VERIFY (run before advancing):
```bash
test -f .hes/specs/{{FEATURE_SLUG}}/04-data.md && echo "✓ file exists" || echo "✗ FILE MISSING — write it before continuing"
```
If file is missing: write it now. Never advance to RED without this file on disk.

---

## ◈ STEP 2 — UPDATE STATE

### `.hes/state/current.json`: change `"{{FEATURE}}": "DATA"`

### `.hes/state/events.log`:

```json
{
  "timestamp": "{{CURRENT_ISO_DATE}}",
  "feature": "{{FEATURE_SLUG}}",
  "from": "DESIGN",
  "to": "DATA",
  "agent": "hes-v3",
  "metadata": {
    "artifacts": ["04-data.md"],
    "migration_file": "V{{N}}__{{description}}.sql",
    "tables_created": ["{{table_name}}"]
  }
}
```

---

────────────────────────────────────────────────────────────────
  DATA complete
  .hes/specs/{{FEATURE_SLUG}}/04-data.md · migration V{{N}} generated
────────────────────────────────────────────────────────────────
  → EXECUTE migration now:

  Flyway    mvn flyway:migrate
  Liquibase mvn liquibase:update
  Prisma    npx prisma migrate dev --name {{description}}
  Alembic   alembic upgrade head

────────────────────────────────────────────────────────────────
  → RED                                        skills/05-tests.md

**Read `current.json.interaction_tool` before rendering choices:**

If `interaction_tool = "question"`: call the question tool with single-select:
  - "DATA phase complete. Migration status?"
    · "migration ok — table created — advance to RED"
    · "migration error — describe the error message"
    · "schema adjustment needed — describe what to change"

If `interaction_tool = null`:
  A  migration ok — table created — advance to RED
  B  migration error — "[error message]"
  C  schema adjustment — "[what needs to change]"

  💡 NUMERIC(precision, scale) for money. Never FLOAT — precision loss.
────────────────────────────────────────────────────────────────
