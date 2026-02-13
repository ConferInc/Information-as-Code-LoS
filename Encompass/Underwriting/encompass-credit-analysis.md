---
type: technical-documentation
module: Underwriting
section: Credit Analysis
subsection: Credit Report Review & Scoring
source: SOP analysis + Encompass documentation
last_updated: 2026-02-13
---

# Encompass: Credit Report Analysis

## Overview

Credit reports are one of the most critical documents in underwriting, containing credit scores, trade lines (debts), payment history, and derogatory items (collections, judgments) [file:1][file:8]. Underwriters review credit reports to assess borrower creditworthiness and identify red flags.

## Section 1: Credit Report Access

### File Viewer Window [file:8]

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

**Pain Point:** Credit report opens in separate File Viewer window (not embedded in UW-1A) [file:2][file:8].

**Multi-Window Problem:**
- UW-1A form = Window 1
- Credit report PDF = Window 2 (File Viewer)
- Underwriter alt-tabs to compare credit report data against UW-1A fields

**Proposed Fix [file:1]:**
"Credit Analysis tab: embedded PDF viewer (no new window)"

## Section 2: Credit Scoring Basics

### The Three Bureau System

**Credit Bureaus:**
1. **Experian**
2. **TransUnion**
3. **Equifax**

**Why 3 Bureaus?**
- Each bureau maintains independent database of consumer credit history
- Creditors may report to 1, 2, or all 3 bureaus
- Scores can vary by 20-50 points across bureaus

### Mid-Score Calculation [file:1]

**Rule:** Use middle (median) score of 3 bureau scores.

**Example:**

| Bureau | Score |
|--------|-------|
| Experian | 740 |
| TransUnion | 735 |
| Equifax | 738 |
| **Mid-Score** | **738** ← Middle value |

**Logic:**
- Sort scores: 735, 738, 740
- Middle value: **738**
- **Not** average (737.7), but median

**If Only 2 Scores Available:**
- Use lower of the two
- Example: 740 and 735 → Use 735

**If Only 1 Score Available:**
- Use that score (rare—most lenders require 3-bureau pulls)

### Credit Score Ranges

| Score Range | Rating | Lending Decision |
|-------------|--------|------------------|
| **800-850** | Excellent | Approved, best rates |
| **740-799** | Very Good | Approved, good rates |
| **670-739** | Good | Approved, standard rates |
| **580-669** | Fair | Manual review, higher rates |
| **300-579** | Poor | Likely denied or subprime |

**Minimum Scores by Loan Type:**
- **Conventional:** 620 minimum (Fannie/Freddie)
- **FHA:** 580 minimum (500 with 10% down)
- **VA:** No minimum (but lender overlays often require 620+)
- **USDA:** 640 minimum

## Section 3: Credit Report Components

### Trade Lines (Accounts)

**What is a Trade Line?**
A trade line is any credit account reported to credit bureaus: credit cards, auto loans, mortgages, student loans, etc.

**Trade Line Data:**

| Field | Description | Example |
|-------|-------------|---------|
| **Creditor** | Company extending credit | Chase Bank |
| **Account Type** | Revolving or Installment | Revolving (credit card) |
| **Balance** | Current amount owed | $5,000 |
| **Credit Limit** | Max borrowing (revolving only) | $15,000 |
| **Monthly Payment** | Minimum or scheduled payment | $150 |
| **Open Date** | When account opened | 01/2020 |
| **Status** | Current, Late, Closed, Charge-off | Current |
| **Payment History** | 24-month record of on-time/late | 24 on-time payments |

**Example Trade Lines:**

| Creditor | Type | Balance | Limit | Payment | Status |
|----------|------|---------|-------|---------|--------|
| Chase Credit Card | Revolving | $5,000 | $15,000 | $150 | Current |
| Wells Fargo Auto | Installment | $18,000 | N/A | $450 | Current |
| Capital One Card | Revolving | $3,500 | $10,000 | $105 | Current |

### Revolving vs Installment Credit

**Revolving Credit:**
- Credit cards, HELOCs (Home Equity Lines of Credit)
- No fixed # of payments
- Balance fluctuates month-to-month
- **Credit Utilization** matters: `Balance / Limit`
  - Example: $5,000 balance / $15,000 limit = 33% utilization
  - **Best practice:** Keep utilization < 30%

**Installment Credit:**
- Auto loans, student loans, mortgages, personal loans
- Fixed # of payments (e.g., 60 months for auto loan)
- Balance decreases each month until paid off
- No credit limit (balance = original loan amount)

### Credit Utilization

**Formula:** `Total Revolving Balance / Total Revolving Limit × 100`

**Example:**
- Chase card: $5,000 / $15,000 = 33%
- Capital One card: $3,500 / $10,000 = 35%
- **Total:** $8,500 / $25,000 = **34% utilization**

**Impact on Credit Score:**
- < 10%: Excellent
- 10-30%: Good
- 30-50%: Fair (negative impact on score)
- 50%+: Poor (significant negative impact)

**Why It Matters:**
High utilization suggests borrower is over-leveraged (relying heavily on credit).

## Section 4: Derogatory Items

### Types of Derogatory Items

**Derogatory** = Negative credit event that impacts creditworthiness.

| Type | Description | Impact on Score | Duration on Report |
|------|-------------|-----------------|---------------------|
| **Late Payment** | Payment 30+ days past due | -50 to -100 points | 7 years |
| **Collection** | Debt sent to collections agency | -100 to -150 points | 7 years |
| **Charge-off** | Creditor writes off debt as loss | -150 to -200 points | 7 years |
| **Judgment** | Court-ordered debt repayment | -150 to -200 points | 7 years |
| **Foreclosure** | Home foreclosure | -200 to -300 points | 7 years |
| **Bankruptcy (Chapter 7)** | All debts discharged | -300+ points | 10 years |
| **Bankruptcy (Chapter 13)** | Repayment plan | -200 to -250 points | 7 years |

### Common Derogatory: Medical Collections

**Example:**
- Borrower has $250 medical collection from 2022 (hospital bill)
- Collection paid in full 01/2024
- **UW Decision:** Acceptable with Letter of Explanation (LOE)

**Letter of Explanation (LOE):**
Borrower writes short narrative explaining:
- What happened? "I had emergency room visit in 2022. Bill went to collections because I moved and didn't receive it."
- How resolved? "I paid in full in January 2024 when I discovered it on my credit report."
- Why it won't happen again? "I've set up autopay for all medical bills and monitor credit regularly."

**UW Analysis:**
- Medical collections < $500 generally acceptable (not indicative of poor money management)
- Paid collections better than unpaid (shows borrower addressed debt)
- If unpaid: UW may require payment before approval

### Late Payments

**30-Day Late:** Payment made 30-59 days after due date
**60-Day Late:** Payment made 60-89 days after due date
**90-Day Late:** Payment made 90+ days after due date

**Impact:**
- One 30-day late in last 12 months: Minor concern (may require LOE)
- Multiple 30-day lates in last 12 months: Red flag
- Any 60+ day late in last 24 months: Significant red flag
- Pattern of late payments: Likely denial

**UW Threshold:**
Most lenders allow:
- No more than 2 late payments in last 12 months
- No late payments in last 6 months (preferred)
- No 60+ day lates in last 24 months

## Section 5: Automated Credit Import [file:1]

### Manual vs Automated Trade Line Entry

**Current Manual Process:**
1. Credit report PDF appears in E-Folder [file:8]
2. Processor opens credit report in File Viewer (new window) [file:8]
3. Processor reads 15 trade lines from PDF
4. Processor navigates to Liabilities section in Borrower form (separate window)
5. Processor manually types each trade line:
   - Creditor: "Chase Credit Card"
   - Balance: $5,000
   - Monthly Payment: $150
   - Account Type: Revolving
6. Repeat 15 times (1-2 minutes per trade line = 15-30 minutes total)

**Proposed Automated Workflow [file:1]:**
```
Workflow: temporal/workflows/credit-report-import.ts
Trigger: creditreports INSERT with status = 'received'

Activities:
1. parseCreditReport - Extract all trade lines, scores, inquiries from 
   credit report data (XML or PDF)
2. createLiabilities - Auto-INSERT liabilities rows from trade lines 
   (creditor, balance, payment, type)
3. updateScores - UPDATE application.customers with bureau scores and 
   creditreports with min/mid
4. flagDerogatory - Create underwriting.conditions for any derogatory items 
   (lates, collections, judgments)
5. generateSummary - Create a human-readable credit summary in notes

Priority: HIGH
```

**Time Saved:** 15-30 minutes per credit report

**See:** Processing Workflows 3.3: Workflow Automation → Credit Report Auto-Import for full implementation details.

## Section 6: Credit Inquiries

### Hard vs Soft Inquiries

**Hard Inquiry (Hard Pull):**
- Triggered when borrower applies for credit (credit card, loan, mortgage)
- Lender pulls credit report to make lending decision
- **Impacts credit score:** -5 to -10 points per inquiry
- Stays on report for 2 years

**Soft Inquiry (Soft Pull):**
- Triggered when borrower checks own credit or receives pre-approval offers
- Does NOT impact credit score
- Not visible to lenders (only visible to borrower)

### Shopping for Mortgage Rates

**Rate Shopping Window:**
- FICO scoring models allow 14-45 day window for mortgage shopping
- Multiple mortgage inquiries within window = counted as 1 inquiry
- **Benefit:** Borrower can shop rates without damaging credit

**Example:**
- 02/01: Lender A pulls credit
- 02/10: Lender B pulls credit
- 02/15: Lender C pulls credit
- **Impact:** All 3 inquiries counted as 1 (within 14-day window)

### Too Many Inquiries = Red Flag

**UW Concern:**
- 5+ inquiries in last 6 months → Borrower shopping for credit aggressively
- **Why concerning?** May indicate financial distress or plans to take on more debt

**UW Action:**
- Request Letter of Explanation (LOE)
- Verify no new accounts opened (borrower shopping, not opening accounts)

## Section 7: Credit Report Fraud Checks

### Red Flags for Fraud

**Identity Theft Indicators:**
- Unknown trade lines (accounts borrower doesn't recognize)
- Incorrect addresses in credit report
- SSN mismatch (credit report SSN ≠ application SSN)
- Multiple recent inquiries from unusual lenders

**Document Alteration Indicators:**
- Inconsistent fonts in PDF (Photoshop editing)
- Misaligned numbers or text
- Credit scores that don't match trade line quality

**UW Action:**
- Cross-reference credit report against borrower's application
- Request verification of any unknown trade lines
- Flag suspicious items in Fraud Report [file:8]

## Section 8: Credit Report Versions

### Multiple Credit Pulls

**Why Multiple Versions?**
- Initial pre-approval credit pull (3-6 months before closing)
- Final credit pull (within 30 days of closing)

**Credit Re-Pull Requirement:**
- Credit report expires after 120 days
- If closing delayed, must re-pull credit before closing
- **Risk:** New derogatory items may appear (late payments, new collections)

**What UW Checks on Re-Pull:**
- Score changed? (if dropped significantly, may require re-underwriting)
- New late payments? (red flag—may suspend approval)
- New trade lines? (borrower opened new credit—violates approval terms)
- New inquiries? (borrower shopping for more credit)

## Common Pain Points

### 1. Manual Trade Line Entry

**Issue:** Processor manually types 15 trade lines from credit report PDF into Liabilities section (15-30 minutes per loan).

**Proposed Fix [file:1]:** Credit-report-import.ts Temporal workflow auto-creates trade lines.

### 2. Credit Report in Separate Window [file:8]

**Issue:** Credit report opens in File Viewer (window 2), UW-1A in window 1 → Alt-tab hell.

**Evidence [file:8]:** `[12:10] Click [File Viewer] - System Result: A new window labeled "File Viewer" appears`

**Proposed Fix [file:1]:** Embedded PDF viewer in Credit Analysis tab (no new window).

### 3. No Auto-Flagging of Derogatory Items

**Issue:** Underwriter manually reads credit report looking for collections, late payments, judgments.

**Proposed Fix [file:1]:** Credit-report-import.ts workflow auto-creates conditions for any derogatory items.

### 4. Mid-Score Calculation Manual Verification

**Issue:** Underwriter manually checks 3 bureau scores to confirm mid-score is correct.

**Proposed Fix [file:1]:** Credit-report-import.ts workflow auto-calculates mid-score and updates application.

## Integration Points

### Inbound Data Sources

- **Credit Bureau API:** XML or PDF credit report data from Experian, TransUnion, Equifax
- **Credit Vendor:** Point Services, Credco, etc. (third-party credit reporting companies)

### Outbound Dependencies

- **UW Decision Panel:** Credit scores and trade lines display in Credit Analysis tab [file:8]
- **Liabilities Section:** Trade lines auto-populate Liabilities form [file:1]
- **Conditions Management:** Derogatory items auto-create conditions [file:1]

## Best Practices

### For Underwriters

1. **Always Review Full Report:** Don't rely on scores alone—read trade lines and derogatory items
2. **Check for Fraud:** Look for mismatched SSN, unknown accounts, suspicious inquiries
3. **Compare to Application:** Credit report address = application address?
4. **Verify Mid-Score:** Manually confirm mid-score calculation (easy to catch data entry errors)
5. **Request LOEs Proactively:** For any derogatory item, request LOE upfront (saves time)

### For Processors

1. **Pull Credit Early:** Don't wait until week before closing (may need time to resolve issues)
2. **Monitor Expiration:** Credit reports expire after 120 days—re-pull if closing delayed
3. **Flag Concerns Early:** If you see derogatory items, flag to UW immediately (don't wait for UW to discover)

## Technical Notes

### Data Model

**Primary Table:** `credit_reports`

**Key Fields:**
- `id` - Unique credit report ID
- `loan_id` - Foreign key to applications table
- `experian_score` - Integer (300-850)
- `transunion_score` - Integer (300-850)
- `equifax_score` - Integer (300-850)
- `mid_score` - Integer (calculated from 3 bureau scores)
- `file_path` - S3 URL (PDF storage)
- `pulled_at` - Timestamp
- `expires_at` - Timestamp (pulled_at + 120 days)

**Secondary Table:** `liabilities` (trade lines)

**Key Fields:**
- `id` - Unique trade line ID
- `loan_id` - Foreign key to applications table
- `credit_report_id` - Foreign key to credit_reports table
- `creditor` - Text (e.g., "Chase Credit Card")
- `account_type` - Enum (Revolving, Installment)
- `balance` - Decimal
- `monthly_payment` - Decimal
- `credit_limit` - Decimal (NULL for installment)
- `status` - Enum (Current, Late, Closed, Charge-off, Collection)
- `derogatory` - Boolean (TRUE if late/collection/charge-off)

### API Access

**Endpoint:** `POST /api/v1/loans/{loanId}/creditReports`

**Request Body:**
```json
{
  "vendor": "Point Services",
  "borrower_ssn": "123-45-6789",
  "borrower_name": "Laylene Jeune",
  "borrower_address": "123 Main St, Anytown, VA 12345"
}
```

**Response:**
```json
{
  "id": 456,
  "loan_id": 123456,
  "experian_score": 740,
  "transunion_score": 735,
  "equifax_score": 738,
  "mid_score": 738,
  "file_path": "s3://credit-reports/123456.pdf",
  "pulled_at": "2026-02-10T09:00:00Z",
  "expires_at": "2026-06-10T09:00:00Z",
  "trade_lines": [
    {
      "creditor": "Chase Credit Card",
      "account_type": "Revolving",
      "balance": 5000.00,
      "monthly_payment": 150.00,
      "credit_limit": 15000.00,
      "status": "Current"
    }
  ]
}
```

## Related Documentation

- **Underwriting 4.1:** UW Decision Panel (credit analysis tab)
- **Processing Workflows 3.3:** Workflow Automation (credit-report-import.ts)
- **Core Modules 1.2:** Borrower Information (liabilities section)
- **Underwriting 4.2:** Conditions Management (auto-flagging derogatory items)