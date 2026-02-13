# Authentication & User Management Tables

**Category**: Core System
**Tables**: `organizations`, `users`
**Dependencies**: Supabase `auth.users`
**Last Updated**: 2026-02-12

---

## Table: `organizations`

**Purpose**: Multi-tenant organization management. Each organization represents a separate lending institution using the Confer LOS platform.

### Columns

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | uuid | NO | `gen_random_uuid()` | Primary key |
| `name` | text | NO | - | Organization display name |
| `slug` | text | NO | - | URL-safe unique identifier |
| `settings` | jsonb | YES | NULL | Organization-specific configuration |
| `billing_status` | text | YES | `'trial'` | Subscription status (trial, active, suspended, cancelled) |
| `stripe_customer_id` | text | YES | NULL | Stripe customer ID for billing |
| `created_at` | timestamp | NO | `now()` | Creation timestamp |
| `updated_at` | timestamp | NO | `now()` | Last update timestamp |

### Constraints

- **PK**: `id`
- **UNIQUE**: `slug`

### Indexes

- `organizations_pkey` on `id`
- `organizations_slug_key` on `slug`

### RLS Policies

**3 policies enabled**:

1. **`system_admin_all`** — FOR ALL
   - Check: `auth.is_system_admin()`
   - Allows Confer platform admins full access across all organizations

2. **`staff_manage`** — FOR ALL
   - Check: `id = get_auth_org_id()` AND `get_auth_role() IN ('admin', 'loan_officer', 'processor', 'underwriter')`
   - Staff can manage their own organization

3. **`staff_view`** — FOR SELECT
   - Check: `id = get_auth_org_id()`
   - Any staff member can view their own organization

### Usage Patterns

**Create new organization** (system admin only):
```sql
INSERT INTO organizations (name, slug, settings, billing_status)
VALUES (
  'Acme Lending',
  'acme-lending',
  '{"theme": "blue", "logo_url": "https://..."}'::jsonb,
  'trial'
);
```

**Update organization settings**:
```sql
UPDATE organizations
SET
  settings = settings || '{"max_applications": 1000}'::jsonb,
  updated_at = now()
WHERE slug = 'acme-lending';
```

### Business Logic

- **Slug**: Must be unique and URL-safe (lowercase, alphanumeric, hyphens only)
- **Settings**: JSONB allows flexible configuration per organization (branding, limits, integrations)
- **Billing Status**: Determines access to platform features
  - `trial`: 30-day trial period
  - `active`: Paid subscription
  - `suspended`: Payment issue or policy violation
  - `cancelled`: Subscription ended

---

## Table: `users`

**Purpose**: Internal staff users (loan officers, processors, underwriters, admins) who work within an organization. This table extends `auth.users` with organization context and role information.

### Columns

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | uuid | NO | - | Primary key, **references auth.users.id** |
| `organization_id` | uuid | YES | NULL | Foreign key to `organizations` |
| `role` | text | YES | NULL | User role within organization |
| `first_name` | text | YES | NULL | First name |
| `last_name` | text | YES | NULL | Last name |
| `email` | text | YES | NULL | Email address (duplicate of auth.users.email) |
| `phone` | text | YES | NULL | Phone number |
| `avatar_url` | text | YES | NULL | Profile picture URL |
| `metadata` | jsonb | YES | NULL | Additional user metadata |
| `system_admin` | boolean | YES | `false` | True if Confer platform admin |
| `nmls_number` | text | YES | NULL | **Phase 5B** — NMLS number (for licensed loan officers) |
| `bio` | text | YES | NULL | **Phase 5B** — Bio/about text for LO profile |
| `is_manager` | boolean | NO | `false` | **Phase 5B** — Is this user a manager? |
| `working_hours` | jsonb | YES | NULL | **Phase 5B** — Working hours (e.g., `{"start": "09:00", "end": "17:00", "timezone": "America/Los_Angeles"}`) |
| `last_lead_assigned_at` | timestamp | YES | NULL | **Phase 5B** — Last time a lead was assigned (for round-robin) |
| `created_at` | timestamp | NO | `now()` | Creation timestamp |
| `updated_at` | timestamp | NO | `now()` | Last update timestamp |

### Constraints

- **PK**: `id`
- **FK**: `organization_id` → `organizations(id)` ON DELETE SET NULL
- **FK**: `id` → `auth.users(id)` ON DELETE CASCADE

### Indexes

- `users_pkey` on `id`
- `users_organization_id_idx` on `organization_id`

### RLS Policies

**3 policies enabled**:

1. **`system_admin_all`** — FOR ALL
   - Check: `auth.is_system_admin()`
   - System admins can access all users across organizations

2. **`staff_manage`** — FOR ALL
   - Check: `organization_id = get_auth_org_id()` AND `get_auth_role() IN ('admin', 'loan_officer', 'processor', 'underwriter')`
   - Staff can view/update users within their organization (admins can modify)

3. **`staff_view`** — FOR SELECT
   - Check: `organization_id = get_auth_org_id()`
   - Any staff member can view other users in their organization

### Triggers

- **`on_auth_user_created`**: Automatically creates a `users` record when a new auth user is created
  - Function: `public.handle_new_user()`

### Usage Patterns

**Get current user's profile**:
```sql
SELECT *
FROM users
WHERE id = auth.uid();
```

**Get all users in organization**:
```sql
SELECT u.*
FROM users u
WHERE u.organization_id = (
  SELECT organization_id FROM users WHERE id = auth.uid()
);
```

**Assign user to application**:
```sql
UPDATE applications
SET
  assigned_to = 'user-uuid-here',
  updated_at = now()
WHERE id = 'app-uuid-here';
```

### User Roles

Common values for the `role` column:

| Role | Description | Typical Access |
|------|-------------|---------------|
| `admin` | Organization administrator | Full access to organization settings, users, all applications |
| `loan_officer` | Loan originator | Create applications, manage assigned applications, communicate with borrowers |
| `processor` | Loan processor | Update applications, collect documents, verify information |
| `underwriter` | Underwriter | View applications, approve/deny, request conditions |
| `closer` | Closing coordinator | Manage closing process, generate documents |
| `viewer` | Read-only access | View applications only |

### Business Logic

- **One Auth User = One Organization User**: The `id` directly references `auth.users.id`, creating a 1:1 relationship
- **System Admins**: Can access multiple organizations (for Confer platform administration)
- **Email Duplication**: Email is stored in both `auth.users` and `users` for easier querying
- **Soft Deletion**: When an auth user is deleted, the `users` record cascades delete
- **Metadata**: Stores additional information like:
  - Phone extension
  - Timezone preference (deprecated - use `working_hours.timezone` in Phase 5B)
  - Other custom fields
- **Phase 5B Changes**:
  - `nmls_number`, `bio`, `is_manager`, `working_hours`, `last_lead_assigned_at` added as dedicated columns
  - `is_manager` controls visibility in round-robin lead assignment
  - `last_lead_assigned_at` tracks round-robin distribution
  - `working_hours` used for scheduling and availability display

### Auth Functions

**Get current user's organization**:
```sql
SELECT auth.current_user_organization_id();
-- Returns: uuid or NULL
```

**Get current user's role**:
```sql
SELECT auth.get_user_role();
-- Returns: text (role name) or NULL
```

These functions are used in RLS policies to enforce organization-scoped access.

---

## Relationship to `auth.users`

The Supabase `auth.users` table (managed by Supabase Auth) stores:
- Encrypted password
- Email confirmation status
- Password reset tokens
- MFA configuration
- Session management

The `public.users` table extends this with:
- Organization context
- User profile information
- Application-specific metadata

**Key Distinction**:
- **Internal users** (staff): Have record in `public.users` with `id = auth.users.id`
- **Borrowers**: Have record in `public.customers` with `auth_user_id = auth.users.id`

---

## Common Queries

### Get user's full name
```sql
SELECT first_name || ' ' || last_name AS full_name
FROM users
WHERE id = auth.uid();
```

### Get all loan officers in organization
```sql
SELECT *
FROM users
WHERE organization_id = (SELECT organization_id FROM users WHERE id = auth.uid())
  AND role = 'loan_officer'
ORDER BY last_name, first_name;
```

### Get user's assigned applications
```sql
SELECT a.*
FROM applications a
WHERE a.assigned_to = auth.uid()
  AND a.status NOT IN ('funded', 'withdrawn', 'denied')
ORDER BY a.created_at DESC;
```

---

*See also: [customers-and-portal.md](./customers-and-portal.md) for borrower authentication*
