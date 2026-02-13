# Underwriter Portal Tables

**Category**: Underwriter Portal (Phase 7B)
**Tables**: `uw_decisions`, `risk_assessments`, `exception_requests`, `condition_templates`, `ctc_clearances`
**Last Updated**: 2026-02-13

---

## Table: `uw_decisions`

**Purpose**: Records underwriting decisions for loan applications (approve, approve with conditions, suspend, or deny). Supports counter-offers and captures rationale for each decision type.

### Key Columns
- `id` (uuid, PK)
- `organization_id` (uuid, FK → organizations)
- `application_id` (uuid, FK → applications)
- `decision_type` (enum: `approve`, `approve_with_conditions`, `suspend`, `deny`)
- `decision_date` (timestamp, default now)
- `decided_by` (uuid, FK → users)

### Rationale Fields
- `rationale_factors` (jsonb) - Array of checked decision factors
- `rationale_notes` (text) - Additional written rationale

### Approval-Specific
- `approval_conditions_summary` (text) - Summary of conditions for approval

### Suspension-Specific
- `suspension_reason` (enum: `document_deficiency`, `verification_issue`, `guideline_exception`, `fraud_concern`, `other`)
- `suspension_notes` (text)

### Denial-Specific
- `denial_reason_primary` (enum: `credit`, `capacity`, `collateral`, `character`, `compliance`)
- `denial_reason_detail` (text)
- `denial_adverse_action_required` (boolean, default true)

### Counter-Offer
- `counter_offer_loan_amount` (numeric)
- `counter_offer_terms` (text)
- `counter_offer_explanation` (text)

### Decision Metadata
- `decision_result` (jsonb) - Additional decision metadata
- `uw_signature` (text, required) - Digital signature of underwriter

### Timestamps
- `created_at`, `updated_at`

### Indexes
1. `uw_decisions_app_idx` on `application_id`
2. `uw_decisions_org_date_idx` on `organization_id`, `decision_date`
3. `uw_decisions_decided_by_idx` on `decided_by`, `decision_date`

### Business Logic
- Each decision must include rationale factors and UW signature
- Denial decisions may trigger adverse action notices
- Suspension decisions can be resumed when deficiencies are resolved
- Counter-offers present alternative loan terms to borrower

### Related Tables
- `applications` - The loan application being underwritten
- `users` - Underwriter who made the decision
- `conditions` - Conditions attached to approved loans
- `risk_assessments` - Risk analysis supporting the decision

---

## Table: `risk_assessments`

**Purpose**: Comprehensive risk analysis for loan applications including DTI, LTV, reserves, credit metrics, and compensating factors. Core data for underwriting decisions.

### Key Columns
- `id` (uuid, PK)
- `organization_id` (uuid, FK → organizations)
- `application_id` (uuid, FK → applications)
- `assessed_by` (uuid, FK → users)

### DTI (Debt-to-Income) Metrics
- `gross_monthly_income` (numeric 10,2)
- `proposed_total_piti` (numeric 10,2) - Principal, Interest, Taxes, Insurance
- `recurring_debts_monthly` (numeric 10,2)
- `front_end_dti` (numeric 5,2) - Housing expense ratio
- `back_end_dti` (numeric 5,2) - Total debt ratio
- `dti_guideline` (numeric 5,2, default 50.00)
- `dti_override` (numeric 5,2) - Manual override value
- `dti_override_reason` (text)

### LTV (Loan-to-Value) Metrics
- `loan_amount` (numeric 12,2)
- `purchase_price` (numeric 12,2)
- `appraised_value` (numeric 12,2)
- `value_used_for_ltv` (numeric 12,2) - Lesser of purchase price or appraised value
- `subordinate_financing` (numeric 12,2)
- `ltv` (numeric 5,2) - Loan-to-value ratio
- `cltv` (numeric 5,2) - Combined LTV (includes subordinate liens)
- `down_payment_amount` (numeric 12,2)
- `down_payment_percent` (numeric 5,2)
- `ltv_guideline` (numeric 5,2)
- `ltv_override` (numeric 5,2)
- `ltv_override_reason` (text)

### Reserves Metrics
- `total_verified_liquid_assets` (numeric 12,2)
- `retirement_assets` (numeric 12,2)
- `retirement_assets_discounted` (numeric 12,2) - Typically 60-70% of retirement assets
- `total_assets_for_reserves` (numeric 12,2)
- `funds_to_close` (numeric 12,2)
- `remaining_assets` (numeric 12,2)
- `reserves_months` (numeric 5,2) - Months of PITI in reserve
- `reserves_guideline` (numeric 5,2)
- `reserves_override` (numeric 5,2)
- `reserves_override_reason` (text)

### Credit Score Metrics
- `credit_score_used` (integer) - Representative/mid credit score
- `credit_score_guideline` (integer) - Minimum required
- `credit_pulled_at` (timestamp)
- `credit_expires_at` (timestamp) - Credit reports expire after 120 days
- `credit_score_override` (integer)
- `credit_score_override_reason` (text)

### Loan-to-Income
- `loan_to_income_ratio` (numeric 5,2) - Total loan / annual income

### Compensating Factors (Boolean Flags)
- `compensating_factor_reserves` - Significant reserves
- `compensating_factor_housing_increase` - Minimal increase in housing payment
- `compensating_factor_down_payment` - Large down payment (>20%)
- `compensating_factor_credit` - Excellent credit history
- `compensating_factor_employment` - Stable employment history
- `compensating_factor_earnings_potential` - Documented earnings growth potential
- `compensating_factor_tax_benefits` - Tax benefits of homeownership
- `compensating_factor_homeownership_education` - Completed homeownership counseling
- `compensating_factor_notes` (text)
- `compensating_factor_count` (integer, default 0)

### Credit Analysis Summary
- `total_tradelines` (integer)
- `open_tradelines` (integer)
- `total_inquiries_90d` (integer)
- `unmatched_inquiries` (integer)
- `total_derogatory_items` (integer)
- `payment_history_ontime_pct` (numeric 5,2)
- `late_30d_12mo` (integer) - 30-day lates in last 12 months
- `late_60d_24mo` (integer)
- `late_90plus_24mo` (integer)
- `collections_unpaid_count` (integer)
- `collections_unpaid_total` (numeric 10,2)
- `chargeoffs_count` (integer)
- `public_records_count` (integer)

### Metadata
- `assessment_data` (jsonb) - Additional assessment data

### Timestamps
- `created_at`, `updated_at`

### Indexes
1. `risk_assessments_app_idx` on `application_id`
2. `risk_assessments_org_idx` on `organization_id`, `created_at`

### Business Logic
- DTI above guideline may require compensating factors or exception request
- LTV determines down payment requirement and PMI eligibility
- Credit score expiration triggers new credit pull requirement
- Multiple compensating factors can offset guideline violations
- CLTV includes all liens (first mortgage + subordinate financing)

### Related Tables
- `applications` - The loan being assessed
- `users` - Underwriter who performed assessment
- `uw_decisions` - Decision based on this assessment
- `exception_requests` - Exceptions requested for guideline violations
- `assets`, `liabilities`, `incomes` - Source data for calculations

---

## Table: `exception_requests`

**Purpose**: Tracks requests for exceptions to standard underwriting guidelines (DTI, LTV, credit score, reserves). Includes approval workflow with justification and compensating factors.

### Key Columns
- `id` (uuid, PK)
- `organization_id` (uuid, FK → organizations)
- `application_id` (uuid, FK → applications)

### Exception Details
- `guideline_exceeded` (enum: `dti`, `ltv`, `credit_score`, `reserves`, `employment_gap`, `other`)
- `standard_limit` (numeric 10,2) - Guideline threshold
- `actual_value` (numeric 10,2) - Actual value exceeding guideline
- `variance_amount` (numeric 10,2) - Absolute difference
- `variance_percent` (numeric 5,2) - Percentage over guideline

### Justification
- `justification` (text, required) - Minimum 100 characters
- `compensating_factors` (jsonb) - Array of compensating factor identifiers

### Request Tracking
- `requested_by` (uuid, FK → users)
- `requested_at` (timestamp, default now)

### Approval Workflow
- `status` (enum: `pending`, `approved`, `denied`, default `pending`)
- `reviewed_by` (uuid, FK → users)
- `reviewed_at` (timestamp)
- `approval_notes` (text) - Notes from approver
- `denial_reason` (text) - Reason if denied

### Metadata
- `metadata` (jsonb) - Additional exception data

### Timestamps
- `created_at`, `updated_at`

### Indexes
1. `exception_requests_app_idx` on `application_id`
2. `exception_requests_status_idx` on `organization_id`, `status`
3. `exception_requests_requested_by_idx` on `requested_by`, `requested_at`

### Business Logic
- Requires detailed justification (min 100 characters)
- Variance amount and percent automatically calculated
- Pending exceptions block final approval
- Approved exceptions attached to loan file
- Denied exceptions require guideline compliance or loan denial

### Related Tables
- `applications` - Loan requiring exception
- `users` - Requester and reviewer
- `risk_assessments` - Risk data showing guideline violation
- `uw_decisions` - Final decision considering exception

---

## Table: `condition_templates`

**Purpose**: Reusable templates for underwriting conditions. Allows underwriters to quickly apply standard conditions (e.g., "Provide VOE dated within 10 days of closing") to applications.

### Key Columns
- `id` (uuid, PK)
- `organization_id` (uuid, FK → organizations)

### Template Content
- `title` (text, required) - Short condition name
- `description` (text, required) - Full condition text

### Classification
- `condition_type` (enum, required)
  - `prior_to_approval` - Must clear before approval
  - `prior_to_docs` - Must clear before document preparation
  - `prior_to_funding` - Must clear before funding
  - `prior_to_purchase` - Must clear before purchase (construction loans)
  - `informational` - Information only, no clearance required
- `category` (enum, required)
  - `income`, `assets`, `employment`, `credit`, `property`, `title`, `insurance`, `legal`, `compliance`, `other`
- `priority` (enum: `low`, `medium`, `high`, `critical`, default `medium`)

### Defaults
- `default_due_date_days` (integer) - Days from condition creation to due date

### Usage Tracking
- `is_active` (boolean, default true) - Can be deactivated without deletion
- `usage_count` (integer, default 0) - Incremented when template is used

### Audit
- `created_by` (uuid, FK → users)
- `created_at`, `updated_at`

### Business Logic
- Templates can be organization-specific or system-wide
- Usage count helps identify most common conditions
- Inactive templates hidden from condition picker
- Templates can be edited; changes don't affect existing conditions

### Related Tables
- `organizations` - Owner of template
- `users` - Creator of template
- `conditions` - Conditions created from this template

---

## Table: `ctc_clearances`

**Purpose**: Clear-to-Close checklist tracking. Boolean flags for all required items that must be verified before issuing Clear-to-Close (CTC) authorization to the closing team.

### Key Columns
- `id` (uuid, PK)
- `organization_id` (uuid, FK → organizations)
- `application_id` (uuid, FK → applications)

### Checklist Items (Boolean Flags)
- `ptd_conditions_cleared` - Prior-to-docs conditions cleared
- `ptf_conditions_cleared` - Prior-to-funding conditions cleared
- `credit_current` - Credit report is current (< 120 days)
- `voe_final_completed` - Final verification of employment completed
- `appraisal_current` - Appraisal is current and acceptable
- `title_received` - Title commitment received and reviewed
- `insurance_binder` - Homeowners insurance binder received
- `cd_prepared` - Closing Disclosure prepared and issued
- `no_adverse_changes` - No adverse changes in borrower profile
- `closing_scheduled` - Closing appointment scheduled
- `funds_verified` - Borrower funds to close verified

### Computed Status
- `all_items_checked` (boolean, default false) - Auto-computed; true when all checklist items = true

### CTC Issuance
- `ctc_issued_at` (timestamp) - When CTC was issued
- `ctc_issued_by` (uuid, FK → users) - Underwriter who issued CTC
- `ctc_final_notes` (text) - Final notes with CTC issuance

### Metadata
- `checklist_data` (jsonb) - Additional checklist metadata

### Timestamps
- `created_at`, `updated_at`

### Indexes
1. `ctc_clearances_app_idx` on `application_id`
2. `ctc_clearances_org_idx` on `organization_id`, `ctc_issued_at`

### Business Logic
- CTC cannot be issued until `all_items_checked` = true
- CTC issuance triggers notification to closing team
- If any item becomes unchecked after CTC, CTC must be rescinded
- Unique per application (one clearance record per loan)

### Related Tables
- `applications` - Loan being cleared
- `users` - Underwriter issuing CTC
- `conditions` - Conditions referenced in checklist
- `closing_schedules` - Closing appointment referenced
- `cd_revisions` - CD referenced in checklist
