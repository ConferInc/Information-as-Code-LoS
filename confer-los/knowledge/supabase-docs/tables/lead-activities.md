# Lead Activities Table

**Category**: Sales & Lead Management (Phase 5B)
**Table**: `lead_activities`
**Purpose**: Complete audit trail of lead interactions and status changes
**Last Updated**: 2026-02-12

---

## Overview

The `lead_activities` table logs all interactions and changes related to leads. This provides a complete audit trail for compliance, analytics, and lead nurturing. Every significant action (status change, assignment, communication, quote generation, etc.) creates an activity record.

---

## Columns

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | uuid | NO | `gen_random_uuid()` | Primary key |
| `organization_id` | uuid | NO | - | FK to `organizations` |
| `lead_id` | uuid | NO | - | FK to `leads` (CASCADE DELETE) |
| `activity_type` | text | NO | - | Type of activity (see values below) |
| `description` | text | YES | NULL | Human-readable description |
| `from_status` | text | YES | NULL | Previous status (for status_changed) |
| `to_status` | text | YES | NULL | New status (for status_changed) |
| `metadata` | jsonb | YES | NULL | Activity-specific details |
| `created_by` | uuid | YES | NULL | FK to `users` who triggered activity |
| `created_at` | timestamp | NO | `now()` | Activity timestamp |

---

## Constraints

- **PK**: `id`
- **FK**: `organization_id` → `organizations(id)`
- **FK**: `lead_id` → `leads(id)` ON DELETE CASCADE
- **FK**: `created_by` → `users(id)`

---

## Indexes

| Index Name | Columns | Purpose |
|------------|---------|---------|
| `lead_activities_lead_time_idx` | `lead_id, created_at` | Timeline for a specific lead |

---

## Activity Types

| Type | Description | Metadata Example |
|------|-------------|------------------|
| `created` | Lead was created | `{"source": "web_form"}` |
| `status_changed` | Status changed | Uses `from_status`, `to_status` |
| `assigned` | Lead assigned to LO | `{"assigned_to_id": "uuid", "assigned_to_name": "John Doe"}` |
| `reassigned` | Lead reassigned to different LO | `{"from_user": "uuid", "to_user": "uuid"}` |
| `note_added` | Note added to lead | `{"note_content": "..."}` |
| `call_logged` | Phone call logged | `{"duration_seconds": 180, "outcome": "qualified"}` |
| `email_sent` | Email sent to lead | `{"subject": "...", "template_id": "uuid"}` |
| `email_received` | Email received from lead | `{"subject": "..."}` |
| `sms_sent` | SMS sent to lead | `{"message": "..."}` |
| `quote_generated` | Quick quote created | `{"quote_id": "uuid", "loan_amount": 350000}` |
| `prequal_letter_sent` | Pre-qualification letter sent | `{"quote_id": "uuid"}` |
| `converted_to_application` | Lead converted to application | `{"application_id": "uuid", "customer_id": "uuid"}` |
| `imported` | Lead imported from external source | `{"import_batch_id": "uuid", "external_id": "123"}` |
| `score_updated` | Lead score changed | `{"old_score": 45, "new_score": 72, "reason": "complete_profile"}` |
| `follow_up_scheduled` | Follow-up scheduled | `{"scheduled_for": "2026-02-15T10:00:00Z"}` |

---

## RLS Policies

**Status**: ⚠️ **Not yet configured**

RLS policies for the `lead_activities` table have not been implemented in Phase 5B. Access control is currently handled at the application level.

**Planned policies**:
1. `system_admin_all` — System admins can access all activities
2. `staff_view` — Staff can view activities in their organization
3. `staff_insert` — Staff can create activities in their organization
4. **No UPDATE or DELETE** — Activities are immutable for audit integrity

---

## Business Logic

### Immutability
- Lead activities are **append-only** (no updates or deletes)
- Provides tamper-proof audit trail
- Only system admins can delete activities (via direct DB access)

### Automatic Activity Creation
Activities are automatically created by:
- Lead status changes
- Lead assignment/reassignment
- Communication sending (email, SMS)
- Quote generation
- Conversion to application

### Manual Activity Logging
Loan officers can manually log:
- Phone calls
- In-person meetings
- Notes
- Follow-up actions

---

## Relationships

### Parent Tables
- `organizations` (1:M) — Each activity belongs to one organization
- `leads` (1:M) — Each activity is for one lead (CASCADE DELETE)
- `users` (created_by) — Who triggered the activity

---

## Usage Patterns

### Log status change
```sql
INSERT INTO lead_activities (
  organization_id, lead_id,
  activity_type, description,
  from_status, to_status,
  created_by
) VALUES (
  'org-uuid', 'lead-uuid',
  'status_changed',
  'Lead qualified after initial phone call',
  'contacted', 'qualified',
  auth.uid()
);
```

### Log phone call
```sql
INSERT INTO lead_activities (
  organization_id, lead_id,
  activity_type, description,
  metadata, created_by
) VALUES (
  'org-uuid', 'lead-uuid',
  'call_logged',
  'Initial qualification call',
  jsonb_build_object(
    'duration_seconds', 300,
    'outcome', 'interested',
    'notes', 'Wants to refinance, current rate 7.5%'
  ),
  auth.uid()
);
```

### Log email sent
```sql
INSERT INTO lead_activities (
  organization_id, lead_id,
  activity_type, description,
  metadata, created_by
) VALUES (
  'org-uuid', 'lead-uuid',
  'email_sent',
  'Welcome email sent',
  jsonb_build_object(
    'template_id', 'template-uuid',
    'subject', 'Welcome to Our Mortgage Team',
    'communication_id', 'comm-uuid'
  ),
  auth.uid()
);
```

### Log quote generation
```sql
INSERT INTO lead_activities (
  organization_id, lead_id,
  activity_type, description,
  metadata, created_by
) VALUES (
  'org-uuid', 'lead-uuid',
  'quote_generated',
  'Quick quote generated: $350,000 purchase',
  jsonb_build_object(
    'quote_id', 'quote-uuid',
    'loan_amount', 350000,
    'monthly_payment', 2145.50
  ),
  auth.uid()
);
```

### Log conversion to application
```sql
INSERT INTO lead_activities (
  organization_id, lead_id,
  activity_type, description,
  metadata, created_by
) VALUES (
  'org-uuid', 'lead-uuid',
  'converted_to_application',
  'Lead converted to application #APP-20260212-0042',
  jsonb_build_object(
    'application_id', 'app-uuid',
    'application_number', 'APP-20260212-0042',
    'customer_id', 'customer-uuid'
  ),
  auth.uid()
);
```

---

## Common Queries

### Get activity timeline for a lead
```sql
SELECT
  la.*,
  u.first_name || ' ' || u.last_name as created_by_name
FROM lead_activities la
LEFT JOIN users u ON la.created_by = u.id
WHERE la.lead_id = 'lead-uuid'
ORDER BY la.created_at DESC;
```

### Get recent activities across all leads (dashboard)
```sql
SELECT
  la.*,
  l.first_name || ' ' || l.last_name as lead_name,
  u.first_name || ' ' || u.last_name as user_name
FROM lead_activities la
JOIN leads l ON la.lead_id = l.id
LEFT JOIN users u ON la.created_by = u.id
WHERE la.organization_id = 'org-uuid'
  AND la.created_at >= now() - interval '7 days'
ORDER BY la.created_at DESC
LIMIT 50;
```

### Count activities by type (analytics)
```sql
SELECT
  activity_type,
  COUNT(*) as count,
  MIN(created_at) as first_activity,
  MAX(created_at) as last_activity
FROM lead_activities
WHERE organization_id = 'org-uuid'
  AND created_at >= date_trunc('month', now())
GROUP BY activity_type
ORDER BY count DESC;
```

### Get leads with no recent activity
```sql
SELECT
  l.*,
  MAX(la.created_at) as last_activity_at
FROM leads l
LEFT JOIN lead_activities la ON l.id = la.lead_id
WHERE l.organization_id = 'org-uuid'
  AND l.status NOT IN ('converted', 'lost', 'disqualified')
GROUP BY l.id
HAVING MAX(la.created_at) < now() - interval '7 days'
   OR MAX(la.created_at) IS NULL
ORDER BY MAX(la.created_at) NULLS FIRST;
```

### Activity report by loan officer
```sql
SELECT
  u.first_name || ' ' || u.last_name as loan_officer,
  COUNT(DISTINCT la.lead_id) as leads_touched,
  COUNT(*) as total_activities,
  COUNT(*) FILTER (WHERE la.activity_type = 'call_logged') as calls_made,
  COUNT(*) FILTER (WHERE la.activity_type = 'email_sent') as emails_sent,
  COUNT(*) FILTER (WHERE la.activity_type = 'quote_generated') as quotes_generated,
  COUNT(*) FILTER (WHERE la.activity_type = 'converted_to_application') as conversions
FROM lead_activities la
JOIN users u ON la.created_by = u.id
WHERE la.organization_id = 'org-uuid'
  AND la.created_at >= date_trunc('month', now())
GROUP BY u.id, u.first_name, u.last_name
ORDER BY conversions DESC, total_activities DESC;
```

---

## Integration Notes

### Automated Activity Logging
The following actions automatically create lead activities:
- **Lead creation** → `created`
- **Status change** → `status_changed` (via trigger or application logic)
- **Assignment** → `assigned` or `reassigned`
- **Communication sent** → `email_sent`, `sms_sent` (via communication service)
- **Quote created** → `quote_generated` (via quick quote action)
- **Conversion** → `converted_to_application` (via conversion logic)

### Manual Activity Logging
Loan officers can manually create activities for:
- Phone calls
- In-person meetings
- Notes/comments
- Follow-up scheduling

### Server Actions
Located in `app/actions/org/`:
- `logLeadActivity()` — Create activity record
- `getLeadTimeline()` — Fetch activities for lead

---

## Performance Considerations

- **Index**: `lead_activities_lead_time_idx` optimizes timeline queries
- **Cascade Delete**: Deleting a lead automatically deletes all activities
- **Append-Only**: No updates/deletes = faster inserts, simpler queries
- **Partitioning**: For high-volume orgs, consider partitioning by `created_at` (monthly)

---

## Related Tables

- See [leads.md](./leads.md) for lead management
- See [communications.md](../communications.md) for communication tracking
- See [quick-quotes.md](./quick-quotes.md) for quote generation

---

*Part of Phase 5B LO Portal release. RLS policies pending implementation.*
