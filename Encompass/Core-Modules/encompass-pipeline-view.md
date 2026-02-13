---
type: technical-documentation
module: Core Modules
section: Pipeline Management
subsection: Pipeline View
source: SOP analysis + ICE Mortgage Technology documentation
last_updated: 2026-02-13
---

# Encompass: Pipeline View

## Overview

The Pipeline View is Encompass's central loan management dashboard that displays all active loans in a grid format. It serves as the primary navigation hub for loan officers, processors, and managers to access individual loan files and monitor portfolio status [file:1][file:7].

## Access Path

**Navigation:** Main Menu → Pipeline (or Ctrl+P shortcut)

The Pipeline View appears immediately upon login for most user roles and can be accessed at any time from the main menu bar.

## Key Components

### Search and Filter Bar

**Location:** Top of pipeline grid

**Fields:**
- **Loan Number Search Bar:** Text input for direct loan lookup [file:7]
  - Accepts partial matches (e.g., typing "Lemieux" filters to show all loans containing that string)
  - Real-time filtering as characters are typed
  - Case-insensitive search

- **Filter Dropdown:** Advanced filtering options
  - Filter by Loan Stage (Application, Processing, Underwriting, Closing, Funded, Denied)
  - Filter by Assigned User (LO, Processor, Underwriter)
  - Filter by Date Range (Application Date, Expected Close Date)
  - Filter by Milestone Status

### Pipeline Grid Columns

The grid displays the following columns by default (customizable per user):

| Column Name | Data Type | Description | Source |
|-------------|-----------|-------------|--------|
| **Loan Number** | Text | Unique loan identifier | Auto-generated on application creation |
| **Borrower Name** | Text | Primary borrower full name | `customers.first_name` + `customers.last_name` |
| **Application Date** | Date | Date loan application was initiated | `applications.created_at` [file:8] |
| **Stage** | Badge | Current milestone stage with color coding | `applications.milestone` |
| **Status** | Badge | Detailed status within stage | `applications.status` |
| **Loan Amount** | Currency | Requested loan amount | `applications.loan_amount` |
| **Property Address** | Text | Subject property full address | `properties.address` |
| **Assigned LO** | Text | Loan Officer name | `users.name` WHERE `role = 'loan_officer'` |
| **Assigned Processor** | Text | Processor name | `users.name` WHERE `role = 'processor'` |
| **Last Updated** | Timestamp | Most recent file activity | `applications.updated_at` |
| **Days in Stage** | Number | Days since current stage entry | Calculated field |

### Milestone Badges

Visual status indicators with color coding:

- 🟦 **Application** (Blue) - Initial application submitted
- 🟨 **Processing** (Yellow) - Document collection and verification
- 🟧 **Underwriting** (Orange) - UW review in progress
- 🟪 **Conditional Approval** (Purple) - Approved with conditions
- 🟩 **Clear to Close** (Green) - All conditions satisfied
- 🟥 **Denied** (Red) - Application denied
- ⚫ **Withdrawn** (Gray) - Borrower withdrew
- 🔵 **Funded** (Dark Blue) - Loan closed and funded

## Workflow: Opening a Loan File

### Method 1: Double-Click (Primary)

1. Locate loan in pipeline grid using search or manual scrolling
2. **Double-click** on the loan row [file:7]
   - **System Result:** Opens "Borrower" window in **new window** (not tab) [file:2][file:7]
   - **Pain Point:** Spawns separate window requiring window management [file:2]

### Method 2: Right-Click Context Menu

1. **Right-click** on loan row
2. Select **"Open Loan"** from context menu
   - **System Result:** Opens loan file in new window

### Method 3: Enter Key

1. Select loan row with arrow keys
2. Press **Enter**
   - **System Result:** Opens loan file in new window

## Documented Interactions from SOPs

### Search Workflow Example [file:7]

```
Timestamp: [12:24]
Action: Click [Loan Number Search Bar]
System Result: Search bar is highlighted, ready for input

Timestamp: [12:29]
Action: Type "Lemieux" into [Loan Number Search Bar]
System Result: The list filters to show two entries related to "Lemieux"

Timestamp: [12:52]
Action: Click [Borrower Name Entry]
System Result: A new window titled "Borrower" opens
```

### Pipeline to Borrower Form Navigation [file:8]

```
Timestamp: [09:21]
Action: Click [Application Date] under the Borrowers tab
System Result: Detailed information such as loan amount, borrower count, 
and other related data points are revealed
```

## Common Pain Points

### 1. Multi-Window Chaos [file:2]

**Issue:** Double-clicking a loan spawns a new window, not a new tab. Users managing multiple loans simultaneously end up with 3-5 overlapping windows, requiring alt-tab navigation to find the correct loan.

**Evidence:** 11 documented instances of "a new window appears" across SOPs. Users frequently lost track of which window contained which loan.

**Workaround:** Users manually tile windows or use Windows Snap Assist, but this is inefficient for high-volume processors.

### 2. No Real-Time Updates [file:1]

**Issue:** Pipeline grid does not auto-refresh when loan statuses change. Processors must manually refresh (F5) to see updated statuses from other team members.

**Impact:** Stale data leads to duplicate work (e.g., two processors opening the same loan simultaneously).

### 3. Limited Bulk Actions [file:2]

**Issue:** No ability to select multiple loans and perform batch actions (e.g., reassign 10 loans to a different processor, bulk status update).

**Evidence:** 13+ one-by-one actions documented for tasks that should support bulk operations.

### 4. Column Customization Resets [file:2]

**Issue:** Custom column configurations (order, width, visibility) frequently reset after Encompass updates, forcing users to reconfigure.

## Integration Points

### Inbound Data Sources

- **Consumer Connect Portal:** New applications auto-appear in pipeline [file:3]
- **LOS Integrations:** Imported loan applications from third-party systems
- **Wholesale/TPO Channel:** Broker-submitted loans

### Outbound Actions

- **Open Loan File:** Navigates to Borrower Information form (Core Module 1.2)
- **Export to Excel:** Export pipeline data for external reporting
- **Print Pipeline Report:** Generate PDF snapshot of current pipeline view

## Best Practices

### For Loan Officers

- **Use Search, Not Scroll:** With 50+ loans in pipeline, typing borrower name is faster than scrolling
- **Filter by Stage:** Create saved filters for "My Loans in Processing" and "My Loans Closing This Week"
- **Check Daily:** Review "Last Updated" column daily to identify stalled files

### For Processors

- **Sort by Days in Stage:** Identify loans aging in current stage (e.g., >7 days in Processing)
- **Flag Priority Loans:** Use notes/flags to mark rush closings
- **Refresh Frequently:** Press F5 every 15-30 minutes to catch new assignments

### For Managers

- **Pipeline Review Meetings:** Use grid as visual aid for weekly pipeline reviews
- **Monitor Aging:** Track Days in Stage across team to identify bottlenecks
- **Reassign Strategically:** Balance workload by reassigning loans from overloaded processors

## Technical Notes

### Data Model

The pipeline grid queries the following Encompass database tables:

- `Loan` (primary table)
- `Contacts` (borrower names)
- `Milestones` (stage tracking)
- `LoanAssociates` (assigned users)

### Performance

- **Load Time:** 2-5 seconds for pipelines with 100-500 loans
- **Refresh Rate:** Manual only (no auto-refresh)
- **Concurrency:** Read-only view; no locking when multiple users view same loan in pipeline

### API Access

Pipeline data accessible via Encompass API:
- **Endpoint:** `/encompass/v3/loans`
- **Query Parameters:** `filter`, `limit`, `cursor`
- **Rate Limit:** 10 requests/second

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| **Ctrl+P** | Open Pipeline View |
| **Ctrl+F** | Focus Search Bar |
| **F5** | Refresh Pipeline |
| **↑/↓** | Navigate loan rows |
| **Enter** | Open selected loan |
| **Ctrl+Click** | Multi-select loans (limited functionality) |

## Related Documentation

- **Core Module 1.2:** Borrower Information Form (opened from pipeline)
- **Document Management 2.1:** E-Folder Structure (accessed via pipeline loan)
- **System Administration 12.2:** Milestones & Workflow (configures pipeline stages)
"""