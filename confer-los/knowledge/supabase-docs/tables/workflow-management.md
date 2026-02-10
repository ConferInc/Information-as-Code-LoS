# Workflow Management Tables

**Category**: Workflow & Collaboration
**Tables**: `tasks`, `notes`, `application_events` (covered in loan-applications.md)

---

## Table: `tasks`

**Purpose**: Task management for application workflow. Tracks action items, follow-ups, and conditions.

### Core Columns
- `application_id` FK, `customer_id` FK (optional - if task relates to specific borrower)
- `assignee_id` FK → users (who should complete the task)
- `created_by` FK → users (who created the task)
- `title`: text (short description)
- `description`: text (detailed instructions)
- `status`: open, in_progress, completed, cancelled
- `priority`: low, medium, high, urgent
- `due_date`: date (when task should be completed)
- `completed_at`: timestamp (when marked complete)

### Common Task Types

| Task | Typical Assignee | Priority | Due Date Logic |
|------|------------------|----------|----------------|
| Review pay stubs | Processor | Medium | +2 business days |
| Order appraisal | Loan Officer | High | +1 business day |
| Clear credit alert | Underwriter | High | +3 business days |
| Request updated bank statement | Processor | Medium | +5 business days |
| Schedule closing | Closer | High | Clear to close date |
| Send pre-approval letter | Loan Officer | High | +1 business day |

### Task Creation Examples

**Auto-generated task** (when application submitted):
```sql
INSERT INTO tasks (
  organization_id, application_id, assignee_id, created_by,
  title, description, status, priority, due_date
) VALUES (
  'org-uuid', 'app-uuid',
  (SELECT id FROM users WHERE role = 'processor' LIMIT 1), -- Auto-assign to processor
  auth.uid(),
  'Review submitted application',
  'Verify all required documents are uploaded and complete. Check for missing information.',
  'open', 'medium',
  CURRENT_DATE + 2 -- Due in 2 days
);
```

**Underwriting condition task**:
```sql
INSERT INTO tasks (
  organization_id, application_id, customer_id, assignee_id, created_by,
  title, description, status, priority, due_date
) VALUES (
  'org-uuid', 'app-uuid', 'cust-uuid',
  (SELECT id FROM users WHERE email = 'processor@lender.com'),
  auth.uid(),
  'Obtain LOE for gap in employment',
  'Borrower has a 3-month gap in employment from Jun-Aug 2024. Request Letter of Explanation documenting what they were doing during this period.',
  'open', 'high',
  CURRENT_DATE + 3
);
```

### Task Workflow

**Assign task**:
```sql
UPDATE tasks
SET
  assignee_id = 'user-uuid',
  status = 'open'
WHERE id = 'task-uuid';
```

**Start task**:
```sql
UPDATE tasks
SET status = 'in_progress'
WHERE id = 'task-uuid'
  AND assignee_id = auth.uid();
```

**Complete task**:
```sql
UPDATE tasks
SET
  status = 'completed',
  completed_at = now()
WHERE id = 'task-uuid'
  AND assignee_id = auth.uid();
```

### Common Queries

**My open tasks**:
```sql
SELECT
  t.*,
  a.application_number,
  c.first_name || ' ' || c.last_name as borrower_name,
  CASE
    WHEN t.due_date < CURRENT_DATE THEN 'overdue'
    WHEN t.due_date = CURRENT_DATE THEN 'due_today'
    WHEN t.due_date <= CURRENT_DATE + 3 THEN 'due_soon'
    ELSE 'on_track'
  END as urgency
FROM tasks t
JOIN applications a ON t.application_id = a.id
LEFT JOIN customers c ON a.primary_customer_id = c.id
WHERE t.assignee_id = auth.uid()
  AND t.status IN ('open', 'in_progress')
ORDER BY t.due_date ASC, t.priority DESC;
```

**Application task status**:
```sql
SELECT
  status,
  priority,
  COUNT(*) as count
FROM tasks
WHERE application_id = 'app-uuid'
GROUP BY status, priority
ORDER BY
  CASE status
    WHEN 'open' THEN 1
    WHEN 'in_progress' THEN 2
    WHEN 'completed' THEN 3
    WHEN 'cancelled' THEN 4
  END,
  CASE priority
    WHEN 'urgent' THEN 1
    WHEN 'high' THEN 2
    WHEN 'medium' THEN 3
    WHEN 'low' THEN 4
  END;
```

---

## Table: `notes`

**Purpose**: Internal notes and comments about applications/customers. NOT visible to borrowers.

### Core Columns
- `application_id` FK, `customer_id` FK (can relate to application, customer, or both)
- `author_id` FK → users (who wrote the note)
- `content`: text (note content, supports Markdown)

### Usage Patterns

**Add application note**:
```sql
INSERT INTO notes (
  organization_id, application_id, author_id, content
) VALUES (
  'org-uuid', 'app-uuid', auth.uid(),
  'Spoke with borrower - they will provide updated bank statement by Friday. Large deposit was from sale of vehicle, will document with bill of sale.'
);
```

**Add customer note** (not tied to specific application):
```sql
INSERT INTO notes (
  organization_id, customer_id, author_id, content
) VALUES (
  'org-uuid', 'cust-uuid', auth.uid(),
  'Customer prefers communication via text message during business hours only. Avoid calling after 5pm.'
);
```

**Get application notes with authors**:
```sql
SELECT
  n.*,
  u.first_name || ' ' || u.last_name as author_name,
  u.avatar_url
FROM notes n
JOIN users u ON n.author_id = u.id
WHERE n.application_id = 'app-uuid'
ORDER BY n.created_at DESC;
```

### Best Practices
- **Be Professional**: Notes may be subject to regulatory review
- **Be Specific**: Include relevant details (dates, amounts, who said what)
- **Don't Make Decisions in Notes**: Use `application_events` for status changes
- **Link to Documents**: Reference document IDs if discussing specific docs

---

## Application Events (Audit Trail)

See [loan-applications.md](./loan-applications.md) for `application_events` table details.

**Key Points**:
- Auto-generated for status/stage changes
- Manually created for significant milestones
- Immutable (never updated or deleted)
- Used for compliance auditing

---

## Workflow Automation Examples

### Auto-create tasks on status change
```sql
-- Trigger function (simplified)
CREATE OR REPLACE FUNCTION create_tasks_on_status_change()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'submitted' AND OLD.status = 'draft' THEN
    -- Create task for processor
    INSERT INTO tasks (organization_id, application_id, assignee_id, title, status, priority, due_date)
    SELECT
      NEW.organization_id,
      NEW.id,
      (SELECT id FROM users WHERE organization_id = NEW.organization_id AND role = 'processor' LIMIT 1),
      'Review submitted application',
      'open',
      'medium',
      CURRENT_DATE + 2;
  END IF;

  IF NEW.status = 'in_underwriting' AND OLD.status != 'in_underwriting' THEN
    -- Create task for underwriter
    INSERT INTO tasks (organization_id, application_id, assignee_id, title, status, priority, due_date)
    SELECT
      NEW.organization_id,
      NEW.id,
      (SELECT id FROM users WHERE organization_id = NEW.organization_id AND role = 'underwriter' LIMIT 1),
      'Perform underwriting review',
      'open',
      'high',
      CURRENT_DATE + 5;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Note: This is illustrative - actual implementation may use Edge Functions
```

### Escalate overdue tasks
```sql
-- Find overdue high-priority tasks and notify
SELECT
  t.id,
  t.title,
  t.due_date,
  t.assignee_id,
  u.email as assignee_email,
  a.application_number
FROM tasks t
JOIN users u ON t.assignee_id = u.id
JOIN applications a ON t.application_id = a.id
WHERE t.status IN ('open', 'in_progress')
  AND t.priority IN ('high', 'urgent')
  AND t.due_date < CURRENT_DATE - 1
ORDER BY t.due_date ASC;
```

---

## Integration with Application Stages

| Application Stage | Typical Tasks | Assignee |
|-------------------|---------------|----------|
| `application` | "Complete application data entry" | Loan Officer |
| `application` | "Send initial disclosures" | Loan Officer |
| `processing` | "Order credit report" | Processor |
| `processing` | "Order appraisal" | Processor |
| `processing` | "Review pay stubs" | Processor |
| `processing` | "Verify employment" | Processor |
| `underwriting` | "Perform desk review" | Underwriter |
| `underwriting` | "Clear conditions" | Processor |
| `underwriting` | "Obtain final approval" | Underwriter |
| `closing` | "Order title search" | Closer |
| `closing` | "Prepare closing disclosure" | Closer |
| `closing` | "Schedule closing" | Closer |

---

## Common Queries

### Application progress (task completion %)
```sql
SELECT
  application_id,
  COUNT(*) as total_tasks,
  SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_tasks,
  ROUND(
    100.0 * SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) / COUNT(*),
    1
  ) as completion_percentage
FROM tasks
WHERE application_id = 'app-uuid'
GROUP BY application_id;
```

### Team workload
```sql
SELECT
  u.first_name || ' ' || u.last_name as team_member,
  COUNT(*) FILTER (WHERE t.status IN ('open', 'in_progress')) as active_tasks,
  COUNT(*) FILTER (WHERE t.due_date < CURRENT_DATE AND t.status != 'completed') as overdue_tasks,
  COUNT(*) FILTER (WHERE t.status = 'completed' AND t.completed_at >= CURRENT_DATE - 7) as completed_this_week
FROM users u
LEFT JOIN tasks t ON u.id = t.assignee_id
WHERE u.organization_id = auth.current_user_organization_id()
  AND u.role IN ('loan_officer', 'processor', 'underwriter', 'closer')
GROUP BY u.id, u.first_name, u.last_name
ORDER BY active_tasks DESC;
```

---

*See also: [documents-and-communications.md](./documents-and-communications.md) for document review tasks*
