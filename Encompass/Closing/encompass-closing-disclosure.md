---
type: technical-documentation
module: Closing & Funding
section: Closing Disclosure
subsection: CD Worksheet & Cash-to-Close
source: SOP analysis + Encompass documentation
last_updated: 2026-02-13
---

# Encompass: Closing Disclosure (CD) Worksheet

## Overview

The Closing Disclosure (CD) is a 5-page federally required form that itemizes all closing costs and final loan terms [file:1][file:6]. The CD Worksheet in Encompass is where closers calculate cash-to-close, prepare the CD, and ensure TRID compliance before delivering to borrowers [file:1][file:6].

## Access Path

**Primary Navigation:**
1. Loan Window → **Closing** menu → **Closing Disclosure** [file:6]
2. Or: Forms → **Est Closing** dropdown → **Cash to Close Estimate** [file:6]
3. Or: Toolbar → **Closing** → **CD Worksheet**

**SOP Evidence [file:6]:**
```
[73:04] Select [Est Closing] dropdown menu
System Result: The dropdown menu expands, showing options

[73:06] Choose [Cash to Close Estimate] from the dropdown
System Result: The dropdown menu closes, and the Cash to Close Estimate 
document is selected

[73:08] Click [View Original File] button
System Result: A new window opens displaying the Cash to Close Estimate document

[73:10] Click [Calculate Cash to Close] button
System Result: The document updates to show the calculated cash to close estimate
```

## Section 1: CD Worksheet Interface

### Multi-Step Manual Process [file:1][file:6]

**Pain Point [file:1]:**
"Est Closing dropdown + Cash to Close + Calculate Cash to Close button + Post button + document selection + Add to Post = new window for each step."

**Current Workflow [file:6]:**
1. Click **[Est Closing]** dropdown [file:6]
2. Select **[Cash to Close Estimate]** [file:6]
3. Click **[View Original File]** → New window opens [file:6]
4. Click **[Calculate Cash to Close]** button → Calculation runs [file:6]
5. Review calculation → Close window
6. Navigate to **Post** section → Generate final CD
7. Select documents to include → Add to Post
8. **Total steps:** 7+ actions across multiple screens/windows

**Proposed Unified Interface [file:1]:**
```
Component: apps/confer-web/src/components/closing/CDWorksheet.tsx
Type: Client Component

Requirements:
- Live cash-to-close calculator that updates as any input changes
- Closing cost line items editor (CFPB categories A-H)
- LE vs CD comparison table (auto-calculated variance with tolerance flagging)
- TRID timer: visual countdown showing days remaining before closing is allowed
- One-click CD generation as PDF
- One-click "Send to Borrower" with delivery method selection (eSign/mail/in-person) 
  and automatic cd_sent_at timestamp
- Signing session initiation (integrated, no separate workflow)

Priority: HIGH
```

## Section 2: Cash-to-Close Calculation

### Components of Cash-to-Close

**Formula:**
```
Cash to Close = 
  Down Payment
  + Closing Costs (Origination + Title + Escrow + Prepaid + Other)
  - Lender Credits
  - Seller Credits
  + Adjustments (Prorations, HOA prepayments, etc.)
```

**Example Calculation:**

| Item | Amount | Notes |
|------|--------|-------|
| **Purchase Price** | $450,000 | From purchase contract |
| **Down Payment (20%)** | $90,000 | Borrower contribution |
| **Loan Amount** | $360,000 | Purchase price - down payment |
| | | |
| **Closing Costs** | | |
| Section A: Origination Charges | $3,600 | 1% origination fee |
| Section B: Services Borrower Cannot Shop | $1,200 | Appraisal, credit report, flood cert |
| Section C: Services Borrower Can Shop | $2,500 | Title, escrow, attorney fees |
| Section E: Taxes & Gov't Fees | $1,500 | Recording fees, transfer tax |
| Section F: Prepaids | $3,200 | Homeowner's insurance, property tax, interest |
| Section G: Initial Escrow Payment | $2,000 | Escrow reserves (2 months) |
| Section H: Other | $500 | HOA transfer fee |
| **Total Closing Costs** | **$14,500** | |
| | | |
| **Credits** | | |
| Lender Credits | -$2,000 | Rate buy-down credit |
| Seller Credits | -$5,000 | Seller pays $5K toward buyer closing costs |
| **Total Credits** | **-$7,000** | |
| | | |
| **CASH TO CLOSE** | **$97,500** | $90,000 + $14,500 - $7,000 |

**Live Calculator Benefit [file:1]:**
- Current: Must click "Calculate Cash to Close" button each time [file:6]
- Proposed: Live updates as inputs change (no button click required)

## Section 3: CFPB Closing Cost Categories

### Section-by-Section Breakdown

The Consumer Financial Protection Bureau (CFPB) standardized CD format into labeled sections A-H [file:1]:

| Section | Category | Examples | Who Chooses? |
|---------|----------|----------|--------------|
| **A** | Origination Charges | Origination fee, underwriting fee, processing fee | Lender sets |
| **B** | Services Borrower Cannot Shop For | Appraisal, credit report, flood certification, tax service | Lender requires specific vendors |
| **C** | Services Borrower Can Shop For | Title insurance, escrow/settlement, attorney, survey | Borrower chooses (or uses lender recommendation) |
| **D** | TOTAL LOAN COSTS | Sum of A + B + C | Auto-calculated |
| **E** | Taxes and Other Government Fees | Recording fees, transfer tax, stamp duty | Government sets |
| **F** | Prepaids | Homeowner's insurance premium, property tax, mortgage interest | Set by 3rd parties |
| **G** | Initial Escrow Payment at Closing | Escrow reserves (property tax, insurance) | Lender calculates |
| **H** | Other | HOA fees, home warranty, etc. | Varies |
| **I** | TOTAL OTHER COSTS | Sum of E + F + G + H | Auto-calculated |
| **J** | TOTAL CLOSING COSTS | D + I (minus Lender Credits) | Auto-calculated |

**Line Items Editor [file:1]:**
Closer can add/edit/delete line items within each section (e.g., add "Attorney Fee: $800" to Section C).

## Section 4: LE vs CD Comparison & Tolerance Violations

### TRID Tolerance Rules

**TRID (TILA-RESPA Integrated Disclosure) requires:**
- Closing costs on CD cannot exceed Loan Estimate (LE) costs by more than specific tolerances
- Violations = lender must refund borrower or re-disclose and wait 3 more days

**Tolerance Categories:**

| Category | Tolerance | Examples | Violation Consequence |
|----------|-----------|----------|----------------------|
| **Zero Tolerance** | 0% increase allowed | Lender fees (origination, underwriting), Transfer tax, Services borrower cannot shop (if lender-required vendor used) | Lender refunds 100% of overage |
| **10% Tolerance** | Total of category cannot increase > 10% | Services borrower can shop for (if lender recommendation not used) | Lender refunds overage beyond 10% |
| **Unlimited Tolerance** | Any increase allowed | Prepaid interest (if closing date changes), Property insurance (if borrower chooses more coverage), Services borrower shops for (if lender recommendation used and borrower chooses different) | No refund required (but must disclose) |

**Example Tolerance Violation:**

| Fee | LE Amount | CD Amount | Tolerance | Overage | Action Required |
|-----|-----------|-----------|-----------|---------|-----------------|
| Origination Fee | $3,000 | $3,500 | Zero | $500 | ❌ Lender must refund $500 or re-disclose |
| Title Insurance | $1,200 | $1,400 | 10% | $200 | ✅ Within 10% tolerance ($1,320 max) = OK |

**Auto-Calculated Variance Table [file:1]:**
Proposed CD Worksheet shows LE vs CD comparison with:
- Green checkmarks for items within tolerance
- Red flags for tolerance violations
- Auto-calculated refund amounts
- One-click "Generate Revised CD" if violations require re-disclosure

## Section 5: TRID Timer & 3-Day Waiting Period

### TRID Compliance Requirements

**Rule:** Borrower must receive CD at least 3 business days before closing.

**Delivery Methods & Timelines:**

| Delivery Method | Receipt Timing | 3-Day Countdown Starts | Example |
|-----------------|----------------|------------------------|---------|
| **eSign** | Same day as sent | Day sent | CD sent Mon 9am → Received Mon 9am → Eligible to close Thu |
| **Mail** | 3 calendar days after mailed | Day sent + 3 calendar days | CD mailed Mon → Received Thu → Eligible to close following Mon |
| **In-Person** | Same day as handed to borrower | Day delivered | CD delivered Mon → Eligible to close Thu |

**Business Days:** Mon-Sat (excluding Sundays and federal holidays)

**Example Timeline (eSign):**
```
Mon 02/10: CD sent to borrower via eSign (9:00 AM)
Mon 02/10: Borrower receives CD (9:05 AM) ← Receipt confirmed
Tue 02/11: Day 1 of waiting period
Wed 02/12: Day 2 of waiting period
Thu 02/13: Day 3 of waiting period
Fri 02/14: ✅ ELIGIBLE TO CLOSE
```

**Visual Countdown [file:1]:**
Proposed CD Worksheet shows:
```
┌─────────────────────────────────────────────┐
│  TRID Timer                                 │
│  CD Sent: Mon 02/10 9:00 AM (eSign)        │
│  Eligible to Close: Fri 02/14              │
│  Days Remaining: 2 days                     │
│  ████████████░░░░ 75% Complete              │
└─────────────────────────────────────────────┘
```

**Automated TRID Timer Workflow [file:1]:**
```
Workflow: temporal/workflows/trid-timer.ts
Triggers:
- applications.cd_sent_at UPDATE

Activities:
1. calculateEligibleDate - Based on delivery method (eSign=3 biz days, 
   mail=3 biz days + 3 calendar days, in-person=same day)
2. scheduleGate - Block closing/funding actions until eligible date
3. sendReminders - 1-day-before reminder to closer
4. releaseGate - On eligible date, update applications to allow closing/funding

Priority: HIGH CRITICAL (compliance)
```

**See:** Processing Workflows 3.3: Workflow Automation → TRID Timer for full implementation details.

## Section 6: Changes Requiring CD Re-Disclosure

### When Must CD Be Re-Disclosed?

**TRID requires re-disclosure (and new 3-day waiting period) if:**

| Change Type | Threshold | Example | Consequence |
|-------------|-----------|---------|-------------|
| **APR increases** | > 0.125% (1/8 of 1%) | APR was 6.500%, now 6.750% | ❌ Re-disclose, wait 3 more days |
| **Loan amount increases** | Any increase | Loan was $360K, now $365K | ❌ Re-disclose, wait 3 more days |
| **Loan product changes** | Any change | Fixed-rate → ARM | ❌ Re-disclose, wait 3 more days |
| **Prepayment penalty added** | Penalty added when LE had none | No penalty on LE, penalty on CD | ❌ Re-disclose, wait 3 more days |

**Changes that DO NOT require re-disclosure:**
- Closing costs within tolerance (see Section 4)
- Closing date changes (unless impacts prepaid interest significantly)
- Minor typo corrections

**Example Re-Disclosure Scenario:**
```
Original CD sent: Mon 02/10
Eligible to close: Fri 02/14

Change on Wed 02/12: APR increased from 6.500% to 6.750% (0.250% increase)
Trigger: APR change > 0.125% → Re-disclosure required

Revised CD sent: Wed 02/12
New eligible to close: Mon 02/17 (3 business days: Thu, Fri, Mon)
Impact: Closing delayed 3 days
```

## Section 7: CD Generation & Delivery

### One-Click CD Generation [file:1]

**Current Manual Process [file:6]:**
1. Closer fills out CD Worksheet fields manually
2. Clicks "Calculate Cash to Close" [file:6]
3. Reviews calculation
4. Navigates to Forms → Closing Disclosure
5. Clicks "Generate CD" → PDF created
6. Manually opens CD PDF to review
7. Saves CD to E-Folder
8. Manually composes email to borrower (via Gmail [file:2])
9. Attaches CD PDF to email
10. Sends email → Manually records delivery timestamp

**Proposed One-Click Workflow [file:1]:**
1. Closer clicks **[Generate & Send CD]** button
2. Modal appears: "Delivery method?" (eSign / Mail / In-Person)
3. Closer selects **[eSign]**
4. System:
   - Generates CD PDF from worksheet data
   - Saves CD to E-Folder (Documents → Closing category)
   - Sends CD to borrower via eSign platform (DocuSign [file:1])
   - Records `cd_sent_at` timestamp → Starts TRID timer [file:1]
   - Calculates eligible closing date
   - Notifies closer: "CD sent. Eligible to close: Fri 02/14."
5. **Total time:** 10 seconds (vs 10 minutes manually)

### Delivery Confirmation

**eSign Delivery:**
- Borrower receives email with DocuSign link
- Borrower opens CD, reviews, acknowledges receipt
- DocuSign confirms receipt → Timestamp recorded
- System updates `cd_received_at` timestamp
- TRID timer starts from confirmed receipt

**Mail Delivery:**
- Closer selects "Mail" → System assumes receipt = 3 calendar days after sent
- TRID timer starts from sent date + 3 calendar days
- No electronic confirmation (complies with TRID mailing rule)

**In-Person Delivery:**
- Closer selects "In-Person" → Records delivery at closing appointment
- TRID timer starts same day
- Eligible to close same day (if no other delays)

## Section 8: Signing Session Initiation

### Integrated E-Signing [file:1]

**Current Separate Workflow:**
- After CD sent, closer must separately initiate signing session
- Signing managed via Simplifile (external platform) [file:1]
- Closer sends email link to borrower
- Borrower signs via Simplifile
- Critical failure point: "Leave Session" must be clicked to sync signed docs back to Encompass [file:1]
- If forgotten, signed docs don't appear in loan file → Funding delayed

**Proposed Integrated Workflow [file:1]:**
```
Component: CD Worksheet includes "Send to Borrower" button with delivery 
method selection

Workflow:
1. Closer generates CD → Sends via eSign
2. System auto-creates signing session with all closing docs:
   - Closing Disclosure (CD)
   - Note (promissory note)
   - Deed of Trust (mortgage)
   - Any state-required disclosures
3. Borrower receives single email: "Your closing documents are ready to sign"
4. Borrower clicks link → DocuSign opens with all docs
5. Borrower signs all docs in one session
6. DocuSign auto-syncs signed docs to Encompass (no "Leave Session" required)
7. System notifies closer: "All docs signed. Ready to fund."
```

**confer-web Implementation [file:1]:**
```
Requirement: DocuSign or Dropbox Sign API integration
- Signing session tracking in signing_sessions table
- Auto-sync signed documents (auto-appear in loan file, no manual "Leave Session")
- Signing progress visible in loan dashboard
- Priority: MEDIUM
```

## Section 9: Common CD Worksheet Pain Points

### 1. Multi-Step Calculation Process [file:1][file:6]

**Issue:** Must click "Calculate Cash to Close" button each time [file:6]. No live updates.

**Evidence [file:6]:** `[73:10] Click [Calculate Cash to Close] button - System Result: The document updates`

**Proposed Fix [file:1]:** Live calculator that updates as inputs change (no button click required).

### 2. Manual LE vs CD Comparison

**Issue:** Closer must manually compare LE to CD line-by-line to check for tolerance violations.

**Time Cost:** 10-15 minutes per loan (comparing 30+ line items).

**Proposed Fix [file:1]:** Auto-calculated variance table with:
- Green checkmarks for items within tolerance
- Red flags for violations
- Auto-calculated refund amounts

### 3. No Visual TRID Timer [file:1]

**Issue:** Closer manually calculates 3-day waiting period using calendar.

**Risk:** Human error = closing scheduled too early = TRID violation.

**Proposed Fix [file:1]:** Visual countdown showing days remaining before eligible to close.

### 4. New Window for Each Step [file:1][file:6]

**Issue:** "New window for each step" [file:1]. CD opens in separate window [file:6].

**Evidence [file:6]:** `[73:08] Click [View Original File] - System Result: A new window opens`

**Proposed Fix [file:1]:** All-in-one CD Worksheet interface (no new windows).

### 5. Manual Email Delivery [file:2]

**Issue:** Closer composes email in Gmail (external tool) [file:2], attaches CD manually, sends, then manually records delivery timestamp.

**Time Cost:** 5-10 minutes per CD delivery.

**Proposed Fix [file:1]:** One-click "Send to Borrower" with auto-recorded `cd_sent_at` timestamp.

## Section 10: CD vs Final HUD-1 (Historical)

### TRID Replaced HUD-1 in 2015

**Before TRID (pre-2015):**
- **HUD-1 Settlement Statement** used for closing cost disclosure
- Delivered at closing (not 3 days before)
- Different format (2 pages, buyer/seller columns)

**After TRID (2015-present):**
- **Closing Disclosure (CD)** replaced HUD-1 for most residential loans
- Must be delivered 3 business days before closing
- Standardized 5-page format (CFPB design)
- Combined TILA (Truth in Lending Act) and RESPA (Real Estate Settlement Procedures Act) disclosures

**Exception:** HUD-1 still used for:
- Reverse mortgages
- Home Equity Lines of Credit (HELOCs)
- Mobile home loans (if property is not real estate)

## Integration Points

### Inbound Data Sources

- **Loan Estimate (LE):** Initial disclosures sent earlier → CD must match within tolerances
- **Processing Workbook:** Loan details, borrower info, property data flow to CD
- **Underwriting:** Loan terms, interest rate, APR from UW approval
- **Title/Escrow:** Title insurance fees, escrow fees from 3rd parties

### Outbound Dependencies

- **TRID Timer Workflow:** `cd_sent_at` timestamp triggers TRID timer [file:1]
- **Disbursement Manager:** CD finalized → Triggers funding workflow [file:1]
- **E-Signing Platform:** CD sent to DocuSign for borrower signature [file:1]
- **Loan Funding:** All conditions cleared + CD 3-day wait complete → Loan can fund

## Best Practices

### For Closers

1. **Double-Check APR:** APR miscalculation = re-disclosure + 3-day delay
2. **Review Tolerance Violations Early:** Catch violations before final CD (easier to correct)
3. **Send CD as Early as Possible:** Don't wait until last minute (buffer for re-disclosure if needed)
4. **Confirm Delivery Method:** eSign = fastest (3 days), Mail = slowest (6+ days)
5. **Use Live Calculator:** Update CD as costs change (don't wait until final day)

### For Processors

1. **Accurate LE Upfront:** LE accuracy = fewer CD changes = fewer re-disclosures
2. **Lock Closing Costs Early:** Finalize title, escrow, attorney fees before CD sent
3. **Coordinate with Title/Escrow:** Confirm all fees before generating CD

## Technical Notes

### Data Model

**Primary Table:** `closing_disclosures`

**Key Fields:**
- `id` - Unique CD ID
- `loan_id` - Foreign key to applications table
- `cd_sent_at` - Timestamp (CD delivered to borrower)
- `cd_received_at` - Timestamp (borrower confirmed receipt)
- `delivery_method` - Enum (eSign, Mail, In-Person)
- `eligible_closing_date` - Date (TRID 3-day calculation)
- `cash_to_close` - Decimal (final calculated amount)
- `tolerance_violations` - JSONB (list of violation details)
- `file_path` - S3 URL (PDF storage)

### API Access

**Endpoint:** `POST /api/v1/loans/{loanId}/closingDisclosures`

**Request Body:**
```json
{
  "delivery_method": "eSign",
  "closing_costs": {
    "section_a_origination": 3600.00,
    "section_b_services_cannot_shop": 1200.00,
    "section_c_services_can_shop": 2500.00,
    "section_e_taxes_govt_fees": 1500.00,
    "section_f_prepaids": 3200.00,
    "section_g_escrow": 2000.00,
    "section_h_other": 500.00
  },
  "down_payment": 90000.00,
  "lender_credits": 2000.00,
  "seller_credits": 5000.00
}
```

**Response:**
```json
{
  "id": 789,
  "loan_id": 123456,
  "cash_to_close": 97500.00,
  "cd_sent_at": "2026-02-10T09:00:00Z",
  "eligible_closing_date": "2026-02-14",
  "file_path": "s3://closing-disclosures/123456_CD_2026-02-10.pdf",
  "tolerance_violations": []
}
```

## Related Documentation

- **Processing Workflows 3.3:** Workflow Automation (TRID timer workflow)
- **Closing 5.2:** Disbursement Manager (funding after CD complete)
- **Core Modules 1.1:** Pipeline Management (loan status tracking)
- **Underwriting 4.2:** Conditions Management (conditions must be cleared before closing)