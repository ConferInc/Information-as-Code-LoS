---
type: screen-schema
persona: Client Concierge / Processor
screen: Conditions Management
stage: 81, 83
system: Encompass
generated: 2026-02-13
source_stubs:
  - modular/03_Processor/04_Conditions_Management.md
source_sops:
  - Moxi_Master_SOP_Part1.md (Section 7)
compliance_refs:
  - Selling Guide (Condition Clearing)
  - TRID (Revised disclosures on material changes)
---

# 04 — Conditions Management

## 1. UI Component Map

### Stage 81: Processing Requests (Signatures & Documents)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| **[Request Signature]** | Checkbox/Button | boolean | YES | Check to enable signature request mode | — |
| Confirmation Dialog | Modal | — | — | "Confirm/OK" to proceed | — |
| **[Confirm/OK]** | Button | — | YES | Activates signature request mode | — |
| Documents Tab | Tab Navigation | — | — | Shows document list | — |
| Document List | Selectable List | — | — | E.g., "Tax Returns 2025" | — |
| **[Send]** (Document Request) | Button | — | YES | Sends request to borrower portal | — |
| Services & Docs Link | Navigation | — | — | Opens service menu | — |
| Disclosure List | Selectable List | — | — | E.g., "Non-Refundable Fee Disclosure" | — |
| **[Transmit / Send]** (Disclosure) | Button | — | YES | Emails disclosure to borrower | — |

### Stage 82: Verification & Certification (from PERSONA.MD)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Docs & Certifications List | Checklist View | — | — | Visual scan of all required certifications | — |
| Credit Report Request | Checkbox | boolean | — | Mark as Verified | — |
| HUD-1 Settlement Statement | Checkbox | boolean | — | ⚠️ **DEPRECATED** — Legacy document replaced by Closing Disclosure under TRID (2015) | — |
| URLA (1003) | Checkbox | boolean | — | Mark as Verified | — |
| **[Sign & Certify]** | Button | — | YES | Creates internal audit stamp | — |
| Borrower Communications Tab | Tab Navigation | — | — | Opens message composer | — |
| Message Text Area | Text Area | string | YES | E.g., "Please upload the following conditions..." | — |
| **[Send]** (Borrower Message) | Button | — | YES | Sends alert to borrower | — |

### Stage 83: Condition Management

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| **[Add Condition]** | Button | — | — | Opens condition creation modal | — |
| Condition Modal | Modal Form | — | — | — | — |
| Loan Status Filter | Dropdown | enum | NO | Filter conditions by status | — |
| Condition Description | Text Input | string | YES | Describe the condition | — |
| Condition Category | Dropdown | enum | YES | Prior-to-Docs, Prior-to-Funding, Prior-to-Closing, Post-Closing | — |
| Condition Status Tag | Text Input / Tag | string | YES | E.g., "Open", "Received", "Cleared", "Waived" | `Open` |
| **[Apply]** | Button | — | YES | Saves condition to list | — |

---

## 2. Database Mapping

### Existing Schema Mappings

| UI Field | Supabase Table | Column | Type | Notes |
|---|---|---|---|---|
| Signature Request Sent | `communications` | all fields | — | `communication_type = 'email'`; subject contains "Signature Request" |
| Document Request Sent | `tasks` | all fields | — | Creates task for borrower to upload specific document |
| Disclosure Sent | `communications` | all fields | — | Email with disclosure attached |
| — | `documents` | all fields | — | Disclosure PDF stored in `documents` table |
| Borrower Message | `communications` | `content` | text | Message to borrower about conditions |
| — | `communications` | `communication_type` | text | `= 'portal_message'` or `= 'email'` |
| Internal Audit Stamp | `application_events` | `event_type` | text | `= 'file_certified'` |
| Condition Description | — | — | — | 🔴 MISSING — No `conditions` table exists |

### 🔴 Schema Change Proposals (Missing Mappings)

| UI Field | Proposed Table | Proposed Column | Type | Rationale |
|---|---|---|---|---|
| Condition Description | NEW: `underwriting_conditions` | `description` | text | Core missing table: UW conditions are central to mortgage processing |
| Condition Category | `underwriting_conditions` | `category` | text (enum) | Values: `prior_to_docs`, `prior_to_funding`, `prior_to_closing`, `post_closing` |
| Condition Status | `underwriting_conditions` | `status` | text (enum) | Values: `open`, `received`, `under_review`, `cleared`, `waived`, `rejected` |
| Condition Source | `underwriting_conditions` | `source` | text (enum) | Who created it: `underwriter`, `processor`, `system` |
| Condition Document | `underwriting_conditions` | `document_id` | uuid FK | Document that satisfies the condition |
| Condition Assigned To | `underwriting_conditions` | `assigned_to` | uuid FK | Who is responsible for clearing |
| Condition Due Date | `underwriting_conditions` | `due_date` | date | When condition must be cleared |
| Certification Status | NEW: `file_certifications` | `status` | text (enum) | Internal audit/certification tracking |
| Certification Item | `file_certifications` | `item_name` | text | E.g., "Credit Report Request", "URLA (1003)" |
| Certification Verified | `file_certifications` | `verified` | boolean | Whether item was verified |
| HUD-1 (Legacy) | `file_certifications` | `item_name` | text | ⚠️ **DEPRECATED**: Map to `closing_disclosure` check instead. Flag with `deprecated = true`. |

#### Proposed New Table: `underwriting_conditions`

```sql
CREATE TABLE underwriting_conditions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id),
  application_id uuid NOT NULL REFERENCES applications(id),
  description text NOT NULL,
  category text NOT NULL,
  status text NOT NULL DEFAULT 'open',
  source text NOT NULL DEFAULT 'underwriter',
  assigned_to uuid REFERENCES users(id),
  created_by uuid NOT NULL REFERENCES users(id),
  document_id uuid REFERENCES documents(id),
  due_date date,
  cleared_by uuid REFERENCES users(id),
  cleared_at timestamptz,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT uc_category_check CHECK (category IN (
    'prior_to_docs', 'prior_to_funding', 'prior_to_closing', 'post_closing'
  )),
  CONSTRAINT uc_status_check CHECK (status IN (
    'open', 'received', 'under_review', 'cleared', 'waived', 'rejected'
  )),
  CONSTRAINT uc_source_check CHECK (source IN ('underwriter', 'processor', 'investor', 'system'))
);

CREATE INDEX idx_uw_conditions_application ON underwriting_conditions(application_id);
CREATE INDEX idx_uw_conditions_status ON underwriting_conditions(status);
CREATE INDEX idx_uw_conditions_category ON underwriting_conditions(category);

COMMENT ON TABLE underwriting_conditions IS 'Underwriting conditions (PTD, PTF, PTC, Post-Closing) with status tracking';
```

#### Proposed New Table: `file_certifications`

```sql
CREATE TABLE file_certifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id),
  application_id uuid NOT NULL REFERENCES applications(id),
  item_name text NOT NULL,
  item_category text NOT NULL DEFAULT 'document',
  verified boolean DEFAULT false,
  verified_by uuid REFERENCES users(id),
  verified_at timestamptz,
  deprecated boolean DEFAULT false,
  deprecated_replacement text,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT fc_category_check CHECK (item_category IN ('document', 'disclosure', 'certification', 'verification'))
);

CREATE INDEX idx_file_certifications_application ON file_certifications(application_id);

COMMENT ON TABLE file_certifications IS 'Internal file audit/certification checklist for processor verification';
```

---

## 3. Workflow & Triggers

### User Actions → System State Changes

| Step | Trigger | Actor | System Action | State Change | Notification |
|---|---|---|---|---|---|
| 81.1-81.5 | Request signature + select docs | Processor | INSERT `communications` (email); INSERT `tasks` for borrower | Tasks created for borrower | Borrower: email + portal notification |
| 81.2 | Send disclosure | Processor | INSERT `communications` (email with disclosure); INSERT `documents` (disclosure PDF) | Disclosure delivered | Borrower: email with disclosure |
| 82.1-82.4 | Review certification checklist | Processor | INSERT/UPDATE `file_certifications` per item | Items marked verified | — |
| 82.1 (HUD-1) | ⚠️ HUD-1 checkbox present | Processor | INSERT `file_certifications` with `deprecated = true`, `deprecated_replacement = 'closing_disclosure'` | Flagged as legacy | Compliance: alert if validated |
| 82.5 | Click **[Sign & Certify]** | Processor | INSERT `application_events` (type=`file_certified`); check all `file_certifications.verified = true` | File certified | Internal: UW notified file is ready |
| 82.6-82.8 | Send conditions message to borrower | Processor | INSERT `communications` (type=`portal_message`, content="Please upload the following conditions...") | Conditions communicated | Borrower: portal/email alert |
| 83.1-83.4 | Add condition | Processor | INSERT `underwriting_conditions` | New condition tracked | Assignee notified |
| — | Borrower uploads condition document | Borrower | UPDATE `underwriting_conditions.status` = `received`; link `document_id` | Condition document received | Processor notified |
| — | Processor reviews & clears | Processor | UPDATE `underwriting_conditions.status` = `cleared`; set `cleared_by`, `cleared_at` | Condition cleared | UW notified |
| — | All conditions cleared | System | Check all `underwriting_conditions.status IN ('cleared', 'waived')` for application | Ready for Clear to Close | MLO + Closer notified |

### Automation Rules

- **Condition Auto-Creation**: When UW renders decision with conditions, auto-INSERT `underwriting_conditions` rows from decision data.
- **Task Linking**: When a condition requires a document, auto-create a `tasks` row for the borrower with the condition description.
- **All-Clear Check**: Trigger function on `underwriting_conditions` UPDATE to check if all conditions for an application are `cleared` or `waived`. If yes, fire `conditions_cleared` event.
- **Deprecated Item Alert**: If `file_certifications.deprecated = true AND verified = true`, log compliance warning.

---

## 4. Compliance Notes

| Regulation | Requirement | Current Status |
|---|---|---|
| **Selling Guide** | All conditions must be cleared before Clear to Close | 🔴 MISSING — `underwriting_conditions` table proposed; no automated all-clear check exists |
| **TRID / Reg Z** | Material condition changes may require revised Loan Estimate | 🟡 PARTIAL — No automated trigger for revised LE; manual process |
| **TRID (2015)** | HUD-1 Settlement Statement replaced by Closing Disclosure | ⚠️ **DEPRECATED** — SOP Stage 82 still validates HUD-1. Must flag with `deprecated = true` and map to CD check. |
| **CFPB** | Borrower must receive condition requests in writing | ✅ OK — `communications` table tracks all borrower messages |

---

## 5. MoXi-Specific Customizations

| Feature | Description | Isolation Strategy |
|---|---|---|
| HUD-1 in Checklist | MoXi SOP still references legacy HUD-1 Settlement Statement in certification checklist | Flag as `deprecated = true` in `file_certifications`; training update needed for MoXi team |
| Non-Refundable Fee Disclosure | MoXi-specific disclosure not standard in US LOS | `documents.document_type = 'non_refundable_fee_disclosure'` enum extension |
| "Tax Returns 2025" | Condition example references specific year | Standard condition; year is dynamic in `underwriting_conditions.description` |
| Conditions Email Template | "Please upload the following conditions..." — MoXi template language | Email template stored in application config; `communications.content` captures actual text sent |
