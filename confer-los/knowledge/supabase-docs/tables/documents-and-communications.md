# Documents & Communications Tables

**Category**: Document Management & Communication
**Tables**: `documents`, `communications`

---

## Table: `documents`

**Purpose**: Document metadata and review workflow. Actual files stored in Supabase Storage buckets.

### Core Columns
- `application_id` FK, `customer_id` FK (optional - if doc is customer-specific)
- `uploaded_by` FK → users (who uploaded)
- `reviewed_by` FK → users (who reviewed)
- `document_type`: pay_stub, w2, tax_return, bank_statement, credit_report, appraisal, purchase_agreement, drivers_license, etc.
- `file_name`, `file_path` (Supabase Storage path)
- `file_size` (bytes), `mime_type` (application/pdf, image/jpeg, etc.)

### Review Workflow
- `status`: pending, approved, rejected
- `reviewed_at`: timestamp when review completed
- `rejection_reason`: text (if rejected, why?)

### Document Dating
- `period_start`, `period_end`: date range for dated documents (e.g., pay stub for 1/1-1/15)
- `year`: integer (for annual documents like W-2, tax returns)

### Storage Integration

**File Path Format**: `{bucket}/{organization_id}/{application_id}/{document_id}/{filename}`

Example: `documents/org-abc123/app-xyz789/doc-uuid/paystub.pdf`

**Upload Flow**:
1. Frontend uploads to Supabase Storage (get file path)
2. Create `documents` record with metadata
3. Storage RLS policies restrict access by organization/application

### Common Document Types

| Type | Description | Typical Period | Review Notes |
|------|-------------|----------------|--------------|
| `pay_stub` | Recent pay stub | Last 30 days | Verify YTD income, employer name |
| `w2` | W-2 form | Previous 2 years | Verify income consistency |
| `tax_return` | 1040 + schedules | Previous 2 years | For self-employed: Schedule C |
| `bank_statement` | Bank/investment statement | Last 2 months | Verify assets, large deposits |
| `credit_report` | Credit bureau report | < 120 days old | Auto-approved, not borrower-uploaded |
| `appraisal` | Property appraisal | < 120 days old | Verify property value |
| `purchase_agreement` | Sales contract | N/A | Verify purchase price, seller info |
| `drivers_license` | ID verification | Current | Verify identity, DOB |
| `gift_letter` | Gift funds letter | N/A | Signed by donor, no repayment required |
| `voe` | Verification of Employment | < 30 days old | Direct from employer |
| `vod` | Verification of Deposit | < 30 days old | Direct from bank |

### Document Review Logic
```sql
-- Get pending documents for review
SELECT
  d.*,
  c.first_name || ' ' || c.last_name as customer_name,
  a.application_number
FROM documents d
JOIN applications a ON d.application_id = a.id
LEFT JOIN customers c ON d.customer_id = c.id
WHERE d.status = 'pending'
  AND a.organization_id = auth.current_user_organization_id()
ORDER BY d.created_at ASC;
```

### Approve document
```sql
UPDATE documents
SET
  status = 'approved',
  reviewed_by = auth.uid(),
  reviewed_at = now()
WHERE id = 'doc-uuid';
```

### Reject document
```sql
UPDATE documents
SET
  status = 'rejected',
  reviewed_by = auth.uid(),
  reviewed_at = now(),
  rejection_reason = 'Document is expired. Please upload a statement from the last 60 days.'
WHERE id = 'doc-uuid';
```

### Document Checklist Progress
```sql
SELECT
  document_type,
  COUNT(*) as total,
  SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved,
  SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected,
  SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending
FROM documents
WHERE application_id = 'app-uuid'
GROUP BY document_type;
```

---

## Table: `communications`

**Purpose**: Log of all communications with borrowers (email, SMS, phone calls, portal messages).

### Core Columns
- `application_id` FK, `customer_id` FK (optional)
- `initiated_by` FK → users (who sent it, NULL for inbound)
- `communication_type`: email, sms, phone_call, portal_message, letter
- `direction`: inbound, outbound
- `channel`: email, sms, phone, portal, mail

### Message Content
- `subject`: text (for emails)
- `content`: text (message body or call notes)
- `external_id`: text (e.g., SendGrid message ID, Twilio SID)
- `metadata` (jsonb): Additional data like attachments, delivery status, call duration

### Metadata Examples

**Email Metadata**:
```json
{
  "to": "borrower@example.com",
  "from": "loanofficer@lender.com",
  "attachments": ["disclosure.pdf", "fee_worksheet.xlsx"],
  "delivered_at": "2026-02-10T14:30:00Z",
  "opened_at": "2026-02-10T15:12:00Z",
  "clicked_links": ["https://portal.lender.com/upload-docs"]
}
```

**Phone Call Metadata**:
```json
{
  "phone_number": "+15551234567",
  "duration_seconds": 420,
  "recording_url": "https://...",
  "call_sid": "CAxxxxx"
}
```

**SMS Metadata**:
```json
{
  "to": "+15551234567",
  "from": "+15559876543",
  "delivered": true,
  "delivered_at": "2026-02-10T09:05:23Z"
}
```

### Common Patterns

**Log outbound email**:
```sql
INSERT INTO communications (
  organization_id, application_id, customer_id, initiated_by,
  communication_type, direction, channel,
  subject, content, external_id, metadata
) VALUES (
  'org-uuid', 'app-uuid', 'cust-uuid', auth.uid(),
  'email', 'outbound', 'email',
  'Action Required: Upload Pay Stubs',
  'Hi John, We need your recent pay stubs to continue processing...',
  'sendgrid-msg-123',
  '{"to": "john@example.com", "attachments": []}'::jsonb
);
```

**Log inbound phone call**:
```sql
INSERT INTO communications (
  organization_id, application_id, customer_id, initiated_by,
  communication_type, direction, channel,
  content, metadata
) VALUES (
  'org-uuid', 'app-uuid', 'cust-uuid', NULL,
  'phone_call', 'inbound', 'phone',
  'Borrower called to ask about appraisal timeline. Explained we are waiting for appraiser to schedule.',
  '{"phone_number": "+15551234567", "duration_seconds": 180}'::jsonb
);
```

**Get communication history**:
```sql
SELECT
  c.*,
  u.first_name || ' ' || u.last_name as initiated_by_name,
  cust.first_name || ' ' || cust.last_name as customer_name
FROM communications c
LEFT JOIN users u ON c.initiated_by = u.id
LEFT JOIN customers cust ON c.customer_id = cust.id
WHERE c.application_id = 'app-uuid'
ORDER BY c.created_at DESC;
```

### Compliance & Auditing
- **Retention**: Communications must be retained per lending regulations (typically 3-7 years)
- **Consent**: SMS requires opt-in consent, tracked in customer record
- **TCPA Compliance**: Phone calls during allowed hours only
- **Disclosure Delivery**: Track when disclosures were sent and opened

---

## Integration Points

### Supabase Storage (Documents)
- **Buckets**: `documents` (internal), `borrower-documents` (borrower-uploaded)
- **RLS**: Borrowers can only access own application documents
- **Policies**: Authenticated users can upload/download based on organization

### Email Service (Communications)
- **SendGrid / AWS SES**: External ID stored in `external_id`
- **Webhooks**: Update `metadata` with delivery/open/click events
- **Templates**: Reference template ID in `metadata`

### SMS Service (Communications)
- **Twilio**: SID stored in `external_id`
- **Webhooks**: Update delivery status in `metadata`

---

## Common Queries

### Missing documents
```sql
-- Applications without required document types
WITH required_docs AS (
  SELECT unnest(ARRAY['pay_stub', 'w2', 'bank_statement', 'drivers_license']) as doc_type
),
submitted_docs AS (
  SELECT DISTINCT document_type FROM documents
  WHERE application_id = 'app-uuid' AND status != 'rejected'
)
SELECT rd.doc_type as missing_document
FROM required_docs rd
LEFT JOIN submitted_docs sd ON rd.doc_type = sd.document_type
WHERE sd.document_type IS NULL;
```

### Last contact with borrower
```sql
SELECT
  communication_type,
  direction,
  subject,
  created_at
FROM communications
WHERE customer_id = 'cust-uuid'
ORDER BY created_at DESC
LIMIT 1;
```

---

*See also: [workflow-management.md](./workflow-management.md) for tasks related to document review*
