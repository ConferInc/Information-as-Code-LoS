---
type: technical-documentation
module: Underwriting
section: UW Review & Decision
subsection: UW-1A Form & Decision Panel
source: SOP analysis + Encompass documentation
last_updated: 2026-02-13
---

# Encompass: UW Decision Panel (UW-1A Form)

## Overview

The UW-1A form is Encompass's primary underwriting review interface where underwriters analyze loan files and render approve/suspend/deny decisions [file:1][file:8]. It opens in a new window and contains multiple tabs for credit, income, assets, fraud reports, and decision buttons [file:1][file:2][file:8].

## Access Path

**Primary Navigation:**
1. Loan Window → **Forms** menu → **UW-1A** [file:8]
2. Or: Toolbar → **Underwriting** → **UW-1A**
3. Or: Pipeline → Right-click loan → **UW-1A**

**SOP Evidence [file:8]:**
```
[09:46] Select [UW-1A] from the main menu
System Result: A new window appears and populates with fields for 
entering personal and financial information
```

**Pain Point [file:2]:**
"Opening UW-1A? New window."

## Section 1: UW-1A Interface Structure

### New Window Spawn [file:1][file:2]

**Issue:** UW-1A always opens in separate window (not within loan file window) [file:2][file:8].

**SOP Evidence [file:8]:**
"[09:46] Select [UW-1A] from the main menu - System Result: A new window appears"

**Multi-Window Problem [file:2]:**
- Loan file window = Window 1
- UW-1A form = Window 2
- Credit report File Viewer = Window 3
- Fraud report File Viewer = Window 4
- Processor must alt-tab between 3-4 windows during UW review

### Main Components [file:1]

| Component | Location | Purpose |
|-----------|----------|---------|
| **Loan Summary Header** | Top | Read-only summary: Borrower, Property, LTV, DTI, FICO, Loan Amount |
| **Tabbed Review Sections** | Center | Credit Analysis, Income/Employment, Assets, Fraud Report, Declarations |
| **5-C Narratives** | Tab | Processor narratives from Processing Workbook |
| **Decision Buttons** | Bottom | Approve, Conditionally Approve, Suspend, Deny |
| **Generate Approval Letter** | Bottom right | One-click PDF generation |
| **Fraud File Button** | Top toolbar | Opens fraud report window [file:8] |
| **Reviewable Checkbox Column** | Various tabs | Mark items as reviewed |

### Proposed Unified Interface [file:1]

**confer-web Implementation:**
```
Component: apps/confer-web/src/components/underwriting/DecisionPanel.tsx
Type: Client Component with role-based access (UW only)

Requirements:
- Loan summary header: Borrower, Property, LTV, DTI, FICO, Loan Amount (read-only)
- Tabbed review sections (all in-page, no new windows):
  • Credit Analysis: scores, trade lines, derogatory items
  • Income & Employment: qualification summary, DTI calculation
  • Assets & Reserves: reserve months calculation
  • Fraud Report: embedded PDF viewer
  • Declarations: flagged items highlighted
  • 5-C Narratives: from Processing Workbook
- Decision buttons: Approve (green), Conditionally Approve (yellow), 
  Suspend (orange), Deny (red)
- On Suspend/Deny: Required text field for reason
- On Suspend: Inline condition creation (conditions auto-created)
- ECOA adverse action timer: auto-starts on Deny
- HMDA action taken: auto-populated from decision
- Generate Approval Letter: one-click PDF generation stored in documents

Priority: HIGH
```

## Section 2: Loan Summary Header

### Read-Only Loan Snapshot

**Purpose:** Provide UW with at-a-glance loan overview without scrolling through multiple forms.

**Fields Displayed:**

| Field | Source | Example Value |
|-------|--------|---------------|
| **Loan Number** | `applications.loan_number` | 123456 |
| **Borrower Name** | `customers.full_name` (primary borrower) | Laylene Jeune |
| **Property Address** | `properties.address` | 456 Oak Ave, Anytown, VA |
| **Purchase Price** | `properties.purchase_price` | $450,000 |
| **Loan Amount** | `applications.loan_amount` | $360,000 |
| **LTV (Loan-to-Value)** | Calculated: `loan_amount / appraised_value` | 80% |
| **DTI (Debt-to-Income)** | Calculated: `total_monthly_debt / gross_monthly_income` | 38% |
| **FICO Score (Mid)** | `credit_reports.mid_score` | 738 |
| **Loan Purpose** | `applications.loan_purpose` | Purchase |
| **Occupancy** | `properties.occupancy` | Primary Residence |

**Calculations:**
- **LTV:** `($360,000 / $450,000) × 100 = 80%`
- **DTI:** `($3,200 monthly debt / $8,500 monthly income) × 100 = 37.6%` → Rounds to 38%

## Section 3: Credit Analysis Tab

### Credit Report Review [file:8]

**SOP Evidence [file:8]:**
```
[12:10] Click [File Viewer]
System Result: A new window labeled "File Viewer" appears with fields 
like Name, File Type, Date, and Version, which populate with data:
  Name: Credit Report
  File Type: PDF  
  Date: 9/30/2024
  Version: 1.0
```

**Current Workflow:**
1. Underwriter opens UW-1A form (window 1)
2. Click **Fraud File** button → Credit report opens in File Viewer (window 2) [file:8]
3. Alt-tab between UW-1A and File Viewer to review credit data
4. Manually check credit scores match mid-score
5. Manually review trade lines for derogatory items
6. Return to UW-1A → Check "Credit Reviewed" checkbox

### Credit Data Displayed in UW-1A

**Scores Section:**

| Bureau | Raw Score | Used for Mid-Score? |
|--------|-----------|---------------------|
| **Experian** | 740 | ✅ Yes |
| **TransUnion** | 735 | ❌ No (lowest) |
| **Equifax** | 738 | ✅ Yes |
| **Mid-Score** | **738** | **✅ Used for qualification** |

**Mid-Score Logic:** Take middle value of 3 scores (740, 735, 738) → 738

**Trade Lines Summary:**

| Creditor | Type | Balance | Monthly Payment | Status |
|----------|------|---------|-----------------|--------|
| Chase Credit Card | Revolving | $5,000 | $150 | Current |
| Wells Fargo Auto Loan | Installment | $18,000 | $450 | Current |
| Capital One Credit Card | Revolving | $3,500 | $105 | Current |
| **Total Revolving** | - | **$8,500** | **$255** | - |
| **Total Installment** | - | **$18,000** | **$450** | - |

**Derogatory Items:**

| Item | Type | Amount | Date | Status |
|------|------|--------|------|--------|
| Medical Collection | Collection | $250 | 03/2022 | Paid in full 01/2024 |

**UW Analysis:**
- One collection account (medical) from 2 years ago, now paid → **Acceptable with LOE**
- No late payments in last 24 months → **Good payment history**
- Credit utilization: `$8,500 / $25,000 limit = 34%` → **Moderate**

**Automated Credit Import [file:1]:**
See Processing Workflows 3.3: Workflow Automation → Credit Report Auto-Import workflow for AI-powered liability creation and derogatory flagging.

## Section 4: Income & Employment Tab

### DTI Calculation

**Purpose:** Verify borrower's monthly debt payments do not exceed 43% of gross monthly income (standard threshold).

**Monthly Income:**

| Source | Amount | Calculation |
|--------|--------|-------------|
| **Base Salary** | $7,083 | $85,000 annual ÷ 12 |
| **Bonus (Avg)** | $833 | $10,000 annual bonus ÷ 12 |
| **Total Monthly Income** | **$7,916** | - |

**Monthly Debts:**

| Debt | Amount | Source |
|------|--------|--------|
| **Proposed Mortgage (PITI)** | $2,450 | Principal + Interest + Tax + Insurance |
| **Chase Credit Card** | $150 | Minimum payment from credit report |
| **Wells Fargo Auto Loan** | $450 | From credit report |
| **Capital One Credit Card** | $105 | From credit report |
| **Total Monthly Debt** | **$3,155** | - |

**DTI Calculation:**
```
DTI = (Total Monthly Debt / Total Monthly Income) × 100
DTI = ($3,155 / $7,916) × 100
DTI = 39.85% → Rounds to 40%
```

**Threshold:** 43% maximum for conventional loans
**Result:** ✅ **40% < 43% → Qualifies**

### Employment Verification

**Employment History Review:**

| Employer | Position | Duration | Annual Income | Status |
|----------|----------|----------|---------------|--------|
| **Acme Corporation** | Software Engineer | 2 years 3 months | $85,000 | Current |
| **Previous Employer** | Junior Developer | 1 year 8 months | $65,000 | Historical |

**Verification:**
- ✅ 2+ years same line of work (software engineering)
- ✅ VOE (Verification of Employment) received
- ✅ Recent pay stubs match annual salary
- ✅ W-2s for last 2 years provided

## Section 5: Assets & Reserves Tab

### Reserve Months Calculation

**Purpose:** Verify borrower has sufficient liquid assets to cover mortgage payments (PITI) for X months after closing.

**Liquid Assets:**

| Account | Institution | Balance | Verified? |
|---------|-------------|---------|-----------|
| **Checking** | Wells Fargo | $25,000 | ✅ Bank statement |
| **Savings** | Wells Fargo | $20,000 | ✅ Bank statement |
| **401(k)** | Fidelity | $80,000 | ⚠️ Not liquid (excluded) |
| **Total Liquid Assets** | - | **$45,000** | - |

**Reserve Calculation:**
```
Monthly PITI = $2,450
Reserve Months = Liquid Assets / Monthly PITI
Reserve Months = $45,000 / $2,450
Reserve Months = 18.4 months
```

**Requirement:** 6 months minimum for conventional loans
**Result:** ✅ **18.4 months > 6 months → Qualifies**

**Down Payment:**
- Purchase price: $450,000
- 20% down: $90,000
- Liquid assets after down payment: $45,000 - $90,000 = -$45,000 ❌

**Issue:** Borrower doesn't have enough liquid assets for both down payment and reserves.
**Resolution:** Gift funds from parents ($50,000) → Total liquid assets = $95,000
- Down payment: $90,000
- Remaining: $5,000 → **Only 2 months reserves** ⚠️

**UW Decision:** Request additional asset verification or reduce down payment to 15%.

## Section 6: Fraud Report Tab

### Fraud File Access [file:8]

**SOP Evidence [file:8]:**
```
[10:13] Click [Fraud File]
System Result: The Fraud File section is highlighted, showing entries 
like "Non-Mortgage Disclosures" and "Pre-Funding Exclusions"
```

**Fraud Report Contents:**
- **Identity Verification:** SSN validation, address history, employment verification
- **Document Verification:** Pay stubs, bank statements, tax returns checked for alterations
- **Red Flags:** OFAC (Office of Foreign Assets Control) sanctions check, fraud alerts
- **Third-Party Reports:** Point Services fraud report, credit report fraud alerts

**Common Fraud Indicators:**
- Income inflation (pay stubs don't match W-2s)
- Bank statement alterations (Photoshop artifacts, font inconsistencies)
- Employment verification mismatches (VOE employer ≠ pay stub employer)
- Address inconsistencies (current address on application ≠ credit report address)
- Recent large deposits (undocumented, potential undisclosed debt)

**UW Review:**
1. Open Fraud File tab in UW-1A [file:8]
2. Review Point Services fraud report (embedded PDF [file:1])
3. Check OFAC sanctions list (auto-checked by system)
4. Verify no fraud alerts on credit report
5. Check "Fraud Report Reviewed" checkbox

## Section 7: Declarations Tab

### Flagged Items Highlight [file:1]

**Declarations Section:** Borrower-answered yes/no questions about:
- Ownership of other properties
- Outstanding judgments or liens
- Bankruptcy history (last 7 years)
- Foreclosure history (last 7 years)
- Party to lawsuit
- Obligations to pay alimony, child support
- Down payment borrowed

**Flagged Items (Answered "Yes"):**
- ✅ Ownership of other properties → **Borrower owns 1 rental property**
- ⚠️ Outstanding judgments or liens → **$5,000 judgment from 2020**

**UW Action:**
- Rental property: Verify rental income via lease agreement, add to income calculation
- Judgment: Request proof of payment plan or payoff, add to liabilities if not paid

## Section 8: 5-C Narratives Tab

### Processor Narratives Review [file:1]

**Purpose:** Read processor's qualitative analysis from Processing Workbook (see Processing Workflows 3.1).

**5-C Narratives:**

**Character:**
> "Borrower has 738 FICO with zero late payments in 24 months. One medical collection from 2022 now paid in full. Stable credit utilization at 34%. No fraud alerts."

**Capacity:**
> "Borrower earns $85,000/year as tenured software engineer. 2 years at current employer. DTI 40% (below 43% threshold). Stable income with annual raises documented."

**Capital:**
> "Borrower contributing 20% down payment ($90,000) with gift funds from parents ($50,000). Liquid reserves total $5,000 after down payment (2 months PITI). **Concern: Low reserves.**"

**Collateral:**
> "Property appraised at $450,000 (matching purchase price). LTV 80%. Single-family residence in good condition per appraisal. No repairs required."

**Conditions:**
> "Purchase transaction in stable market. Borrower relocating for job (documented offer letter). **Red flag: $5,000 judgment from 2020 (needs verification).**"

**UW Analysis:**
- Overall: Strong borrower (good credit, stable income, sufficient DTI)
- Concerns: Low reserves (2 months), outstanding judgment
- Decision: **Suspend** with conditions:
  1. Provide proof of judgment payment plan or payoff
  2. Provide additional liquid assets or reduce down payment to 15%

## Section 9: Decision Buttons

### Approve / Suspend / Deny Workflow [file:1]

**Decision Options:**

| Button | Color | Meaning | Next Steps |
|--------|-------|---------|------------|
| **Approve** | Green | Loan fully approved, clear to close | Generate approval letter, notify closer |
| **Conditionally Approve** | Yellow | Approved with standard conditions (e.g., final pay stub, insurance) | Create conditions, notify processor |
| **Suspend** | Orange | Cannot approve until specific issues resolved | Create conditions, notify processor [file:1] |
| **Deny** | Red | Loan does not qualify | Start ECOA timer, generate adverse action notice [file:1] |

### SOP Evidence: Conditions Management [file:7]

**Add Condition Workflow [file:7]:**
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
"Add Condition modal with dropdown + text field + Apply button. 4 steps per condition. No auto-creation from UW decisions."

### Suspend Decision with Auto-Conditions [file:1]

**Proposed Workflow:**
1. Underwriter clicks **[Suspend]** button
2. Modal appears: "Reason for suspension" (required text field)
3. Underwriter types: "Need proof of judgment payoff and additional reserves"
4. System parses reason → Auto-creates 2 conditions:
   - Condition #1: "Provide proof of $5,000 judgment payment or payoff"
   - Condition #2: "Provide additional $10,000 in liquid reserves or reduce down payment"
5. Conditions auto-assigned to processor
6. Processor receives notification: "Loan #123456 suspended. 2 conditions created."

**Current Manual Workflow [file:1][file:7]:**
1. Underwriter clicks **[Suspend]**
2. Underwriter manually opens Conditions tab [file:7]
3. Clicks **[Add Condition]** → Dropdown → Select category → Type description → Apply [file:7]
4. Repeat for each condition (4 steps × 2 conditions = 8 clicks)
5. Manually compose email to processor explaining suspension
6. Send email via Gmail (external tool [file:2])

**Time Saved with Automation:** 5-10 minutes per suspension.

### Deny Decision with ECOA Timer [file:1]

**Proposed Workflow:**
1. Underwriter clicks **[Deny]** button
2. Modal appears: "Reason for denial" (required text field)
3. Underwriter types: "DTI too high (52%)"
4. System records denial date → Starts ECOA 30-day timer [file:1]
5. System auto-populates HMDA "Action Taken" field: "Denied"
6. System schedules escalation alerts:
   - Day 20: Alert compliance officer if adverse action notice not sent
   - Day 27: Urgent escalation to executive team
7. System auto-generates adverse action notice letter from denial reason [file:1]
8. Processor reviews letter → Sends to borrower

**Current Manual Workflow:**
- Underwriter clicks **[Deny]** → Manually types denial reason → Saves
- Compliance officer manually tracks 30-day deadline in spreadsheet
- If forgotten, ECOA violation = $10K+ fine per violation
- Adverse action letter manually drafted and sent

**Compliance Risk Eliminated:** ECOA timer automation [file:1] prevents missed deadlines.

## Section 10: Generate Approval Letter

### One-Click PDF Generation [file:1]

**Workflow:**
1. Underwriter clicks **[Generate Approval Letter]** button [file:1]
2. System generates PDF from template + loan data:
   - Borrower name, address
   - Loan amount, interest rate, term
   - Approval conditions (if any)
   - Expiration date (typically 60 days)
3. PDF auto-saves to E-Folder → Documents → Underwriting category
4. Underwriter reviews PDF → Sends to borrower (via integrated email [file:1])

**Sample Approval Letter:**
```
Dear Laylene Jeune,

Congratulations! Your mortgage application (#123456) has been approved 
for a loan amount of $360,000 at 6.5% interest for 30 years.

Conditions:
- Provide final pay stub dated within 30 days of closing
- Provide homeowner's insurance declaration with mortgagee clause

This approval is valid until April 15, 2026.

Sincerely,
[Underwriter Name]
```

**Pain Point [file:1]:**
"Generate Approval Letter button in separate screen."

**Proposed Fix [file:1]:**
"One-click PDF generation stored in documents (all in same window)."

## Common Pain Points

### 1. Multi-Window Chaos [file:2][file:8]

**Issue:** UW-1A opens in new window. Credit report opens in another new window. Fraud report in yet another window.

**Evidence [file:2]:** "11 documented new-window spawns. Opening UW-1A? New window."

**Evidence [file:8]:** `[09:46] Select [UW-1A] - System Result: A new window appears`

**Impact:** Underwriter manages 3-4 windows simultaneously, alt-tabbing constantly.

### 2. Manual Condition Creation [file:1][file:7]

**Issue:** 4 steps per condition (dropdown → select → type → apply) [file:7]. No auto-creation from UW decision reason.

**Evidence [file:7]:** Full 4-step workflow documented at [60:32]-[60:50]

**Time Cost:** 5-10 minutes per suspension (creating conditions + emailing processor).

### 3. No ECOA Timer Automation [file:1]

**Issue:** Compliance officer manually tracks 30-day adverse action deadline. Missed deadlines = $10K+ fines.

**Proposed Fix [file:1]:** Adverse-action-timer.ts Temporal workflow auto-tracks deadline with day-20 and day-27 escalations.

### 4. Separate Fraud File Window [file:8]

**Issue:** Fraud File button opens new window [file:8]. Underwriter alt-tabs between UW-1A and fraud report.

**Evidence [file:8]:** `[10:13] Click [Fraud File] - System Result: The Fraud File section is highlighted`

**Proposed Fix [file:1]:** Embedded PDF viewer in Fraud Report tab (no new window).

### 5. Manual HMDA Population

**Issue:** Underwriter must manually update HMDA "Action Taken" field after rendering decision.

**Proposed Fix [file:1]:** Auto-populate HMDA fields from UW decision (Approve = "Originated", Deny = "Denied", etc.).

## Integration Points

### Inbound Data Sources

- **Processing Workbook:** 5-C narratives flow to UW-1A [file:1]
- **Credit Report:** Scores and trade lines display in Credit Analysis tab [file:8]
- **Fraud Report:** Point Services report displays in Fraud File tab [file:8]
- **Loan Application:** All borrower, property, income, asset data

### Outbound Dependencies

- **Conditions Management:** UW-created conditions flow to Conditions tab [file:7]
- **ECOA Timer:** Denial triggers adverse-action-timer.ts workflow [file:1]
- **HMDA Reporting:** Decision auto-populates HMDA fields [file:1]
- **Closing:** Approval triggers "Clear to Close" status → Closer notified

## Best Practices

### For Underwriters

1. **Review 5-C Narratives First:** Processor narratives provide context before diving into numbers
2. **Verify Mid-Score:** Manually check credit report mid-score matches UW-1A header
3. **Check Fraud Report:** Always review Point Services fraud report for red flags
4. **Document Conditions Clearly:** Be specific (not "Provide more info", but "Provide explanation for $5,000 judgment")
5. **Set Expiration Dates:** Approval letters should expire in 60-90 days (market conditions change)

### For Processors

1. **Complete Processing Workbook:** UW will read 5-C narratives—make them detailed and accurate
2. **Pre-Review Fraud Report:** Flag any concerns in narratives so UW knows what to focus on
3. **Prepare for Conditions:** Anticipate common conditions (final pay stub, insurance, etc.) and have ready

## Technical Notes

### Data Model

**Primary Table:** `uw_decisions` (Encompass database)

**Key Fields:**
- `LoanGUID` - Link to parent loan
- `DecisionType` - Approve, Conditionally Approve, Suspend, Deny
- `DecisionDate` - Timestamp
- `DecisionBy` - Underwriter user ID
- `DecisionReason` - Text (required for Suspend/Deny)
- `ApprovalLetterGenerated` - Boolean
- `EcoaTimerStarted` - Boolean (TRUE if Deny)
- `HmdaActionTaken` - Auto-populated from DecisionType

### API Access

**Endpoint:** `POST /encompass/v3/loans/{loanId}/uwDecisions`

**Request Body:**
```json
{
  "decisionType": "Suspend",
  "decisionReason": "Need proof of judgment payoff and additional reserves",
  "decisionBy": "underwriter@company.com",
  "conditions": [
    {
      "description": "Provide proof of $5,000 judgment payment or payoff",
      "category": "Prior-to-Docs"
    },
    {
      "description": "Provide additional $10,000 in liquid reserves",
      "category": "Prior-to-Docs"
    }
  ]
}
```

## Related Documentation

- **Processing Workflows 3.1:** Processing Workbook (5-C narratives source)
- **Underwriting 4.2:** Conditions Management (creating and tracking conditions)
- **Underwriting 4.3:** Credit Report Analysis (detailed credit review)
- **Processing Workflows 3.3:** Workflow Automation (ECOA timer, credit import)