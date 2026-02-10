---
type: documentation
category: database-schema
database: PostgreSQL 15.8 (Supabase)
last_updated: 2026-02-10
created_by: Claude Sonnet 4.5
tags: [database, supabase, postgresql, los, schema, documentation]
---

# Supabase Database Documentation

**Comprehensive database schema documentation for the Confer LOS (Loan Origination System)**

---

## 📚 Documentation Structure

This documentation is organized to serve **two audiences**:

1. **Human Developers** - Detailed, business-logic-focused documentation
2. **AI Agents** - Token-optimized, dense reference format

---

## 📖 For Humans: Start Here

### High-Level Overview
- **[Architecture Overview](./00-architecture-overview.md)** - Multi-tenancy, auth model, RLS policies, system design
- **[Schema Map](./01-schema-map.md)** - Visual ER diagram and relationship overview

### Detailed Table Documentation

Located in `./tables/`:

| File | Tables Covered | Description |
|------|----------------|-------------|
| [auth-and-users.md](./tables/auth-and-users.md) | `organizations`, `users` | Multi-tenant setup, internal user auth |
| [customers-and-portal.md](./tables/customers-and-portal.md) | `customers`, `application_customers`, `invitation_tokens` | Borrower profiles, portal access, multi-borrower support |
| [loan-applications.md](./tables/loan-applications.md) | `loan_products`, `properties`, `applications`, `application_events` | Core application entities, workflow, audit trail |
| [employment-and-income.md](./tables/employment-and-income.md) | `employments`, `incomes` | Employment history, income qualification |
| [assets-and-liabilities.md](./tables/assets-and-liabilities.md) | `assets`, `asset_ownership`, `gift_funds`, `liabilities`, `liability_ownership` | Financial profile, DTI calculation |
| [real-estate.md](./tables/real-estate.md) | `real_estate_owned`, `residences` | REO properties, residence history |
| [declarations-and-demographics.md](./tables/declarations-and-demographics.md) | `declarations`, `demographics` | URLA compliance, HMDA reporting |
| [documents-and-communications.md](./tables/documents-and-communications.md) | `documents`, `communications` | Document management, communication log |
| [workflow-management.md](./tables/workflow-management.md) | `tasks`, `notes` | Task management, internal notes |

---

## 🤖 For AI Agents: Quick Reference

**[agent-context.md](./agent-context.md)** - Token-optimized database schema reference

This file contains:
- All 27 tables in condensed format
- Key relationships and foreign keys
- RLS policies summary
- Common query patterns
- JSONB structures
- Enum values
- Workflow patterns

**Use this file** when you need to:
- Feed database context to an AI agent
- Minimize token usage in prompts
- Get a quick reference without reading full docs

---

## 🗂️ Database Statistics

- **Database**: PostgreSQL 15.8 (Supabase-managed)
- **Total Public Tables**: 27
- **RLS Enabled**: All 27 tables
- **Foreign Key Relationships**: 50+
- **Indexes**: 30+
- **Custom Types**: 0 (uses text-based enums)
- **Storage Buckets**: 2 (`documents`, `borrower-documents`)

---

## 🏗️ Schema Design Principles

### 1. Multi-Tenancy
- Every table has `organization_id` foreign key
- RLS policies enforce organization-based isolation
- Shared Supabase infrastructure (auth, storage, realtime)

### 2. URLA 1003 Compliance
Schema mirrors the Uniform Residential Loan Application:
- Section I: Borrower Information → `customers`, `residences`
- Section II: Financial Information → `employments`, `incomes`, `assets`, `liabilities`
- Section III: Loan and Property Information → `applications`, `properties`
- Section IV: Declarations → `declarations`
- Section V: Demographics → `demographics`

### 3. Multi-Borrower Support
- `application_customers` junction table links multiple borrowers to one application
- Financial data (income, assets, liabilities) linked to both customer AND application
- Asset/liability ownership tables support joint accounts

### 4. Audit Trail
- `application_events` logs every status change, assignment, and milestone
- Immutable records (never updated or deleted)
- Supports regulatory compliance and dispute resolution

### 5. Document Management
- Metadata stored in `documents` table
- Actual files in Supabase Storage with RLS policies
- Review workflow (pending → approved/rejected)

---

## 🔐 Security & Access Control

### RLS (Row-Level Security)

**All 27 tables have RLS enabled.** Key policies:

**Borrower Portal**:
- Borrowers can only view/update their own customer record (`customers.auth_user_id = auth.uid()`)
- Borrowers can view applications where they are linked (`application_customers`)
- Borrowers can upload/view documents for their applications only

**Internal Users**:
- Users can only access data within their organization (`organization_id = auth.current_user_organization_id()`)
- Future: Role-based restrictions (loan officer vs. underwriter access)

**System Admins**:
- Can access cross-organization data (for Confer platform administration)

### Auth Functions

```sql
-- Get current user's organization
SELECT auth.current_user_organization_id(); -- Returns: uuid

-- Get current user's role
SELECT auth.get_user_role(); -- Returns: text (role name)
```

---

## 📊 Common Business Logic

### DTI (Debt-to-Income) Calculation
```sql
WITH income AS (
  SELECT SUM(monthly_amount) as total FROM incomes
  WHERE application_id = ? AND include_in_qualification = true
),
debt AS (
  SELECT SUM(monthly_payment) as total FROM liabilities
  WHERE application_id = ? AND exclude_from_dti = false
)
SELECT (debt.total / income.total * 100) as dti_ratio
FROM income, debt;
```

### Application Progress Tracking
```sql
SELECT
  COUNT(*) as total_tasks,
  SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_tasks,
  ROUND(100.0 * SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) / COUNT(*), 1) as progress_pct
FROM tasks
WHERE application_id = ?;
```

### Asset Verification Status
```sql
SELECT
  asset_category,
  COUNT(*) as total,
  SUM(CASE WHEN verification_status = 'verified' THEN 1 ELSE 0 END) as verified,
  SUM(cash_or_market_value) as total_value,
  SUM(verified_value) as verified_value
FROM assets
WHERE application_id = ?
GROUP BY asset_category;
```

---

## 🚀 Quick Start for AI Agents

**To get started with database queries:**

1. **Read** [agent-context.md](./agent-context.md) for complete schema overview
2. **Reference** specific table docs in `./tables/` for business logic details
3. **Use** RLS helper functions: `auth.uid()`, `auth.current_user_organization_id()`, `auth.get_user_role()`
4. **Remember** all tables have RLS enabled - queries must respect access policies

**Example Query Template**:
```sql
-- Get applications for current user's organization
SELECT a.*, c.first_name, c.last_name
FROM applications a
JOIN customers c ON a.primary_customer_id = c.id
WHERE a.organization_id = auth.current_user_organization_id()
  AND a.status = 'in_underwriting'
ORDER BY a.updated_at DESC;
```

---

## 🔄 Workflow Examples

### New Application Flow
1. Create/select customer → `customers`
2. Create application → `applications` (status: draft)
3. Link customer → `application_customers` (role: primary_borrower)
4. Add co-borrowers → `customers`, `application_customers`, `invitation_tokens`
5. Collect data → `employments`, `incomes`, `assets`, `liabilities`, etc.
6. Upload docs → `documents` (status: pending)
7. Submit → `applications.status = 'submitted'`, log `application_events`
8. Review → `documents.status = 'approved'`, create `tasks`
9. Underwrite → `applications.status = 'in_underwriting'`
10. Decision → `applications.decision_result`, log `application_events`
11. Close → `applications.status = 'funded'`

### Document Review Flow
1. Borrower uploads → `documents` (status: pending) + Supabase Storage
2. Processor reviews → View document from Storage
3. Approve/Reject → `documents.status`, `reviewed_by`, `reviewed_at`
4. If rejected → Borrower notified via `communications`, uploads new version

---

## 📝 Naming Conventions

### Tables
- Lowercase, plural nouns (`customers`, `applications`, `incomes`)
- Junction tables: `{table1}_{table2}` (`application_customers`, `asset_ownership`)

### Columns
- Lowercase, snake_case (`first_name`, `loan_amount`, `econsent_given_at`)
- Foreign keys: `{table_singular}_id` (`customer_id`, `application_id`)
- Timestamps: `{action}_at` (`created_at`, `submitted_at`, `funded_at`)
- Booleans: `is_{condition}`, `has_{thing}`, `will_{action}` (`is_active`, `has_mortgage`, `will_occupy_property`)

### Enums (Text-Based)
- Lowercase, snake_case values (`primary_borrower`, `in_underwriting`, `clear_to_close`)
- No native PostgreSQL ENUMs used (for flexibility)

---

## 🛠️ Maintenance & Updates

### When to Update This Documentation

- **Schema changes**: Add/remove tables, columns, or relationships
- **New RLS policies**: Security policy changes
- **Business logic changes**: New workflow states, validation rules
- **New integrations**: External services, APIs

### How to Update

1. Update the relevant table documentation file in `./tables/`
2. Update [agent-context.md](./agent-context.md) with condensed changes
3. Update [01-schema-map.md](./01-schema-map.md) if relationships changed
4. Update this README if major structural changes
5. Commit with descriptive message following IaC guidelines

---

## 📚 Related Documentation

- **Source Schema**: [../../../schema/schema.sql](../../../schema/schema.sql)
- **Supabase Dashboard**: [app.supabase.com](https://app.supabase.com)
- **URLA 1003 Form**: [Fannie Mae URLA](https://singlefamily.fanniemae.com/originating-underwriting/mortgage-products/uniform-residential-loan-application-urla)
- **HMDA Reporting**: [CFPB HMDA](https://www.consumerfinance.gov/data-research/hmda/)

---

## ✅ Checklist: Using This Documentation

- [ ] Read [00-architecture-overview.md](./00-architecture-overview.md) for system understanding
- [ ] Review [01-schema-map.md](./01-schema-map.md) for visual relationships
- [ ] Explore relevant table docs in `./tables/` for specific domains
- [ ] Use [agent-context.md](./agent-context.md) as quick reference
- [ ] Test RLS policies in Supabase SQL Editor before deploying
- [ ] Update documentation when schema changes

---

## 🤝 Contributing

This documentation is part of the **Confer LOS Information as Code (IaC)** repository.

**To improve this documentation**:
1. Make changes to the relevant files
2. Test any code examples
3. Update the `last_updated` date in frontmatter
4. Commit with a clear message: `docs: Update {table} documentation with {change}`
5. Push to repository

**Documentation Standards**:
- Use Markdown for all files
- Include YAML frontmatter
- Provide executable code examples
- Link to related documentation
- Keep [agent-context.md](./agent-context.md) in sync with detailed docs

---

*Last Updated: 2026-02-10*
*Generated by: Claude Sonnet 4.5*
*Repository: confer-los*
