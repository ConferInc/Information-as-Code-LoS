---
type: engineering-requirements
title: Encompass Feature Parity — confer-web Implementation Requirements
date: 2026-02-13
target: apps/confer-web/
source_data: 69 documented pain points from 6 MoXi SOP transcripts
goal: 95%+ Encompass feature parity with modern UX improvements
---

# Encompass Feature Parity — Engineering Requirements

> This document translates every documented Encompass pain point into actionable engineering requirements for the `apps/confer-web/` Next.js application. Each requirement specifies the Encompass feature being replicated, the friction it causes, and the exact `confer-web` implementation needed to match and exceed it.

---

## 1. Missing UI Components

### 1.1 Unified Loan Dashboard (Pipeline View)

**Encompass Feature:** Pipeline grid view showing all loans with borrower name, milestone badge, and file status. Opens individual loans via double-click, but spawns a new window.

**`confer-web` Implementation:**
- **Component:** `apps/confer-web/src/components/pipeline/LoanPipeline.tsx`
- **Type:** Server Component with client-side filtering
- **Requirements:**
  - Filterable/sortable data table (use `@tanstack/react-table` or similar)
  - Columns: Loan Number, Borrower Name, Stage (badge), Status (badge), Assigned LO, Assigned Processor, Last Updated, Days in Stage
  - Click-to-open navigates via Next.js router (no new window) to `/loans/[id]`
  - Real-time status updates via Supabase Realtime subscriptions
  - Keyboard navigation (arrow keys, Enter to open)
- **Priority:** HIGH

### 1.2 Split-Pane Document Verification Screen

**Encompass Feature:** Separate windows for document viewing (E-Folder/File Viewer) and data forms (Borrower Information). Forces stare-and-compare across windows.

**`confer-web` Implementation:**
- **Component:** `apps/confer-web/src/components/verification/SplitPaneVerifier.tsx`
- **Type:** Client Component with resizable panes
- **Requirements:**
  - Left pane: PDF/image viewer (`react-pdf` or `@react-pdf-viewer/core`) displaying uploaded documents
  - Right pane: Corresponding form fields from the relevant section (borrower info, income, assets, etc.)
  - AI-extracted values highlighted in the document with matching form fields highlighted on the right
  - "Accept AI Extraction" button to auto-fill fields from parsed document data
  - "Flag Discrepancy" button to create a condition/task when document doesn't match
  - Resizable split via drag handle
  - Document navigation (prev/next) without leaving the split view
- **Priority:** HIGH

### 1.3 Borrower Application Wizard (Consumer Portal)

**Encompass Feature:** Consumer Connect Portal with 9+ tabs (Purpose, Summary, Assets, Liabilities, E&O Consent, Declarations, Personal Info, Expenses). Requires 11 navigation clicks. Account creation requires separate credentials.

**`confer-web` Implementation:**
- **Component:** `apps/confer-web/src/app/(portal)/apply/page.tsx`
- **Type:** Multi-step wizard with progress indicator
- **Requirements:**
  - Single-page wizard with step indicator (not separate tabs/pages)
  - Steps: Personal Info → Employment → Property → Assets → Liabilities → Declarations → Demographics → Review → Submit
  - Auto-save on every field change (debounced 500ms)
  - Progress bar showing completion percentage
  - Section validation before advancing (real-time, not end-of-form)
  - Magic link authentication (no username/password creation)
  - Mobile-responsive design
  - SSN field: mask all but last 4; send full SSN to vault API (never Supabase)
- **Priority:** HIGH

### 1.4 Document Upload Zone

**Encompass Feature:** File upload via "LOCAL DRIVE" click → OS file explorer → select → Open → progress bar. 7 steps per document. Upload widget that showed "0 Documents Uploaded" after 8 clicks.

**`confer-web` Implementation:**
- **Component:** `apps/confer-web/src/components/documents/DocumentUploadZone.tsx`
- **Type:** Client Component
- **Requirements:**
  - Drag-and-drop zone with `react-dropzone`
  - Multi-file upload (select multiple files at once)
  - Instant progress feedback per file (upload percentage, checkmark on success)
  - Auto-categorization: AI classifies uploaded document type (pay stub, tax return, bank statement, DL, etc.)
  - Thumbnail preview for images; first-page preview for PDFs
  - Retry on failure with clear error message
  - Document version tracking (re-upload replaces previous version with history)
  - Category containers matching portal task list (Income, Assets, Identity, Property)
- **Priority:** HIGH

### 1.5 Conditions Management Board

**Encompass Feature:** "Add Condition" modal with dropdown + text field + Apply button. 4 steps per condition. No auto-creation from UW decisions. Manual message composition to request conditions from borrowers.

**`confer-web` Implementation:**
- **Component:** `apps/confer-web/src/components/conditions/ConditionsBoard.tsx`
- **Type:** Client Component (Kanban-style board)
- **Requirements:**
  - Kanban columns: Open → Received → Under Review → Cleared / Waived
  - Drag-and-drop to change status
  - Quick-add: inline text input to add condition (no modal required)
  - Category filter: Prior-to-Docs, Prior-to-Funding, Prior-to-Closing, Post-Closing
  - Auto-creation: When UW renders "Suspend" decision, auto-populate conditions from decision notes
  - Borrower notification: "Send to Borrower" button auto-generates a structured message listing all open conditions with upload links
  - Document linking: When borrower uploads a document, suggest which condition it satisfies
  - Counter badge: total open / total conditions
- **Priority:** HIGH

### 1.6 Fee Collection & Payment Dashboard

**Encompass Feature:** Fee Collection buried behind 3 clicks (Fee Collection menu → Fee Collection - Mortgage sub-menu → Fee Collection - Mortgage again). Payment via external portal requiring manual re-entry of borrower name, email, and loan number.

**`confer-web` Implementation:**
- **Component:** `apps/confer-web/src/components/fees/FeePaymentDashboard.tsx`
- **Type:** Client Component
- **Requirements:**
  - Fee schedule table: Type, Amount, Status (Pending/Collected/Refunded), Method, Date, Proof
  - Integrated Stripe payment link generation (no external portal)
  - Auto-populate borrower info in payment flow (name, email, loan number from application context)
  - Wire verification workflow: Mark wire as expected → Upload proof → Mark confirmed
  - Credit card authorization: Digital form with e-signature (stored as document, card number tokenized via Stripe)
  - Fee gate enforcement: Block credit ordering until credit report fee is collected
- **Priority:** HIGH

### 1.7 Processing Workbook (Checklist + 5-C Narratives)

**Encompass Feature:** Processing Workbook accessed via Forms list. Separate sections for borrower info review, housing expense verification, document cross-reference, purchase contract review, and "Tell the Story" 5-C narratives. All manual checkbox/dropdown verification.

**`confer-web` Implementation:**
- **Component:** `apps/confer-web/src/components/processing/ProcessingWorkbook.tsx`
- **Type:** Client Component with collapsible sections
- **Requirements:**
  - Checklist with auto-completion: Sections auto-mark as complete when underlying data validates
    - Borrower Info Complete: checks all required `customers` fields populated
    - 24-Month Address History: checks sum of `residences` durations >= 24 months
    - Housing Expenses Verified: checks `real_estate_owned` fields match uploaded mortgage statement
    - Documents Cross-Referenced: checks all `documents` have `status = 'reviewed'`
    - Purchase Contract Reviewed: checks `properties.purchase_price` populated
  - 5-C Narrative editor: Rich text editors for Character, Capacity, Capital, Collateral, Conditions
  - "All Green Checks" status bar at top
  - Enable/disable "Submit to UW" button based on checklist completion
- **Priority:** MEDIUM

### 1.8 Underwriting Decision Panel

**Encompass Feature:** UW-1A form (opens new window), Fraud File button, Reviewable checkbox column, Approve/Suspend/Deny buttons, Generate Approval Letter button. All in separate screens.

**`confer-web` Implementation:**
- **Component:** `apps/confer-web/src/components/underwriting/DecisionPanel.tsx`
- **Type:** Client Component with role-based access (UW only)
- **Requirements:**
  - Loan summary header: Borrower, Property, LTV, DTI, FICO, Loan Amount (read-only)
  - Tabbed review sections (all in-page, no new windows):
    - Credit Analysis (scores, trade lines, derogatory items)
    - Income & Employment (qualification summary, DTI calculation)
    - Assets & Reserves (reserve months calculation)
    - Fraud Report (embedded PDF viewer)
    - Declarations (flagged items highlighted)
    - 5-C Narratives (from Processing Workbook)
  - Decision buttons: Approve (green) / Conditionally Approve (yellow) / Suspend (orange) / Deny (red)
  - On Suspend/Deny: Required text field for reason
  - On Suspend: Inline condition creation (conditions auto-created)
  - ECOA adverse action timer: auto-starts on Deny
  - HMDA action taken: auto-populated from decision
  - Generate Approval Letter: one-click PDF generation stored in documents
- **Priority:** HIGH

### 1.9 Closing Disclosure Worksheet

**Encompass Feature:** "Est Closing" dropdown → "Cash to Close" → "Calculate Cash to Close" button → "Post" button → document selection → "Add to Post" → new window for each step.

**`confer-web` Implementation:**
- **Component:** `apps/confer-web/src/components/closing/CDWorksheet.tsx`
- **Type:** Client Component
- **Requirements:**
  - Live cash-to-close calculator that updates as any input changes
  - Closing cost line items editor (CFPB categories A-H)
  - LE vs CD comparison table (auto-calculated variance with tolerance flagging)
  - TRID timer: visual countdown showing days remaining before closing is allowed
  - One-click CD generation as PDF
  - One-click "Send to Borrower" with delivery method selection (eSign/mail/in-person) and automatic `cd_sent_at` timestamp
  - Signing session initiation integrated (no separate workflow)
- **Priority:** HIGH

### 1.10 Disbursement Manager

**Encompass Feature:** "Loan Payment" tab → ledger view → "Copy Payments to Itemization" → manual verification against bank spreadsheets. Seller's remit via separate email. No standardized disbursement format.

**`confer-web` Implementation:**
- **Component:** `apps/confer-web/src/components/closing/DisbursementManager.tsx`
- **Type:** Client Component
- **Requirements:**
  - Disbursement table: Payee, Type, Amount, Wire Instructions, Status
  - Balance indicator: shows running total vs expected (must balance to $0)
  - Wire instruction templates per escrow company (configurable, no manual formatting)
  - Dual-authorization workflow: Preparer creates → Approver confirms (enforced when amount > threshold)
  - Wire status tracking: Pending → Sent → Confirmed
  - "Send Instructions" button generates email with wire details (internal, no Gmail)
  - Funding confirmation: When all wires confirmed, auto-advance application to `funded`
- **Priority:** MEDIUM

---

## 2. Automated Parsing Workflows

### 2.1 AI Document Extraction Pipeline

**Encompass Limitation:** Zero document parsing. Every value from every uploaded document must be manually read and typed into form fields. Processors spend entire sessions opening PDFs, reading values, and re-typing them.

**Temporal / Agentic Fix:**
- **Workflow:** `temporal/workflows/document-extraction.ts`
- **Trigger:** `documents` INSERT (any new upload via portal or internal)
- **Activities:**
  1. `classifyDocument`: AI classifies document type (pay stub, W2, tax return, bank statement, DL, etc.)
  2. `extractFields`: AI extracts key-value pairs from document based on type
  3. `mapToSchema`: Map extracted fields to Supabase table/column targets
  4. `createSuggestions`: Create suggested field updates (not auto-applied — processor reviews)
  5. `notifyProcessor`: Push notification to processor with extraction results
- **AI Model:** Claude for document understanding; OCR pre-processing for scanned documents
- **Output:** `document_extractions` table with `field_name`, `extracted_value`, `confidence`, `status` (suggested/accepted/rejected)
- **Priority:** HIGH

### 2.2 Credit Report Auto-Import

**Encompass Limitation:** Credit report PDF appears in E-Folder but liabilities must be manually mapped to the 1003. Scores must be manually verified. No automated liability creation from credit data.

**Temporal / Agentic Fix:**
- **Workflow:** `temporal/workflows/credit-report-import.ts`
- **Trigger:** `credit_reports` INSERT with `status = 'received'`
- **Activities:**
  1. `parseCreditReport`: Extract all trade lines, scores, inquiries from credit report data (XML or PDF)
  2. `createLiabilities`: Auto-INSERT `liabilities` rows from trade lines (creditor, balance, payment, type)
  3. `updateScores`: UPDATE `application_customers` with bureau scores and `credit_reports` with min/mid
  4. `flagDerogatory`: Create `underwriting_conditions` for any derogatory items (lates, collections, judgments)
  5. `generateSummary`: Create a human-readable credit summary in `notes`
- **Priority:** HIGH

### 2.3 Automated Fee Gate Enforcement

**Encompass Limitation:** No enforcement. Processor manually checks whether fee was paid and credit was authorized before ordering credit reports. If they forget, the pull happens anyway.

**Temporal / Agentic Fix:**
- **Workflow:** `temporal/workflows/service-order-gate.ts`
- **Trigger:** Any service order attempt (credit pull, appraisal, fraud report)
- **Activities:**
  1. `checkFeePayment`: Query `fee_payments` WHERE `application_id = ? AND fee_type = ? AND status = 'collected'`
  2. `checkAuthorization`: Query `application_customers.credit_auth_signed = true`
  3. `gate`: If both pass, proceed. If either fails, return error with specific missing prerequisite.
- **Priority:** HIGH

### 2.4 TRID Timer Automation

**Encompass Limitation:** No automated TRID timer. Processors manually track the 3-business-day waiting periods for Loan Estimate and Closing Disclosure delivery.

**Temporal / Agentic Fix:**
- **Workflow:** `temporal/workflows/trid-timer.ts`
- **Triggers:**
  - `applications.initial_disclosures_sent_at` UPDATE (LE timer)
  - `applications.cd_sent_at` UPDATE (CD timer)
- **Activities:**
  1. `calculateEligibleDate`: Based on delivery method (eSign=3 biz days, mail=3 biz days + 3 calendar days, in-person=same day)
  2. `scheduleGate`: Block closing/funding actions until eligible date
  3. `sendReminders`: 1-day-before reminder to closer
  4. `releaseGate`: On eligible date, update `applications` to allow closing/funding
- **Priority:** HIGH (CRITICAL compliance)

### 2.5 ECOA Adverse Action Timer

**Encompass Limitation:** No tracking of denial-to-adverse-action timeline. 30-day ECOA requirement is manually managed (or missed).

**Temporal / Agentic Fix:**
- **Workflow:** `temporal/workflows/adverse-action-timer.ts`
- **Trigger:** `uw_decisions` INSERT WHERE `decision = 'denied'`
- **Activities:**
  1. `startTimer`: Record denial date, calculate 30-day deadline
  2. `sendEscalation`: At day 20, alert compliance officer if `adverse_action_sent_at` is NULL
  3. `sendUrgentAlert`: At day 27, urgent escalation
  4. `generateNotice`: Auto-generate adverse action notice letter from denial reason
- **Priority:** HIGH (CRITICAL compliance)

### 2.6 Automated Condition Matching

**Encompass Limitation:** Processor manually checks if uploaded documents satisfy outstanding conditions. No linking between document uploads and open conditions.

**Temporal / Agentic Fix:**
- **Workflow:** `temporal/workflows/condition-matcher.ts`
- **Trigger:** `documents` INSERT WHERE `upload_source = 'borrower_portal'`
- **Activities:**
  1. `classifyDocument`: Identify document type from AI extraction
  2. `matchConditions`: Query `underwriting_conditions` WHERE `application_id = ? AND status = 'open'` and match by keyword/type
  3. `suggestMatch`: Suggest which condition(s) the document satisfies
  4. `updateStatus`: On processor approval, UPDATE `underwriting_conditions.status = 'received'` and link `document_id`
  5. `checkAllClear`: If all conditions cleared/waived, fire `conditions_cleared` event
- **Priority:** MEDIUM

### 2.7 UW Portal Submission Automation

**Encompass Limitation:** 14-step manual export-upload process. MISMO XML export hidden behind 3-level right-click menu. Manual folder creation, file naming, and upload to Evolve portal.

**Temporal / Agentic Fix:**
- **Workflow:** `temporal/workflows/uw-submission.ts`
- **Trigger:** Processor clicks "Submit to Underwriting" in `confer-web`
- **Activities:**
  1. `generateMISMO`: Export loan data as MISMO 3.4 XML from Supabase
  2. `validateExport`: Check all required MISMO fields are populated; return errors if not
  3. `submitToPortal`: API call to Evolve/DU/LPA with XML payload
  4. `trackStatus`: Poll portal for processing status until accepted/rejected
  5. `updateApplication`: On acceptance, UPDATE `uw_submissions.status` and advance stage
- **Priority:** MEDIUM

### 2.8 Smart Notification Router

**Encompass Limitation:** Two separate notification systems: "Send Message" window and "Notify via Email" window. 6+ clicks and two modal windows to notify one person. Emails composed in external Gmail.

**Temporal / Agentic Fix:**
- **Workflow:** `temporal/workflows/notification-router.ts`
- **Trigger:** Any application event (status change, document upload, condition update, etc.)
- **Activities:**
  1. `determineRecipients`: Based on event type, identify who needs to know (borrower, MLO, processor, UW, closer)
  2. `selectChannels`: Based on user preferences (`notification_preferences` table), choose email/SMS/in-app
  3. `renderTemplate`: Generate message from event data + template
  4. `dispatch`: Send via configured channel (Resend for email, Twilio for SMS, Supabase Realtime for in-app)
  5. `logCommunication`: INSERT into `communications` for audit trail
- **Priority:** MEDIUM

---

## 3. Infrastructure & Integration Requirements

### 3.1 Integrated Email System

**Encompass Gap:** All borrower emails sent via Gmail. No in-LOS email capability.

**`confer-web` Requirement:**
- Email composition component in-app (`apps/confer-web/src/components/communications/EmailComposer.tsx`)
- Rich text editor with template selection
- Attachment support (pull from `documents` table)
- Sent emails auto-logged in `communications` table
- Provider: Resend or AWS SES
- **Priority:** HIGH

### 3.2 Integrated Payment Processing

**Encompass Gap:** External payment portal with redundant data entry.

**`confer-web` Requirement:**
- Stripe Elements integration for PCI-compliant card collection
- Pre-filled payment form (borrower name, email, loan number from context)
- Wire instruction management (template per escrow company)
- Payment status webhooks auto-update `fee_payments` table
- **Priority:** HIGH

### 3.3 CRM Integration Layer

**Encompass Gap:** Salesforce/Jungo is a separate system. Leads created in CRM must be manually bridged to Encompass.

**`confer-web` Requirement:**
- Built-in lead management (or Salesforce webhook sync)
- `customers.external_crm_id` for bi-directional sync
- Lead → Application conversion with single click
- Lead source tracking and pipeline reporting
- **Priority:** MEDIUM

### 3.4 E-Signing Integration

**Encompass Gap:** Signing sessions managed via Simplifile with email links. "Leave Session" triggers sync back to Encompass (critical failure point if missed).

**`confer-web` Requirement:**
- DocuSign or Dropbox Sign API integration
- Signing session tracking in `signing_sessions` table
- Auto-sync: signed documents auto-appear in loan file (no manual "Leave Session" required)
- Signing progress visible in loan dashboard
- **Priority:** MEDIUM

### 3.5 Document AI Infrastructure

**Encompass Gap:** Zero document intelligence. Every document is a dumb file.

**`confer-web` Requirement:**
- OCR pipeline for scanned documents (Tesseract or cloud OCR)
- Claude API integration for document understanding
- `document_extractions` table for suggested field mappings
- Processor review queue for AI suggestions
- Confidence thresholds: auto-apply above 95%, suggest below 95%, flag below 70%
- **Priority:** HIGH

---

## 4. UI/UX Patterns to Enforce

### 4.1 No New Windows (Ever)

**Encompass Problem:** 11 documented new-window spawns.

**Rule:** All navigation happens via Next.js router within a single browser tab. Use slide-over panels (`Sheet` component) for secondary content. Use modals only for confirmations.

### 4.2 Pre-Validation on All Forms

**Encompass Problem:** Errors only shown at final submission.

**Rule:** Every form field validates on blur. Every submit/generate/print action runs a pre-flight check showing all incomplete required fields before attempting the action.

### 4.3 Bulk Actions on All Lists

**Encompass Problem:** 13+ one-by-one checkbox clicks for document review.

**Rule:** Every list/table has: select-all checkbox, bulk status change, bulk category assignment. Category-level actions ("Review All Income Docs").

### 4.4 Contextual Quick Actions

**Encompass Problem:** Core functions hidden behind right-click menus (3-level deep).

**Rule:** Primary actions are always visible as buttons. Secondary actions in a "..." dropdown menu. No right-click menus for core functionality.

### 4.5 Single Data Entry

**Encompass Problem:** Same data entered in 2-3 different forms.

**Rule:** Data entered once in `customers`, `employments`, `residences`, etc. Downstream forms auto-populate via React context/hooks reading from the same Supabase record.

### 4.6 Mobile-First Borrower Portal

**Encompass Problem:** Desktop-only portal with 7-step upload process per file.

**Rule:** Borrower-facing components must be mobile-responsive. Document upload via camera capture on mobile. Single-tap actions for common tasks.

---

## 5. Feature Parity Scorecard

| Encompass Feature | Pain Point Count | `confer-web` Component | Status | Priority |
|---|---|---|---|---|
| Pipeline View | 2 | `LoanPipeline.tsx` | TO BUILD | HIGH |
| Document Verification (Split Pane) | 6 | `SplitPaneVerifier.tsx` | TO BUILD | HIGH |
| Application Wizard (1003) | 3 | `apply/page.tsx` | TO BUILD | HIGH |
| Document Upload | 4 | `DocumentUploadZone.tsx` | TO BUILD | HIGH |
| Conditions Management | 4 | `ConditionsBoard.tsx` | TO BUILD | HIGH |
| Fee Collection | 3 | `FeePaymentDashboard.tsx` | TO BUILD | HIGH |
| Processing Workbook | 5 | `ProcessingWorkbook.tsx` | TO BUILD | MEDIUM |
| UW Decision Panel | 3 | `DecisionPanel.tsx` | TO BUILD | HIGH |
| CD Worksheet | 4 | `CDWorksheet.tsx` | TO BUILD | HIGH |
| Disbursement Manager | 4 | `DisbursementManager.tsx` | TO BUILD | MEDIUM |
| Email System | 3 | `EmailComposer.tsx` | TO BUILD | HIGH |
| Payment Processing | 2 | Stripe integration | TO BUILD | HIGH |
| Document AI | 8 | Temporal workflows | TO BUILD | HIGH |
| TRID Timer | 3 | Temporal workflow | TO BUILD | HIGH |
| ECOA Timer | 2 | Temporal workflow | TO BUILD | HIGH |
| Credit Import | 2 | Temporal workflow | TO BUILD | HIGH |
| Notification Router | 3 | Temporal workflow | TO BUILD | MEDIUM |
| UW Submission | 2 | Temporal workflow | TO BUILD | MEDIUM |
| Condition Matching | 2 | Temporal workflow | TO BUILD | MEDIUM |
| **TOTAL** | **69 pain points** | **19 components/workflows** | — | — |

---

## 6. Implementation Priority Order

### Sprint 1: Core CRUD + Pipeline
1. `LoanPipeline.tsx` — Pipeline view
2. `apply/page.tsx` — Borrower application wizard
3. `DocumentUploadZone.tsx` — Document upload
4. Stripe integration — Fee payment

### Sprint 2: Processing Workflow
5. `SplitPaneVerifier.tsx` — Document verification
6. `ProcessingWorkbook.tsx` — Processing checklist
7. `FeePaymentDashboard.tsx` — Fee management
8. `EmailComposer.tsx` — Internal email system
9. Document extraction Temporal workflow

### Sprint 3: Underwriting + Compliance
10. `DecisionPanel.tsx` — UW decision
11. `ConditionsBoard.tsx` — Conditions management
12. Credit report import Temporal workflow
13. TRID timer Temporal workflow
14. ECOA timer Temporal workflow
15. Fee gate Temporal workflow

### Sprint 4: Closing + Funding
16. `CDWorksheet.tsx` — Closing Disclosure
17. `DisbursementManager.tsx` — Funding
18. UW submission Temporal workflow
19. Notification router Temporal workflow
20. Condition matching Temporal workflow
