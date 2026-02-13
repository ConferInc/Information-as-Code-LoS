---
type: technical-documentation
module: Document Management
section: Document Operations
subsection: Document Viewer
source: SOP analysis + Encompass documentation
last_updated: 2026-02-13
---

# Encompass: Document Viewer (File Viewer)

## Overview

The File Viewer is Encompass's built-in document viewing tool for opening PDFs, images, and converted documents within (or rather, spawning from) the loan file. It's plagued by the multi-window problem and lacks side-by-side comparison capabilities [file:2][file:8].

## Access Path

**Primary Navigation:**
1. Documents tab → Select document → Double-click to open [file:8]
2. Or: Right-click document → **View**
3. Or: Documents tab → **[File Viewer]** button [file:8]

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

## Section 1: File Viewer Interface

### Window Structure

**New Window Opens (Pain Point [file:2]):**
- File Viewer always opens in **new window**
- Cannot view document within loan file window
- Forces alt-tabbing between document and data entry forms

**Pain Point [file:2]:**
"Separate windows for document viewing (E-Folder/File Viewer) and data forms (Borrower Information). Forces stare-and-compare across windows."

### Interface Components

| Component | Location | Function |
|-----------|----------|----------|
| **Document Metadata Bar** | Top | Shows Name, File Type, Date, Version |
| **Page Navigation** | Left sidebar | Page thumbnails (if multi-page PDF) |
| **Document Canvas** | Center | Main viewing area |
| **Zoom Controls** | Bottom toolbar | Zoom in/out, fit to width, fit to page |
| **Page Counter** | Bottom right | "Page 1 of 5" indicator |
| **Close Button** | Top right | Closes File Viewer window |

## Section 2: Supported Document Types

### Native Support

| File Type | Extension | Viewing Quality | Notes |
|-----------|-----------|-----------------|-------|
| **PDF** | .pdf | Native rendering | Best quality, all features supported |
| **Images** | .jpg, .jpeg, .png, .tif | Native rendering | Displays at uploaded resolution |
| **Word** | .doc, .docx | Converted to PDF | Auto-converts on open (may lose formatting) |
| **Excel** | .xls, .xlsx | Preview only | Limited support; formulas may not display |

**Best Practice:** All documents should be PDF for consistent viewing experience.

## Section 3: Viewing Features

### Zoom & Navigation

**Zoom Controls:**
- **Zoom In:** Magnify document (25% → 400% range)
- **Zoom Out:** Reduce magnification
- **Fit to Width:** Scale document to fit window width
- **Fit to Page:** Scale entire page to fit window height
- **Actual Size:** Display at 100% (1:1 pixel ratio)

**Page Navigation:**
- **Thumbnail Pane:** Click page thumbnail to jump to page
- **Page Up/Down Keys:** Navigate sequentially
- **Page Number Field:** Type page number → Press Enter

### Annotation Capabilities

**❌ NOT SUPPORTED:**
- No highlighting
- No text annotations
- No sticky notes
- No drawing tools
- No redaction

**Workaround:** If annotation needed, download document → open in Adobe Acrobat → annotate → re-upload to Encompass.

## Section 4: Stare-and-Compare Workflow

### The 14-Minute Cross-Reference Cycle [file:2]

**Pain Point: Dual-Window Document Verification**

**SOP Evidence [file:2]:**
"In one recorded session, a processor opened an uploaded mortgage statement PDF in one window, then navigated back to the Borrower Information form in a separate window to verify that the 'Total Payment' figure matched the 'Present Housing Mortgage' field. When it didn't, they had to manually type the correction."

**Step-by-Step Stare-and-Compare:**
1. Open loan file (Borrower window)
2. Navigate to Documents tab
3. Double-click uploaded mortgage statement
4. File Viewer opens in **new window**
5. Read "Total Payment" amount from PDF: $2,450
6. Alt-tab back to Borrower window
7. Navigate to Housing Expenses section
8. Find "Present Housing Mortgage" field: $2,200
9. Realize discrepancy ($2,450 ≠ $2,200)
10. Alt-tab back to File Viewer window
11. Re-read PDF to confirm: $2,450 (yep, still the same)
12. Alt-tab back to Borrower window
13. Click "Present Housing Mortgage" field
14. Delete old value, type $2,450
15. Save form
16. Move to next field → **Repeat entire cycle**

**Time Cost:** "One processor spent 14 minutes on a single document cross-reference cycle." [file:2]

**Why It's Painful:**
- Two windows = cognitive overhead (where was that number again?)
- Alt-tabbing = lost focus + context switching
- Manual re-typing = human error risk
- No highlighting in PDF = can't mark "already verified" fields

## Section 5: Split-Pane Solution (Not Exists in Encompass)

### Proposed Fix [file:1][file:2]

**Pain Point [file:2]:**
"Forces stare-and-compare across windows."

**Proposed Solution [file:1]:**
```
Component: apps/confer-web/src/components/verification/SplitPaneVerifier.tsx
Type: Client Component with resizable panes

Requirements:
- Left pane: PDF/image viewer (react-pdf or react-pdf-viewer/core) 
  displaying uploaded documents
- Right pane: Corresponding form fields from the relevant section 
  (borrower info, income, assets, etc.)
- AI-extracted values highlighted in the document with matching form 
  fields highlighted on the right
- "Accept AI Extraction" button to auto-fill fields from parsed document data
- "Flag Discrepancy" button to create a condition/task when document 
  doesn't match
- Resizable split via drag handle
- Document navigation (prev/next) without leaving the split view
- Priority: HIGH
```

**Benefit:**
- **One screen:** Document and form side-by-side
- **AI assistance:** Auto-extraction highlights fields
- **One-click apply:** Accept AI suggestions or manually correct
- **No context switching:** All data visible simultaneously

## Section 6: Document Comparison

### Version Comparison (Not Supported)

**Missing Feature:** Cannot view two versions of same document side-by-side.

**Use Case:** Borrower uploads W-2, then re-uploads corrected W-2. Processor needs to see what changed.

**Current Workflow:**
1. Open W-2 v1.0 in File Viewer (window 1)
2. Open W-2 v1.1 in File Viewer (window 2)
3. Alt-tab between windows to spot differences
4. Manually note changes

**Proposed Fix:** Split-screen version comparison with change highlighting (like Git diff for documents).

### Multi-Document Comparison (Not Supported)

**Missing Feature:** Cannot view multiple documents simultaneously.

**Use Case:** Compare pay stub to W-2 to verify employer name and income match.

**Current Workflow:**
1. Open pay stub in File Viewer (window 1)
2. Open W-2 in File Viewer (window 2)
3. Alt-tab between windows to cross-reference
4. Manually verify matching data

**Proposed Fix:** Multi-document tab view within single File Viewer window.

## Section 7: Credit Report Viewing [file:8]

### Credit Report Special Handling

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

**Credit Report Workflow:**
1. Credit report ordered via Services tab
2. Report received from credit bureau (Experian, TransUnion, Equifax)
3. PDF auto-uploads to E-Folder → Credit category
4. Processor opens credit report in File Viewer [file:8]
5. **Manually reads and transcribes** all trade lines to Liabilities section

**Pain Point [file:2]:**
"Credit report PDF appears in E-Folder but liabilities must be manually mapped to the 1003. Scores must be manually verified. No automated liability creation from credit data."

**Time Cost:** 10-15 minutes per loan to manually transcribe 10-15 trade lines.

## Section 8: Document Download

### Downloading Documents

**Download Process:**
1. Documents tab → Select document
2. Right-click → **Download** or **Save As**
3. Choose save location in OS file dialog
4. File downloads to local computer

**Use Cases:**
- Send document to borrower via email
- Print document for physical file
- Edit document in external software (e.g., Adobe Acrobat)
- Archive document locally for backup

**Bulk Download:**
- Not supported in File Viewer
- Cannot select multiple documents and download as ZIP
- Must download one file at a time

## Common Pain Points

### 1. Multi-Window Chaos [file:2]

**Issue:** File Viewer always opens in new window. Opening multiple documents = 3-5 overlapping windows.

**Evidence [file:2]:** "11 documented instances of 'a new window appears.' Opening UW-1A? New window. Viewing the credit report in File Viewer? New window."

**Impact:** Window management overhead, lost context, accidental window closures.

### 2. Stare-and-Compare Bottleneck [file:2]

**Issue:** Document in one window, form fields in another. Processor alt-tabs repeatedly to cross-reference data.

**Evidence [file:2]:** "6 documented stare-and-compare workflows. One processor spent 14 minutes on a single document cross-reference cycle."

**Impact:** Slow processing, human error from context switching, processor fatigue.

### 3. No AI Extraction [file:1][file:2]

**Issue:** Zero automated document parsing. Every value must be manually read and re-typed.

**Evidence [file:2]:** "Processors spend entire sessions opening PDFs, reading values, and re-typing them."

**Proposed Fix [file:1]:** AI document extraction Temporal workflow with split-pane verifier.

### 4. No Annotation Tools

**Issue:** Cannot highlight, comment, or mark up documents within File Viewer.

**Workaround:** Download → open in Adobe Acrobat → annotate → re-upload (adds 5-10 minutes per document).

### 5. No Version Comparison

**Issue:** Cannot view two versions of same document side-by-side to spot changes.

**Workaround:** Open both versions in separate File Viewer windows → alt-tab to compare.

## Integration Points

### Inbound Data Sources

- **E-Folder:** File Viewer displays documents stored in E-Folder
- **Third-Party Documents:** Credit reports, appraisals auto-open in File Viewer when received

### Outbound Dependencies

- **Document Review Workflow:** Processor marks documents as "Reviewed" after viewing [file:7]
- **Underwriting Review:** UW views all documents in File Viewer during loan analysis

## Best Practices

### For Processors

1. **Close Windows:** After reviewing document, close File Viewer window immediately (prevent window clutter)
2. **Use Keyboard Shortcuts:** Alt+Tab to switch windows faster than clicking
3. **Dual Monitors:** Use second monitor for File Viewer (leave Borrower form on primary monitor)
4. **Download for Annotation:** If document needs markup, download → annotate in Adobe → re-upload

### For Underwriters

1. **Document Verification:** Always view original uploaded documents (don't rely on processor-entered data)
2. **Credit Report Analysis:** Open credit report in File Viewer while reviewing Liabilities section
3. **Version History:** Check version history if document has been re-uploaded (may indicate fraud)

## Technical Notes

### File Viewer Technology

**Rendering Engine:**
- PDF: Embedded PDF.js or similar JavaScript PDF renderer
- Images: HTML `<img>` tag with zoom/pan controls
- Word/Excel: Server-side conversion to PDF, then rendered as PDF

**Performance:**
- Large PDFs (>10 MB) can be slow to render
- Multi-page credit reports (30+ pages) may lag on page navigation
- Scanned images load faster than text-heavy PDFs

### API Access

**Endpoint:** `GET /encompass/v3/loans/{loanId}/documents/{documentId}/content`

**Response:** Binary file content (PDF, JPG, etc.) with `Content-Type` header

**Example:**
```bash
curl -X GET "https://api.encompass.com/v3/loans/12345/documents/67890/content" \\
  -H "Authorization: Bearer {token}" \\
  --output document.pdf
```

## Related Documentation

- **Document Management 2.1:** E-Folder Structure (where documents are stored)
- **Document Management 2.2:** Document Upload Workflows (how documents get to E-Folder)
- **Document Management 2.4:** Document Review & Verification (post-viewing workflow)
- **Processing Workflows 3.1:** Processing Workbook (document verification checklist)