# Declarations & Demographics Tables

**Category**: Compliance
**Tables**: `declarations`, `demographics`

---

## Table: `declarations`

**Purpose**: URLA Section IV - Borrower declarations. Required disclosures about property occupancy, financial history, and legal issues.

### Property & Transaction Declarations
- `will_occupy_as_primary`: boolean (primary residence intent)
- `have_ownership_interest_last_3_years`: boolean
- `property_type_if_owned`: Single Family, Condo, etc.
- `title_holding_method`: Sole, Joint with Spouse, etc.
- `is_family_relationship_with_seller`: boolean (related party transaction)

### Undisclosed Obligations
- `have_undisclosed_borrowed_funds`: boolean (borrowed down payment)
- `undisclosed_borrowed_amount`: numeric
- `have_undisclosed_mortgage_application`: boolean (other pending loans)
- `have_undisclosed_credit_application`: boolean

### Financial Obligations
- `have_priority_liens`: boolean (IRS liens, judgments)
- `have_cosigned_obligations`: boolean
- `have_outstanding_judgments`: boolean
- `are_delinquent_on_federal_debt`: boolean (student loans, taxes)
- `is_party_to_lawsuit`: boolean

### Credit Events
- `have_deed_in_lieu`: boolean
- `have_short_sale`: boolean
- `have_foreclosure`: boolean
- `have_bankruptcy`: boolean
- `bankruptcy_chapter` (jsonb): `{"chapter": "7", "year": 2020, "case_number": "..."}`

### Explanations
- `explanations` (jsonb): Array of explanation objects
```json
[
  {
    "question": "foreclosure",
    "explanation": "Foreclosure in 2019 due to job loss. Fully resolved, no deficiency."
  },
  {
    "question": "undisclosed_borrowed_funds",
    "explanation": "Borrowed $10,000 from parents, documented with promissory note."
  }
]
```

### Waiting Periods After Credit Events

| Event | Conventional | FHA | VA |
|-------|--------------|-----|-----|
| Bankruptcy Ch 7 | 4 years | 2 years | 2 years |
| Bankruptcy Ch 13 | 2 years | 1 year | 1 year |
| Foreclosure | 7 years | 3 years | 2 years |
| Short Sale | 4 years | 3 years | 2 years |
| Deed in Lieu | 4 years | 3 years | 2 years |

### Business Logic
- If ANY adverse declaration is YES, explanation required in `explanations`
- Waiting period validation happens in underwriting logic
- `will_occupy_as_primary` affects loan terms (primary residence rates are better)

---

## Table: `demographics`

**Purpose**: HMDA (Home Mortgage Disclosure Act) demographic data. Required for regulatory reporting.

### Data Collection
- `collection_method`: face_to_face, telephone, fax_or_mail, email, internet
- `declined_to_provide`: boolean (borrower can decline to provide)

### Ethnicity
- `ethnicity` (jsonb): Array of ethnicity codes
  - `hispanic_or_latino` (with subcategories)
  - `not_hispanic_or_latino`
- `ethnicity_other_description`: text (for "Other" ethnicity)

### Race
- `race` (jsonb): Array of race codes (can select multiple)
  - `american_indian_or_alaska_native`
  - `asian`
  - `black_or_african_american`
  - `native_hawaiian_or_other_pacific_islander`
  - `white`
- `race_tribe_name`: text (for Native American tribes)
- `race_other_asian`: text (specific Asian ethnicity)
- `race_other_pacific_islander`: text

### Sex
- `sex`: male, female, i_do_not_wish_to_provide

### Visual Observation (if not provided by applicant)
- `observed_ethnicity` (jsonb)
- `observed_race` (jsonb)
- `observed_sex`: text

### JSONB Structures

**Ethnicity Example**:
```json
{
  "categories": ["hispanic_or_latino"],
  "subcategories": ["mexican"]
}
```

**Race Example** (can be multiple):
```json
{
  "categories": ["asian", "white"],
  "asian_subcategories": ["chinese", "filipino"]
}
```

### Compliance Requirements
- Must collect for ALL applicants (primary + co-borrowers)
- Borrower can decline to provide (check `declined_to_provide`)
- If declined, visual observation required for in-person applications
- Data used for HMDA reporting (not for loan decision)
- Must be kept confidential, not shared with underwriters

### Privacy & Security
- RLS policies must restrict access to authorized users only
- Should NOT be visible to underwriters (to prevent bias)
- Reported in aggregate to CFPB annually

---

## URLA Mapping

- **Section IV**: Declarations → `declarations`
- **Section X**: Demographic Information → `demographics`

---

## Common Patterns

### Check for adverse declarations
```sql
SELECT
  customer_id,
  have_bankruptcy OR have_foreclosure OR have_short_sale OR
  have_outstanding_judgments OR is_party_to_lawsuit as has_adverse_credit
FROM declarations
WHERE application_id = 'app-uuid';
```

### Verify all borrowers completed demographics
```sql
SELECT ac.customer_id, c.first_name, c.last_name
FROM application_customers ac
JOIN customers c ON ac.customer_id = c.id
LEFT JOIN demographics d ON ac.customer_id = d.customer_id AND ac.application_id = d.application_id
WHERE ac.application_id = 'app-uuid'
  AND d.id IS NULL; -- Missing demographics
```

---

*See also: [loan-applications.md](./loan-applications.md) for application workflow*
