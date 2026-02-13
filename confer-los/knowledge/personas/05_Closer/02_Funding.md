---
type: screen-schema
persona: Closer / Funder
screen: Funding Execution
stage: Funding
system: Encompass / Banking Portal
generated: 2026-02-13
source_stubs:
  - modular/05_Closer/02_Funding.md
source_sops:
  - Moxi_SOP_Jan_21_Part3.md (Sections 1-3, 9)
compliance_refs:
  - RESPA (Settlement procedures)
  - Wire Fraud Prevention (CFPB advisory)
  - BSA/AML (Suspicious activity monitoring)
---

# 02 — Funding Execution

## 1. UI Component Map

### Loan Payment / Ledger View

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| **[Loan Payment]** Tab | Tab Navigation | — | — | Opens Ledger View | — |
| Ledger View | Table/Grid | — | — | Full payment itemization | — |
| Loan Amount | Read-Only | decimal(12,2) | — | From `applications.loan_amount` | — |
| Interest Rate | Read-Only | decimal(6,4) | — | From `applications.interest_rate` | — |
| Monthly P&I | Read-Only | decimal(12,2) | — | Calculated | — |
| Escrow (Taxes + Insurance) | Read-Only | decimal(12,2) | — | From `applications.monthly_escrow` | — |
| Total Monthly Payment | Read-Only | decimal(12,2) | — | P&I + MI + Escrow | — |

### Payment Itemization

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| **[Copy Payments to Itemization]** | Button | — | YES | Auto-fills itemization from payment data | — |
| Itemization Grid | Editable Table | — | — | Line items for all payment components | — |
| Ledger Balance | Calculated | decimal(12,2) | — | Must balance to $0.00 | — |

### Deposit Reconciliation (from SOPs)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Deposit Amount | Currency Input | decimal(12,2) | YES | E.g., `$199` | — |
| Deposit Date | Date Picker | date | YES | E.g., January 20th | — |
| File Identifier | Text Input | string | YES | Loan number (e.g., "9603") | — |

### Disbursement Instructions (Seller's Remit)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Legal Docs Section | Navigation | — | — | Access disbursement/funding docs | — |
| **[Send Reminder Email for Seller's Remit]** | Button | — | NO | Sends reminder to title/escrow | — |
| Seller's Remit Instructions | Document | PDF | YES | Wire/disbursement details | — |
| Send Remit to Email | Button + Confirm | — | YES | **[OK]** to confirm send | — |

### Legal / Pre-Filing (from SOPs)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Borrower Window | Panel | — | — | General, Documents, Services, Legal tabs | — |
| Legal Tab | Tab Navigation | — | — | — | — |
| Pre-Filing Sub-Tab | Tab Navigation | — | — | Legal pre-filing documents | — |
| Power of Attorney Section | Form Group | — | — | POA review and approval | — |

### Post-Closing Audit (from SOPs)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Post-Closing Audit Checklist | Checklist | — | — | Final verification items | — |
| Servicing Welcome Letter | Document | PDF | — | Generated for borrower | — |
| Payment Coupons | Document | PDF | — | Generated for borrower | — |
| Project Archival | Action | — | — | Archive completed loan file | — |

---

## 2. Database Mapping

### Existing Schema Mappings

| UI Field | Supabase Table | Column | Type | Notes |
|---|---|---|---|---|
| Loan Amount | `applications` | `loan_amount` | decimal | — |
| Interest Rate | `applications` | `interest_rate` | decimal | — |
| Loan Term | `applications` | `loan_term` | integer | — |
| Monthly Escrow | `applications` | `monthly_escrow` | decimal | 🔴 PROPOSED in 01_CD_Preparation |
| Monthly MI | `applications` | `monthly_mi` | decimal | 🔴 PROPOSED in 01_CD_Preparation |
| Application Status | `applications` | `status` | text | Updated to `funded` |
| Application Stage | `applications` | `stage` | text | Updated to `funded` |
| Seller's Remit Document | `documents` | all fields | — | `document_type = 'sellers_remit'` (enum extension) |
| POA Document | `documents` | all fields | — | `document_type = 'power_of_attorney'` (enum extension) |
| Servicing Welcome Letter | `documents` | all fields | — | `document_type = 'servicing_welcome_letter'` |
| Payment Coupons | `documents` | all fields | — | `document_type = 'payment_coupons'` |
| Disbursement Email | `communications` | all fields | — | `communication_type = 'email'` |
| Funding Event | `application_events` | `event_type` | text | `= 'funded'` |

### 🔴 Schema Change Proposals (Missing Mappings)

| UI Field | Proposed Table | Proposed Column | Type | Rationale |
|---|---|---|---|---|
| Wire Instructions | NEW: `disbursements` | `wire_instructions` (JSONB) | JSONB | `{ "bank_name": "...", "routing_number": "...", "account_number": "...", "swift_code": "...", "beneficiary": "..." }` |
| Disbursement Amount | `disbursements` | `amount` | decimal(12,2) | Total wire amount |
| Disbursement Type | `disbursements` | `disbursement_type` | text (enum) | Values: `seller_proceeds`, `payoff`, `escrow_funding`, `commission`, `other` |
| Disbursement Status | `disbursements` | `status` | text (enum) | Values: `pending`, `sent`, `confirmed`, `failed` |
| Wire Reference # | `disbursements` | `wire_reference` | text | Bank wire reference number for tracking |
| Disbursement Sent At | `disbursements` | `sent_at` | timestamptz | When wire was executed |
| Disbursement Confirmed At | `disbursements` | `confirmed_at` | timestamptz | When wire receipt confirmed |
| Ledger Balanced | `applications` | `ledger_balanced` | boolean | Whether the payment ledger balanced to $0 |
| Funded Date | `applications` | `funded_at` | timestamptz | Official funding date |
| Funding Type | `applications` | `funding_type` | text | Values: `table_fund`, `dry_fund`. State-dependent. |
| Deposit Amount | `fee_payments` | `amount` | decimal | 🔴 PROPOSED in 02_Third_Party_Orders; deposit reconciliation |
| POA Required | `applications` | `poa_required` | boolean | Whether borrower has POA for signing |
| POA Approved | `applications` | `poa_approved` | boolean | Whether POA was reviewed and approved |
| POA Approval Date | `applications` | `poa_approved_at` | timestamptz | — |
| Post-Closing Archive Date | `applications` | `archived_at` | timestamptz | When loan file was archived |

#### Proposed New Table: `disbursements`

```sql
CREATE TABLE disbursements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id),
  application_id uuid NOT NULL REFERENCES applications(id),
  disbursement_type text NOT NULL,
  amount decimal(12,2) NOT NULL,
  wire_instructions jsonb,
  wire_reference text,
  payee_name text,
  status text NOT NULL DEFAULT 'pending',
  prepared_by uuid REFERENCES users(id),
  approved_by uuid REFERENCES users(id),
  sent_at timestamptz,
  confirmed_at timestamptz,
  document_id uuid REFERENCES documents(id),
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT db_type_check CHECK (disbursement_type IN (
    'seller_proceeds', 'payoff', 'escrow_funding', 'commission',
    'title_fees', 'government_fees', 'other'
  )),
  CONSTRAINT db_status_check CHECK (status IN (
    'pending', 'approved', 'sent', 'confirmed', 'failed', 'cancelled'
  ))
);

CREATE INDEX idx_disbursements_application ON disbursements(application_id);
CREATE INDEX idx_disbursements_status ON disbursements(status);

COMMENT ON TABLE disbursements IS 'Wire/funding disbursements for loan closing. Tracks seller proceeds, payoffs, commissions, etc.';
```

#### Proposed Column Additions to `applications` Table

```sql
ALTER TABLE applications
  ADD COLUMN ledger_balanced boolean DEFAULT false,
  ADD COLUMN funded_at timestamptz,
  ADD COLUMN funding_type text,
  ADD COLUMN poa_required boolean DEFAULT false,
  ADD COLUMN poa_approved boolean DEFAULT false,
  ADD COLUMN poa_approved_at timestamptz,
  ADD COLUMN archived_at timestamptz;

COMMENT ON COLUMN applications.ledger_balanced IS 'Whether the payment ledger balanced to $0 during funding';
COMMENT ON COLUMN applications.funded_at IS 'Official funding date';
COMMENT ON COLUMN applications.funding_type IS 'table_fund or dry_fund (state-dependent)';
COMMENT ON COLUMN applications.poa_required IS 'Whether borrower is signing via Power of Attorney';
COMMENT ON COLUMN applications.poa_approved IS 'Whether POA was reviewed and approved by UW/Closer';
COMMENT ON COLUMN applications.poa_approved_at IS 'POA approval timestamp';
COMMENT ON COLUMN applications.archived_at IS 'Post-closing: when loan file was archived';
```

---

## 3. Workflow & Triggers

### User Actions → System State Changes

| Step | Trigger | Actor | System Action | State Change | Notification |
|---|---|---|---|---|---|
| FN.1 | Click **[Loan Payment]** tab | Closer | Load payment data from `applications`, `closing_costs` | Ledger view active | — |
| FN.2 | Click **[Copy Payments to Itemization]** | Closer | Auto-populate itemization grid from payment schedule | Itemization filled | — |
| — | Balance ledger | Closer | Verify itemization sums to $0; SET `applications.ledger_balanced = true` | Ledger balanced | — |
| — | Reconcile deposits | Closer | Verify `fee_payments` deposits match expected amounts | Deposits reconciled | — |
| — | Prepare disbursement instructions | Closer | INSERT `disbursements` per payee (seller, title, commissions); attach wire instructions | Disbursements prepared | — |
| — | Send Seller's Remit | Closer | INSERT `communications` (reminder email); link `documents` (type=`sellers_remit`) | Remit instructions sent | Title/escrow/seller notified |
| — | Review POA (if applicable) | Closer | Review POA document; SET `applications.poa_approved = true`, `poa_approved_at` | POA cleared | — |
| — | Execute wire | Closer/Funder | UPDATE `disbursements.status` = `sent`; SET `sent_at`; INSERT `application_events` (type=`wire_sent`) | Wire in transit | Internal: compliance notified |
| — | Confirm wire receipt | System/Manual | UPDATE `disbursements.status` = `confirmed`; SET `confirmed_at` | Wire confirmed | — |
| — | All wires confirmed | System | SET `applications.funded_at`; UPDATE `applications.status` = `funded`; UPDATE `applications.stage` = `funded` | **LOAN FUNDED** | All parties notified; servicing welcome letter triggered |
| — | Generate servicing docs | System | INSERT `documents` (servicing_welcome_letter, payment_coupons) | Post-closing docs generated | Email: servicing letter to borrower |
| — | Archive loan file | Closer | SET `applications.archived_at`; INSERT `application_events` (type=`archived`) | File archived | — |

### Automation Rules

- **Ledger Balance Check**: Before enabling wire execution, verify `ledger_balanced = true`. Block wires on unbalanced ledger.
- **Wire Fraud Prevention**: On `disbursements` INSERT, validate wire instructions against known patterns. Flag suspicious changes to wire instructions.
- **Dual Authorization**: Wires above $X threshold require `prepared_by` != `approved_by` (separation of duties).
- **Funding Confirmation**: When ALL `disbursements.status = 'confirmed'` for an application, auto-set `funded_at` and advance to `funded` stage.
- **Post-Closing Timer**: After `funded_at`, start 30-day timer for post-closing audit completion.
- **Servicing Transfer**: On `funded_at` SET, auto-generate servicing welcome letter and payment coupons.

---

## 4. Compliance Notes

| Regulation | Requirement | Current Status |
|---|---|---|
| **RESPA** | All settlement charges must be accurately itemized | 🔴 DEPENDS on `closing_costs` table (PROPOSED in 01_CD_Preparation) |
| **Wire Fraud Prevention** | Verify wire instructions through independent channel; never change instructions based on email alone | 🔴 MISSING — No wire verification workflow exists; `disbursements` table proposed but fraud checks are application-layer |
| **BSA/AML** | Suspicious wire activity must be reported (SAR filing) | 🟡 PARTIAL — `disbursements` table provides audit trail; SAR filing is external process |
| **TRID / Reg Z** | Funding cannot occur until 3-day CD waiting period expires | 🔴 DEPENDS on `cd_sent_at` (PROPOSED in 01_CD_Preparation); must block wires until timer expires |
| **State Law** | Table funding vs dry funding rules vary by state | 🟡 PARTIAL — `funding_type` proposed but state-based enforcement is application-layer |
| **Selling Guide** | Post-closing audit must verify all documents within 30 days | 🟡 PARTIAL — `archived_at` proposed; 30-day timer needs implementation |

---

## 5. MoXi-Specific Customizations

| Feature | Description | Isolation Strategy |
|---|---|---|
| Seller's Remit to Mexico | Disbursement to Mexican seller/notary may use international wire (SWIFT) | `disbursements.wire_instructions` JSONB includes `swift_code` field for international wires |
| Escritura Recording | Mexican deed recording is handled by Notario Publico, not US county recorder | Application-layer process; no Supabase schema needed |
| Testimonio Certification | Certified copy of Escritura stamped by Notario | `documents.document_type = 'testimonio'` enum extension |
| Power of Attorney (Mexico) | Borrower may sign via POA for Mexico closing when not present in Mexico | `applications.poa_required`, `poa_approved`, `poa_approved_at` columns handle this |
| Fideicomiso (Trust) | Mexico property held in bank trust for foreign buyers; trust setup fees are part of closing costs | `closing_costs` table can track fideicomiso fees under `category = 'other'` |
| $199 Deposit Reconciliation | MoXi collects $199 upfront application fee that must be reconciled at funding | `fee_payments` table tracks the deposit; reconciliation is manual in ledger |
| Disbursement to Escrow Company | SOP discusses disbursement instructions to Mexican escrow company | `disbursements.payee_name` and `disbursement_type = 'escrow_funding'` handle this |
| Post-Closing: Servicing Welcome Letter | Standard US requirement; MoXi may customize for cross-border servicing | Document template customization; `documents.document_type = 'servicing_welcome_letter'` |

---

## 6. Document Type Enum Extensions Required

The following `documents.document_type` values are referenced across the Closer persona and need to be added to the enum:

```sql
-- Add to documents.document_type enum/check constraint:
-- 'closing_disclosure'     (CD - CFPB H-25)
-- 'sellers_remit'          (Wire/disbursement instructions)
-- 'power_of_attorney'      (POA for signing)
-- 'international_cover_sheet' (MoXi cross-border)
-- 'escritura'              (Mexican deed)
-- 'testimonio'             (Certified copy of Escritura)
-- 'servicing_welcome_letter'
-- 'payment_coupons'
-- 'approval_letter'
-- 'cash_to_close_estimate'
-- 'fraud_report'
-- 'fee_payment_confirmation'
-- 'mismo_export'
-- 'credit_report'
-- 'non_refundable_fee_disclosure'
```
