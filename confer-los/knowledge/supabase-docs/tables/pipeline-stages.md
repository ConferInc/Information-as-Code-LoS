# Pipeline Stages Table

**Category**: Sales & Lead Management (Phase 5B)
**Table**: `pipeline_stages`
**Purpose**: Customizable workflow stages per organization for applications
**Last Updated**: 2026-02-12

---

## Overview

The `pipeline_stages` table allows each organization to define custom workflow stages for their loan processing pipeline. This supplements the default `applications.stage` enum with organization-specific stages that can have custom names, colors, SLA deadlines, and prerequisites.

**Key Distinction**: Applications can use either:
- **Custom stages**: `applications.pipeline_stage_id` (FK to this table)
- **Default enum**: `applications.stage` (backward compatible)

---

## Columns

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | uuid | NO | `gen_random_uuid()` | Primary key |
| `organization_id` | uuid | NO | - | FK to `organizations` |
| `name` | text | NO | - | Stage name (e.g., "Pre-Qualification") |
| `slug` | text | NO | - | URL-safe identifier (e.g., "pre_qual") |
| `description` | text | YES | NULL | Stage description |
| `sort_order` | integer | NO | - | Display order (1, 2, 3...) |
| `color` | text | YES | `'#6B7280'` | Hex color for UI |
| `sla_days` | integer | YES | NULL | SLA deadline in days |
| `is_terminal` | boolean | NO | `false` | Is this a final stage (won/lost)? |
| `is_active` | boolean | NO | `true` | Is stage currently in use? |
| `prerequisites` | jsonb | YES | NULL | Array of stage IDs that must precede this stage |
| `created_at` | timestamp | NO | `now()` | Creation timestamp |
| `updated_at` | timestamp | NO | `now()` | Last update timestamp |

---

## Constraints

- **PK**: `id`
- **FK**: `organization_id` → `organizations(id)`
- **UNIQUE**: `(organization_id, slug)` — Each org's slugs must be unique

---

## Indexes

| Index Name | Columns | Purpose |
|------------|---------|---------|
| `pipeline_stages_org_order_idx` | `organization_id, sort_order` | Sort stages by order |
| `pipeline_stages_org_slug_idx` | `organization_id, slug` | Unique constraint + lookups |

---

## RLS Policies

**Status**: ⚠️ **Not yet configured**

**Planned policies**:
1. `system_admin_all` — System admins full access
2. `staff_manage` — Admins can manage stages in their org
3. `staff_view` — All staff can view stages in their org

---

## Business Logic

### Stage Ordering
- `sort_order` determines display order in UI
- Stages can be reordered by updating `sort_order`

### Terminal Stages
- `is_terminal = true` indicates final stages (e.g., "Funded", "Denied", "Withdrawn")
- Applications in terminal stages typically don't move to other stages

### SLA Tracking
- `sla_days` defines expected time to complete stage
- `applications.stage_entered_at` tracks when stage was entered
- Overdue applications: `stage_entered_at + sla_days < now()`

### Prerequisites
- `prerequisites` is a jsonb array of stage IDs that must be completed first
- Used for workflow validation (e.g., can't go to "Clear to Close" without "Underwriting")

---

## Usage Patterns

### Create default stages for new organization
```sql
INSERT INTO pipeline_stages (organization_id, name, slug, sort_order, color, sla_days) VALUES
  ('org-uuid', 'Pre-Qualification', 'pre_qual', 1, '#3B82F6', 1),
  ('org-uuid', 'Application', 'application', 2, '#10B981', 3),
  ('org-uuid', 'Processing', 'processing', 3, '#F59E0B', 7),
  ('org-uuid', 'Underwriting', 'underwriting', 4, '#EF4444', 5),
  ('org-uuid', 'Clear to Close', 'clear_to_close', 5, '#8B5CF6', 2),
  ('org-uuid', 'Closing', 'closing', 6, '#EC4899', 1),
  ('org-uuid', 'Funded', 'funded', 7, '#059669', NULL);
```

### Move application to stage
```sql
UPDATE applications
SET
  pipeline_stage_id = 'stage-uuid',
  stage_entered_at = now(),
  updated_at = now()
WHERE id = 'app-uuid';
```

### Get applications by stage with SLA status
```sql
SELECT
  a.*,
  ps.name as stage_name,
  ps.color as stage_color,
  CASE
    WHEN ps.sla_days IS NOT NULL
      AND a.stage_entered_at + (ps.sla_days || ' days')::interval < now()
    THEN true
    ELSE false
  END as is_overdue
FROM applications a
LEFT JOIN pipeline_stages ps ON a.pipeline_stage_id = ps.id
WHERE a.organization_id = 'org-uuid'
  AND a.status NOT IN ('funded', 'denied', 'withdrawn')
ORDER BY ps.sort_order, a.stage_entered_at;
```

---

## Common Queries

### Get active stages for organization
```sql
SELECT *
FROM pipeline_stages
WHERE organization_id = 'org-uuid'
  AND is_active = true
ORDER BY sort_order;
```

### Application count by stage (pipeline report)
```sql
SELECT
  ps.name,
  ps.color,
  COUNT(a.id) as application_count,
  AVG(a.loan_amount) as avg_loan_amount,
  COUNT(*) FILTER (
    WHERE ps.sla_days IS NOT NULL
      AND a.stage_entered_at + (ps.sla_days || ' days')::interval < now()
  ) as overdue_count
FROM pipeline_stages ps
LEFT JOIN applications a ON ps.id = a.pipeline_stage_id
  AND a.status NOT IN ('funded', 'denied', 'withdrawn')
WHERE ps.organization_id = 'org-uuid'
  AND ps.is_active = true
GROUP BY ps.id, ps.name, ps.color, ps.sort_order
ORDER BY ps.sort_order;
```

---

## Related Tables

- `applications` — Applications reference this via `pipeline_stage_id`
- See [loan-applications.md](./loan-applications.md) for application workflow

---

*Part of Phase 5B LO Portal release. RLS policies pending implementation.*
