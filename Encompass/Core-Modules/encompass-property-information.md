---
type: technical-documentation
module: Core Modules  
section: Property & Loan Details
subsection: Property Information
source: SOP analysis + Encompass documentation
last_updated: 2026-02-13
---

# Encompass: Property Information

## Overview

The Property Information form captures all details about the subject property being financed, including address, property type, occupancy, value, and legal description. This form is critical for appraisal ordering, title work, and underwriting analysis [file:4][file:6].

## Access Path

**Primary Navigation:**
1. Borrower Window → **Property** tab
2. Or: Forms menu → **Subject Property**
3. Or: Pipeline → Right-click loan → **Property Details**

## Section 1: Property Address

### Subject Property Location

| Field Name | Data Type | Required | Validation | SOP Evidence |
|------------|-----------|----------|------------|--------------|
| **Property Address** | Text (100 char) | Yes | Street number + name | Standard field |
| **Unit/Apt #** | Text (10 char) | No | For condos/multi-unit | Optional |
| **City** | Text (50 char) | Yes | Alpha characters | Required |
| **County** | Text (50 char) | Yes | Auto-populated from zip or manual | Used for tax assessment |
| **State** | Dropdown | Yes | 50 US states + territories | Required |
| **Zip Code** | Text (5-9 digits) | Yes | ##### or #####-#### | Required |
| **Legal Description** | Text (500 char) | No | Lot, Block, Subdivision | From title report |

**International Properties [file:2][file:5]:**
Pain Point: Encompass built for US addresses only. Mexico property addresses don't fit US format, requiring workarounds.

**Evidence [file:5]:** "The MoXi team... faces constant friction: Mexico property addresses don't fit US address formats."

## Section 2: Property Type & Characteristics

| Field Name | Options | Required | Notes |
|------------|---------|----------|-------|
| **Property Type** | SFR, Condo, Townhouse, 2-4 Unit, Manufactured, Co-op, PUD | Yes | Impacts loan type eligibility |
| **Occupancy** | Primary, Second Home, Investment | Yes | [file:6] "Property Used As: Primary" required for form generation |
| **Number of Units** | 1, 2, 3, 4 | Yes | 1 for SFR; 2-4 for multi-family |
| **Year Built** | Number (4 digits) | Yes | YYYY format (e.g., 1985) | From appraisal |
| **Square Footage** | Number | No | Living area sq ft | From appraisal or tax records |
| **Lot Size** | Number | No | Acres or sq ft | From appraisal |
| **Number of Stories** | 1, 1.5, 2, 2.5, 3+ | No | Visual inspection |

### Property Intended Use

**Primary Residence:**
- Borrower will occupy within 60 days of closing
- Lower interest rates, best loan terms
- Required for FHA/VA loans

**Second Home:**
- Occasional occupancy (vacation home)
- Must be >50 miles from primary
- Higher rates than primary, lower than investment

**Investment Property:**
- Rental income property
- Highest rates, largest down payment (20-25%)
- Rental income used in qualification [file:8]

## Section 3: Purchase Details (If Purchase Transaction)

| Field Name | Data Type | Required | SOP Evidence |
|------------|-----------|----------|--------------|
| **Purchase Price** | Currency | Yes | [file:4] "$1,000,000" Estimated Purchase Price |
| **Down Payment** | Currency | Yes | [file:4] "$400,000" Down Payment Amount |
| **Down Payment %** | Percentage | Auto-calc | [file:4] "40%" calculated |
| **Sales Contract Date** | Date | Yes | Date contract signed |
| **Seller Name** | Text (100 char) | Yes | Individual or entity |
| **Seller Address** | Full address | No | For disbursement |
| **Real Estate Agent** | Text (100 char) | No | Buyer's agent name |
| **Agent Phone** | Phone | No | For communication |
| **Listing Agent** | Text (100 char) | No | Seller's agent |

**Purchase Workflow [file:4]:**
```
[30:11] Type "$1,000,000" into [Estimated Purchase Price] field
[30:12] Type "$400,000" into [Down Payment Amount] field
[30:13] Type "40%" into [Down Payment Percentage] field
```

## Section 4: Refinance Details (If Refinance Transaction)

| Field Name | Data Type | Required | Notes |
|------------|-----------|----------|-------|
| **Current Value (Estimated)** | Currency | Yes | Borrower-stated or AVMestimate |
| **Original Purchase Price** | Currency | Yes | Historical purchase amount |
| **Original Purchase Date** | Date | Yes | For seasoning requirement |
| **Current Lien Balance** | Currency | Yes | Payoff amount from existing loan |
| **Current Lender** | Text (100 char) | Yes | For payoff request |
| **Current Loan Number** | Text (50 char) | Yes | For payoff coordination |
| **Cash Out Amount** | Currency | Auto-calc | If cash-out refi |

**Refinance Purpose Options:**
- Rate/Term (lower rate or change term)
- Cash-Out (extract equity)
- Streamline (FHA/VA simplified refi)

## Section 5: Property Value & Appraisal

| Field Name | Data Type | Required | Source |
|------------|-----------|----------|--------|
| **Appraised Value** | Currency | Yes (after appraisal) | From appraisal report |
| **Appraisal Date** | Date | Yes | Date of property inspection |
| **Appraisal Type** | Full, Drive-by, Desktop, Waiver | Yes | Level of inspection |
| **Appraiser Name** | Text (100 char) | Yes | Licensed appraiser |
| **Appraiser License #** | Text (50 char) | Yes | State license number |

**LTV Calculation:**
```
LTV = (Loan Amount ÷ Appraised Value) × 100

Example:
Loan Amount: $600,000
Appraised Value: $1,000,000
LTV = ($600,000 ÷ $1,000,000) × 100 = 60%
```

**LTV Thresholds:**
- **Conventional:** ≤80% (no PMI), ≤97% (with PMI)
- **FHA:** ≤96.5%
- **VA:** ≤100% (no down payment)
- **Jumbo:** ≤80% typical

## Section 6: HOA & Assessments

| Field Name | Data Type | Required | Notes |
|------------|-----------|----------|-------|
| **HOA?** | Yes/No | Yes | Homeowners Association present |
| **HOA Monthly Fee** | Currency | If HOA=Yes | [file:3] "$100 HOA Fees" in expenses |
| **HOA Name** | Text (100 char) | No | Association name |
| **HOA Contact** | Phone | No | For questionnaire |
| **Special Assessments** | Currency | No | One-time or ongoing fees |
| **Condo Project Name** | Text (100 char) | If Condo | For condo questionnaire |

**Impact on Qualification [file:3]:**
HOA fees added to monthly housing expense (PITI + HOA) for DTI calculation.

## Section 7: Property Ownership History

| Field Name | Data Type | Required | Purpose |
|------------|-----------|----------|---------|
| **How Title Held** | Sole, Joint Tenants, Tenants in Common, Community Property | Yes | Legal ownership structure |
| **Owned By** | Dropdown: Borrower, Co-Borrower, Both | Yes | [file:6] Required for form generation |
| **Date Acquired** | Date | If refi | For title seasoning |
| **Source of Down Payment** | Dropdown | If purchase | Gift, Savings, Sale of Property, Other |

**Pain Point [file:6]:**
```
Timestamp: [76:30]
Action: Click [Print File]
System Result: Error - "Owned By" and "Property Used As" fields not populated

Evidence: System accepted all prior steps without validation, 
then failed at finish line. Processor had to navigate back and restart.
```

## Common Pain Points

### 1. Form Validation Failure at End [file:2][file:6]

**Issue:** Processor completed entire property form workflow, clicked "Print File," received error: "Owned By and Property Used As fields not populated."

**Evidence:** "System happily accepted every prior step without warning, then failed at the finish line" [file:2].

**Impact:** Wasted time, frustration, having to navigate back through form.

### 2. International Address Format [file:2][file:5]

**Issue:** Mexico properties don't fit US address structure (no state dropdown option for Mexican states, no handling for Escritura documents).

**Workaround:** Team enters random US state or uses workarounds, compromising data integrity.

**Evidence:** "One processor entered a random US state in a fraud report just to avoid MERS charges on a non-US property" [file:2].

### 3. Manual LTV Calculation [file:1]

**Issue:** While system auto-calculates LTV, processors still manually verify using external spreadsheets for complex scenarios (subordinate financing, piggyback loans).

### 4. Property Tax Entry Confusion [file:3]

**Issue:** Annual property taxes must be divided by 12 for monthly amount, but field label doesn't specify "monthly" clearly.

**SOP Evidence [file:3]:**
```
[57:06] Type "100.00" into [Property Tax]
```
Unclear if this is monthly or annual amount without context.

## Integration Points

### Inbound Data Sources

- **AVM (Automated Valuation Model):** Instant property value estimate from MLS data
- **Tax Assessor Records:** Auto-import property tax amount, lot size, year built
- **MLS Integration:** Pre-fill property details from listing data

### Outbound Dependencies

- **Appraisal Order:** Property address, type, occupancy sent to AMC [file:5]
- **Title Order:** Property address and legal description sent to title company
- **1003 URLA:** Property section auto-populates Section 2
- **Closing Disclosure:** Property address prints on CD

## Best Practices

### For Loan Officers

1. **Verify Address Early:** Confirm property address with borrower/realtor before ordering services
2. **Occupancy Intent:** Clearly document primary vs second home vs investment to avoid occupancy fraud
3. **HOA Verification:** Request HOA contact early for condo questionnaire (30-day turnaround)

### For Processors

1. **Match Appraisal to Contract:** Ensure appraised value ≥ purchase price (or address shortfall)
2. **Legal Description:** Verify legal description matches title report exactly
3. **Property Type Accuracy:** Ensure property type selection matches actual structure (e.g., townhouse vs condo)

### For Underwriters

1. **LTV Review:** Recalculate LTV if appraisal comes in low
2. **Occupancy Verification:** Check distance between primary residence and "second home" (must be >50 miles)
3. **Condo Review:** Verify project is FHA/VA approved if applicable

## Technical Notes

### Data Model

**Primary Table:** `Property` (Encompass database)

**Key Fields (Encompass Field IDs):**
- `SubjectPropertyAddress` - Field ID: 11
- `SubjectPropertyCity` - Field ID: 12
- `SubjectPropertyState` - Field ID: 14
- `SubjectPropertyZip` - Field ID: 15
- `PropertyUsageType` - Field ID: 1811
- `LoanPurposeType` - Field ID: 19

### API Access

**Endpoint:** `/encompass/v3/loans/{loanId}/property`

**Methods:**
- `GET` - Retrieve property data
- `PATCH` - Update property fields

## Related Documentation

- **Core Module 1.7:** Expenses & HOA Fees
- **Processing Workflows 3.2:** Appraisal Ordering [file:5]
- **Underwriting 4.1:** LTV/CLTV Analysis
- **Closing 5.2:** Title & Legal Description Verification