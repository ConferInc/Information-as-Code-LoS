---
type: technical-documentation
module: Document Management
section: Document Operations
subsection: Upload Workflows
source: SOP analysis + Encompass documentation
last_updated: 2026-02-13
---

# Encompass: Document Upload Workflows

## Overview

Document upload is a critical workflow in Encompass with distinct processes for internal users (processors/LOs) versus borrowers using the Consumer Connect Portal. Upload reliability and ease-of-use directly impact loan cycle time [file:2][file:3][file:6].

## Section 1: Internal Upload (Processor/LO)

### Standard Internal Upload Process

**7-Step Process [file:3][file:6]:**

1. **Navigate to Documents Tab**
   - Open loan file → Click **[Documents]** tab

2. **Select Target Folder**
   - Click document category folder in left pane (Income, Assets, etc.)

3. **Initiate Upload**
   - Click **[Add File]** or **[Upload]** button

4. **File Explorer Opens**
   - OS file browser appears (Windows Explorer / Mac Finder)

5. **Select File**
   - Navigate to file location
   - Click file to select
   - Multi-select supported (Ctrl+Click or Shift+Click)

6. **Confirm Upload**
   - Click **[Open]** button in file explorer

7. **Upload Completes**
   - Progress bar displays during upload
   - Document appears in E-Folder with metadata

**SOP Evidence [file:6]:**
```
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

### Supported File Types

| File Type | Extension | Notes |
|-----------|-----------|-------|
| **PDF** | .pdf | Preferred format (no conversion needed) |
| **Images** | .jpg, .jpeg, .png, .tif, .tiff | Auto-converts to PDF for viewing |
| **Word** | .doc, .docx | Converts to PDF for viewing |
| **Excel** | .xls, .xlsx | Limited support (preview may fail) |
| **Text** | .txt | Supported but rare |

**Best Practice:** Convert all documents to PDF before upload for consistent viewing experience.

### Upload Size Limits

- **Single File:** 25 MB maximum
- **Batch Upload:** 100 MB total per batch
- **Exception:** Appraisal PDFs may exceed 25 MB (system allows up to 50 MB for appraisals)

## Section 2: Borrower Portal Upload (Consumer Connect)

### Portal Upload Workflow [file:3]

**8-Click Process Per Document [file:2][file:3]:**

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

**Step-by-Step Breakdown:**
1. **Click Document Category** - Select category (e.g., "U2B Tax Return - Personal")
2. **Click Upload Button** - Modal opens with upload options
3. **Click [LOCAL DRIVE]** - Selects local file upload method
4. **File Explorer Opens** - OS file browser appears
5. **Navigate to File** - Borrower finds file on computer
6. **Select File** - Click file to select
7. **Click [Open]** - Confirms selection
8. **Wait for Upload** - Progress bar displays (or doesn't—see pain point)

### Upload Widget Failure [file:2][file:3]

**Major Pain Point: "0 Documents Uploaded" Bug**

**SOP Evidence [file:3]:**
```
[15:35] Click [Upload Documents]
System Result: A pop-up window with a list of document categories appears

[15:45] Select [U2B Tax Return - Personal] and click [Upload]
System Result: The page updates to show "0 Documents Uploaded" 
under U2B Tax Return - Personal

[15:55] Click [U2B Tax Return - Personal] again
System Result: The page updates to show "0 Documents Uploaded"

[16:05] Click [U2B Tax Return - Personal]
System Result: The page updates to show "0 Documents Uploaded"

[16:15] Click [U2B Tax Return - Personal]
System Result: The page updates to show "0 Documents Uploaded"

[16:25] Click [U2B Tax Return - Personal]
System Result: The page updates to show "0 Documents Uploaded"

[16:35] Click [U2B Tax Return - Personal]
System Result: The page updates to show "0 Documents Uploaded"

[16:45] Click [U2B Tax Return - Personal]
System Result: The page updates to show "0 Documents Uploaded"

[16:55] Click [U2B Tax Return - Personal]
System Result: The page updates to show "0 Documents Uploaded"
```

**8 consecutive clicks, all showing "0 Documents Uploaded."**

**Pain Point [file:2]:**
"Upload widget that showed '0 Documents Uploaded' after 8 clicks. In the borrower portal, one user clicked the same upload button 8 consecutive times with '0 Documents Uploaded' each time—the UI either broke or was so confusing the user couldn't complete a basic file upload."

**Root Cause Theories:**
1. **Progress indicator bug** - Upload succeeds but UI doesn't update counter
2. **Upload fails silently** - Network error with no error message shown
3. **Category mismatch** - File uploads to wrong category, not the one being viewed
4. **Session timeout** - Borrower logged out mid-upload without notification

**Impact:**
- Borrower frustration → phone calls to processor
- Processor must manually request document via email (defeats purpose of portal)
- Loan timeline delays (waiting for document re-upload)

### Successful Upload Example [file:3]

**Driver's License Upload (Worked):**
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

**Key Differences from Failed Upload:**
- Progress bar appeared (visual feedback)
- Progress bar disappeared after completion (clear success indicator)
- Returned to main page (confirmed navigation)
- Document count updated (likely showed "1 Document Uploaded")

## Section 3: Document Retrieval (Portal → Encompass)

### Manual Retrieval Workflow [file:3]

**After borrower uploads via portal, processor must manually retrieve documents into Encompass E-Folder.**

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

**Retrieval Process:**
1. Open loan file in Encompass
2. Navigate to **Documents** tab
3. Click **[Retrieve]** button (often hidden in toolbar or right-click menu)
4. System queries Consumer Connect Portal database
5. Loading animation displays (can take 10-30 seconds)
6. Retrieved documents appear in E-Folder
7. Processor reviews and categorizes documents

**Pain Points:**
- **Not automatic** - Documents don't auto-flow from portal to E-Folder
- **Manual trigger** - Processor must remember to click [Retrieve]
- **No notification** - System doesn't alert processor when borrower uploads
- **Delay risk** - If processor doesn't retrieve, documents stay in portal limbo

**Proposed Fix [file:1]:**
```
Real-time sync: When borrower uploads via portal, Temporal workflow 
auto-triggers document import to Encompass E-Folder with notification 
to assigned processor.
```

## Section 4: Bulk Upload & Batch Processing

### Multi-File Upload

**Internal Users (Processors):**
- Multi-select files in file explorer (Ctrl+Click or Shift+Click)
- Upload up to 20 files simultaneously
- All files must be <100 MB total

**Portal Users (Borrowers):**
- **Not supported** - Borrowers must upload one file at a time [file:3]
- Each upload requires full 8-click process
- **Major friction point** for borrowers with 10+ documents to upload

### Batch Upload via Scanner Integration

**Desktop-Only Feature:**
- Scanner plugged into computer running Encompass desktop client
- Scan-to-Encompass button in scanner software
- Scanned pages auto-upload to E-Folder
- **Not available in web-based Consumer Connect Portal**

## Section 5: Upload Error Handling

### Common Upload Errors

| Error | Cause | User Impact | Resolution |
|-------|-------|-------------|------------|
| **File too large** | >25 MB single file | Upload fails with error message | Compress PDF or split into multiple files |
| **Unsupported format** | .exe, .zip, .rar, etc. | Upload rejected | Convert to PDF or extract contents |
| **Network timeout** | Slow internet connection | Upload fails mid-process | Retry upload (progress lost) |
| **Session expired** | Portal login timeout | Upload fails silently | Re-login and retry (work lost) |
| **0 Documents Uploaded** | UI bug or server error | [file:3] User confusion | Clear cache, refresh page, retry |

### Error Message Quality [file:2]

**Pain Point:** Encompass provides minimal error feedback.

**Example:** When print-file workflow fails at final step [file:2]:
```
Error: "Owned By and Property Used As fields were not populated."

Issue: System accepted all prior steps (form selection, print settings) 
without validation. Error only shown at final "Print" click.

Better UX: Pre-flight validation before initiating workflow, showing 
all missing required fields upfront.
```

## Section 6: Document Naming & Organization

### Automatic vs Manual Naming

**Auto-Generated Documents:**
- System assigns standardized names
- Example: "1003_URLA_2024-02-13.pdf"
- Example: "Loan_Estimate_20240213_v1.pdf"

**Uploaded Documents:**
- Retain original filename by default
- Example: "IMG_1234.jpg" (borrower's phone photo)
- Example: "Scan001.pdf" (generic scanner output)

**Best Practice:** Processor should rename uploaded documents for clarity:
- Before: "IMG_1234.jpg"
- After: "Drivers_License_Borrower_LastName.jpg"

### Document Categorization

**Manual Categorization:**
- After upload, processor assigns document to category
- Drag-and-drop from "Uncategorized" to target folder
- Or: Right-click document → **Move to** → Select category

**Auto-Categorization (Limited):**
- Credit report auto-categorizes to "Credit" folder
- Appraisal auto-categorizes to "Appraisal" folder
- Most uploaded documents land in "Uncategorized" [file:3]

**Proposed AI Fix [file:1]:**
```
Document-extraction Temporal workflow includes classifyDocument activity:
- AI analyzes uploaded PDF/image
- Determines document type (W-2, pay stub, bank statement, DL, etc.)
- Auto-assigns to appropriate E-Folder category
- Processor reviews and confirms classification
```

## Common Pain Points

### 1. 8-Click Upload Per Document [file:2][file:3]

**Issue:** Borrower portal requires 8 clicks per document. No drag-and-drop. No multi-file upload.

**Evidence [file:3]:** Full 8-step workflow documented with timestamps.

**Time Cost:** 5-10 borrower documents × 8 clicks each = 40-80 clicks. Borrowers abandon portal and email documents instead.

### 2. "0 Documents Uploaded" UI Bug [file:2][file:3]

**Issue:** Upload widget shows "0 Documents Uploaded" even after apparent successful upload. No error message. No success confirmation.

**Evidence [file:3]:** 8 consecutive clicks all showing "0 Documents Uploaded."

**Resolution:** None documented in SOPs. Likely requires support call or manual email to processor.

### 3. Manual Retrieval Required [file:3]

**Issue:** Borrower uploads don't auto-sync to Encompass. Processor must manually click [Retrieve].

**Evidence [file:3]:** `[48:00] Click [Retrieve] - System Result: A loading animation appears`

**Risk:** If processor forgets to retrieve, documents never make it to loan file → UW delay or denial for "missing documents."

### 4. No Upload Notifications [file:1][file:2]

**Issue:** When borrower uploads document via portal, no notification sent to processor. Processor must manually check portal or remember to retrieve.

**Proposed Fix [file:1]:** Smart notification router Temporal workflow to send real-time alerts when borrower uploads.

### 5. No Bulk Upload for Borrowers [file:3]

**Issue:** Borrowers must upload one file at a time. Multi-select not supported in portal.

**Impact:** Borrower with 10 documents spends 10 × 8 clicks = 80 clicks. High abandonment rate.

## Integration Points

### Inbound Data Sources

- **Consumer Connect Portal:** Primary borrower upload channel [file:3]
- **Email Import:** Some lenders use email-to-E-Folder forwarding
- **Scanner Integration:** Desktop only (not web portal)
- **Third-Party API:** Credit, appraisal, title vendors auto-deliver documents

### Outbound Dependencies

- **Document Review Workflow:** Uploaded docs flow to processor review queue [file:7]
- **AI Extraction Pipeline:** Temporal workflow parses uploaded documents [file:1]
- **Underwriting Package:** All uploaded docs must be in E-Folder for UW submission

## Best Practices

### For Loan Officers

1. **Portal Setup:** Send Consumer Connect link with clear instructions ("Upload 10 documents: W-2s, pay stubs, bank statements, etc.")
2. **Set Expectations:** Warn borrowers portal upload is clunky (but still better than email for audit trail)
3. **Follow-Up:** Check portal daily for new uploads; don't wait for system notification (there isn't one)

### For Processors

1. **Daily Retrieval:** Log into Encompass → Documents → [Retrieve] at start of each day
2. **Immediate Review:** Review retrieved documents same day (flag issues while fresh)
3. **Rename Files:** Standardize uploaded filenames for easy future reference
4. **Categorize:** Move documents from "Uncategorized" to proper folders

### For Borrowers (LO Should Advise)

1. **File Format:** Convert phone photos to PDF before upload (better quality, smaller file size)
2. **File Names:** Rename files before upload (e.g., "2024_W2.pdf" instead of "IMG_1234.jpg")
3. **Patience:** Wait for progress bar to complete; don't refresh page mid-upload
4. **Confirmation:** After upload, verify document counter updates (if shows "0," try again or call LO)

## Technical Notes

### Upload API

**Endpoint:** `POST /encompass/v3/loans/{loanId}/documents`

**Request Body:**
```json
{
  "title": "2024_W2_Borrower.pdf",
  "documentType": "Income",
  "fileContent": "<base64-encoded file>",
  "contentType": "application/pdf"
}
```

**Response:**
```json
{
  "documentId": "doc_12345",
  "title": "2024_W2_Borrower.pdf",
  "uploadedDate": "2026-02-13T17:00:00Z",
  "uploadedBy": "user_67890",
  "version": "1.0",
  "status": "Received"
}
```

### Consumer Connect Portal Architecture

**Upload Flow:**
1. Borrower uploads file via portal (separate database from Encompass)
2. File stored in portal's S3 bucket with `loan_id` reference
3. Portal database INSERT: `portal_uploads` table
4. Processor clicks [Retrieve] in Encompass
5. Encompass queries portal database for `loan_id` uploads
6. Encompass copies files from portal S3 to Encompass S3
7. Encompass database INSERT: `documents` table
8. Documents appear in E-Folder

**Sync Lag:** Typically 1-2 minutes after [Retrieve] click.

## Related Documentation

- **Document Management 2.1:** E-Folder Structure (document categories)
- **Document Management 2.3:** Document Viewer (viewing uploaded documents)
- **Document Management 2.4:** Document Review & Verification (post-upload workflow)
- **Processing Workflows 3.1:** Processing Workbook (document verification checklist)