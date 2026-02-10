# Real Estate Tables

**Category**: Real Estate
**Tables**: `real_estate_owned`, `residences`

---

## Table: `real_estate_owned`

**Purpose**: Properties currently owned by borrowers. Used for:
- Rental income qualification
- DTI calculation (mortgage payments)
- Down payment source (if selling property)
- Reserve requirements (if keeping property)

### Key Property Information
- `property_address*`: street, unit, city, state, zip_code, country
- `property_type`: single_family, condo, townhouse, multi_family_2_4
- `property_value`: numeric(12,2) (current market value)
- `property_status`: current_residence, rental, pending_sale, sold
- `intended_occupancy`: primary, second_home, investment

### Financial Information
- `monthly_insurance_taxes_hoa`: PITI excluding principal & interest
- **Mortgage Details**:
  - `has_mortgage`: boolean
  - `mortgage_creditor_name`, `mortgage_account_number`
  - `mortgage_monthly_payment`: numeric (included in DTI)
  - `mortgage_unpaid_balance`: numeric
  - `mortgage_to_be_paid_off`: boolean (if selling or paying off)
  - `mortgage_type`: conventional, fha, va, usda
- **HELOC Details**:
  - `has_heloc`: boolean
  - `heloc_credit_limit`, `heloc_balance`
- **Rental Details**:
  - `is_rental`: boolean
  - `monthly_rental_income`: numeric (gross rent)
  - `net_rental_income`: numeric (after 75% multiplier or expenses)

### Common Scenarios

**Current Residence (Keeping)**:
```sql
INSERT INTO real_estate_owned (
  customer_id, application_id,
  property_address, property_status, intended_occupancy,
  property_value, has_mortgage, mortgage_monthly_payment
) VALUES (
  'cust-uuid', 'app-uuid',
  '123 Oak St, Chicago, IL 60601',
  'current_residence', 'primary',
  450000, true, 2200
);
-- Impact: $2,200 mortgage payment added to DTI
```

**Rental Property (Income Qualification)**:
```sql
INSERT INTO real_estate_owned (
  customer_id, application_id,
  property_address, property_status, is_rental,
  monthly_rental_income, net_rental_income,
  has_mortgage, mortgage_monthly_payment
) VALUES (
  'cust-uuid', 'app-uuid',
  '456 Elm Ave, Austin, TX 78701',
  'rental', true,
  2500, 1875, -- 75% of gross rent = $1,875 net
  true, 1600
);
-- Impact: +$1,875 income, +$1,600 debt → Net +$275/mo
```

### Calculate REO Impact on DTI
```sql
SELECT
  customer_id,
  SUM(CASE WHEN has_mortgage THEN mortgage_monthly_payment ELSE 0 END) as total_reo_debt,
  SUM(CASE WHEN is_rental THEN net_rental_income ELSE 0 END) as total_rental_income
FROM real_estate_owned
WHERE application_id = 'app-uuid'
  AND property_status NOT IN ('sold', 'pending_sale')
  AND mortgage_to_be_paid_off = false
GROUP BY customer_id;
```

---

## Table: `residences`

**Purpose**: 2-year residence history. Required for loan application. Gaps require explanation.

### Key Columns
- `residence_type`: current, previous
- `street_address`, `unit_number`, `city`, `state`, `zip_code`, `country`
- `move_in_date`, `move_out_date`
- `years_at_address`, `months_at_address` (calculated or manually entered)
- `housing_type`: own, rent, living_rent_free
- `monthly_rent`: numeric (if renting, used for housing expense history)
- `is_mailing_address`: boolean (current mailing address)

### Validation Rules
- Must have at least 2 years total residence history
- Gaps > 30 days require explanation in `declarations.explanations`
- Current residence has `move_out_date` = NULL
- Sum of all residence durations should be ≥ 24 months

### Example: Complete 2-Year History
```sql
-- Current residence (1 year)
INSERT INTO residences (customer_id, application_id,
  residence_type, street_address, city, state, zip_code,
  move_in_date, years_at_address, months_at_address,
  housing_type, monthly_rent, is_mailing_address)
VALUES ('cust-uuid', 'app-uuid',
  'current', '789 Pine St', 'Denver', 'CO', '80201',
  '2025-02-01', 1, 0, 'rent', 1800, true);

-- Previous residence (1.5 years)
INSERT INTO residences (customer_id, application_id,
  residence_type, street_address, city, state, zip_code,
  move_in_date, move_out_date, years_at_address, months_at_address,
  housing_type, monthly_rent)
VALUES ('cust-uuid', 'app-uuid',
  'previous', '321 Maple Dr', 'Boulder', 'CO', '80301',
  '2023-08-01', '2025-01-31', 1, 6, 'rent', 1600);
```

### Verify 2-Year Coverage
```sql
SELECT
  customer_id,
  SUM(years_at_address * 12 + months_at_address) as total_months
FROM residences
WHERE application_id = 'app-uuid'
GROUP BY customer_id
HAVING SUM(years_at_address * 12 + months_at_address) >= 24;
```

---

## URLA Mapping

- **Section IId**: Real Estate Owned → `real_estate_owned`
- **Section Ic**: Residence History → `residences`

---

*See also: [declarations-and-demographics.md](./declarations-and-demographics.md) for property-related declarations*
