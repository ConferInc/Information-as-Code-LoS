---
type: technical-documentation
module: Document Management
section: Document Operations
subsection: Review & Verification
source: SOP analysis + Encompass documentation
last_updated: 2026-02-13
---

# Encompass: Document Review & Verification

## Overview

Document review and verification is the processor's workflow for confirming uploaded documents are complete, legible, accurate, and match borrower-provided information. This process is critical for underwriting approval but is highly manual in Encompass [file:2][file:7].

## Access Path

**Primary Navigation:**
1. Loan Window → **Documents** tab → **Verifications** section [file:7]
2. Or: Forms menu → **Processing Workbook** → **Document Review**
3. Or: Documents tab → Right-click document → **Mark as Reviewed**

**SOP Evidence [file:7]:**
```
[45:00] Click [Docs & Certifications] under the Services section
System Result: The main window's content changes to display various 
document types related to mortgage loans

[47:24] Click [Credit Report Request] checkbox
System Result: The checkbox is marked as completed
```

## Section 1: Document Review Checklist

### The 13-Checkbox Marathon [file:2][file:7]

**Pain Point: One-by-One Checkbox Clicking**

**SOP Evidence [file:7]:**
```
[47:24] Click [Credit Report Request] checkbox → System Result: Marked as completed
[47:25] Click [Deed Restrictions] checkbox → System Result: Marked as completed
[47:26] Click [Final Truth-in-Lending Statement] checkbox → System Result: Marked as completed
[47:27] Click [Good Faith Estimate] checkbox → System Result: Marked as completed
[47:28] Click [HUD-1 Settlement Statement] checkbox → System Result: Marked as completed
[47:29] Click [Notice of Right to Cancel] checkbox → System Result: Marked as completed
[47:30] Click [Property Tax Receipt] checkbox → System Result: Marked as completed
[47:31] Click [Seller's Disclosure] checkbox → System Result: Marked as completed
[47:32] Click [Survey] checkbox → System Result: Marked as completed
[47:33] Click [Termite Inspection] checkbox → System Result: Marked as completed
[47:34] Click [Title Commitment] checkbox → System Result: Marked as completed
[47:35] Click [Uniform Residential Loan Application (URLA)] checkbox → System Result: Marked as completed
[47:36] Click [WIRCOE] checkbox → System Result: Marked as completed
```

**13 consecutive checkbox clicks in ~12 seconds.**

**Pain Point [file:2]:**
"Document review in Encompass is a tedious one-by-one checkbox marathon. There is no 'Select All,' no bulk review, no smart grouping."

**Time Cost:** ~1 minute per loan just clicking checkboxes (excludes actual document review time).

### Document Types Requiring Review

| Document Type | Verification Checklist | Source |
|---------------|------------------------|--------|
| **Credit Report** | ✓ All 3 bureau scores present; ✓ Borrower name matches; ✓ SSN matches | [file:7] |
| **Pay Stubs** | ✓ Last 30 days; ✓ YTD earnings visible; ✓ Employer name matches VOE | - |
| **W-2s** | ✓ Last 2 years; ✓ All W-2s for all employers; ✓ Wage amounts match tax returns | - |
| **Tax Returns** | ✓ Last 2 years; ✓ All pages present; ✓ Signed by borrower; ✓ Income matches 1040 Line 11 | - |
| **Bank Statements** | ✓ Last 2 months; ✓ All pages present; ✓ Account number matches Assets section | - |
| **Appraisal** | ✓ Property address matches; ✓ Appraised value ≥ purchase price; ✓ Signed by appraiser | - |
| **Purchase Agreement** | ✓ Signed by all parties; ✓ Purchase price matches application; ✓ Closing date confirmed | - |
| **Insurance** | ✓ Coverage amount ≥ loan amount; ✓ Mortgagee clause includes lender; ✓ Effective date covers closing | - |
| **Title Commitment** | ✓ Clear title; ✓ No liens except disclosed; ✓ Legal description matches deed | [file:7] |

## Section 2: Document Review Workflow

### Standard Processor Review Process

**8-Step Review Cycle Per Document:**
1. **Open Document** - Double-click in E-Folder → File Viewer opens (new window) [file:8]
2. **Verify Completeness** - Check all pages present (page 1 of 5 = 5 pages total)
3. **Verify Legibility** - Ensure text is readable (not blurry, not cut off)
4. **Verify Accuracy** - Cross-reference document data against application data
5. **Identify Discrepancies** - Flag any mismatches (e.g., pay stub employer ≠ application employer)
6. **Close File Viewer** - Close document window [file:3]
7. **Mark as Reviewed** - Check checkbox in Documents Verifications section [file:7]
8. **Move to Next Document** - Repeat cycle for next document

**Time Per Document:** 2-5 minutes (varies by document complexity)

### Stare-and-Compare Cross-Reference [file:2]

**Pain Point: Dual-Window Verification**

**Example: Verifying Pay Stub Against Employment Section**
1. Open pay stub in File Viewer (window 1)
2. Read employer name: "Acme Corporation"
3. Read gross pay: "$5,000"
4. Read YTD earnings: "$60,000"
5. Alt-tab to Borrower window (window 2)
6. Navigate to Employment & Income section
7. Compare employer name field: "Acme Corp" ← **Discrepancy!**
8. Alt-tab back to pay stub (window 1)
9. Re-read employer name: "Acme Corporation" (yep, full name)
10. Alt-tab back to Borrower window (window 2)
11. Update employer name field: "Acme Corporation"
12. Save form
13. Repeat for gross pay and YTD earnings

**Evidence [file:2]:**
"In one recorded session, a processor opened an uploaded mortgage statement PDF in one window, then navigated back to the Borrower Information form in a separate window to verify that the 'Total Payment' figure matched the 'Present Housing Mortgage' field."

**Time Cost:** "One processor spent 14 minutes on a single document cross-reference cycle." [file:2]

## Section 3: Bulk Actions (Not Supported)

### Missing Feature: Select All [file:2]

**Pain Point:** Cannot select multiple documents and mark as "Reviewed" in bulk.

**Current Workflow:**
- 13 documents to review = 13 individual checkbox clicks [file:7]
- Even if processor batch-reviews all income docs, must click each checkbox separately

**Proposed Fix [file:1]:**
"Review All Income Documents" category-level action:
1. Select "Income" category
2. Click "Mark All as Reviewed"
3. Confirmation prompt: "Mark 5 documents as reviewed? Yes/No"
4. All 5 income docs marked complete in one click

### Missing Feature: Smart Grouping

**Pain Point:** Documents not grouped by logical categories for review.

**Example:** Processor reviewing "Income" category sees:
- Pay stub 1
- W-2 2023
- Pay stub 2
- Tax return 2023
- W-2 2024
- Pay stub 3
- Tax return 2024

**Better UX:** Group by year or type:
- **Pay Stubs (3)** - Mark group as reviewed
- **W-2s (2)** - Mark group as reviewed
- **Tax Returns (2)** - Mark group as reviewed

## Section 4: Document Rejection & Conditions

### Rejecting Documents

**When to Reject:**
- Illegible (blurry, cut off)
- Incomplete (missing pages)
- Incorrect (wrong document uploaded)
- Outdated (2022 pay stub when 2024 required)
- Fraudulent (altered, PhotoShopped)

**Rejection Workflow:**
1. Right-click document → **Reject**
2. Modal opens: "Reason for rejection"
3. Type reason: "Pay stub is illegible—please re-upload clear copy"
4. Click **[Submit]**
5. System creates condition: "Re-upload legible pay stub"
6. Borrower receives notification (if auto-notification enabled)

### Creating Conditions from Document Issues [file:7]

**Condition Creation Workflow:**

**SOP Evidence [file:7]:**
```
[49:51] Click [Send To Post] below the Generated Date field
System Result: A pop-up window titled "Request Sent For Borrower" shows up, 
indicating that the request has been sent successfully

[53:26] Click [Send] in the Borrower tab
System Result: A new window titled "Send Message" opens

[53:30] Select [Recipient's Name] from the dropdown menu in the Send Message window
System Result: The recipient's name is selected

[53:35] Type "Please upload the following conditions" into [Message Body]
System Result: The message body is filled with the text

[53:45] Click [Send] in the Send Message window
System Result: The message is sent to the borrower
```

**Manual Condition Workflow:**
1. Identify document issue during review
2. Open **Conditions** tab (or modal) [file:7]
3. Click **[Add Condition]**
4. Type condition: "Provide explanation for $5,000 deposit on bank statement page 2"
5. Select category: "Prior to Docs" / "Prior to Funding" / "Prior to Closing"
6. Assign to: Borrower / Processor / LO
7. Click **[Save]**
8. Send notification to borrower [file:7]

**Pain Point [file:1]:**
"Add Condition modal with dropdown + text field + Apply button. 4 steps per condition. No auto-creation from UW decisions. Manual message composition to request conditions from borrowers."

## Section 5: Post-Closing Verification [file:7]

### Post-Closing Document Checklist

**4 Separate Radio Button Clicks [file:2]:**

While not explicitly captured in the provided SOP timestamp range, the pain point document [file:2] states:
"Post-closing verification requires 4 separate checkbox/radio button clicks for items that could be a single confirmation."

**Typical Post-Closing Verification Items:**
- [ ] Final signed Note received
- [ ] Final signed Deed of Trust received
- [ ] Funding confirmation received
- [ ] Loan sold to investor and delivered

**Each item requires individual click** - no batch completion.

## Section 6: Processing Workbook Integration [file:1]

### Automated Workbook Completion

**Proposed Automation [file:1]:**
```
Component: apps/confer-web/src/components/processing/ProcessingWorkbook.tsx
Type: Client Component with collapsible sections

Auto-Completion Rules:
- "Documents Cross-Referenced" section auto-marks as complete when 
  all documents have status = 'reviewed'
- "Borrower Info Complete" checks all required customers fields populated
- "24-Month Address History" checks sum of residences.durations >= 24 months
- "Housing Expenses Verified" checks realestateowned fields match uploaded 
  mortgage statement
```

**Current Manual Process:**
- Processor clicks checkbox for each verification item [file:7]
- No auto-completion based on underlying data status
- Processor must manually track completeness

## Common Pain Points

### 1. 13-Checkbox One-by-One Clicking [file:2][file:7]

**Issue:** No bulk review capability. Processor clicks 13 individual checkboxes sequentially to mark documents as reviewed.

**Evidence [file:7]:** 13 consecutive checkbox clicks documented at timestamps [47:24] through [47:36].

**Time Cost:** ~1 minute per loan (just checkbox clicking, excludes actual review time).

### 2. Stare-and-Compare Across Windows [file:2]

**Issue:** Document in File Viewer (window 1), form fields in Borrower window (window 2). Processor alt-tabs repeatedly to cross-reference.

**Evidence [file:2]:** "6 documented stare-and-compare workflows. One processor spent 14 minutes on a single document cross-reference cycle."

**Impact:** Slow processing, human error, processor fatigue.

### 3. No AI Pre-Review [file:1]

**Issue:** Processor must manually open and review every single document. No AI pre-check for completeness or legibility.

**Proposed Fix [file:1]:**
"AI pre-reviews documents for completeness and legibility, flagging only the ones that need human attention. Processors review exceptions, not every single document."

### 4. No Automated Condition Creation

**Issue:** When document issue identified, processor manually creates condition, types description, assigns category, sends notification [file:7].

**Proposed Fix [file:1]:**
"On 'Suspend' decision, auto-populate conditions from decision notes."

### 5. No Version Comparison Tool

**Issue:** If borrower re-uploads document (v1.0 → v1.1), processor must manually compare versions to see what changed.

**Workaround:** Open both versions in separate File Viewer windows → alt-tab to compare.

## Integration Points

### Inbound Data Sources

- **E-Folder:** All documents reviewed from E-Folder [file:7]
- **Consumer Connect Portal:** Borrower uploads trigger review workflow [file:3]

### Outbound Dependencies

- **Processing Workbook:** Document review checklist integrates with workbook [file:1]
- **Underwriting Submission:** All documents must be "Reviewed" before submitting to UW
- **Conditions Management:** Rejected documents create conditions [file:7]

## Best Practices

### For Processors

1. **Review Daily:** Don't let document backlog build—review uploaded docs same day
2. **Use Checklist:** Follow standard verification checklist for each document type
3. **Document Notes:** Add notes when rejecting documents (helps borrower understand issue)
4. **Dual Monitors:** Keep File Viewer on second monitor, Borrower form on primary (reduces alt-tabbing)

### For Underwriters

1. **Spot Check:** Randomly review "Reviewed" documents—don't assume processor caught everything
2. **Red Flags:** Look for PhotoShop artifacts, white-out, altered dates (fraud indicators)
3. **Version History:** If document has multiple versions, investigate why (may indicate attempt to hide something)

## Technical Notes

### Document Status State Machine

**Status Flow:**
```
Received → Pending Review → [Reviewed | Rejected]
                              ↓
                         (If Rejected) → Replaced → Pending Review → Reviewed
```

**Database Fields:**
- `documents.status` - Current status
- `documents.reviewed_at` - Timestamp when marked reviewed
- `documents.reviewed_by` - User ID who reviewed
- `documents.rejection_reason` - Text if rejected

### API Access

**Endpoint:** `PATCH /encompass/v3/loans/{loanId}/documents/{documentId}`

**Request Body (Mark as Reviewed):**
```json
{
  "status": "Reviewed",
  "reviewedBy": "user_12345",
  "reviewedAt": "2026-02-13T17:30:00Z"
}
```

**Request Body (Reject Document):**
```json
{
  "status": "Rejected",
  "rejectionReason": "Illegible—please re-upload clear copy",
  "rejectedBy": "user_12345",
  "rejectedAt": "2026-02-13T17:30:00Z"
}
```

## Related Documentation

- **Document Management 2.1:** E-Folder Structure (document storage)
- **Document Management 2.2:** Document Upload Workflows (how documents arrive)
- **Document Management 2.3:** Document Viewer (viewing documents during review)
- **Processing Workflows 3.1:** Processing Workbook (document verification checklist integration)
- **Underwriting 4.2:** Conditions Management (creating conditions from document issues)