# Assets & Liabilities Tables

**Category**: Assets & Liabilities
**Tables**: `assets`, `asset_ownership`, `gift_funds`, `liabilities`, `liability_ownership`

---

## Table: `assets`

**Purpose**: Financial assets for down payment, closing costs, and reserves.

### Key Columns
- `asset_category`: checking, savings, investment, retirement, stocks, bonds, mutual_funds, certificate_of_deposit, money_market
- `asset_type`: More specific subcategory
- `institution_name`, `account_number` (last 4 digits)
- `cash_or_market_value`: numeric(12,2)
- `is_gift_or_grant`: boolean
- `gift_type`, `gift_source`, `gift_deposited_status` (if gift)
- `verification_status`: not_verified, verified, declined
- `verified_value`: Actual value per bank statement

### Asset Ownership (M:N)
Junction table `asset_ownership` links assets to customers for joint accounts:
- `asset_id` FK, `customer_id` FK
- `ownership_percentage`: numeric (e.g., 50.00 for joint account)
- `ownership_role`: owner, joint_owner

---

## Table: `gift_funds`

**Purpose**: Detailed tracking of gift funds (requires gift letter per regulations).

### Key Columns
- `donor_name`, `donor_relationship` (parent, grandparent, sibling, etc.)
- `gift_amount`: numeric(12,2)
- `gift_date`, `gift_letter_received`: boolean
- `gift_letter_document_id` FK → documents
- `deposited`: boolean, `deposit_date`, `deposit_account`

### Gift Fund Rules
- Gift letter required (signed by donor)
- Must document source of funds
- Donor cannot have interest in transaction
- Gift must be deposited before closing

---

## Table: `liabilities`

**Purpose**: Monthly debts used for DTI calculation. Includes mortgages, auto loans, credit cards, student loans.

### Key Columns
- `liability_type`: mortgage, auto_loan, credit_card, student_loan, personal_loan, alimony, child_support, tax_lien
- `creditor_name`, `account_number`
- `unpaid_balance`: numeric(12,2) (remaining principal)
- `monthly_payment`: numeric(12,2) (used in DTI)
- `months_remaining`: integer (payoff timeline)
- `to_be_paid_off_at_closing`: boolean (excluded from DTI if true)
- `will_be_subordinated`: boolean (for refinances)
- `exclude_from_dti`: boolean
- `exclusion_reason`: paid_off, subordinated, less_than_10_months

### Liability Ownership (M:N)
Junction table `liability_ownership` links liabilities to customers:
- `liability_id` FK, `customer_id` FK
- `ownership_role`: primary_obligor, co_signer, authorized_user
- `is_excluded`: boolean (e.g., authorized user on credit card not counted)

### DTI Calculation
```sql
SELECT
  SUM(l.monthly_payment) as total_monthly_debt
FROM liabilities l
WHERE l.application_id = 'app-uuid'
  AND l.exclude_from_dti = false
  AND l.to_be_paid_off_at_closing = false;
```

### Qualify Joint Liabilities
```sql
-- Get all liabilities for borrowers on application
SELECT
  l.*,
  lo.customer_id,
  lo.ownership_role
FROM liabilities l
JOIN liability_ownership lo ON l.id = lo.liability_id
JOIN application_customers ac ON lo.customer_id = ac.customer_id
WHERE ac.application_id = 'app-uuid'
  AND lo.is_excluded = false;
```

---

## Assets for Down Payment & Reserves

### Calculate Available Funds
```sql
WITH verified_assets AS (
  SELECT
    a.id,
    a.cash_or_market_value,
    ao.customer_id,
    ao.ownership_percentage
  FROM assets a
  JOIN asset_ownership ao ON a.id = ao.asset_id
  JOIN application_customers ac ON ao.customer_id = ac.customer_id
  WHERE ac.application_id = 'app-uuid'
    AND a.verification_status = 'verified'
)
SELECT
  customer_id,
  SUM(cash_or_market_value * (ownership_percentage / 100)) as available_funds
FROM verified_assets
GROUP BY customer_id;
```

### Reserve Requirements
Most loan products require 2-6 months reserves (PITI payments in liquid assets after closing):
```sql
-- Calculate reserves after closing
WITH closing_costs AS (
  SELECT 50000 as down_payment, 8000 as closing_costs
),
monthly_piti AS (
  SELECT 2500 as piti -- Principal, Interest, Taxes, Insurance
),
total_assets AS (
  SELECT SUM(cash_or_market_value) as total FROM assets
  WHERE application_id = 'app-uuid' AND verification_status = 'verified'
)
SELECT
  (total_assets.total - closing_costs.down_payment - closing_costs.closing_costs) / monthly_piti.piti as months_reserves
FROM total_assets, closing_costs, monthly_piti;
```

---

## URLA Mapping

- **Section IIIa**: Assets → `assets`, `asset_ownership`, `gift_funds`
- **Section IIIb**: Liabilities → `liabilities`, `liability_ownership`

---

*See also: [employment-and-income.md](./employment-and-income.md) for income side of DTI*
