# Notification Preferences Table

**Category**: Sales & Lead Management (Phase 5B)
**Table**: `notification_preferences`
**Purpose**: Per-user notification settings for email and in-app notifications
**Last Updated**: 2026-02-12

---

## Overview

The `notification_preferences` table stores notification settings for each user (loan officers, processors, underwriters, admins). Users can configure which notifications they receive via email and which appear in-app.

---

## Columns

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | uuid | NO | `gen_random_uuid()` | Primary key |
| `user_id` | uuid | NO | - | FK to `users` (UNIQUE) |
| `preferences` | jsonb | NO | `{}` | Notification preferences by type |
| `updated_at` | timestamp | NO | `now()` | Last update timestamp |

---

## Constraints

- **PK**: `id`
- **FK**: `user_id` → `users(id)` (UNIQUE — one record per user)

---

## JSONB Structure

The `preferences` column is a JSONB object where each key is a notification type and each value has `email` and `inApp` boolean flags:

```json
{
  "lead_assigned": {
    "email": true,
    "inApp": true
  },
  "lead_status_changed": {
    "email": false,
    "inApp": true
  },
  "application_submitted": {
    "email": true,
    "inApp": true
  },
  "document_uploaded": {
    "email": true,
    "inApp": true
  },
  "task_assigned": {
    "email": true,
    "inApp": true
  },
  "task_due_soon": {
    "email": true,
    "inApp": false
  },
  "condition_added": {
    "email": true,
    "inApp": true
  },
  "underwriting_decision": {
    "email": true,
    "inApp": true
  }
}
```

---

## Notification Types

Common notification types include:
- `lead_assigned` — New lead assigned to user
- `lead_status_changed` — Lead status changed on user's lead
- `application_submitted` — New application submitted
- `application_status_changed` — Application status changed
- `document_uploaded` — New document uploaded
- `document_reviewed` — Document reviewed
- `task_assigned` — Task assigned to user
- `task_due_soon` — Task due within 24 hours
- `task_overdue` — Task is overdue
- `condition_added` — Condition added to application
- `condition_cleared` — Condition cleared
- `underwriting_decision` — Underwriting decision made
- `message_received` — New message/communication received

---

## RLS Policies

**Status**: ⚠️ **Not yet configured**

---

## Business Logic

### Default Preferences
When a user is created, default preferences are set with all notifications enabled for both email and in-app.

### Preference Updates
Users can update their preferences via settings UI. Updates are merged into existing preferences (not replaced entirely).

### Notification Delivery
When a notification is triggered:
1. Check `notification_preferences` for the user
2. If `email: true`, send email notification
3. If `inApp: true`, create in-app notification (future: notifications table)

---

## Usage Patterns

### Create default preferences for new user
```sql
INSERT INTO notification_preferences (user_id, preferences)
VALUES (
  'user-uuid',
  jsonb_build_object(
    'lead_assigned', jsonb_build_object('email', true, 'inApp', true),
    'task_assigned', jsonb_build_object('email', true, 'inApp', true),
    'application_submitted', jsonb_build_object('email', true, 'inApp', true)
  )
)
ON CONFLICT (user_id) DO NOTHING;
```

### Update specific preference
```sql
UPDATE notification_preferences
SET
  preferences = jsonb_set(
    preferences,
    '{lead_assigned,email}',
    'false'::jsonb
  ),
  updated_at = now()
WHERE user_id = auth.uid();
```

### Get user's preferences
```sql
SELECT preferences
FROM notification_preferences
WHERE user_id = auth.uid();
```

### Check if user wants email for specific notification
```sql
SELECT
  COALESCE(
    (preferences->'lead_assigned'->>'email')::boolean,
    true  -- Default to true if not set
  ) as send_email
FROM notification_preferences
WHERE user_id = 'user-uuid';
```

---

## Common Queries

### Users who want email for lead assignments
```sql
SELECT u.*
FROM users u
LEFT JOIN notification_preferences np ON u.id = np.user_id
WHERE u.organization_id = 'org-uuid'
  AND u.role = 'loan_officer'
  AND COALESCE(
    (np.preferences->'lead_assigned'->>'email')::boolean,
    true
  ) = true;
```

### Notification settings report
```sql
SELECT
  u.first_name || ' ' || u.last_name as user_name,
  u.email,
  COALESCE(
    jsonb_object_keys(np.preferences)::text,
    'No preferences set'
  ) as notification_types
FROM users u
LEFT JOIN notification_preferences np ON u.id = np.user_id
WHERE u.organization_id = 'org-uuid'
ORDER BY u.last_name, u.first_name;
```

---

## Integration Notes

### Server Actions
- `updateNotificationPreferences()` — Update user's preferences
- `getNotificationPreferences()` — Get user's current preferences

### Future Enhancements
- Add `in_app_notifications` table to store notification history
- Add notification digest settings (daily/weekly summary emails)
- Add quiet hours (don't send notifications during certain times)

---

*Part of Phase 5B LO Portal release. RLS policies pending implementation.*
