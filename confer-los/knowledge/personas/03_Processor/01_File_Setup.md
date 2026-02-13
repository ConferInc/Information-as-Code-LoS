---
type: screen-schema
persona: Client Concierge / Processor
screen: File Setup & Processing Workbook
stage: 54-60, 79-80
system: Encompass (LOS)
generated: 2026-02-13
source_stubs:
  - modular/03_Processor/01_File_Setup.md
source_sops:
  - Moxi_SOP_Jan_21_Part2.md (Sections 1, 5)
compliance_refs:
  - URLA Sections 1a-1e (Borrower Info)
  - Selling Guide (Address History, Employment History)
---

# 01 — File Setup & Processing Workbook

## 1. UI Component Map

### Stage 54: Processing Workbook Access

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Encompass Pipeline | Grid View | — | — | Filterable loan list | — |
| Forms List | Sidebar Menu | — | — | Select "Processing Workbook" | — |

### Stage 55: Borrower Information Review

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Borrower Name (Blue Field) | Read-Only / Edit | string | YES | Pre-populated from application | — |
| Borrower Email (Blue Field) | Read-Only / Edit | string (email) | YES | — | — |
| Borrower Phone (Blue Field) | Read-Only / Edit | string (phone) | YES | — | — |
| Current Address (Blue Field) | Read-Only / Edit | JSONB | YES | Street, City, State, ZIP | — |
| "Is the borrower's information complete?" | Dropdown | boolean | YES | Yes/No | — |
| "Min 24 months address history?" | Dropdown | boolean | YES | Yes/No | — |
| Passport Number | Text Input | string | CONDITIONAL | From uploaded document | — |
| Passport Issuing Authority | Text Input | string | CONDITIONAL | E.g., "DEPARTMENT OF STATE" | — |
| Passport Is Current? | Checkbox | boolean | CONDITIONAL | — | — |
| Passport Issued Date | Date Picker | date | CONDITIONAL | — | — |
| Passport Expiration Date | Date Picker | date | CONDITIONAL | Must be future date | — |
| Driver's License Number | Text Input | string | CONDITIONAL | From uploaded document | — |
| DL Issuing Authority | Text Input | string | CONDITIONAL | — | — |
| DL Issued Date | Date Picker | date | CONDITIONAL | — | — |
| DL Expiration Date | Date Picker | date | CONDITIONAL | Must be future date | — |

### Stage 56: Housing Expense Validation

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| **[Edit]** (Paper/Pen Icon) | Button | — | — | Enables edit mode | — |
| Present Housing: Mortgage | Currency Input | decimal(12,2) | NO | >= 0 | — |
| Present Housing: Taxes | Currency Input | decimal(12,2) | NO | >= 0 | — |
| Present Housing: Insurance | Currency Input | decimal(12,2) | NO | >= 0 | — |
| Present Housing: HOA | Currency Input | decimal(12,2) | NO | >= 0 | — |
| Proposed Housing: Mortgage | Currency Input | decimal(12,2) | — | Auto-calculated | — |
| Proposed Housing: Taxes | Currency Input | decimal(12,2) | — | — | — |
| Proposed Housing: Insurance | Currency Input | decimal(12,2) | — | — | — |
| Proposed Housing: HOA | Currency Input | decimal(12,2) | — | — | — |

### Stage 57: Document Verification (Cross-Reference)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| E-Folder | File Browser | — | — | List of uploaded documents | — |
| "Current Mortgage Statement" | Document Viewer | PDF | — | Compare "Total Payment" against Workbook | — |
| Workbook Correction | Edit Fields | decimal | CONDITIONAL | Update if statement differs | — |

### Stage 58: Green Check Validation

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Borrower Info Sections | Section Status | icon (✅/❌) | — | All sections must show green checkmark | — |

### Stage 59: Purchase Contract Review

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Contract Price (USD) | Currency Input | decimal(12,2) | CONDITIONAL | Required if contract received | — |
| Contract Price (MXN) | Currency Input | decimal(12,2) | CONDITIONAL | MoXi-specific: Mexico property | — |
| Construction Status | Dropdown | enum | CONDITIONAL | Values: Existing, Under Construction, Proposed | — |
| TBD Property Fields | Read-Only | — | — | Empty/TBD acceptable (Red X OK) | — |

### Stage 60: "Tell the Story" (The 5 C's)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Character | Text Area | string | YES | Borrower's credit history narrative | — |
| Capacity | Text Area | string | YES | Income-to-debt ability | — |
| Capital | Text Area | string | YES | Cash reserves and assets | — |
| Collateral | Text Area | string | YES | Property value/condition | — |
| Conditions | Text Area | string | YES | Loan terms and market conditions | — |
| "Has mortgage advisor provided adequate info?" | Dropdown | boolean | YES | Yes/No | — |

### Stages 79-80: Alternate File Setup Flow

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Search Bar | Text Input | string | — | Search by borrower name | — |
| Borrower Summary | Read-Only Panel | — | — | Overview of borrower data | — |
| Email/Messages Tab | Tab Navigation | — | — | Check for credit approvals | — |
| Borrower Tab | Tab Navigation | — | — | Complete personal info | — |
| Personal Info Fields | Form Group | mixed | YES | Name, DOB, SSN, Address, Contact | — |
| Employment History | Form Group | mixed | YES | Employer, Start Date, Income | — |
| **[Notify via Email]** | Button | — | NO | Send welcome email | — |

---

## 2. Database Mapping

### Existing Schema Mappings

| UI Field | Supabase Table | Column | Type | Notes |
|---|---|---|---|---|
| Borrower Name | `customers` | `first_name`, `last_name` | text | — |
| Borrower Email | `customers` | `email` | text | — |
| Borrower Phone | `customers` | `phone` | text | — |
| Current Address | `residences` | `address` (JSONB) | JSONB | `is_current = true` |
| Address History | `residences` | multiple rows | — | Calculate total duration; must be >= 24 months |
| Present Housing: Mortgage | `real_estate_owned` | `mortgage_payment` | decimal | Primary residence |
| Present Housing: Taxes | `real_estate_owned` | `tax_amount` | decimal | — |
| Present Housing: Insurance | `real_estate_owned` | `insurance_amount` | decimal | — |
| Present Housing: HOA | `real_estate_owned` | `hoa_amount` | decimal | — |
| E-Folder Documents | `documents` | all fields | — | `WHERE application_id = ?` |
| Contract Price | `properties` | `purchase_price` | decimal | — |
| Construction Status | `properties` | — | — | 🔴 MISSING — see below |
| Borrower Info Complete? | — | — | — | 🔴 MISSING — processing checklist |
| Employment History | `employments` | all fields | — | Multiple rows per customer |
| Welcome Email | `communications` | all fields | — | `communication_type = 'email'` |

### 🔴 Schema Change Proposals (Missing Mappings)

| UI Field | Proposed Table | Proposed Column | Type | Rationale |
|---|---|---|---|---|
| Passport Number | `customers` | `passport_number` | text (encrypted) | URLA requires government ID for identity verification. Sensitive — consider vault. |
| Passport Issuing Authority | `customers` | `passport_issuing_authority` | text | — |
| Passport Issue Date | `customers` | `passport_issued_date` | date | — |
| Passport Expiration Date | `customers` | `passport_expiration_date` | date | Must be future date for valid ID |
| Passport Is Current | `customers` | `passport_is_current` | boolean | — |
| Driver's License Number | `customers` | `drivers_license_number` | text (encrypted) | Government ID verification |
| DL Issuing Authority | `customers` | `drivers_license_issuing_authority` | text | — |
| DL Issue Date | `customers` | `drivers_license_issued_date` | date | — |
| DL Expiration Date | `customers` | `drivers_license_expiration_date` | date | — |
| Construction Status | `properties` | `construction_status` | text (enum) | URLA-Lender Section L1 field. Values: `existing`, `under_construction`, `proposed`. |
| Contract Price (MXN) | `properties` | `purchase_price_foreign` | decimal(12,2) | MoXi-specific: dual-currency property pricing |
| Contract Currency | `properties` | `purchase_price_currency` | text | Default `USD`; MoXi may use `MXN` |
| "Tell the Story" (5 C's) | NEW: `processing_narratives` | — | — | Narrative assessment by processor (see below) |
| Borrower Info Complete? | NEW: `processing_checklists` | — | — | Processing workbook completion tracking (see below) |
| 24-Month Address History OK? | `processing_checklists` | `address_history_complete` | boolean | — |
| Advisor Info Adequate? | `processing_checklists` | `advisor_info_adequate` | boolean | — |

#### Proposed Column Additions to `customers` Table

```sql
ALTER TABLE customers
  ADD COLUMN passport_number text,
  ADD COLUMN passport_issuing_authority text,
  ADD COLUMN passport_issued_date date,
  ADD COLUMN passport_expiration_date date,
  ADD COLUMN passport_is_current boolean DEFAULT false,
  ADD COLUMN drivers_license_number text,
  ADD COLUMN drivers_license_issuing_authority text,
  ADD COLUMN drivers_license_issued_date date,
  ADD COLUMN drivers_license_expiration_date date;

COMMENT ON COLUMN customers.passport_number IS 'Government-issued passport number. Consider PCI vault for sensitive data.';
COMMENT ON COLUMN customers.passport_issuing_authority IS 'E.g., DEPARTMENT OF STATE';
COMMENT ON COLUMN customers.drivers_license_number IS 'State-issued DL number. Consider PCI vault.';
```

#### Proposed Column Additions to `properties` Table

```sql
ALTER TABLE properties
  ADD COLUMN construction_status text,
  ADD COLUMN purchase_price_foreign decimal(12,2),
  ADD COLUMN purchase_price_currency text DEFAULT 'USD';

COMMENT ON COLUMN properties.construction_status IS 'URLA L1: existing, under_construction, proposed';
COMMENT ON COLUMN properties.purchase_price_foreign IS 'MoXi: Purchase price in foreign currency (e.g., MXN)';
COMMENT ON COLUMN properties.purchase_price_currency IS 'Currency code for purchase price. Default USD.';
```

#### Proposed New Table: `processing_checklists`

```sql
CREATE TABLE processing_checklists (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id),
  application_id uuid NOT NULL REFERENCES applications(id) UNIQUE,
  processor_id uuid REFERENCES users(id),
  borrower_info_complete boolean DEFAULT false,
  address_history_complete boolean DEFAULT false,
  housing_expenses_verified boolean DEFAULT false,
  document_cross_reference_done boolean DEFAULT false,
  purchase_contract_reviewed boolean DEFAULT false,
  tell_the_story_complete boolean DEFAULT false,
  advisor_info_adequate boolean DEFAULT false,
  all_green_checks boolean DEFAULT false,
  completed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_processing_checklists_app ON processing_checklists(application_id);

COMMENT ON TABLE processing_checklists IS 'Tracks Processing Workbook completion status for each application';
```

#### Proposed New Table: `processing_narratives`

```sql
CREATE TABLE processing_narratives (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id),
  application_id uuid NOT NULL REFERENCES applications(id),
  author_id uuid NOT NULL REFERENCES users(id),
  narrative_type text NOT NULL,
  content text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT pn_type_check CHECK (narrative_type IN ('character', 'capacity', 'capital', 'collateral', 'conditions', 'general'))
);

CREATE INDEX idx_processing_narratives_app ON processing_narratives(application_id);

COMMENT ON TABLE processing_narratives IS '"Tell the Story" 5-C narratives: Character, Capacity, Capital, Collateral, Conditions';
```

---

## 3. Workflow & Triggers

### User Actions → System State Changes

| Step | Trigger | Actor | System Action | State Change | Notification |
|---|---|---|---|---|---|
| 54.1 | Open Processing Workbook | Processor | Load `processing_checklists` for application; create if not exists | — | — |
| 55.1 | Verify borrower info fields | Processor | Compare `customers` data against uploaded docs in `documents` | Set `borrower_info_complete = true` | — |
| 55.3-55.4 | Enter ID details (Passport/DL) | Processor | UPDATE `customers` with passport/DL fields | ID documented | — |
| 56.1 | Edit housing expenses | Processor | UPDATE `real_estate_owned` payment fields | Set `housing_expenses_verified = true` | — |
| 57.1 | Cross-reference docs | Processor | Compare `documents` (mortgage statement) against `real_estate_owned` | Set `document_cross_reference_done = true` | — |
| 58.1 | All sections green | System | Check all boolean fields in `processing_checklists` = true | Set `all_green_checks = true` | — |
| 59.1-59.2 | Review purchase contract | Processor | UPDATE `properties.purchase_price`, `construction_status` | Set `purchase_contract_reviewed = true` | — |
| 60.1 | Write 5-C narratives | Processor | INSERT into `processing_narratives` (5 rows) | Set `tell_the_story_complete = true` | — |
| 79-80 | Alternate file setup | Processor | Same as above; complete `customers`, `employments` | — | Welcome email sent via `communications` |

### Automation Rules

- **Checklist Auto-Update**: Trigger function on `processing_checklists` UPDATE to set `all_green_checks = true` when all individual checks are true.
- **Stage Advancement**: When `all_green_checks = true`, enable "Submit to UW" button in Encompass.
- **Address History Validation**: On `residences` INSERT/UPDATE, auto-check if total duration >= 24 months and update `address_history_complete`.

---

## 4. Compliance Notes

| Regulation | Requirement | Current Status |
|---|---|---|
| **URLA Section 1a** | 24-month address history required | ✅ OK — `residences` table supports multiple rows; `address_history_complete` checklist flag proposed |
| **URLA Section 1b** | Employer phone must be main business number, not personal | ✅ OK — `employments.employer_phone` exists |
| **URLA Section 1d** | Previous employment required if current < 2 years | ✅ OK — Multiple `employments` rows with `is_current` flag |
| **Selling Guide** | Cross-reference all data against source documents | 🟡 PARTIAL — `document_cross_reference_done` proposed for tracking but actual verification is manual |
| **ID Verification** | Government-issued ID must be verified and non-expired | 🔴 MISSING — `passport_*` and `drivers_license_*` columns proposed |

---

## 5. MoXi-Specific Customizations

| Feature | Description | Isolation Strategy |
|---|---|---|
| Dual-Currency Contract Price | Mexico property prices may be in MXN; processor converts to USD | `purchase_price_foreign` + `purchase_price_currency` columns; conversion logic in application layer |
| Spanish Purchase Contracts | SOPs mention using translation tools for Spanish contracts | Application-layer tooling; no schema impact |
| TBD Property (Red X OK) | Mexico property may not be identified at pre-qual; fields can remain TBD | `properties` fields are nullable; `construction_status` can be NULL for TBD |
| "Tell the Story" 5-C Narrative | May require Mexico-specific collateral assessment (Escritura-based value) | `processing_narratives` table is generic; `narrative_type = 'collateral'` can include Mexico-specific context |
