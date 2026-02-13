---
type: technical-documentation
module: Core Modules
section: Assets & Liabilities
subsection: Assets Management
source: SOP analysis + Encompass field documentation
last_updated: 2026-02-13
---

# Encompass: Assets Management

## Overview

The Assets section documents all borrower financial assets including checking accounts, savings accounts, retirement accounts, stocks, bonds, and other liquid assets. Assets are used to verify down payment source, closing cost reserves, and overall financial stability [file:3][file:4][file:6].

## Access Path

**Primary Navigation:**
1. Borrower Window → **Assets** tab [file:4]
2. Or: Forms menu → **Assets & Liabilities**
3. Or: Consumer Connect Portal → **Assets** section [file:4]

## Section 1: Bank Accounts

### Checking Accounts

| Field Name | Data Type | Required | Validation | SOP Evidence |
|------------|-----------|----------|------------|--------------|
| **Account Type** | Dropdown | Yes | Checking, Savings, Money Market | [file:6] "Checking Account" |
| **Financial Institution** | Text (100 char) | Yes | Bank name | Required for verification |
| **Account Number** | Text (20 char) | Yes | Last 4 digits displayed | Partial masking for security |
| **Account Balance** | Currency | Yes | $#,###.## | [file:6] "$100,000" entered |
| **Statement Date** | Date | Yes | Date of most recent statement | For verification |

**Documented Workflow [file:6]:**
```
[30:00] Click [Checking Account]
[30:05] Click [Add] button next to [Bank Account] field
[30:10] Type "100000" into [Amount] field
[30:15] Click [Save] button
System Result: The entered bank account details are saved
```

### Savings Accounts

**Same fields as Checking, with addition of:**
- **Average Balance:** 2-month or 3-month average (for reserve calculation)

### Money Market Accounts

**Same structure as Savings**

**Note:** All deposit accounts require 2 months most recent bank statements for verification.

## Section 2: Retirement Accounts

### 401(k), IRA, 403(b), TSP

| Field Name | Data Type | Required | Notes |
|------------|-----------|----------|-------|
| **Account Type** | Dropdown | Yes | 401k, Traditional IRA, Roth IRA, 403b, TSP, SEP IRA, SIMPLE IRA |
| **Financial Institution** | Text (100 char) | Yes | Custodian name (Fidelity, Vanguard, etc.) |
| **Account Number** | Text (20 char) | Yes | Masked display |
| **Vested Balance** | Currency | Yes | Amount available for withdrawal |
| **Employer Match** | Currency | No | Monthly employer contribution |
| **Statement Date** | Date | Yes | Most recent quarter-end statement |

**Reserve Calculation Rules:**
- **Traditional 401k/IRA:** Vested balance × 60% (assumes 40% tax/penalty)
- **Roth IRA:** Contributions (not earnings) = 100% available
- **401k Loan:** Existing loan reduces vested balance

**Documentation Required:**
- Most recent quarterly statement showing vested balance
- If using for reserves: Letter from plan administrator confirming vesting

## Section 3: Investment Accounts

### Stocks, Bonds, Mutual Funds

| Field Name | Data Type | Required | Notes |
|------------|-----------|----------|-------|
| **Account Type** | Dropdown | Yes | Individual, Joint, Brokerage |
| **Institution** | Text (100 char) | Yes | Brokerage firm |
| **Account Number** | Text (20 char) | Yes | Masked |
| **Market Value** | Currency | Yes | Current value (as of statement date) |
| **Statement Date** | Date | Yes | Must be within 90 days |

**Valuation for Qualification:**
- **Stocks/Mutual Funds:** 70% of market value (30% haircut for volatility)
- **Bonds:** 80-90% of face value (depending on maturity)
- **Stock Options:** Not counted until vested and exercised

## Section 4: Other Assets

### Cash on Hand

| Field Name | Amount | Notes |
|------------|--------|-------|
| **Cash Value** | Currency | Rarely accepted (must be <$1,000 or heavily documented) |

**Red Flag:** Large cash amounts without source documentation trigger fraud concerns.

### Gifts

| Field Name | Data Type | Required | Notes |
|------------|-----------|----------|-------|
| **Gift Amount** | Currency | Yes | Amount of gift funds |
| **Donor Name** | Text (100 char) | Yes | Full name of donor |
| **Donor Relationship** | Dropdown | Yes | Parent, Sibling, Grandparent, Aunt/Uncle, Employer |
| **Gift Source** | Dropdown | Yes | Checking, Savings, Sale of Asset |

**Required Documentation:**
1. **Gift Letter:** Signed statement that funds are a gift (not a loan) with no repayment expected
2. **Donor Bank Statement:** Evidence donor has funds to give
3. **Transfer Evidence:** Wire receipt or canceled check showing transfer to borrower

**Restrictions:**
- **FHA:** Gift funds allowed for entire down payment
- **Conventional:** Gift funds allowed, but borrower must contribute ≥5% from own funds (≥20% LTV)
- **Non-relative gifts:** Often not allowed or require employer letter

### Proceeds from Sale of Asset

| Field Name | Data Type | Required | Notes |
|------------|-----------|----------|-------|
| **Asset Type** | Dropdown | Yes | Real Estate, Vehicle, Boat, Stocks |
| **Sale Price** | Currency | Yes | Gross sale amount |
| **Net Proceeds** | Currency | Yes | After payoff/fees |
| **Closing/Sale Date** | Date | Yes | Date funds received |

**Documentation:**
- **Real Estate:** HUD-1/Closing Disclosure showing net proceeds
- **Vehicle/Boat:** Bill of sale + bank deposit
- **Stocks:** Brokerage statement showing sale + deposit

## Section 5: Asset Verification Workflow

### Standard Verification Requirements [file:1]

**For All Deposit Accounts:**
1. **Bank Statements:** 2 months most recent, consecutive, all pages
2. **Large Deposits:** Any deposit >50% of monthly income requires explanation (Letter of Explanation + source documentation)
3. **Seasoning:** Funds must be in account ≥60 days (or source documented)

**Red Flags Requiring Explanation:**
- **NSF/Overdraft Fees:** Indicates poor cash management
- **Multiple Large Cash Deposits:** Potential undisclosed income or fraud
- **Sudden Balance Spike:** Requires source documentation (gift, sale of asset, tax refund, etc.)

### Processing Workbook Integration [file:1]

**Assets Verification Checklist:**
- [ ] All accounts documented with statements
- [ ] Down payment source verified (funds ≥ required amount)
- [ ] Large deposits explained and documented
- [ ] Gift funds: Letter, donor statement, transfer evidence received
- [ ] Reserve months calculated (min 2 months PITI)
- [ ] Asset summary worksheet complete

**Auto-Completion Rule [file:1]:** Section auto-marks complete when all asset documents have `status = 'reviewed'` in E-Folder.

## Section 6: Reserve Requirements

**Purpose:** Demonstrate borrower can afford mortgage payments after closing

**Calculation:**
```
Required Reserves = Number of Months × PITI

Where:
- PITI = Principal + Interest + Taxes + Insurance
- Number of Months varies by loan type and investor

Examples:
- PITI = $2,500/month
- 2-month reserve = $2,500 × 2 = $5,000
- 6-month reserve = $2,500 × 6 = $15,000
```

**Reserve Requirements by Loan Type:**
| Loan Type | Primary Residence | Second Home | Investment |
|-----------|-------------------|-------------|------------|
| **Conventional (1 unit)** | 2 months | 4 months | 6 months |
| **Conventional (2-4 units)** | 6 months | 6 months | 6 months |
| **FHA** | 0 months | N/A | N/A |
| **VA** | 0 months | N/A | N/A |
| **Jumbo** | 6-12 months | 12 months | 12 months |

**Acceptable Reserve Assets:**
- Checking, savings, money market = 100%
- Stocks/bonds/mutual funds = 70%
- Vested retirement accounts = 60% (assuming tax/penalty)
- Non-vested retirement = 0%

## Common Pain Points

### 1. Manual Cross-Reference with Bank Statements [file:2]

**Issue:** Processor opens bank statement PDF in separate window, manually reads account balance, closes PDF, returns to Assets form, types amount.

**Evidence:** "Processors spend entire sessions opening PDFs, reading values, and re-typing them" [file:2].

**Time Cost:** 14 minutes per document cross-reference cycle [file:2].

### 2. Large Deposit Explanations [file:2]

**Issue:** Borrower makes large deposit (e.g., tax refund, bonus). System doesn't auto-flag, processor manually identifies during review, must request LOE + documentation.

**Workflow Friction:** Separate "Send Message" window requires 6+ clicks to request explanation from borrower [file:7].

### 3. Gift Funds Documentation Chase [file:2]

**Issue:** Gift letters require 3 separate documents (letter, donor statement, transfer proof). Processors spend days chasing missing pieces.

**Impact:** Loan stalled in processing until all 3 docs received.

### 4. Reserve Calculation Errors [file:1]

**Issue:** Manual calculation of reserves (especially with mixed asset types) prone to errors.

**Example:**
- Checking: $10,000 × 100% = $10,000
- 401k: $50,000 × 60% = $30,000
- Stocks: $20,000 × 70% = $14,000
- Total reserves = $54,000

If processor forgets to apply haircut percentages, overestimates reserves.

## Integration Points

### Inbound Data Sources

- **Consumer Connect Portal:** Borrower self-enters asset data [file:4]
- **Bank Statement Parsers:** AI extraction of account numbers and balances (not native) [file:1]
- **1003 Import:** Assets section from Fannie Mae 3.4 XML

### Outbound Dependencies

- **1003 URLA:** Assets section auto-populates Section 4
- **Underwriting:** Reserve calculation displayed in UW decision panel [file:1]
- **Closing:** Down payment wire amount calculated from assets

## Best Practices

### For Loan Officers

1. **Pre-Qualify with Assets:** Verify borrower has sufficient assets for down payment + closing + reserves before taking application
2. **Gift Funds Early:** Identify gift funds upfront and request all 3 docs immediately (avoid delays)
3. **Seasoning Awareness:** Warn borrowers not to make large transfers <60 days before application

### For Processors

1. **Flag Large Deposits:** Review all statements page-by-page for deposits >50% monthly income
2. **Verify Math:** Use calculator to verify account balances match statement totals
3. **Reserve Calculation:** Use Encompass built-in reserve calculator (if available) to avoid manual errors

### For Underwriters

1. **Source and Seasoning:** Verify all funds are sourced and seasoned appropriately
2. **Red Flag Review:** Look for NSF fees, cash deposits, sudden spikes
3. **Gift vs Loan:** Ensure gift letters state "no repayment expected" explicitly

## Technical Notes

### Data Model

**Primary Table:** `Assets` (Encompass database)

**Key Fields (Encompass Field IDs):**
- `AccountType` - Field ID: 264
- `FinancialInstitution` - Field ID: 97
- `AccountNumber` - Field ID: 269
- `CashMarketValue` - Field ID: 267

### API Access

**Endpoint:** `/encompass/v3/loans/{loanId}/applications/{applicationId}/assets`

**Methods:**
- `GET` - Retrieve all assets
- `POST` - Add new asset
- `PATCH` - Update asset
- `DELETE` - Remove asset

## Related Documentation

- **Core Module 1.6:** Liabilities Management (for net worth calculation)
- **Processing Workflows 3.1:** Processing Workbook - Asset Review
- **Document Management 2.2:** Bank Statement Upload & Verification
- **Underwriting 4.1:** Reserve Calculation Requirements