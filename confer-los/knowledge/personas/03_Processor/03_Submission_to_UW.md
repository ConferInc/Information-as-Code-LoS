---
type: screen-schema
persona: Client Concierge / Processor
screen: Submission to Underwriting
stage: 45, 66-68
system: Encompass / Evolve Portal
generated: 2026-02-13
source_stubs:
  - modular/03_Processor/03_Submission_to_UW.md
source_sops:
  - Moxi_SOP_Jan_21_Part2.md (Sections 3-4)
compliance_refs:
  - MISMO 3.4 (GSE Export Standard)
  - Selling Guide (Pre-submission requirements)
---

# 03 — Submission to Underwriting

## 1. UI Component Map

### Stage 66: Preparing for Evolve Submission

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| E-Folder > Documents | File Browser | — | — | Navigate to document list | — |
| Right-Click Context Menu | Menu | — | — | New > Folder | — |
| Folder Name | Text Input | string | YES | Borrower last name (e.g., "Lejeune") | — |
| Right-Click > GSE Services | Menu | — | — | Export ILAD MISMO 3.4 | — |
| Export ILAD MISMO 3.4 | Action | — | YES | Generates XML file | — |
| XML Filename | Text Input | string | YES | `[Loan Number].xml` (e.g., `24009603.xml`) | — |
| Save Location | File Picker | path | YES | Local directory | — |
| **[OK]** (Save) | Button | — | YES | Saves XML export | — |

### Stage 67: Upload to Evolve Portal

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Evolve Portal | External Web App | — | — | Third-party UW submission portal | — |
| **[Upload Data / Image Files]** | Button | — | — | Opens upload interface | — |
| **[Add Files]** (Green Plus) | Button | — | YES | File picker | — |
| XML File Selection | File Picker | file (.xml) | YES | Select MISMO 3.4 XML | — |
| **[Upload]** | Button | — | YES | Sends file to Evolve | — |
| Upload Progress | Progress Bar | percentage | — | ~10-15 minute processing time | — |

### Stage 45: Internal Operations Review Trigger

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| MA Workbook > Final Verifications | Tab | — | — | — | — |
| "Are You Ready To Request The Initial Review...?" | Dropdown | boolean | YES | Yes/No | `No` |
| Operations Submission Notes | Text Area | string | NO | E.g., "Full package uploaded - ready for audit" | — |
| **[Send Review Request]** | Button | — | YES | Triggers internal operations review | — |

### Stage 68: Processor Assignment

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Milestone View | Panel | — | — | — | — |
| Loan Processor Field | Dropdown | enum (user list) | YES | Select from team members | Default processor |
| Processor Update | Selection | uuid | YES | E.g., change to "Carlos" | — |

---

## 2. Database Mapping

### Existing Schema Mappings

| UI Field | Supabase Table | Column | Type | Notes |
|---|---|---|---|---|
| MISMO 3.4 XML Export | `documents` | all fields | — | `document_type = 'mismo_export'`; `mime_type = 'application/xml'` |
| Evolve Upload Status | `application_events` | `event_type` | text | `= 'uw_submission'`; `metadata` stores upload details |
| Operations Review Request | `application_events` | `event_type` | text | `= 'review_requested'` |
| Submission Notes | `notes` | `content` | text | Linked to application |
| Loan Processor Assignment | `applications` | `assigned_processor_id` | uuid | FK to `users.id` |
| Application Stage | `applications` | `stage` | text | Transitions from `processing` to `underwriting` |

### 🔴 Schema Change Proposals (Missing Mappings)

| UI Field | Proposed Table | Proposed Column | Type | Rationale |
|---|---|---|---|---|
| MISMO Export Version | `documents` | `metadata` (JSONB) | JSONB | Track MISMO version (3.4) and export type (ILAD) in document metadata. No new column needed — use existing JSONB or add column. |
| Evolve Submission ID | NEW: `uw_submissions` | `external_submission_id` | text | Track third-party UW portal submissions |
| Evolve Submission Status | `uw_submissions` | `status` | text (enum) | Values: `uploading`, `processing`, `accepted`, `rejected`, `returned` |
| Evolve Portal | `uw_submissions` | `portal` | text (enum) | Values: `evolve`, `du`, `lpa`, `manual`. MoXi uses Evolve. |
| Submission Timestamp | `uw_submissions` | `submitted_at` | timestamptz | When XML was uploaded |
| Processing Duration | `uw_submissions` | `processed_at` | timestamptz | When Evolve finished processing (~10-15 min) |
| Review Readiness Flag | `processing_checklists` | `ready_for_uw_review` | boolean | Maps to "Are You Ready To Request..." dropdown. 🔴 PROPOSED table in 01_File_Setup |
| Review Requested At | `applications` | `uw_review_requested_at` | timestamptz | Timestamp of operations review request for SLA tracking |

#### Proposed New Table: `uw_submissions`

```sql
CREATE TABLE uw_submissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id),
  application_id uuid NOT NULL REFERENCES applications(id),
  portal text NOT NULL DEFAULT 'evolve',
  external_submission_id text,
  mismo_document_id uuid REFERENCES documents(id),
  status text NOT NULL DEFAULT 'uploading',
  submitted_by uuid REFERENCES users(id),
  submitted_at timestamptz NOT NULL DEFAULT now(),
  processed_at timestamptz,
  response_data jsonb,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT us_portal_check CHECK (portal IN ('evolve', 'du', 'lpa', 'manual')),
  CONSTRAINT us_status_check CHECK (status IN ('uploading', 'processing', 'accepted', 'rejected', 'returned'))
);

CREATE INDEX idx_uw_submissions_application ON uw_submissions(application_id);
CREATE INDEX idx_uw_submissions_status ON uw_submissions(status);

COMMENT ON TABLE uw_submissions IS 'Tracks underwriting submissions to external portals (Evolve, DU, LPA)';
```

#### Proposed Column Additions

```sql
-- Add to processing_checklists (proposed in 01_File_Setup)
ALTER TABLE processing_checklists
  ADD COLUMN ready_for_uw_review boolean DEFAULT false;

-- Add to applications
ALTER TABLE applications
  ADD COLUMN uw_review_requested_at timestamptz;

COMMENT ON COLUMN applications.uw_review_requested_at IS 'Timestamp when operations review was requested. SLA tracking.';
```

---

## 3. Workflow & Triggers

### User Actions → System State Changes

| Step | Trigger | Actor | System Action | State Change | Notification |
|---|---|---|---|---|---|
| 66.1 | Create folder in E-Folder | Processor | Create local document folder (Encompass-side) | — | — |
| 66.2 | Export MISMO 3.4 | Processor | Generate XML from Encompass loan data; INSERT `documents` (type=`mismo_export`) | MISMO file created | — |
| 67.1-67.5 | Upload to Evolve | Processor | INSERT `uw_submissions` (portal=evolve, status=uploading); on upload complete, status=processing | `uw_submissions.status` = `processing` | — |
| 67.5 | Evolve processing complete | System (webhook) | UPDATE `uw_submissions.status` = `accepted` or `rejected`; set `processed_at` | Submission result known | Internal: Processor notified of result |
| 45.2 | Set "Ready for Review" = Yes | Processor | UPDATE `processing_checklists.ready_for_uw_review` = true | Review enabled | — |
| 45.4 | Click **[Send Review Request]** | Processor | SET `applications.uw_review_requested_at`; INSERT `application_events` (type=`review_requested`); INSERT `notes` with submission notes | `applications.stage` → `underwriting` (pending) | Internal: Operations team notified |
| 68.1 | Assign Loan Processor | Processor/Admin | UPDATE `applications.assigned_processor_id` | Processor formally assigned | — |

### Automation Rules

- **MISMO Validation**: Before export, validate all required MISMO 3.4 fields are populated. Block export if critical fields missing.
- **Stage Transition**: On `review_requested` event AND `uw_submissions.status = 'accepted'`, auto-advance `applications.stage` to `underwriting`.
- **SLA Monitoring**: If `uw_review_requested_at` is set but `applications.stage` hasn't advanced to `underwriting` within 2 business days, alert operations.
- **Evolve Polling**: If no webhook available, poll Evolve portal every 5 minutes for upload status until `processed_at` is set.

---

## 4. Compliance Notes

| Regulation | Requirement | Current Status |
|---|---|---|
| **MISMO 3.4** | GSE-standard data exchange format for loan submissions | ✅ OK — Export functionality exists in Encompass; `uw_submissions` table proposed for tracking |
| **Selling Guide** | All required documents must be in file before UW submission | 🟡 PARTIAL — `processing_checklists.all_green_checks` tracks this but no hard block on submission |
| **TRID / Reg Z** | If terms change after UW, revised LE may be required | ⚠️ Downstream concern — tracked in Underwriting/Closer stages |

---

## 5. MoXi-Specific Customizations

| Feature | Description | Isolation Strategy |
|---|---|---|
| Evolve Portal | MoXi uses Evolve for UW submission; other orgs may use DU/LPA/manual | `uw_submissions.portal` enum handles multiple options |
| 10-15 Minute Processing Time | Evolve takes 10-15 min to process uploads; system must handle async | `submitted_at` vs `processed_at` timestamps; async status polling |
| MISMO 3.4 Export Format | Standard GSE format; MoXi uses ILAD variant | `documents.metadata` JSONB stores `{ "mismo_version": "3.4", "export_type": "ILAD" }` |
| Processor Assignment Override | Default processor may need to be changed to correct team member | `applications.assigned_processor_id` is updatable; audit trail via `application_events` |
