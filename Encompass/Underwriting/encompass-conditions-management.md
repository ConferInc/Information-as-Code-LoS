---
type: technical-documentation
module: Underwriting
section: Conditions & Requirements
subsection: Conditions Management Board
source: SOP analysis + Encompass documentation
last_updated: 2026-02-13
---

# Encompass: Conditions Management

## Overview

Conditions are outstanding requirements that must be satisfied before a loan can progress to the next stage (e.g., "Provide recent pay stub", "Upload homeowner's insurance") [file:1][file:7]. Encompass manages conditions through a combination of the UW-1A form, a dedicated Conditions tab, and manual tracking [file:7].

## Section 1: Condition Lifecycle

### Stages of a Condition

| Stage | Status | Description | Who Acts |
|-------|--------|-------------|----------|
| **Created** | Open | Condition created by UW, processor, or system | UW |
| **Assigned** | Open | Condition assigned to borrower or processor | Processor |
| **Requested** | Open | Borrower notified to upload document | Processor |
| **Received** | Received | Borrower uploaded document, pending review | Processor/UW |
| **Under Review** | Under Review | Processor/UW reviewing document | Processor/UW |
| **Cleared** | Cleared | Condition satisfied, requirement met | UW |
| **Waived** | Waived | Condition no longer required (rare) | UW |

### Condition Categories [file:1]

| Category | Timing | Description | Examples |
|----------|--------|-------------|----------|
| **Prior-to-Docs** | Before loan docs | Must be cleared before generating closing docs | Final pay stub, proof of insurance, gift letter |
| **Prior-to-Funding** | Before money disbursed | Must be cleared before funding loan | Signed closing docs, final walkthrough, clear title |
| **Prior-to-Closing** | Before closing meeting | Must be cleared before closing appointment | HOA approval, final appraisal, down payment wire |
| **Post-Closing** | After closing | Cleared after loan funded (rare) | Final utility bill, occupancy certification |

## Section 2: Current Encompass Workflow

### Add Condition (Manual 4-Step Process) [file:7]

**SOP Evidence [file:7]:**
```
[60:32] Click [Add Condition]
System Result: A dropdown menu appears for selecting the condition type

[60:35] Select [Loan Status] from the dropdown menu
System Result: The dropdown closes, and the loan status field becomes active

[60:45] Type "Closed" into [Loan Status]
System Result: The text "Closed" is entered into the loan status field

[60:50] Click [Apply]
System Result: The screen transitions back to the Conditions Viewer, 
displaying a single row with the condition "Loan Status = Closed"
```

**Pain Point [file:1]:**
"Add Condition modal with dropdown + text field + Apply button. 4 steps per condition. No auto-creation from UW decisions. Manual message composition to request conditions from borrowers."

**Step-by-Step Breakdown:**

**Step 1: Open Add Condition Modal**
- Navigate to Conditions tab
- Click **[Add Condition]** button [file:7]
- Modal window opens

**Step 2: Select Condition Type**
- Dropdown menu with 50+ condition types:
  - Income Verification
  - Asset Verification
  - Credit Explanation
  - Insurance
  - Title/Escrow
  - Property
  - Employment
  - Gift Funds
  - Other
- Select category (e.g., "Income Verification") [file:7]

**Step 3: Type Condition Description**
- Text field appears
- Type specific requirement: "Provide most recent pay stub dated within 30 days of closing" [file:7]
- No spell check, no formatting

**Step 4: Click Apply**
- Click **[Apply]** button [file:7]
- Modal closes
- New condition appears in list

**Time Cost:** 1-2 minutes per condition × 5-10 conditions per loan = 5-20 minutes per loan

### View Conditions List

**Current Interface:**
- Simple table view with columns:
  - **Condition Description**
  - **Category** (Prior-to-Docs, Prior-to-Funding, etc.)
  - **Status** (Open, Received, Cleared, Waived)
  - **Assigned To** (Borrower, Processor, Third-Party)
  - **Date Created**
  - **Date Cleared**

**Limitations:**
- No visual grouping by status (all conditions in one flat list)
- No drag-and-drop status changes (must edit each condition manually)
- No bulk actions (can't mark multiple conditions as cleared at once)
- No document linking (can't see which uploaded doc satisfies condition)

## Section 3: Request Conditions from Borrower

### Manual Email Composition [file:1][file:7]

**SOP Evidence [file:7]:**
```
[53:26] Click [Send] in the Borrower tab
System Result: A new window titled "Send Message" opens

[53:30] Select [Recipient's Name] from the dropdown menu in the Send Message window
System Result: The recipient's name is selected

[53:35] Type "Please upload the following conditions" into [Message Body]
System Result: The message body is filled with the text

[53:45] Click [Send] in the Send Message window
System Result: The message is sent to the borrower
```

**Pain Point [file:1]:**
"Manual message composition to request conditions from borrowers."

**Manual Workflow:**
1. Processor creates 5 conditions in Conditions tab (4 clicks × 5 = 20 clicks)
2. Processor manually composes email listing all 5 conditions [file:7]
3. Processor manually copies condition descriptions into email body [file:7]
4. Processor sends email via Encompass "Send Message" window (separate modal) [file:7]
5. Borrower receives plain-text email with no upload links
6. Borrower must separately log into Consumer Connect Portal
7. Borrower uploads documents (hoping they match conditions)
8. Processor manually checks if uploaded docs satisfy conditions

**Time Cost:** 10-15 minutes per condition request email

## Section 4: Proposed Kanban-Style Conditions Board [file:1]

### Modern Drag-and-Drop Interface

**confer-web Implementation [file:1]:**
```
Component: apps/confer-web/src/components/conditions/ConditionsBoard.tsx
Type: Client Component (Kanban-style board)

Requirements:
- Kanban columns: Open → Received → Under Review → Cleared → Waived
- Drag-and-drop to change status
- Quick-add: inline text input to add condition (no modal required)
- Category filter: Prior-to-Docs, Prior-to-Funding, Prior-to-Closing, Post-Closing
- Auto-creation: When UW renders "Suspend" decision, auto-populate conditions 
  from decision notes
- Borrower notification: "Send to Borrower" button auto-generates a structured 
  message listing all open conditions with upload links
- Document linking: When borrower uploads a document, suggest which condition 
  it satisfies
- Counter badge: total open / total conditions
- Priority: HIGH
```

### Visual Example

```
┌─────────────────────────────────────────────────────────────────────┐
│  Conditions Board - Loan #123456          [5 Open / 8 Total]        │
│  Filter: [Prior-to-Docs ▼]  [+ Quick Add Condition]                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  OPEN (3)       │  RECEIVED (2)  │  UNDER REVIEW (1) │  CLEARED (2) │
│  ──────────     │  ────────────  │  ───────────────  │  ──────────  │
│                 │                │                   │              │
│  📄 Final pay   │  📄 Insurance  │  📄 Gift letter   │  ✅ Credit   │
│  stub           │  declaration   │                   │  report      │
│  Prior-to-Docs  │  Prior-to-Docs │  Prior-to-Docs    │  Prior-to-   │
│  Created: 2/10  │  Received: 2/12│  Received: 2/11   │  Docs        │
│                 │                │  Reviewing...     │  Cleared:    │
│                 │                │                   │  2/9         │
│  📄 Proof of    │  📄 Final      │                   │              │
│  judgment       │  walkthrough   │                   │  ✅ VOE      │
│  payoff         │                │                   │  Cleared:    │
│  Prior-to-Docs  │  Prior-to-     │                   │  2/8         │
│  Created: 2/10  │  Funding       │                   │              │
│                 │  Received: 2/13│                   │              │
│  📄 Additional  │                │                   │              │
│  $10K reserves  │                │                   │              │
│  Prior-to-Docs  │                │                   │              │
│  Created: 2/10  │                │                   │              │
│                 │                │                   │              │
└─────────────────┴────────────────┴───────────────────┴──────────────┘
```

### Quick-Add Condition (No Modal) [file:1]

**Current: 4 clicks** (modal → dropdown → text field → apply) [file:7]
**Proposed: 1 action** (inline text input)

**Example:**
1. Processor types directly in "Quick Add" field: "Provide most recent pay stub"
2. Press **Enter**
3. Condition auto-created in "Open" column with category "Prior-to-Docs" (default)
4. Processor can change category via dropdown if needed

**Time Saved:** 1 minute per condition

## Section 5: Auto-Creation from UW Decisions [file:1]

### Suspend Decision → Auto-Populate Conditions

**Proposed Workflow [file:1]:**
1. Underwriter clicks **[Suspend]** in UW-1A form
2. Modal: "Reason for suspension" (required text field)
3. Underwriter types: 
   ```
   Need proof of judgment payoff and additional reserves. 
   Also need final pay stub.
   ```
4. System parses reason using AI (Claude) → Extracts 3 conditions:
   - "Provide proof of $5,000 judgment payment or payoff"
   - "Provide additional $10,000 in liquid reserves"
   - "Provide final pay stub dated within 30 days of closing"
5. System auto-creates 3 conditions in Conditions Board → "Open" column
6. System auto-assigns conditions to processor
7. Processor receives notification: "Loan #123456 suspended. 3 conditions auto-created. Review now."

**Current Manual Workflow:**
- Underwriter types suspension reason in UW-1A
- Processor must read suspension reason
- Processor manually opens Conditions tab
- Processor manually creates 3 conditions (4 clicks × 3 = 12 clicks)
- Processor manually composes email to borrower

**Time Saved:** 10-15 minutes per suspension

## Section 6: Borrower Notification with Upload Links [file:1]

### Send to Borrower Button

**Proposed Feature [file:1]:**
"Borrower notification: 'Send to Borrower' button auto-generates a structured message listing all open conditions with upload links."

**Example Email:**

```
Subject: Action Required - Loan #123456 Conditions

Dear Laylene Jeune,

Your loan application (#123456) has been conditionally approved! 
To proceed to closing, please upload the following documents:

1. Final pay stub dated within 30 days of closing
   → Upload here: https://portal.confer.com/loans/123456/upload?condition=1

2. Proof of $5,000 judgment payment or payoff
   → Upload here: https://portal.confer.com/loans/123456/upload?condition=2

3. Additional $10,000 in liquid reserves (bank statement)
   → Upload here: https://portal.confer.com/loans/123456/upload?condition=3

Each upload link will automatically match your document to the condition.

Questions? Reply to this email or call us at (555) 123-4567.

Best regards,
[Processor Name]
```

**Benefits:**
- Borrower clicks link → Auto-directs to upload page for that specific condition
- System knows which condition each document satisfies (no manual matching)
- Processor receives notification when all conditions received

**Current Manual Workflow [file:7]:**
- Processor types plain-text email listing conditions [file:7]
- No upload links → Borrower must navigate to portal manually
- Borrower uploads documents → Processor manually checks which condition each doc satisfies

**Time Saved:** 5-10 minutes per borrower notification

## Section 7: Document Linking & Automated Matching [file:1]

### When Borrower Uploads Document

**Proposed Workflow [file:1]:**
1. Borrower clicks upload link for "Final pay stub" condition
2. Borrower uploads file: "Pay_Stub_Jan2026.pdf"
3. System triggers `condition-matcher.ts` Temporal workflow [file:1]:
   - **Activity 1:** Classify document → "Pay Stub, dated 01/31/2026"
   - **Activity 2:** Match conditions → Open condition = "Final pay stub dated within 30 days of closing"
   - **Activity 3:** Suggest match → "This document satisfies condition #1"
   - **Activity 4:** Auto-update condition status → "Received"
   - **Activity 5:** Notify processor → "Condition #1 received. Review document."
4. Processor reviews document → Clicks **[Approve Match]**
5. Condition status → "Cleared"
6. System checks: All conditions cleared? → If yes, advance loan to "Clear to Close"

**Current Manual Workflow:**
- Borrower uploads document (no link to specific condition)
- Document appears in E-Folder
- Processor must manually check which condition document satisfies
- Processor manually updates condition status from "Open" to "Received"
- Processor reviews document → Manually updates condition status to "Cleared"

**Time Saved:** 5-10 minutes per uploaded document

### Document Linking UI [file:1]

**Visual Example:**

```
┌─────────────────────────────────────────────────────────────┐
│  Condition #1: Final pay stub dated within 30 days          │
│  Status: Received                                            │
│  ────────────────────────────────────────────────────────   │
│  📎 Linked Document: Pay_Stub_Jan2026.pdf                   │
│     Uploaded: 2/12/2026 10:30 AM                            │
│     AI Confidence: 98% match                                 │
│  ────────────────────────────────────────────────────────   │
│  [✅ Approve Match]  [❌ Reject Match]  [👁️ View Document]   │
└─────────────────────────────────────────────────────────────┘
```

**Benefits:**
- Processor sees which document satisfies which condition (no guesswork)
- AI confidence score shows match quality (98% = high confidence)
- One-click approve or reject (no manual status updates)

## Section 8: All Conditions Cleared Event [file:1]

### Auto-Advance to Clear to Close

**Proposed Workflow [file:1]:**
```
Workflow: temporal/workflows/condition-matcher.ts
Activity 5: checkAllClear

Logic:
SELECT COUNT(*) FROM underwriting_conditions 
WHERE loan_id = 123456 
AND status NOT IN ('Cleared', 'Waived');

If COUNT = 0:
  - Fire event: 'conditions_cleared'
  - UPDATE applications SET stage = 'Clear to Close', status = 'Active'
  - Notify closer: "Loan #123456 ready to close. All conditions cleared."
```

**Current Manual Workflow:**
- Processor manually checks if all conditions cleared (visual scan of list)
- Processor manually updates loan stage to "Clear to Close"
- Processor manually emails closer: "Loan ready to close"

**Time Saved:** 2-5 minutes per loan

## Section 9: Common Condition Types

### Income Verification

**Examples:**
- "Provide most recent pay stub dated within 30 days of closing"
- "Provide W-2 forms for last 2 years"
- "Provide 2 months bank statements showing direct deposits"
- "Provide explanation for large deposit ($10,000) on 01/15/2026"

**Typical Documents:**
- Pay stubs
- W-2s
- Tax returns (1040s)
- Bank statements
- Letter of explanation (LOE)

### Asset Verification

**Examples:**
- "Provide 2 months bank statements for all accounts"
- "Provide proof of additional $10,000 in liquid reserves"
- "Provide gift letter and proof of transfer from donor"
- "Provide 401(k) statement showing balance"

**Typical Documents:**
- Bank statements (checking, savings)
- Investment account statements (401k, IRA, brokerage)
- Gift letters (signed by donor)
- Wire confirmation (proof of gift transfer)

### Credit Explanation

**Examples:**
- "Provide letter of explanation for $5,000 judgment dated 03/2020"
- "Provide proof of payment plan for collection account"
- "Provide explanation for late payment on auto loan (12/2024)"
- "Provide proof of medical collection paid in full"

**Typical Documents:**
- Letter of explanation (LOE) - borrower-written narrative
- Payment plan agreement
- Proof of payoff (receipt, bank statement showing payment)
- Court documents (judgment satisfaction)

### Insurance

**Examples:**
- "Provide homeowner's insurance declaration page with mortgagee clause"
- "Provide proof of flood insurance (property in flood zone)"
- "Provide certificate of insurance for rental property"

**Typical Documents:**
- Insurance declaration page
- Binder (temporary proof of coverage)
- Certificate of insurance

### Property / Title

**Examples:**
- "Provide final appraisal (if not yet received)"
- "Provide HOA approval letter"
- "Provide proof of clear title (no liens)"
- "Provide termite inspection report"

**Typical Documents:**
- Appraisal report
- HOA approval letter
- Title commitment
- Termite inspection, survey, etc.

### Employment Verification

**Examples:**
- "Provide Verification of Employment (VOE) from current employer"
- "Provide offer letter for new job (if relocating)"
- "Provide 2 years tax returns for self-employed income"

**Typical Documents:**
- VOE form (signed by employer HR)
- Offer letter
- Tax returns (Schedule C for self-employed)

## Common Pain Points

### 1. 4-Step Manual Condition Creation [file:1][file:7]

**Issue:** Every condition requires 4 clicks: modal → dropdown → text field → apply [file:7]

**Evidence [file:7]:** Complete workflow documented at [60:32]-[60:50]

**Time Cost:** 1-2 minutes per condition × 5-10 conditions = 5-20 minutes per loan

**Proposed Fix [file:1]:** Inline quick-add text input (no modal)

### 2. No Auto-Creation from UW Decisions [file:1]

**Issue:** Underwriter types suspension reason → Processor must manually re-create conditions from reason text

**Proposed Fix [file:1]:** AI parses suspension reason → Auto-creates conditions

### 3. Manual Borrower Notification [file:1][file:7]

**Issue:** Processor manually composes email listing conditions [file:7]. No upload links.

**Evidence [file:7]:** `[53:35] Type "Please upload the following conditions" into [Message Body]`

**Proposed Fix [file:1]:** "Send to Borrower" button auto-generates email with per-condition upload links

### 4. No Document Linking [file:1]

**Issue:** Processor must manually check which uploaded doc satisfies which condition

**Proposed Fix [file:1]:** Automated condition matching workflow links docs to conditions with AI confidence scores

### 5. No Bulk Actions

**Issue:** Can't mark multiple conditions as cleared at once (must edit each individually)

**Proposed Fix [file:1]:** Bulk status change (select multiple conditions → mark all as cleared)

## Integration Points

### Inbound Data Sources

- **UW Decision Panel:** UW suspension reason → Auto-creates conditions [file:1]
- **Document Upload:** Borrower uploads doc → Triggers condition-matcher.ts [file:1]
- **Processing Workbook:** Processor identifies missing items → Creates conditions

### Outbound Dependencies

- **Borrower Portal:** Upload links direct to portal upload page for specific condition [file:1]
- **Email/SMS:** Condition notifications sent via notification-router.ts [file:1]
- **Closing:** All conditions cleared → Loan advances to "Clear to Close" [file:1]

## Best Practices

### For Processors

1. **Be Specific:** Not "Provide more info", but "Provide explanation for $5,000 judgment"
2. **Set Deadlines:** "Provide by 02/20/2026" gives borrower clear timeline
3. **Group by Category:** Use Prior-to-Docs, Prior-to-Funding correctly (impacts closing timeline)
4. **Link Documents:** When borrower uploads doc, immediately link to condition (don't wait)

### For Underwriters

1. **Clear Suspension Reasons:** Write structured reasons that AI can parse into discrete conditions
2. **Review Processor-Cleared Conditions:** Spot-check that processor correctly cleared conditions
3. **Waive Only When Appropriate:** Waiving conditions = removing requirement (use sparingly)

## Technical Notes

### Data Model

**Primary Table:** `underwriting_conditions`

**Key Fields:**
- `id` - Unique condition ID
- `loan_id` - Foreign key to applications table
- `description` - Text (condition requirement)
- `category` - Enum (Prior-to-Docs, Prior-to-Funding, Prior-to-Closing, Post-Closing)
- `status` - Enum (Open, Received, Under Review, Cleared, Waived)
- `created_by` - User ID (UW or processor)
- `created_at` - Timestamp
- `assigned_to` - User ID (borrower, processor, third-party)
- `satisfied_by_document_id` - Foreign key to documents table (NULL if not yet satisfied)
- `cleared_at` - Timestamp (when status changed to Cleared)
- `cleared_by` - User ID (UW or processor)

### API Access

**Endpoint:** `POST /api/v1/loans/{loanId}/conditions`

**Request Body:**
```json
{
  "description": "Provide final pay stub dated within 30 days of closing",
  "category": "Prior-to-Docs",
  "status": "Open",
  "assigned_to": "borrower"
}
```

**Response:**
```json
{
  "id": 789,
  "loan_id": 123456,
  "description": "Provide final pay stub dated within 30 days of closing",
  "category": "Prior-to-Docs",
  "status": "Open",
  "created_at": "2026-02-10T14:30:00Z",
  "upload_link": "https://portal.confer.com/loans/123456/upload?condition=789"
}
```

## Related Documentation

- **Underwriting 4.1:** UW Decision Panel (creating conditions from suspension decisions)
- **Processing Workflows 3.3:** Workflow Automation (condition-matcher.ts Temporal workflow)
- **Document Management 2.2:** Document Upload (borrower uploads trigger condition matching)
- **Core Modules 1.3:** Notifications & Communications (borrower condition notifications)