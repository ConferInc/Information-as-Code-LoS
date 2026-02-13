# Leads Table

**Category**: Sales & Lead Management (Phase 5B)
**Table**: `leads`
**Purpose**: Pre-application contact management with lead scoring and conversion tracking
**Last Updated**: 2026-02-12

---

## Overview

The `leads` table manages pre-application contacts in the **LO Portal** (Loan Officer Portal). Leads represent potential borrowers who have expressed interest but haven't yet started a formal application. This table supports lead scoring, assignment, qualification tracking, and conversion to applications.

---

## Columns

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | uuid | NO | `gen_random_uuid()` | Primary key |
| `organization_id` | uuid | NO | - | FK to `organizations` |
| `first_name` | text | NO | - | First name |
| `middle_name` | text | YES | NULL | Middle name |
| `last_name` | text | NO | - | Last name |
| `email` | text | YES | NULL | Email address |
| `phone` | text | YES | NULL | Primary phone number |
| `phone_secondary` | text | YES | NULL | Secondary phone number |
| `status` | text | NO | `'new'` | Lead status (see values below) |
| `source` | text | YES | NULL | Lead source (see values below) |
| `source_detail` | text | YES | NULL | Additional source information |
| `assigned_to` | uuid | YES | NULL | FK to `users` (loan officer assigned) |
| `score` | integer | YES | `0` | Lead score (0-100 typically) |
| `loan_purpose` | text | YES | NULL | Purchase, refinance, etc. (see values below) |
| `estimated_loan_amount` | numeric | YES | NULL | Estimated loan amount |
| `estimated_purchase_price` | numeric | YES | NULL | Estimated purchase price (for purchase loans) |
| `estimated_down_payment` | numeric | YES | NULL | Estimated down payment |
| `property_type` | text | YES | NULL | Type of property (see values below) |
| `property_state` | text | YES | NULL | Property state (2-letter code) |
| `property_city` | text | YES | NULL | Property city |
| `occupancy_type` | text | YES | NULL | Primary residence, second home, investment |
| `credit_score_range` | text | YES | NULL | Credit score range (see values below) |
| `annual_income` | numeric | YES | NULL | Borrower's annual income |
| `is_self_employed` | boolean | YES | NULL | Is borrower self-employed |
| `is_first_time_buyer` | boolean | YES | NULL | Is borrower a first-time home buyer |
| `is_veteran` | boolean | YES | NULL | Is borrower a veteran (for VA loans) |
| `has_realtor` | boolean | YES | NULL | Does lead have a realtor |
| `realtor_name` | text | YES | NULL | Realtor name |
| `realtor_phone` | text | YES | NULL | Realtor phone |
| `realtor_email` | text | YES | NULL | Realtor email |
| `preferred_contact_method` | text | YES | `'email'` | Email, phone, text |
| `preferred_contact_time` | text | YES | NULL | Morning, afternoon, evening, anytime |
| `disposition_reason` | text | YES | NULL | Reason for disqualification/loss |
| `disposition_notes` | text | YES | NULL | Notes on disposition |
| `converted_application_id` | uuid | YES | NULL | FK to `applications` (when converted) |
| `converted_customer_id` | uuid | YES | NULL | FK to `customers` (when converted) |
| `last_contacted_at` | timestamp | YES | NULL | Last contact timestamp |
| `next_follow_up_at` | timestamp | YES | NULL | Scheduled follow-up time |
| `notes` | text | YES | NULL | General notes |
| `metadata` | jsonb | YES | NULL | Additional flexible data |
| `created_at` | timestamp | NO | `now()` | Creation timestamp |
| `updated_at` | timestamp | NO | `now()` | Last update timestamp |
| `created_by` | uuid | YES | NULL | FK to `users` who created the lead |

---

## Constraints

- **PK**: `id`
- **FK**: `organization_id` → `organizations(id)`
- **FK**: `assigned_to` → `users(id)`
- **FK**: `converted_application_id` → `applications(id)`
- **FK**: `converted_customer_id` → `customers(id)`
- **FK**: `created_by` → `users(id)`

---

## Indexes

| Index Name | Columns | Purpose |
|------------|---------|---------|
| `leads_org_status_idx` | `organization_id, status` | Filter by status per org |
| `leads_org_assigned_idx` | `organization_id, assigned_to` | LO's assigned leads |
| `leads_org_email_idx` | `organization_id, email` | Find by email (duplicate check) |
| `leads_org_phone_idx` | `organization_id, phone` | Find by phone (duplicate check) |
| `leads_org_score_idx` | `organization_id, score` | Sort by lead score |
| `leads_org_created_idx` | `organization_id, created_at` | Recent leads |

---

## Enum Values

### Status
| Value | Description |
|-------|-------------|
| `new` | Newly created lead, not yet contacted |
| `contacted` | Initial contact made |
| `qualifying` | Currently being qualified |
| `qualified` | Meets loan criteria |
| `quoted` | Quote/pre-qual provided |
| `application_started` | Application in progress |
| `nurturing` | Long-term follow-up |
| `disqualified` | Does not meet criteria |
| `lost` | Lost to competitor or decided not to proceed |
| `converted` | Converted to application |

### Source
| Value | Description |
|-------|-------------|
| `web` | Website inquiry/form |
| `phone` | Phone call |
| `referral` | Referral from existing customer |
| `walk_in` | Walk-in to office |
| `builder` | Builder/developer referral |
| `realtor` | Real estate agent referral |
| `marketing` | Marketing campaign |
| `purchase_list` | Purchased lead list |
| `social_media` | Social media |
| `other` | Other source |

### Loan Purpose
| Value | Description |
|-------|-------------|
| `purchase` | Purchase a home |
| `refinance_rate_term` | Refinance (rate/term) |
| `refinance_cash_out` | Refinance (cash-out) |
| `construction` | Construction loan |
| `renovation` | Renovation/rehab loan |
| `heloc` | Home equity line of credit |

### Property Type
| Value | Description |
|-------|-------------|
| `single_family` | Single-family residence |
| `condo` | Condominium |
| `townhouse` | Townhouse |
| `multi_2_unit` | 2-unit multi-family |
| `multi_3_unit` | 3-unit multi-family |
| `multi_4_unit` | 4-unit multi-family |
| `manufactured` | Manufactured home |
| `cooperative` | Co-op |

### Occupancy Type
| Value | Description |
|-------|-------------|
| `primary_residence` | Primary residence |
| `second_home` | Second home/vacation property |
| `investment` | Investment property |

### Credit Score Range
| Value | Description |
|-------|-------------|
| `below_580` | Below 580 |
| `580_619` | 580-619 |
| `620_639` | 620-639 |
| `640_659` | 640-659 |
| `660_679` | 660-679 |
| `680_699` | 680-699 |
| `700_719` | 700-719 |
| `720_739` | 720-739 |
| `740_759` | 740-759 |
| `760_779` | 760-779 |
| `780_plus` | 780+ |
| `unknown` | Unknown |

### Preferred Contact Method
| Value | Description |
|-------|-------------|
| `email` | Email |
| `phone` | Phone call |
| `text` | SMS/text message |

### Preferred Contact Time
| Value | Description |
|-------|-------------|
| `morning` | Morning (8am-12pm) |
| `afternoon` | Afternoon (12pm-5pm) |
| `evening` | Evening (5pm-8pm) |
| `anytime` | Anytime |

---

## RLS Policies

**Status**: ⚠️ **Not yet configured**

RLS policies for the `leads` table have not been implemented in Phase 5B. Access control is currently handled at the application level.

**Planned policies**:
1. `system_admin_all` — System admins can access all leads
2. `staff_manage` — Staff can manage leads in their organization
3. `staff_view` — Staff can view leads in their organization
4. `assigned_lo_manage` — Loan officers can manage their assigned leads

---

## Business Logic

### Lead Scoring
- Score is calculated based on:
  - Completeness of information (email, phone, property details)
  - Credit score range
  - Loan amount vs. income ratio
  - Time since last contact
  - Engagement level (number of interactions)
- Higher scores indicate higher priority/likelihood of conversion

### Lead Assignment
- Leads can be assigned manually or via round-robin
- `users.last_lead_assigned_at` tracks round-robin distribution
- Only active loan officers with `is_manager = false` participate in round-robin

### Lead Conversion
When a lead converts to an application:
1. Create `customers` record from lead data
2. Create `applications` record
3. Set `leads.converted_application_id` and `converted_customer_id`
4. Set `leads.status = 'converted'`
5. Set `applications.lead_id` to link back
6. Log `lead_activities` (activity_type: `converted_to_application`)

### Follow-Up Scheduling
- `next_follow_up_at` is used for automated reminders
- Creates tasks when follow-up is due
- Can be set manually or auto-calculated based on status

---

## Relationships

### Parent Tables
- `organizations` (1:M) — Each lead belongs to one organization
- `users` (assigned_to, created_by) — Assigned loan officer and creator

### Child Tables
- `lead_activities` (1:M) — Audit trail of lead interactions
- `quick_quotes` (1:M) — Quotes generated for this lead
- `communications` (1:M) — Communications with this lead
- `tasks` (1:M) — Follow-up tasks for this lead

### Conversion Targets
- `applications` (M:1) — Lead converts to application
- `customers` (M:1) — Lead converts to customer

---

## Usage Patterns

### Create a new lead (web form)
```sql
INSERT INTO leads (
  organization_id, first_name, last_name, email, phone,
  source, loan_purpose, estimated_loan_amount, property_type,
  occupancy_type, property_state, created_by
) VALUES (
  'org-uuid',
  'Jane', 'Doe',
  'jane.doe@example.com',
  '555-123-4567',
  'web',
  'purchase',
  350000,
  'single_family',
  'primary_residence',
  'CA',
  auth.uid()
)
RETURNING id;
```

### Assign lead to loan officer
```sql
UPDATE leads
SET
  assigned_to = 'lo-user-uuid',
  updated_at = now()
WHERE id = 'lead-uuid';

-- Also update last_lead_assigned_at for round-robin
UPDATE users
SET last_lead_assigned_at = now()
WHERE id = 'lo-user-uuid';
```

### Update lead status and log activity
```sql
-- Update lead status
UPDATE leads
SET
  status = 'contacted',
  last_contacted_at = now(),
  updated_at = now()
WHERE id = 'lead-uuid';

-- Log activity
INSERT INTO lead_activities (
  organization_id, lead_id,
  activity_type, description,
  from_status, to_status,
  created_by
) VALUES (
  'org-uuid', 'lead-uuid',
  'status_changed', 'Initial contact made by phone',
  'new', 'contacted',
  auth.uid()
);
```

### Convert lead to application
```sql
-- Create customer from lead
INSERT INTO customers (
  organization_id, first_name, last_name,
  email, phone
)
SELECT
  organization_id, first_name, last_name,
  email, phone
FROM leads
WHERE id = 'lead-uuid'
RETURNING id INTO customer_id;

-- Create application
INSERT INTO applications (
  organization_id, primary_customer_id,
  loan_product_id, loan_amount,
  occupancy_type, status, stage,
  lead_id, assigned_to, source
)
SELECT
  organization_id, customer_id,
  'product-uuid', estimated_loan_amount,
  occupancy_type, 'draft', 'application',
  id, assigned_to, 'lead_conversion'
FROM leads
WHERE id = 'lead-uuid'
RETURNING id INTO application_id;

-- Update lead
UPDATE leads
SET
  converted_application_id = application_id,
  converted_customer_id = customer_id,
  status = 'converted',
  updated_at = now()
WHERE id = 'lead-uuid';

-- Log activity
INSERT INTO lead_activities (
  organization_id, lead_id,
  activity_type, description,
  created_by
) VALUES (
  'org-uuid', 'lead-uuid',
  'converted_to_application',
  'Lead converted to application #' || application_number,
  auth.uid()
);
```

### Get leads for dashboard (loan officer view)
```sql
SELECT
  l.*,
  u.first_name || ' ' || u.last_name as assigned_to_name,
  COUNT(la.id) as activity_count,
  COUNT(qq.id) as quote_count
FROM leads l
LEFT JOIN users u ON l.assigned_to = u.id
LEFT JOIN lead_activities la ON l.id = la.lead_id
LEFT JOIN quick_quotes qq ON l.id = qq.lead_id
WHERE l.organization_id = auth.current_user_organization_id()
  AND l.assigned_to = auth.uid()
  AND l.status NOT IN ('converted', 'lost', 'disqualified')
GROUP BY l.id, u.first_name, u.last_name
ORDER BY l.score DESC, l.created_at DESC;
```

---

## Common Queries

### Find leads needing follow-up
```sql
SELECT *
FROM leads
WHERE organization_id = 'org-uuid'
  AND status NOT IN ('converted', 'lost', 'disqualified')
  AND next_follow_up_at <= now()
ORDER BY score DESC;
```

### Lead pipeline report
```sql
SELECT
  status,
  COUNT(*) as count,
  AVG(score) as avg_score,
  SUM(estimated_loan_amount) as total_potential_volume
FROM leads
WHERE organization_id = 'org-uuid'
  AND created_at >= date_trunc('month', now())
GROUP BY status
ORDER BY status;
```

### Check for duplicate leads
```sql
SELECT *
FROM leads
WHERE organization_id = 'org-uuid'
  AND (
    email = 'email@example.com'
    OR phone = '555-123-4567'
  )
  AND status != 'converted'
ORDER BY created_at DESC;
```

---

## Integration Notes

### Server Actions
Located in `app/actions/org/`:
- `createLead()` — Create new lead
- `updateLead()` — Update lead details
- `assignLead()` — Assign to loan officer
- `convertLeadToApplication()` — Convert lead

### Related Tables
- See [lead-activities.md](./lead-activities.md) for activity tracking
- See [quick-quotes.md](./quick-quotes.md) for quote generation
- See [pipeline-stages.md](./pipeline-stages.md) for custom workflows

---

*Part of Phase 5B LO Portal release. RLS policies pending implementation.*
