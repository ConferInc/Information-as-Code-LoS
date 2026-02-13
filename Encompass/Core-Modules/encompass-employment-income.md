---
type: technical-documentation
module: Core Modules
section: Borrower Information Management
subsection: Employment & Income
source: SOP analysis + Encompass field documentation
last_updated: 2026-02-13
---

# Encompass: Employment & Income

## Overview

The Employment & Income section captures all borrower employment history, income sources, and income calculations necessary for debt-to-income (DTI) ratio qualification. This form is accessed via the Employment tab within the Borrower window or as a separate input form [file:4][file:7].

## Access Path

**Primary Navigation:**
1. Borrower Window → **Employment** tab
2. Or: Forms menu → **Employment Information**
3. Or: Processing Workbook → **Employment Verification** section [file:1]

## Section 1: Current Employment

### Employer Information

| Field Name | Data Type | Required | Validation | Notes |
|------------|-----------|----------|------------|-------|
| **Employer Name** | Text (100 char) | Yes | Free text | Company/organization name |
| **Address** | Text (100 char) | Yes | Street address | [file:7] shows redundant entry issue |
| **City** | Text (50 char) | Yes | Alpha + spaces | [file:7] "Anytown" re-entered |
| **State** | Dropdown | Yes | 50 US states | [file:7] "VA" re-entered |
| **Zip Code** | Text (5-9 digits) | Yes | ##### or #####-#### | [file:7] "12345" re-entered |
| **Phone** | Phone | Yes | (###) ###-#### | Employer contact number |

**Pain Point [file:7]:** Processor typed same address, city, state, zip already entered in Borrower form—duplicate data entry with zero auto-fill.

### Position Details

| Field Name | Data Type | Required | Options/Format | SOP Evidence |
|------------|-----------|----------|----------------|--------------|
| **Occupation/Title** | Text (100 char) | Yes | Free text | [file:7] "Manager" |
| **Employment Status** | Dropdown | Yes | Employed, Self-Employed, Retired, Unemployed | [file:7] "Yes" (Employed) |
| **Start Date** | Date (MM/YYYY) | Yes | Month/Year format | Used for tenure calculation |
| **Years on Job** | Number | Auto-calc | Calculated from Start Date | System auto-populates |
| **Years in Profession** | Number | No | Manual entry if different from current job | For job-hopping scenarios |

### Income Fields

| Field Name | Data Type | Required | Format | Calculation |
|------------|-----------|----------|--------|-------------|
| **Base Income** | Currency | Yes | $#,###.## | Monthly amount |
| **Overtime** | Currency | No | $#,###.## | Average monthly overtime |
| **Bonuses** | Currency | No | $#,###.## | Annual bonus ÷ 12 |
| **Commissions** | Currency | No | $#,###.## | Average monthly commission |
| **Military Entitlements** | Currency | No | $#,###.## | If applicable |
| **Other Income** | Currency | No | $#,###.## | Specify source in notes |
| **Total Monthly Income** | Currency | Auto-calc | Sum of above | Used for DTI |

### Employment Type Specifications

**W-2 Employee:**
- Requires: Pay stubs (most recent 30 days), W-2s (2 years), VOE (Verification of Employment)
- Income stability: 2-year history required

**Self-Employed:**
- Requires: Tax returns (2 years personal + business), CPA letter, YTD P&L
- Income calculation: Average of 2 years after depreciation add-back

**Retired:**
- Requires: Pension award letter, Social Security statement, retirement account statements
- Income sources: SS, pension, 401k distributions, annuities

## Section 2: Previous Employment

**Requirement:** If current employment < 2 years, previous employment history required to total 2 years [file:1].

### Fields per Previous Employer

| Field Name | Required | Notes |
|------------|----------|-------|
| **Employer Name** | Yes | Full company name |
| **Address** | Yes | Complete address |
| **Phone** | Yes | Verification contact |
| **Position** | Yes | Job title |
| **Start Date** | Yes | MM/YYYY format |
| **End Date** | Yes | MM/YYYY format |
| **Monthly Income** | Yes | Base income only (no bonus/OT for past jobs) |
| **Reason for Leaving** | No | Optional notes field |

### Employment Gap Handling

**If gap > 1 month between jobs:**
- **Explanation Required:** Free text field to document reason (e.g., "Relocated," "Laid off - actively seeking employment")
- **Impact on Qualification:** Gaps > 6 months may require additional reserves or explanation letter

## Section 3: Additional Income Sources

**Purpose:** Capture non-employment income used for qualification

### Income Type Options

| Income Type | Documentation Required | Stability Requirement |
|-------------|------------------------|----------------------|
| **Alimony** | Divorce decree + 3 months bank statements | Must continue ≥3 years post-closing |
| **Child Support** | Court order + 3 months bank statements | Must continue ≥3 years post-closing |
| **Social Security** | Award letter + bank statements | Permanent/continuous |
| **Disability** | Award letter + bank statements | Permanent preferred |
| **Rental Income** | Lease agreements + tax returns (Sch E) | 2-year history or 25% equity in rental |
| **Investment Income** | 1099-INT, 1099-DIV, brokerage statements | 2-year history |
| **Trust Income** | Trust documents + distribution schedule | Verified continuity |
| **Other** | Custom documentation | Underwriter discretion |

### Rental Income Calculation [file:8]

**If borrower has Real Estate Owned:**

1. Gross monthly rent (from lease) = $X
2. Subtract: PITIA (Principal, Interest, Taxes, Insurance, Association fees) = $Y
3. Net rental income = $X - $Y
4. **Qualifying income:**
   - If positive: 75% of net rental income
   - If negative: 100% of negative cash flow (added to debts)

**SOP Evidence [file:8]:**
```
Click [Real Estate Owned] section
System Result: Checkbox next to "Is a Real Estate Owned?" changes from "No" to "Yes"
```

System automatically prompts for rental income calculation when REO indicated.

## Section 4: Income Verification Workflow

### Standard Verification Documents [file:1]

**For W-2 Employees:**
1. **Pay Stubs:** Most recent 30 days (must show YTD earnings)
2. **W-2 Forms:** Most recent 2 years
3. **VOE (Verification of Employment):** Completed by employer OR equivalent (Form 1005 or Attestation)
4. **Tax Returns:** 2 years (if commission/bonus income > 25% of total)

**For Self-Employed:**
1. **Personal Tax Returns (1040):** 2 years with all schedules
2. **Business Tax Returns:** 2 years (1120/1120S/1065/Schedule C)
3. **CPA Letter:** Signed attestation of continued self-employment
4. **Year-to-Date P&L:** CPA-prepared or borrower-signed
5. **Business License:** Copy for verification

### Processing Workbook Integration [file:1]

**Employment Verification Checklist:**

- [ ] 2-year employment history complete
- [ ] Income sources documented and verified
- [ ] Pay stubs match stated income
- [ ] W-2s/1099s match tax returns
- [ ] VOE returned (if applicable)
- [ ] Self-employed: CPA letter received
- [ ] Income calculation worksheet complete

**Auto-completion rule [file:1]:** System auto-marks this section complete when all required docs have `status = 'reviewed'` in E-Folder.

## Section 5: Income Calculation Worksheet

**Purpose:** Document how processor calculated qualifying monthly income

### Calculation Methods

**Salary/Hourly:**
- **Annual Salary:** Annual ÷ 12 = Monthly
- **Hourly:** Hourly rate × Hours/week × 52 ÷ 12 = Monthly

**Overtime/Bonus (Variable Income):**
- **2-Year Average:** (Year 1 + Year 2) ÷ 24 months = Monthly avg
- **Declining Income:** If Year 2 < Year 1, use Year 2 only (conservative approach)
- **Stability Test:** If income decreasing >20%, may not qualify

**Self-Employed:**
```
Adjusted Gross Income (from 1040)
+ Depreciation (non-cash expense add-back)
+ Depletion
+ Meals & Entertainment (50% add-back)
- Decline in income (if decreasing trend)
= Qualifying Monthly Income ÷ 12
```

### DTI Calculation

**Formula:**
```
DTI = (Total Monthly Debt Payments + Proposed Housing Payment) ÷ Total Monthly Income

Where:
- Total Monthly Debt = Credit cards + Auto loans + Student loans + Other debts
- Proposed Housing Payment = PITI + HOA + MI (if applicable)
```

**Qualification Thresholds:**
- **Conventional:** ≤43% (50% max with compensating factors)
- **FHA:** ≤43% front-end, ≤56.9% back-end
- **VA:** No set limit (uses residual income method)

## Common Pain Points

### 1. Manual Cross-Reference with Pay Stubs [file:2]

**Issue:** Processor opens uploaded pay stub PDF in separate window, manually reads YTD income, closes PDF, returns to Employment form, types amount.

**Time Cost:** 14-minute cycle for single document verification [file:2].

**Workaround:** Print pay stub and place next to screen, but this defeats digital workflow purpose.

### 2. Redundant Address Entry [file:7]

**Issue:** Employer address must be manually typed even when same as borrower's current employer in another section.

**Evidence:** SOP shows "123 Main St," "Anytown," "VA," "12345" re-entered 3 separate times across Borrower, Employment, and POA forms [file:2][file:7].

### 3. Income Calculation Errors [file:1]

**Issue:** Manual income worksheet calculations prone to human error (transposed digits, incorrect formulas).

**Impact:** Incorrect qualifying income leads to wrong DTI, potential loan denial or compliance violation.

**Best Practice:** Use built-in Encompass income calculators when available, but many lenders still use external Excel spreadsheets [file:2].

### 4. Self-Employed Documentation Overload

**Issue:** Self-employed borrowers require 10+ documents (tax returns, business returns, P&L, CPA letter, license). Processors spend hours chasing missing docs.

**Evidence:** SOP shows repeated "Send Message" actions requesting tax returns from borrower [file:7].

## Integration Points

### Inbound Data Sources

- **VOE Services:** Automated VOE via The Work Number, Equifax TWN
- **Tax Return Parsers:** Automated income extraction from 1040/1120 PDFs [file:1]
- **Pay Stub OCR:** AI-powered extraction of pay stub data (not native to Encompass) [file:2]

### Outbound Dependencies

- **1003 URLA:** Employment section auto-populates Section 3
- **Underwriting:** DTI calculation displayed in UW-1A form [file:8]
- **Closing Disclosure:** Employment info prints on CD for borrower review

## Best Practices

### For Processors

1. **Verify Continuity:** Ensure no employment gaps > 1 month without explanation
2. **Declining Income:** If commission/bonus declining, use conservative (lower year) calculation
3. **Cross-Check Tax Returns:** W-2 Box 1 should match Line 7 of 1040

### For Underwriters

1. **Self-Employed Red Flags:** Large write-offs, declining revenue, new business (<2 years)
2. **Variable Income:** Require 2-year avg; reject if unstable (>20% variance)
3. **Rental Income:** Verify with lease agreement AND Schedule E

### For Loan Officers

1. **Pre-Qualify Accurately:** Use conservative income calculations during pre-qual to avoid surprises
2. **Set Expectations:** Warn self-employed borrowers upfront about heavy documentation requirements

## Technical Notes

### Data Model

**Primary Table:** `Employment` (Encompass database)

**Key Fields (Encompass Field IDs):**
- `EmployerName` - Field ID: 96
- `PositionTitle` - Field ID: 1493
- `MonthlyIncome` - Field ID: 1991
- `StartDate` - Field ID: 98
- `YearsOnJob` - Field ID: VEND.X264

### API Access

**Endpoint:** `/encompass/v3/loans/{loanId}/applications/{applicationId}/employment`

**Methods:**
- `GET` - Retrieve employment records
- `POST` - Add new employment
- `PATCH` - Update existing employment
- `DELETE` - Remove employment record

## Related Documentation

- **Core Module 1.2:** Borrower Information Form (personal details)
- **Core Module 1.6:** Assets Management (related to income verification)
- **Processing Workflows 3.1:** Processing Workbook - Income Review
- **Underwriting 4.1:** UW-1A Form (DTI analysis)