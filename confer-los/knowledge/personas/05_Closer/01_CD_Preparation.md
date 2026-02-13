---
type: screen-schema
persona: Closer / Funder
screen: CD Preparation
stage: Closing Disclosure & Cash to Close
system: Encompass
generated: 2026-02-13
source_stubs:
  - modular/05_Closer/01_CD_Preparation.md
source_sops:
  - Moxi_SOP_Jan_21_Part2.md (Section 5)
  - Moxi_SOP_Jan_21_Part3.md (Sections 7-8)
compliance_refs:
  - TRID / Reg Z (Closing Disclosure 3-day rule)
  - CFPB Form H-25 (Closing Disclosure)
  - RESPA (Settlement costs)
---

# 01 — CD Preparation (Closing Disclosure)

## 1. UI Component Map

### Cash to Close Calculation

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Est Closing Dropdown | Dropdown | enum | YES | Select `Cash to Close` | — |
| **[Calculate Cash to Close]** | Button | — | YES | Generates final cash-to-close figure | — |
| Loan Amount | Read-Only | decimal(12,2) | — | From `applications.loan_amount` | — |
| Purchase Price | Read-Only | decimal(12,2) | — | From `properties.purchase_price` | — |
| Total Closing Costs | Calculated | decimal(12,2) | — | Sum of all loan costs + other costs | — |
| Prepaid Items | Calculated | decimal(12,2) | — | Insurance, taxes, prepaid interest | — |
| Credits | Calculated | decimal(12,2) | — | Seller credits, lender credits | — |
| Down Payment | Read-Only | decimal(12,2) | — | From `applications.down_payment_amount` | — |
| Deposit / Earnest Money | Read-Only | decimal(12,2) | — | From `assets` WHERE `asset_type = 'earnest_money'` | — |
| **Final Cash to Close** | Calculated (Bold) | decimal(12,2) | — | Net amount borrower must bring | — |

### Document Preparation (Post)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| **[Post]** | Button | — | YES | Opens Doc Prep Menu | — |
| Doc Prep Menu | List View | — | — | Available documents for closing package | — |
| Standard Forms List | Selectable List | — | — | International Cover Sheet - English, etc. | — |
| **[International Cover Sheet - English]** | List Item | — | YES | MoXi-specific cross-border doc | — |
| **[Add to Post]** | Button | — | YES | Adds selected doc to closing package | — |
| Closing Package | Document Set | — | — | Complete assembled package for signing | — |

### Post-Closing Verification (from SOPs)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Project Approved | Checkbox | boolean | YES | — | — |
| "How to Complete the Property Law Review?" | Dropdown | boolean | YES | Yes/No | — |
| "Confirm Full Payment Date?" | Dropdown | boolean | YES | Yes/No | — |
| "First Pro-Forma Data Complete?" | Dropdown | boolean | YES | Yes/No | — |
| Owned By | Dropdown | enum | YES | E.g., "Bar" (entity) | — |
| Property Used As | Dropdown | enum | YES | "Primary" | — |

### CD Content Fields (CFPB H-25 Compliance)

> These fields mirror the official CFPB Closing Disclosure form (H-25):

| Section | Field | Data Type | Source |
|---|---|---|---|
| **Page 1: Loan Terms** | Loan Amount | decimal | `applications.loan_amount` |
| | Interest Rate | decimal | `applications.interest_rate` |
| | Monthly P&I | decimal | Calculated |
| | Prepayment Penalty | boolean + amount | See below |
| | Balloon Payment | boolean | See below |
| | Estimated Total Monthly Payment | decimal | P&I + MI + Escrow |
| **Page 2: Closing Cost Details** | A. Origination Charges | decimal | Points, Application Fee, UW Fee |
| | B. Services Not Shopped For | decimal | Appraisal, Credit Report, Flood, Tax |
| | C. Services Shopped For | decimal | Title, Survey, Pest, Settlement |
| | D. Total Loan Costs | decimal | A + B + C |
| | E. Taxes/Govt Fees | decimal | Recording, Transfer Tax |
| | F. Prepaids | decimal | Insurance, Interest, Taxes |
| | G. Initial Escrow | decimal | Monthly reserves |
| | H. Other | decimal | HOA, Home Inspection, Commissions |
| **Page 3: Cash to Close** | Loan Estimate vs Final comparison | table | Side-by-side comparison |
| | Borrower Transaction Summary | table | Total due vs total paid |
| | Seller Transaction Summary | table | Due to seller vs due from seller |
| **Page 4: Disclosures** | Assumption | boolean | — |
| | Late Fee (% after N days) | decimal + integer | — |
| | Negative Amortization | boolean | — |
| | Escrow Account | boolean | — |
| **Page 5: Calculations** | Total of Payments | decimal | All payments over loan life |
| | Finance Charge | decimal | Total interest + fees |
| | Amount Financed | decimal | — |
| | APR | decimal | Annual Percentage Rate |
| | TIP (Total Interest %) | decimal | Total interest as % of loan |

---

## 2. Database Mapping

### Existing Schema Mappings

| UI Field | Supabase Table | Column | Type | Notes |
|---|---|---|---|---|
| Loan Amount | `applications` | `loan_amount` | decimal | — |
| Interest Rate | `applications` | `interest_rate` | decimal | — |
| Loan Term | `applications` | `loan_term` | integer | Months |
| LTV | `applications` | `ltv` | decimal | — |
| Down Payment | `applications` | `down_payment_amount` | decimal | — |
| Purchase Price | `properties` | `purchase_price` | decimal | — |
| Property Address | `properties` | `address` (JSONB) | JSONB | — |
| Earnest Money | `assets` | `cash_market_value` | decimal | WHERE `asset_type = 'earnest_money'` |
| CD Document | `documents` | all fields | — | `document_type = 'closing_disclosure'` |
| Closing Package Docs | `documents` | all fields | — | Multiple docs assembled |
| Signing Session | `signing_sessions` | all fields | — | 🔴 PROPOSED in 04_Closing_Signing |
| Application Status | `applications` | `status` | text | Updated to `clear_to_close` |

### 🔴 Schema Change Proposals (Missing Mappings)

| UI Field | Proposed Table | Proposed Column | Type | Rationale |
|---|---|---|---|---|
| Closing Cost Line Items | NEW: `closing_costs` | — | — | CFPB H-25 requires itemized closing costs. No table exists for individual line items. |
| Cost Category | `closing_costs` | `category` | text (enum) | A through H categories from CFPB form |
| Cost Description | `closing_costs` | `description` | text | E.g., "Appraisal Fee", "Recording Fees" |
| Cost Amount | `closing_costs` | `amount` | decimal(12,2) | — |
| Paid By | `closing_costs` | `paid_by` | text (enum) | Values: `borrower`, `seller`, `lender`, `other` |
| Prepayment Penalty | `applications` | `prepayment_penalty` | boolean | CD Page 1: whether prepayment penalty exists |
| Prepayment Penalty Amount | `applications` | `prepayment_penalty_amount` | decimal(12,2) | Maximum penalty amount |
| Prepayment Penalty Period | `applications` | `prepayment_penalty_years` | integer | Years penalty applies |
| Balloon Payment | `applications` | `balloon_payment` | boolean | CD Page 1: whether balloon payment exists |
| Monthly MI (Mortgage Insurance) | `applications` | `monthly_mi` | decimal(12,2) | Projected monthly mortgage insurance |
| Monthly Escrow | `applications` | `monthly_escrow` | decimal(12,2) | Taxes + Insurance escrow |
| APR | `applications` | `apr` | decimal(6,4) | Annual Percentage Rate for CD Page 5 |
| Total Interest Percentage (TIP) | `applications` | `tip` | decimal(6,2) | Total interest as % of loan amount |
| Finance Charge | `applications` | `finance_charge` | decimal(12,2) | Total cost of borrowing |
| Total of Payments | `applications` | `total_of_payments` | decimal(12,2) | All payments over loan life |
| Cash to Close (Final) | `applications` | `final_cash_to_close` | decimal(12,2) | Replaces estimated; final calculated amount |
| CD Sent At | `applications` | `cd_sent_at` | timestamptz | TRID: 3-business-day countdown before closing |
| CD Delivery Method | `applications` | `cd_delivery_method` | text | Values: `esign`, `mail`, `in_person`. Affects day count. |
| Clear to Close Date | `applications` | `clear_to_close_at` | timestamptz | When CTC was issued |
| Project Approved | `processing_checklists` | `project_approved` | boolean | Post-closing verification flag |
| Property Law Review Complete | `processing_checklists` | `property_law_review_complete` | boolean | MoXi: Mexico legal review |
| Full Payment Date Confirmed | `processing_checklists` | `full_payment_confirmed` | boolean | — |
| Pro-Forma Data Complete | `processing_checklists` | `pro_forma_complete` | boolean | — |
| International Cover Sheet | `documents` | `document_type` | text | Enum extension: `international_cover_sheet` |

#### Proposed New Table: `closing_costs`

```sql
CREATE TABLE closing_costs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id),
  application_id uuid NOT NULL REFERENCES applications(id),
  category text NOT NULL,
  subcategory text,
  description text NOT NULL,
  amount decimal(12,2) NOT NULL DEFAULT 0,
  paid_by text NOT NULL DEFAULT 'borrower',
  is_financed boolean DEFAULT false,
  tolerance_category text,
  loan_estimate_amount decimal(12,2),
  variance decimal(12,2),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT cc_category_check CHECK (category IN (
    'origination_charges',           -- A
    'services_not_shopped',          -- B
    'services_shopped',              -- C
    'taxes_govt_fees',               -- E
    'prepaids',                      -- F
    'initial_escrow',                -- G
    'other'                          -- H
  )),
  CONSTRAINT cc_paid_by_check CHECK (paid_by IN ('borrower', 'seller', 'lender', 'other')),
  CONSTRAINT cc_tolerance_check CHECK (tolerance_category IS NULL OR tolerance_category IN (
    'zero_tolerance', 'ten_percent', 'no_limit'
  ))
);

CREATE INDEX idx_closing_costs_application ON closing_costs(application_id);
CREATE INDEX idx_closing_costs_category ON closing_costs(category);

COMMENT ON TABLE closing_costs IS 'CFPB H-25 Closing Disclosure itemized costs (Sections A-H)';
```

#### Proposed Column Additions to `applications` Table

```sql
ALTER TABLE applications
  ADD COLUMN prepayment_penalty boolean DEFAULT false,
  ADD COLUMN prepayment_penalty_amount decimal(12,2),
  ADD COLUMN prepayment_penalty_years integer,
  ADD COLUMN balloon_payment boolean DEFAULT false,
  ADD COLUMN monthly_mi decimal(12,2) DEFAULT 0,
  ADD COLUMN monthly_escrow decimal(12,2) DEFAULT 0,
  ADD COLUMN apr decimal(6,4),
  ADD COLUMN tip decimal(6,2),
  ADD COLUMN finance_charge decimal(12,2),
  ADD COLUMN total_of_payments decimal(12,2),
  ADD COLUMN final_cash_to_close decimal(12,2),
  ADD COLUMN cd_sent_at timestamptz,
  ADD COLUMN cd_delivery_method text,
  ADD COLUMN clear_to_close_at timestamptz;

COMMENT ON COLUMN applications.prepayment_penalty IS 'CD Page 1: Whether loan has prepayment penalty';
COMMENT ON COLUMN applications.apr IS 'CD Page 5: Annual Percentage Rate';
COMMENT ON COLUMN applications.tip IS 'CD Page 5: Total Interest Percentage';
COMMENT ON COLUMN applications.finance_charge IS 'CD Page 5: Total finance charge over loan life';
COMMENT ON COLUMN applications.total_of_payments IS 'CD Page 5: Total of all payments over loan life';
COMMENT ON COLUMN applications.final_cash_to_close IS 'CD Page 3: Final calculated cash to close from borrower';
COMMENT ON COLUMN applications.cd_sent_at IS 'TRID: When Closing Disclosure was sent. 3-business-day waiting period starts.';
COMMENT ON COLUMN applications.cd_delivery_method IS 'TRID: esign, mail, in_person. Mail adds 3 calendar days.';
COMMENT ON COLUMN applications.clear_to_close_at IS 'When Clear to Close was formally issued';
```

#### Proposed Column Additions to `processing_checklists` (PROPOSED in 01_File_Setup)

```sql
ALTER TABLE processing_checklists
  ADD COLUMN project_approved boolean DEFAULT false,
  ADD COLUMN property_law_review_complete boolean DEFAULT false,
  ADD COLUMN full_payment_confirmed boolean DEFAULT false,
  ADD COLUMN pro_forma_complete boolean DEFAULT false;
```

---

## 3. Workflow & Triggers

### User Actions → System State Changes

| Step | Trigger | Actor | System Action | State Change | Notification |
|---|---|---|---|---|---|
| CL.1 | Select "Cash to Close" from dropdown | Closer | Load closing cost data from `closing_costs`, `fee_payments`, `applications` | Worksheet active | — |
| CL.2 | Click **[Calculate Cash to Close]** | Closer | Compute final cash to close; UPDATE `applications.final_cash_to_close` | Final figure set | — |
| CL.3 | Click **[Post]** | Closer | Generate CD PDF from loan data; INSERT `documents` (type=`closing_disclosure`) | CD document created | — |
| CL.4 | Select International Cover Sheet | Closer | Add to closing package | — | — |
| CL.5 | Click **[Add to Post]** | Closer | Assemble complete closing package; INSERT `documents` per document in package | Closing package ready | — |
| — | Send CD to borrower | Closer | SET `applications.cd_sent_at`; INSERT `communications` (email with CD); INSERT `application_events` (type=`cd_sent`) | **TRID 3-day clock starts** | Email: CD to borrower |
| — | 3-day waiting period expires | System | Auto-advance `applications.status` to `clear_to_close`; SET `clear_to_close_at` | CTC issued | Notifications: MLO, Processor, Borrower, Signing team |
| — | Post-closing verification | Closer | UPDATE `processing_checklists` flags (project_approved, property_law_review, payment_confirmed, pro_forma) | Post-closing audit complete | — |

### Automation Rules

- **TRID 3-Day Timer**: On `cd_sent_at` SET, calculate closing-eligible date:
  - eSign delivery: 3 business days from `cd_sent_at`
  - Mail delivery: 3 business days + 3 calendar days (mailbox rule)
  - In-person: Same day (if acknowledged)
- **Tolerance Check**: Compare each `closing_costs.amount` against `loan_estimate_amount`. Flag if variance exceeds tolerance category limits:
  - Zero tolerance: 0% variance allowed
  - 10% aggregate tolerance: total variance <= 10%
  - No limit: informational only
- **Cash to Close Auto-Calc**: `final_cash_to_close = purchase_price + total_closing_costs - loan_amount - deposit - seller_credits - lender_credits`
- **APR Calculation**: Compute APR from loan amount, interest rate, fees, and term using Regulation Z methodology.

---

## 4. Compliance Notes

| Regulation | Requirement | Current Status |
|---|---|---|
| **TRID / Reg Z** | CD must be provided at least 3 business days before closing | 🔴 CRITICAL — `cd_sent_at` and `cd_delivery_method` proposed. No timer exists. |
| **TRID / Reg Z** | Revised CD required if APR increases > 1/8% (fixed) or 1/4% (ARM) after initial CD | 🔴 MISSING — No APR comparison logic; `apr` column proposed |
| **TRID / Reg Z** | Closing costs must fall within tolerance categories vs Loan Estimate | 🔴 MISSING — `closing_costs.tolerance_category` and `loan_estimate_amount` proposed for variance tracking |
| **CFPB H-25** | CD must contain all Page 1-5 content (Loan Terms, Costs, Cash to Close, Disclosures, Calculations) | 🔴 MISSING — Multiple `applications` columns proposed (APR, TIP, finance_charge, total_of_payments, etc.) |
| **RESPA** | All settlement costs must be itemized and disclosed | 🔴 MISSING — `closing_costs` table proposed |
| **ECOA** | Adverse action notice if application denied at this stage | ⚠️ Handled in UW Decisioning stage |

---

## 5. MoXi-Specific Customizations

| Feature | Description | Isolation Strategy |
|---|---|---|
| International Cover Sheet - English | MoXi-specific closing document for cross-border Mexico transactions | `documents.document_type = 'international_cover_sheet'` enum extension; content is template-driven |
| Mexico Property Law Review | Post-closing verification includes Mexico-specific legal review | `processing_checklists.property_law_review_complete` boolean; MoXi-only field |
| Pro-Forma Data | MoXi uses pro-forma data for Mexico property transactions | `processing_checklists.pro_forma_complete` boolean; MoXi-only field |
| Dual-Currency Closing | Cash to Close may need to be presented in both USD and MXN | `applications.final_cash_to_close` in USD; MXN conversion is display-layer |
| Mexico Closing Costs Explanation | SOP references "Mexico Real Estate - Estimated Closing Costs Explanation" PDF | Stored in `documents`; educational content, not regulatory |
| Escritura Wet Signing | The actual Escritura must be signed in blue ink in Mexico — separate from e-signing | Handled in Borrower 04_Closing_Signing with `signing_sessions.platform = 'wet_ink'` |
