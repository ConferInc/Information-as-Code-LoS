---
type: technical-documentation
module: Document Management
section: Document Storage & Organization
subsection: E-Folder Structure
source: SOP analysis + Encompass documentation
last_updated: 2026-02-13
---

# Encompass: E-Folder Structure

## Overview

The E-Folder (Electronic Folder) is Encompass's document repository for each loan file. All uploaded, generated, and received documents are stored in the E-Folder with categorization, version tracking, and access controls [file:3][file:6][file:7].

## Access Path

**Primary Navigation:**
1. Loan Window → **Documents** tab [file:6][file:7]
2. Or: Forms menu → **Documents**
3. Or: Right-click loan in Pipeline → **Documents**

**SOP Evidence [file:6]:**
```
[37:28] Click [Documents] tab
System Result: The documents tab is selected, and the folder creation 
interface is displayed
```

## Section 1: Document Categories

### Standard Encompass Document Types

The E-Folder organizes documents into predefined categories:

| Category | Purpose | Typical Documents | Auto-Generated? |
|----------|---------|-------------------|-----------------|
| **Application** | Initial loan application documents | 1003 URLA, Disclosures | Yes |
| **Income** | Employment & income verification | Pay stubs, W-2s, Tax returns, VOE | No (uploaded) |
| **Assets** | Asset verification | Bank statements, Investment statements | No (uploaded) |
| **Credit** | Credit analysis documents | Credit report, Credit supplement | Yes (when ordered) |
| **Appraisal** | Property valuation | Appraisal report, AVM, BPO | Yes (when received) |
| **Title** | Title & legal documents | Title commitment, Deed, Survey | No (uploaded) |
| **Insurance** | Hazard & mortgage insurance | HOI declaration, Flood cert | No (uploaded) |
| **Underwriting** | UW decision documents | Approval letter, Conditions list, AUS findings | Yes |
| **Closing** | Closing documents | Closing Disclosure, HUD-1, Note, Deed of Trust | Yes |
| **Servicing** | Post-closing documents | Final signed docs, Funding proof | Yes |
| **Misc** | Uncategorized documents | POA, Affidavits, Correspondence | No |

### Consumer Connect Portal Document Categories [file:3]

When borrowers upload via Consumer Connect Portal, they see simplified categories:

**SOP Evidence [file:3]:**
```
[15:35] Click [Upload Documents]
System Result: A pop-up window with a list of document categories appears

[15:45] Select [U2B Tax Return - Personal] and click [Upload]
System Result: The page updates to show "0 Documents Uploaded" 
under U2B Tax Return - Personal
```

**Portal Categories:**
- U2B Tax Return - Personal
- U2B Borrower's Driver's License [file:3]
- Pay Stubs
- Bank Statements
- Purchase Agreement
- Insurance Documents

## Section 2: E-Folder Navigation

### Documents Tab Interface

**Main Components:**
- **Folder Tree (Left Pane):** Hierarchical document categories
- **Document List (Center Pane):** Files in selected category with columns:
  - Document Name
  - File Type (PDF, DOCX, JPG, etc.)
  - Date Uploaded/Generated
  - Version Number
  - Uploaded By (User or "Borrower Portal")
  - Status (Received, Reviewed, Approved)
- **Preview Pane (Right Pane - Optional):** Document preview

**SOP Evidence [file:8]:**
```
[12:10] Click [File Viewer]
System Result: A new window labeled "File Viewer" appears with fields 
like Name, File Type, Date, and Version, which populate with data:
  Name: Credit Report
  File Type: PDF  
  Date: 9/30/2024
  Version: 1.0
```

## Section 3: Document Upload Workflows

### Internal Upload (Processor/LO)

**Standard Upload Process:**
1. Open loan file → Documents tab
2. Select document category folder
3. Click **[Add File]** or **[Upload]** button [file:6]
4. OS file explorer opens
5. Select file(s) → Click **[Open]**
6. Document uploads with progress bar
7. Document appears in E-Folder with metadata

**SOP Evidence [file:6]:**
```
[41:13] Click [Browse] button
System Result: The file browser dialog box appears

[41:13] Navigate to [Templates] folder
System Result: The templates folder is selected in the file browser

[44:28] Click [Add File] button
System Result: A dialog box appears for selecting the file to upload

[44:28] Click [File to upload]
System Result: The file is selected for upload

[44:28] Click [Open] button
System Result: The file upload process begins
```

### Borrower Portal Upload (Consumer Connect)

**Borrower Upload Workflow [file:3]:**

**Pain Point:** 8-click upload process per document with confusing UI [file:2][file:3]

**SOP Evidence [file:3]:**
```
[30:00] Hover over [LOCAL DRIVE] under the U2B Borrower's Drivers License section
[30:01] Click [LOCAL DRIVE]
[30:02] Navigate through the file explorer window
[30:03] Select file named "Chantilly.jpg"
[30:04] Click [Open] in the file explorer
[30:05] Progress bar appears indicating upload status
[30:06] Progress bar disappears after upload completes successfully
[30:08] Return to the main page showing the uploaded document count
```

**Upload Failure Evidence [file:3]:**
```
[15:45] Select [U2B Tax Return - Personal] and click [Upload]
System Result: The page updates to show "0 Documents Uploaded"

[15:55] Click [U2B Tax Return - Personal] again
System Result: The page updates to show "0 Documents Uploaded"

[16:05-16:45] Clicks repeated 8 times, all showing "0 Documents Uploaded"
```

**Pain Point [file:2]:**
"In the borrower portal, one user clicked the same upload button 8 consecutive times with '0 Documents Uploaded' each time—the UI either broke or was so confusing the user couldn't complete a basic file upload."

### Document Retrieval Workflow [file:3]

**After portal upload, processor must manually retrieve:**

**SOP Evidence [file:3]:**
```
[48:00] Click [Retrieve]
System Result: A loading animation appears, and the retrieved documents 
are displayed

[48:14] Click [Affiliated Business Arrangement Disclosure.pdf]
System Result: The document opens in a new window

[48:20] Click [Close]
System Result: The document window closes, and the screen returns to 
the list of documents
```

## Section 4: Document Viewer (File Viewer)

### Viewing Documents

**File Viewer Window [file:8]:**
- Opens in **new window** (pain point [file:2])
- Displays PDF, images, DOCX (converted to PDF)
- Basic navigation: Page up/down, zoom in/out
- No annotation capability
- No side-by-side comparison

**SOP Evidence [file:8]:**
```
[12:10] Click [File Viewer]
System Result: A new window labeled "File Viewer" appears with fields 
like Name, File Type, Date, and Version, which populate with data:
  Name: Credit Report
  File Type: PDF  
  Date: 9/30/2024
  Version: 1.0
```

**Pain Point [file:2]:**
"Separate windows for document viewing (E-Folder/File Viewer) and data forms (Borrower Information). Forces stare-and-compare across windows."

## Section 5: Document Review & Status Tracking

### Document Review Checklist [file:7]

**13-Checkbox Marathon Pain Point [file:2][file:7]:**

**SOP Evidence [file:7]:**
```
[47:24] Click [Credit Report Request] checkbox
System Result: The checkbox is marked as completed

[47:25] Click [Deed Restrictions] checkbox
System Result: The checkbox is marked as completed

[47:26] Click [Final Truth-in-Lending Statement] checkbox
System Result: The checkbox is marked as completed

[47:27] Click [Good Faith Estimate] checkbox
System Result: The checkbox is marked as completed

[47:28] Click [HUD-1 Settlement Statement] checkbox
System Result: The checkbox is marked as completed

[47:29] Click [Notice of Right to Cancel] checkbox
System Result: The checkbox is marked as completed

[47:30] Click [Property Tax Receipt] checkbox
System Result: The checkbox is marked as completed

[47:31] Click [Seller's Disclosure] checkbox
System Result: The checkbox is marked as completed

[47:32] Click [Survey] checkbox
System Result: The checkbox is marked as completed

[47:33] Click [Termite Inspection] checkbox
System Result: The checkbox is marked as completed

[47:34] Click [Title Commitment] checkbox
System Result: The checkbox is marked as completed

[47:35] Click [Uniform Residential Loan Application (URLA)] checkbox
System Result: The checkbox is marked as completed

[47:36] Click [WIRCOE] checkbox
System Result: The checkbox is marked as completed
```

**Pain Point [file:2]:**
"13 checkboxes clicked one-by-one in a single session. Zero bulk-action capability."

### Document Status Values

| Status | Meaning | Who Sets | When Set |
|--------|---------|----------|----------|
| **Received** | Document uploaded/generated | System | Auto on upload |
| **Pending Review** | Awaiting processor review | System | Auto if validation required |
| **Reviewed** | Processor verified | Processor | Manual checkbox [file:7] |
| **Approved** | Underwriter accepted | Underwriter | Manual in UW review |
| **Rejected** | Document issue identified | Processor/UW | Manual with condition |
| **Replaced** | New version uploaded | System | Auto when re-uploaded |

## Section 6: Document Version Control

### Version Tracking

**When document is re-uploaded:**
- Previous version archived (not deleted)
- Version number increments (1.0 → 1.1 → 2.0)
- Upload timestamp recorded
- Uploader identity captured (user ID or "Borrower Portal")

**Accessing Previous Versions:**
1. Right-click document in E-Folder
2. Select **View Version History**
3. List of versions displays with dates and uploaders
4. Select version → **View** or **Restore**

**Pain Point:** No automatic comparison between versions. Processor must open v1.0 in one window, v2.0 in another window, and manually compare.

## Section 7: Document Generation

### System-Generated Documents

**Auto-Generated Documents:**
- **1003 URLA:** From Borrower/Co-Borrower data entry
- **Loan Estimate:** From loan terms + fee worksheet
- **Closing Disclosure:** From CD worksheet [file:6]
- **Approval Letter:** From UW decision panel [file:1]
- **Denial Letter:** From UW decision with adverse action reason

**Generation Workflow:**
1. User completes data entry in relevant form
2. User clicks **[Generate]** button (e.g., "Generate LE")
3. System creates PDF from template + loan data
4. PDF auto-saves to E-Folder in appropriate category
5. PDF opens in File Viewer (new window) for review

**SOP Evidence [file:6]:**
```
[73:04] Select [Est Closing] dropdown menu
System Result: The dropdown menu expands, showing options

[73:06] Choose [Cash to Close Estimate] from the dropdown
System Result: The dropdown menu closes, and the Cash to Close Estimate 
document is selected

[73:08] Click [View Original File] button
System Result: A new window opens displaying the Cash to Close Estimate document

[73:10] Click [Calculate Cash to Close] button
System Result: The document updates to show the calculated cash to close estimate
```

## Common Pain Points

### 1. 8-Click Upload Widget Failure [file:2][file:3]

**Issue:** Borrower portal upload requires 8 clicks per document. UI shows "0 Documents Uploaded" even after successful upload in some cases.

**Evidence [file:3]:** 8 consecutive clicks on "U2B Tax Return - Personal" all showing "0 Documents Uploaded."

**Time Cost:** Borrower frustration → phone calls to processor → manual re-upload.

### 2. Manual Document Retrieval [file:3]

**Issue:** After borrower uploads via portal, documents don't auto-appear in E-Folder. Processor must click **[Retrieve]** to pull documents from portal to Encompass.

**Evidence [file:3]:** `[48:00] Click [Retrieve] - System Result: A loading animation appears, and the retrieved documents are displayed`

**Risk:** If processor forgets to retrieve, documents remain in limbo—not in loan file, not available for UW review.

### 3. 13-Checkbox Review Marathon [file:2][file:7]

**Issue:** No bulk document review. Processor clicks 13 individual checkboxes one-by-one to mark documents as "Reviewed."

**Evidence [file:7]:** 13 sequential checkbox clicks documented from [47:24] to [47:36].

**Time Cost:** ~1 minute per loan just clicking checkboxes (no actual review time counted).

### 4. Stare-and-Compare Across Windows [file:2]

**Issue:** Document opens in File Viewer (new window). Form fields in Borrower window. Processor alt-tabs between windows to cross-reference data.

**Evidence [file:2]:** "6 documented stare-and-compare workflows across SOPs. One processor spent 14 minutes on a single document cross-reference cycle."

**Workflow:**
1. Open uploaded mortgage statement PDF in File Viewer
2. Alt-tab to Borrower Information form
3. Manually compare PDF field to form field
4. Alt-tab back to PDF if value doesn't match
5. Re-read PDF value
6. Alt-tab back to form
7. Type correction
8. Repeat for next field

### 5. No Document AI / Auto-Extraction [file:1][file:2]

**Issue:** Zero automated document parsing. Every value from every uploaded document must be manually read and typed into form fields.

**Evidence [file:2]:** "Processors spend entire sessions opening PDFs, reading values, and re-typing them."

**Proposed Fix [file:1]:**
```
Temporal Workflow: document-extraction.ts
Trigger: documents INSERT (any new upload via portal or internal)

Activities:
1. classifyDocument - AI classifies document type (pay stub, W2, tax return, etc.)
2. extractFields - AI extracts key-value pairs from document based on type
3. mapToSchema - Map extracted fields to Supabase table/column targets
4. createSuggestions - Create suggested field updates (not auto-applied; processor reviews)
5. notifyProcessor - Push notification to processor with extraction results
```

## Integration Points

### Inbound Data Sources

- **Consumer Connect Portal:** Borrower-uploaded documents [file:3]
- **Third-Party Services:** Credit report, appraisal, title docs auto-delivered via API
- **Email Attachments:** Manual forward to E-Folder (some lenders use email import)
- **Scanner Integration:** Direct scan-to-E-Folder (desktop only)

### Outbound Dependencies

- **Underwriting Review:** UW accesses E-Folder to review all documents [file:7]
- **Investor Delivery:** E-Folder documents exported to investor upon loan sale
- **Compliance Audit:** E-Folder is official record for CFPB/state regulator audits
- **Servicing Transfer:** E-Folder documents transferred to loan servicer post-closing

## Best Practices

### For Loan Officers

1. **Portal Setup:** Send Consumer Connect Portal link immediately after application (don't wait for processor)
2. **Document Checklist:** Provide borrower with clear checklist of required documents (reduces "What do you need?" calls)
3. **Version Discipline:** If borrower uploads wrong document, have them re-upload (don't accept via email—keeps audit trail clean)

### For Processors

1. **Daily Retrieval:** Check Consumer Connect Portal daily for new uploads; click **[Retrieve]** to pull into E-Folder
2. **Immediate Review:** Mark documents as "Reviewed" or "Rejected" same day (don't let backlog build)
3. **Version Notes:** When document is replaced, add note explaining why (e.g., "Updated bank statement with missing page 3")
4. **Filename Discipline:** Rename uploaded docs to standard format (e.g., "2024_W2_LastName.pdf" instead of "IMG_1234.jpg")

### For Underwriters

1. **Document Verification:** Always verify document authenticity (check for PhotoShop, white-out, altered dates)
2. **Version History:** Check version history for suspicious re-uploads (multiple W-2 versions may indicate fraud)
3. **Cross-Reference:** Compare documents to each other (pay stub employer should match W-2 employer)

## Technical Notes

### Data Model

**Primary Table:** `Documents` (Encompass database)

**Key Fields (Encompass Field IDs):**
- `DocumentID` - Unique document identifier
- `LoanGUID` - Link to parent loan
- `DocumentTitle` - Filename
- `DocumentType` - Category (Application, Income, etc.)
- `FileType` - Extension (PDF, JPG, DOCX)
- `UploadedDate` - Timestamp
- `UploadedBy` - User ID or "Borrower Portal"
- `Version` - Version number (1.0, 1.1, etc.)
- `Status` - Received, Reviewed, Approved, Rejected
- `FilePath` - S3 or file server path

### API Access

**Endpoint:** `/encompass/v3/loans/{loanId}/documents`

**Methods:**
- `GET` - Retrieve document list or specific document metadata
- `POST` - Upload new document
- `PATCH` - Update document metadata (status, title, etc.)
- `DELETE` - Delete document (soft delete—archived, not purged)

**File Download:**
`GET /encompass/v3/loans/{loanId}/documents/{documentId}/content`
Returns binary file content (PDF, JPG, etc.)

## Related Documentation

- **Core Module 1.1:** Pipeline View (accessing loans to view documents)
- **Document Management 2.2:** Document Upload Workflows (detailed upload processes)
- **Document Management 2.3:** Document Viewer (File Viewer deep dive)
- **Document Management 2.4:** Document Review & Verification
- **Processing Workflows 3.1:** Processing Workbook (document verification checklist)