# Supabase Database Schema - AI Agent Context

**Token-Optimized Reference | LOS Database PostgreSQL 15.8**

---

## CORE ENTITIES (31 Tables — 24 original + 7 Phase 5B LO Portal)

### organizations
PK: id (uuid)
Cols: name, slug UK, settings (jsonb), billing_status, stripe_customer_id
Purpose: Multi-tenant root entity

### users
PK: id (uuid, FK→auth.users)
Cols: organization_id FK, role, first_name, last_name, email, phone, system_admin, nmls_number, bio, is_manager, working_hours (jsonb), last_lead_assigned_at
RLS: 3 policies — system_admin_all, staff_manage (org-scoped + role check), staff_view (org-scoped)
Purpose: Internal staff (loan officers, processors, underwriters)
**Phase 5B**: Added nmls_number, bio, is_manager (for team management), working_hours (for scheduling), last_lead_assigned_at (for round-robin)

### customers
PK: id (uuid)
Cols: organization_id FK, auth_user_id FK→auth.users, customer_type, first_name, last_name, company_name, email, phone*, addresses (jsonb), ssn_encrypted, date_of_birth, citizenship_type, marital_status, dependent_count
RLS: 5 policies — system_admin_all, staff_manage, staff_view, borrower_view_own (auth_user_id = auth.uid()), borrower_update_own
Index: idx_customers_auth_user_id
Purpose: Borrowers/applicants with optional portal access

### loan_products
PK: id (uuid)
Cols: organization_id FK, name, product_type, country_code, template (jsonb), is_active
Purpose: Loan product definitions

### properties
PK: id (uuid)
Cols: organization_id FK, address (jsonb), property_type, year_built, square_feet, bedrooms, bathrooms, appraised_value, purchase_price
Purpose: Subject properties

### applications
PK: id (uuid)
Cols: organization_id FK, property_id FK, loan_product_id FK, primary_customer_id FK, assigned_to FK→users, application_number UK, title, loan_amount, occupancy_type, status, stage, key_information (jsonb), decision_result (jsonb), submitted_at, funded_at
**Phase 5B New Cols**: pipeline_stage_id FK→pipeline_stages, stage_entered_at, lead_id FK→leads, estimated_closing_date, loan_officer_id FK→users, processor_id FK→users, source (lo_created|borrower_portal|lead_conversion|api), processing_status, processing_started_at, submitted_to_uw_at, submitted_to_uw_by FK, credit_score_*, credit_pulled_at, appraisal_value, appraisal_date, uw_decision, uw_decision_date, uw_decision_by FK, rate_lock_*, aus_*, ltv, dti, target_closing_date, submission_notes
Status: draft→submitted→in_review→processing→underwriting→clear_to_close→closing_scheduled→funded
Stage (legacy enum): prequal→application→submitted→processing→underwriting→conditional→clear_to_close→closing→funded
**Note**: pipeline_stage_id (custom per org) vs stage (default enum) — apps can use either
RLS: 8 policies — system_admin_all, staff_manage, staff_view, borrower_view_own_apps (via get_borrower_application_ids()), borrower_update_own_draft (draft/in_progress only), anon_create_draft, anon_update_own_draft, anon_view_own_draft (via key_information->>'_authUserId')
Indexes: idx_applications_primary_customer_id, idx_applications_key_info_auth_user, idx_applications_processor_idx, idx_applications_processing_status_idx
Purpose: Loan application central entity

### application_customers
PK: id (uuid)
Cols: application_id FK, customer_id FK, organization_id FK, created_by FK→users, role, sequence, ownership_percentage, will_occupy_property, will_be_on_title, credit_type, invite_status, invited_at, accepted_at, econsent_given, econsent_given_at, econsent_ip_address
Roles: primary_borrower, co_borrower, guarantor
RLS: 5 policies — system_admin_all, staff_manage, staff_view, borrower_view_own (customer_id IN get_auth_customer_ids() OR application_id IN get_borrower_application_ids()), borrower_insert_own
Indexes: idx_application_customers_application_id, idx_application_customers_customer_id
Purpose: M:N junction linking customers to applications

### invitation_tokens
PK: id (uuid)
Cols: application_customer_id FK, token UK, expires_at, used_at
Purpose: Secure co-borrower invite tokens

### employments
PK: id (uuid)
Cols: organization_id FK, customer_id FK, application_id FK, employment_type, is_current, employer_name, employer_phone, employer_address*, position_title, start_date, end_date, years/months_in_profession, is_self_employed, ownership_percentage, self_employed_monthly_income
Purpose: Employment history

### incomes
PK: id (uuid)
Cols: organization_id FK, customer_id FK, application_id FK, employment_id FK, income_source, income_type, monthly_amount, include_in_qualification, verification_status, verified_amount
Purpose: Income sources (employment, self-employment, other)

### assets
PK: id (uuid)
Cols: organization_id FK, application_id FK, asset_category, asset_type, institution_name, account_number, cash_or_market_value, is_gift_or_grant, gift_type, verification_status, verified_value
Rels: M:N to customers via asset_ownership
Purpose: Financial assets (checking, savings, investments)

### asset_ownership
Cols: asset_id FK, customer_id FK, ownership_percentage, ownership_role
Purpose: Links assets to customers (for joint accounts)

### gift_funds
PK: id (uuid)
Cols: organization_id FK, application_id FK, customer_id FK, gift_letter_document_id FK→documents, donor_name, donor_relationship, gift_amount, gift_date, gift_letter_received, deposited, deposit_date
Purpose: Gift fund tracking

### liabilities
PK: id (uuid)
Cols: organization_id FK, application_id FK, liability_type, creditor_name, account_number, unpaid_balance, monthly_payment, months_remaining, to_be_paid_off_at_closing, exclude_from_dti, exclusion_reason
Rels: M:N to customers via liability_ownership
Purpose: Debts (mortgage, auto, credit card, student loan)

### liability_ownership
Cols: liability_id FK, customer_id FK, ownership_role, is_excluded, exclusion_reason
Roles: primary_obligor, co_signer
Purpose: Links liabilities to customers

### real_estate_owned
PK: id (uuid)
Cols: organization_id FK, customer_id FK, application_id FK, property_address*, property_type, property_value, property_status, intended_occupancy, monthly_insurance_taxes_hoa, has_mortgage, mortgage_*, has_heloc, heloc_*, is_rental, monthly_rental_income, net_rental_income
Purpose: Borrower-owned real estate

### residences
PK: id (uuid)
Cols: organization_id FK, customer_id FK, application_id FK, residence_type, street_address, city, state, zip_code, move_in_date, move_out_date, years/months_at_address, housing_type, monthly_rent, is_mailing_address
Purpose: Residence history (current + 2 years)

### declarations
PK: id (uuid)
Cols: organization_id FK, customer_id FK, application_id FK, will_occupy_as_primary, have_ownership_interest_last_3_years, is_family_relationship_with_seller, have_undisclosed_borrowed_funds, have_priority_liens, have_outstanding_judgments, have_foreclosure, have_bankruptcy, bankruptcy_chapter (jsonb), explanations (jsonb)
Purpose: URLA Section IV declarations

### demographics
PK: id (uuid)
Cols: organization_id FK, customer_id FK, application_id FK, collection_method, declined_to_provide, ethnicity (jsonb), race (jsonb), sex, observed_*
Purpose: HMDA demographic data

### documents
PK: id (uuid)
Cols: organization_id FK, application_id FK, customer_id FK, uploaded_by FK→users, reviewed_by FK→users, document_type, file_name, file_path, file_size, mime_type, status, reviewed_at, rejection_reason, period_start, period_end, year
Status: pending, approved, rejected
Purpose: Document management + review workflow

### communications
PK: id (uuid)
Cols: organization_id FK, application_id FK, customer_id FK, initiated_by FK→users, communication_type, direction, channel, subject, content, external_id, metadata (jsonb)
**Phase 5B New Cols**: lead_id FK→leads, template_id FK→communication_templates, read_at, thread_id, sender_role, recipient_role, visibility (all|staff_only|processor_uw), processing_comm_type (message|document_request|status_update|condition_notice)
Direction: inbound, outbound
Channel: email, sms, call, portal
Purpose: Communication log

### tasks
PK: id (uuid)
Cols: organization_id FK, application_id FK, customer_id FK, assignee_id FK→users, created_by FK→users, title, description, status, priority, due_date (timestamp, was date), completed_at
**Phase 5B New Cols**: lead_id FK→leads, task_type (follow_up|document_request|review|closing_prep|general), auto_generated, task_category, source_type (manual|system|agent), related_entity_type (condition|service_order|document|verification), related_entity_id, reminder_sent_at
Status: open, in_progress, completed, cancelled
Priority: low, medium, high, urgent
Purpose: Task management

### notes
PK: id (uuid)
Cols: organization_id FK, application_id FK, customer_id FK, author_id FK→users, content
Purpose: Notes and comments

### application_events
PK: id (uuid)
Cols: application_id FK, organization_id FK, user_id FK→users, event_type, from_status, to_status, from_stage, to_stage, source, metadata (jsonb)
Event Types: status_change, assignment_change, document_uploaded, decision_made
Purpose: Audit trail

---

## PHASE 5B: SALES & LEAD MANAGEMENT (7 Tables)

### leads
PK: id (uuid)
Cols: organization_id FK, first_name, middle_name, last_name, email, phone, phone_secondary, status, source, source_detail, assigned_to FK→users, score (integer), loan_purpose, estimated_loan_amount, estimated_purchase_price, estimated_down_payment, property_type, property_state, property_city, occupancy_type, credit_score_range, annual_income, is_self_employed, is_first_time_buyer, is_veteran, has_realtor, realtor_*, preferred_contact_method, preferred_contact_time, disposition_reason, disposition_notes, converted_application_id FK, converted_customer_id FK, last_contacted_at, next_follow_up_at, notes, metadata (jsonb), created_at, updated_at, created_by FK
Status: new, contacted, qualifying, qualified, quoted, application_started, nurturing, disqualified, lost, converted
Source: web, phone, referral, walk_in, builder, realtor, marketing, purchase_list, social_media, other
Indexes: leads_org_status_idx, leads_org_assigned_idx, leads_org_email_idx, leads_org_phone_idx, leads_org_score_idx, leads_org_created_idx
RLS: **Not configured yet**
Purpose: Pre-application contact management with lead scoring and conversion tracking

### lead_activities
PK: id (uuid)
Cols: organization_id FK, lead_id FK (cascade delete), activity_type, description, from_status, to_status, metadata (jsonb), created_by FK→users, created_at
Activity Types: created, status_changed, assigned, reassigned, note_added, call_logged, email_sent, email_received, sms_sent, quote_generated, prequal_letter_sent, converted_to_application, imported, score_updated, follow_up_scheduled
Index: lead_activities_lead_time_idx (lead_id, created_at)
RLS: **Not configured yet**
Purpose: Complete audit trail of lead interactions

### pipeline_stages
PK: id (uuid)
Cols: organization_id FK, name, slug UK (per org), description, sort_order (integer), color (default '#6B7280'), sla_days (integer), is_terminal (boolean, default false), is_active (boolean, default true), prerequisites (jsonb array), created_at, updated_at
Indexes: pipeline_stages_org_order_idx (org, sort_order), pipeline_stages_org_slug_idx (org, slug) UNIQUE
RLS: **Not configured yet**
Purpose: Customizable workflow stages per organization; applications.pipeline_stage_id references this OR uses default applications.stage enum

### lead_sources
PK: id (uuid)
Cols: organization_id FK, name, category, is_active (default true), cost_per_lead (numeric), metadata (jsonb), created_at
Category: web, phone, referral, walk_in, builder, realtor, marketing, purchase_list, social_media, other
RLS: **Not configured yet**
Purpose: Lead source tracking for ROI analysis

### quick_quotes
PK: id (uuid)
Cols: organization_id FK, lead_id FK→leads (nullable), application_id FK→applications (nullable), created_by FK→users, loan_purpose, purchase_price, loan_amount, down_payment, down_payment_pct, property_type, occupancy_type, credit_score_range, property_state, loan_term_months (default 360), interest_rate, monthly_pi, monthly_taxes, monthly_insurance, monthly_mi, monthly_hoa, monthly_total, ltv, dti, borrower_annual_income, borrower_monthly_debts, scenario_name, loan_product_id FK, prequal_letter_generated (default false), metadata (jsonb), created_at, updated_at
Indexes: quick_quotes_lead_idx, quick_quotes_app_idx, quick_quotes_created_by_idx (created_by, created_at)
RLS: **Not configured yet**
Purpose: Scenario modeling for leads (pre-application) or applications (in-process); supports multiple quotes per lead/app

### notification_preferences
PK: id (uuid)
Cols: user_id FK→users (UNIQUE), preferences (jsonb, default {}, shape: Record<string, {email: boolean, inApp: boolean}>), updated_at
RLS: **Not configured yet**
Purpose: Per-user notification settings for lead assignment, document requests, status updates, etc.

### communication_templates
PK: id (uuid)
Cols: organization_id FK, name, category, subject, body, merge_fields (jsonb string array), is_active (default true), created_by FK→users, created_at, updated_at
Category: welcome, document_request, status_update, follow_up, closing, general
RLS: **Not configured yet**
Purpose: Reusable email/SMS templates per organization; linked via communications.template_id

---

## KEY RELATIONSHIPS

```
organizations
  ├─► users (1:M)
  ├─► customers (1:M)
  ├─► loan_products (1:M)
  ├─► properties (1:M)
  ├─► pipeline_stages (1:M) — Phase 5B
  ├─► lead_sources (1:M) — Phase 5B
  ├─► communication_templates (1:M) — Phase 5B
  ├─► leads (1:M) — Phase 5B
  │   ├─► lead_activities (1:M)
  │   ├─► quick_quotes (1:M)
  │   ├─► communications (1:M)
  │   ├─► tasks (1:M)
  │   └─┬─► applications (converts to)
  │     └─► customers (converts to)
  └─► applications (1:M)
      ├─► application_customers (1:M) ─► customers
      ├─► employments (1:M) ─► customers
      ├─► incomes (1:M) ─► customers
      ├─► assets (1:M) ─┬─► asset_ownership ─► customers
      │                 └─► gift_funds
      ├─► liabilities (1:M) ─► liability_ownership ─► customers
      ├─► real_estate_owned (1:M) ─► customers
      ├─► residences (1:M) ─► customers
      ├─► declarations (1:M) ─► customers
      ├─► demographics (1:M) ─► customers
      ├─► documents (1:M)
      ├─► communications (1:M) ─► communication_templates
      ├─► tasks (1:M)
      ├─► notes (1:M)
      ├─► quick_quotes (1:M) — Phase 5B
      ├─► pipeline_stages (M:1) — Phase 5B
      └─► application_events (1:M)

users ←1:1→ notification_preferences — Phase 5B
```

---

## AUTH MODEL

**Internal Users (Staff)**
- auth.users ←1:1→ public.users (via id)
- Access: organization_id scoped
- Roles: admin, loan_officer, processor, underwriter

**External Users (Borrowers)**
- auth.users ←1:M→ public.customers (via auth_user_id)
- Access: own customer records + linked applications
- Portal RLS: customers.auth_user_id = auth.uid()

---

## RLS SUMMARY

**23 tables enabled** (consents not yet created) | **115 policies deployed**

### Helper Functions (5)
```sql
get_auth_org_id() → uuid              -- Staff user's organization_id
get_auth_role() → text                -- Staff user's role (NULL for borrowers)
auth.is_system_admin() → boolean      -- System admin flag (COALESCE false)
get_auth_customer_ids() → SETOF uuid  -- Customer IDs for auth.uid()
get_borrower_application_ids() → SETOF uuid -- App IDs where user is borrower/co-borrower/draft creator
```

All SECURITY DEFINER, STABLE, `SET search_path = public`

### Standard Policy Pattern (per table)
1. `system_admin_all` (FOR ALL) — bypass for system admins
2. `staff_manage` (FOR ALL) — org-scoped + role check
3. `staff_view` (FOR SELECT) — org-scoped, any staff
4. `borrower_view_own` (FOR SELECT) — scoped to borrower data
5. `borrower_manage_own` (INSERT/UPDATE) — borrower writes

### Scoping by Table Type
- **Customer-scoped**: `customer_id IN (SELECT get_auth_customer_ids())`
  - Tables: residences, employments, incomes, declarations, demographics, gift_funds, real_estate_owned
- **Application-scoped**: `application_id IN (SELECT get_borrower_application_ids())`
  - Tables: assets, liabilities, documents, communications, application_events
- **Junction tables**: Scoped via parent's application_id
  - Tables: asset_ownership, liability_ownership
- **Staff-only**: No borrower policies
  - Tables: tasks, notes
- **Public read**: All authenticated can SELECT
  - Tables: loan_products

### Special Rules
- **Applications**: Anonymous can INSERT drafts; borrowers can UPDATE draft/in_progress only
- **Documents**: Borrowers can SELECT/INSERT/UPDATE but NOT DELETE
- **Application Events**: Borrowers read-only (audit trail)
- **Consents** (pending): INSERT + SELECT only (immutability)

---

## COMMON PATTERNS

**Get app borrowers**:
```sql
SELECT c.* FROM customers c
JOIN application_customers ac ON c.id = ac.customer_id
WHERE ac.application_id = ? ORDER BY ac.sequence;
```

**Total income for customer**:
```sql
SELECT SUM(monthly_amount) FROM incomes
WHERE customer_id = ? AND application_id = ?
AND include_in_qualification = true;
```

**Assets owned by customer**:
```sql
SELECT a.* FROM assets a
JOIN asset_ownership ao ON a.id = ao.asset_id
WHERE ao.customer_id = ? AND a.application_id = ?;
```

**Application timeline**:
```sql
SELECT event_type, from_status, to_status, created_at
FROM application_events
WHERE application_id = ? ORDER BY created_at DESC;
```

---

## ENUMS (text-based, no native enums)

**Status**: draft, submitted, in_review, in_underwriting, conditional_approval, clear_to_close, funded, denied, withdrawn, suspended

**Stage**: application, processing, underwriting, closing, funded

**Role** (user): admin, loan_officer, processor, underwriter, closer, viewer

**Role** (application_customers): primary_borrower, co_borrower, guarantor, seller, authorized_signer

**Customer_type**: individual, business

**Employment_type**: current, previous, self_employed

**Income_source**: employment, self_employment, retirement, social_security, rental, investment

**Asset_category**: checking, savings, investment, retirement, stocks, bonds, mutual_funds

**Liability_type**: mortgage, auto_loan, credit_card, student_loan, personal_loan, alimony, child_support

**Document_type**: pay_stub, w2, tax_return, bank_statement, credit_report, appraisal, purchase_agreement

**Property_type**: single_family, condo, townhouse, multi_family_2_4, manufactured

**Occupancy_type**: primary_residence, second_home, investment

---

## JSONB STRUCTURES

**customers.addresses**:
```json
[{"type": "current", "street": "...", "city": "...", "state": "...", "zip_code": "...", "is_mailing": true}]
```

**loan_products.template**:
```json
{"interest_rate": 6.5, "term_months": 360, "min_credit_score": 620, "max_ltv": 80}
```

**declarations.bankruptcy_chapter**:
```json
{"chapter": "7", "year": 2020}
```

**declarations.explanations**:
```json
[{"question": "foreclosure", "explanation": "..."}]
```

**application_events.metadata**:
```json
{"ip_address": "1.2.3.4", "user_agent": "..."}
```

---

## INDEXES (Performance)

**Key Indexes**:
- applications_primary_customer_id_idx
- customers_auth_user_id_idx
- application_customers_application_id_idx
- employments_customer_application_idx
- incomes_customer_application_idx
- documents_application_id_idx
- application_events_application_id_idx

---

## TRIGGERS

- handle_new_user() → AFTER INSERT auth.users → Creates public.users record

---

## EXTENSIONS

- uuid-ossp (UUID generation)
- pgcrypto (encryption: ssn_encrypted uses pgp_sym_encrypt)
- pgjwt (JWT handling)
- pgsodium (advanced encryption)

---

## WORKFLOW: New Application

1. Create/select customer → customers
2. Create application → applications (status: draft)
3. Link customer → application_customers (role: primary_borrower)
4. Add co-borrowers → customers, application_customers, invitation_tokens
5. Collect data → employments, incomes, assets, liabilities, residences, declarations, demographics
6. Upload docs → documents (status: pending)
7. Submit → applications.status = 'submitted', application_events log
8. Review → documents.status = 'approved', tasks created
9. Underwrite → applications.status = 'in_underwriting'
10. Decision → applications.decision_result, application_events log
11. Close → applications.status = 'funded', funded_at timestamp

---

## PHASE 5B: LO PORTAL WORKFLOW

**Lead → Application Conversion**:
1. Lead created → leads (status: new)
2. Loan officer qualifies → lead_activities logged
3. Generate quick quotes → quick_quotes (linked to lead)
4. Convert to application → applications.lead_id set, lead.converted_application_id set, lead.status = 'converted'
5. Customer record created → customers, lead.converted_customer_id set

**Pipeline Stage Management**:
- **Custom stages**: organizations can define custom pipeline_stages with sort_order, SLA, colors
- **Default stage enum**: applications.stage (backward compatible)
- **Dual approach**: applications.pipeline_stage_id (custom) OR applications.stage (default enum)
- Server actions in `app/actions/org/` handle stage transitions

**Server Actions** (Phase 5B):
Located in `app/actions/org/`:
- Lead CRUD and assignment
- Lead activity logging
- Quick quote generation
- Pipeline stage management
- Notification preference updates
- Communication template management

**Important Distinctions**:
- `applications.stage` (enum) vs `applications.pipeline_stage_id` (FK to custom stages)
- `tasks.due_date` changed from `date` to `timestamp` (migration needed)
- RLS policies NOT YET CONFIGURED for Phase 5B tables (application-level auth only)

---

**END CONTEXT**
