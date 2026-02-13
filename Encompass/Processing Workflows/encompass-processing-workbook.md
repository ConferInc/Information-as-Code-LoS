---
type: technical-documentation
module: Processing Workflows
section: Loan Processing & Verification
subsection: Processing Workbook
source: SOP analysis + Encompass documentation
last_updated: 2026-02-13
---

# Encompass: Processing Workbook

## Overview

The Processing Workbook is Encompass's checklist and verification tool used by processors to ensure loan files are complete and accurate before submission to underwriting. It contains multiple sections for borrower info review, document cross-reference, housing expense verification, and narrative composition [file:1][file:2].

## Access Path

**Primary Navigation:**
1. Loan Window → **Forms** menu → **Processing Workbook** [file:6]
2. Or: Toolbar → **Processing** → **Processing Workbook**
3. Or: Pipeline → Right-click loan → **Processing Workbook**

**SOP Evidence [file:6]:**
```
[90:00-105:00] Processing Workbench section demonstrated
System Result: The speaker navigates through various tabs and fields 
within the Processing Workbench (no specific interactions documented 
in this time range)
```

## Section 1: Processing Workbook Structure

### Main Sections

The Processing Workbook contains collapsible sections for different verification tasks:

| Section | Purpose | Verification Type | Auto-Complete? |
|---------|---------|-------------------|----------------|
| **Borrower Info Complete** | Verify all required borrower fields populated | Checkbox | ❌ Manual |
| **24-Month Address History** | Verify residence history sums to ≥24 months | Checkbox | ❌ Manual |
| **Housing Expenses Verified** | Cross-reference uploaded docs against form fields | Checkbox | ❌ Manual |
| **Documents Cross-Referenced** | Verify all required documents uploaded and reviewed | Checkbox | ❌ Manual |
| **Purchase Contract Reviewed** | Verify purchase price, closing date, contingencies | Checkbox | ❌ Manual |
| **5-C Narratives** | Qualitative loan analysis (Character, Capacity, Capital, Collateral, Conditions) | Rich text | ❌ Manual |
| **All Green Checks Status Bar** | Visual indicator showing completion percentage | Progress bar | ✅ Auto-updates |

**Pain Point [file:1]:**
"All manual checkbox/dropdown verification. Sections do not auto-mark as complete when underlying data validates."

### Proposed Auto-Completion [file:1]

**confer-web Implementation:**
```
Component: apps/confer-web/src/components/processing/ProcessingWorkbook.tsx
Type: Client Component with collapsible sections

Auto-Completion Rules:
- "Borrower Info Complete" checks all required customers fields populated
- "24-Month Address History" checks sum of residences.durations >= 24 months
- "Housing Expenses Verified" checks realestateowned fields match uploaded 
  mortgage statement
- "Documents Cross-Referenced" checks all documents have status = 'reviewed'
- "Purchase Contract Reviewed" checks properties.purchaseprice populated
- "5-C Narrative" editor: Rich text editors for Character, Capacity, Capital, 
  Collateral, Conditions
- "All Green Checks" status bar at top
- Enable/disable "Submit to UW" button based on checklist completion
- Priority: MEDIUM
```

## Section 2: Borrower Info Complete

### What's Verified

**Required Fields Checklist:**
- [ ] All borrowers have: First Name, Last Name, DOB, SSN
- [ ] All borrowers have: Address (current residence)
- [ ] All borrowers have: Phone, Email
- [ ] All borrowers have: Employment (current employer, income)
- [ ] All borrowers have: Credit authorization signed
- [ ] Co-borrowers identified (if applicable)
- [ ] Marital status documented

**SOP Evidence [file:6]:**
```
[15:05] Type "Laylene" into First Name field
System Result: The First Name field is populated with Laylene

[15:10] Type "Jeune" into Last Name field
System Result: The Last Name field is populated with Jeune

[15:15] Select "Female" from Gender dropdown menu
System Result: The Gender field is set to Female

[15:20] Type "111988" into Date of Birth field
System Result: The Date of Birth field is populated with 111988

[15:30] Type "123456789" into SSN field
System Result: The SSN field is populated with 123456789
```

**Manual Verification Process:**
1. Processor opens Borrower Information form
2. Visually scans all required fields
3. Confirms each field is populated (not blank)
4. Returns to Processing Workbook
5. Manually checks "Borrower Info Complete" checkbox

**Pain Point:** No auto-validation. Processor must manually verify every field is populated, even though the system knows which fields are required and which are empty.

## Section 3: 24-Month Address History

### What's Verified

**Requirement:** Borrower must have documented residence history covering at least 24 consecutive months.

**Verification Logic:**
- Sum of all `residences.duration` (in months) ≥ 24
- No gaps in residence timeline
- Current residence + previous residences = 24+ months

**Example:**

| Residence | Address | Duration (months) | Start Date | End Date |
|-----------|---------|-------------------|------------|----------|
| **Current** | 123 Main St, Anytown | 18 | 08/2024 | Present |
| **Previous #1** | 456 Oak Ave, Oldtown | 6 | 02/2024 | 08/2024 |
| **Total** | - | **24** | ✅ Meets requirement | - |

**Manual Verification Process:**
1. Processor opens Residences section
2. Manually counts months for each residence
3. Adds durations in head or calculator
4. Confirms total ≥ 24 months
5. Returns to Processing Workbook
6. Manually checks "24-Month Address History" checkbox

**Pain Point:** Simple arithmetic that the system could auto-calculate but doesn't.

## Section 4: Housing Expenses Verified

### What's Verified

**Requirement:** Reported housing expenses match uploaded mortgage statement or lease agreement.

**Cross-Reference Workflow [file:2]:**
1. Processor opens uploaded mortgage statement in File Viewer (new window)
2. Reads "Total Payment" from PDF: $2,450
3. Alt-tabs to Borrower Information form
4. Navigates to Present Housing Mortgage field: $2,200
5. Identifies discrepancy ($2,450 ≠ $2,200)
6. Alt-tabs back to File Viewer to re-confirm
7. Alt-tabs back to Borrower form
8. Updates field to $2,450
9. Returns to Processing Workbook
10. Manually checks "Housing Expenses Verified" checkbox

**Pain Point [file:2]:**
"One processor spent 14 minutes on a single document cross-reference cycle."

**Fields to Verify:**
- **If Renting:** Monthly rent matches lease agreement
- **If Owning:** Mortgage payment matches mortgage statement
- **Property Tax:** Matches tax bill or escrow statement
- **HOA Fees:** Matches HOA statement
- **Insurance:** Matches homeowner's insurance declaration

## Section 5: Documents Cross-Referenced

### What's Verified

**Requirement:** All required documents uploaded and marked as "Reviewed."

**Document Review Integration [file:7]:**
- Integrates with Documents → Verifications checklist
- Processor must have clicked all document review checkboxes [file:7]
- System checks: `SELECT COUNT(*) FROM documents WHERE status = 'Reviewed' AND loan_id = ?`

**SOP Evidence [file:7]:**
```
[47:24-47:36] Click 13 document review checkboxes in sequence:
- [47:24] Credit Report Request ✓
- [47:25] Deed Restrictions ✓
- [47:26] Final Truth-in-Lending Statement ✓
- [47:27] Good Faith Estimate ✓
- [47:28] HUD-1 Settlement Statement ✓
- [47:29] Notice of Right to Cancel ✓
- [47:30] Property Tax Receipt ✓
- [47:31] Seller's Disclosure ✓
- [47:32] Survey ✓
- [47:33] Termite Inspection ✓
- [47:34] Title Commitment ✓
- [47:35] URLA ✓
- [47:36] WIRCOE ✓
```

**Manual Verification Process:**
1. Processor navigates to Documents tab
2. Clicks through 13+ document review checkboxes [file:7]
3. Returns to Processing Workbook
4. Manually checks "Documents Cross-Referenced" checkbox

**Pain Point:** Redundant checkbox clicking. Processor already verified documents individually; why must they click a separate checkbox confirming they clicked the other checkboxes?

## Section 6: Purchase Contract Reviewed

### What's Verified

**Requirement:** Purchase agreement uploaded and key terms match application data.

**Fields to Cross-Reference:**

| Purchase Contract Field | Application Field | Must Match? |
|-------------------------|-------------------|-------------|
| **Purchase Price** | `properties.purchaseprice` | ✅ Exact match |
| **Property Address** | `properties.address` | ✅ Exact match |
| **Closing Date** | `applications.closingdate` | ⚠️ May differ (estimate vs actual) |
| **Buyer Name(s)** | `customers.fullname` | ✅ Exact match |
| **Seller Name(s)** | Documented in notes | 📝 For reference |
| **Earnest Money Deposit** | `properties.earnestmoneydeposit` | ✅ Exact match |
| **Contingencies** | Documented in notes | 📝 For UW review |

**SOP Evidence [file:1]:**
"Purchase Contract Reviewed" checks `properties.purchaseprice` populated."

**Manual Verification Process:**
1. Processor opens purchase contract PDF in File Viewer (new window)
2. Reads purchase price from contract: $450,000
3. Alt-tabs to Property section
4. Verifies `Purchase Price` field: $450,000 ✓
5. Repeats for address, buyer names, closing date
6. Returns to Processing Workbook
7. Manually checks "Purchase Contract Reviewed" checkbox

**Pain Point:** More stare-and-compare across windows [file:2].

## Section 7: 5-C Narratives

### Overview

The "5-C's of Credit" is a qualitative loan analysis framework used by processors and underwriters to assess creditworthiness beyond numerical scores [file:1].

### The 5 C's

| C | Focus Area | What Processor Documents | Example Narrative |
|---|------------|--------------------------|-------------------|
| **Character** | Borrower's credit history, payment patterns | Credit report analysis, payment trends, derogatory items | "Borrower has 740 FICO with zero late payments in 24 months. One medical collection from 2019 now paid in full. Stable credit utilization at 15%." |
| **Capacity** | Borrower's ability to repay | DTI calculation, income stability, employment history | "Borrower earns $85,000/year as tenured software engineer. 2 years at current employer. DTI 38% (below 43% threshold). Stable income with annual raises." |
| **Capital** | Borrower's financial reserves | Assets, down payment, reserves | "Borrower contributing 20% down payment ($90,000). Reserves total $45,000 in checking/savings (6 months PITI). No gift funds." |
| **Collateral** | Property value and condition | Appraisal, LTV, property type | "Property appraised at $450,000 (matching purchase price). LTV 80%. Single-family residence in good condition per appraisal. No repairs required." |
| **Conditions** | External factors affecting loan | Market conditions, loan purpose, borrower circumstances | "Purchase transaction in stable market. Borrower relocating for job (documented offer letter). No red flags in application or interview." |

### Rich Text Editor [file:1]

**Proposed Implementation:**
- Each "C" has dedicated rich text editor
- Processors compose 2-4 paragraph narratives
- Narratives flow to Underwriting Decision Panel for UW review [file:1]
- Underwriters reference narratives when rendering decision

**Current Manual Process:**
1. Processor opens Processing Workbook → 5-C Narratives section
2. Clicks "Character" text field
3. Types narrative (no formatting, plain text only)
4. Repeats for Capacity, Capital, Collateral, Conditions
5. Saves Processing Workbook

**Pain Point:** No rich text formatting (bold, bullet lists, etc.). No spell check. No auto-save (lose work if window closes).

## Section 8: All Green Checks Status Bar

### Visual Completion Indicator

**Purpose:** Show processor at-a-glance which sections are complete and which still need work.

**Display:**
- Progress bar at top of Processing Workbook
- Shows: "5 of 6 sections complete (83%)"
- Each completed section: ✅ Green checkmark
- Each incomplete section: ⚠️ Yellow warning icon

**Example:**

```
Processing Workbook - Loan #123456

Progress: ███████████░░░ 83% Complete (5 of 6)

✅ Borrower Info Complete
✅ 24-Month Address History
⚠️ Housing Expenses Verified ← Still needs review
✅ Documents Cross-Referenced
✅ Purchase Contract Reviewed
✅ 5-C Narratives
```

**Current State:** No visual progress indicator. Processor must mentally track which sections are complete.

## Section 9: Submit to UW Button

### Pre-Flight Validation [file:1]

**Proposed Implementation:**
- "Submit to UW" button disabled (grayed out) until all Processing Workbook sections complete
- When processor clicks disabled button, show modal with incomplete items:
  - "Cannot submit to UW. Missing:"
  - ⚠️ Housing Expenses Verified
  - ⚠️ 5-C Narratives - Capital (required)
- When all sections complete, button enabled → triggers UW submission workflow [file:6]

**Current State [file:2]:**
"Encompass lets you complete an entire multi-step workflow and only tells you something is wrong at the very last step."

**Example Failure Scenario [file:6]:**
```
[76:30] Click [Print File]
System Result: Error - "Owned By and Property Used As fields were not populated"

Issue: System accepted all prior steps (form selection, print settings) 
without validation. Error only shown at final "Print" click.
```

## Common Pain Points

### 1. All Manual Checkbox Verification [file:1]

**Issue:** Every Processing Workbook section requires manual checkbox click, even when underlying data already proves completeness.

**Evidence [file:1]:** "All manual checkbox/dropdown verification."

**Example:** Processor manually verified all 13 documents [file:7], but still must click "Documents Cross-Referenced" checkbox in Processing Workbook.

### 2. No Auto-Completion Based on Data [file:1]

**Issue:** System doesn't auto-check "24-Month Address History" even when `SUM(residences.duration) >= 24`.

**Proposed Fix [file:1]:** Auto-mark sections complete when validation rules pass.

### 3. Stare-and-Compare Across Windows [file:2]

**Issue:** Housing expense verification requires opening document in one window, form in another, alt-tabbing to cross-reference.

**Evidence [file:2]:** "14 minutes on a single document cross-reference cycle."

### 4. No Rich Text Formatting for 5-C Narratives

**Issue:** Plain text only. No bold, italics, bullet lists, or spell check.

**Impact:** Narratives hard to read. UW must parse wall-of-text paragraphs.

### 5. No Pre-Flight Validation [file:2]

**Issue:** Processor can attempt "Submit to UW" with incomplete Processing Workbook. System only shows error at final step [file:6].

**Proposed Fix [file:1]:** Disable "Submit to UW" button until all sections complete. Show clear error message listing incomplete items.

## Integration Points

### Inbound Data Sources

- **Borrower Information Form:** Populates "Borrower Info Complete" section
- **Residences Section:** Populates "24-Month Address History" section
- **Documents Tab:** Populates "Documents Cross-Referenced" section [file:7]
- **Property Section:** Populates "Purchase Contract Reviewed" section

### Outbound Dependencies

- **UW Submission Workflow:** Processing Workbook must be 100% complete before submit [file:6]
- **Underwriting Decision Panel:** 5-C narratives flow to UW for review [file:1]
- **Loan File Completeness:** Processing Workbook completion = loan "ready for UW"

## Best Practices

### For Processors

1. **Complete Workbook Early:** Don't wait until UW submission day—complete sections as data becomes available
2. **Use 5-C Narratives Effectively:** Be specific. Cite numbers (DTI %, FICO scores, LTV). Explain anomalies proactively.
3. **Cross-Reference Diligently:** Housing expense discrepancies are common UW rejection reasons—verify carefully
4. **Save Frequently:** If using plain text editors with no auto-save, copy narratives to external doc as backup

### For Underwriters

1. **Read 5-C Narratives First:** Processor narratives provide context for numerical data
2. **Trust But Verify:** Processing Workbook completion means processor verified—but spot-check key items
3. **Provide Feedback:** If processor narratives are unclear or incomplete, coach them on what you need

## Technical Notes

### Data Model

**Primary Table:** `ProcessingWorkbook` (Encompass database)

**Key Fields:**
- `LoanGUID` - Link to parent loan
- `BorrowerInfoComplete` - Boolean (TRUE/FALSE)
- `AddressHistoryComplete` - Boolean
- `HousingExpensesComplete` - Boolean
- `DocumentsComplete` - Boolean
- `PurchaseContractComplete` - Boolean
- `Character_Narrative` - Text (5-C narrative)
- `Capacity_Narrative` - Text
- `Capital_Narrative` - Text
- `Collateral_Narrative` - Text
- `Conditions_Narrative` - Text
- `CompletionPercentage` - Integer (0-100)
- `CompletedAt` - Timestamp (when 100% complete)
- `CompletedBy` - User ID (processor who completed)

### API Access

**Endpoint:** `GET /encompass/v3/loans/{loanId}/processingWorkbook`

**Response:**
```json
{
  "loanId": "12345",
  "completionPercentage": 83,
  "sections": {
    "borrowerInfoComplete": true,
    "addressHistoryComplete": true,
    "housingExpensesComplete": false,
    "documentsComplete": true,
    "purchaseContractComplete": true
  },
  "narratives": {
    "character": "Borrower has 740 FICO...",
    "capacity": "DTI 38%, stable income...",
    "capital": "20% down, 6 months reserves...",
    "collateral": "Property appraised at $450K...",
    "conditions": "Purchase in stable market..."
  },
  "completedAt": null,
  "completedBy": null
}
```

## Related Documentation

- **Document Management 2.4:** Document Review & Verification (13-checkbox marathon)
- **Processing Workflows 3.2:** Loan File Verification (verification checklists)
- **Processing Workflows 3.3:** UW Submission (what happens after workbook complete)
- **Underwriting 4.1:** UW Decision Panel (how UW uses 5-C narratives)