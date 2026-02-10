# Supabase Database Schema - AI Agent Context

**Token-Optimized Reference | LOS Database PostgreSQL 15.8**

---

## CORE ENTITIES (27 Tables)

### organizations
PK: id (uuid)
Cols: name, slug UK, settings (jsonb), billing_status, stripe_customer_id
Purpose: Multi-tenant root entity

### users
PK: id (uuid, FK→auth.users)
Cols: organization_id FK, role, first_name, last_name, email, phone, system_admin
RLS: users.id = auth.uid()
Purpose: Internal staff (loan officers, processors, underwriters)

### customers
PK: id (uuid)
Cols: organization_id FK, auth_user_id FK→auth.users, customer_type, first_name, last_name, company_name, email, phone*, addresses (jsonb), ssn_encrypted, date_of_birth, citizenship_type, marital_status, dependent_count
RLS: customers.auth_user_id = auth.uid()
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
Status: draft→submitted→in_review→in_underwriting→conditional_approval→clear_to_close→funded
RLS: Borrowers see own apps, users see org apps
Purpose: Loan application central entity

### application_customers
PK: id (uuid)
Cols: application_id FK, customer_id FK, organization_id FK, created_by FK→users, role, sequence, ownership_percentage, will_occupy_property, will_be_on_title, credit_type, invite_status, invited_at, accepted_at, econsent_given, econsent_given_at, econsent_ip_address
Roles: primary_borrower, co_borrower, guarantor
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
Direction: inbound, outbound
Channel: email, sms, call, portal
Purpose: Communication log

### tasks
PK: id (uuid)
Cols: organization_id FK, application_id FK, customer_id FK, assignee_id FK→users, created_by FK→users, title, description, status, priority, due_date, completed_at
Status: open, completed
Priority: low, medium, high
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

## KEY RELATIONSHIPS

```
organizations
  ├─► users (1:M)
  ├─► customers (1:M)
  ├─► loan_products (1:M)
  ├─► properties (1:M)
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
      ├─► communications (1:M)
      ├─► tasks (1:M)
      ├─► notes (1:M)
      └─► application_events (1:M)
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

All 27 tables have RLS enabled.

**Key Policies**:
- Borrower Portal: customers.auth_user_id = auth.uid()
- Borrower Apps: application_customers.customer_id IN (SELECT id FROM customers WHERE auth_user_id = auth.uid())
- Internal Users: organization_id = auth.current_user_organization_id()
- Storage: borrower-documents bucket filtered by auth.uid()

**Security Functions**:
- auth.current_user_organization_id() → uuid
- auth.get_user_role() → text

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

**END CONTEXT**
