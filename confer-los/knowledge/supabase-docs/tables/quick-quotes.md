# Quick Quotes Table

**Category**: Sales & Lead Management (Phase 5B)
**Table**: `quick_quotes`
**Purpose**: Fast scenario modeling for leads and applications with pre-qualification letter tracking
**Last Updated**: 2026-02-12

---

## Overview

The `quick_quotes` table stores loan scenarios and payment estimates for leads (pre-application) and applications (in-process). Loan officers can generate multiple quotes to help borrowers compare options. Quotes can be converted to pre-qualification letters.

---

## Columns

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | uuid | NO | `gen_random_uuid()` | Primary key |
| `organization_id` | uuid | NO | - | FK to `organizations` |
| `lead_id` | uuid | YES | NULL | FK to `leads` (for pre-application quotes) |
| `application_id` | uuid | YES | NULL | FK to `applications` (for in-process quotes) |
| `created_by` | uuid | NO | - | FK to `users` (loan officer) |
| `loan_purpose` | text | NO | - | Purchase, refinance, etc. |
| `purchase_price` | numeric | YES | NULL | Purchase price (for purchase loans) |
| `loan_amount` | numeric | NO | - | Loan amount |
| `down_payment` | numeric | YES | NULL | Down payment amount |
| `down_payment_pct` | numeric | YES | NULL | Down payment percentage |
| `property_type` | text | YES | NULL | Property type |
| `occupancy_type` | text | YES | NULL | Primary residence, second home, investment |
| `credit_score_range` | text | YES | NULL | Estimated credit score range |
| `property_state` | text | YES | NULL | Property state |
| `loan_term_months` | integer | NO | `360` | Loan term (default 30 years) |
| `interest_rate` | numeric | YES | NULL | Interest rate (%) |
| `monthly_pi` | numeric | YES | NULL | Monthly principal & interest |
| `monthly_taxes` | numeric | YES | NULL | Monthly property taxes |
| `monthly_insurance` | numeric | YES | NULL | Monthly homeowner's insurance |
| `monthly_mi` | numeric | YES | NULL | Monthly mortgage insurance |
| `monthly_hoa` | numeric | YES | NULL | Monthly HOA fees |
| `monthly_total` | numeric | YES | NULL | Total monthly payment (PITI + HOA) |
| `ltv` | numeric | YES | NULL | Loan-to-value ratio (%) |
| `dti` | numeric | YES | NULL | Debt-to-income ratio (%) |
| `borrower_annual_income` | numeric | YES | NULL | Borrower's annual income |
| `borrower_monthly_debts` | numeric | YES | NULL | Borrower's monthly debts |
| `scenario_name` | text | YES | NULL | User-defined scenario name |
| `loan_product_id` | uuid | YES | NULL | FK to `loan_products` |
| `prequal_letter_generated` | boolean | NO | `false` | Has pre-qual letter been generated? |
| `metadata` | jsonb | YES | NULL | Additional quote details |
| `created_at` | timestamp | NO | `now()` | Creation timestamp |
| `updated_at` | timestamp | NO | `now()` | Last update timestamp |

---

## Constraints

- **PK**: `id`
- **FK**: `organization_id` → `organizations(id)`
- **FK**: `lead_id` → `leads(id)`
- **FK**: `application_id` → `applications(id)`
- **FK**: `created_by` → `users(id)`
- **FK**: `loan_product_id` → `loan_products(id)`
- **CHECK**: Either `lead_id` OR `application_id` must be set (not both, not neither)

---

## Indexes

| Index Name | Columns | Purpose |
|------------|---------|---------|
| `quick_quotes_lead_idx` | `lead_id` | Get quotes for a lead |
| `quick_quotes_app_idx` | `application_id` | Get quotes for an application |
| `quick_quotes_created_by_idx` | `created_by, created_at` | LO's recent quotes |

---

## RLS Policies

**Status**: ⚠️ **Not yet configured**

---

## Business Logic

### Quote Calculation
Quotes calculate:
- **Monthly PI**: Principal & interest payment based on loan amount, rate, term
- **LTV**: Loan amount / purchase price (or appraised value)
- **DTI**: (Monthly debts + monthly housing payment) / (monthly income)

### Pre-Qualification Letters
- Loan officers can generate pre-qual letters from quotes
- Sets `prequal_letter_generated = true`
- Pre-qual letter is typically a PDF document stored separately

### Multiple Scenarios
- Borrowers can compare multiple scenarios (different rates, down payments, etc.)
- Use `scenario_name` to identify scenarios ("Best Rate", "Lowest Payment", etc.)

---

## Usage Patterns

### Create quick quote for lead
```sql
INSERT INTO quick_quotes (
  organization_id, lead_id, created_by,
  loan_purpose, loan_amount, purchase_price, down_payment,
  property_type, occupancy_type, property_state,
  loan_term_months, interest_rate, credit_score_range,
  monthly_pi, monthly_taxes, monthly_insurance, monthly_total,
  ltv, scenario_name
) VALUES (
  'org-uuid', 'lead-uuid', auth.uid(),
  'purchase', 280000, 350000, 70000,
  'single_family', 'primary_residence', 'CA',
  360, 6.75,
  '740_759',
  1816.50, 375.00, 125.00, 2316.50,
  80.0,
  'Conventional 20% Down'
);
```

### Get quotes for lead
```sql
SELECT *
FROM quick_quotes
WHERE lead_id = 'lead-uuid'
ORDER BY created_at DESC;
```

### Compare scenarios
```sql
SELECT
  scenario_name,
  loan_amount,
  interest_rate,
  monthly_total,
  ltv,
  CASE
    WHEN ltv > 80 THEN 'Requires PMI'
    ELSE 'No PMI'
  END as pmi_status
FROM quick_quotes
WHERE lead_id = 'lead-uuid'
ORDER BY monthly_total;
```

---

## Common Queries

### Quotes needing pre-qual letters
```sql
SELECT
  qq.*,
  l.first_name || ' ' || l.last_name as lead_name,
  l.email
FROM quick_quotes qq
JOIN leads l ON qq.lead_id = l.id
WHERE qq.organization_id = 'org-uuid'
  AND qq.prequal_letter_generated = false
  AND l.status IN ('qualified', 'quoted')
ORDER BY qq.created_at DESC;
```

### Quote volume by loan officer
```sql
SELECT
  u.first_name || ' ' || u.last_name as loan_officer,
  COUNT(*) as total_quotes,
  COUNT(*) FILTER (WHERE qq.prequal_letter_generated) as prequal_letters,
  AVG(qq.loan_amount) as avg_loan_amount,
  AVG(qq.monthly_total) as avg_monthly_payment
FROM quick_quotes qq
JOIN users u ON qq.created_by = u.id
WHERE qq.organization_id = 'org-uuid'
  AND qq.created_at >= date_trunc('month', now())
GROUP BY u.id, u.first_name, u.last_name
ORDER BY total_quotes DESC;
```

---

## Integration Notes

### Server Actions
- `generateQuickQuote()` — Create quote with calculations
- `generatePrequalLetter()` — Create pre-qual letter PDF

### Related Tables
- See [leads.md](./leads.md) for lead management
- See [loan-applications.md](./loan-applications.md) for applications

---

*Part of Phase 5B LO Portal release. RLS policies pending implementation.*
