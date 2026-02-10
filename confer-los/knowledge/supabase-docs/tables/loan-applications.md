# Loan Applications Tables

**Category**: Loan Application Core
**Tables**: `loan_products`, `properties`, `applications`, `application_events`

---

## Table: `loan_products`

**Purpose**: Product templates defining loan types offered by the organization (30-year fixed, ARM, FHA, VA, etc.)

### Key Columns
- `id`, `organization_id`, `name`, `product_type`
- `country_code` - US, CA, etc.
- `customer_type` - consumer, commercial
- `template` (jsonb) - Product configuration, pricing rules, qualification criteria
- `is_active` - Whether product is available for new applications

### Example Template Structure
```json
{
  "interest_rate": 6.5,
  "term_months": 360,
  "amortization_type": "fixed",
  "min_credit_score": 620,
  "max_ltv": 80,
  "product_features": ["no_prepayment_penalty", "assumable"]
}
```

### Business Logic
- Each organization can have multiple loan products
- Template structure is flexible (jsonb) to accommodate various product types
- Product selection drives application requirements and workflow

---

## Table: `properties`

**Purpose**: Subject properties for loan applications. Stores property address and characteristics.

### Key Columns
- `id`, `organization_id`
- `address` (jsonb) - Structured address
- `country_code`, `property_type`
- `year_built`, `square_feet`, `bedrooms`, `bathrooms`
- `appraised_value`, `purchase_price`
- `metadata` (jsonb) - Additional property details (parcel #, HOA, etc.)

### Address Structure
```json
{
  "street": "123 Main St",
  "unit": "Suite 100",
  "city": "San Francisco",
  "state": "CA",
  "zip_code": "94102",
  "county": "San Francisco",
  "country": "US"
}
```

### Property Types
- Single Family, Condo, Townhouse, Multi-Family (2-4 units), Manufactured/Mobile Home

---

## Table: `applications`

**Purpose**: Core application entity. Central hub connecting customer, property, loan product, and all application data.

### Key Columns

| Column | Type | Description |
|--------|------|-------------|
| `id` | uuid | Primary key |
| `organization_id` | uuid | FK to organizations |
| `property_id` | uuid | FK to properties (subject property) |
| `loan_product_id` | uuid | FK to loan_products |
| `primary_customer_id` | uuid | FK to customers (primary borrower) |
| `assigned_to` | uuid | FK to users (loan officer) |
| `title` | text | Application title/name |
| `application_number` | text | Unique identifier (UNIQUE) |
| `loan_amount` | numeric | Requested loan amount |
| `occupancy_type` | text | Primary Residence, Second Home, Investment |
| `status` | text | Workflow status (see below) |
| `stage` | text | Workflow stage (see below) |
| `key_information` | jsonb | Flexible application data |
| `decision_result` | jsonb | Underwriting decision details |
| `created_at`, `updated_at` | timestamp | Timestamps |
| `submitted_at`, `funded_at` | timestamp | Milestone timestamps |

### Application Status Values

| Status | Description |
|--------|-------------|
| `draft` | Being completed by borrower/LO |
| `submitted` | Submitted for processing |
| `in_review` | Being reviewed by processor |
| `in_underwriting` | With underwriter |
| `conditional_approval` | Approved with conditions |
| `clear_to_close` | All conditions met |
| `funded` | Loan funded |
| `denied` | Application denied |
| `withdrawn` | Withdrawn by borrower |
| `suspended` | On hold |

### Application Stage Values

| Stage | Description |
|-------|-------------|
| `application` | Initial application entry |
| `processing` | Document collection, verification |
| `underwriting` | Credit review, risk assessment |
| `closing` | Final approval, closing preparation |
| `funded` | Loan closed and funded |

### RLS Policies
- Borrowers can view applications where they are primary_customer or linked via application_customers
- Borrowers can update draft applications only
- Internal users can view/update applications in their organization

### Business Logic
- **Application Number**: Auto-generated, format: `ORG-YYYYMMDD-NNNN`
- **Primary Customer**: Required, represents the main borrower
- **Assigned To**: Loan officer responsible for the application
- **Status vs. Stage**: Status is granular, Stage is high-level grouping
- **Key Information**: Stores calculated values like DTI, LTV, CLTV

---

## Table: `application_events`

**Purpose**: Audit trail of all application changes. Tracks who changed what and when.

### Key Columns
- `id`, `application_id`, `organization_id`, `user_id`
- `event_type` - Type of event (see below)
- `from_status`, `to_status` - Status changes
- `from_stage`, `to_stage` - Stage changes
- `source` - UI, API, automation, etc.
- `metadata` (jsonb) - Event-specific details
- `created_at` - Event timestamp

### Event Types
- `status_change` - Application status changed
- `stage_change` - Application stage changed
- `assignment_change` - Loan officer assignment changed
- `document_uploaded` - Document added
- `communication_sent` - Email/SMS sent
- `note_added` - Note created
- `decision_made` - Underwriting decision
- `condition_added` - Condition requested
- `condition_cleared` - Condition satisfied

### Usage Pattern
```sql
-- Log status change
INSERT INTO application_events (
  application_id, organization_id, user_id,
  event_type, from_status, to_status, source, metadata
) VALUES (
  'app-uuid', 'org-uuid', auth.uid(),
  'status_change', 'draft', 'submitted',
  'ui', '{"ip_address": "1.2.3.4"}'::jsonb
);
```

### Common Query: Application Timeline
```sql
SELECT
  ae.event_type,
  ae.from_status || ' → ' || ae.to_status as change,
  u.first_name || ' ' || u.last_name as changed_by,
  ae.created_at
FROM application_events ae
LEFT JOIN users u ON ae.user_id = u.id
WHERE ae.application_id = 'app-uuid'
ORDER BY ae.created_at DESC;
```

---

## Application Lifecycle Flow

```mermaid
stateDiagram-v2
    [*] --> draft
    draft --> submitted: Borrower submits
    submitted --> in_review: Processor accepts
    in_review --> in_underwriting: Docs complete
    in_underwriting --> conditional_approval: Approved with conditions
    in_underwriting --> denied: Denied
    conditional_approval --> clear_to_close: Conditions met
    clear_to_close --> funded: Loan closed

    draft --> withdrawn: Borrower withdraws
    submitted --> withdrawn
    in_review --> withdrawn
    in_underwriting --> withdrawn
    conditional_approval --> withdrawn

    in_review --> suspended: On hold
    in_underwriting --> suspended
    suspended --> in_review: Resumed
    suspended --> in_underwriting

    funded --> [*]
    denied --> [*]
    withdrawn --> [*]
```

---

## Common Queries

### Get applications by status
```sql
SELECT
  a.*,
  c.first_name || ' ' || c.last_name as borrower_name,
  p.address->>'street' as property_address
FROM applications a
JOIN customers c ON a.primary_customer_id = c.id
LEFT JOIN properties p ON a.property_id = p.id
WHERE a.organization_id = auth.current_user_organization_id()
  AND a.status = 'in_underwriting'
ORDER BY a.updated_at DESC;
```

### Get assigned applications for current user
```sql
SELECT *
FROM applications
WHERE assigned_to = auth.uid()
  AND status NOT IN ('funded', 'denied', 'withdrawn')
ORDER BY updated_at DESC;
```

### Calculate application metrics
```sql
SELECT
  status,
  COUNT(*) as count,
  AVG(loan_amount) as avg_loan_amount,
  MAX(updated_at) as last_updated
FROM applications
WHERE organization_id = auth.current_user_organization_id()
  AND created_at >= now() - interval '30 days'
GROUP BY status;
```

---

*See also: [customers-and-portal.md](./customers-and-portal.md) for borrower linking*
