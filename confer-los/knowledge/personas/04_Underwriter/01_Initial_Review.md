---
type: screen-schema
persona: Underwriter (UW)
screen: Initial Review
stage: Pre-Decision (File Review)
system: Encompass / Pentaview
generated: 2026-02-13
source_stubs:
  - modular/04_Underwriter/01_Initial_Review.md
source_sops:
  - Moxi_SOP_Jan_21_Part1.md (Sections 1-2)
  - Moxi_SOP_Jan_21_Part3.md (Section 6)
compliance_refs:
  - Selling Guide (Underwriting Standards)
  - ECOA / Reg B (Adverse Action)
  - HMDA (Data Collection)
---

# 01 — Initial Review

> **Note:** The source stub (`01_Initial_Review.md`) defers to `02_Decisioning.md` for the detailed click-path. This schema covers the **pre-decision file review** phase that precedes the formal decision rendering.

## 1. UI Component Map

### File Review: UW-1A Transmittal Summary

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| **[UW-1A]** (Transmittal Summary) | Form Link | — | — | Opens Fannie Mae Form 1008 view | — |
| Borrower Name | Read-Only | string | — | From application data | — |
| Loan Amount | Read-Only | decimal | — | From `applications.loan_amount` | — |
| Property Address | Read-Only | string/JSONB | — | From `properties.address` | — |
| Property Type | Read-Only | enum | — | From `properties.property_type` | — |
| Occupancy Type | Read-Only | enum | — | From `properties.occupancy_type` | — |
| LTV Ratio | Read-Only/Calculated | decimal | — | From `applications.ltv` | — |
| DTI Ratio | Read-Only/Calculated | decimal | — | From `applications.dti` | — |
| FICO Score | Read-Only | integer | — | From `application_customers.credit_score` | — |
| Loan Purpose | Read-Only | enum | — | Purchase, Refinance, Other | — |

### File Review: Fraud Report

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| **[Fraud File]** | Button | — | — | Opens ADV120 / Fraud Guard report | — |
| Non-Mortgage Disclosures | Read-Only Section | — | — | Fraud report findings | — |
| Pre-Funding Exclusions | Read-Only Section | — | — | Red flags / exclusions list | — |
| Risk Report Summary | Read-Only | text | — | Overall risk assessment | — |

### File Review: Credit Analysis

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Credit Report | Document Viewer | PDF | — | From `credit_reports.document_id` | — |
| Credit Report Date | Read-Only | date | — | `credit_reports.pulled_at` | — |
| Equifax Score | Read-Only | integer | — | `credit_reports.credit_score_equifax` | — |
| Experian Score | Read-Only | integer | — | `credit_reports.credit_score_experian` | — |
| TransUnion Score | Read-Only | integer | — | `credit_reports.credit_score_transunion` | — |
| Min/Mid Score | Read-Only | integer | — | Used for qualification | — |
| Trade Lines | List View | — | — | Credit accounts from report | — |
| Derogatory Items | Flagged List | — | — | Late payments, collections, etc. | — |

### File Review: Income & Employment Analysis

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Employment History | List View | — | — | All `employments` for borrower | — |
| Employment Duration | Calculated | text | — | Total months at current employer | — |
| Base Income | Read-Only | decimal | — | `incomes` WHERE `income_type = 'base'` | — |
| Total Qualifying Income | Calculated | decimal | — | Sum of all qualifying `incomes` | — |
| Income Stability Assessment | Manual | text | — | UW judgment on income reliability | — |

### File Review: Asset Verification

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Asset List | List View | — | — | All `assets` for application | — |
| Total Liquid Assets | Calculated | decimal | — | Sum of `assets.cash_market_value` | — |
| Reserve Months | Calculated | integer | — | Liquid assets / proposed monthly payment | — |
| Gift Funds | List View | — | — | `gift_funds` for application | — |
| Down Payment Source | Review | text | — | Verify source of down payment | — |

### File Review: Declarations

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| **[View Declarations]** | Button | — | — | Opens URLA Section 5 declarations | — |
| Outstanding Judgments | Read-Only | boolean | — | `declarations` field | — |
| Bankruptcy (7 years) | Read-Only | boolean | — | `declarations` field | — |
| Foreclosure (7 years) | Read-Only | boolean | — | `declarations` field | — |
| Lawsuit Party | Read-Only | boolean | — | `declarations` field | — |
| Federal Debt Delinquency | Read-Only | boolean | — | `declarations` field | — |
| Deed in Lieu | Read-Only | boolean | — | `declarations` field | — |
| Undisclosed Borrowing | Read-Only | boolean | — | Section 5a — clean energy liens (PACE) | — |

### File Review: Real Estate Owned

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| REO Schedule | List View | — | — | All `real_estate_owned` for borrower | — |
| Is Real Estate Owned? | Toggle | boolean | — | Yes/No | — |
| Association With Property? | Toggle | boolean | — | Co-borrower/co-owner flag | — |
| Are They A Co-Borrower? | Toggle | boolean | — | — | — |
| Property Value | Read-Only | decimal | — | `real_estate_owned.current_value` | — |
| Mortgage Balance | Read-Only | decimal | — | `real_estate_owned.mortgage_balance` | — |
| Net Rental Income | Calculated | decimal | — | `rental_income - mortgage - taxes - insurance - hoa` | — |

### File Review: Processing Workbook Narratives

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Character Narrative | Read-Only | text | — | From `processing_narratives` (🔴 PROPOSED) | — |
| Capacity Narrative | Read-Only | text | — | — | — |
| Capital Narrative | Read-Only | text | — | — | — |
| Collateral Narrative | Read-Only | text | — | — | — |
| Conditions Narrative | Read-Only | text | — | — | — |

---

## 2. Database Mapping

### Existing Schema Mappings

| UI Field | Supabase Table | Column | Type | Notes |
|---|---|---|---|---|
| Borrower Info | `customers` | all personal fields | — | Via `application_customers` join |
| Loan Amount | `applications` | `loan_amount` | decimal | — |
| LTV | `applications` | `ltv` | decimal | — |
| DTI | `applications` | `dti` | decimal | — |
| Purpose | `applications` | `purpose` | text | — |
| Property Info | `properties` | all fields | — | Via `applications.property_id` |
| FICO Score | `application_customers` | `credit_score` | integer | — |
| Employment | `employments` | all fields | — | Via `application_customer_id` |
| Income | `incomes` | all fields | — | Via `application_customer_id` |
| Assets | `assets` | all fields | — | Via `application_id` + `asset_ownership` |
| Gift Funds | `gift_funds` | all fields | — | Via `application_id` |
| Liabilities | `liabilities` | all fields | — | Via `application_id` + `liability_ownership` |
| REO | `real_estate_owned` | all fields | — | Via `application_customer_id` |
| Declarations | `declarations` | all boolean fields | — | Via `application_customer_id` |
| Demographics | `demographics` | all fields | — | HMDA reporting |
| Documents | `documents` | all fields | — | All docs in E-Folder |

### 🔴 Schema Change Proposals (Missing Mappings)

| UI Field | Proposed Table | Proposed Column | Type | Rationale |
|---|---|---|---|---|
| Credit Report Details | `credit_reports` | all fields | — | 🔴 PROPOSED in 02_Sales_MLO — bureau-level scores, vendor, document link |
| Fraud Report Details | `fraud_reports` | all fields | — | 🔴 PROPOSED in 02_Third_Party_Orders — risk level, findings |
| 5-C Narratives | `processing_narratives` | all fields | — | 🔴 PROPOSED in 01_File_Setup — character/capacity/capital/collateral/conditions |
| UW File Review Started | `applications` | `uw_review_started_at` | timestamptz | Track when UW began reviewing the file for SLA |
| UW Review Assigned To | `applications` | `assigned_underwriter_id` | uuid | ✅ Already exists |
| Reserve Months Calculation | — | — | — | Calculated in application layer: `total_liquid_assets / proposed_monthly_payment`; no new column needed |

#### Proposed Column Addition to `applications` Table

```sql
ALTER TABLE applications
  ADD COLUMN uw_review_started_at timestamptz;

COMMENT ON COLUMN applications.uw_review_started_at IS 'Timestamp when underwriter opened the file for initial review. SLA tracking.';
```

---

## 3. Workflow & Triggers

### User Actions → System State Changes

| Step | Trigger | Actor | System Action | State Change | Notification |
|---|---|---|---|---|---|
| — | UW opens loan file | Underwriter | SET `applications.uw_review_started_at` if null; INSERT `application_events` (type=`uw_review_started`) | Review clock started | — |
| UW.1 | Click **[UW-1A]** | Underwriter | Load transmittal summary from `applications`, `properties`, `customers` | — | — |
| UW.2 | Click **[Fraud File]** | Underwriter | Load `fraud_reports` WHERE `application_id = ?` | — | — |
| — | Review credit report | Underwriter | Load `credit_reports` + `documents` WHERE `document_type = 'credit_report'` | — | — |
| — | Review declarations | Underwriter | Load `declarations` WHERE `application_customer_id = ?` | — | Adverse declarations flagged |
| — | Review REO | Underwriter | Load `real_estate_owned` + calculate net rental income | — | — |
| — | Read 5-C narratives | Underwriter | Load `processing_narratives` WHERE `application_id = ?` | — | — |
| — | Complete initial review | Underwriter | INSERT `application_events` (type=`initial_review_complete`); proceed to decisioning | Ready for decision | — |

### Automation Rules

- **SLA Tracking**: On `uw_review_started_at` SET, start SLA timer. If no decision within 5 business days, escalate.
- **Auto-Flag Declarations**: If any `declarations` boolean = `true`, auto-create `underwriting_conditions` for further documentation.
- **DTI Auto-Calculate**: On file open, compute `dti = (total_monthly_debt + proposed_housing) / gross_monthly_income` and compare against product limits from `loan_products`.
- **Credit Expiry Check**: If `credit_reports.pulled_at` is older than 120 days, flag for refresh.

---

## 4. Compliance Notes

| Regulation | Requirement | Current Status |
|---|---|---|
| **Selling Guide** | UW must verify all 1003 data against source documents | ✅ OK — Documents available in `documents` table; cross-reference is manual |
| **ECOA / Reg B** | Decision must be rendered within 30 days of complete application | 🟡 PARTIAL — `uw_review_started_at` proposed for tracking but no countdown timer exists |
| **HMDA** | Demographic data must NOT influence lending decision | ✅ OK — `demographics` data exists but is separate from decisioning workflow |
| **BSA/AML** | Fraud report must be reviewed before decision | 🔴 DEPENDS on `fraud_reports` table (PROPOSED in 02_Third_Party_Orders) |
| **URLA Section 5** | All declarations must be reviewed; adverse declarations require explanation | ✅ OK — `declarations` table has all Section 5a/5b fields |

---

## 5. MoXi-Specific Customizations

| Feature | Description | Isolation Strategy |
|---|---|---|
| Pentaview System | MoXi UW uses Pentaview alongside Encompass for document viewing | External tool; no schema impact |
| TBD Mexico Property | Property may not have full US address; collateral assessment may reference Escritura | `properties.address` JSONB supports freeform; `processing_narratives` (collateral) can describe Mexico property |
| Commercial vs Residential Appraisal | MoXi may use commercial appraisals for Mexico properties — different from standard MISMO residential | Appraisal handling addressed in 02_Third_Party_Orders; UW reviews whatever appraisal document is in `documents` |
| Cross-Border Risk Assessment | Mexico property introduces country risk, currency risk, legal system risk | UW captures risk assessment in decision notes; `processing_narratives.narrative_type = 'conditions'` |
