# Communication Templates Table

**Category**: Sales & Lead Management (Phase 5B)
**Table**: `communication_templates`
**Purpose**: Reusable email/SMS templates per organization with merge field support
**Last Updated**: 2026-02-12

---

## Overview

The `communication_templates` table stores reusable email and SMS templates for each organization. Templates support merge fields (placeholders like `{{first_name}}`) for personalization. Templates are referenced by the `communications` table via `template_id`.

---

## Columns

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | uuid | NO | `gen_random_uuid()` | Primary key |
| `organization_id` | uuid | NO | - | FK to `organizations` |
| `name` | text | NO | - | Template name (e.g., "Welcome Email") |
| `category` | text | NO | - | Template category (see values below) |
| `subject` | text | YES | NULL | Email subject line (NULL for SMS) |
| `body` | text | NO | - | Template body with merge fields |
| `merge_fields` | jsonb | YES | NULL | Array of available merge fields |
| `is_active` | boolean | NO | `true` | Is template currently in use? |
| `created_by` | uuid | YES | NULL | FK to `users` who created template |
| `created_at` | timestamp | NO | `now()` | Creation timestamp |
| `updated_at` | timestamp | NO | `now()` | Last update timestamp |

---

## Constraints

- **PK**: `id`
- **FK**: `organization_id` → `organizations(id)`
- **FK**: `created_by` → `users(id)`

---

## Category Values

| Value | Description |
|-------|-------------|
| `welcome` | Welcome/introduction emails |
| `document_request` | Document request notifications |
| `status_update` | Application status updates |
| `follow_up` | Follow-up emails/SMS |
| `closing` | Closing-related communications |
| `general` | General purpose |

---

## Merge Fields

Templates support merge fields that are replaced with actual values when sending:

**Common merge fields**:
- `{{first_name}}` — Borrower's first name
- `{{last_name}}` — Borrower's last name
- `{{email}}` — Borrower's email
- `{{phone}}` — Borrower's phone
- `{{loan_officer_name}}` — Assigned loan officer's name
- `{{loan_officer_email}}` — Loan officer's email
- `{{loan_officer_phone}}` — Loan officer's phone
- `{{application_number}}` — Application number
- `{{loan_amount}}` — Loan amount (formatted)
- `{{property_address}}` — Property address
- `{{application_status}}` — Current application status
- `{{organization_name}}` — Organization name
- `{{current_date}}` — Current date

The `merge_fields` column stores an array of available merge fields for the template:

```json
["first_name", "last_name", "loan_officer_name", "application_number"]
```

---

## RLS Policies

**Status**: ⚠️ **Not yet configured**

---

## Usage Patterns

### Create template
```sql
INSERT INTO communication_templates (
  organization_id, name, category,
  subject, body, merge_fields,
  created_by
) VALUES (
  'org-uuid',
  'Welcome Email - New Lead',
  'welcome',
  'Welcome {{first_name}} - Let''s Get Started!',
  'Hi {{first_name}},

Thank you for your interest in financing with {{organization_name}}! I''m {{loan_officer_name}}, and I''ll be your dedicated loan officer.

I''d love to schedule a quick call to discuss your goals and answer any questions. You can reach me at {{loan_officer_phone}} or {{loan_officer_email}}.

Looking forward to working with you!

Best regards,
{{loan_officer_name}}
{{organization_name}}',
  ARRAY['first_name', 'organization_name', 'loan_officer_name', 'loan_officer_phone', 'loan_officer_email']::jsonb,
  auth.uid()
);
```

### Send communication using template
```sql
-- 1. Fetch template and merge data
SELECT
  subject,
  body,
  merge_fields
FROM communication_templates
WHERE id = 'template-uuid';

-- 2. Replace merge fields in application code
-- body = body.replace('{{first_name}}', 'John')
--            .replace('{{loan_officer_name}}', 'Jane Doe')
--            ...

-- 3. Create communication record
INSERT INTO communications (
  organization_id, lead_id, initiated_by,
  communication_type, direction, channel,
  subject, content, template_id
) VALUES (
  'org-uuid', 'lead-uuid', auth.uid(),
  'email', 'outbound', 'email',
  'Welcome John - Let''s Get Started!',  -- Merged subject
  'Hi John, ...',  -- Merged body
  'template-uuid'
);
```

### Get templates by category
```sql
SELECT *
FROM communication_templates
WHERE organization_id = 'org-uuid'
  AND category = 'welcome'
  AND is_active = true
ORDER BY name;
```

---

## Common Queries

### Most used templates
```sql
SELECT
  ct.name,
  ct.category,
  COUNT(c.id) as usage_count,
  MAX(c.created_at) as last_used_at
FROM communication_templates ct
LEFT JOIN communications c ON ct.id = c.template_id
WHERE ct.organization_id = 'org-uuid'
GROUP BY ct.id, ct.name, ct.category
ORDER BY usage_count DESC;
```

### Templates by creator
```sql
SELECT
  ct.*,
  u.first_name || ' ' || u.last_name as created_by_name
FROM communication_templates ct
LEFT JOIN users u ON ct.created_by = u.id
WHERE ct.organization_id = 'org-uuid'
ORDER BY ct.created_at DESC;
```

---

## Business Logic

### Template Rendering
1. Fetch template by ID
2. Get merge field values from context (lead, application, user, etc.)
3. Replace all `{{field_name}}` placeholders with actual values
4. Send rendered content via email/SMS

### Template Versioning (Future)
- Currently templates are editable in place
- Future: Track template versions for audit trail
- Create new version when editing, keep old communications linked to original version

### Validation
- Validate that all merge fields used in body are listed in `merge_fields` array
- Validate merge field syntax (no typos like `{first_name}` or `{{{first_name}}}`)

---

## Integration Notes

### Server Actions
- `createTemplate()` — Create new template
- `updateTemplate()` — Update existing template
- `renderTemplate()` — Render template with merge fields
- `sendTemplatedEmail()` — Send email using template

### Related Tables
- `communications` — Communications sent using templates (via `template_id`)
- See [documents-and-communications.md](./documents-and-communications.md)

---

## Example Templates

### Welcome Email (Lead)
**Category**: `welcome`
**Subject**: `Welcome {{first_name}} - Let's Get Started!`
**Body**:
```
Hi {{first_name}},

Thank you for your interest in {{organization_name}}! I'm {{loan_officer_name}}, and I'll be assisting you with your {{loan_purpose}} loan.

Based on the information you provided:
- Estimated loan amount: {{loan_amount}}
- Property type: {{property_type}}

I'd love to schedule a call to discuss your goals. Please reply to this email or call me at {{loan_officer_phone}}.

Best regards,
{{loan_officer_name}}
```

### Document Request
**Category**: `document_request`
**Subject**: `Documents Needed - Application #{{application_number}}`
**Body**:
```
Hi {{first_name}},

To move forward with your application (#{{application_number}}), we need the following documents:

- Recent pay stubs (last 2 months)
- W-2 forms (last 2 years)
- Bank statements (last 2 months)

You can upload these securely through your borrower portal: {{portal_url}}

Please let me know if you have any questions.

Thanks,
{{loan_officer_name}}
```

---

*Part of Phase 5B LO Portal release. RLS policies pending implementation.*
