---
type: technical-documentation
module: Processing Workflows
section: Underwriting Submission
subsection: MISMO Export & Portal Upload
source: SOP analysis + Encompass documentation
last_updated: 2026-02-13
---

# Encompass: UW Submission Workflow (14-Step Export)

## Overview

Submitting a loan file from Encompass to an external underwriting portal (like Evolve, DU Desktop Underwriter, or LP Loan Prospector) requires a manual 14-step export-upload process [file:2][file:6]. This is one of the most painful workflows in Encompass, involving hidden menus, manual file management, and a 10-15 minute processing wait [file:2].

## The 14-Step Manual Export Process

### Complete Workflow [file:2][file:6]

**Pain Point [file:2]:**
"To get a loan file from Encompass to the Evolve underwriting portal, a processor must execute 14 discrete steps: open the Documents tab, right-click for a hidden context menu, navigate to GSE Services, select 'Export ILAD MISMO 3.4,' type a filename, click OK, then switch to the Evolve portal, click Upload, click Add Files, navigate to the saved file, select it, click Open, wait 10-15 minutes for processing."

**SOP Evidence [file:6]:**
```
[37:28] Click [Documents] tab
System Result: The documents tab is selected, and the folder creation 
interface is displayed

[37:56] Click [Right-click menu]
System Result: A context menu appears with options including "GSE services"

[37:56] Click [GSE services]
System Result: The GSE services menu is expanded, showing options like 
"Export ILAD MISMO 3.4"

[37:56] Click [Export ILAD MISMO 3.4]
System Result: A dialog box appears for naming and saving the exported file

[38:24] Type "LDPExport" into [File name] field
System Result: The file name is updated to LDPExport

[38:24] Click [OK] button
System Result: The file is exported and saved in the specified folder

--- Switch to Evolve Portal (separate system) ---

[41:13] Click [Browse] button
System Result: The file browser dialog box appears

[41:13] Navigate to [Templates] folder
System Result: The templates folder is selected in the file browser

[41:13] Type "WC2024Drive" into [File name] field
System Result: The file name is updated to WC2024Drive

[41:13] Click [OK] button
System Result: The file is selected and the dialog box closes

[44:28] Click [Add File] button
System Result: A dialog box appears for selecting the file to upload

[44:28] Navigate to [Same section where file was saved]
System Result: The file is located in the specified section

[44:28] Click [File to upload]
System Result: The file is selected for upload

[44:28] Click [Open] button
System Result: The file upload process begins
```

### Step-by-Step Breakdown

#### **Phase 1: Export from Encompass (Steps 1-7)**

**Step 1: Open Loan File**
- Navigate to loan in Pipeline
- Double-click to open loan window

**Step 2: Navigate to Documents Tab**
- Click **[Documents]** tab [file:6]

**Step 3: Access Hidden Context Menu**
- **Right-click** anywhere in Documents area [file:6]
- Context menu appears with 10+ options

**Step 4: Navigate to GSE Services (3-Level Menu)**
- Hover over **GSE services** [file:6]
- Sub-menu expands with 5+ options
- Locate **Export ILAD MISMO 3.4** [file:6]

**Pain Point [file:2]:**
"The export function itself is buried behind a 3-level right-click menu that new users would never discover."

**Step 5: Click Export ILAD MISMO 3.4**
- Dialog box opens: "Save As" [file:6]

**Step 6: Name the Export File**
- Type filename (e.g., "LDPExport") [file:6]
- Choose save location (e.g., C:\\Users\\Processor\\Desktop\\Exports)
- **Pain Point:** Manual folder navigation every time

**Step 7: Confirm Export**
- Click **[OK]** button [file:6]
- System generates MISMO 3.4 XML file (5-10 seconds)
- File saved to chosen location

#### **Phase 2: Upload to Evolve Portal (Steps 8-14)**

**Step 8: Switch to Evolve Portal**
- Open web browser
- Navigate to Evolve underwriting portal (separate website)
- Log in (if not already logged in)

**Step 9: Navigate to Upload Section**
- Click **Upload** or **Submit File** button
- Upload interface appears

**Step 10: Click Add File**
- Click **[Add File]** button [file:6]
- OS file browser dialog opens

**Step 11: Navigate to Saved Export**
- Navigate to folder where MISMO file was saved (Step 6) [file:6]
- Locate file: "LDPExport.xml"

**Step 12: Select File**
- Click file to select [file:6]

**Step 13: Confirm File Selection**
- Click **[Open]** button [file:6]
- File browser closes
- File name appears in upload field

**Step 14: Submit Upload**
- Click **[Submit]** or **[Upload]** button
- System processes file (10-15 minutes) [file:2]
- **Pain Point:** No status updates during processing
- Processor must manually refresh page to check status

### Wait Time: 10-15 Minutes [file:2]

**During Processing:**
- No progress bar in Encompass
- No real-time status updates
- Processor must periodically refresh Evolve portal to check status
- If file has errors, notification appears in Evolve (not Encompass)

**Possible Outcomes:**
- **Accepted:** Loan file successfully uploaded → Processor notified in Evolve
- **Rejected:** Validation errors (missing fields, format issues) → Error message in Evolve
- **Timeout:** Upload failed → Must retry entire 14-step process

## Section 1: MISMO 3.4 XML Format

### What is MISMO?

**MISMO (Mortgage Industry Standards Maintenance Organization):**
- Industry-standard XML format for mortgage data exchange
- Version 3.4 is current standard (as of 2024-2026)
- Contains all loan data: borrower info, property, income, assets, liabilities, etc.

### Sample MISMO XML Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<MISMO_FILE>
  <LOAN_IDENTIFIER>123456</LOAN_IDENTIFIER>
  <BORROWER>
    <FIRST_NAME>Laylene</FIRST_NAME>
    <LAST_NAME>Jeune</LAST_NAME>
    <SSN>123456789</SSN>
    <DOB>11/19/1988</DOB>
    <CURRENT_ADDRESS>
      <STREET>123 Main St</STREET>
      <CITY>Anytown</CITY>
      <STATE>VA</STATE>
      <ZIP>12345</ZIP>
    </CURRENT_ADDRESS>
  </BORROWER>
  <PROPERTY>
    <ADDRESS>456 Oak Ave</ADDRESS>
    <PURCHASE_PRICE>450000</PURCHASE_PRICE>
    <APPRAISED_VALUE>450000</APPRAISED_VALUE>
  </PROPERTY>
  <!-- ... hundreds more fields ... -->
</MISMO_FILE>
```

### Why MISMO Export Required?

**Reason:** Third-party underwriting systems (Evolve, DU, LP) cannot directly access Encompass database.

**Solution:** Export loan data as standardized XML → Upload to portal → Portal parses XML and runs underwriting analysis.

## Section 2: Pain Points & Failures

### 1. Hidden 3-Level Right-Click Menu [file:2]

**Issue:** Export function buried under **Right-click → GSE Services → Export ILAD MISMO 3.4**

**Evidence [file:2]:**
"Core export functionality hidden behind right-click → GSE Services → Export ILAD MISMO 3.4."

**Impact:**
- New processors don't know this feature exists
- Must be trained on hidden menu structure
- Inefficient access to critical function

**Why It's Bad UX:**
- Primary actions should be visible buttons, not hidden in right-click menus [file:1]
- 3-level menu nesting exceeds usability best practices (max 2 levels recommended)

### 2. Manual File Management [file:2][file:6]

**Issue:** Processor must manually name file, choose save location, navigate to file later.

**Pain Point [file:2]:**
"Manual folder creation, file naming, and upload to Evolve portal."

**Workflow Friction:**
- Step 6: Type filename "LDPExport" [file:6]
- Step 11: Navigate back to same folder to find "LDPExport.xml" [file:6]
- **If processor forgets save location:** Must search entire computer for file

**Why It's Bad UX:**
- File should auto-upload to portal without saving to local disk
- Processor shouldn't need to know where XML file is stored

### 3. Two Separate Systems [file:2]

**Issue:** Must switch from Encompass to Evolve portal (separate browser tab/window).

**Evidence [file:2]:**
"14 steps documented across two separate systems with manual file saving and re-uploading."

**Context Switching Cost:**
- Open Encompass → Export file → Switch to browser → Open Evolve portal → Upload file
- If processor forgets to export first, must switch back to Encompass
- No unified interface

### 4. 10-15 Minute Wait with No Status [file:2]

**Issue:** After upload, file processes for 10-15 minutes with zero progress indicator.

**Processor Experience:**
- Click [Submit] → Wait
- No progress bar
- No status updates
- Must manually refresh Evolve portal page every 2-3 minutes
- If refresh too early, see "Processing..." → Refresh again later
- If errors occur, processor doesn't know until processing complete

**Why It's Bad UX:**
- Modern systems show real-time progress (e.g., "Validating fields... 45% complete")
- Encompass provides no feedback during critical 15-minute window

### 5. Validation Errors at Final Step [file:2][file:6]

**Issue:** If MISMO export missing required fields, error shown only after 15-minute upload wait.

**SOP Evidence [file:6]:**
```
[76:30] Click [Print File]
System Result: Error - "Owned By and Property Used As fields were not populated"

Issue: System accepted all prior steps without validation. Error only 
shown at final "Print" click.
```

**Parallel to UW Submission:**
- Processor completes 14-step export
- Waits 15 minutes for processing
- Evolve portal shows: "Error: Borrower SSN missing"
- Processor must return to Encompass, add SSN, re-export, re-upload (14 steps again)

**Why It's Bad UX:**
- Pre-flight validation should check required fields before allowing export [file:1]
- Show missing fields upfront: "Cannot export. Missing: Borrower SSN, Property Address"

### 6. No Automated Tracking [file:1]

**Issue:** After upload, no status tracking in Encompass. Processor must manually check Evolve portal.

**Proposed Fix [file:1]:**
```
Workflow: temporal/workflows/uw-submission.ts

Activities:
4. trackStatus - Poll portal for processing status until accepted/rejected
5. updateApplication - On acceptance, UPDATE uwsubmissions.status and 
   advance stage
```

## Section 3: Proposed Automation [file:1]

### One-Click UW Submission

**Vision [file:2]:**
"One click. Our platform has direct API integrations with underwriting engines (DU, LPA, and third-party portals). The processor clicks 'Submit to Underwriting' and the system handles the MISMO export, secure transmission, and status tracking automatically. No file management. No alt-tabbing to a second portal. No right-click menus."

**Implementation [file:1]:**
```
Workflow: temporal/workflows/uw-submission.ts
Trigger: Processor clicks "Submit to Underwriting" in confer-web

Activities:
1. generateMISMO - Export loan data as MISMO 3.4 XML from Supabase
2. validateExport - Check all required MISMO fields are populated; 
   return errors if not
3. submitToPortal - API call to Evolve/DU/LPA with XML payload
4. trackStatus - Poll portal for processing status until accepted/rejected
5. updateApplication - On acceptance, UPDATE uwsubmissions.status and 
   advance stage

Priority: MEDIUM
```

### Pre-Flight Validation [file:1]

**Before allowing export:**
1. Check all required MISMO fields populated
2. Show checklist of missing fields if incomplete:
   - ⚠️ Borrower SSN missing
   - ⚠️ Property Address incomplete
   - ⚠️ Employment info missing for Co-Borrower
3. Disable "Submit to UW" button until all fields complete
4. When complete, enable button → One click submits

**User Experience:**
```
Processor clicks [Submit to Underwriting]

If incomplete:
  Modal shows: "Cannot submit. Missing required fields:"
  - ⚠️ Borrower SSN
  - ⚠️ Co-Borrower Employment
  [Fix Issues] button navigates to missing fields

If complete:
  Modal shows: "Submitting to Evolve..."
  Progress bar: [█████████░░░] 75% - Validating data
  Success: "Submitted! Evolve status: Processing (est. 10 min)"
```

## Section 4: Alternative Submission Methods

### Desktop Underwriter (DU) Direct Integration

**Fannie Mae's Desktop Underwriter:**
- Some Encompass installations have DU plugin
- Click **Services** → **Desktop Underwriter** → **Order DU**
- Export happens automatically (no manual MISMO file)
- Results return to Encompass (no separate portal)

**Better UX than Evolve workflow, but still has issues:**
- Results can take 5-15 minutes
- No real-time progress indicator
- Findings appear in Encompass forms (must manually review)

### Loan Prospector (LP) Integration

**Freddie Mac's Loan Prospector:**
- Similar to DU integration
- Click **Services** → **Loan Prospector** → **Order LP**
- Auto-export and auto-return of findings

**Same UX issues as DU:** No progress tracking, manual review of findings.

## Common Pain Points

### 1. 14-Step Manual Process [file:2][file:6]

**Issue:** Export-upload workflow requires 14 discrete steps across two systems.

**Evidence [file:2]:** "14 steps documented across two separate systems with manual file saving and re-uploading."

**Time Cost:** 5-10 minutes per submission (excluding 10-15 minute processing wait).

### 2. Hidden 3-Level Menu [file:2]

**Issue:** Export function buried in **Right-click → GSE Services → Export ILAD MISMO 3.4**.

**Impact:** New users never discover this feature without training.

### 3. No Pre-Flight Validation [file:2][file:6]

**Issue:** System allows export even if required fields missing. Error shown only after 15-minute upload.

**Evidence [file:6]:** Print file error at [76:30] after all prior steps succeeded.

### 4. 10-15 Minute Wait with No Status [file:2]

**Issue:** After upload, processor waits 10-15 minutes with zero feedback.

**Impact:** Processor must manually refresh Evolve portal page to check status.

### 5. Manual File Management [file:6]

**Issue:** Processor must name file, save to folder, navigate back to folder, upload file.

**Better UX:** Auto-upload via API (no local file saving).

## Integration Points

### Inbound Data Sources

- **Processing Workbook:** Must be 100% complete before UW submission allowed
- **Documents Tab:** All required documents must be uploaded and reviewed
- **Loan Application Data:** All borrower, property, income, asset, liability data

### Outbound Dependencies

- **Evolve Portal:** Receives MISMO XML file [file:6]
- **Desktop Underwriter (DU):** Fannie Mae underwriting engine
- **Loan Prospector (LP):** Freddie Mac underwriting engine
- **Underwriting Decision:** UW reviews findings and renders decision

## Best Practices

### For Processors

1. **Pre-Validate Before Export:** Manually check all required fields populated before attempting export (avoid re-work)
2. **Standardize Filenames:** Use naming convention: `{LoanNumber}_MISMO_{Date}.xml` (e.g., "123456_MISMO_2026-02-13.xml")
3. **Track Submissions:** Keep log of submissions (loan #, date, time, status) in spreadsheet
4. **Don't Close Encompass:** Keep Encompass open while waiting for Evolve processing (in case need to make corrections)

### For Underwriters

1. **Check Submission Status:** Don't assume file submitted just because processor says so—verify in Evolve portal
2. **Review Findings Promptly:** Evolve findings expire after 120 days—review within days, not weeks

## Technical Notes

### MISMO 3.4 Required Fields

**Minimum fields for valid export:**
- Loan Number
- Borrower: First Name, Last Name, SSN, DOB, Address
- Co-Borrower (if applicable): Same fields as Borrower
- Property: Address, Purchase Price, Appraised Value
- Employment: Employer Name, Income, Years on Job
- Credit Report: Credit Scores, Trade Lines

**If any required field missing:** Export fails or Evolve rejects file.

### API Integration (Proposed [file:1])

**Endpoint:** `POST /evolve/api/v1/submissions`

**Request Body:**
```json
{
  "loanNumber": "123456",
  "mismoXML": "<MISMO_FILE>...</MISMO_FILE>",
  "submittedBy": "processor@company.com",
  "submittedAt": "2026-02-13T17:30:00Z"
}
```

**Response:**
```json
{
  "submissionId": "sub_789",
  "status": "Processing",
  "estimatedCompletionTime": "2026-02-13T17:45:00Z"
}
```

**Polling for Status:**
```
GET /evolve/api/v1/submissions/{submissionId}/status

Response:
{
  "status": "Accepted",
  "findings": {
    "duFindings": "Approve/Eligible",
    "conditions": ["Verify employment", "Provide proof of insurance"]
  }
}
```

## Related Documentation

- **Processing Workflows 3.1:** Processing Workbook (must be complete before submission)
- **Document Management 2.1:** E-Folder Structure (required documents for submission)
- **Underwriting 4.1:** UW Decision Panel (what happens after submission accepted)
- **Underwriting 4.2:** Conditions Management (handling conditions from UW findings)