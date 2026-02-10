# Employment & Income Tables

**Category**: Employment & Income
**Tables**: `employments`, `incomes`

---

## Table: `employments`

**Purpose**: Employment history for borrowers (current + 2 years). Required for income verification and qualification.

### Key Columns
- `customer_id` FK, `application_id` FK (dual-keyed for customer context)
- `employment_type`: current, previous, self_employed
- `is_current`: boolean flag
- `employer_name`, `employer_phone`, `employer_address*`
- `position_title`, `start_date`, `end_date`
- `years_in_profession`, `months_in_profession` (total experience)
- `is_self_employed`, `ownership_percentage`, `self_employed_monthly_income`
- `is_employed_by_family`, `is_party_to_transaction` (compliance flags)

### Business Logic
- Minimum 2 years employment history required
- Gaps > 30 days require explanation
- Self-employed borrowers require 2 years tax returns
- Current employment verified via VOE (Verification of Employment)

---

## Table: `incomes`

**Purpose**: Income sources from employment and other sources. Feeds into DTI (Debt-to-Income) calculation.

### Key Columns
- `customer_id` FK, `application_id` FK
- `employment_id` FK (optional link to employment)
- `income_source`: employment, self_employment, retirement, social_security, rental, investment, alimony, child_support, disability
- `income_type`: base_salary, overtime, bonus, commission, tips
- `monthly_amount`: numeric(12,2)
- `include_in_qualification`: boolean (if false, excluded from DTI)
- `verification_status`: not_verified, verified, declined
- `verified_amount`: actual verified amount (may differ from stated)

### Common Income Patterns

**W-2 Employee**:
```sql
INSERT INTO incomes (customer_id, application_id, employment_id,
  income_source, income_type, monthly_amount, include_in_qualification)
VALUES ('cust-uuid', 'app-uuid', 'emp-uuid',
  'employment', 'base_salary', 5000.00, true);
```

**Self-Employed (2-year average)**:
```sql
-- Year 1: $60k, Year 2: $72k → Avg: $66k/12 = $5,500/mo
INSERT INTO incomes (customer_id, application_id, employment_id,
  income_source, income_type, monthly_amount, include_in_qualification)
VALUES ('cust-uuid', 'app-uuid', 'emp-uuid',
  'self_employment', 'base_salary', 5500.00, true);
```

### Calculate Total Qualifying Income
```sql
SELECT
  customer_id,
  SUM(monthly_amount) as total_income
FROM incomes
WHERE application_id = 'app-uuid'
  AND include_in_qualification = true
  AND verification_status IN ('not_verified', 'verified')
GROUP BY customer_id;
```

### Calculate DTI (Debt-to-Income Ratio)
```sql
WITH income AS (
  SELECT SUM(monthly_amount) as total FROM incomes
  WHERE application_id = 'app-uuid' AND include_in_qualification = true
),
debt AS (
  SELECT SUM(monthly_payment) as total FROM liabilities
  WHERE application_id = 'app-uuid' AND exclude_from_dti = false
)
SELECT (debt.total / income.total * 100) as dti_ratio
FROM income, debt;
```

---

## URLA Mapping

- **Section IIa**: Employment Information → `employments`
- **Section IIb**: Income → `incomes`

---

*See also: [assets-and-liabilities.md](./assets-and-liabilities.md) for debt side of DTI*
