# Supabase Database Architecture Overview

**Project**: Confer LOS (Loan Origination System)
**Database**: PostgreSQL 15.8 (Supabase-managed)
**Last Updated**: 2026-02-13

---

## System Purpose

The Confer LOS database is a comprehensive **multi-tenant loan origination system** designed to manage the complete lifecycle of mortgage applications from initial borrower contact through funding. The system is **URLA 1003 compliant** and includes full **HMDA demographic tracking**.

---

## High-Level Architecture

```mermaid
graph TB
    subgraph "Multi-Tenant Layer"
        ORG[Organizations]
        USERS[Internal Users/Staff]
    end

    subgraph "Borrower Portal"
        CUST[Customers<br/>Borrowers]
        AUTH[Auth Users<br/>Supabase Auth]
    end

    subgraph "Loan Application Core"
        PROD[Loan Products]
        PROP[Properties]
        APP[Applications]
        APPCUST[Application Customers<br/>Junction Table]
    end

    subgraph "Financial Profile"
        EMP[Employments]
        INC[Incomes]
        ASS[Assets]
        LIA[Liabilities]
        REO[Real Estate Owned]
        RES[Residences]
    end

    subgraph "Compliance & Declarations"
        DEC[Declarations]
        DEM[Demographics]
    end

    subgraph "Document & Workflow"
        DOC[Documents]
        COMM[Communications]
        TASKS[Tasks]
        NOTES[Notes]
        EVENTS[Application Events]
    end

    subgraph "Sales & Lead Management"
        LEADS[Leads]
        LEADACT[Lead Activities]
        STAGES[Pipeline Stages]
        SOURCES[Lead Sources]
        QUOTES[Quick Quotes]
        NOTIF[Notification Preferences]
        TEMPLATES[Communication Templates]
    end

    ORG --> USERS
    ORG --> CUST
    ORG --> PROD
    ORG --> PROP
    ORG --> APP

    AUTH -.->|auth_user_id| CUST
    CUST --> APPCUST
    APP --> APPCUST
    PROD --> APP
    PROP --> APP
    USERS -->|assigned_to| APP

    APPCUST --> EMP
    APPCUST --> INC
    APPCUST --> ASS
    APPCUST --> LIA
    APPCUST --> REO
    APPCUST --> RES
    APPCUST --> DEC
    APPCUST --> DEM

    APP --> DOC
    APP --> COMM
    APP --> TASKS
    APP --> NOTES
    APP --> EVENTS

    ORG --> LEADS
    ORG --> STAGES
    ORG --> SOURCES
    ORG --> TEMPLATES
    USERS -->|assigned_to| LEADS
    LEADS --> LEADACT
    LEADS --> QUOTES
    LEADS -->|converts to| APP
    LEADS -->|converts to| CUST
    APP --> QUOTES
    USERS --> NOTIF
    COMM --> TEMPLATES
```

---

## Multi-Tenancy Model

The system uses **organization-based multi-tenancy**:

- Every core table has an `organization_id` foreign key
- Row-Level Security (RLS) policies enforce data isolation
- Each organization is completely isolated from others
- Shared infrastructure (auth, storage, realtime) is managed by Supabase

**Benefits**:
- Single database for all tenants (cost-effective)
- Strong data isolation via RLS
- Consistent schema across all organizations
- Easy to add new organizations

---

## User Roles & Access Model

### Internal Users (Lender Staff)
These users work within an organization and process loans:

| Role | Access Level | Typical Responsibilities |
|------|-------------|-------------------------|
| `admin` | Full organization access | Manage settings, users, products |
| `loan_officer` | Create/manage applications | Originate loans, communicate with borrowers |
| `processor` | View/update applications | Collect documents, verify information |
| `underwriter` | View/decide applications | Review financials, approve/deny loans |
| `system_admin` | Cross-organization | Confer platform administrators |

**Authentication**: Via `auth.users` with `users.id = auth.uid()`

---

### External Users (Borrowers)
Customers can access the borrower portal to:
- Complete their loan application
- Upload documents
- View application status
- Communicate with loan officer

**Authentication**: Via `auth.users` with `customers.auth_user_id = auth.uid()`

**Key Distinction**:
- Internal users have a record in `public.users`
- Borrowers have a record in `public.customers` with `auth_user_id` linked to `auth.users`

---

## Authentication & Authorization Flow

### Internal User Flow
```mermaid
sequenceDiagram
    participant U as User (Staff)
    participant Auth as Supabase Auth
    participant DB as Database
    participant RLS as RLS Policies

    U->>Auth: Login (email/password)
    Auth->>U: JWT with auth.uid()
    U->>DB: Query applications
    DB->>RLS: Check: users.id = auth.uid()
    RLS->>DB: Filter by user's organization_id
    DB->>U: Return applications
```

### Borrower Portal Flow
```mermaid
sequenceDiagram
    participant B as Borrower
    participant Auth as Supabase Auth
    participant DB as Database
    participant RLS as RLS Policies

    B->>Auth: Login (email/password or magic link)
    Auth->>B: JWT with auth.uid()
    B->>DB: View my applications
    DB->>RLS: Check: customers.auth_user_id = auth.uid()
    RLS->>DB: Filter applications by customer_id
    DB->>B: Return borrower's applications
```

---

## Row-Level Security (RLS) Strategy

**23 tables** have **RLS enabled** (consents table exists in Drizzle but not yet migrated; Phase 5B tables do not have RLS configured yet). The system deployed 115+ comprehensive policies across existing tables.

### RLS Helper Functions (5)

All functions are `SECURITY DEFINER` with `SET search_path = public` and `STABLE` volatility:

1. **`get_auth_org_id()`** → uuid
   - Returns staff user's organization_id from users table
   - Returns NULL for borrowers or unauthenticated users

2. **`get_auth_role()`** → text
   - Returns staff user's role (admin, loan_officer, processor, underwriter)
   - Returns NULL for borrowers or unauthenticated users

3. **`auth.is_system_admin()`** → boolean
   - Checks system_admin flag on users table
   - COALESCE to false for safety

4. **`get_auth_customer_ids()`** → SETOF uuid
   - Returns customer IDs linked to auth.uid() via customers.auth_user_id
   - Used for borrower access to customer-scoped data

5. **`get_borrower_application_ids()`** → SETOF uuid
   - Returns application IDs where user is:
     - Primary customer (applications.primary_customer_id)
     - Co-borrower (via application_customers)
     - Anonymous draft creator (via key_information->>'_authUserId')

### Standard Policy Pattern

Each table follows this 5-policy pattern (with variations):

1. **`system_admin_all`** — FOR ALL
   - Check: `auth.is_system_admin()`
   - Bypasses all restrictions for Confer platform admins

2. **`staff_manage`** — FOR ALL
   - Check: `organization_id = get_auth_org_id()` AND role IN ('admin', 'loan_officer', 'processor', 'underwriter')
   - Full CRUD for staff within their organization

3. **`staff_view`** — FOR SELECT
   - Check: `organization_id = get_auth_org_id()`
   - Read-only for any staff role

4. **`borrower_view_own`** — FOR SELECT
   - Check: Scoped to borrower's data (see patterns below)
   - Read access to own data

5. **`borrower_manage_own`** — FOR INSERT/UPDATE
   - Check: Scoped to borrower's data + status restrictions
   - Write access where appropriate (e.g., draft applications only)

### Scoping Patterns by Table Type

**Customer-scoped tables** (residences, employments, incomes, declarations, demographics, gift_funds, real_estate_owned):
```sql
customer_id IN (SELECT get_auth_customer_ids())
```

**Application-scoped tables** (assets, liabilities, documents, communications, application_events):
```sql
application_id IN (SELECT get_borrower_application_ids())
```

**Junction tables** (asset_ownership, liability_ownership):
- Scoped via parent table's application_id

**Staff-only tables** (tasks, notes):
- No borrower policies (staff only)

**Public read tables** (loan_products):
- All authenticated users can SELECT (for rate shopping)

### Special Application Policies

The `applications` table has the most complex policies:

1. **`borrower_view_own_apps`** — FOR SELECT
   - Check: `id IN (SELECT get_borrower_application_ids())`

2. **`borrower_update_own_draft`** — FOR UPDATE
   - Check: `id IN (SELECT get_borrower_application_ids())` AND `status IN ('draft', 'in_progress')`
   - Borrowers can only edit draft/in-progress applications

3. **`anon_create_draft`** — FOR INSERT
   - Anonymous users can create draft applications

4. **`anon_update_own_draft`** — FOR UPDATE
   - Check: `key_information->>'_authUserId' = auth.uid()::text` AND `status = 'draft'`
   - Anonymous draft creators can update their drafts

5. **`anon_view_own_draft`** — FOR SELECT
   - Check: `key_information->>'_authUserId' = auth.uid()::text` AND `status = 'draft'`
   - Anonymous draft creators can view their drafts

### Compliance Rules

**Documents**:
- Borrowers can SELECT, INSERT, UPDATE but NOT DELETE
- Only staff can delete documents (audit compliance)

**Application Events**:
- Borrowers have read-only access (audit trail integrity)
- No UPDATE or DELETE policies for borrowers

**Consents** (table not yet created):
- INSERT + SELECT only (no UPDATE/DELETE)
- Immutability for regulatory compliance

### Performance Indexes

RLS-optimized indexes added:
- `idx_customers_auth_user_id` on customers(auth_user_id)
- `idx_application_customers_customer_id` on application_customers(customer_id)
- `idx_application_customers_application_id` on application_customers(application_id)
- `idx_applications_primary_customer_id` on applications(primary_customer_id)
- `idx_applications_key_info_auth_user` on applications using btree(key_information->>'_authUserId')

---

## Middleware Route Protection

The Next.js middleware enforces route-level access control:

### Staff Routes
- **`/dashboard/*`** — Staff only (loan officers, processors, underwriters, admins)
  - Requires: `public.users` record with valid organization_id
  
- **`/admin/*`** — Admin/System Admin only
  - Requires: role = 'admin' OR system_admin = true

### Borrower Routes
- **`/borrower/*`** — Authenticated borrowers only (NEW)
  - Requires: `public.customers` record with auth_user_id
  
- **`/co-borrower/*`** — Authenticated borrowers, with exceptions (NEW)
  - Public access: `/co-borrower/welcome`, `/co-borrower/verify`
  - Protected: All other co-borrower routes

### Public/Anonymous Routes
- **`/apply/*`** — Partial anonymous access
  - Steps 1-9: Anonymous (draft creation)
  - Step 10+: Authentication required
  - Uses key_information->>'_authUserId' for anonymous tracking

### Implementation Notes
- Middleware runs before RLS policies (first line of defense)
- RLS provides data-level security (second line of defense)
- Defense-in-depth: both layers must authorize access

---

## Data Model Principles

### 1. Multi-Borrower Support
Applications can have multiple borrowers (e.g., married couple, business partners):
- `application_customers` is a junction table linking applications to customers
- Each link has a `role` (primary_borrower, co_borrower, guarantor)
- Financial data (employment, income, assets, liabilities) is linked to the customer AND application

### 2. URLA 1003 Compliance
The schema mirrors the **Uniform Residential Loan Application**:
- Section I: Borrower Information → `customers`, `residences`
- Section II: Financial Information → `employments`, `incomes`, `assets`, `liabilities`
- Section III: Loan and Property Information → `applications`, `properties`
- Section IV: Declarations → `declarations`
- Section V: Demographics → `demographics`

### 3. Asset/Liability Ownership
Assets and liabilities can be:
- Owned by a single borrower
- Jointly owned by multiple borrowers

This is modeled via ownership junction tables:
- `asset_ownership` (asset_id, customer_id, ownership_percentage)
- `liability_ownership` (liability_id, customer_id, ownership_role)

### 4. Document Management
Documents are stored in Supabase Storage with metadata in the `documents` table:
- `file_path`: Reference to storage bucket
- `document_type`: Categorization (pay_stub, w2, bank_statement, etc.)
- `status`: Review workflow (pending, approved, rejected)
- Linked to applications and optionally to specific customers

### 5. Audit Trail
Every status change is logged in `application_events`:
- Event type (status_change, stage_change, assignment_change)
- From/to values
- User who made the change
- Timestamp and source

### 6. Sales & Lead Management (Phase 5B)
The **LO Portal** introduces a comprehensive lead management system with 7 new tables:

#### `leads`
- Pre-application contact management
- Lead scoring and qualification tracking
- Source attribution and pipeline status
- Conversion to customers and applications
- Includes property intent, loan purpose, credit score range
- Assigned to loan officers with follow-up scheduling

#### `lead_activities`
- Complete audit trail of lead interactions
- Activity types: created, status_changed, assigned, note_added, call_logged, email_sent, quote_generated, converted_to_application
- Metadata for context and analytics

#### `pipeline_stages`
- Customizable workflow stages per organization
- Configurable sort order, colors, and SLA deadlines
- Terminal stage tracking (won/lost/disqualified)
- Prerequisites for stage progression
- Applications can reference pipeline_stage_id (custom) or use default stage enum

#### `lead_sources`
- Source tracking for ROI analysis
- Categories: web, phone, referral, realtor, marketing, social_media, etc.
- Cost-per-lead tracking for marketing attribution

#### `quick_quotes`
- Fast scenario modeling for leads and applications
- Linked to leads (pre-application) or applications (in-process)
- Calculates monthly PI, DTI, LTV
- Pre-qualification letter generation tracking
- Multiple scenarios per lead/application

#### `notification_preferences`
- Per-user notification settings (email, in-app)
- Granular control over notification types
- Used for lead assignment, document requests, status updates

#### `communication_templates`
- Reusable email/SMS templates per organization
- Categories: welcome, document_request, status_update, follow_up, closing
- Merge field support for personalization
- Templates linked to communications table

**Note**: RLS policies for Phase 5B tables are **not yet configured**. Current access control is application-level only.

### 7. Underwriter Portal (Phase 7B)
The **Underwriter Portal** provides comprehensive risk analysis and decision-making capabilities with 5 new tables:

#### `uw_decisions`
- Records underwriting decisions for loan applications
- Decision types: approve, approve_with_conditions, suspend, deny
- Captures rationale factors and underwriter signature
- Supports counter-offers with alternative loan terms
- Denial-specific fields for adverse action compliance
- Suspension workflow for document deficiencies or fraud concerns

#### `risk_assessments`
- Comprehensive risk analysis for each application
- **DTI Metrics**: front-end/back-end ratios, guideline compliance, overrides
- **LTV Metrics**: loan-to-value, CLTV, down payment calculations
- **Reserves Metrics**: liquid assets, retirement assets (discounted), months of PITI
- **Credit Metrics**: representative score, expiration tracking, credit history analysis
- **Compensating Factors**: 8 boolean flags for manual underwriting criteria
- **Credit Analysis**: tradelines, inquiries, derogatory items, payment history
- Supports guideline overrides with required justification

#### `exception_requests`
- Tracks requests for exceptions to standard underwriting guidelines
- Exception types: DTI, LTV, credit_score, reserves, employment_gap
- Calculates variance amount and percentage from guideline
- Approval workflow: pending → approved/denied
- Requires detailed justification (min 100 characters)
- Tracks compensating factors supporting exception

#### `condition_templates`
- Reusable templates for common underwriting conditions
- Condition types: prior_to_approval, prior_to_docs, prior_to_funding, prior_to_purchase, informational
- Categories: income, assets, employment, credit, property, title, insurance, legal, compliance
- Priority levels: low, medium, high, critical
- Usage tracking for template optimization
- Default due date configuration

#### `ctc_clearances`
- Clear-to-Close checklist with boolean flags
- 11 required items: conditions cleared, credit current, VOE final, appraisal, title, insurance, CD, no adverse changes, closing scheduled, funds verified
- Auto-computed `all_items_checked` flag
- CTC issuance tracking with timestamp and issuing underwriter
- Prevents closing until all items verified

**Note**: RLS policies for Phase 7B tables are **not yet configured**. Current access control is application-level only.

### 8. Closer Portal (Phase 8B)
The **Closer Portal** manages the final stages of loan closing and post-closing with 6 new tables:

#### `closing_packages`
- Manages assembly and delivery of closing document packages
- Document checklist with status tracking (not_uploaded, uploaded, reviewed, approved)
- Completeness percentage auto-calculated
- Multiple delivery methods: email, portal_upload, sftp, physical_mail, courier
- Generates final merged PDF package
- Unique per application (one package per loan)

#### `wire_requests`
- Wire transfer management with fraud prevention measures
- **Dual Approval Workflow**: first and second approver for large amounts
- **Phone Verification Required**: must verbally confirm account with bank rep
- Recipient types: title_escrow, borrower, seller, other
- Wire status progression: draft → submitted → pending_verification → approved → sent → confirmed
- Stores wire instructions document and confirmation document
- Tracks wire reference number and confirmation date

#### `cd_revisions`
- Version history of Closing Disclosures (CDs)
- **TRID Compliance**: 3-business-day waiting period tracking
- Version numbering for each revision (1, 2, 3...)
- Revision reasons: correction, changed_circumstance, borrower_request
- **Tolerance Monitoring**: pass/fail/changed_circumstance status
- Tracks changed circumstances with detailed documentation
- Delivery method tracking: esign, email, hand_delivered, mail
- Status progression: draft → ready_to_issue → issued → viewed → signed → acknowledged → superseded

#### `closing_schedules`
- Closing appointment scheduling and coordination
- Supports in-person, RON (Remote Online Notarization), and mobile closings
- Location types: title_office, lender_office, attorney_office, remote_ron, mobile_notary
- Participant tracking with confirmation status
- Rescheduling workflow with reason tracking
- Unique per application (one schedule per loan)

#### `disbursements`
- Fund disbursement tracking from loan proceeds
- Disbursement types: purchase_price, payoff_existing_loan, closing_costs, realtor_commission, cash_to_borrower
- Status tracking: scheduled → sent → confirmed → failed
- Links to wire_requests for wire transfers
- Ensures total disbursements equal loan amount + borrower funds

#### `post_closing_items`
- Post-closing trailing documents and tasks checklist
- Item types: recorded_deed, wet_ink_note, title_policy, trailing_condition, qc_review, servicing_boarding, investor_delivery
- Status tracking: pending → received → complete
- Due date tracking and document attachment
- Required items must be complete before final loan delivery
- Typical timeline: 0-90 days post-closing

**Note**: RLS policies for Phase 8B tables are **not yet configured**. Current access control is application-level only.

---

## Key Workflows

### New Application Workflow
1. **Loan Officer** creates application
   - Selects `loan_product`
   - Creates or selects `property`
   - Creates or selects `primary_customer`
2. **System** creates `application` record (status: draft)
3. **System** creates `application_customers` link (role: primary_borrower)
4. **Loan Officer** invites co-borrowers
   - Creates additional `customers`
   - Creates `application_customers` links
   - Generates `invitation_tokens`
5. **Borrower** completes profile
   - Adds `employments`, `incomes`, `assets`, `liabilities`
   - Completes `declarations`, `demographics`
   - Uploads `documents`
6. **Loan Officer** reviews and submits application
   - Changes status from `draft` to `submitted`
   - System logs `application_events`

### Document Review Workflow
1. **Borrower** uploads document
   - Creates record in `documents` (status: pending)
   - File stored in Supabase Storage bucket
2. **Processor** reviews document
   - Views document
   - Updates status to `approved` or `rejected`
   - If rejected, adds `rejection_reason`
3. **System** logs review
   - Sets `reviewed_by` and `reviewed_at`

---

## Schema Statistics

- **Total Tables**: 42 (24 original + 7 Phase 5B LO Portal + 5 Phase 7B Underwriter Portal + 6 Phase 8B Closer Portal; consents exists in Drizzle but not yet migrated)
- **RLS Enabled**: 23 tables (Phase 5B, 7B, and 8B tables do not have RLS configured yet; consents not yet migrated)
- **RLS Policies**: 115+ policies deployed across existing tables
- **RLS Helper Functions**: 5 security functions
- **Foreign Keys**: 75+ relationships
- **Indexes**: 60+ performance indexes (including 5 RLS-optimized, plus new indexes on Phase 5B, 7B, 8B tables)
- **Storage Buckets**: 2 (documents, borrower-documents)

---

## Technology Stack

- **Database**: PostgreSQL 15.8
- **Platform**: Supabase (managed PostgreSQL)
- **Extensions**:
  - `uuid-ossp`: UUID generation
  - `pgcrypto`: Encryption functions
  - `pgjwt`: JWT handling
  - `pgsodium`: Advanced encryption
  - `pg_graphql`: GraphQL API
- **Auth**: Supabase Auth (built-in)
- **Storage**: Supabase Storage (S3-compatible)
- **Realtime**: Supabase Realtime (WebSocket subscriptions)

---

## Future Enhancements

**Planned Features** (not yet in schema):
- Credit report integration tables
- Automated valuation model (AVM) results
- Third-party service integrations (e.g., Encompass sync)
- Pricing engine configuration
- Compliance checklist tracking
- E-signature integration

---

## Related Documentation

- [Schema Map](./01-schema-map.md) - Visual ER diagram
- [Table Documentation](./tables/) - Detailed table specifications
- [Agent Context](./agent-context.md) - AI-optimized reference

---

*This document is part of the Confer LOS Information as Code (IaC) repository. For questions or updates, submit a PR or contact the development team.*
