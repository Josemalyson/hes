# HES Skill — 04: Data Layer (Schema + Migrations)

> Skill carregada quando: feature.estado = DATA
> Pré-condição: `03-design.md` e `ADR-{{NNN}}.md` aprovados pelo usuário.

---

## ◈ CONTEXTO A CARREGAR ANTES DE AGIR

```
1. Ler .hes/specs/{{feature}}/02-spec.md → modelo de domínio (campos, tipos, regras)
2. Ler .hes/specs/{{feature}}/03-design.md → componentes e entidades
3. Verificar schema existente no banco:
   - Flyway: src/main/resources/db/migration/ → última versão V?
   - Liquibase: src/main/resources/db/changelog/
   - Prisma: prisma/schema.prisma
   - Alembic: alembic/versions/
4. Verificar convenções de nomenclatura já usadas nas migrations existentes
```

**Anti-alucinação:**
- Migrations são SEMPRE aditivas em produção
- Nunca DROP sem aprovação explícita do usuário (REGRA-04)
- Verificar a versão mais alta de migration antes de numerar a nova

---

## ◈ PASSO 1 — GERAR `.hes/specs/{{FEATURE_SLUG}}/04-data.md`

```markdown
# Data Layer — {{NOME_FEATURE}}

Data: {{DATA_ATUAL}} | Versão: 1.0
Derivado de: 03-design.md | Feature: {{FEATURE_SLUG}}

---

## Schema

### Tabela: `{{nome_tabela}}`

| Coluna | Tipo SQL | Nulo? | Default | Constraint | Comentário |
|--------|----------|-------|---------|-----------|------------|
| id | UUID | NOT NULL | gen_random_uuid() | PK | Identificador único |
| {{coluna_1}} | {{tipo}} | {{NOT NULL / NULL}} | {{default ou —}} | {{FK / UNIQUE / CHECK}} | {{regra — ex: RN-01}} |
| {{coluna_2}} | {{tipo}} | {{NOT NULL / NULL}} | — | — | |
| created_at | TIMESTAMPTZ | NOT NULL | NOW() | — | Auditoria |
| updated_at | TIMESTAMPTZ | NOT NULL | NOW() | — | Auditoria |
| deleted_at | TIMESTAMPTZ | NULL | — | — | Soft delete (se aplicável) |

### Índices

| Nome do Índice | Colunas | Tipo | Justificativa |
|---------------|---------|------|--------------|
| `idx_{{tabela}}_{{coluna}}` | {{coluna}} | BTREE | Filtro frequente por {{coluna}} |
| `idx_{{tabela}}_{{col1}}_{{col2}}` | {{col1}}, {{col2}} | BTREE | Query de {{UC-01}} |

### Relacionamentos

| Tabela Origem | Tabela Destino | Tipo | Coluna FK | On Delete |
|--------------|---------------|------|-----------|-----------|
| {{tabela}} | {{tabela_ref}} | N:1 | {{coluna_fk}} | RESTRICT / CASCADE / SET NULL |

---

## Arquivo de Migration

### Flyway

Arquivo: `src/main/resources/db/migration/V{{N}}__{{descricao_snake_case}}.sql`

```sql
-- V{{N}}__{{descricao_snake_case}}.sql
-- HES | Feature: {{FEATURE_SLUG}} | Data: {{DATA_ATUAL}}

CREATE TABLE IF NOT EXISTS {{nome_tabela}} (
    id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    {{coluna}}  {{tipo}}     NOT NULL,
    created_at  TIMESTAMPTZ  NOT NULL    DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  NOT NULL    DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_{{nome_tabela}}_{{coluna_indexada}}
    ON {{nome_tabela}}({{coluna_indexada}});

-- FK (se aplicável)
ALTER TABLE {{nome_tabela}}
    ADD CONSTRAINT fk_{{tabela}}_{{ref}}
    FOREIGN KEY ({{coluna_fk}})
    REFERENCES {{tabela_ref}}(id)
    ON DELETE RESTRICT;

-- Comentário de auditoria HES
COMMENT ON TABLE {{nome_tabela}}
    IS '{{DESCRICAO_DA_TABELA}} | HES:{{FEATURE_SLUG}}';
```

### Trigger de updated_at (se necessário)

```sql
-- Função (criar uma vez por projeto, não por tabela)
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger por tabela
CREATE TRIGGER trg_{{nome_tabela}}_updated_at
    BEFORE UPDATE ON {{nome_tabela}}
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

---

## DTOs

### Request DTO — `{{NomeFeature}}Request`

| Campo | Tipo | Obrigatório | Validação | Descrição |
|-------|------|------------|-----------|-----------|
| {{campo_1}} | String | Sim | @NotBlank | {{descricao}} |
| {{campo_2}} | BigDecimal | Sim | @Positive | {{descricao}} |
| {{campo_3}} | String | Não | @Size(max=255) | {{descricao}} |

### Response DTO — `{{NomeFeature}}Response`

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID | Identificador gerado |
| {{campo}} | {{tipo}} | {{descricao}} |
| createdAt | ISO 8601 | Data de criação |

---

## Checklist de Aprovação

- [ ] Migration é aditiva (sem DROP, ALTER COLUMN, ou TRUNCATE sem aprovação)?
- [ ] Índices justificados pelas queries dos cenários BDD?
- [ ] Tipos SQL adequados para as regras de negócio (ex: NUMERIC para valores monetários)?
- [ ] Soft delete planejado se necessário?
- [ ] Migration testada localmente (execução + rollback)?
- [ ] Aprovado para avançar à Etapa 5 (TESTS)
```

---

## ◈ PASSO 2 — ATUALIZAR ESTADO

### `.hes/state/current.json`: alterar `"{{FEATURE}}": "DATA"`

### `.hes/state/events.log`:

```json
{
  "timestamp": "{{DATA_ATUAL_ISO}}",
  "feature": "{{FEATURE_SLUG}}",
  "from": "DESIGN",
  "to": "DATA",
  "agent": "hes-v3",
  "metadata": {
    "artifacts": ["04-data.md"],
    "migration_file": "V{{N}}__{{descricao}}.sql",
    "tables_created": ["{{nome_tabela}}"]
  }
}
```

---

▶ PRÓXIMA AÇÃO — VALIDAÇÃO DA MIGRATION

```
💾 Data layer gerado:
   .hes/specs/{{FEATURE_SLUG}}/04-data.md
   Migration: V{{N}}__{{descricao}}.sql

Antes de avançar, rode a migration localmente:

  [Flyway]    mvn flyway:migrate
  [Liquibase] mvn liquibase:update
  [Prisma]    npx prisma migrate dev --name {{descricao}}
  [Alembic]   alembic upgrade head

  [A] "migration ok, tabela criada"
      → Escrevo os testes (fase RED — skills/05-tests.md)

  [B] "erro de migration: [mensagem]"
      → Carrego skills/error-recovery.md e analiso o erro

  [C] "preciso ajustar o schema: [mudança]"
      → Ajusto o 04-data.md e regenero a migration

📄 Skill-file próximo: skills/05-tests.md
💡 Dica: NUMERIC(precision, scale) para valores monetários.
   Nunca FLOAT/DOUBLE — perda de precisão em operações financeiras.
```
