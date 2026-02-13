---
type: technical-documentation
module: Core Modules
section: Assets & Liabilities
subsection: Liabilities Management
source: SOP analysis + Encompass field documentation
last_updated: 2026-02-13
---

# Encompass: Liabilities Management

## Overview

The Liabilities section documents all borrower monthly debt obligations including credit cards, auto loans, student loans, mortgages, and other recurring payments. These liabilities are critical for calculating the debt-to-income (DTI) ratio, which determines loan qualification [file:1][file:8].

## Access Path

**Primary Navigation:**
1. Borrower Window → **Liabilities** tab
2. Or: Forms menu → **Assets & Liabilities**
3. Or: Consumer Connect Portal → **Liabilities** section [file:4]

## Section 1: Credit Report Liabilities

### Auto-Population from Credit Report

When credit report is ordered and received, Encompass can auto-populate liabilities from credit report data [file:1][file:8].

**Pain Point [file:2]:**
"Credit report PDF appears in E-Folder but liabilities must be manually mapped to the 1003. Scores must be manually verified. No automated liability creation from credit data."

**Manual Process:**
1. Processor opens credit report PDF in File Viewer [file:8]
2. Manually reads each trade line (creditor name, balance, payment)
3. Returns to Liabilities tab
4. Manually creates liability entry for each trade line
5. Types creditor name, account number, balance, monthly payment

**SOP Evidence [file:8]:**
```
[12:10] Click [File Viewer]
System Result: A new window labeled "File Viewer" appears with fields like Name, 
File Type, Date, and Version, which populate with data:
  Name: Credit Report
  File Type: PDF  
  Date: 9/30/2024
  Version: 1.0
```

### Credit Report Data to Extract

From credit report, processor must manually map:
- **Revolving Accounts:** Credit cards, HELOCs, lines of credit
- **Installment Loans:** Auto loans, student loans, personal loans
- **Mortgages:** Current mortgage on primary residence or rental properties
- **Collection Accounts:** Unpaid collections (must be paid off or added to DTI)
- **Monthly Payments:** Minimum payment for revolving, actual payment for installment

## Section 2: Liability Types & Fields

### Revolving Debt (Credit Cards, Lines of Credit)

| Field Name | Data Type | Required | Notes | DTI Treatment |
|------------|-----------|----------|-------|---------------|
| **Creditor Name** | Text (100 char) | Yes | Bank/issuer name | Required |
| **Account Number** | Text (20 char) | Yes | Last 4 digits displayed | Verification |
| **Account Type** | Dropdown | Yes | Credit Card, HELOC, Line of Credit | Classification |
| **Credit Limit** | Currency | No | Maximum credit line | For utilization calc |
| **Current Balance** | Currency | Yes | Outstanding balance | From credit report |
| **Monthly Payment** | Currency | Yes | Minimum payment OR 5% of balance | **Used in DTI** |
| **Months Remaining** | Number | No | Typically ongoing | Not applicable for revolving |
| **To Be Paid Off** | Checkbox | No | If paying off before/at closing | Excluded from DTI if checked |

**DTI Calculation Rule for Revolving:**
- If statement shows monthly payment → Use that amount
- If no payment shown → Use **greater of:**
  - 5% of current balance, OR
  - $10 (minimum)

**Example:**
- Credit card balance: $5,000
- No monthly payment on credit report
- DTI calculation: $5,000 × 5% = $250/month

### Installment Loans (Auto, Personal, Student Loans)

| Field Name | Data Type | Required | Notes | DTI Treatment |
|------------|-----------|----------|-------|---------------|
| **Creditor Name** | Text (100 char) | Yes | Lender name | Required |
| **Account Number** | Text (20 char) | Yes | Last 4 digits | Verification |
| **Account Type** | Dropdown | Yes | Auto, Student, Personal, Boat, RV | Classification |
| **Original Loan Amount** | Currency | No | Initial loan balance | Historical |
| **Current Balance** | Currency | Yes | Payoff amount | From credit report |
| **Monthly Payment** | Currency | Yes | Fixed payment | **Used in DTI** |
| **Months Remaining** | Number | Yes | Payments left until payoff | <10 months may be excluded |
| **To Be Paid Off** | Checkbox | No | If paying off at closing | Excluded from DTI if checked |

**DTI Exclusion Rules:**
- **<10 months remaining:** Can exclude from DTI (investor-dependent)
- **10+ months remaining:** Must include in DTI
- **Deferred student loans:** Must include 1% of balance OR $0 if IBR with $0 payment documented

### Mortgages (Current Housing Payment)

| Field Name | Data Type | Required | Notes | DTI Treatment |
|------------|-----------|----------|-------|---------------|
| **Lender Name** | Text (100 char) | Yes | Mortgage company | Required |
| **Account Number** | Text (20 char) | Yes | Loan number | For payoff request |
| **Mortgage Type** | Dropdown | Yes | Conventional, FHA, VA, HELOC | Classification |
| **Current Balance** | Currency | Yes | Unpaid principal balance | From credit report |
| **Monthly Payment (PITI)** | Currency | Yes | Principal + Interest + Taxes + Insurance | **Used in DTI if not being paid off** |
| **Property Address** | Text (200 char) | Yes | Subject property or rental | Links to REO |
| **To Be Paid Off** | Checkbox | Yes | If subject property (purchase) or refi payoff | Excluded from DTI if checked |

**Special Cases:**
- **Purchase transaction:** Current mortgage on primary residence marked "To Be Paid Off"
- **Refinance:** Existing mortgage on subject property marked "To Be Paid Off"
- **Rental property mortgage:** Not paid off → Remains in DTI (offset by rental income [file:8])

### Alimony, Child Support, Separate Maintenance (Paid)

| Field Name | Data Type | Required | Notes | DTI Treatment |
|------------|-----------|----------|-------|---------------|
| **Payee Name** | Text (100 char) | Yes | Ex-spouse or custodian | Required |
| **Obligation Type** | Dropdown | Yes | Alimony, Child Support, Separate Maintenance | Classification |
| **Monthly Payment** | Currency | Yes | Court-ordered amount | **Always included in DTI** |
| **Months Remaining** | Number | Yes | Until obligation ends | Must continue ≥3 years post-closing |
| **Court Order** | Document reference | Yes | Link to divorce decree | Verification required |

**DTI Treatment:**
- **Always included** in monthly debt obligations
- Must continue for ≥36 months after closing
- If <36 months remaining → Cannot be used to offset income, but still counted as debt

### Other Liabilities

**Additional debt types:**
- **401k Loans:** Monthly payment included in DTI
- **Tax Liens:** Must be in repayment plan (monthly payment included)
- **Judgments:** Must be paid off or in payment plan
- **Collections:** >$250 aggregate must be paid off or included in DTI

## Section 3: DTI Calculation

### Formula

```
Back-End DTI = (Total Monthly Debts + Proposed Housing Payment) ÷ Total Gross Monthly Income

Where:
Total Monthly Debts = Sum of all monthly payments from liabilities
Proposed Housing Payment = PITI + HOA + MI (if applicable)
Total Gross Monthly Income = From Employment & Income section
```

### DTI Qualification Thresholds

| Loan Type | Max Front-End DTI | Max Back-End DTI | Notes |
|-----------|-------------------|------------------|-------|
| **Conventional** | 28% | 43% (50% max with compensating factors) | Fannie/Freddie guidelines |
| **FHA** | 31% | 43% (56.9% with manual underwrite) | HUD 4000.1 |
| **VA** | N/A | No set maximum (residual income method) | VA guidelines |
| **USDA** | 29% | 41% | Rural housing |
| **Jumbo** | 28% | 38-43% | Investor-specific |

**Front-End DTI:**
```
Front-End DTI = Proposed Housing Payment ÷ Total Gross Monthly Income
```

**Back-End DTI:**
```
Back-End DTI = (All Monthly Debts + Housing Payment) ÷ Total Gross Monthly Income
```

### Example Calculation

**Income:**
- Gross monthly income: $10,000

**Liabilities:**
- Credit card 1: $200/month
- Credit card 2: $150/month
- Auto loan: $450/month
- Student loan: $300/month
- Total debts: $1,100/month

**Proposed Housing:**
- Principal & Interest: $1,800
- Property taxes: $400
- Homeowners insurance: $150
- HOA: $100
- Total housing: $2,450/month

**DTI Calculation:**
- Front-End DTI = $2,450 ÷ $10,000 = **24.5%** ✅
- Back-End DTI = ($1,100 + $2,450) ÷ $10,000 = **35.5%** ✅

**Result:** Qualifies for Conventional loan (below 28%/43% thresholds)

## Section 4: Liability Verification Workflow

### Standard Verification Requirements [file:1]

**For Credit Report Debts:**
1. **Credit report** serves as primary verification
2. **If discrepancy:** Request account statement to verify payment amount
3. **If paid off:** Require proof of payoff (zero balance letter or canceled check)

**For Non-Credit Report Debts:**
1. **Alimony/Child Support:** Divorce decree + 12 months canceled checks
2. **401k Loan:** Most recent 401k statement showing loan balance and payment
3. **Tax Liens:** IRS payment agreement letter showing monthly payment

### Red Flags Requiring Explanation

**Credit Report Analysis:**
- **Derogatory items:** Late payments (30/60/90+ days), collections, charge-offs, foreclosures
- **High utilization:** Credit cards >80% of limit (indicates financial stress)
- **Recent inquiries:** Multiple inquiries in last 90 days (credit shopping or financial distress)
- **Undisclosed accounts:** Accounts on credit report not listed by borrower

### Processing Workbook Integration [file:1]

**Liabilities Verification Checklist:**
- [ ] All credit report trade lines reviewed and entered
- [ ] Monthly payments verified (minimum payment or 5% rule applied)
- [ ] Derogatory items documented and explained
- [ ] Accounts "to be paid off" verified with payoff letter or proof
- [ ] Alimony/child support verified with court order
- [ ] DTI calculation complete and within limits
- [ ] Student loans: Deferment/IBR documentation if $0 payment

## Section 5: Special Liability Scenarios

### Student Loans (Complex Rules)

**Status-Specific Treatment:**

| Status | Documentation Required | DTI Treatment |
|--------|------------------------|---------------|
| **Active repayment** | Credit report shows payment | Use payment from credit report |
| **Deferred (in school)** | Deferment letter | Use 1% of balance OR payment from credit report (higher) |
| **Income-Based Repayment (IBR)** | IBR letter showing $0 payment | $0 if documented; else 1% of balance |
| **Forbearance** | Forbearance agreement | Use 1% of balance |
| **Forgiveness program** | Acceptance letter (PSLF, etc.) | Use current payment, even if $0 |

**Example:**
- Student loan balance: $50,000
- Status: Deferred
- Credit report: No payment shown
- DTI treatment: $50,000 × 1% = $500/month

### Co-Signed Debts

**Rules:**
- **If borrower co-signed for someone else:** Include payment in DTI UNLESS 12 months canceled checks prove non-borrower makes payments
- **If someone co-signed for borrower:** Include payment in DTI (borrower is primary obligor)

### Joint Debts (Divorce)

**If divorced and decree states ex-spouse responsible:**
- **Conservative approach:** Include in DTI unless 12 months proof of ex-spouse payment
- **Alternative:** Exclude with divorce decree + 12 months canceled checks from ex-spouse

### Business Debts (Self-Employed)

**If borrower personally guaranteed business debt:**
- Include in DTI (personal guarantee = personal liability)
- Exception: If business cash flow covers debt and CPA letter confirms

## Common Pain Points

### 1. Credit Report Manual Entry [file:2][file:8]

**Issue:** No automated liability import from credit report. Processor must open credit report PDF, read each trade line, manually create liability entries in Liabilities tab.

**Evidence [file:2]:** "Credit report PDF appears in E-Folder but liabilities must be manually mapped to the 1003. Scores must be manually verified. No automated liability creation from credit data."

**Time Cost:** 10-15 minutes per loan to manually transcribe 10-15 trade lines.

### 2. DTI Calculation Errors [file:1]

**Issue:** Manual DTI calculation prone to errors (missed liabilities, wrong payment amounts, incorrect 5% rule application).

**Impact:** Incorrect DTI can lead to loan denial after conditional approval, or worse—compliance violation if loan closes with inaccurate DTI.

### 3. Student Loan Payment Ambiguity [file:2]

**Issue:** Deferred student loans require complex logic (1% of balance unless IBR $0 documented). Processors frequently apply wrong treatment.

**Example:** Borrower has $80,000 student loans in deferment. Processor uses $0 payment (wrong). Should be $800/month, which increases DTI by 8% and may disqualify loan.

### 4. "To Be Paid Off" Confusion [file:1]

**Issue:** Forgetting to check "To Be Paid Off" box for debts being eliminated at closing causes DTI to appear higher than reality.

**Example:** Purchase transaction—borrower's current mortgage ($2,000/month) should be marked "To Be Paid Off" but isn't. DTI calculation incorrectly includes both old and new mortgage payments.

## Integration Points

### Inbound Data Sources

- **Credit Report:** Primary source for most liabilities [file:8]
- **1003 Import:** Liabilities section from Fannie Mae 3.4 XML
- **Consumer Connect Portal:** Borrower self-disclosed debts [file:4]

### Outbound Dependencies

- **1003 URLA:** Liabilities section auto-populates Section 4
- **Underwriting:** DTI calculation displayed in UW-1A form [file:8]
- **Closing:** Payoff amounts for "To Be Paid Off" liabilities flow to CD

### Credit Report Integration Workflow [file:1]

**Proposed Automated Fix:**
```
Temporal Workflow: credit-report-import.ts
Trigger: creditreports INSERT with status='received'

Activities:
1. parseCreditReport - Extract all trade lines from credit report XML/PDF
2. createLiabilities - Auto-INSERT liabilities rows (creditor, balance, payment, type)
3. updateScores - UPDATE applications.customers with bureau scores
4. flagDerogatory - Create underwriting.conditions for derogatory items
5. generateSummary - Create human-readable credit summary in notes
```

## Best Practices

### For Loan Officers

1. **Pre-Qualify Accurately:** Get full credit report during pre-qual to capture all debts (avoid surprises)
2. **Student Loan Discussion:** Warn borrowers upfront about 1% deferred loan treatment
3. **Debt Payoff Strategy:** Advise paying off small debts to improve DTI if borderline

### For Processors

1. **Cross-Reference Credit Report:** Verify every trade line from credit report is entered in Liabilities
2. **5% Rule:** Apply 5% of balance for credit cards with no payment shown
3. **Double-Check "To Be Paid Off":** Verify all closing payoffs are properly flagged
4. **Student Loan Documentation:** Request deferment letters or IBR statements upfront

### For Underwriters

1. **Recalculate DTI:** Always recalculate DTI independently (don't trust processor calculation blindly)
2. **Derogatory Review:** Investigate cause of late payments (isolated incident vs pattern)
3. **Undisclosed Debts:** If credit report shows accounts not disclosed by borrower, request explanation

## Technical Notes

### Data Model

**Primary Table:** `Liabilities` (Encompass database)

**Key Fields (Encompass Field IDs):**
- `CreditorName` - Field ID: 4002
- `AccountNumber` - Field ID: 4004  
- `MonthlyPayment` - Field ID: 1993
- `UnpaidBalance` - Field ID: 272
- `ToBeReimbursed` - Field ID: TBD (To Be Paid Off checkbox)

### API Access

**Endpoint:** `/encompass/v3/loans/{loanId}/applications/{applicationId}/liabilities`

**Methods:**
- `GET` - Retrieve all liabilities
- `POST` - Add new liability
- `PATCH` - Update liability
- `DELETE` - Remove liability

### Credit Report Field Mapping

**From Credit Report XML to Liabilities:**
- `<AccountName>` → `CreditorName`
- `<AccountNumber>` → `AccountNumber`
- `<CurrentBalance>` → `UnpaidBalance`
- `<MonthlyPayment>` → `MonthlyPayment`
- `<AccountType>` → Map to liability type (Revolving, Installment, Mortgage)

## Related Documentation

- **Core Module 1.3:** Employment & Income (DTI numerator calculation)
- **Core Module 1.5:** Assets Management (net worth calculation)
- **Processing Workflows 3.1:** Processing Workbook - Liability Review
- **Underwriting 4.1:** UW-1A Form (DTI analysis)
- **Document Management 2.5:** Credit Report Viewer