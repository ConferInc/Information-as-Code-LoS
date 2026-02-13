


---
type: technical-documentation
module: Closing & Funding
section: Disbursement & Funding
subsection: Disbursement Manager & Wire Instructions
source: SOP analysis + Encompass documentation
last_updated: 2026-02-13
---

# Encompass: Disbursement Manager

## Overview

The Disbursement Manager is where closers prepare and execute wire transfers to disburse loan funds to all parties involved in the transaction: seller, title company, payoffs, real estate agents, etc. [file:1][file:2]. The system must balance to $0 (total disbursements = loan amount + borrower's cash-to-close) before funding can proceed [file:1].

## Access Path

**Primary Navigation:**
1. Loan Window → **Funding** menu → **Disbursement Manager**
2. Or: Closing tab → **Loan Payment** tab → Ledger view [file:1]
3. Or: Toolbar → **Closing** → **Disbursement**

**Pain Point [file:1]:**
"Loan Payment tab ledger view + Copy Payments to Itemization + manual verification against bank spreadsheets. Sellers remit via separate email. No standardized disbursement format."

## Section 1: Disbursement Manager Interface

### Current Manual Workflow [file:1]

**Problem:** No unified disbursement interface. Multiple steps:
1. Open **Loan Payment** tab → Ledger view
2. Manually list all payees in spreadsheet (external tool)
3. Copy amounts from spreadsheet → Paste into Encompass
4. Manually format wire instructions (no templates)
5. Compose email with wire details via Gmail (external tool) [file:2]
6. Send wire instructions to title company
7. Wait for confirmation email from title company
8. Manually update Encompass: "Wire sent"
9. Repeat for each payee (seller, title, agent, payoffs)

**Time Cost:** 30-60 minutes per loan

### Proposed Unified Interface [file:1]

**confer-web Implementation:**
```
Component: apps/confer-web/src/components/closing/DisbursementManager.tsx
Type: Client Component

Requirements:
- Disbursement table: Payee, Type, Amount, Wire Instructions, Status
- Balance indicator: shows running total vs expected (must balance to $0)
- Wire instruction templates per escrow company (configurable, no manual formatting)
- Dual-authorization workflow: Preparer creates → Approver confirms 
  (enforced when amount > threshold)
- Wire status tracking: Pending → Sent → Confirmed
- "Send Instructions" button generates email with wire details (internal, no Gmail)
- Funding confirmation: When all wires confirmed, auto-advance application to "funded"

Priority: MEDIUM
```

## Section 2: Disbursement Table Structure

### Payee Types

| Payee Type | Description | Example Amount | Typical Wire Instructions |
|------------|-------------|----------------|---------------------------|
| **Seller** | Purchase price to property seller | $360,000 | Seller's bank account (escrow handles) |
| **Title Company** | Title insurance & escrow fees | $3,500 | Title company trust account |
| **Payoff - Existing Loan** | Pay off seller's existing mortgage | $280,000 | Seller's current lender payoff dept |
| **Payoff - HELOC** | Pay off seller's home equity line | $15,000 | HELOC lender payoff dept |
| **Realtor Commission** | Buyer's agent & seller's agent | $27,000 | Brokerage firm trust account |
| **HOA Fees** | Homeowner's association transfer fee | $500 | HOA management company |
| **Recording Fees** | Government recording of deed/mortgage | $300 | County recorder's office |
| **Inspection Repairs** | Repairs negotiated in purchase contract | $2,000 | Contractor or escrow holdback |

### Example Disbursement Table

**Loan Details:**
- Purchase Price: $450,000
- Loan Amount: $360,000
- Borrower's Cash-to-Close: $97,500
- **Total Funds Available:** $457,500 ($360,000 loan + $97,500 borrower cash)

| Payee | Type | Amount | Wire Instructions | Status |
|-------|------|--------|-------------------|--------|
| **Seller (via escrow)** | Seller | $360,000 | ABC Title Trust Account #123456 | ✅ Confirmed |
| **Existing Mortgage Payoff** | Payoff | $280,000 | XYZ Bank Payoff Dept (deducted from seller proceeds) | ✅ Confirmed |
| **ABC Title Company** | Title/Escrow | $3,500 | ABC Title Trust Account #123456 | ✅ Confirmed |
| **Realtor Commission** | Commission | $27,000 | ABC Title distributes to agents | ✅ Confirmed |
| **HOA Transfer Fee** | HOA | $500 | HOA Management Co. | ⏳ Pending |
| **Recording Fees** | Govt Fees | $300 | County Recorder | ⏳ Pending |
| **Property Tax Proration** | Proration | $1,200 | Paid via escrow | ⏳ Pending |
| **Reserve - Borrower Cash** | Return to Borrower | $85,000 | Borrower's account (unused cash) | ⏳ Pending |
| **TOTAL DISBURSEMENTS** | - | **$457,500** | - | - |

**Balance Check:**
```
Total Funds Available: $457,500
Total Disbursements:   $457,500
Balance:               $0 ✅ (Must = $0 to fund)
```

**Balance Indicator [file:1]:**
```
┌─────────────────────────────────────────────┐
│  Disbursement Balance                       │
│  Total Funds:        $457,500               │
│  Total Disbursed:    $457,500               │
│  Balance:            $0 ✅                  │
│  ████████████████████ 100% Allocated        │
└─────────────────────────────────────────────┘
```

**If Imbalanced:**
```
│  Balance:            -$1,000 ❌             │
│  ERROR: Over-disbursed by $1,000            │
```

## Section 3: Wire Instruction Templates

### Manual Wire Formatting Problem [file:1]

**Current Issue:** Closer manually types wire instructions for each disbursement. No templates. Prone to typos.

**Example Manual Entry:**
```
Payee: ABC Title Company
Bank: Wells Fargo
Routing: 121000248
Account: 1234567890
Account Name: ABC Title Trust Account
Reference: Loan #123456 - Smith Purchase
```

**If Typo in Routing Number:** Wire fails → Funding delayed 1-3 days → Closing postponed.

### Wire Instruction Templates [file:1]

**Proposed Solution:** Pre-configured templates per escrow company.

**Template Example (ABC Title Company):**
```json
{
  "escrow_company": "ABC Title Company",
  "bank_name": "Wells Fargo",
  "routing_number": "121000248",
  "account_number": "1234567890",
  "account_name": "ABC Title Trust Account",
  "wire_type": "Domestic",
  "reference_format": "Loan #{loan_number} - {borrower_last_name} Purchase"
}
```

**Auto-Population:**
1. Closer selects **[ABC Title Company]** from dropdown
2. System auto-fills wire instructions from template
3. Reference auto-generates: "Loan #123456 - Smith Purchase"
4. Closer reviews → Clicks **[Send Wire Instructions]**

**Time Saved:** 5-10 minutes per disbursement × 5 disbursements = 25-50 minutes per loan

## Section 4: Dual-Authorization Workflow

### Why Dual-Authorization?

**Fraud Prevention:** Large wire transfers (e.g., $360K to seller) require two people to confirm:
1. **Preparer** (Closer): Creates disbursement, enters wire details
2. **Approver** (Operations Manager): Reviews and approves

**Typical Thresholds:**
- < $10,000: Single approval (closer only)
- $10,000-$100,000: Dual approval required
- > $100,000: Dual approval + executive review

### Dual-Authorization Workflow [file:1]

**Proposed Implementation:**
```
Workflow:
1. Closer creates disbursement: Payee = Seller, Amount = $360,000
2. System checks: $360,000 > $100,000 threshold → Dual approval required
3. System status: "Pending Approval"
4. System notifies Operations Manager: "Disbursement #789 requires approval"
5. Operations Manager reviews:
   - Wire instructions correct?
   - Amount matches settlement statement?
   - Payee verified?
6. Operations Manager clicks [Approve] → Status: "Approved"
7. System status: "Ready to Send"
8. Closer clicks [Send Wire Instructions] → Status: "Sent"
```

**Audit Trail:**
- Created by: John Closer (02/14/2026 9:00 AM)
- Approved by: Jane Manager (02/14/2026 9:15 AM)
- Sent at: 02/14/2026 9:20 AM
- Confirmed by: ABC Title Company (02/14/2026 10:05 AM)

## Section 5: Wire Status Tracking

### Status Lifecycle

| Status | Description | Who Acts | Next Step |
|--------|-------------|----------|-----------|
| **Draft** | Disbursement created but not submitted | Closer | Submit for approval |
| **Pending Approval** | Awaiting Operations Manager approval | Ops Manager | Approve or reject |
| **Approved** | Ready to send wire instructions | Closer | Send wire instructions |
| **Sent** | Wire instructions sent to recipient | Recipient (Title Co) | Confirm receipt of funds |
| **Confirmed** | Recipient confirmed funds received | System | Mark as complete |
| **Failed** | Wire failed (wrong routing, etc.) | Closer | Correct and re-send |

### Real-Time Status Updates

**Visual Example:**
```
┌─────────────────────────────────────────────────────────────────┐
│  Disbursements - Loan #123456                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  Payee             Amount      Status        Last Updated        │
│  ────────────────  ──────────  ────────────  ──────────────────  │
│  Seller (Escrow)   $360,000    ✅ Confirmed  02/14 10:05 AM      │
│  ABC Title Co.     $3,500      ✅ Confirmed  02/14 10:10 AM      │
│  Mortgage Payoff   $280,000    ✅ Confirmed  02/14 10:15 AM      │
│  HOA Transfer      $500        ⏳ Sent       02/14 9:45 AM       │
│  Recording Fees    $300        📝 Approved   02/14 9:30 AM       │
│                                                                   │
│  [Send All Approved Wires]  [Refresh Status]                    │
└─────────────────────────────────────────────────────────────────┘
```

## Section 6: Send Wire Instructions

### Manual Email Composition Problem [file:1][file:2]

**Current Workflow:**
1. Closer manually composes email in Gmail (external tool) [file:2]
2. Subject: "Wire Instructions - Loan #123456"
3. Body: Manually types wire details (prone to copy-paste errors)
4. Attaches settlement statement PDF
5. Sends email to title company
6. Title company replies: "Funds received" (hours later)
7. Closer manually updates Encompass: "Wire confirmed"

**Time Cost:** 5-10 minutes per wire × 5 wires = 25-50 minutes per loan

### Automated Email Generation [file:1]

**Proposed Workflow:**
1. Closer clicks **[Send Instructions]** button [file:1]
2. System auto-generates email:

```
From: closer@mortgagecompany.com
To: wires@abctitle.com
Subject: Wire Instructions - Loan #123456 - Smith Purchase

Dear ABC Title Company,

Please disburse funds for Loan #123456 (Smith Purchase) as follows:

───────────────────────────────────────────────────────
Disbursement #1: Seller Payment
───────────────────────────────────────────────────────
Amount: $360,000.00
Payee: John & Jane Smith (via ABC Title Trust Account)
Bank: Wells Fargo
Routing: 121000248
Account: 1234567890
Account Name: ABC Title Trust Account
Reference: Loan #123456 - Smith Purchase

───────────────────────────────────────────────────────
Disbursement #2: Title & Escrow Fees
───────────────────────────────────────────────────────
Amount: $3,500.00
Payee: ABC Title Company
[Wire details same as above]

Total Disbursement: $363,500.00

Attached: Settlement Statement (CD)

Please confirm receipt of funds by replying to this email.

Best regards,
[Closer Name]
[Mortgage Company Name]
```

3. System sends email via Resend/AWS SES (internal [file:1], not Gmail [file:2])
4. System logs email in `communications` table (audit trail)
5. Title company replies → System detects reply → Auto-updates status to "Confirmed"

**Time Saved:** 5 minutes per wire × 5 wires = 25 minutes per loan

## Section 7: Funding Confirmation & Auto-Advance

### When Can Loan Fund?

**Prerequisites:**
1. ✅ All underwriting conditions cleared
2. ✅ CD sent 3 business days ago (TRID timer elapsed)
3. ✅ Borrower signed all closing documents
4. ✅ All disbursements confirmed (funds received by all parties)
5. ✅ Title insurance issued
6. ✅ Deed recorded (in some states)

### Auto-Advance to "Funded" Status [file:1]

**Proposed Workflow [file:1]:**
```
Trigger: Last disbursement status changes to "Confirmed"

Logic:
1. Check all disbursements for loan #123456
2. If ALL status = "Confirmed":
   - UPDATE applications SET stage = "Funded", status = "Complete"
   - UPDATE applications SET funded_at = CURRENT_TIMESTAMP
   - Fire event: "loan_funded"
   - Notify loan officer: "Loan #123456 funded successfully!"
   - Notify borrower: "Congratulations! Your loan has been funded."
```

**Current Manual Workflow:**
- Closer manually checks each disbursement confirmation email
- Closer manually updates loan stage to "Funded"
- Closer manually emails loan officer: "Loan funded"
- Closer manually emails borrower: "Congratulations"

**Time Saved:** 10-15 minutes per loan

## Section 8: Common Disbursement Pain Points

### 1. Manual Spreadsheet Tracking [file:1]

**Issue:** Closers maintain disbursements in external Excel spreadsheet [file:1]. No integration with Encompass.

**Evidence [file:1]:** "Manual verification against bank spreadsheets"

**Risk:** Copy-paste errors when transferring data from spreadsheet to Encompass.

**Proposed Fix [file:1]:** Unified disbursement table in Encompass (no external spreadsheet).

### 2. No Standardized Wire Format [file:1]

**Issue:** "No standardized disbursement format" [file:1]. Every closer formats wire instructions differently.

**Risk:** Typos → Wire failures → Funding delays.

**Proposed Fix [file:1]:** Wire instruction templates per escrow company.

### 3. Sellers Remit via Separate Email [file:1]

**Issue:** "Sellers remit via separate email" [file:1]. Closer must manually track seller proceeds in Gmail [file:2].

**Time Cost:** 5-10 minutes per loan tracking seller wire confirmations.

**Proposed Fix [file:1]:** All wire confirmations tracked in Disbursement Manager (no separate email tracking).

### 4. Manual Balance Verification

**Issue:** Closer manually calculates: Total disbursements = Total funds available?

**Risk:** Math errors → Over-disbursement or under-disbursement → Funding fails.

**Proposed Fix [file:1]:** Balance indicator auto-calculates and flags imbalances in real-time.

### 5. No Dual-Authorization [file:1]

**Issue:** Single closer can send $360K wire without approval (fraud risk).

**Proposed Fix [file:1]:** Dual-authorization workflow enforced for wires > $100K threshold.

## Section 9: Post-Closing Disbursements

### Holdbacks & Escrows

**What is a Holdback?**
A holdback is funds withheld from closing and held in escrow until a condition is met.

**Common Holdback Types:**

| Holdback Type | Amount | Release Trigger | Example |
|---------------|--------|-----------------|---------|
| **Repair Holdback** | $5,000 | Repairs completed & verified | Roof repair required before closing |
| **HOA Approval** | $1,000 | HOA approval letter received | Condo HOA approval pending |
| **Clear Title** | $10,000 | Lien released | Outstanding mechanic's lien on property |
| **Occupancy** | $2,000 | Borrower moves into property | Investment property converting to primary |

**Holdback Workflow:**
1. Closing occurs with $5,000 held in escrow for roof repair
2. Borrower completes roof repair (1-2 weeks post-closing)
3. Borrower submits proof: Paid invoice + inspection report
4. Title company verifies repair completion
5. Title company releases $5,000 to borrower

**Disbursement Manager Tracking:**
- Status: "Held in Escrow"
- Release Condition: "Roof repair completion"
- Expected Release Date: "03/01/2026"
- When released → Status: "Disbursed"

## Section 10: Disbursement vs Settlement Statement

### What's the Difference?

**Settlement Statement (Closing Disclosure):**
- Borrower-facing document
- Shows borrower's cash-to-close calculation
- Itemizes borrower's costs (closing costs, down payment)
- Shows lender credits, seller credits

**Disbursement Schedule (Internal):**
- Lender-facing document
- Shows how lender disburses loan funds
- Lists all payees (seller, title, agents, payoffs, etc.)
- Must balance to $0 (total funds = total disbursements)

**Example:**
- Borrower brings $97,500 to closing (per CD)
- Lender funds $360,000 loan
- **Total Funds:** $457,500
- Disbursement Manager shows how $457,500 is distributed to 8 different payees

## Integration Points

### Inbound Data Sources

- **Closing Disclosure (CD):** Cash-to-close, closing costs flow to disbursement table
- **Title/Escrow:** Wire instructions for title company, seller, agents
- **Payoff Statements:** Existing mortgage/HELOC payoff amounts and wire instructions
- **Purchase Contract:** Purchase price, seller credits, repair holdbacks

### Outbound Dependencies

- **Wire Transfer System:** Bank integration for wire execution (if fully automated)
- **Email/SMS:** Wire confirmation notifications [file:1]
- **Loan Status:** All disbursements confirmed → Loan status = "Funded" [file:1]
- **Post-Closing:** Holdback tracking for post-closing disbursements

## Best Practices

### For Closers

1. **Use Wire Templates:** Never manually type wire instructions (typo risk)
2. **Balance Before Sending:** Ensure disbursement table balances to $0 before submitting wires
3. **Request Dual Approval:** For wires > $100K, always get manager approval
4. **Verify Payee Info:** Call title company to confirm wire instructions (BEC fraud prevention)
5. **Track Status Daily:** Check disbursement status dashboard daily until all confirmed

### For Operations Managers

1. **Review Dual Approvals Daily:** Don't let disbursements sit in "Pending Approval" status
2. **Audit Wire Templates:** Quarterly review of escrow company wire instructions (they change)
3. **Monitor Failed Wires:** Failed wires = immediate escalation (funding delays)

## Technical Notes

### Data Model

**Primary Table:** `disbursements`

**Key Fields:**
- `id` - Unique disbursement ID
- `loan_id` - Foreign key to applications table
- `payee_name` - Text (e.g., "ABC Title Company")
- `payee_type` - Enum (Seller, Title, Payoff, Commission, HOA, Govt, Other)
- `amount` - Decimal
- `wire_routing` - Text (9-digit routing number)
- `wire_account` - Text (account number)
- `wire_account_name` - Text
- `status` - Enum (Draft, Pending Approval, Approved, Sent, Confirmed, Failed)
- `created_by` - User ID (closer)
- `approved_by` - User ID (operations manager, if dual auth required)
- `sent_at` - Timestamp
- `confirmed_at` - Timestamp

### API Access

**Endpoint:** `POST /api/v1/loans/{loanId}/disbursements`

**Request Body:**
```json
{
  "payee_name": "ABC Title Company",
  "payee_type": "Title",
  "amount": 3500.00,
  "wire_routing": "121000248",
  "wire_account": "1234567890",
  "wire_account_name": "ABC Title Trust Account",
  "reference": "Loan #123456 - Smith Purchase"
}
```

**Response:**
```json
{
  "id": 789,
  "loan_id": 123456,
  "status": "Pending Approval",
  "requires_dual_auth": true,
  "balance_remaining": -1000.00,
  "balance_status": "Over-disbursed by $1,000"
}
```

## Related Documentation

- **Closing 5.1:** Closing Disclosure (CD finalized before disbursements)
- **Processing Workflows 3.3:** Workflow Automation (funding confirmation event)
- **Core Modules 1.1:** Pipeline Management (loan status "Funded")
- **Core Modules 1.3:** Notifications & Communications (wire confirmation emails)