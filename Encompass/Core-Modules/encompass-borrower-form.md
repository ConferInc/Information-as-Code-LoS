---
type: technical-documentation
module: Core Modules
section: Borrower Information Management
subsection: Borrower Information Form
source: SOP analysis (6 transcripts) + Encompass Developer Connect
last_updated: 2026-02-13
---

# Encompass: Borrower Information Form

## Overview

The Borrower Information form is the central data entry screen for all primary borrower personal details in Encompass. This form is accessed immediately upon opening a loan file from the Pipeline View and serves as the foundation for all downstream loan processing activities [file:7][file:8].

## Access Path

**Primary Navigation:**
1. Pipeline View → Double-click loan → **"Borrower" window opens** [file:7]
2. Or: Open loan → **Forms** menu → **Borrower Information**

**Window Behavior:** Opens in a **new window** (not browser tab), separate from the pipeline grid [file:2][file:7].

## Form Structure

### Tab Organization

The Borrower form contains multiple tabs (exact count varies by lender configuration, typically 5-8 tabs):

1. **General** - Core personal information
2. **Employment** - Current and previous employers
3. **Income** - Income sources and calculations
4. **Documents** - Borrower-specific document list
5. **Services** - Third-party service orders
6. **Legal** - Legal disclosures and compliance tracking [file:5]

## Section 1: Personal Information (General Tab)

### Name and Demographics

| Field Name | Data Type | Required | Validation Rules | SOP Evidence |
|------------|-----------|----------|------------------|--------------|
| **First Name** | Text (50 char) | Yes | Alpha only, no special characters | [file:7] "Laylene" |
| **Middle Name** | Text (50 char) | No | Alpha only | Not captured in SOPs |
| **Last Name** | Text (50 char) | Yes | Alpha only, no special characters | [file:7] "Jeune" |
| **Suffix** | Dropdown | No | Jr., Sr., II, III, IV | Not used in SOPs |
| **Gender** | Dropdown | No (HMDA) | Male, Female, I do not wish to provide | [file:7] "Female" |
| **Date of Birth** | Date (MM/DD/YYYY) | Yes | Must be 18+ years ago | [file:7] "1/1/1988" |
| **Marital Status** | Dropdown | Yes | Single, Married, Separated, Divorced, Widowed | [file:7] "Single" |
| **Number of Dependents** | Number (0-99) | No | Integer only | Not captured |
| **SSN** | SSN (XXX-XX-XXXX) | Yes | 9 digits, masked display (XXX-XX-1234) | [file:7] "123456789" |

### Documented Workflow [file:7]

```
Action Log:
[15:00] Click [Borrower] tab
[15:05] Type "Laylene" into [First Name] field
[15:10] Type "Jeune" into [Last Name] field
[15:15] Select [Female] from [Gender] dropdown
[15:20] Type "1/1/1988" into [Date of Birth] field
[15:25] Select [Single] from [Marital Status] dropdown
[15:30] Type "123456789" into [SSN] field
```

### Address Information

**Current Residence (Present Address):**

| Field Name | Data Type | Required | Validation | SOP Evidence |
|------------|-----------|----------|------------|--------------|
| **Address** | Text (100 char) | Yes | Street number + name | [file:7] "123 Main St" |
| **Unit/Apt** | Text (10 char) | No | Apt, Unit, Ste | Not shown |
| **City** | Text (50 char) | Yes | Alpha characters + spaces | [file:7] "Anytown" |
| **State** | Dropdown | Yes | 50 US states + territories | [file:7] "VA" |
| **Zip Code** | Text (5 or 9 digits) | Yes | ##### or #####-#### | [file:7] "12345" |
| **Country** | Dropdown | Yes | Default: USA | Not shown (US default) |
| **Housing Status** | Dropdown | Yes | Own, Rent, Living Rent Free | Not captured |
| **Years at Address** | Number (0-99) | Yes | Decimal allowed (e.g., 2.5) | Not shown |
| **Months at Address** | Number (0-11) | Yes | Used with Years for 24-month history | Not shown |

**Documented Workflow [file:7]:**

```
[15:35] Type "123 Main St" into [Address] field
[15:40] Type "Anytown" into [City] field
[15:45] Select [VA] from [State] dropdown
[15:50] Type "12345" into [Zip] field
```

### Previous Addresses (24-Month History)

**Requirement:** If current address residency < 24 months, additional addresses required [file:1].

**Fields per Previous Address:**
- Full address (Street, City, State, Zip)
- Housing Status (Own, Rent)
- Years/Months at address

**Calculation:** System validates that sum of all address durations ≥ 24 months before allowing submission.

### Contact Information

| Field Name | Data Type | Required | Format | SOP Evidence |
|------------|-----------|----------|--------|--------------|
| **Home Phone** | Phone (10 digits) | No | (###) ###-#### | Not captured |
| **Cell Phone** | Phone (10 digits) | Yes | (###) ###-#### | [file:7] "415-555-1234" |
| **Work Phone** | Phone (10 digits) | No | (###) ###-#### | Not captured |
| **Email** | Email (100 char) | Yes | Valid email format (user@domain.com) | [file:7] "415-555-5678" (note: invalid email in SOP) |

**Pain Point [file:7]:** The SOP shows "415-555-5678" entered in Email field—an invalid email format. Encompass did not validate this in real-time, allowing the processor to continue. The error would only surface later when attempting to send borrower communications.

## Section 2: Government Monitoring (HMDA)

**Purpose:** ECOA and HMDA compliance data collection

| Field Name | Options | Required | Notes |
|------------|---------|----------|-------|
| **Ethnicity** | Hispanic or Latino / Not Hispanic or Latino / I do not wish to provide | No* | *Required to offer |
| **Race** | Multi-select: White, Black, Asian, Native Hawaiian, American Indian | No* | *Required to offer |
| **How Provided** | Face-to-face, Telephone, Fax, Mail, Email, Internet | Yes | Auto-populated by application source |

## Section 3: Identification Documents

**Sub-section:** Borrower ID Verification [file:6]

| Field Name | Data Type | Required | SOP Evidence |
|------------|-----------|----------|--------------|
| **ID Type** | Dropdown | Yes | Driver's License, Passport, State ID, Military ID |
| **ID Number** | Text (50 char) | Yes | Alphanumeric |
| **Issuing State/Country** | Dropdown | Yes | 50 states + countries |
| **Issue Date** | Date (MM/DD/YYYY) | Yes | [file:6] "04/10/2020" |
| **Expiration Date** | Date (MM/DD/YYYY) | Yes | [file:6] "04/10/2020" |
| **Department** | Text | No | [file:6] "STATE" typed manually |
| **License Issuing Authority** | Text | No | [file:6] "DEPARTMENT OF STATE" |

### Documented Workflow [file:6]

```
[05:41] Click [Department field]
[05:41] Type "STATE" into [Department field]
[09:53] Click [Borrower License Issuing Authority field]
[09:53] Type "DEPARTMENT OF STATE" into [Borrower License Issuing Authority field]
[10:19] Select [Yes] from [Is Current?] dropdown
[10:19] Type "04/10/2020" into [Issued Date field]
[10:19] Type "04/10/2020" into [Expiration Date field]
```

### Pain Point: Redundant Data Entry [file:2][file:6]

**Issue:** Processor typed "STATE" in Department field, then separately typed "DEPARTMENT OF STATE" in License Issuing Authority field—the same concept entered twice with zero auto-fill.

**Evidence:** 22+ fields of duplicate data entry documented in a single 15-minute segment. Same borrower SSN, address, city, state, zip are re-entered in Power of Attorney form minutes later [file:2].

## Section 4: Credit Authorization

**Purpose:** Obtain borrower consent for credit pull (FCRA compliance)

| Field Name | Data Type | Required | Notes |
|------------|-----------|----------|-------|
| **Credit Auth Signed** | Checkbox | Yes | Must be checked before credit order |
| **Credit Auth Date** | Date | Yes | Auto-populated on checkbox |
| **Credit Auth Method** | Dropdown | Yes | eSign, Wet Signature, Verbal (recorded) |

**Integration:** Linked to credit ordering workflow—fee gate enforcement checks this field before allowing credit report order [file:1].

## Section 5: Employment Status

**Quick Entry Fields (detailed employment in separate Employment tab):**

| Field Name | Data Type | Options | SOP Evidence |
|------------|-----------|---------|--------------|
| **Employed** | Dropdown | Yes, No, Retired, Self-Employed | [file:7] "Yes" |
| **Occupation** | Text (50 char) | Free text | [file:7] "Manager" |

**If "Yes" selected:** System prompts to complete detailed employment information in Employment tab (see Core Module 1.3).

## Common Pain Points

### 1. Stare-and-Compare Bottleneck [file:2]

**Issue:** Processors must manually compare uploaded borrower documents (driver's license, bank statements) against the Borrower Information form fields in **separate windows**.

**Example from SOP:** Processor opened mortgage statement PDF in one window, then navigated back to Borrower form in separate window to verify "Total Payment" matched "Present Housing: Mortgage" field. When mismatch found, manually typed correction.

**Time Cost:** One processor spent 14 minutes on a single document cross-reference cycle [file:2].

### 2. Redundant Data Entry Across Forms [file:2]

**Issue:** Same borrower data (SSN, address, city, state, zip) must be re-typed in:
- Power of Attorney form [file:5]
- Co-Borrower form (if applicable)
- Disclosure packages [file:1]

**Evidence:** 22+ duplicate field entries in 15-minute segment [file:2]. Encompass does not auto-populate downstream forms from Borrower Information.

### 3. No Real-Time Validation [file:2][file:7]

**Issue:** Invalid data (e.g., email formatted as phone number) accepted without error until much later in workflow.

**Example:** SOP shows "415-555-5678" entered in Email field—clearly invalid—but system allowed save [file:7].

### 4. New Window Spawning [file:2][file:7]

**Issue:** Opening Borrower form spawns new window. Opening related forms (POA, Employment, Assets) spawns additional windows. Users end up with 3-5 overlapping windows per loan.

**Evidence:** 11 documented "new window opens" instances [file:2]. One SOP session captured modal dialog requiring clicking "Close" twice—24 seconds apart—because first click didn't dismiss [file:2].

## Integration Points

### Inbound Data Sources

- **Consumer Connect Portal:** Borrower self-entered data pre-populates form [file:3]
- **1003 URLA Import:** Fannie Mae 3.2/3.4 XML import auto-fills fields
- **CRM Integration:** Lead data from Salesforce/Jungo flows to borrower fields [file:2]

### Outbound Depen dencies

- **Credit Report Order:** SSN, DOB, current address required [file:8]
- **1003 Generation:** All fields map to URLA sections
- **Disclosure Packages:** Name, address, email used for delivery [file:1]
- **Underwriting:** Borrower info reviewed in UW-1A form [file:8]

## Best Practices

### For Processors

1. **Complete Borrower Info First:** Before ordering credit or starting processing, ensure 100% of Borrower form complete
2. **Verify Against Docs:** Cross-reference uploaded driver's license and bank statements before marking complete
3. **Check 24-Month History:** Validate address history adds to ≥24 months before advancing to Processing

### For Loan Officers

1. **Pre-fill from CRM:** Use Salesforce integration to auto-populate borrower data from lead record
2. **Request Portal Completion:** Send Consumer Connect link to borrower to self-enter data (reduces manual entry)

### For Quality Control

1. **Spot Check SSN:** Verify SSN matches credit report and W2s
2. **Address Validation:** Use USPS address validation tool (if integrated) to standardize addresses

## Technical Notes

### Data Model

**Primary Table:** `Contacts` (Encompass database)

**Key Fields (Encompass Field IDs):**
- `FirstName` - Field ID: 4000
- `LastName` - Field ID: 4002
- `SSN` - Field ID: 65
- `BirthDate` - Field ID: 1402
- `EmailAddress` - Field ID: 6093

### Field-Level Security

- **SSN:** Masked display for most roles (shows XXX-XX-1234). Only Admin and Compliance see full SSN.
- **Credit Auth:** Read-only after checked (prevents unauthorized credit pulls)

### API Access

**Encompass API Endpoint:** `/encompass/v3/loans/{loanId}/contacts`

**Methods:**
- `GET` - Retrieve borrower data
- `PATCH` - Update specific fields
- `POST` - Create new contact (co-borrower)

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| **Ctrl+S** | Save Borrower form |
| **Tab** | Navigate to next field |
| **Shift+Tab** | Navigate to previous field |
| **F2** | Edit selected field |

## Related Documentation

- **Core Module 1.3:** Employment & Income Form
- **Core Module 1.4:** Residence History Tracking
- **Core Module 1.5:** Co-Borrower Management
- **Document Management 2.3:** Identity Documents Upload
- **Processing Workflows 3.1:** Processing Workbook - Borrower Info Review
"""