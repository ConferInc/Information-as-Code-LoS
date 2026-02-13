---
type: technical-documentation
module: Core Modules
section: Borrower Information Management
subsection: Co-Borrower Management
source: SOP analysis + Encompass documentation
last_updated: 2026-02-13
---

# Encompass: Co-Borrower Management

## Overview

The Co-Borrower module manages additional borrowers on a loan application. Co-borrowers can be spouses, domestic partners, co-purchasers, or other parties jointly applying for the mortgage. All co-borrower data mirrors the primary borrower structure [file:7][file:8].

## Access Path

**Primary Navigation:**
1. Borrower Window → **Add Borrower** button
2. Or: Forms menu → **Borrowers** → **Add Co-Borrower**
3. Or: Consumer Connect Portal → Add additional borrower during application

## Section 1: Adding a Co-Borrower

### Add Borrower Workflow

**Steps:**
1. Click **[Add Borrower]** button in Borrower window
2. System creates new borrower record linked to same loan
3. Processor completes all same sections as primary borrower:
   - Personal Information (name, SSN, DOB, address)
   - Employment & Income
   - Assets & Liabilities
   - Credit Authorization

**Pain Point [file:2]:**
All co-borrower data must be manually entered. Even when co-borrower shares same address as primary borrower (e.g., married couple), address must be re-typed.

**Evidence [file:2]:** "The same borrower data is entered over and over across different Encompass forms... Borrower Information fields are re-entered in POA forms, co-borrower forms, and disclosure packages."

## Section 2: Co-Borrower Relationship Types

### Relationship Options

| Relationship | Description | Typical Use Case |
|--------------|-------------|------------------|
| **Spouse** | Married to primary borrower | Married couples applying jointly |
| **Domestic Partner** | Unmarried partners | Non-married couples in joint purchase |
| **Other Relative** | Parent, sibling, adult child | Family joint purchase or co-signing |
| **Non-Relative Co-Borrower** | Friend, business partner | Investment property or shared purchase |

**Community Property States:**
In community property states (AZ, CA, ID, LA, NV, NM, TX, WA, WI), spouse must be on loan even if not on title, OR sign disclaimer.

## Section 3: Joint vs Separate Treatment

### Income Aggregation

**Joint Application:**
- **Total Income** = Primary Borrower Income + Co-Borrower Income
- Used for DTI calculation
- Both borrowers' credit scores considered (typically lowest middle score used)

**Example:**
- Primary borrower income: $6,000/month
- Co-borrower income: $4,000/month
- **Total qualifying income: $10,000/month**

### Asset Aggregation

**Joint Assets:**
- Bank accounts held jointly (both names on account)
- Count 100% of balance toward reserves

**Separate Assets:**
- Each borrower's individual accounts
- Count 100% of each borrower's accounts

**Example:**
- Joint checking: $20,000
- Primary borrower savings: $10,000
- Co-borrower savings: $15,000
- **Total assets: $45,000**

### Liability Aggregation

**Joint Debts:**
- Mortgage or credit card with both names
- Monthly payment included in DTI (counted once, not twice)

**Individual Debts:**
- Each borrower's separate debts
- All included in combined DTI calculation

**Example:**
- Primary borrower: Auto loan $400/month
- Co-borrower: Student loan $250/month
- Joint: Credit card $150/month
- **Total debts: $800/month**

## Section 4: Credit Score Treatment

### Multiple Borrower Credit Score Rules

**Fannie Mae / Freddie Mac:**
1. Pull tri-merge credit report for each borrower
2. For each borrower, use **middle score** (of 3 bureau scores)
3. For multiple borrowers, use **lowest middle score**

**Example:**
- **Primary Borrower Scores:** Equifax 720, Experian 740, TransUnion 700 → **Middle: 720**
- **Co-Borrower Scores:** Equifax 680, Experian 710, TransUnion 690 → **Middle: 690**
- **Qualifying Score: 690** (lowest middle score)

**Impact on Loan:**
- Interest rate: Based on 690 score (higher rate than if primary borrower alone)
- LTV restrictions: 690 may have tighter LTV limits than 720

## Section 5: Co-Borrower Verification Requirements

### Documentation Required (Per Co-Borrower)

**Same as Primary Borrower:**
- **Identity:** Driver's license or passport
- **Income:** Pay stubs, W-2s, tax returns (2 years)
- **Employment:** VOE or employment verification
- **Assets:** Bank statements (2 months), retirement statements
- **Credit:** Credit report with authorization

**Processing Workbook Checklist [file:1]:**
- [ ] Co-borrower personal information complete
- [ ] Co-borrower employment verified (2-year history)
- [ ] Co-borrower income calculated and added to total
- [ ] Co-borrower assets documented and added to total
- [ ] Co-borrower liabilities added to DTI calculation
- [ ] Co-borrower credit report received and middle score determined

## Common Pain Points

### 1. Redundant Data Entry [file:2][file:7]

**Issue:** Co-borrower who shares same address as primary borrower (e.g., married couple) requires re-entry of identical address, city, state, zip.

**Evidence [file:2]:** "22 fields of duplicate data entry documented in a single 15-minute segment."

**Example:** Husband and wife applying jointly. Processor types "123 Main St, Anytown, VA 12345" for primary borrower, then must type exact same address for co-borrower.

### 2. Separate Windows Per Borrower [file:2]

**Issue:** Primary borrower and co-borrower open in separate windows. Processor alt-tabs between windows to compare data.

**Evidence [file:2]:** "11 documented instances of 'a new window appears.'"

### 3. Credit Score Confusion [file:1]

**Issue:** Determining which credit score to use (lowest middle score) is manual process prone to error.

**Example:** Processor accidentally uses primary borrower's middle score (720) instead of lowest middle score (690), quotes lower rate, then loan is re-priced at closing.

## Integration Points

### Inbound Data Sources

- **Consumer Connect Portal:** Co-borrower self-enters data during application [file:4]
- **1003 Import:** Co-borrower data from Fannie Mae 3.4 XML
- **Credit Report:** Separate credit pull for co-borrower

### Outbound Dependencies

- **1003 URLA:** Co-borrower data populates all sections with "Co-Borrower" designation
- **Underwriting:** Combined income, assets, liabilities, credit score analysis
- **Closing:** Both borrowers sign all documents

## Best Practices

### For Loan Officers

1. **Explain Score Impact:** Warn co-borrower applicants that lower credit score will be used for qualification
2. **Income vs Score Trade-Off:** Analyze if adding co-borrower helps (income boost) or hurts (score drag)
3. **Non-Purchasing Spouse:** In community property states, clarify spouse must be on loan or sign waiver

### For Processors

1. **Verify Relationship:** Confirm relationship type (spouse, domestic partner, etc.) for proper documentation
2. **Address Verification:** Even if same address, cross-check driver's license to confirm co-borrower residency
3. **Joint Account Verification:** Verify both names on joint bank accounts (request statement showing both names)

### For Underwriters

1. **Credit Score Verification:** Independently verify lowest middle score calculation
2. **Income Reasonability:** Verify both borrowers' income sources are stable and continuing
3. **Asset Ownership:** Verify joint assets are truly joint (both names on account)

## Technical Notes

### Data Model

**Primary Table:** `Borrowers` (Encompass database)

**Key Fields:**
- `BorrowerType` - Field ID: 97 (Primary, Co-Borrower, Non-Purchasing Spouse)
- `BorrowerID` - Unique identifier linking to loan
- All other fields mirror primary borrower structure

### API Access

**Endpoint:** `/encompass/v3/loans/{loanId}/applications/{applicationId}/borrowers`

**Methods:**
- `GET` - Retrieve all borrowers on loan
- `POST` - Add co-borrower
- `PATCH` - Update co-borrower data
- `DELETE` - Remove co-borrower

## Related Documentation

- **Core Module 1.2:** Borrower Information Form (same fields for co-borrower)
- **Core Module 1.3:** Employment & Income (income aggregation)
- **Core Module 1.5:** Assets Management (asset aggregation)
- **Core Module 1.6:** Liabilities Management (liability aggregation)
- **Underwriting 4.1:** Credit Score Determination