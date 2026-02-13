---
type: technical-documentation
module: Core Modules
section: Financial Management
subsection: Expenses Tracking
source: SOP analysis + Encompass documentation
last_updated: 2026-02-13
---

# Encompass: Expenses Tracking

## Overview

The Expenses section captures all borrower monthly housing expenses and other recurring obligations. These expenses are used for DTI calculation and to verify borrower's stated housing costs .

## Access Path

**Primary Navigation:**
1. Borrower Window → **Expenses** tab
2. Or: Consumer Connect Portal → **Expenses** section
3. Or: Forms menu → **Monthly Housing Expenses**

## Section 1: Monthly Housing Expenses

### Current Housing Costs

| Field Name | Data Type | Required | SOP Evidence | Notes |
|------------|-----------|----------|--------------|-------|
| **Rent** | Currency | If Renter |  "$1,000.00" | Monthly rent payment |
| **Property Tax** | Currency | If Owner |  "$100.00" | Monthly escrow or direct payment |
| **Insurance** | Currency | If Owner |  "$100.00" | Homeowners insurance |
| **Utilities** | Currency | No |  "$100.00" | May be included for some loan types |
| **Maintenance** | Currency | No |  "$100.00" | Optional tracking |
| **HOA Fees** | Currency | If applicable |  "$100.00" HOA Fees | "$5,000" in another example |
| **Other** | Currency | No |  "$100.00" | Miscellaneous housing costs |
| **Total Monthly Housing Expenses** | Currency | Auto-calc |  "$1,600.00" | **Calculated automatically** |

### Documented Workflow 

**SOP Evidence from Moxi_Master_SOP_Part2.md:**
```
[57:05] Click [Monthly Housing Expenses]
[57:05] Type "1000.00" into [Rent]
[57:06] Type "100.00" into [Property Tax]
[57:07] Type "100.00" into [Insurance]
[57:08] Type "100.00" into [Utilities]
[57:09] Type "100.00" into [Maintenance]
[57:10] Type "100.00" into [HOA Fees]
[57:11] Type "100.00" into [Other]
[57:12] Click [Total Monthly Housing Expenses]
System Result: The value in Total Monthly Housing Expenses field updates to 1600.00
[57:13] Click [Apply]
System Result: The changes are applied
```

### Documented Workflow

**From Moxi_Master_SOP_Part1.md - Expenses Section:**
```
[45:00] Click [Expenses]
System Result: The Expenses section is displayed

[45:05] Type "5000" into [Real Estate Taxes]
System Result: The value 5000 is entered into Real Estate Taxes field

[45:10] Type "5000" into [Homeowners Association Fees]
System Result: The value 5000 is entered into Homeowners Association Fees field

[45:15] Click [SAVE]
System Result: The form is saved and the total monthly housing expense updates to 10,000
```

## Section 2: Proposed Housing Expenses (New Loan)

### PITI + HOA Calculation

For the **new mortgage** being applied for, system calculates total monthly housing payment:

| Component | Description | Source |
|-----------|-------------|--------|
| **P** - Principal | Loan amount principal payment | From loan amount + interest rate |
| **I** - Interest | Monthly interest portion | From loan amount + interest rate |
| **T** - Property Taxes | Monthly property tax escrow | From Property section ÷ 12 |
| **I** - Insurance | Homeowners insurance escrow | From Insurance estimate |
| **HOA** | Homeowners Association fee | $100.00; $5,000 examples |
| **MI** | Mortgage Insurance (if <20% down) | PMI/MIP calculation |

**Total Proposed Housing Payment = PITI + HOA + MI**

This amount is used in both Front-End and Back-End DTI calculations.

## Section 3: Other Monthly Expenses

### Additional Obligations

| Field Name | Data Type | Required | Used in DTI? |
|------------|-----------|----------|--------------|
| **Childcare** | Currency | No | Sometimes (FHA/VA allow deduction from income) |
| **Alimony Paid** | Currency | If applicable | **Yes** (tracked in Liabilities) |
| **Child Support Paid** | Currency | If applicable | **Yes** (tracked in Liabilities) |

**Note:** Alimony and child support paid are typically entered in the **Liabilities** section, not Expenses, because they're debt obligations used in DTI calculation.

## Section 4: Housing Expense Verification

### Documentation Required

**For Renters:**
- **Lease Agreement:** Current lease showing monthly rent amount
- **12 Months Rent Checks:** Canceled checks or bank statements showing rent payments
- **Verification of Rent (VOR):** Form completed by landlord (alternative to checks)

**For Current Homeowners:**
- **Mortgage Statement:** Most recent statement showing PITI payment
- **Property Tax Bill:** Annual tax bill (to verify escrow accuracy)
- **Insurance Declaration:** Homeowners insurance policy dec page
- **HOA Statement:** If applicable, most recent HOA statement showing monthly fee

### Processing Workbook Integration [file:1]

**Housing Expenses Verified Checklist:**
- Current housing payment documented (rent or mortgage statement)
- Property tax amount verified (if owner)
- Insurance coverage verified (if owner)
- HOA fees verified (if applicable)
- Total monthly housing expense calculated correctly
- Verification of Rent (VOR) received (if renter)

**Auto-Completion Rule:** Section auto-marks complete when all required housing docs have `status = 'reviewed'`.

## Common Pain Points

### 1. Annual vs Monthly Confusion

**Issue:** Property tax field doesn't clearly specify "monthly" vs "annual." Processors sometimes enter annual amount instead of monthly.

**Example:**
```
Type "100.00" into [Property Tax]
```

Without context, unclear if $100 is monthly or annual. If processor enters $1,200 (annual) thinking it's the correct field, DTI calculation will be wrong.

**Impact:** Over-estimates housing expense by 12x, artificially inflates DTI, may deny qualified borrower.

### 2. HOA Fee Verification Delay ]

**Issue:** HOA fees vary widely ($50-$500+/month). Processors often use borrower-stated amount without verification, then discover actual fee is higher during title review.

**Example:** SOP shows "$5,000" entered in HOA Fees—likely an error or annual amount. This would dramatically impact DTI if not caught.

**Best Practice:** Request HOA statement or contact HOA directly for current fee before submitting to underwriting.

### 3. Escrow vs Non-Escrow Confusion

**Issue:** Some borrowers pay property tax and insurance directly (non-escrow). Processor must manually add these to PITI calculation for DTI.

**Workaround:** If non-escrow, manually calculate:
- Monthly property tax = Annual tax ÷ 12
- Monthly insurance = Annual premium ÷ 12
- Add both to P+I for total housing payment

## Integration Points

### Inbound Data Sources

- **Consumer Connect Portal:** Borrower self-enters current housing expenses
- **Mortgage Statement Upload:** AI extraction of PITI from uploaded statement (future enhancement) [file:1]
- **Property Tax Records:** Auto-import from county assessor (if integrated)

### Outbound Dependencies

- **DTI Calculation:** Total housing expense flows to DTI numerator [file:1]
- **1003 URLA:** Housing expenses populate Section 5
- **Closing Disclosure:** Proposed PITI prints on CD for borrower review

## Best Practices

### For Loan Officers

1. **Verify Rent Amount:** Request lease agreement upfront (don't rely on borrower-stated amount)
2. **HOA Research:** Check property records for HOA fees before quoting payment to borrower
3. **Tax Estimate:** Use county tax records for accurate property tax estimate (don't guess)

### For Processors

1. **Monthly Conversion:** Always verify annual amounts are converted to monthly (÷ 12)
2. **Cross-Check Mortgage Statement:** Compare borrower-stated housing payment to actual mortgage statement
3. **HOA Confirmation:** Contact HOA or request statement before finalizing expense amounts

### For Underwriters

1. **Recalculate PITI:** Independently verify PITI calculation using loan amount, rate, tax, insurance
2. **HOA Reasonability:** Flag unusually high or low HOA fees for verification
3. **Tax Escrow Shortage:** Check for tax escrow shortages that would increase payment

## Technical Notes

### Data Model

**Primary Table:** `HousingExpenses` (Encompass database)

**Key Fields (Encompass Field IDs):**
- `Rent` - Field ID: 1821
- `FirstMortgagePrincipalAndInterest` - Field ID: 1840
- `PropertyTax` - Field ID: 356
- `HomeownersInsurance` - Field ID: 1822
- `HOADues` - Field ID: 1823
- `MortgageInsurance` - Field ID: 1841

### API Access

**Endpoint:** `/encompass/v3/loans/{loanId}/housingExpenses`

**Methods:**
- `GET` - Retrieve housing expenses
- `PATCH` - Update expense fields

## Related Documentation

- **Core Module 1.3:** Employment & Income (DTI calculation)
- **Core Module 1.4:** Property Information (property tax source)
- **Core Module 1.6:** Liabilities Management (DTI calculation)
- **Underwriting 4.1:** UW-1A Form (DTI analysis)