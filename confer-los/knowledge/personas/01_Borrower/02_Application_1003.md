---
type: screen-schema
persona: Borrower (Applicant)
screen: Portal Activation & Application (1003)
stage: 8-15
system: Consumer Connect Portal
generated: 2026-02-13
source_stubs:
  - modular/01_Borrower/02_Application_1003.md
source_sops:
  - Moxi_Master_SOP_Part1.md (Sections 3-5)
  - Moxi_Master_SOP_Part2.md (Section 4)
compliance_refs:
  - URLA Instructions (Freddie Mac 65 / Fannie Mae 1003) revised 11/2024
---

# 02 — Portal Activation & Digital Loan Application (1003)

## 1. UI Component Map

### Stage 8: Consumer Connect Portal Access

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Username | Text Input | string | YES | Min 6 chars | — |
| Password | Text Input | string (password) | YES | Min 8 chars, complexity rules | — |
| **[Log In]** | Button | — | — | Valid credentials | — |
| **[Create Account]** | Button | — | — | Redirects to registration | — |

### Stage 9: Borrower Personal Information (URLA Section 1a)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Email | Text Input | string (email) | YES | RFC 5322; pre-filled from lead | — |
| Date of Birth | Date Picker | date | YES | Must be 18+ years old | — |
| SSN | Masked Input | string (9 digits) | YES | Format: XXX-XX-XXXX | — |
| Citizenship Status | Dropdown | enum | YES | Values: US Citizen, Permanent Resident, Non-Permanent Resident | — |
| Marital Status | Dropdown | enum | YES | Values: Married, Separated, Unmarried | — |
| Mobile Phone | Text Input | string (phone) | YES | US format; used for SMS consent | — |
| Dependents (Number) | Number Input | integer | NO | >= 0 | `0` |
| Dependents (Ages) | Text Input | string | NO | Comma-separated ages | — |
| Current Address | Address Group | JSONB | YES | Street, City, State, ZIP | — |
| Years at Address | Number Input | decimal | YES | >= 0 | — |
| Previous Address | Address Group | JSONB | CONDITIONAL | Required if current address < 2 years | — |

### Stage 9.2: Employment and Income (URLA Section 1b)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Current Employer | Text Input | string | YES | Non-empty | — |
| Position/Title | Text Input | string | YES | Non-empty | — |
| Start Date | Date Picker | date | YES | Must be past date | — |
| Monthly Income (Base) | Currency Input | decimal(12,2) | YES | > 0 | — |
| Overtime | Currency Input | decimal(12,2) | NO | >= 0 | `0.00` |
| Bonuses | Currency Input | decimal(12,2) | NO | >= 0 | `0.00` |
| **[This is my current job]** | Checkbox | boolean | YES | — | `true` |

### Stage 9.3: Loan Details & Property (URLA Section 4a)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Purpose of Loan | Dropdown | enum | YES | Values: Purchase, Refinance, Other | — |
| Est. Purchase Price | Currency Input | decimal(12,2) | YES | > 0 | — |
| Down Payment | Currency Input | decimal(12,2) | YES | > 0 | — |
| Down Payment % | Auto-Calculated | decimal(5,2) | — | `(down_payment / purchase_price) * 100` | — |
| Have You Identified a Home? | Radio Group | boolean | YES | Yes/No | — |
| Property Use | Dropdown | enum | YES | Values: Primary Home, Second Home, Investment | — |
| Property Type | Dropdown | enum | YES | Values: Single Family, Condo, Multi-Family, Manufactured | — |

### Stage 10: Expenses & Assets (URLA Sections 2a, 2c)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Current Mortgage Payment | Currency Input | decimal(12,2) | NO | >= 0 | `0.00` |
| Property Taxes | Currency Input | decimal(12,2) | NO | >= 0 | `0.00` |
| Homeowners Insurance | Currency Input | decimal(12,2) | NO | >= 0 | `0.00` |
| HOA Dues | Currency Input | decimal(12,2) | NO | >= 0 | `0.00` |
| Total Monthly Housing | Auto-Calculated | decimal(12,2) | — | Sum of above | — |
| **[Add Asset]** | Button | — | — | Opens asset entry modal | — |
| Asset Type | Dropdown | enum | YES | Values: Cash On Hand, Checking, Savings, Retirement, Stocks/Bonds, Other | — |
| Financial Institution | Text Input | string | YES | Non-empty | — |
| Cash/Market Value | Currency Input | decimal(12,2) | YES | > 0 | — |

### Stage 12: Liabilities & Credit (URLA Sections 2c, 2d)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Credit Authorization Agreement | Static Text | — | YES | Must be read | — |
| **[Authorize]** | Button | — | YES | Triggers credit pull | — |
| Manual Liability Type | Text Input | string | NO | E.g., "Child Care" | — |
| Manual Liability Amount | Currency Input | decimal(12,2) | NO | > 0 | — |

### Stage 13: eConsent & Submission

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| eConsent Agreement | Static Text | — | YES | Must be read | — |
| **[Agree]** (eConsent) | Button | — | YES | Grants electronic consent | — |
| Summary Page | Review Panel | — | — | All sections must show checkmark | — |
| **[SUBMIT]** | Button | — | YES | All sections validated | — |

### Stage 14-15: Confirmation & Education

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Confirmation Screen | Static Page | — | — | "Thank You — Let's Take the Next Step with MoXi" | — |
| Advisor Contact Card | Card Component | — | — | Displays assigned MLO info | — |
| **[WHAT'S NEXT?]** | Button | — | NO | Opens educational carousel | — |
| Educational Slides (1-6) | Carousel | — | — | 6 slides covering next steps, timelines, fees | — |

---

## 2. Database Mapping

### Existing Schema Mappings

| UI Field | Supabase Table | Column | Type | Notes |
|---|---|---|---|---|
| Email | `customers` | `email` | text | Pre-filled from lead capture |
| Date of Birth | `customers` | `date_of_birth` | date | URLA Section 1a |
| SSN | `customers` | `ssn_last_four` | text | ⚠️ Only last 4 stored; full SSN needs secure vault |
| Citizenship Status | `customers` | `citizenship_status` | text | URLA Section 1a |
| Marital Status | `customers` | `marital_status` | text | URLA Section 1a |
| Mobile Phone | `customers` | `phone` | text | — |
| Current Address | `residences` | `address` (JSONB) | JSONB | `is_current = true`, `residence_type = 'own'` or `'rent'` |
| Previous Address | `residences` | `address` (JSONB) | JSONB | `is_current = false`; required if current < 2 years |
| Current Employer | `employments` | `employer_name` | text | — |
| Position/Title | `employments` | `position_title` | text | — |
| Start Date | `employments` | `start_date` | date | — |
| Is Current Job | `employments` | `is_current` | boolean | — |
| Monthly Income (Base) | `incomes` | `amount` | decimal | `income_type = 'base'`, `frequency = 'monthly'` |
| Overtime | `incomes` | `amount` | decimal | `income_type = 'overtime'` |
| Bonuses | `incomes` | `amount` | decimal | `income_type = 'bonus'` |
| Purpose of Loan | `applications` | `purpose` | text (enum) | Values: purchase, refinance, other |
| Est. Purchase Price | `properties` | `purchase_price` | decimal | — |
| Down Payment | `applications` | `down_payment_amount` | decimal | — |
| Down Payment % | `applications` | `down_payment_percentage` | decimal | Auto-calculated |
| Loan Amount | `applications` | `loan_amount` | decimal | `purchase_price - down_payment` |
| Property Use | `properties` | `occupancy_type` | text | — |
| Property Type | `properties` | `property_type` | text | — |
| Have Identified Home? | `properties` | — | — | If No → property fields are TBD |
| Housing Expenses (Mortgage) | `real_estate_owned` | `mortgage_payment` | decimal | Current primary residence |
| Housing Expenses (Taxes) | `real_estate_owned` | `tax_amount` | decimal | — |
| Housing Expenses (Insurance) | `real_estate_owned` | `insurance_amount` | decimal | — |
| Housing Expenses (HOA) | `real_estate_owned` | `hoa_amount` | decimal | — |
| Asset Type | `assets` | `asset_type` | text (enum) | — |
| Financial Institution | `assets` | `institution_name` | text | — |
| Cash/Market Value | `assets` | `cash_market_value` | decimal | — |
| Liability Type | `liabilities` | `liability_type` | text (enum) | — |
| Liability Amount | `liabilities` | `monthly_payment` | decimal | — |
| Application Status | `applications` | `status` | text (enum) | Set to `submitted` on submit |
| Application Stage | `applications` | `stage` | text (enum) | Set to `application` |
| eConsent | `customers` | `e_consent_status` | text | Updated to `granted` on agree |

### 🔴 Schema Change Proposals (Missing Mappings)

| UI Field | Proposed Table | Proposed Column | Type | Rationale |
|---|---|---|---|---|
| Full SSN | `customers` | — | — | Only `ssn_last_four` exists. Full SSN must be stored in a **PCI-compliant vault** (e.g., Skyflow, VGS), NOT in Supabase. Add `ssn_vault_token` reference column. |
| SSN Vault Reference | `customers` | `ssn_vault_token` | text | Reference token to PCI-compliant external vault storing full SSN |
| Dependents Count | `customers` | `dependents_count` | integer | URLA Section 1a requires number of dependents |
| Dependents Ages | `customers` | `dependents_ages` | text | URLA Section 1a requires ages of dependents; comma-separated |
| Credit Authorization Signed | `application_customers` | `credit_auth_signed` | boolean | Tracks whether borrower authorized credit pull |
| Credit Authorization Date | `application_customers` | `credit_auth_signed_at` | timestamptz | Timestamp for compliance audit |
| eConsent Granted At | `customers` | `e_consent_granted_at` | timestamptz | Timestamp of eConsent for ESIGN Act compliance |
| Monthly Rent (if renting) | `residences` | `monthly_rent` | decimal | ✅ Already exists — confirm mapping |
| Employer Phone | `employments` | `employer_phone` | text | ✅ Already exists |
| Employer Address | `employments` | `employer_address` | JSONB | ✅ Already exists |
| Years at Current Address | `residences` | — | — | Calculated from `start_date` to now; no column needed |

#### Proposed Column Additions to `customers` Table

```sql
ALTER TABLE customers
  ADD COLUMN ssn_vault_token text,
  ADD COLUMN dependents_count integer DEFAULT 0,
  ADD COLUMN dependents_ages text,
  ADD COLUMN e_consent_granted_at timestamptz;

COMMENT ON COLUMN customers.ssn_vault_token IS 'Reference token for full SSN stored in PCI-compliant vault (Skyflow/VGS)';
COMMENT ON COLUMN customers.dependents_count IS 'URLA Section 1a: Number of dependents';
COMMENT ON COLUMN customers.dependents_ages IS 'URLA Section 1a: Ages of dependents, comma-separated';
COMMENT ON COLUMN customers.e_consent_granted_at IS 'ESIGN Act: Timestamp of electronic consent agreement';
```

#### Proposed Column Additions to `application_customers` Table

```sql
ALTER TABLE application_customers
  ADD COLUMN credit_auth_signed boolean DEFAULT false,
  ADD COLUMN credit_auth_signed_at timestamptz;

COMMENT ON COLUMN application_customers.credit_auth_signed IS 'Whether borrower signed the credit authorization agreement';
COMMENT ON COLUMN application_customers.credit_auth_signed_at IS 'Timestamp of credit authorization for compliance audit';
```

---

## 3. Workflow & Triggers

### User Actions → System State Changes

| Step | Trigger (User Action) | Actor | System Action | State Change | Notification |
|---|---|---|---|---|---|
| 8.1 | Login / Create Account | Borrower | Authenticate via Supabase Auth; link to `customers` record | Session active | — |
| 9.1-9.3 | Fill Personal Info, Employment, Property | Borrower | Upsert into `customers`, `residences`, `employments`, `incomes`, `properties` | `applications.status` = `draft` | — |
| 10.1-10.2 | Enter Expenses & Assets | Borrower | Upsert into `real_estate_owned`, `assets`, `asset_ownership` | — | — |
| 12.1 | Click **[Authorize]** (Credit) | Borrower | Set `application_customers.credit_auth_signed` = true; log `application_events` | Credit pull authorized | Internal: Processor notified |
| 12.2 | Add Manual Liabilities | Borrower | INSERT into `liabilities`, `liability_ownership` | — | — |
| 13.1 | Click **[Agree]** (eConsent) | Borrower | Set `customers.e_consent_status` = `granted`; set `e_consent_granted_at` | eConsent active | — |
| 13.2 | Click **[SUBMIT]** | Borrower | Set `applications.status` = `submitted`; INSERT `application_events` (type: `application_submitted`) | `applications.stage` = `application` → `processing` | Email: "Welcome to MoXi" to borrower; Internal: MLO + Processor notified |

### Automation Rules

- **Auto-Calculate**: `down_payment_percentage` = `(down_payment_amount / purchase_price) * 100` on INSERT/UPDATE to `applications`.
- **Address History Check**: If sum of residence durations < 24 months, flag for additional address collection.
- **LTV Calculation**: `ltv` = `(loan_amount / property_value) * 100` on INSERT/UPDATE to `applications`.
- **Application Event Log**: Every status change fires an INSERT into `application_events` via database trigger.

---

## 4. Compliance Notes

| Regulation | URLA Section | Requirement | Current Status |
|---|---|---|---|
| **URLA 1003** | 1a | Personal info, dependents, address history (24mo) | 🟡 PARTIAL — `dependents_count`/`dependents_ages` columns missing |
| **URLA 1003** | 1b | Employment with employer phone (main number, not personal) | ✅ OK — `employments.employer_phone` exists |
| **URLA 1003** | 1d | Previous employment if current < 2 years | ✅ OK — Multiple `employments` rows with `is_current` flag |
| **URLA 1003** | 2a | Assets with institution and value | ✅ OK — `assets` table |
| **URLA 1003** | 2c | All personal debt including deferred | ✅ OK — `liabilities` table |
| **URLA 1003** | 4a | Loan purpose, amount, property info | ✅ OK — `applications` + `properties` |
| **ESIGN Act** | — | Electronic consent with timestamp | 🔴 MISSING — `e_consent_granted_at` proposed |
| **ECOA / Reg B** | — | Cannot require marital status info in certain states | ✅ OK — Field is optional in Community Property states |
| **FCRA** | — | Credit authorization must be signed before pull | 🔴 MISSING — `credit_auth_signed` columns proposed |
| **PCI-DSS** | — | Full SSN must NOT be stored in plaintext database | 🔴 CRITICAL — `ssn_vault_token` proposed; full SSN must go to external vault |

---

## 5. MoXi-Specific Customizations

| Feature | Description | Isolation Strategy |
|---|---|---|
| $1M Purchase / $400K Down Example | MoXi demo uses high-value Mexico property; standard US LOS handles any amount | No isolation needed — standard fields |
| "TBD" Property Address | Mexico property may not have US-style address; property can be TBD at pre-qual | `properties.address` JSONB supports freeform; application proceeds without full address |
| Consumer Connect Portal | MoXi uses Encompass Consumer Connect as borrower-facing portal | Portal integration is configuration, not schema |
| Educational Carousel (Slides 1-6) | MoXi-specific post-submission content (Mexico closing timeline, 10-day activity requirement, fee collection) | Content is application-layer; no DB schema impact |
