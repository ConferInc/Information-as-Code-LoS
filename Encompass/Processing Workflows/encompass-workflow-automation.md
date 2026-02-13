---
type: technical-documentation
module: Processing Workflows
section: Automation & Intelligence
subsection: Temporal Workflow Automation
source: SOP analysis + Encompass feature parity requirements
last_updated: 2026-02-13
---

# Encompass: Workflow Automation (Proposed Temporal Workflows)

## Overview

Current Encompass has **zero workflow automation**. Every task—document extraction, credit import, fee validation, TRID timers, notifications—is manual [file:1][file:2]. This document outlines proposed Temporal workflow automations to eliminate repetitive manual tasks documented in the SOPs.

## Section 1: Temporal Workflow Architecture

### What is Temporal?

**Temporal** is a durable workflow orchestration platform that executes long-running, fault-tolerant business processes [file:1].

**Key Capabilities:**
- **Durable Execution:** Workflows survive system crashes, restarts, deployments
- **Activity Retry:** Failed steps auto-retry with exponential backoff
- **Event-Driven Triggers:** Workflows start on database INSERT, UPDATE, or time-based schedules
- **State Management:** Temporal tracks workflow state (no custom state machines needed)

**Use Case for Mortgage LOS:**
- Document uploaded → Workflow triggered → AI extraction → Processor notification
- UW decision = "Denied" → Workflow triggered → 30-day ECOA timer starts → Escalation alerts
- Loan submitted to UW → Workflow triggered → MISMO export → Portal upload → Status polling

### Workflow vs Activity

| Concept | Definition | Example |
|---------|------------|---------|
| **Workflow** | High-level business process | `document-extraction.ts` - Extract data from uploaded PDF |
| **Activity** | Individual task within workflow | `classifyDocument()`, `extractFields()`, `notifyProcessor()` |

**Workflow orchestrates activities:**
```typescript
// Workflow: document-extraction.ts
export async function documentExtractionWorkflow(documentId: string) {
  const docType = await classifyDocument(documentId);       // Activity 1
  const fields = await extractFields(documentId, docType);  // Activity 2
  await mapToSchema(fields);                                 // Activity 3
  await notifyProcessor(documentId);                         // Activity 4
}
```

## Section 2: Proposed Temporal Workflows

### 2.1 AI Document Extraction Pipeline [file:1]

**Pain Point [file:2]:**
"Zero document parsing. Every value from every uploaded document must be manually read and typed into form fields. Processors spend entire sessions opening PDFs, reading values, and re-typing them."

**Workflow Implementation [file:1]:**
```
Workflow: temporal/workflows/document-extraction.ts
Trigger: documents INSERT (any new upload via portal or internal)

Activities:
1. classifyDocument - AI classifies document type (pay stub, W2, tax return, 
   bank statement, DL, etc.)
2. extractFields - AI extracts key-value pairs from document based on type
3. mapToSchema - Map extracted fields to Supabase table/column targets
4. createSuggestions - Create suggested field updates (not auto-applied; 
   processor reviews)
5. notifyProcessor - Push notification to processor with extraction results

AI Model: Claude for document understanding; OCR pre-processing for scanned documents
Output: documentextractions table with field_name, extracted_value, confidence, 
status (suggested/accepted/rejected)
Priority: HIGH
```

**Example Workflow Execution:**

**Trigger:** Borrower uploads W-2 via Consumer Connect Portal
```
1. documents INSERT → loan_id = 123456, document_type = 'Income', 
   file_name = 'W2_2024.pdf'
2. Temporal workflow starts: documentExtractionWorkflow('doc_789')
```

**Activity 1: classifyDocument**
- Input: PDF binary data
- AI Analysis: "This document is a W-2 tax form for year 2024"
- Output: `document_type = 'W2'`, `tax_year = 2024`

**Activity 2: extractFields**
- Input: PDF + `document_type = 'W2'`
- AI Extraction:
  - `employer_name = "Acme Corporation"`
  - `employee_name = "Laylene Jeune"`
  - `ssn = "***-**-6789"` (last 4 only visible)
  - `wages = 85000.00`
  - `federal_tax_withheld = 12000.00`
- Output: Key-value pairs with confidence scores

**Activity 3: mapToSchema**
- Map extracted fields to Supabase schema:
  - `employer_name` → `employments.employer_name`
  - `wages` → `employments.annual_income`
  - `ssn` → `customers.ssn` (verify match)

**Activity 4: createSuggestions**
- INSERT into `document_extractions` table:
  ```sql
  INSERT INTO document_extractions (document_id, field_name, extracted_value, confidence, status)
  VALUES ('doc_789', 'employments.annual_income', '85000.00', 0.98, 'suggested');
  ```

**Activity 5: notifyProcessor**
- Send notification: "New W-2 uploaded for Loan #123456. AI extracted 5 fields (98% confidence). Review now."

**Processor Experience:**
1. Receives notification
2. Opens loan file → Split-pane verifier appears
3. Left pane: W-2 PDF with highlighted fields
4. Right pane: Form fields with AI-extracted values (pre-filled, pending review)
5. Processor clicks **[Accept AI Extraction]** or manually corrects → Saves

**Time Saved:** 10-15 minutes per document (no manual data entry).

### 2.2 Credit Report Auto-Import [file:1]

**Pain Point [file:2]:**
"Credit report PDF appears in E-Folder but liabilities must be manually mapped to the 1003. Scores must be manually verified. No automated liability creation from credit data."

**Workflow Implementation [file:1]:**
```
Workflow: temporal/workflows/credit-report-import.ts
Trigger: creditreports INSERT with status = 'received'

Activities:
1. parseCreditReport - Extract all trade lines, scores, inquiries from credit 
   report data (XML or PDF)
2. createLiabilities - Auto-INSERT liabilities rows from trade lines 
   (creditor, balance, payment, type)
3. updateScores - UPDATE application.customers with bureau scores and 
   creditreports with min/mid
4. flagDerogatory - Create underwriting.conditions for any derogatory items 
   (lates, collections, judgments)
5. generateSummary - Create a human-readable credit summary in notes

Priority: HIGH
```

**Example Workflow Execution:**

**Trigger:** Credit report received from Experian
```
1. creditreports INSERT → loan_id = 123456, status = 'received', 
   file_path = 's3://credit-reports/123456.xml'
2. Temporal workflow starts: creditReportImportWorkflow('credit_789')
```

**Activity 1: parseCreditReport**
- Input: Credit report XML (Experian format)
- Parse: 15 trade lines, 3 bureau scores, 2 inquiries, 1 collection

**Activity 2: createLiabilities**
- Auto-INSERT trade lines as liabilities:
  ```sql
  INSERT INTO liabilities (loan_id, creditor, balance, monthly_payment, type)
  VALUES 
    (123456, 'Chase Credit Card', 5000.00, 150.00, 'Revolving'),
    (123456, 'Wells Fargo Auto Loan', 18000.00, 450.00, 'Installment'),
    ...
  ```

**Activity 3: updateScores**
- UPDATE borrower credit scores:
  ```sql
  UPDATE customers 
  SET experian_score = 740, transunion_score = 735, equifax_score = 738
  WHERE loan_id = 123456 AND customer_type = 'Borrower';
  
  -- Calculate mid-score (middle of 3 scores)
  UPDATE creditreports 
  SET mid_score = 738 
  WHERE loan_id = 123456;
  ```

**Activity 4: flagDerogatory**
- Found: 1 collection account ($250, medical)
- Auto-create condition:
  ```sql
  INSERT INTO underwriting_conditions (loan_id, description, category, status)
  VALUES (123456, 'Provide letter of explanation for $250 medical collection', 
  'Prior-to-Docs', 'Open');
  ```

**Activity 5: generateSummary**
- Generate summary:
  ```
  Credit Summary for Loan #123456:
  - Mid-Score: 738 (Good)
  - Total Trade Lines: 15
  - Total Revolving Debt: $8,500
  - Total Installment Debt: $32,000
  - Derogatory Items: 1 medical collection ($250)
  - Recent Inquiries: 2 (within 6 months)
  - Recommendation: Approved with condition (LOE for collection)
  ```

**Time Saved:** 10-15 minutes per credit report (no manual trade line entry).

### 2.3 Automated Fee Gate Enforcement [file:1]

**Pain Point [file:1]:**
"No enforcement. Processor manually checks whether fee was paid and credit was authorized before ordering credit reports. If they forget, the pull happens anyway."

**Workflow Implementation [file:1]:**
```
Workflow: temporal/workflows/service-order-gate.ts
Trigger: Any service order attempt (credit pull, appraisal, fraud report)

Activities:
1. checkFeePayment - Query feepayments WHERE application_id = ? AND 
   feetype = ? AND status = 'collected'
2. checkAuthorization - Query application.customers.creditauth_signed = true
3. gate - If both pass, proceed. If either fails, return error with specific 
   missing prerequisite.

Priority: HIGH
```

**Example Workflow Execution:**

**Trigger:** Processor clicks **[Order Credit Report]**
```
1. serviceorders INSERT → loan_id = 123456, service_type = 'credit_report'
2. Temporal workflow starts: serviceOrderGateWorkflow('order_123')
```

**Activity 1: checkFeePayment**
```sql
SELECT * FROM feepayments 
WHERE loan_id = 123456 
AND fee_type = 'Credit Report Fee' 
AND status = 'Collected';
```
- **If found:** ✅ Fee paid → Proceed to Activity 2
- **If not found:** ❌ Return error: "Cannot order credit report. Credit report fee not collected."

**Activity 2: checkAuthorization**
```sql
SELECT credit_auth_signed FROM customers 
WHERE loan_id = 123456 AND customer_type = 'Borrower';
```
- **If `true`:** ✅ Authorization signed → Proceed to Activity 3
- **If `false`:** ❌ Return error: "Cannot order credit report. Borrower has not signed credit authorization."

**Activity 3: gate**
- **If both checks pass:** Allow credit report order → Proceed to vendor API call
- **If either check fails:** Block order → Show error message to processor

**Benefit:** Prevents unauthorized credit pulls (FCRA compliance risk).

### 2.4 TRID Timer Automation [file:1]

**Pain Point [file:1]:**
"No automated TRID timer. Processors manually track the 3-business-day waiting periods for Loan Estimate and Closing Disclosure delivery."

**Workflow Implementation [file:1]:**
```
Workflow: temporal/workflows/trid-timer.ts
Triggers:
- applications.initial_disclosures_sent_at UPDATE (LE timer)
- applications.cd_sent_at UPDATE (CD timer)

Activities:
1. calculateEligibleDate - Based on delivery method (eSign=3 biz days, 
   mail=3 biz days + 3 calendar days, in-person=same day)
2. scheduleGate - Block closing/funding actions until eligible date
3. sendReminders - 1-day-before reminder to closer
4. releaseGate - On eligible date, update applications to allow closing/funding

Priority: HIGH CRITICAL (compliance)
```

**Example Workflow Execution:**

**Trigger:** Loan Estimate sent to borrower via eSign
```
1. applications UPDATE → initial_disclosures_sent_at = '2026-02-13 10:00:00'
2. Temporal workflow starts: tridTimerWorkflow('loan_123456', 'LE')
```

**Activity 1: calculateEligibleDate**
- Delivery method: eSign
- Rule: 3 business days after receipt
- Sent: 2026-02-13 (Thursday)
- Receipt: 2026-02-13 (same day—eSign immediate)
- Eligible date: 2026-02-18 (Tuesday—3 biz days: Fri, Mon, Tue)

**Activity 2: scheduleGate**
- UPDATE applications:
  ```sql
  UPDATE applications 
  SET le_eligible_date = '2026-02-18', 
      funding_blocked = true, 
      funding_block_reason = 'LE 3-day waiting period (ends 2026-02-18)'
  WHERE loan_id = 123456;
  ```

**Activity 3: sendReminders**
- Schedule reminder for 2026-02-17 (1 day before eligible):
  ```
  Temporal.schedule('2026-02-17 09:00:00', sendNotification(
    recipient: 'closer@company.com',
    message: 'Loan #123456 - LE waiting period ends tomorrow (2026-02-18). Ready to close.'
  ));
  ```

**Activity 4: releaseGate**
- On 2026-02-18 at 00:01:
  ```sql
  UPDATE applications 
  SET funding_blocked = false, 
      funding_block_reason = NULL 
  WHERE loan_id = 123456;
  ```
- Send notification: "Loan #123456 - LE waiting period complete. Clear to close."

**Benefit:** TRID compliance enforced automatically (no manual tracking).

### 2.5 ECOA Adverse Action Timer [file:1]

**Pain Point [file:1]:**
"No tracking of denial-to-adverse-action timeline. 30-day ECOA requirement is manually managed or missed."

**Workflow Implementation [file:1]:**
```
Workflow: temporal/workflows/adverse-action-timer.ts
Trigger: uwdecisions INSERT WHERE decision = 'denied'

Activities:
1. startTimer - Record denial date, calculate 30-day deadline
2. sendEscalation - At day 20, alert compliance officer if 
   adverse_action_sent_at is NULL
3. sendUrgentAlert - At day 27, urgent escalation
4. generateNotice - Auto-generate adverse action notice letter from denial reason

Priority: HIGH CRITICAL (compliance)
```

**Example Workflow Execution:**

**Trigger:** Underwriter denies loan
```
1. uwdecisions INSERT → loan_id = 123456, decision = 'Denied', 
   denial_reason = 'DTI too high (52%)'
2. Temporal workflow starts: adverseActionTimerWorkflow('loan_123456')
```

**Activity 1: startTimer**
- Denial date: 2026-02-13
- Deadline: 2026-03-15 (30 calendar days)
- UPDATE applications:
  ```sql
  UPDATE applications 
  SET adverse_action_deadline = '2026-03-15', 
      adverse_action_sent_at = NULL 
  WHERE loan_id = 123456;
  ```

**Activity 2: sendEscalation (Day 20)**
- Date: 2026-03-05
- Check: `adverse_action_sent_at IS NULL`?
- **If NULL:** Send alert to compliance officer:
  ```
  Subject: URGENT - Adverse Action Notice Not Sent (Loan #123456)
  Body: Loan #123456 was denied on 2026-02-13. Adverse action notice 
  has not been sent. Deadline: 2026-03-15 (10 days remaining). 
  Please send notice immediately to avoid ECOA violation.
  ```

**Activity 3: sendUrgentAlert (Day 27)**
- Date: 2026-03-12
- Check: `adverse_action_sent_at IS NULL`?
- **If NULL:** Escalate to executive team:
  ```
  Subject: CRITICAL - ECOA Violation Imminent (Loan #123456)
  Body: Loan #123456 denial deadline is in 3 DAYS (2026-03-15). 
  Adverse action notice STILL NOT SENT. Immediate action required.
  ```

**Activity 4: generateNotice**
- Auto-generate adverse action letter from denial reason:
  ```
  Dear [Borrower Name],

  Your mortgage application (#123456) has been denied for the following reason:
  - Debt-to-Income Ratio: 52% exceeds maximum allowable 43%

  This decision was made based on information from:
  - Credit report from Experian
  - Income verification documents

  You have the right to a free copy of your credit report...
  ```
- Store in documents table → Send to borrower

**Benefit:** ECOA compliance enforced (avoid $10K+ fines per violation).

### 2.6 Automated Condition Matching [file:1]

**Pain Point [file:1]:**
"Processor manually checks if uploaded documents satisfy outstanding conditions. No linking between document uploads and open conditions."

**Workflow Implementation [file:1]:**
```
Workflow: temporal/workflows/condition-matcher.ts
Trigger: documents INSERT WHERE upload_source = 'borrower_portal'

Activities:
1. classifyDocument - Identify document type from AI extraction
2. matchConditions - Query underwriting_conditions WHERE loan_id = ? AND 
   status = 'open' and match by keyword/type
3. suggestMatch - Suggest which conditions the document satisfies
4. updateStatus - On processor approval, UPDATE underwriting_conditions.status = 
   'received' and link document_id
5. checkAllClear - If all conditions cleared/waived, fire 'conditions_cleared' event

Priority: MEDIUM
```

**Example Workflow Execution:**

**Trigger:** Borrower uploads document via portal
```
1. documents INSERT → loan_id = 123456, document_type = 'Income', 
   file_name = 'Pay_Stub_Jan2026.pdf', upload_source = 'borrower_portal'
2. Temporal workflow starts: conditionMatcherWorkflow('doc_456')
```

**Activity 1: classifyDocument**
- AI classifies: `document_type = 'Pay Stub'`, `date = '2026-01-31'`

**Activity 2: matchConditions**
- Query open conditions:
  ```sql
  SELECT * FROM underwriting_conditions 
  WHERE loan_id = 123456 
  AND status = 'Open'
  AND (description LIKE '%pay stub%' OR description LIKE '%income%');
  ```
- Found: 1 condition:
  ```
  ID: 789
  Description: "Provide most recent pay stub"
  Category: Prior-to-Docs
  Status: Open
  ```

**Activity 3: suggestMatch**
- Create suggestion:
  ```sql
  INSERT INTO condition_suggestions (condition_id, document_id, confidence)
  VALUES (789, 'doc_456', 0.95);
  ```
- Notify processor: "Borrower uploaded pay stub. Suggests match for condition #789."

**Activity 4: updateStatus (on processor approval)**
- Processor reviews, clicks **[Accept Match]**
- UPDATE condition:
  ```sql
  UPDATE underwriting_conditions 
  SET status = 'Received', 
      satisfied_by_document_id = 'doc_456', 
      satisfied_at = NOW() 
  WHERE id = 789;
  ```

**Activity 5: checkAllClear**
- Query: All conditions cleared/waived?
  ```sql
  SELECT COUNT(*) FROM underwriting_conditions 
  WHERE loan_id = 123456 
  AND status NOT IN ('Cleared', 'Waived');
  ```
- **If 0:** Fire event: `conditions_cleared` → Advance loan to "Clear to Close" stage

**Benefit:** Faster condition resolution (no manual matching by processor).

### 2.7 UW Portal Submission Automation [file:1]

**See Section 3.2: UW Submission for full 14-step manual workflow details [file:6].**

**Workflow Implementation [file:1]:**
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

**Replaces:** 14-step manual export-upload process [file:2][file:6].

### 2.8 Smart Notification Router [file:1]

**Pain Point [file:1]:**
"Two separate notification systems: 'Send Message' window and 'Notify via Email' window. 6 clicks and two modal windows to notify one person. Emails composed in external Gmail."

**Workflow Implementation [file:1]:**
```
Workflow: temporal/workflows/notification-router.ts
Trigger: Any application event (status change, document upload, condition update, etc.)

Activities:
1. determineRecipients - Based on event type, identify who needs to know 
   (borrower, MLO, processor, UW, closer)
2. selectChannels - Based on user preferences (notification_preferences table), 
   choose email/SMS/in-app
3. renderTemplate - Generate message from event data + template
4. dispatch - Send via configured channel (Resend for email, Twilio for SMS, 
   Supabase Realtime for in-app)
5. logCommunication - INSERT into communications for audit trail

Priority: MEDIUM
```

**Example:** Borrower uploads document → Processor receives in-app notification + email (based on preferences).

## Section 3: Workflow Orchestration Benefits

### Durable Execution

**Problem:** Manual tasks forgotten or skipped.
**Solution:** Temporal workflows never forget. If server crashes mid-workflow, Temporal resumes from last completed activity.

### Automatic Retry

**Problem:** API call to Evolve portal fails (network timeout).
**Solution:** Temporal automatically retries failed activities with exponential backoff (1s, 2s, 4s, 8s, ...).

### Audit Trail

**Problem:** No visibility into who did what when.
**Solution:** Temporal logs every workflow execution and activity result (full audit trail for compliance).

### Event-Driven

**Problem:** Processor must manually check for new documents, conditions, status changes.
**Solution:** Workflows trigger automatically on database events (INSERT, UPDATE) or time-based schedules.

## Common Pain Points (Solved by Automation)

### 1. Zero Document Parsing [file:1][file:2]

**Manual:** Processor opens PDF, reads values, types into form fields (10-15 min/document)
**Automated:** AI extraction workflow auto-populates fields, processor reviews (2-3 min/document)
**Time Saved:** 7-12 minutes per document × 10 documents = 70-120 minutes per loan

### 2. Manual Credit Report Entry [file:1][file:2]

**Manual:** Processor reads credit report PDF, types 15 trade lines into Liabilities section (10-15 min)
**Automated:** Credit import workflow auto-creates liabilities, processor reviews (2-3 min)
**Time Saved:** 7-12 minutes per loan

### 3. No Fee Gate Enforcement [file:1]

**Manual:** Processor forgets to check if fee paid → credit pulled anyway → compliance issue
**Automated:** Fee gate workflow blocks credit pull until fee collected
**Compliance Risk:** Eliminated

### 4. Manual TRID Tracking [file:1]

**Manual:** Processor tracks 3-day waiting period in spreadsheet or memory → human error risk
**Automated:** TRID timer workflow enforces waiting period automatically
**Compliance Risk:** Eliminated

### 5. Manual ECOA Deadline Tracking [file:1]

**Manual:** Compliance officer tracks 30-day adverse action deadline manually → missed deadlines = $10K+ fines
**Automated:** ECOA timer workflow escalates at day 20 and day 27 → deadline never missed
**Compliance Risk:** Eliminated

## Technical Architecture

### Temporal Server

**Deployment:**
- Self-hosted Temporal server (Docker container)
- Or: Temporal Cloud (managed service)

**Connection:**
- Next.js app connects to Temporal server via gRPC
- Workflows written in TypeScript (same language as app)

### Workflow Triggers

**Database Triggers (Supabase):**
```sql
-- Trigger document extraction workflow on document upload
CREATE TRIGGER trigger_document_extraction
AFTER INSERT ON documents
FOR EACH ROW
EXECUTE FUNCTION call_temporal_workflow('document-extraction', NEW.id);
```

**Event Listeners (Supabase Realtime):**
```typescript
// Listen for document uploads
supabase
  .channel('documents')
  .on('postgres_changes', 
    { event: 'INSERT', schema: 'public', table: 'documents' },
    (payload) => {
      temporalClient.startWorkflow('documentExtractionWorkflow', {
        workflowId: `doc-extraction-${payload.new.id}`,
        args: [payload.new.id]
      });
    }
  )
  .subscribe();
```

## Related Documentation

- **Processing Workflows 3.1:** Processing Workbook (automated checklist completion)
- **Processing Workflows 3.2:** UW Submission (14-step manual → 1-click automated)
- **Document Management 2.2:** Document Upload (AI extraction workflow triggered)
- **Underwriting 4.2:** Conditions Management (automated condition matching)