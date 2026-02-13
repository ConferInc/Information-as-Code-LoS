# Lead Sources Table

**Category**: Sales & Lead Management (Phase 5B)
**Table**: `lead_sources`
**Purpose**: Lead source tracking for ROI analysis and marketing attribution
**Last Updated**: 2026-02-12

---

## Overview

The `lead_sources` table tracks where leads originate from, enabling ROI analysis and marketing campaign effectiveness measurement. Each organization can define custom lead sources with cost tracking.

---

## Columns

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | uuid | NO | `gen_random_uuid()` | Primary key |
| `organization_id` | uuid | NO | - | FK to `organizations` |
| `name` | text | NO | - | Source name (e.g., "Google Ads - Bay Area") |
| `category` | text | NO | - | Source category (see values below) |
| `is_active` | boolean | NO | `true` | Is source currently in use? |
| `cost_per_lead` | numeric | YES | NULL | Average cost per lead from this source |
| `metadata` | jsonb | YES | NULL | Additional source details |
| `created_at` | timestamp | NO | `now()` | Creation timestamp |

---

## Constraints

- **PK**: `id`
- **FK**: `organization_id` → `organizations(id)`

---

## Category Values

| Value | Description |
|-------|-------------|
| `web` | Website/online form |
| `phone` | Phone call |
| `referral` | Customer referral |
| `walk_in` | Walk-in to office |
| `builder` | Builder/developer |
| `realtor` | Real estate agent |
| `marketing` | Marketing campaign |
| `purchase_list` | Purchased lead list |
| `social_media` | Social media |
| `other` | Other |

---

## RLS Policies

**Status**: ⚠️ **Not yet configured**

---

## Usage Patterns

### Create lead source
```sql
INSERT INTO lead_sources (
  organization_id, name, category, cost_per_lead, metadata
) VALUES (
  'org-uuid',
  'Google Ads - Refinance Campaign Q1',
  'marketing',
  45.00,
  jsonb_build_object(
    'campaign_id', 'GA-12345',
    'platform', 'google_ads'
  )
);
```

### ROI report by source
```sql
SELECT
  ls.name,
  ls.category,
  ls.cost_per_lead,
  COUNT(l.id) as lead_count,
  COUNT(l.id) FILTER (WHERE l.status = 'converted') as conversions,
  ROUND(
    COUNT(l.id) FILTER (WHERE l.status = 'converted')::numeric / NULLIF(COUNT(l.id), 0) * 100,
    2
  ) as conversion_rate_pct,
  ls.cost_per_lead * COUNT(l.id) as total_cost,
  SUM(a.loan_amount) FILTER (WHERE l.status = 'converted') as total_funded_volume
FROM lead_sources ls
LEFT JOIN leads l ON ls.name = l.source_detail
  AND l.source = ls.category
LEFT JOIN applications a ON l.converted_application_id = a.id
  AND a.status = 'funded'
WHERE ls.organization_id = 'org-uuid'
  AND l.created_at >= date_trunc('quarter', now())
GROUP BY ls.id, ls.name, ls.category, ls.cost_per_lead
ORDER BY total_funded_volume DESC NULLS LAST;
```

---

*Part of Phase 5B LO Portal release. RLS policies pending implementation.*
