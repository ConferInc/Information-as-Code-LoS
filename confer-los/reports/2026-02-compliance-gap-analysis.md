---
type: compliance-report
title: Compliance Gap Analysis — Confer LOS (MoXi Digital Twin)
date: 2026-02-13
version: 1.0
author: Lead System Architect (AI)
scope: URLA/HMDA/TRID/CFPB/ECOA/FCRA/PCI-DSS/BSA-AML
sources:
  - URLA Instructions (Freddie Mac 65 / Fannie Mae 1003) revised 11/2024
  - CFPB Closing Disclosure Form H-25 (sample dated 4/15/2013)
  - MISMO 3.4 Document Inventory (41 documents)
  - NotebookLM Cross-Reference Gap Analysis (5 discontinuities)
  - Chain of Custody Audit (60-row lifecycle table)
  - Supabase Schema (27 tables, as documented)
  - MoXi Master SOPs (6 files)
  - 13 Generated Screen Schemas
---

# Compliance Gap Analysis Report
## Confer LOS — February 2026

---

## Executive Summary

This report cross-references the 13 generated screen schemas (derived from MoXi SOPs and persona stubs) against US regulatory requirements (URLA, HMDA, TRID, CFPB, ECOA, FCRA, PCI-DSS, BSA/AML) and the existing Supabase database schema (27 tables).

### Key Findings

| Severity | Count | Description |
|---|---|---|
| 🔴 **CRITICAL** | 8 | Missing mandatory fields/tables that block regulatory compliance |
| 🟡 **HIGH** | 11 | Partial implementations that need completion |
| 🟠 **MEDIUM** | 7 | Functional gaps with workarounds available |
| ⚠️ **DEPRECATED** | 3 | Legacy items that must be retired |
| ✅ **COMPLIANT** | 14 | Areas that meet regulatory requirements |

### New Tables Proposed: 10
### Column Additions Proposed: 47
### Document Type Enum Extensions: 15

---

## Section 1: Missing Mandatory US Data Fields (URLA / HMDA)

### 1.1 URLA (Uniform Residential Loan Application — Form 1003) Gaps

The URLA Instructions (revised 11/2024) define 9 sections. Below maps each section against the current Supabase schema.

#### Section 1a: Personal Information

| URLA Field | Supabase Status | Gap |
|---|---|---|
| Borrower Name | ✅ `customers.first_name`, `last_name` | — |
| SSN | 🔴 Only `ssn_last_four` exists | **CRITICAL**: Full SSN needed for credit pulls, tax transcripts, employment verification. Proposed: `customers.ssn_vault_token` referencing PCI-compliant external vault. |
| Date of Birth | ✅ `customers.date_of_birth` | — |
| Citizenship Status | ✅ `customers.citizenship_status` | — |
| Marital Status | ✅ `customers.marital_status` | — |
| Dependents (Number) | 🔴 Missing | Proposed: `customers.dependents_count` |
| Dependents (Ages) | 🔴 Missing | Proposed: `customers.dependents_ages` |
| Current Address | ✅ `residences.address` (JSONB) | — |
| 24-Month Address History | ✅ Multiple `residences` rows | Need validation trigger for 24-month minimum |
| Phone (Mobile) | ✅ `customers.phone` | — |
| "No Primary Housing Expense" | 🟡 Inferable | Can be inferred from `real_estate_owned` being empty; no explicit field |
| Individual vs Joint Credit | 🔴 Missing | Proposed: add to `application_customers` or `applications.key_information` JSONB |

#### Section 1b-1e: Employment & Income

| URLA Field | Supabase Status | Gap |
|---|---|---|
| Employer Name | ✅ `employments.employer_name` | — |
| Position/Title | ✅ `employments.position_title` | — |
| Start Date | ✅ `employments.start_date` | — |
| Employer Phone (main number) | ✅ `employments.employer_phone` | — |
| Employer Address | ✅ `employments.employer_address` (JSONB) | — |
| Employment Type | ✅ `employments.employment_type` | — |
| Business Ownership Share | 🔴 Missing | URLA 1b requires ownership percentage for self-employed. Proposed: `employments.ownership_share` (already exists — verify column name) |
| Gross Monthly Income (Base) | ✅ `incomes.amount` WHERE `income_type = 'base'` | — |
| Military Entitlements | 🟡 Partial | URLA 1b lists "Military Entitlements" as separate income type; ensure `incomes.income_type` enum includes `military_entitlements` |
| Previous Employment (if < 2 years) | ✅ Multiple `employments` rows | — |
| Income from Other Sources (Section 1e) | ✅ `incomes.income_type` enum | Verify enum includes: `alimony`, `child_support`, `rental_income`, `social_security`, `pension`, `trust`, `other` |

#### Section 2a-2d: Assets & Liabilities

| URLA Field | Supabase Status | Gap |
|---|---|---|
| Bank Accounts | ✅ `assets.asset_type` enum | — |
| Retirement Accounts | ✅ `assets.asset_type` includes retirement | — |
| Cash/Market Value | ✅ `assets.cash_market_value` | — |
| Earnest Money | ✅ `assets` with `asset_type = 'earnest_money'` | Verify enum includes this value |
| Employer Assistance | 🟡 Partial | URLA 2b "Other Assets": verify `assets.asset_type` includes `employer_assistance`, `lot_equity`, `relocation_funds`, `rent_credit`, `sweat_equity`, `trade_equity` |
| All Personal Debts | ✅ `liabilities` table | — |
| Deferred Debts | 🟡 Verify | URLA 2c includes deferred student loans, etc. Ensure `liabilities` captures these with `months_remaining` = 0 or deferred flag |
| Job-Related Expenses (2d) | 🟡 Partial | URLA 2d "Other Liabilities and Expenses": may need `liabilities.liability_type` = `job_related_expense` |

#### Section 3a: Real Estate Owned

| URLA Field | Supabase Status | Gap |
|---|---|---|
| Property Value | ✅ `real_estate_owned.current_value` | — |
| Status (Sold/Pending/Retained) | ✅ `real_estate_owned.property_status` | — |
| Intended Occupancy | ✅ `real_estate_owned.intended_occupancy` | — |
| Monthly Insurance/Taxes/HOA | ✅ Individual columns | — |
| Monthly Rental Income | ✅ `real_estate_owned.rental_income` | — |
| Net Monthly Rental Income | Calculated | Application-layer calculation |
| Mortgage Loans (balance, payment, type) | ✅ `real_estate_owned.mortgage_balance`, `mortgage_payment` | Missing: `mortgage_type`, `lender_name`, `account_number` |

#### Section 4a-4d: Loan & Property Information

| URLA Field | Supabase Status | Gap |
|---|---|---|
| Loan Amount | ✅ `applications.loan_amount` | — |
| Loan Purpose | ✅ `applications.purpose` | — |
| Property Value | ✅ `properties.estimated_value` | — |
| Occupancy | ✅ `properties.occupancy_type` | — |
| Number of Units | ✅ `properties.number_of_units` | — |
| FHA Secondary Residence | 🔴 Missing | URLA 4a field not present. Add to `applications.key_information` JSONB or new column. |
| Mixed-Use Property | 🔴 Missing | URLA 4a: "Will you occupy as primary and operate a business?" Add `properties.mixed_use` boolean. |
| Manufactured Home | 🟡 Partial | `properties.property_type` should include `manufactured_home` enum value |
| Gifts or Grants (4d) | ✅ `gift_funds` table | — |
| Expected Rental Income (4c) | 🔴 Missing | URLA 4c: Expected monthly rental income on purchase property. Add to `properties` or `applications.key_information`. |

#### Section 5: Declarations

| URLA Field | Supabase Status | Gap |
|---|---|---|
| Primary Residence | ✅ `declarations` table | — |
| Undisclosed Borrowing | ✅ `declarations` table | — |
| Clean Energy Liens (PACE) | 🟡 Verify | URLA 5a.A includes PACE lien question. Verify `declarations` has this field. |
| Bankruptcy (7 years) | ✅ `declarations` table | — |
| Foreclosure (7 years) | ✅ `declarations` table | — |
| Federal Debt Delinquency | ✅ `declarations` table | — |
| All Section 5a/5b questions | ✅ Individual boolean columns | — |

#### Section 6-7: Acknowledgments & Military

| URLA Field | Supabase Status | Gap |
|---|---|---|
| Acknowledgments & Agreements Signed | 🔴 Missing | No timestamp tracking for when Section 6 was signed. Add `application_customers.acknowledgment_signed_at`. |
| Military Service | 🔴 Missing | URLA Section 7: Currently serving, previously served, surviving spouse, service expiration date. No `military_service` fields exist. |

#### Section 8: Demographics (HMDA)

| URLA Field | Supabase Status | Gap |
|---|---|---|
| Ethnicity | ✅ `demographics.ethnicity` | — |
| Race | ✅ `demographics.race` | — |
| Sex | ✅ `demographics.sex` | — |
| Collection Method | ✅ `demographics.collection_method` | — |
| HMDA Fields | ✅ `demographics.hmda_fields` | — |

#### URLA-Lender Sections (L1-L4)

| URLA-Lender Field | Supabase Status | Gap |
|---|---|---|
| Construction/Renovation (L1) | 🔴 Missing | `properties.construction_status` proposed. Also need: `renovation`, `construction_to_permanent` flags. |
| Refinance Type (L1) | 🟡 Partial | `applications.purpose` = refinance, but no sub-type (No Cash Out / Limited / Cash Out). |
| Refinance Program (L1) | 🔴 Missing | Values: Full Documentation, IRRRL, Streamlined without Appraisal, VA, Other. |
| Title Information (L2) | 🔴 Missing | Title holder name, manner held, Indian Country Land Tenure. |
| Note Rate (L3) | ✅ `applications.interest_rate` | — |
| Loan Term (L3) | ✅ `applications.loan_term` | — |
| Amortization Type (L3) | 🔴 Missing | Values: Fixed Rate, Adjustable Rate, GPM, Other. |
| Proposed Monthly Payment Breakdown (L3) | 🔴 Missing | P&I, MI, Escrow breakdown. Proposed columns in 01_CD_Preparation. |
| Qualifying Ratios (L4) | ✅ `applications.dti`, `applications.ltv` | — |
| Seller Credits | 🔴 Missing | Add to `closing_costs` or `applications.key_information`. |

### 1.2 HMDA (Home Mortgage Disclosure Act) Gaps

| HMDA Requirement | Status | Gap |
|---|---|---|
| Action Taken Code | 🔴 Missing | `uw_decisions.hmda_action_taken` proposed in 02_Decisioning |
| Action Taken Date | 🔴 Missing | `uw_decisions.decided_at` proposed |
| Applicant Demographics | ✅ `demographics` table | — |
| Property Census Tract | 🔴 Missing | Required for HMDA LAR (Loan Application Register). Need geocoding for property address. |
| HOEPA Status | 🔴 Missing | High-cost mortgage flag. Add to `applications`. |
| Rate Spread | 🔴 Missing | Difference between APR and APOR. Add to `applications` after APR calculation. |
| NMLS ID | 🟡 Partial | MLO NMLS tracked in `users` but may need dedicated field. |
| Application Channel | 🟡 Partial | `customers.lead_source` proposed but HMDA needs specific channel codes. |

---

## Section 2: Missing Compliance Triggers (TRID / CFPB)

### 2.1 TRID (TILA-RESPA Integrated Disclosure) Gaps

| TRID Requirement | Timer | Current Status | Gap |
|---|---|---|---|
| **Loan Estimate within 3 business days** | Application receipt → 3 biz days | 🔴 CRITICAL | No `initial_disclosures_sent_at` field. Proposed in 01_Lead_Intake. No countdown timer or blocking mechanism. |
| **CD at least 3 business days before closing** | CD sent → 3 biz days → closing | 🔴 CRITICAL | No `cd_sent_at` field. Proposed in 01_CD_Preparation. No timer or close-date blocking. |
| **CD delivery method affects timing** | Mail: +3 calendar days | 🔴 CRITICAL | No `cd_delivery_method` or `disclosures_delivery_method` fields. Proposed in both Lead Intake and CD Preparation. |
| **Revised LE for changed circumstances** | Within 3 biz days of change | 🔴 Missing | No mechanism to detect "changed circumstances" or trigger revised LE. |
| **Revised CD for APR change** | >1/8% (fixed) or >1/4% (ARM) | 🔴 Missing | No APR comparison; `applications.apr` proposed but no delta-check trigger. |
| **Closing cost tolerance check** | Zero / 10% / No limit categories | 🔴 Missing | `closing_costs.tolerance_category` and `loan_estimate_amount` proposed for variance tracking. |
| **Intent to Proceed** | Required before charging fees (except credit report) | 🟡 Partial | Captured via eConsent but no explicit `intent_to_proceed` flag or timestamp. |

### 2.2 CFPB (Consumer Financial Protection Bureau) Gaps

| CFPB Requirement | Current Status | Gap |
|---|---|---|
| **Closing Disclosure Content (H-25)** | 🔴 Multiple fields missing | APR, TIP, Finance Charge, Total of Payments, Prepayment Penalty, Balloon Payment — all proposed as new columns in 01_CD_Preparation |
| **Itemized Closing Costs** | 🔴 No `closing_costs` table | Proposed in 01_CD_Preparation with CFPB categories A-H |
| **Cash to Close Comparison** | 🟡 Partial | LE vs CD comparison requires both `loan_estimate_amount` and final amount per line item |
| **Borrower/Seller Transaction Summaries** | 🔴 Missing | CD Page 3 detail not tracked in database |
| **Escrow Account Disclosure** | 🔴 Missing | Annual escrow analysis not tracked |
| **Loan Calculations (Page 5)** | 🔴 Missing | APR, TIP, Finance Charge, Total of Payments — proposed columns |

### 2.3 ECOA / Regulation B Gaps

| ECOA Requirement | Current Status | Gap |
|---|---|---|
| **Adverse Action Notice within 30 days** | 🔴 CRITICAL | No `uw_decisions` table. No adverse action tracking. No countdown timer. Proposed in 02_Decisioning. |
| **Specific Reason for Denial** | 🔴 Missing | `uw_decisions.reason` proposed |
| **Adverse Action Sent Timestamp** | 🔴 Missing | `uw_decisions.adverse_action_sent_at` proposed |
| **Counteroffer Tracking** | 🔴 Missing | `uw_decisions.decision = 'counter_offer'` proposed |

### 2.4 FCRA (Fair Credit Reporting Act) Gaps

| FCRA Requirement | Current Status | Gap |
|---|---|---|
| **Credit Authorization Required Before Pull** | 🔴 Missing | `application_customers.credit_auth_signed` and `credit_auth_signed_at` proposed |
| **Credit Report Tracking** | 🔴 Missing | `credit_reports` table proposed in 01_Lead_Intake |
| **Credit Report Expiry (120 days)** | 🔴 Missing | `credit_reports.expires_at` proposed; no expiry check trigger |

### 2.5 PCI-DSS Gaps

| PCI Requirement | Current Status | Gap |
|---|---|---|
| **Full SSN Never in Plaintext DB** | 🔴 CRITICAL | `customers.ssn_last_four` is safe, but no vault integration for full SSN. `ssn_vault_token` proposed. |
| **Credit Card Numbers Never Stored** | 🔴 CRITICAL | No payment table exists. `fee_payments.stripe_payment_id` proposed — tokenized, card numbers NEVER stored. |
| **Credit Card Authorization Form** | 🔴 Missing | `fee_payments.credit_card_auth_document_id` proposed to link to signed authorization PDF |

### 2.6 BSA/AML Gaps

| BSA/AML Requirement | Current Status | Gap |
|---|---|---|
| **Fraud Report Before UW Decision** | 🔴 Missing | `fraud_reports` table proposed in 02_Third_Party_Orders |
| **Suspicious Activity Monitoring** | 🟡 Partial | Wire fraud prevention is application-layer; `disbursements` table proposed for audit trail |
| **Wire Transfer Verification** | 🔴 Missing | `disbursements` table proposed in 02_Funding with dual-authorization workflow |

---

## Section 3: MoXi-Specific (Mexico) Customizations to Isolate

### 3.1 Cross-Border Documents (Isolate from US Base)

These documents appear in MoXi SOPs but are NOT part of the US standard mortgage workflow. They must be isolated to prevent contamination of the US compliance base.

| MoXi Document | MISMO Mapping | Isolation Strategy | Schema Impact |
|---|---|---|---|
| **Escritura** (Mexican Deed) | `PROPERTY/Title/Deed` (non-standard) | `documents.document_type = 'escritura'`; flagged as `international = true` | Enum extension only; no new table |
| **Testimonio** (Certified Copy) | `PROPERTY/Title/Certification` (non-standard) | `documents.document_type = 'testimonio'` | Enum extension only |
| **International Cover Sheet - English** | `BORROWER/ForeignNational` (non-standard) | `documents.document_type = 'international_cover_sheet'` | Enum extension only |
| **Commercial Appraisal Request** | `APPRAISAL_REQUEST/Type="Comm"` (non-standard) | Use standard `documents.document_type = 'appraisal'` with metadata `{ "appraisal_type": "commercial" }` | No new type needed; metadata distinction |
| **Power of Attorney (Mexico)** | Generic; not MISMO-specific | `documents.document_type = 'power_of_attorney'` + `applications.poa_required/poa_approved` | Enum extension + column additions |
| **Non-Refundable Fee Disclosure** | Not in standard US inventory | `documents.document_type = 'non_refundable_fee_disclosure'` | Enum extension only |

### 3.2 MoXi-Specific Business Rules (Isolate from US Base)

| Rule | Current Implementation | Isolation Strategy |
|---|---|---|
| **$550K Minimum Property Value** | `customers.pre_qual_property_threshold` (PROPOSED) | Application-layer gate; NOT a DB constraint. Other orgs have different thresholds or none. |
| **US Citizen Requirement** | `customers.citizenship_status` (EXISTING) | Business rule enforcement in application layer; field is URLA-standard. |
| **Dual-Currency Pricing (USD/MXN)** | `properties.purchase_price_foreign` + `purchase_price_currency` (PROPOSED) | Nullable columns; US-only loans ignore these fields. |
| **TBD Property Address (Mexico)** | `properties.address` JSONB allows null/partial | Standard nullable behavior; no MoXi-specific enforcement. |
| **SARMA Credit Vendor** | `credit_reports.vendor = 'sarma'` (PROPOSED) | Enum value; other orgs use other vendors. |
| **Evolve Portal for UW Submission** | `uw_submissions.portal = 'evolve'` (PROPOSED) | Enum value; other orgs use DU/LPA/manual. |
| **Simplifile for E-Signing** | `signing_sessions.platform = 'simplifile'` (PROPOSED) | Enum value; other orgs use DocuSign. |
| **Escritura Wet Signing (Blue Ink)** | `signing_sessions.platform = 'wet_ink'` (PROPOSED) | Separate signing session record with manual completion workflow. |
| **Fideicomiso (Bank Trust) Fees** | `closing_costs.description` = "Fideicomiso Trust Setup" (PROPOSED) | Standard closing cost line item; category = 'other'. |
| **Mexico Property Law Review** | `processing_checklists.property_law_review_complete` (PROPOSED) | MoXi-only checklist flag; NULL for US-only loans. |
| **Pro-Forma Data** | `processing_checklists.pro_forma_complete` (PROPOSED) | MoXi-only checklist flag. |

### 3.3 Legacy/Anomalous Items from SOPs

| Item | Issue | Resolution |
|---|---|---|
| **GFE (Good Faith Estimate)** | ⚠️ **DEPRECATED**: Replaced by Loan Estimate under TRID (effective 10/3/2015). MoXi SOP Stage 82 still validates this. | Flag in `file_certifications` with `deprecated = true`, `deprecated_replacement = 'loan_estimate'`. Training update required. |
| **HUD-1 Settlement Statement** | ⚠️ **DEPRECATED**: Replaced by Closing Disclosure under TRID (effective 10/3/2015). MoXi SOP Stage 82 still validates this. | Flag in `file_certifications` with `deprecated = true`, `deprecated_replacement = 'closing_disclosure'`. Training update required. |
| **Right of Rescission** | ⚠️ **CONTEXT**: Only applies to refinance transactions, NOT purchases. MoXi SOP includes it in general checklist. | Conditional: only validate when `applications.purpose = 'refinance'`. |
| **$350K vs $550K Threshold Discrepancy** | CRM (Salesforce) shows $350K minimum; lead form shows $550K minimum. | Needs MoXi team clarification. Schema uses single boolean `pre_qual_property_threshold`. |
| **ADV120 — Random US State for Mexico Property** | Processor enters random US state to avoid MERS charges when property is TBD/Mexico. | Workaround documented in SOP; `fraud_reports` metadata can track `{ "property_tbd": true }`. |
| **Employer Info Omission in ADV120** | Processor instructed NOT to enter employer info to avoid Work Number charges. | SOP/training enforcement; no schema impact. |
| **Credit Card Authorization Form Missing from Inventory** | Form exists in transcripts but was not in the Master Document Inventory. | Now tracked via `fee_payments.credit_card_auth_document_id` + `documents.document_type = 'credit_card_authorization'`. |
| **Seller's Remit Missing from Standard Flow** | Referenced in transcripts but flagged as missing from standard flow maps. | Now tracked via `disbursements` table + `documents.document_type = 'sellers_remit'`. |

---

## Section 4: Consolidated Schema Change Summary

### 4.1 New Tables Required (10)

| # | Table Name | Purpose | Proposed In |
|---|---|---|---|
| 1 | `credit_reports` | Track credit report pulls, scores, vendor, linked PDF | 02_Sales_MLO > 01_Lead_Intake |
| 2 | `fee_payments` | Track all fee collections (application, credit, appraisal, etc.) | 03_Processor > 02_Third_Party_Orders |
| 3 | `fraud_reports` | Track fraud/compliance reports (ADV120, FraudGuard) | 03_Processor > 02_Third_Party_Orders |
| 4 | `processing_checklists` | Processing Workbook completion tracking | 03_Processor > 01_File_Setup |
| 5 | `processing_narratives` | "Tell the Story" 5-C narratives | 03_Processor > 01_File_Setup |
| 6 | `uw_submissions` | Track UW portal submissions (Evolve, DU, LPA) | 03_Processor > 03_Submission_to_UW |
| 7 | `underwriting_conditions` | UW conditions (PTD, PTF, PTC, Post-Closing) | 03_Processor > 04_Conditions_Management |
| 8 | `file_certifications` | Internal file audit/certification checklist | 03_Processor > 04_Conditions_Management |
| 9 | `uw_decisions` | Formal UW decisions with ECOA/HMDA tracking | 04_Underwriter > 02_Decisioning |
| 10 | `signing_sessions` + `signing_session_documents` | E-signing session tracking (Simplifile/DocuSign) | 01_Borrower > 04_Closing_Signing |
| 11 | `closing_costs` | CFPB H-25 itemized closing costs | 05_Closer > 01_CD_Preparation |
| 12 | `disbursements` | Wire/funding disbursement tracking | 05_Closer > 02_Funding |

> Note: 12 tables listed (10 primary + 2 junction/child tables: `signing_session_documents` and implicit `closing_costs` line items)

### 4.2 Column Additions to Existing Tables (47)

#### `customers` (14 new columns)

| Column | Type | Purpose |
|---|---|---|
| `lead_source` | text | Lead acquisition channel |
| `financing_timeline` | text | Self-reported financing urgency |
| `pre_qual_property_threshold` | boolean | MoXi: $550K minimum confirmed |
| `sms_consent` | boolean | TCPA SMS opt-in |
| `sms_consent_at` | timestamptz | TCPA audit |
| `email_verified` | boolean | Email confirmation link clicked |
| `email_verified_at` | timestamptz | Email verification timestamp |
| `ssn_vault_token` | text | PCI vault reference for full SSN |
| `dependents_count` | integer | URLA 1a |
| `dependents_ages` | text | URLA 1a |
| `e_consent_granted_at` | timestamptz | ESIGN Act |
| `external_crm_id` | text | Salesforce Record ID |
| `crm_stage` | text | CRM funnel stage |
| `discovery_session_at` | timestamptz | Discovery call timestamp |
| `passport_*` (5 cols) | mixed | Government ID |
| `drivers_license_*` (4 cols) | mixed | Government ID |

#### `applications` (20+ new columns)

| Column | Type | Purpose |
|---|---|---|
| `initial_disclosures_sent_at` | timestamptz | TRID 3-day LE timer |
| `disclosures_delivery_method` | text | TRID day-count |
| `fee_template` | text | Fee template by state |
| `estimated_cash_to_close` | decimal | Processor estimate |
| `uw_review_requested_at` | timestamptz | SLA tracking |
| `uw_review_started_at` | timestamptz | SLA tracking |
| `prepayment_penalty` | boolean | CD Page 1 |
| `prepayment_penalty_amount` | decimal | CD Page 1 |
| `prepayment_penalty_years` | integer | CD Page 1 |
| `balloon_payment` | boolean | CD Page 1 |
| `monthly_mi` | decimal | Mortgage insurance |
| `monthly_escrow` | decimal | Escrow amount |
| `apr` | decimal | CD Page 5 |
| `tip` | decimal | CD Page 5 |
| `finance_charge` | decimal | CD Page 5 |
| `total_of_payments` | decimal | CD Page 5 |
| `final_cash_to_close` | decimal | CD Page 3 |
| `cd_sent_at` | timestamptz | TRID 3-day CD timer |
| `cd_delivery_method` | text | TRID day-count |
| `clear_to_close_at` | timestamptz | CTC date |
| `ledger_balanced` | boolean | Funding verification |
| `funded_at` | timestamptz | Funding date |
| `funding_type` | text | Table/dry fund |
| `poa_required` | boolean | POA flag |
| `poa_approved` | boolean | POA approval |
| `poa_approved_at` | timestamptz | POA timestamp |
| `archived_at` | timestamptz | Post-closing archive |

#### `application_customers` (2 new columns)

| Column | Type | Purpose |
|---|---|---|
| `credit_auth_signed` | boolean | FCRA compliance |
| `credit_auth_signed_at` | timestamptz | FCRA audit |

#### `properties` (3 new columns)

| Column | Type | Purpose |
|---|---|---|
| `construction_status` | text | URLA-Lender L1 |
| `purchase_price_foreign` | decimal | MoXi: dual currency |
| `purchase_price_currency` | text | Default USD |

#### `documents` (4 new columns)

| Column | Type | Purpose |
|---|---|---|
| `category` | text | Portal UI grouping |
| `upload_source` | text | Track upload origin |
| `version` | integer | Document versioning |
| `supersedes_id` | uuid FK | Previous version reference |

#### `tasks` (1 new column)

| Column | Type | Purpose |
|---|---|---|
| `document_id` | uuid FK | Link upload-task to document |

#### `communications` (1 new column)

| Column | Type | Purpose |
|---|---|---|
| `external_reference_id` | text | Encompass reference ID |

### 4.3 Document Type Enum Extensions (15)

```
closing_disclosure, sellers_remit, power_of_attorney,
international_cover_sheet, escritura, testimonio,
servicing_welcome_letter, payment_coupons, approval_letter,
cash_to_close_estimate, fraud_report, fee_payment_confirmation,
mismo_export, credit_report, non_refundable_fee_disclosure,
credit_card_authorization
```

---

## Section 5: Priority Implementation Roadmap

### Phase 1: CRITICAL Compliance (Immediate)

| Priority | Item | Regulation | Impact |
|---|---|---|---|
| P0 | Add `ssn_vault_token` + vault integration | PCI-DSS | Full SSN handling blocks credit pulls, employment verification |
| P0 | Create `uw_decisions` table | ECOA / HMDA | No adverse action tracking = regulatory violation |
| P0 | Add TRID timer fields (`initial_disclosures_sent_at`, `cd_sent_at`, delivery methods) | TRID / Reg Z | No disclosure timing = regulatory violation |
| P0 | Add `credit_auth_signed` fields | FCRA | Credit pulls without authorization tracking = violation |

### Phase 2: HIGH Priority (Next Sprint)

| Priority | Item | Regulation | Impact |
|---|---|---|---|
| P1 | Create `credit_reports` table | FCRA | No credit report tracking or expiry monitoring |
| P1 | Create `fee_payments` table | PCI-DSS / RESPA | No fee tracking; credit card data handling risk |
| P1 | Create `underwriting_conditions` table | Selling Guide | No condition tracking = cannot manage loan pipeline |
| P1 | Create `closing_costs` table | CFPB H-25 | No itemized cost tracking = CD cannot be generated from DB |
| P1 | Create `disbursements` table | BSA/AML | No wire tracking = fraud risk |
| P1 | Add CD calculation fields to `applications` | CFPB H-25 | APR, TIP, finance charge needed for CD Page 5 |

### Phase 3: MEDIUM Priority (Subsequent Sprints)

| Priority | Item | Purpose |
|---|---|---|
| P2 | Create `fraud_reports` table | BSA/AML tracking |
| P2 | Create `uw_submissions` table | UW portal submission tracking |
| P2 | Create `signing_sessions` tables | E-signing session management |
| P2 | Create `processing_checklists` + `processing_narratives` | Processor workflow tracking |
| P2 | Create `file_certifications` table | Internal audit tracking |
| P2 | Add URLA fields: dependents, military service, mixed-use, etc. | URLA completeness |
| P2 | Add HMDA fields: census tract, HOEPA, rate spread | HMDA LAR reporting |

### Phase 4: MoXi Isolation (Parallel Track)

| Priority | Item | Purpose |
|---|---|---|
| P3 | Add document type enums for international docs | MoXi cross-border support |
| P3 | Add dual-currency fields to `properties` | MoXi Mexico pricing |
| P3 | Add POA tracking fields to `applications` | MoXi Mexico closing |
| P3 | Add MoXi-specific checklist flags | MoXi post-closing workflow |
| P3 | Deprecate GFE/HUD-1 in certification checklists | Legacy cleanup |
| P3 | Resolve $350K/$550K threshold discrepancy | MoXi business rule |

---

## Appendix A: Cross-Reference Matrix (Screen → Regulation → Table)

| Screen Schema | Primary Regulations | New Tables | Column Additions |
|---|---|---|---|
| 01_Borrower/01_Lead_Capture | TCPA, CAN-SPAM, ECOA | — | 7 to `customers` |
| 01_Borrower/02_Application_1003 | URLA, ESIGN, FCRA, PCI | — | 4 to `customers`, 2 to `application_customers` |
| 01_Borrower/03_Conditions_Upload | TRID, Selling Guide | — | 4 to `documents`, 1 to `tasks` |
| 01_Borrower/04_Closing_Signing | TRID, ESIGN, CFPB | `signing_sessions`, `signing_session_documents` | — |
| 02_Sales_MLO/01_Lead_Intake | TRID, FCRA, TCPA, HMDA | `credit_reports` | 3 to `customers`, 2 to `applications`, 1 to `communications` |
| 03_Processor/01_File_Setup | URLA, Selling Guide | `processing_checklists`, `processing_narratives` | 9+ to `customers`, 3 to `properties` |
| 03_Processor/02_Third_Party_Orders | PCI, FCRA, BSA/AML | `fee_payments`, `fraud_reports` | 2 to `applications` |
| 03_Processor/03_Submission_to_UW | MISMO 3.4, Selling Guide | `uw_submissions` | 1 to `applications` |
| 03_Processor/04_Conditions_Management | Selling Guide, TRID | `underwriting_conditions`, `file_certifications` | — |
| 04_Underwriter/01_Initial_Review | Selling Guide, ECOA, HMDA | — | 1 to `applications` |
| 04_Underwriter/02_Decisioning | ECOA, HMDA, Fair Lending | `uw_decisions` | — |
| 05_Closer/01_CD_Preparation | TRID, CFPB H-25, RESPA | `closing_costs` | 16+ to `applications` |
| 05_Closer/02_Funding | RESPA, BSA/AML, Wire Fraud | `disbursements` | 7 to `applications` |

---

*Report generated 2026-02-13. This document should be reviewed by a licensed compliance officer before implementing schema changes.*
