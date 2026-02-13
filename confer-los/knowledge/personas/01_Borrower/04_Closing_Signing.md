---
type: screen-schema
persona: Borrower (Applicant)
screen: Closing & Signing
stage: 27
system: Simplifile / Encompass (via Email Link)
generated: 2026-02-13
source_stubs:
  - modular/01_Borrower/04_Closing_Signing.md
source_sops:
  - Moxi_SOP_Jan_21_Part3.md (Sections 7-8)
compliance_refs:
  - CFPB Closing Disclosure (Form H-25)
  - ESIGN Act
---

# 04 — Closing & Signing

## 1. UI Component Map

### Stage 27: Electronic Signature Execution (Simplifile)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Email Link: "Electronic Signature Request" | Email Hyperlink | URL | YES | Opens Simplifile signing session | — |
| Simplifile Signing Interface | External App | — | — | Third-party signing platform | — |
| Disclosure List | Dynamic List | — | — | All documents requiring signature/initial | — |
| **[Sign]** Button (per document) | Signature Capture | signature | YES | Applied at each "Signer" point | — |
| **[Initial]** Button (per document) | Initial Capture | initials | YES | Applied at each "Initial" point | — |
| Signing Progress Indicator | Progress Bar | percentage | — | Tracks completion across all docs | — |
| "Signing Complete!" | Confirmation Screen | — | — | Displayed after all signatures applied | — |
| **[Leave Session]** | Button | — | YES | **CRITICAL**: Triggers sync back to Encompass | — |

---

## 2. Database Mapping

### Existing Schema Mappings

| UI Field | Supabase Table | Column | Type | Notes |
|---|---|---|---|---|
| Signing Request Sent | `communications` | `communication_type` | text | `= 'email'`; `subject` = "Electronic Signature Request" |
| — | `communications` | `direction` | text | `= 'outbound'` |
| — | `communications` | `metadata` (JSONB) | JSONB | `{ "signing_platform": "simplifile", "signing_session_url": "..." }` |
| — | `communications` | `sent_by` | uuid | Closer or system user |
| Signing Completed Event | `application_events` | `event_type` | text | `= 'signing_completed'` |
| — | `application_events` | `metadata` (JSONB) | JSONB | `{ "platform": "simplifile", "documents_signed": [...], "completed_at": "..." }` |
| Signed Documents | `documents` | `status` | text | Updated from `pending` → `approved` after signing |
| — | `documents` | `document_type` | text | Various: `closing_disclosure`, `promissory_note`, `security_instrument`, etc. |
| Application Status | `applications` | `status` | text | Updated to `closing` or `funded` after signing |

### 🔴 Schema Change Proposals (Missing Mappings)

| UI Field | Proposed Table | Proposed Column | Type | Rationale |
|---|---|---|---|---|
| Signing Session ID | NEW: `signing_sessions` | `id` | uuid PK | No table tracks e-signing sessions. Simplifile/DocuSign integration needs session tracking. |
| Signing Platform | `signing_sessions` | `platform` | text (enum) | Values: `simplifile`, `docusign`, `wet_ink`. |
| Session URL | `signing_sessions` | `session_url` | text | URL of the signing session for audit |
| Session Status | `signing_sessions` | `status` | text (enum) | Values: `pending`, `in_progress`, `completed`, `expired`, `voided`. |
| Initiated At | `signing_sessions` | `initiated_at` | timestamptz | When the signing request was sent |
| Completed At | `signing_sessions` | `completed_at` | timestamptz | When the borrower clicked "Leave Session" |
| Application Link | `signing_sessions` | `application_id` | uuid FK | References `applications.id` |
| Signer | `signing_sessions` | `signer_customer_id` | uuid FK | References `customers.id` |
| Individual Doc Signature | NEW: `signing_session_documents` | `id` | uuid PK | Tracks which documents were signed within a session |
| — | `signing_session_documents` | `signing_session_id` | uuid FK | References `signing_sessions.id` |
| — | `signing_session_documents` | `document_id` | uuid FK | References `documents.id` |
| — | `signing_session_documents` | `signature_type` | text (enum) | Values: `signature`, `initial`, `date`. |
| — | `signing_session_documents` | `signed_at` | timestamptz | Timestamp of individual document signature |

#### Proposed New Table: `signing_sessions`

```sql
CREATE TABLE signing_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id),
  application_id uuid NOT NULL REFERENCES applications(id),
  signer_customer_id uuid NOT NULL REFERENCES customers(id),
  platform text NOT NULL DEFAULT 'simplifile',
  session_url text,
  status text NOT NULL DEFAULT 'pending',
  initiated_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT signing_sessions_platform_check CHECK (platform IN ('simplifile', 'docusign', 'wet_ink')),
  CONSTRAINT signing_sessions_status_check CHECK (status IN ('pending', 'in_progress', 'completed', 'expired', 'voided'))
);

CREATE INDEX idx_signing_sessions_application ON signing_sessions(application_id);
CREATE INDEX idx_signing_sessions_status ON signing_sessions(status);

COMMENT ON TABLE signing_sessions IS 'Tracks e-signing sessions for closing packages (Simplifile, DocuSign, etc.)';
```

#### Proposed New Table: `signing_session_documents`

```sql
CREATE TABLE signing_session_documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  signing_session_id uuid NOT NULL REFERENCES signing_sessions(id) ON DELETE CASCADE,
  document_id uuid NOT NULL REFERENCES documents(id),
  signature_type text NOT NULL DEFAULT 'signature',
  signed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT ssd_signature_type_check CHECK (signature_type IN ('signature', 'initial', 'date'))
);

CREATE INDEX idx_ssd_session ON signing_session_documents(signing_session_id);

COMMENT ON TABLE signing_session_documents IS 'Individual document signatures within a signing session';
```

---

## 3. Workflow & Triggers

### User Actions → System State Changes

| Step | Trigger (User Action) | Actor | System Action | State Change | Notification |
|---|---|---|---|---|---|
| 27.1 (Pre) | Closer sends signing request | Closer | INSERT `signing_sessions` (status=pending); INSERT `communications` (email with signing link) | `signing_sessions.status` = `pending` | Email: "Electronic Signature Request" to borrower |
| 27.1a | Borrower clicks email link | Borrower | Update `signing_sessions.status` = `in_progress` | Session active | — |
| 27.1b | Borrower signs each document | Borrower | INSERT `signing_session_documents` per signed doc; update `documents.status` = `approved` | Individual docs marked signed | — |
| 27.2 | Borrower clicks **[Leave Session]** | Borrower | Update `signing_sessions.status` = `completed`; set `completed_at`; INSERT `application_events` (type=`signing_completed`); sync to Encompass | `applications.status` = `closed` | Internal: Closer/Funder notified; triggers funding workflow |
| — | Session expires (no action in 72h) | System | Update `signing_sessions.status` = `expired` | Session void | Email: reminder to borrower; alert to Closer |

### Automation Rules

- **Encompass Sync**: On `signing_sessions.status` = `completed`, trigger webhook/Edge Function to sync signed documents back to Encompass E-Folder.
- **Session Monitoring**: Cron job to expire sessions older than 72 hours where `status IN ('pending', 'in_progress')`.
- **Funding Trigger**: On `signing_completed` event, auto-advance `applications.stage` to `funding` if all conditions are met.

---

## 4. Compliance Notes

| Regulation | Requirement | Current Status |
|---|---|---|
| **TRID / Reg Z** | Closing Disclosure must be provided at least 3 business days before closing | ✅ Tracked via `documents` table + `communications` send date |
| **ESIGN Act** | Electronic signatures legally equivalent to wet ink if consent obtained | ✅ eConsent captured in Application stage (02_Application_1003) |
| **CFPB H-25** | Closing Disclosure must itemize all loan costs, cash to close, APR, TIP | ✅ Document content is generated by Encompass/LOS; stored in `documents` |
| **RESPA** | Settlement Agent info, real estate commission disclosure | ✅ Included in CD; no separate schema needed |

---

## 5. MoXi-Specific Customizations

| Feature | Description | Isolation Strategy |
|---|---|---|
| Simplifile Platform | MoXi uses Simplifile for e-signing; other orgs may use DocuSign | `signing_sessions.platform` enum handles multiple providers |
| Mexican Wet Signing (Escritura) | Escritura must be signed in blue ink in Mexico — NOT electronic | `platform = 'wet_ink'` for Escritura; separate `signing_session` record with manual completion |
| International Cover Sheet - English | MoXi-specific closing document for cross-border transactions | Standard `documents.document_type = 'international_cover_sheet'`; enum extension needed |
| **[Leave Session]** Critical Action | SOP emphasizes this triggers Encompass sync — failure to click leaves documents in limbo | Monitoring: alert if `signing_sessions` stays `in_progress` > 1 hour after all docs signed |
