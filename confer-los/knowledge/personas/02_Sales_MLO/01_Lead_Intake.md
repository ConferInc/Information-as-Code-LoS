---
type: screen-schema
persona: Sales / Mortgage Loan Originator (MLO)
screen: Lead Intake & Initial Processing
stage: 3-7 (CRM), 16-24 (LOS)
system: Salesforce (Jungo) / Encompass (LOS) / Gmail
generated: 2026-02-13
source_stubs:
  - modular/02_Sales_MLO/01_Lead_Intake.md
source_sops:
  - Moxi_Master_SOP_Part1.md (Sections 5-7)
  - Moxi_Master_SOP_Part2.md (Sections 1, 4-5)
compliance_refs:
  - URLA Instructions (Sections 1a-1e, 4a, 5)
  - TRID (Reg Z) — 3-day disclosure requirement
  - FCRA — Credit authorization
---

# 01 — Lead Intake & Initial Processing (CRM → LOS)

> **Note:** This is the largest persona file, spanning two systems (Salesforce CRM → Encompass LOS) across 22 stages. The schema is split into two phases.

---

## PHASE A: CRM Lead Management (Stages 3-7, Salesforce/Jungo)

### 1A. UI Component Map

#### Stage 3: Lead Queue Monitoring

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Reports Tab | Tab Navigation | — | — | Navigates to Salesforce Reports | — |
| Report: "Intro Call 1 - Needed Today" | Report View | — | — | Filtered list of new leads | — |
| Lead Name | Hyperlink | string | — | Click to open Contact Record | — |
| Marketing Campaign Status | Read-Only Field | string | — | — | — |
| Stage | Read-Only Field | string | — | — | "Intro Message Sent - No Initial Contact" |
| Contact Info | Read-Only Group | — | — | Name, Email, Phone from web form | — |

#### Stage 4: Lead Qualification

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| "Are You A US Citizen?" | Read-Only Field | string | — | Captured from lead form | — |
| "Property Value At Least 350k" | Read-Only Field | string | — | ⚠️ SOP says $350K but lead form says $550K — discrepancy | — |
| Lead Source | Read-Only Field | string | — | E.g., "Online/Website" | — |
| Record Owner | Read-Only Field | string | — | Assigned MLO | — |

#### Stage 5: Communication Compliance

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Email Opt Out | Checkbox | boolean | — | Must be UNCHECKED for email | `false` |
| Do Not Call | Checkbox | boolean | — | Must be UNCHECKED for phone | `false` |

#### Stage 6-7: Marketing & Scheduling

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Automated Email Subject | Read-Only | string | — | "Finance Your Mexican Real Estate..." | — |
| Email Content: "WATCH THIS VIDEO FIRST!" | Read-Only | HTML | — | Automated nurture content | — |
| Scheduling Link | Hyperlink | URL | — | Books "MoXi Discovery Session" | — |
| Advisor Contact Card | Card Component | — | — | Mortgage Advisor info (e.g., Carl Cardarelli) | — |

---

## PHASE B: LOS Application Processing (Stages 16-24, Encompass)

### 1B. UI Component Map

#### Stage 16: Pipeline & Application Receipt

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Pipeline View | Grid/Table | — | — | Filterable list of all loans | — |
| Loan File Row | Clickable Row | — | — | Double-click to open | — |
| Borrower Name | Text | string | — | E.g., "Lejeune, Teydra" | — |
| Milestone | Badge | enum | — | "Pre-Qualification" or "Prospect" | — |
| File Status | Badge | enum | — | "Application Received" | — |

#### Stage 17: MA Workbook — Borrower Info Review

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| MA Workbook | Form Selection | — | — | Select from Forms list | — |
| Current Status | Read-Only | string | — | "Application Received" | — |
| Borrower Name | Read-Only | string | YES | Cross-reference against application | — |
| SSN | Masked Read-Only | string | YES | Cross-reference against application | — |
| DOB | Read-Only | date | YES | Cross-reference against application | — |
| Citizenship | Read-Only | string | YES | Cross-reference against application | — |

#### Stage 18: Declarations & Credit Review

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| **[View Declarations]** | Button | — | — | Opens declarations panel | — |
| Declarations: Judgments | Read-Only | boolean | — | URLA Section 5 questions | — |
| Declarations: Lawsuits | Read-Only | boolean | — | URLA Section 5 questions | — |
| Credit & Income Tab | Tab Navigation | — | — | — | — |
| Base Income | Read-Only | decimal | — | E.g., $12,500.00 | — |
| Credit Status | Badge | string | — | "Not Imported" initially | — |
| Authorized Credit Report | Checkbox | boolean | YES | Must be checked before credit pull | — |

#### Stage 19-21: Document Request & Disclosures

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Docs & Verifications Panel | Navigation | — | — | Pre-Submittal section | — |
| "Borrower is Using" | Read-Only | string | — | "Consumer Connect" | — |
| **[Send Document Request & Disclosures]** | Button | — | YES | Triggers disclosure package | — |
| Progress Bar: "Preparing Forms" | Loading Indicator | — | — | System generating forms | — |
| Document Request Popup | Modal | — | — | Checklist of documents to request | — |
| Non-Refundable Fee Disclosure | Checkbox (Pre-Selected) | boolean | YES | — | `true` |
| US Passport | Checkbox (Pre-Selected) | boolean | YES | — | `true` |
| Personal Bank Statements | Checkbox (Pre-Selected) | boolean | YES | — | `true` |
| Credit Report Disclosure | Checkbox (Pre-Selected) | boolean | YES | — | `true` |
| U10 - Asset Statements | Checkbox | boolean | NO | Manually added if needed | `false` |
| Send Request Window | Modal | — | — | Email configuration | — |
| Sender Type | Dropdown | enum | — | "Current User" | — |
| Recipient Email | Pre-Filled | string (email) | YES | Borrower's email | — |
| Subject Line | Pre-Filled | string | — | "MoXi - A Global Mortgage Company - Electronic Loan Document Request" | — |
| **[Notify Additional Users]** | Button | — | NO | Opens user picker | — |
| Additional User Picker | Dropdown/Search | — | NO | E.g., "Oscar Galicia" (Processor) | — |
| "Notify me when borrower receives..." | Checkbox | boolean | NO | — | `false` |
| eSign Option | Radio | enum | YES | "eSign (electronically sign and return)" | — |
| **[Send]** | Button | — | YES | Dispatches email + portal tasks | — |

#### Stage 24: Credit & Income Verification

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Credit & Income Tab | Tab Navigation | — | — | MA Workbook section | — |
| Authorized Credit Report | Checkbox | boolean | YES | Must be selected | — |
| Min FICO Score | Read-Only | integer | — | E.g., 700 | — |
| Reference # | Read-Only | string | — | Credit report reference | — |
| Primary Qualifying Income Type | Dropdown | enum | YES | "Wage Earner", "Self-Employed", "Retired" | — |
| Total Income Calculations | Auto-Calculated | decimal | — | Sum of all income sources | — |

---

## 2. Database Mapping

### Phase A: CRM Mappings (Salesforce → Supabase)

> **Architectural Note:** Salesforce/Jungo is an EXTERNAL CRM. The Supabase schema does not replicate CRM data. However, on transition to Encompass (Stage 16), the lead becomes an `applications` record. Below maps the CRM-to-Supabase handoff.

| CRM Field (Salesforce) | Supabase Table | Column | Type | Notes |
|---|---|---|---|---|
| Lead Name | `customers` | `first_name`, `last_name` | text | Synced on lead conversion |
| Lead Email | `customers` | `email` | text | — |
| Lead Phone | `customers` | `phone` | text | — |
| Lead Source | `customers` | `lead_source` | text | 🔴 PROPOSED in 01_Lead_Capture |
| US Citizen? | `customers` | `citizenship_status` | text | — |
| Record Owner (MLO) | `applications` | `assigned_lo_id` | uuid | Maps to `users.id` of the MLO |
| Marketing Campaign Stage | — | — | — | CRM-only; no Supabase equivalent needed |
| Email Opt Out | `customers` | `sms_consent` (inverse) | boolean | 🔴 PROPOSED; map opt-out = `sms_consent = false` |
| Do Not Call | — | — | — | CRM-only compliance field |

### Phase B: LOS Mappings (Encompass → Supabase)

| UI Field | Supabase Table | Column | Type | Notes |
|---|---|---|---|---|
| Pipeline View / Loan File | `applications` | `id`, `application_number` | uuid, text | — |
| Milestone | `applications` | `stage` | text (enum) | Values: `application`, `processing`, `underwriting`, `closing`, `funded` |
| File Status | `applications` | `status` | text (enum) | Values: `draft`, `submitted`, `in_review`, etc. |
| MA Workbook — Borrower Info | `customers` | all personal fields | — | Cross-reference audit |
| Declarations | `declarations` | all boolean fields | boolean | URLA Section 5a/5b |
| Credit Status | `application_customers` | `credit_score`, `credit_report_date` | integer, date | Updated after credit pull |
| Authorized Credit Report | `application_customers` | `credit_auth_signed` | boolean | 🔴 PROPOSED in 02_Application_1003 |
| Base Income | `incomes` | `amount` WHERE `income_type = 'base'` | decimal | — |
| Qualifying Income Type | `employments` | `employment_type` | text | Values: `wage_earner`, `self_employed`, `retired` |
| Document Request Sent | `communications` | all fields | — | `communication_type = 'email'`, `subject = "Electronic Loan Document Request"` |
| Disclosures Sent | `documents` | `document_type` | text | INSERT rows for each disclosure (LE, fee disclosure, privacy notice) |
| Assigned Processor | `applications` | `assigned_processor_id` | uuid | Set when additional user notified |
| Min FICO | `application_customers` | `credit_score` | integer | — |

### 🔴 Schema Change Proposals (Missing Mappings)

| UI Field | Proposed Table | Proposed Column | Type | Rationale |
|---|---|---|---|---|
| CRM Lead ID (Salesforce) | `customers` | `external_crm_id` | text | Salesforce Record ID for bi-directional sync. Critical for CRM ↔ LOS integration. |
| CRM Lead Stage | `customers` | `crm_stage` | text | Track CRM funnel stage. Values: `new_lead`, `intro_sent`, `discovery_scheduled`, `qualified`, `converted`. |
| Discovery Session Scheduled | `customers` | `discovery_session_at` | timestamptz | Timestamp of booked discovery call. |
| Assigned MLO (from CRM) | `applications` | `assigned_lo_id` | uuid | ✅ Already exists — confirm auto-populated from CRM owner |
| Disclosure Package Sent At | `applications` | `initial_disclosures_sent_at` | timestamptz | TRID compliance: must track when initial disclosures were sent (3-day rule). |
| Disclosure Package Method | `applications` | `disclosures_delivery_method` | text (enum) | Values: `esign`, `mail`, `in_person`. TRID requires tracking delivery method for day-count calculation. |
| Document Request ID | `communications` | `external_reference_id` | text | Encompass document request ID for traceability. |
| Credit Report Vendor | NEW: `credit_reports` | `vendor` | text | Need dedicated table for credit reports (see below). |
| Credit Report Type | `credit_reports` | `report_type` | text (enum) | Values: `tri_merge`, `single_bureau`, `soft_pull`. |
| Credit Report Reference # | `credit_reports` | `reference_number` | text | Vendor reference number. |
| Credit Report PDF | `credit_reports` | `document_id` | uuid FK | Link to `documents` table for stored PDF. |

#### Proposed Column Additions to `customers` Table

```sql
ALTER TABLE customers
  ADD COLUMN external_crm_id text,
  ADD COLUMN crm_stage text,
  ADD COLUMN discovery_session_at timestamptz;

COMMENT ON COLUMN customers.external_crm_id IS 'Salesforce/Jungo Record ID for CRM sync';
COMMENT ON COLUMN customers.crm_stage IS 'CRM funnel stage: new_lead, intro_sent, discovery_scheduled, qualified, converted';
COMMENT ON COLUMN customers.discovery_session_at IS 'Booked discovery/intro call timestamp';
```

#### Proposed Column Additions to `applications` Table

```sql
ALTER TABLE applications
  ADD COLUMN initial_disclosures_sent_at timestamptz,
  ADD COLUMN disclosures_delivery_method text;

COMMENT ON COLUMN applications.initial_disclosures_sent_at IS 'TRID: Timestamp when initial disclosures (LE, etc.) were sent. 3-business-day rule starts here.';
COMMENT ON COLUMN applications.disclosures_delivery_method IS 'TRID: Delivery method for day-count. Values: esign, mail, in_person';
```

#### Proposed Column Addition to `communications` Table

```sql
ALTER TABLE communications
  ADD COLUMN external_reference_id text;

COMMENT ON COLUMN communications.external_reference_id IS 'External system reference ID (e.g., Encompass document request ID)';
```

#### Proposed New Table: `credit_reports`

```sql
CREATE TABLE credit_reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id),
  application_id uuid NOT NULL REFERENCES applications(id),
  application_customer_id uuid NOT NULL REFERENCES application_customers(id),
  vendor text NOT NULL DEFAULT 'sarma',
  report_type text NOT NULL DEFAULT 'tri_merge',
  reference_number text,
  credit_score_equifax integer,
  credit_score_experian integer,
  credit_score_transunion integer,
  min_score integer,
  mid_score integer,
  document_id uuid REFERENCES documents(id),
  pulled_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT cr_report_type_check CHECK (report_type IN ('tri_merge', 'single_bureau', 'soft_pull')),
  CONSTRAINT cr_vendor_check CHECK (vendor IN ('sarma', 'equifax', 'experian', 'transunion', 'other'))
);

CREATE INDEX idx_credit_reports_application ON credit_reports(application_id);
CREATE INDEX idx_credit_reports_customer ON credit_reports(application_customer_id);

COMMENT ON TABLE credit_reports IS 'Tracks credit report pulls including vendor, scores, and linked PDF document';
```

---

## 3. Workflow & Triggers

### Phase A: CRM Workflow

| Step | Trigger | Actor | System Action | State Change | Notification |
|---|---|---|---|---|---|
| 3.1 | New lead appears in "Intro Call 1" report | System | Lead synced from web form to Salesforce | CRM Stage: `new_lead` | MLO sees lead in queue |
| 5.1 | MLO verifies communication preferences | MLO | Confirm Email Opt Out = UNCHECKED, Do Not Call = UNCHECKED | Compliance cleared | — |
| 6.1 | Automated email fires | System | Send "Finance Your Mexican Real Estate" email | CRM Stage: `intro_sent` | Borrower receives email |
| 7.1 | Borrower books discovery session | Borrower | Calendar event created; CRM updated | CRM Stage: `discovery_scheduled` | MLO receives calendar invite |

### Phase B: LOS Workflow

| Step | Trigger | Actor | System Action | State Change | Notification |
|---|---|---|---|---|---|
| 16.1 | MLO opens Pipeline | MLO | Query `applications` WHERE `assigned_lo_id = MLO AND stage = 'application'` | — | — |
| 17.1-17.2 | MLO reviews MA Workbook | MLO | Read `customers`, `application_customers`; audit data integrity | — | — |
| 18.1-18.2 | MLO checks declarations & credit | MLO | Read `declarations`; verify `application_customers.credit_auth_signed` | — | Flag if credit not authorized |
| 19.2 | Click **[Send Document Request & Disclosures]** | MLO | INSERT `communications`; INSERT `documents` (one per disclosure); INSERT `tasks` for borrower; SET `applications.initial_disclosures_sent_at` | TRID 3-day clock starts | Email to borrower with doc request; notification to Processor |
| 21.3 | Click **[Send]** (final send) | MLO | Execute email delivery; notify additional users | Documents dispatched | Additional user (Processor) notified |
| 24.2 | Verify credit report | MLO | Check `credit_reports.min_score`; verify `application_customers.credit_score` populated | Credit data available | — |
| 24.3 | Set qualifying income type | MLO | UPDATE `employments.employment_type`; verify `incomes` totals | Income qualified | — |

### Automation Rules

- **TRID Timer**: On `applications.initial_disclosures_sent_at` SET, start 3-business-day countdown. Block closing actions until timer expires.
- **CRM → LOS Sync**: When CRM stage = `converted`, trigger Supabase function to create `applications` row and link `customers` record.
- **Credit Pull**: On `credit_auth_signed = true` AND fee paid, auto-enable "Order Credit" button in Encompass.
- **Auto-Assignment**: On application submission, auto-assign `assigned_lo_id` based on CRM Record Owner mapping.

---

## 4. Compliance Notes

| Regulation | Requirement | Current Status |
|---|---|---|
| **TRID / Reg Z** | Initial disclosures (LE) within 3 business days of application receipt | 🔴 MISSING — `initial_disclosures_sent_at` proposed. No timer mechanism exists. |
| **TRID / Reg Z** | If delivered by mail, add 3 calendar days to waiting period | 🔴 MISSING — `disclosures_delivery_method` proposed to calculate correct waiting period |
| **FCRA** | Credit report can only be pulled after explicit written authorization | 🟡 PARTIAL — `credit_auth_signed` proposed in 02_Application_1003; no hard block in current system |
| **TCPA** | Do Not Call list must be checked before phone outreach | ✅ OK — CRM has "Do Not Call" field (Salesforce-side enforcement) |
| **CAN-SPAM** | Email Opt Out must be respected | ✅ OK — CRM has "Email Opt Out" field |
| **ECOA / Reg B** | Must send adverse action notice within 30 days of application receipt | ⚠️ Not handled in this stage — belongs to Underwriting decisioning |
| **HMDA** | Demographic data collection required at or before application | ✅ OK — `demographics` table exists |

---

## 5. MoXi-Specific Customizations

| Feature | Description | Isolation Strategy |
|---|---|---|
| Salesforce/Jungo CRM | MoXi uses Salesforce with Jungo overlay for mortgage CRM | `external_crm_id` and `crm_stage` are generic; any CRM can populate them |
| $350K vs $550K Threshold Discrepancy | SOP Stage 4 says "$350K" but lead form (01_Lead_Capture) says "$550K" — likely outdated CRM field | 🟡 Needs clarification from MoXi team; schema uses single `pre_qual_property_threshold` boolean |
| "MoXi Discovery Session" | Brand-specific discovery call name | Content/CRM config; no schema impact |
| "Consumer Connect" Portal | MoXi/Encompass borrower portal; other orgs may use different portals | `applications.key_information` JSONB can store portal type if needed |
| Email Subject Line Branding | "MoXi - A Global Mortgage Company" in subject | Email template configuration; no schema impact |
| Credit Vendor: SARMA | MoXi uses SARMA for tri-merge credit reports | `credit_reports.vendor` enum includes `sarma`; extensible for other vendors |
