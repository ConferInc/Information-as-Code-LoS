---
type: technical-documentation
module: Core Modules
section: Property & Financial Management
subsection: Real Estate Owned (REO)
source: SOP analysis + Encompass documentation
last_updated: 2026-02-13
---

# Encompass: Real Estate Owned (REO)

## Overview

The Real Estate Owned (REO) section documents all properties currently owned by the borrower other than the subject property. REO properties are critical for calculating rental income (if applicable) and determining total housing obligations for DTI [file:8].

## Access Path

**Primary Navigation:**
1. Borrower Window → **REO** tab
2. Or: Forms menu → **Real Estate Owned**
3. Or: During Borrower Information entry, checkbox: "Is a Real Estate Owned?" [file:8]

## Section 1: REO Property Entry

### Property Information Fields

| Field Name | Data Type | Required | Notes |
|------------|-----------|----------|-------|
| **Property Address** | Text (200 char) | Yes | Full address of owned property |
| **Property Type** | Dropdown | Yes | SFR, Condo, 2-4 Unit, Commercial |
| **Property Status** | Dropdown | Yes | Retained (Rental), Sold, Pending Sale |
| **Original Purchase Price** | Currency | Yes | Historical purchase amount |
| **Current Market Value** | Currency | Yes | Borrower-estimated or recent appraisal |
| **Date Acquired** | Date | Yes | Purchase date |

### Documented Workflow [file:8]

**SOP Evidence from Moxi_SOP_Jan_21_Part1.md:**
```
[15:00] Click [Real Estate Owned] section
System Result: The checkbox next to "Is a Real Estate Owned?" changes from "No" to "Yes"

[16:40] Click [Verification] section
System Result: The checkbox next to "Is There Any Association With Property?" 
changes from "No" to "Yes"

[16:50] Click [Verification] section
System Result: The checkbox next to "Are They A Co-Borrower?" changes from "No" to "Yes"
```

## Section 2: Mortgage & Financial Details

### Existing Mortgage on REO

| Field Name | Data Type | Required | Notes |
|------------|-----------|----------|-------|
| **Lender Name** | Text (100 char) | If mortgaged | Current mortgage servicer |
| **Mortgage Balance** | Currency | If mortgaged | Current unpaid principal balance |
| **Monthly Payment (PITI)** | Currency | If mortgaged | Principal + Interest + Taxes + Insurance |
| **Property Tax (Annual)** | Currency | Yes | Annual property tax amount |
| **Insurance (Annual)** | Currency | Yes | Annual homeowners insurance |
| **HOA Fees (Monthly)** | Currency | If applicable | Monthly HOA/condo fees |

**Note:** Even if property is owned free-and-clear (no mortgage), taxes and insurance must be documented.

## Section 3: Rental Income Calculation

### If Property is Rented

| Field Name | Data Type | Required | Verification |
|------------|-----------|----------|--------------|
| **Rental Status** | Dropdown | Yes | Currently Rented, Vacant, Owner-Occupied |
| **Gross Monthly Rent** | Currency | If rented | Monthly rent collected from tenant |
| **Lease Agreement** | Document | If rented | Current signed lease |

### Rental Income Formula

**For Qualifying Income:**
```
Gross Monthly Rent - PITIA = Net Rental Income

Qualifying Rental Income = Net Rental Income × 75%
```

**Where PITIA:**
- P = Principal
- I = Interest
- T = Taxes (annual ÷ 12)
- I = Insurance (annual ÷ 12)
- A = Association fees (HOA)

**Example [file:8]:**
- Gross monthly rent: $2,500
- Mortgage payment (P+I): $1,200
- Property tax: $400/month
- Insurance: $100/month
- HOA: $100/month
- **Total PITIA: $1,800**
- Net rental income: $2,500 - $1,800 = $700
- **Qualifying income: $700 × 75% = $525/month**

### Negative Cash Flow Treatment

**If PITIA > Gross Rent:**
- Result is negative cash flow
- **100% of negative amount added to monthly debt obligations** (increases DTI)

**Example:**
- Gross monthly rent: $1,500
- PITIA: $2,000
- Negative cash flow: -$500
- **Added to liabilities: $500/month** (hurts qualification)

## Section 4: REO Documentation Requirements

### Standard Verification Documents [file:1]

**For All REO Properties:**
1. **Mortgage Statement:** Most recent statement showing balance and payment
2. **Property Tax Bill:** Annual tax bill or escrow statement
3. **Insurance Declaration:** Homeowners insurance policy dec page
4. **Lease Agreement:** If rental property, current signed lease
5. **Schedule E (Tax Return):** IRS Schedule E showing rental income/expenses (2 years)

**If Property Being Sold:**
- **Purchase Agreement:** Signed sales contract
- **Estimated HUD-1:** Projected closing statement showing payoff

**If Property Was Sold:**
- **Final HUD-1/Closing Disclosure:** Closed settlement statement showing sale proceeds

### Processing Workbook Integration [file:1]

**REO Verification Checklist:**
- [ ] All owned properties documented
- [ ] Mortgage balances verified with statements
- [ ] Rental income verified with lease + Schedule E
- [ ] Property taxes and insurance amounts verified
- [ ] Net rental income calculated (75% rule applied)
- [ ] Negative cash flow properties added to liabilities

## Section 5: REO Treatment by Transaction Type

### Purchase Transaction

**If borrower owns current primary residence:**
- **Selling current home:** Mark as "Pending Sale," exclude from DTI if closing simultaneously or within X days
- **Keeping as rental:** Must document rental income, PITIA stays in DTI (offset by 75% of net rent)
- **Keeping as second home:** PITIA stays in DTI (no rental income offset)

### Refinance Transaction

**If borrower owns other properties:**
- **Rental properties:** Document rental income and PITIA
- **Second home:** PITIA included in DTI (no rental income)

### Cash-Out Refinance

**If taking cash out:**
- Underwriter may require explanation of cash-out use, especially if REO properties have negative cash flow

## Common Pain Points

### 1. Manual PITIA Calculation [file:8]

**Issue:** Processor must manually calculate PITIA by adding mortgage payment + (annual tax ÷ 12) + (annual insurance ÷ 12) + HOA. Prone to calculation errors.

**Example:** Annual property tax is $4,800. Processor forgets to divide by 12, enters $4,800 as monthly (should be $400). This over-inflates PITIA by 12x, shows massive negative cash flow, may deny loan.

### 2. Schedule E Complexity [file:1]

**Issue:** Reading IRS Schedule E requires understanding of rental income reporting, depreciation, and expense deductions. Processors without tax knowledge struggle.

**Verification Challenge:** Gross rent on Schedule E may not match current lease (rent increased, property vacated, etc.). Requires reconciliation.

### 3. 75% Rule Misapplication [file:8]

**Issue:** Processors sometimes apply 75% to gross rent instead of net rental income.

**Wrong:** $2,500 × 75% = $1,875 qualifying income
**Correct:** ($2,500 - $1,800 PITIA) × 75% = $525 qualifying income

**Impact:** Over-crediting rental income by 3x-4x, falsely qualifies borrower.

### 4. Pending Sale Documentation [file:1]

**Issue:** If borrower is selling REO property to reduce obligations, underwriter requires firm evidence (signed contract + estimated closing date). Borrower's verbal promise to sell is not acceptable.

**Delay:** Loan may be suspended until sales contract is signed and provided.

## Integration Points

### Inbound Data Sources

- **1003 Import:** REO section from Fannie Mae 3.4 XML
- **Mortgage Statement Upload:** AI extraction of balance and payment (future) [file:1]
- **Schedule E Upload:** AI extraction of rental income and expenses (future)

### Outbound Dependencies

- **1003 URLA:** REO section auto-populates Section 1b
- **DTI Calculation:** Net rental income (75%) added to income; negative cash flow added to debts
- **Underwriting:** REO cash flow analysis, reserve requirements (may require 6 months PITI reserves per REO)

## Best Practices

### For Loan Officers

1. **Disclose REO Upfront:** Ask during pre-qual: "Do you own any other properties?" to avoid surprises
2. **Schedule E Warning:** Advise self-employed with rentals that Schedule E is required (often creates delays)
3. **Pending Sale Strategy:** If selling REO, advise to list property immediately (contract needed for approval)

### For Processors

1. **Verify Lease Matches Schedule E:** Cross-check lease agreement rent vs Schedule E gross rents (should match)
2. **75% Calculation:** Always apply 75% to NET rental income (after PITIA), not gross rent
3. **Property Tax Annual → Monthly:** Divide annual tax by 12; don't enter annual amount in monthly field

### For Underwriters

1. **Schedule E Deep Dive:** Review all pages of Schedule E for each property, verify income continuity
2. **Negative Cash Flow Red Flag:** Multiple REO properties with negative cash flow indicate over-leverage
3. **Reserve Requirements:** Ensure borrower has 6 months PITI reserves per rental property (investor guidelines)

## Technical Notes

### Data Model

**Primary Table:** `RealEstateOwned` (Encompass database)

**Key Fields (Encompass Field IDs):**
- `PropertyAddress` - Field ID: REO.X1
- `PropertyType` - Field ID: REO.X2
- `MonthlyRentalIncome` - Field ID: REO.X10
- `MonthlyMortgagePayment` - Field ID: REO.X11

### API Access

**Endpoint:** `/encompass/v3/loans/{loanId}/reo`

**Methods:**
- `GET` - Retrieve all REO properties
- `POST` - Add REO property
- `PATCH` - Update REO property
- `DELETE` - Remove REO property

## Related Documentation

- **Core Module 1.3:** Employment & Income (rental income aggregation)
- **Core Module 1.6:** Liabilities Management (negative cash flow treatment)
- **Core Module 1.7:** Expenses Tracking (PITIA calculation)
- **Underwriting 4.1:** UW-1A Form (rental income analysis)