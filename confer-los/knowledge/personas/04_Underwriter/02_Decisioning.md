---
type: screen-schema
persona: Underwriter (UW)
screen: Initial Review & Decisioning
stage: Decision Rendering
system: Encompass / Pentaview
generated: 2026-02-13
source_stubs:
  - modular/04_Underwriter/02_Decisioning.md
source_sops:
  - Moxi_SOP_Jan_21_Part3.md (Section 6)
compliance_refs:
  - ECOA / Reg B (Adverse Action Notice, 30-day requirement)
  - Selling Guide (Underwriting Decision Standards)
  - HMDA (Action Taken reporting)
---

# 02 — Decisioning

## 1. UI Component Map

### Decision Form (UW-1A)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| **[UW-1A]** (Transmittal Summary) | Form Link | — | YES | Loads Fannie Mae 1008 decision form | — |
| Decision Form Header | Read-Only | — | — | Borrower, Property, Loan details summarized | — |

### Risk Assessment

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| **[Fraud File]** | Button | — | YES | Opens ADV120 fraud report | — |
| Risk Report | Document Viewer | PDF | — | Fraud findings from `fraud_reports` | — |
| Risk Level Assessment | Read-Only / Manual | enum | — | Low, Medium, High, Critical | — |

### Condition Review & Approval

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Approvals Column | Checklist | — | — | List of reviewable items | — |
| **[Reviewable]** Toggle (per item) | Checkbox | boolean | YES | Toggle in Approvals column | — |
| Item Cleared Status | Badge | enum | — | Cleared / Not Cleared | — |

### Final Decision

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| **[Approve]** | Button | — | CONDITIONAL | One of Approve/Suspend/Deny required | — |
| **[Suspend]** | Button | — | CONDITIONAL | Requires conditions to be specified | — |
| **[Deny]** | Button | — | CONDITIONAL | Requires denial reason | — |
| Decision Reason | Text Area | string | CONDITIONAL | Required for Suspend/Deny | — |
| Conditions List (on Suspend) | Dynamic List | — | CONDITIONAL | Conditions that must be met for approval | — |

### Post-Decision: Approval Letter

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| **[Generate Approval Letter]** | Button | — | CONDITIONAL | Only available after Approve decision | — |
| Approval Letter PDF | Document | PDF | — | Auto-generated from loan data | — |

### Post-Decision: Conditional Approval Details

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Conditions List Email | Communication | text | — | List of conditions sent to Processor/MLO | — |
| Counter Offer Details | Form | — | CONDITIONAL | If terms modified (rate, amount, etc.) | — |

---

## 2. Database Mapping

### Existing Schema Mappings

| UI Field | Supabase Table | Column | Type | Notes |
|---|---|---|---|---|
| Application Status Update | `applications` | `status` | text (enum) | Changes to `approved`, `suspended`, `denied`, `conditionally_approved` |
| Decision Event | `application_events` | `event_type` | text | `= 'uw_decision'`; metadata stores decision details |
| — | `application_events` | `metadata` (JSONB) | JSONB | `{ "decision": "approve", "underwriter_id": "...", "conditions_count": 0 }` |
| — | `application_events` | `created_by` | uuid | The underwriter who rendered the decision |
| Approval Letter PDF | `documents` | all fields | — | `document_type = 'approval_letter'` |
| Conditions (on Suspend) | `underwriting_conditions` | all fields | — | 🔴 PROPOSED in 04_Conditions_Management; auto-created on suspend |
| Conditions Email | `communications` | all fields | — | `communication_type = 'email'`; conditions list in body |
| Counter Offer | `application_events` | `event_type` | text | `= 'counter_offer'`; metadata has modified terms |
| Denial Reason | `application_events` | `metadata` (JSONB) | JSONB | `{ "decision": "deny", "reason": "...", "adverse_action_required": true }` |

### 🔴 Schema Change Proposals (Missing Mappings)

| UI Field | Proposed Table | Proposed Column | Type | Rationale |
|---|---|---|---|---|
| Decision Type | NEW: `uw_decisions` | `decision` | text (enum) | Dedicated decision record for audit trail. Values: `approved`, `conditionally_approved`, `suspended`, `denied`, `counter_offer`. |
| Decision Timestamp | `uw_decisions` | `decided_at` | timestamptz | When decision was rendered |
| Underwriter | `uw_decisions` | `underwriter_id` | uuid FK | Who made the decision |
| Decision Reason | `uw_decisions` | `reason` | text | Required for Suspend/Deny |
| Decision Notes | `uw_decisions` | `notes` | text | UW internal notes |
| Adverse Action Required | `uw_decisions` | `adverse_action_required` | boolean | ECOA: must send adverse action notice within 30 days |
| Adverse Action Sent At | `uw_decisions` | `adverse_action_sent_at` | timestamptz | ECOA compliance tracking |
| HMDA Action Taken | `uw_decisions` | `hmda_action_taken` | text (enum) | HMDA reporting code. Values: `originated`, `approved_not_accepted`, `denied`, `withdrawn`, `incomplete`, `purchased`. |
| Approval Letter Document | `uw_decisions` | `approval_letter_document_id` | uuid FK | Link to generated approval letter in `documents` |
| Conditions Created | `uw_decisions` | `conditions_count` | integer | Number of conditions created with this decision |
| Counter Offer — Modified Loan Amount | `uw_decisions` | `modified_loan_amount` | decimal | If counter offer changes loan amount |
| Counter Offer — Modified Rate | `uw_decisions` | `modified_interest_rate` | decimal | If counter offer changes rate |
| Reviewable Items | `file_certifications` | `verified` | boolean | 🔴 PROPOSED in 04_Conditions_Management; UW toggles "Reviewable" per item |

#### Proposed New Table: `uw_decisions`

```sql
CREATE TABLE uw_decisions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id),
  application_id uuid NOT NULL REFERENCES applications(id),
  underwriter_id uuid NOT NULL REFERENCES users(id),
  decision text NOT NULL,
  reason text,
  notes text,
  conditions_count integer DEFAULT 0,
  adverse_action_required boolean DEFAULT false,
  adverse_action_sent_at timestamptz,
  hmda_action_taken text,
  approval_letter_document_id uuid REFERENCES documents(id),
  modified_loan_amount decimal(12,2),
  modified_interest_rate decimal(6,4),
  modified_loan_term integer,
  decided_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT ud_decision_check CHECK (decision IN (
    'approved', 'conditionally_approved', 'suspended', 'denied', 'counter_offer'
  )),
  CONSTRAINT ud_hmda_check CHECK (hmda_action_taken IS NULL OR hmda_action_taken IN (
    'originated', 'approved_not_accepted', 'denied', 'withdrawn', 'incomplete', 'purchased'
  ))
);

CREATE INDEX idx_uw_decisions_application ON uw_decisions(application_id);
CREATE INDEX idx_uw_decisions_decision ON uw_decisions(decision);
CREATE INDEX idx_uw_decisions_hmda ON uw_decisions(hmda_action_taken);

COMMENT ON TABLE uw_decisions IS 'Formal underwriting decisions with ECOA/HMDA compliance tracking';
```

---

## 3. Workflow & Triggers

### User Actions → System State Changes

| Step | Trigger | Actor | System Action | State Change | Notification |
|---|---|---|---|---|---|
| UW.1 | Open UW-1A | Underwriter | Load `applications` + `properties` + `customers` data | — | — |
| UW.2 | Click **[Fraud File]** | Underwriter | Load `fraud_reports` for application | — | — |
| UW.3 | Toggle **[Reviewable]** items | Underwriter | UPDATE `file_certifications.verified` per item | Items cleared | — |
| UW.4a | Click **[Approve]** | Underwriter | INSERT `uw_decisions` (decision=`approved`); UPDATE `applications.status` = `approved`; INSERT `application_events` | `applications.stage` → `closing` | Email: Approval to MLO, Processor, Borrower |
| UW.4b | Click **[Suspend]** | Underwriter | INSERT `uw_decisions` (decision=`suspended`, reason); auto-INSERT `underwriting_conditions` per condition; UPDATE `applications.status` = `suspended` | Application suspended | Email: Conditions list to Processor; Processor creates tasks |
| UW.4c | Click **[Deny]** (if applicable) | Underwriter | INSERT `uw_decisions` (decision=`denied`, reason, adverse_action_required=true); UPDATE `applications.status` = `denied`; INSERT `application_events` | Application denied | Adverse Action Notice triggered (30-day ECOA) |
| UW.5 | Click **[Generate Approval Letter]** | Underwriter | Generate PDF; INSERT `documents` (type=`approval_letter`); UPDATE `uw_decisions.approval_letter_document_id` | Letter available | Letter emailed to borrower/MLO |
| — | Counter Offer | Underwriter | INSERT `uw_decisions` (decision=`counter_offer`, modified_loan_amount, modified_interest_rate); INSERT `application_events` | Terms modified | MLO notified; revised disclosures may be required |

### Automation Rules

- **Adverse Action Timer**: On `uw_decisions.decision = 'denied'`, start 30-day ECOA countdown. If `adverse_action_sent_at` is NULL after 25 days, escalate.
- **HMDA Auto-Populate**: On decision, auto-set `hmda_action_taken` based on decision type and subsequent events.
- **Condition Auto-Creation**: On `suspended` decision, parse conditions from UW notes and auto-INSERT into `underwriting_conditions` table.
- **Stage Advancement**: On `approved` decision, auto-advance `applications.stage` from `underwriting` to `closing`.
- **Counter Offer → Revised LE**: On `counter_offer` decision where `modified_loan_amount` or `modified_interest_rate` differs from original, flag for revised Loan Estimate (TRID).
- **Clear to Close**: On `approved` AND all `underwriting_conditions.status IN ('cleared', 'waived')`, fire `clear_to_close` event.

---

## 4. Compliance Notes

| Regulation | Requirement | Current Status |
|---|---|---|
| **ECOA / Reg B** | Adverse action notice within 30 days of complete application for denials | 🔴 CRITICAL — `uw_decisions` table with `adverse_action_required` and `adverse_action_sent_at` proposed. No existing tracking. |
| **ECOA / Reg B** | Must state specific reason(s) for denial | 🔴 MISSING — `uw_decisions.reason` proposed |
| **HMDA** | Action Taken must be reported for every application | 🔴 MISSING — `uw_decisions.hmda_action_taken` proposed |
| **TRID / Reg Z** | Counter offers with changed terms may require revised Loan Estimate | 🟡 PARTIAL — Counter offer tracking proposed; revised LE automation not built |
| **Fair Lending** | Decision must be based on creditworthiness, not prohibited factors | ✅ OK — `demographics` data is separate from decisioning; UW reviews financial data only |
| **Selling Guide** | All conditions must be documented and tracked | 🔴 DEPENDS on `underwriting_conditions` table (PROPOSED in 04_Conditions_Management) |

---

## 5. MoXi-Specific Customizations

| Feature | Description | Isolation Strategy |
|---|---|---|
| Mexico Property Risk | Cross-border collateral introduces country/currency/legal risk not present in standard US UW | `uw_decisions.notes` captures Mexico-specific risk factors; `processing_narratives.collateral` addresses this |
| Conditional Approval with Mexico Conditions | Conditions may include Mexico-specific items (Escritura, Fideicomiso trust setup, Notary certification) | `underwriting_conditions.description` is freeform; Mexico conditions are content, not schema |
| Commercial Appraisal Review | MoXi may use commercial appraisal (not standard residential) | UW reviews whatever `documents.document_type` is present; no schema gate |
| Pentaview Integration | MoXi UW uses Pentaview for document viewing alongside Encompass | External tool; no DB impact |
