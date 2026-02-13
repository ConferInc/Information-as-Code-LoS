---
type: screen-schema
persona: Client Concierge / Processor
screen: Third Party Orders
stage: 51-52, 69-74
system: Encompass / Point Services
generated: 2026-02-13
source_stubs:
  - modular/03_Processor/02_Third_Party_Orders.md
source_sops:
  - Moxi_SOP_Jan_21_Part1.md (Sections 3, 5)
  - Moxi_Master_SOP_Part2.md (Sections 5-7)
compliance_refs:
  - PCI-DSS (Credit Card Authorization)
  - FCRA (Credit Report Ordering)
  - BSA/AML (Fraud Guard Report)
---

# 02 — Third Party Orders

## 1. UI Component Map

### Stage 51: Fee Collection & Credit Reports

#### 51.1: Wire Transfer Check (Manual)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Bank Portal (External) | External Browser | — | — | Manual check for incoming wires | — |
| Wire Status | Manual Verification | boolean | — | Confirmed/Not Confirmed | — |

#### 51.2: Fee Collection Worksheet

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Fee Collection Worksheet | Form | — | — | Encompass internal form | — |
| Date Collected | Date Picker | date | YES | — | Today |
| Amount | Currency Input | decimal(12,2) | YES | > 0; e.g., `$199` | — |
| Payment Method | Dropdown | enum | YES | Wire, Credit Card, Check | — |
| Proof of Payment | File Upload | file (PDF) | YES | Attached payment confirmation | — |

#### 51.3: Ordering Credit Reports

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| **Prerequisite Check** | — | — | — | Credit Auth signed AND Fee paid | — |
| Services Menu | Menu | — | — | Select "Order Credit" | — |
| Credit Report Type | Dropdown | enum | YES | "Tri-Merge" | — |
| Provider | Read-Only | string | — | "SARMA" | SARMA |
| **[Submit]** (Credit Order) | Button | — | YES | Triggers credit pull | — |

#### 51.4: Credit Report Verification

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| E-Folder | File Browser | — | — | Check for credit report PDF | — |
| Credit Report PDF | Document Viewer | PDF | — | Verify report exists | — |
| Liability Mapping Check | Manual Verification | — | — | Map liabilities to Form 1003 if missing | — |

### Stage 52: Credit Milestone & Fee Templates

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Unassigned Documents | Drag Source | — | — | Documents not yet categorized | — |
| U9 Container | Drop Target | — | — | "U9" = Underwriting Index 9 | — |
| Drag Credit Report to U9 | Drag-and-Drop | — | YES | Assigns credit report to correct bucket | — |
| Pre-Underwrite Fee Date | Date Picker | date | YES | — | — |
| Pre-Underwrite Fee Amount | Currency Input | decimal(12,2) | YES | > 0 | — |
| Fee Payment Confirmation | File Upload | file (PDF) | YES | — | — |
| Subject Property Details | Section | — | — | — | — |
| Fee Template | Dropdown | enum | YES | Based on State/location | — |
| "Area Not Listed / Generic" | Dropdown Option | enum | — | Used for TBD property | — |

### Stage 69-70: ADV120 / Fraud Guard Report (Point Services)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Point Services Login | External Site | — | — | Third-party fraud service | — |
| ADV120 Report Selection | Navigation | — | — | — | — |
| Loan Number (Reference ID) | Text Input | string | YES | From Encompass | — |
| Subject Property Address | Text Input | string | YES | "To Be Determined" for Mexico | TBD |
| State | Dropdown | enum | YES | Select random US state if forced (avoids MERS charges) | — |
| Borrower Name | Text Input | string | YES | From 1003 URLA Part 1 | — |
| SSN | Masked Input | string | YES | From 1003 | — |
| DOB | Date Picker | date | YES | From 1003 | — |
| ⚠️ Employer Info | — | — | NO | **DO NOT ENTER** — avoids Work Number charges | — |
| **[Submit]** (ADV120) | Button | — | YES | Generates fraud report | — |
| Generated Report | PDF | file | — | Download after generation | — |

### Stage 73: Upload to Encompass E-Folder

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| **[Add Document]** | Button | — | — | Opens upload dialog | — |
| Document Name | Text Input | string | YES | Type `"U9"` | — |
| Attach File | File Picker | file (PDF) | YES | Select ADV120 PDF | — |

### Stage 74: Cash to Close Estimate

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Moxi Cash to Close Estimate | Form | — | — | Auto-populated | — |
| LTV | Read-Only | decimal | — | Auto-calculated | — |
| Loan Amount | Read-Only | decimal | — | — | — |
| Purchase Price | Read-Only | decimal | — | — | — |
| **[Generate Estimate]** | Button | — | YES | Creates PDF in Unassigned | — |

---

## 2. Database Mapping

### Existing Schema Mappings

| UI Field | Supabase Table | Column | Type | Notes |
|---|---|---|---|---|
| Credit Report PDF | `documents` | all fields | — | `document_type = 'credit_report'`; stored in E-Folder |
| ADV120 Fraud Report | `documents` | all fields | — | `document_type = 'fraud_report'` (enum extension needed) |
| Cash to Close Estimate PDF | `documents` | all fields | — | `document_type = 'cash_to_close_estimate'` (enum extension needed) |
| U9 Document Container | `documents` | `document_type` | text | U9 is an Encompass index; maps to `document_type` metadata |
| Fee Payment Confirmation | `documents` | all fields | — | `document_type = 'fee_payment_confirmation'` |
| Application LTV | `applications` | `ltv` | decimal | — |
| Application Loan Amount | `applications` | `loan_amount` | decimal | — |
| Property Purchase Price | `properties` | `purchase_price` | decimal | — |
| Credit Report Scores | `credit_reports` | `min_score`, `mid_score`, etc. | integer | 🔴 PROPOSED in 02_Sales_MLO |
| Credit Report PDF Link | `credit_reports` | `document_id` | uuid FK | 🔴 PROPOSED in 02_Sales_MLO |

### 🔴 Schema Change Proposals (Missing Mappings)

| UI Field | Proposed Table | Proposed Column | Type | Rationale |
|---|---|---|---|---|
| Fee Date Collected | NEW: `fee_payments` | `collected_at` | timestamptz | No fee/payment tracking table exists |
| Fee Amount | `fee_payments` | `amount` | decimal(12,2) | — |
| Fee Payment Method | `fee_payments` | `payment_method` | text (enum) | Values: `wire`, `credit_card`, `check`, `ach` |
| Fee Type | `fee_payments` | `fee_type` | text (enum) | Values: `application_fee`, `credit_report_fee`, `appraisal_fee`, `pre_underwrite_fee`, `processing_fee` |
| Payment Proof Document | `fee_payments` | `proof_document_id` | uuid FK | References `documents.id` |
| Credit Card Auth Form | `fee_payments` | `credit_card_auth_document_id` | uuid FK | PCI: Link to signed authorization form in `documents` |
| Fraud Report Vendor | NEW: `fraud_reports` | `vendor` | text | Point Services / ADV120 |
| Fraud Report Reference | `fraud_reports` | `reference_id` | text | Loan number used as reference |
| Fraud Report Status | `fraud_reports` | `status` | text (enum) | Values: `ordered`, `received`, `reviewed`, `flagged` |
| Fraud Report Document | `fraud_reports` | `document_id` | uuid FK | Link to PDF in `documents` |
| Fee Template / State | `applications` | `fee_template` | text | Fee template selection based on property state/location |
| Cash to Close Estimate Amount | `applications` | `estimated_cash_to_close` | decimal(12,2) | Final calculated amount |

#### Proposed New Table: `fee_payments`

```sql
CREATE TABLE fee_payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id),
  application_id uuid NOT NULL REFERENCES applications(id),
  fee_type text NOT NULL,
  amount decimal(12,2) NOT NULL,
  payment_method text NOT NULL,
  collected_at timestamptz NOT NULL DEFAULT now(),
  collected_by uuid REFERENCES users(id),
  proof_document_id uuid REFERENCES documents(id),
  credit_card_auth_document_id uuid REFERENCES documents(id),
  stripe_payment_id text,
  status text NOT NULL DEFAULT 'collected',
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT fp_fee_type_check CHECK (fee_type IN (
    'application_fee', 'credit_report_fee', 'appraisal_fee',
    'pre_underwrite_fee', 'processing_fee', 'technology_fee', 'other'
  )),
  CONSTRAINT fp_method_check CHECK (payment_method IN ('wire', 'credit_card', 'check', 'ach', 'stripe')),
  CONSTRAINT fp_status_check CHECK (status IN ('pending', 'collected', 'refunded', 'failed'))
);

CREATE INDEX idx_fee_payments_application ON fee_payments(application_id);
CREATE INDEX idx_fee_payments_type ON fee_payments(fee_type);

COMMENT ON TABLE fee_payments IS 'Tracks all fee collections: application fees, credit report fees, appraisal fees, etc.';
```

#### Proposed New Table: `fraud_reports`

```sql
CREATE TABLE fraud_reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id),
  application_id uuid NOT NULL REFERENCES applications(id),
  vendor text NOT NULL DEFAULT 'point_services',
  report_type text NOT NULL DEFAULT 'adv120',
  reference_id text,
  status text NOT NULL DEFAULT 'ordered',
  ordered_by uuid REFERENCES users(id),
  ordered_at timestamptz NOT NULL DEFAULT now(),
  received_at timestamptz,
  reviewed_at timestamptz,
  reviewed_by uuid REFERENCES users(id),
  document_id uuid REFERENCES documents(id),
  findings_summary text,
  risk_level text,
  created_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT fr_status_check CHECK (status IN ('ordered', 'received', 'reviewed', 'flagged', 'cleared')),
  CONSTRAINT fr_risk_check CHECK (risk_level IN ('low', 'medium', 'high', 'critical'))
);

CREATE INDEX idx_fraud_reports_application ON fraud_reports(application_id);

COMMENT ON TABLE fraud_reports IS 'Tracks fraud/compliance reports (ADV120, FraudGuard, etc.)';
```

#### Proposed Column Additions to `applications` Table

```sql
ALTER TABLE applications
  ADD COLUMN fee_template text,
  ADD COLUMN estimated_cash_to_close decimal(12,2);

COMMENT ON COLUMN applications.fee_template IS 'Fee template selection based on property state. E.g., Area Not Listed / Generic';
COMMENT ON COLUMN applications.estimated_cash_to_close IS 'Processor-calculated cash to close estimate';
```

---

## 3. Workflow & Triggers

### User Actions → System State Changes

| Step | Trigger | Actor | System Action | State Change | Notification |
|---|---|---|---|---|---|
| 51.1 | Check bank portal for wire | Processor | Manual; no system action | — | — |
| 51.2 | Enter fee in worksheet | Processor | INSERT `fee_payments` (type=`credit_report_fee`, amount=$199) | Fee recorded | — |
| 51.2 | Upload payment proof | Processor | INSERT `documents` (type=`fee_payment_confirmation`); link to `fee_payments.proof_document_id` | Proof attached | — |
| 51.3 | Click **[Submit]** (Order Credit) | Processor | INSERT `credit_reports` (vendor=sarma, type=tri_merge); call credit bureau API; INSERT `application_events` | `credit_reports.status` = `ordered` | Internal: credit pull initiated |
| 51.4 | Verify credit PDF in E-Folder | Processor | UPDATE `credit_reports.document_id`; map liabilities to `liabilities` table | Credit data available | — |
| 52.1 | Drag report to U9 | Processor | UPDATE `documents.document_type` = `credit_report` with U9 metadata | Document categorized | — |
| 52.4 | Select fee template | Processor | UPDATE `applications.fee_template` | Fee structure set | — |
| 69.1-69.4 | Fill ADV120 form | Processor | INSERT `fraud_reports` (vendor=point_services, reference_id=loan_number) | Report ordered | — |
| 70.1-70.2 | Download & upload report | Processor | UPDATE `fraud_reports.status` = `received`; INSERT `documents`; link `fraud_reports.document_id` | Report available for UW | — |
| 74.1-74.3 | Generate Cash to Close Estimate | Processor | Calculate estimate; UPDATE `applications.estimated_cash_to_close`; INSERT `documents` (type=`cash_to_close_estimate`) | Estimate generated | — |

### Automation Rules

- **Fee Gate**: Block credit ordering until `fee_payments` WHERE `fee_type = 'credit_report_fee' AND status = 'collected'` exists.
- **Credit Auth Gate**: Block credit ordering until `application_customers.credit_auth_signed = true`.
- **Auto-Liability Mapping**: On credit report receipt, auto-INSERT `liabilities` rows from credit report data (via vendor API parsing).
- **Cash to Close Calculation**: Auto-calculate from `applications.loan_amount`, `properties.purchase_price`, `fee_payments` totals, and estimated closing costs.

---

## 4. Compliance Notes

| Regulation | Requirement | Current Status |
|---|---|---|
| **PCI-DSS** | Credit card authorization form must be securely stored; card numbers never in plaintext | 🔴 MISSING — `fee_payments.credit_card_auth_document_id` proposed; form stored as PDF in `documents`. Stripe tokenization for online payments. |
| **FCRA** | Credit report can only be pulled with signed authorization AND permissible purpose | 🟡 PARTIAL — Authorization tracked via `credit_auth_signed`; fee gate proposed |
| **BSA/AML** | Fraud reports (ADV120) required before underwriting | 🔴 MISSING — `fraud_reports` table proposed; no automated tracking exists |
| **RESPA** | Fee disclosures must match actual fees charged | ✅ OK — Fee worksheet feeds into Loan Estimate calculations |
| **Selling Guide** | All documents must be properly indexed in loan file | ✅ OK — `documents` table tracks categorization |

---

## 5. MoXi-Specific Customizations

| Feature | Description | Isolation Strategy |
|---|---|---|
| "To Be Determined" Property Address | Mexico property address entered as "TBD" in ADV120; random US state selected to avoid MERS charges | `fraud_reports` metadata can store `{ "property_tbd": true, "substitute_state": "XX" }` in `findings_summary` or new JSONB field |
| Employer Info Omission (ADV120) | **DO NOT enter employer info** — avoids Work Number verification charges | Processor training/SOP; no schema enforcement needed |
| SARMA Credit Vendor | MoXi uses SARMA for tri-merge; other vendors available | `credit_reports.vendor` enum includes `sarma` |
| MoXi Cash to Close Estimate Form | Custom Encompass form for MoXi cross-border deals | Standard form; estimates stored in `applications.estimated_cash_to_close` |
| Wire Transfer (Manual Check) | Fee collection relies on manual bank portal check; no automated wire notification | Future: integrate banking API for automated wire detection |
| Payment Portal (Credit Card) | SOP shows separate payment portal: First=John, Last=Doe, Email=john.doe@example.com, Loan#=980420 | `fee_payments.stripe_payment_id` links to Stripe transaction; credit card details NEVER stored in Supabase |
| $199 Application Fee | MoXi-specific fee amount | `fee_payments.amount`; amount is business config, not schema |
