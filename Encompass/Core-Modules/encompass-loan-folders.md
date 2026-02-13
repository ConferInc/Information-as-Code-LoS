---
type: technical-documentation
module: Core Modules
section: Loan Management & Organization
subsection: Loan Folders & File Structure
source: SOP analysis + Encompass documentation
last_updated: 2026-02-13
---

# Encompass: Loan Folders & File Organization

## Overview

Encompass organizes each loan application as a "loan file" or "loan folder" containing all data, documents, forms, and communications related to that specific mortgage application. Understanding loan folder structure is critical for efficient file management and navigation [file:7][file:8].

## Access Path

**Primary Navigation:**
1. Pipeline View → Double-click loan → Opens loan folder (Borrower window) [file:7]
2. Or: Search by Loan Number → Opens loan folder
3. Or: Recent Loans list → Select loan → Opens loan folder

## Section 1: Loan Folder Structure

### Core Components

Every loan folder contains the following core sections (accessible via tabs or menus):

| Section | Purpose | Access Point |
|---------|---------|--------------|
| **Borrower Information** | Personal details, employment, income | [Borrower] tab [file:7] |
| **Property Information** | Subject property details, value, appraisal | [Property] tab |
| **Assets & Liabilities** | Financial statement | [Assets] / [Liabilities] tabs |
| **Documents (E-Folder)** | All uploaded and generated documents | [Documents] tab [file:8] |
| **Forms** | Loan application forms (1003, etc.) | [Forms] menu |
| **Services** | Third-party service orders (credit, appraisal) | [Services] tab [file:7] |
| **Underwriting** | UW decision, conditions, notes | [Underwriting] tab [file:8] |
| **Closing** | Closing Disclosure, signing, funding | [Closing] tab |
| **Loan Details** | Loan amount, rate, term, product | [Loan] tab |

## Section 2: Loan Number Assignment

### Loan Number Format

**Typical Structure:**
- **Format:** 8-12 digit alphanumeric code
- **Example:** "RAU40084203" (from SOP evidence [file:7])
- **Components:** May include branch code, year, sequential number

**SOP Evidence [file:7]:**
```
Email title: "EVOLVE CREDIT APPROVAL - Raulinio40084203 - system updates needed"

Loan number "Raulinio40084203" (or variant) used throughout SOPs
```

### Loan Number Uses

- **Unique identifier** for each loan application
- **Search key** in Pipeline View [file:7]
- **Reference number** for third-party services (credit report, appraisal)
- **Filing system** for physical documents (if applicable)
- **Investor tracking** when loan is sold on secondary market

## Section 3: Loan Folder Navigation

### Window-Based Navigation (Current Encompass Behavior)

**Pain Point [file:2]:**
"Opening UW-1A? New window. Viewing the credit report in File Viewer? New window. Checking the Cash to Close estimate? New window. Reviewing the Borrower form? New window."

**Evidence [file:2]:** "In a single workflow, users manage 3-5 overlapping windows, alt-tabbing between them while trying to remember which window has which data."

### Documented Navigation Workflow [file:7]

**Pipeline to Borrower Form:**
```
[12:24] Click [Loan Number Search Bar]
System Result: Search bar is highlighted, ready for input

[12:29] Type "Lemieux" into [Loan Number Search Bar]
System Result: The list filters to show two entries related to "Lemieux"

[12:52] Click [Borrower Name Entry]
System Result: A new window titled "Borrower" opens
```

### Tabbed Sections Within Loan Folder

Once loan folder (Borrower window) is open:
- **General tab:** Core borrower information
- **Employment tab:** Employment and income details
- **Documents tab:** E-Folder access [file:8]
- **Services tab:** Service orders and results [file:7]
- **Legal tab:** Legal disclosures and compliance [file:5]

## Section 4: Loan Stages & Milestones

### Stage Progression

Loans progress through defined stages/milestones:

1. **Application** - Loan application submitted
2. **Processing** - Document collection and verification
3. **Submitted to UW** - File sent to underwriting [file:1]
4. **Underwriting** - UW review in progress [file:8]
5. **Conditional Approval** - Approved with conditions
6. **Clear to Close** - All conditions satisfied
7. **Closing** - Loan documents signed
8. **Funding** - Loan funded and disbursed
9. **Post-Closing** - Final audit and investor delivery
10. **Closed** - Loan complete

**Milestone Tracking:**
Each milestone has associated date fields (e.g., `applications.uwsubmitted_at`, `applications.closingdate`) used for tracking and reporting.

## Section 5: Loan Folder Management

### Folder Permissions & Access Control

**Role-Based Access:**
- **Loan Officer:** Full read/write access to own loans; limited access to team loans
- **Processor:** Full read/write access to assigned loans; workflow actions enabled
- **Underwriter:** Read-only for processing data; read/write for UW decisions and conditions
- **Closer:** Read-only for most fields; read/write for closing documents and funding
- **Manager/Admin:** Full access to all loans; can reassign, delete, modify permissions

### Loan Assignment & Reassignment

**Assigned Users:**
- **Loan Officer** - Originating LO (sales/borrower relationship)
- **Processor** - Assigned processor (document collection, file prep)
- **Underwriter** - Assigned UW (credit decision)
- **Closer** - Assigned closer (closing coordination)

**Reassignment Workflow:**
- Manager can reassign loan to different user (e.g., processor out sick → reassign to backup)
- Pipeline view shows assigned users per loan
- Email notifications sent when loan is reassigned

## Section 6: Loan Folder Organization Best Practices

### For Loan Officers

1. **Name Loans Clearly:** Use borrower last name + property address format for easy identification
2. **Lock Loan Number:** Don't reuse loan numbers (creates confusion in document trail)
3. **Archive Withdrawn Loans:** Move withdrawn/denied loans to separate folder (don't delete—compliance requirement)

### For Processors

1. **Daily Pipeline Review:** Check assigned loans in pipeline daily; prioritize by closing date
2. **Status Updates:** Update milestone status immediately when stage changes (keeps team informed)
3. **Notes for Handoff:** Document key info in notes field before sending to UW (saves underwriter time)

### For Managers

1. **Load Balancing:** Monitor processor assignment counts; reassign if workload imbalanced
2. **Aging Report:** Run weekly report of loans >30 days in same stage (identify stuck files)
3. **Pipeline Meetings:** Use pipeline view in weekly team meetings to review status

## Common Pain Points

### 1. Multi-Window Chaos [file:2]

**Issue:** Opening loan spawns new window. Opening related forms (UW-1A, File Viewer, Property, etc.) spawns additional windows. Users end up with 3-5 overlapping windows per loan.

**Evidence [file:2]:** "11 documented 'new window opens' instances. One SOP session captured modal dialog requiring clicking 'Close' twice—24 seconds apart—because first click didn't dismiss."

**Impact:** Window management overhead slows workflow; easy to lose track of which window contains which data.

### 2. Search Performance [file:2]

**Issue:** Pipeline search can be slow with large loan volumes (500+ active loans). No real-time auto-refresh.

**Evidence [file:2]:** "Pipeline grid does not auto-refresh when loan statuses change. Processors must manually refresh (F5) to see updated statuses."

### 3. No Bulk Actions [file:2]

**Issue:** Cannot select multiple loans and perform batch actions (e.g., reassign 10 loans, bulk status update).

**Evidence [file:2]:** "No ability to select multiple loans and perform batch actions."

**Workaround:** Processors manually open each loan individually to update—time-consuming for high-volume tasks.

## Integration Points

### Inbound Data Sources

- **LOS Integrations:** Imported loans from POS (Point of Sale) systems
- **TPO/Wholesale Channel:** Broker-submitted loans auto-create loan folders
- **Consumer Connect Portal:** Direct-to-consumer applications [file:4]

### Outbound Dependencies

- **Investor Delivery:** Loan data exported to investor upon sale
- **Servicing Transfer:** Loan folder data sent to loan servicer post-closing
- **Compliance Audit:** Loan folders archived for compliance retention (CFPB requires 5 years)

## Technical Notes

### Data Model

**Primary Table:** `Loan` (Encompass database)

**Key Fields:**
- `LoanGUID` - Unique global identifier
- `LoanNumber` - Human-readable loan number
- `LoanFolder` - File path reference (legacy desktop system)
- `MilestoneID` - Current stage/milestone
- `AssignedLO`, `AssignedProcessor`, `AssignedUW`, `AssignedCloser` - User assignments

### API Access

**Endpoint:** `/encompass/v3/loans/{loanId}`

**Methods:**
- `GET` - Retrieve loan data
- `POST` - Create new loan
- `PATCH` - Update loan fields
- `DELETE` - Delete loan (soft delete—archived, not purged)

## Related Documentation

- **Core Module 1.1:** Pipeline View (loan search and navigation)
- **Document Management 2.1:** E-Folder Structure (documents within loan folder)
- **Processing Workflows 3.1:** Processing Workbook (workflow through loan stages)
- **System Administration 12.2:** Milestones & Workflow Configuration