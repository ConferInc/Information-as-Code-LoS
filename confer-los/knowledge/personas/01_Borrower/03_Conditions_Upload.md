---
type: screen-schema
persona: Borrower (Applicant)
screen: Document Submission (Conditions)
stage: 25-26
system: Consumer Connect Portal (Borrower Portal)
generated: 2026-02-13
source_stubs:
  - modular/01_Borrower/03_Conditions_Upload.md
source_sops:
  - Moxi_Master_SOP_Part2.md (Sections 2-3)
---

# 03 — Document Submission (Conditions Upload)

## 1. UI Component Map

### Stage 25: Borrower Document Submission (Portal)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Portal Login | Auth Screen | — | YES | Valid credentials for `www.globalmortgage.mx/clients` | — |
| Task List | List View | — | — | Displays required documents with status | — |
| Document Container: Paystubs | File Upload Zone | file (PDF/JPG/PNG) | CONDITIONAL | Max 10MB per file; image must be legible | — |
| Document Container: Purchase Agreement | File Upload Zone | file (PDF) | CONDITIONAL | — | — |
| Document Container: Driver's License | File Upload Zone | file (PDF/JPG/PNG) | CONDITIONAL | Clear, unobstructed photo | — |
| Document Container: Tax Returns | File Upload Zone | file (PDF) | CONDITIONAL | 2 most recent years | — |
| Document Container: Asset Statements | File Upload Zone | file (PDF) | CONDITIONAL | All pages, 2 most recent months | — |
| **[Drag and drop or browse]** | Upload Button | — | — | Opens file picker or accepts drag/drop | — |
| Document(s) Uploaded Count | Badge/Counter | integer | — | Auto-increments on successful upload | `0` |

### Stage 26: Task Management

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Tasks Tab | Tab Navigation | — | — | Switches to task list view | — |
| Task List | Checklist | — | — | Pending items with upload actions | — |
| Task Item: Tax Returns | List Item + Upload | file | CONDITIONAL | Status: Pending/Uploaded | Pending |
| Task Item: Asset Statements | List Item + Upload | file | CONDITIONAL | Status: Pending/Uploaded | Pending |

---

## 2. Database Mapping

### Existing Schema Mappings

| UI Field | Supabase Table | Column | Type | Notes |
|---|---|---|---|---|
| Uploaded Document (file) | `documents` | `file_name` | text | Original filename |
| — | `documents` | `file_path` | text | Local/temp path |
| — | `documents` | `file_size` | bigint | File size in bytes |
| — | `documents` | `mime_type` | text | e.g., `application/pdf`, `image/jpeg` |
| — | `documents` | `storage_bucket` | text | Supabase Storage bucket name |
| — | `documents` | `storage_path` | text | Full path in storage |
| Document Type | `documents` | `document_type` | text (enum) | Values: `paystub`, `tax_return`, `bank_statement`, `drivers_license`, `purchase_agreement`, etc. |
| Upload Status | `documents` | `status` | text (enum) | Values: `pending`, `reviewed`, `approved`, `rejected` |
| Uploaded By | `documents` | `uploaded_by` | uuid | References the borrower's `users.id` (portal user) |
| Application Link | `documents` | `application_id` | uuid | Links to the loan application |
| Organization | `documents` | `organization_id` | uuid | Multi-tenancy scope |
| Task Item | `tasks` | `title` | text | E.g., "Upload Tax Returns" |
| Task Status | `tasks` | `status` | text (enum) | Values: `open`, `in_progress`, `completed`, `cancelled` |
| Task Assignee | `tasks` | `assignee_id` | uuid | Set to borrower's `users.id` for portal tasks |
| Task Application | `tasks` | `application_id` | uuid | Links task to loan |

### 🔴 Schema Change Proposals (Missing Mappings)

| UI Field | Proposed Table | Proposed Column | Type | Rationale |
|---|---|---|---|---|
| Document Container / Category | `documents` | `category` | text (enum) | Current schema has `document_type` but no grouping category for the portal UI containers. Values: `income`, `assets`, `identity`, `property`, `disclosures`, `compliance`. |
| Upload Source | `documents` | `upload_source` | text (enum) | Track whether document was uploaded via portal, email, or internal system. Values: `borrower_portal`, `processor_upload`, `email_attachment`, `system_generated`. |
| Task-Document Link | `tasks` | `document_id` | uuid | When a task is "Upload Tax Returns", completing it should link to the uploaded `documents.id`. Currently tasks have no document reference. |
| Document Version | `documents` | `version` | integer | Borrower may re-upload a corrected document. Need version tracking. |
| Document Supersedes | `documents` | `supersedes_id` | uuid (FK) | Points to the previous version of this document that was replaced. |

#### Proposed Column Additions to `documents` Table

```sql
ALTER TABLE documents
  ADD COLUMN category text,
  ADD COLUMN upload_source text DEFAULT 'borrower_portal',
  ADD COLUMN version integer DEFAULT 1,
  ADD COLUMN supersedes_id uuid REFERENCES documents(id);

COMMENT ON COLUMN documents.category IS 'Portal UI grouping: income, assets, identity, property, disclosures, compliance';
COMMENT ON COLUMN documents.upload_source IS 'Source of upload: borrower_portal, processor_upload, email_attachment, system_generated';
COMMENT ON COLUMN documents.version IS 'Document version number; increments on re-upload';
COMMENT ON COLUMN documents.supersedes_id IS 'FK to previous version of this document';
```

#### Proposed Column Addition to `tasks` Table

```sql
ALTER TABLE tasks
  ADD COLUMN document_id uuid REFERENCES documents(id);

COMMENT ON COLUMN tasks.document_id IS 'Links a document-upload task to the fulfilling document';
```

---

## 3. Workflow & Triggers

### User Actions → System State Changes

| Step | Trigger (User Action) | Actor | System Action | State Change | Notification |
|---|---|---|---|---|---|
| 25.1 | Login to portal | Borrower | Authenticate; load task list from `tasks` WHERE `assignee_id = borrower AND status = 'open'` | Session active | — |
| 25.2 | Upload file to container | Borrower | INSERT into `documents`; link `documents.application_id`; set `status = 'pending'`; update upload count | `documents.status` = `pending` | Internal: Processor receives notification of new upload |
| 25.3 | Upload counter increments | System | Update UI badge; check if all required docs uploaded | — | — |
| 26.1 | Complete task (upload doc) | Borrower | UPDATE `tasks.status` = `completed`; SET `tasks.document_id` to uploaded doc; INSERT `application_events` | Task cleared from pending list | Internal: Processor notified |
| — | All tasks completed | System | Check if all `tasks` for application are `completed`; if yes, fire "documents_complete" event | `applications.stage` may advance | Email: "All documents received" to MLO/Processor |
| — | Document reviewed by Processor | Processor | UPDATE `documents.status` = `approved` or `rejected`; if rejected, reopen task | If rejected: task re-created for borrower | Borrower: "Please re-upload [document]" notification |

### Automation Rules

- **Task Auto-Creation**: When Processor sends document request (Stage 19-21 in Sales/MLO flow), auto-create `tasks` rows for borrower with `title` = each requested document.
- **Upload Notification**: On `documents` INSERT WHERE `upload_source = 'borrower_portal'`, notify assigned Processor via `communications` table or webhook.
- **Completion Check**: After each task completion, count remaining open tasks. If 0, log `application_events` with `event_type = 'documents_complete'`.

---

## 4. Compliance Notes

| Regulation | Requirement | Current Status |
|---|---|---|
| **TRID (Reg Z)** | Initial disclosures must be sent within 3 business days of application | ✅ OK — Document request flow (Sales/MLO Stage 19-21) triggers this |
| **ECOA / Reg B** | Adverse action notice within 30 days if application denied | ⚠️ Not relevant to this screen — handled in Underwriting |
| **Selling Guide** | All documents must be legible, complete (all pages), and current | 🟡 PARTIAL — No automated legibility check; manual review by Processor |
| **BSA/AML** | Identity documents (Driver's License, Passport) must be verified | 🟡 PARTIAL — Upload exists but no automated ID verification integration |

---

## 5. MoXi-Specific Customizations

| Feature | Description | Isolation Strategy |
|---|---|---|
| Portal URL | `www.globalmortgage.mx/clients` — MoXi-specific domain | Configuration/DNS; no schema impact |
| Task List: Authentication Code | SOP shows entering code "1234" for portal access — likely a demo/staging value | Application-layer authentication; no DB impact |
| Document Upload: `Chantilly.jpg` | SOP demo shows uploading a JPG as Driver's License | Standard file upload; `mime_type` handles image vs PDF |
| Mexico-Specific Documents | Purchase Agreement may be in Spanish (Escritura draft) | `documents.document_type` should include `purchase_agreement_foreign` or use `category = 'property'` with language metadata |
