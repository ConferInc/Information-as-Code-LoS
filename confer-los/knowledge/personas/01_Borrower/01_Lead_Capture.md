---
type: screen-schema
persona: Borrower (Applicant)
screen: Lead Capture & Pre-Qualification
stage: 1-2
system: Public Website / MoXi Homepage
generated: 2026-02-13
source_stubs:
  - modular/01_Borrower/01_Lead_Capture.md
source_sops:
  - Moxi_Master_SOP_Part1.md (Section 2, 15m-30m)
---

# 01 — Lead Capture & Pre-Qualification

## 1. UI Component Map

### Stage 1: External Lead Generation (MoXi Homepage)

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Browser Navigation | Address Bar | — | — | — | `bing.com` |
| Search Query | Text Input | string | — | — | `"financing in mexico for us citizens"` |
| MoXi Website Link | Hyperlink | URL | — | — | Global Mortgage (MoXi) Homepage |
| **[Get Pre-Qualified Today]** | CTA Button | — | — | — | Opens Pre-Qual Modal |

### Stage 1.3: Lead Capture Form ("Let's Explore Your Options")

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| First Name | Text Input | string | YES | Non-empty, alpha characters | — |
| Last Name | Text Input | string | YES | Non-empty, alpha characters | — |
| Email Address | Text Input | string (email) | YES | RFC 5322 email format | — |
| Phone Number | Text Input | string (phone) | YES | US phone format (10 digits) | — |
| How did you hear about us? | Radio Group | enum | YES | Single selection required | — |
| Are You a US Citizen? | Radio Group | boolean | YES | Yes/No | — |
| When Do You Need Financing? | Radio Group | enum | YES | Single selection required | — |
| Is Your Property Value at least $550K? | Radio Group | boolean | YES | Yes/No | — |
| I agree to messages... (Consent) | Checkbox | boolean | YES | Must be checked to submit | `false` |
| **[Submit]** | Button | — | — | All fields valid | — |

### Stage 2: Verification & Acknowledgement

| Field / Element | Component Type | Data Type | Required | Validation Rules | Default Value |
|---|---|---|---|---|---|
| Confirmation Screen | Static Page | — | — | Displays "WAIT! CHECK YOUR EMAIL" | — |
| Verification Email | Email Link | URL | YES | Subject: "Final step confirm here" | — |
| **[Click To Confirm]** | Email CTA Button | — | YES | Validates email ownership | — |

---

## 2. Database Mapping

### Existing Schema Mappings

| UI Field | Supabase Table | Column | Type | Notes |
|---|---|---|---|---|
| First Name | `customers` | `first_name` | text | Direct mapping |
| Last Name | `customers` | `last_name` | text | Direct mapping |
| Email Address | `customers` | `email` | text | Unique per org; used for portal login |
| Phone Number | `customers` | `phone` | text | Used for SMS consent |
| Are You a US Citizen? | `customers` | `citizenship_status` | text | Maps to URLA Section 1a; store as enum value |
| Consent Checkbox | `customers` | `e_consent_status` | text | Maps to opt-in consent tracking |
| Portal Access | `customers` | `portal_access_enabled` | boolean | Set to `true` after email verification |
| Created By (system) | `customers` | `created_by` | uuid | References the system/auto-creation user |
| Email Verification | `invitation_tokens` | `token`, `status` | text, enum | Token sent via email; status updated on click |

### 🔴 Schema Change Proposals (Missing Mappings)

| UI Field | Proposed Table | Proposed Column | Type | Rationale |
|---|---|---|---|---|
| How did you hear about us? | `customers` | `lead_source` | text (enum) | No lead source tracking exists. URLA does not require this but CRM integration (Salesforce/Jungo) depends on it. Values: `online_website`, `referral`, `social_media`, `event`, `other`. |
| When Do You Need Financing? | `customers` | `financing_timeline` | text (enum) | No timeline field exists. Values: `immediately`, `next_3_months`, `next_6_months`, `next_12_months`, `just_exploring`. |
| Is Property Value >= $550K? | `customers` | `pre_qual_property_threshold` | boolean | MoXi-specific qualification gate. $550K minimum is a business rule, not regulatory. |
| SMS Consent Opt-In | `customers` | `sms_consent` | boolean | Separate from `e_consent_status`. TCPA requires explicit SMS consent tracking with timestamp. |
| SMS Consent Timestamp | `customers` | `sms_consent_at` | timestamptz | TCPA audit trail for when SMS consent was granted. |
| Email Verified | `customers` | `email_verified` | boolean | Currently no field tracks whether the confirmation link was clicked. |
| Email Verified At | `customers` | `email_verified_at` | timestamptz | Timestamp of email verification for audit. |

#### Proposed Column Additions to `customers` Table

```sql
ALTER TABLE customers
  ADD COLUMN lead_source text,
  ADD COLUMN financing_timeline text,
  ADD COLUMN pre_qual_property_threshold boolean DEFAULT false,
  ADD COLUMN sms_consent boolean DEFAULT false,
  ADD COLUMN sms_consent_at timestamptz,
  ADD COLUMN email_verified boolean DEFAULT false,
  ADD COLUMN email_verified_at timestamptz;

COMMENT ON COLUMN customers.lead_source IS 'Lead acquisition channel. Values: online_website, referral, social_media, event, other';
COMMENT ON COLUMN customers.financing_timeline IS 'Self-reported financing urgency. Values: immediately, next_3_months, next_6_months, next_12_months, just_exploring';
COMMENT ON COLUMN customers.pre_qual_property_threshold IS 'MoXi-specific: borrower confirmed property value >= $550K';
COMMENT ON COLUMN customers.sms_consent IS 'TCPA-compliant SMS opt-in consent';
COMMENT ON COLUMN customers.sms_consent_at IS 'Timestamp of SMS consent for TCPA audit';
COMMENT ON COLUMN customers.email_verified IS 'Whether borrower clicked the email confirmation link';
COMMENT ON COLUMN customers.email_verified_at IS 'Timestamp of email verification';
```

---

## 3. Workflow & Triggers

### User Actions → System State Changes

| Step | Trigger (User Action) | Actor | System Action | State Change | Notification |
|---|---|---|---|---|---|
| 1.2.11 | Click **[Submit]** on lead form | Borrower | Create `customers` record; generate `invitation_tokens` row; fire email | `invitation_tokens.status` = `pending` | Email: "Final step confirm here" sent to borrower |
| 2.1.2 | Click **[Click To Confirm]** in email | Borrower | Validate token; update `customers.email_verified` = true; update `invitation_tokens.status` = `accepted` | `customers.portal_access_enabled` = `true` | Confirmation screen displays |
| — | Token expires (24h) | System | Set `invitation_tokens.status` = `expired` | Lead stale; no portal access | — |
| — | New lead created | System | Push to Salesforce/Jungo CRM via webhook | CRM record created (Stage: "Intro Message Sent") | Internal: Sales/MLO notified via CRM queue |

### Automation Rules

- **Auto-email**: On `customers` INSERT where `lead_source IS NOT NULL`, trigger verification email via Edge Function.
- **CRM Sync**: On successful email verification, push lead to Salesforce "Intro Call 1 - Needed Today" report queue.
- **Expiry Cleanup**: Cron job to expire `invitation_tokens` older than 24 hours where `status = 'pending'`.

---

## 4. Compliance Notes

| Regulation | Requirement | Current Status |
|---|---|---|
| **TCPA** | SMS consent must be explicitly captured with timestamp | 🔴 MISSING — `sms_consent` and `sms_consent_at` columns proposed |
| **CAN-SPAM** | Email opt-in must be tracked; unsubscribe mechanism required | 🟡 PARTIAL — `e_consent_status` exists but no unsubscribe tracking |
| **ECOA / Reg B** | Cannot discriminate based on national origin in pre-qualification | ✅ OK — "Are You a US Citizen?" is a product eligibility question, not discriminatory (MoXi requires US citizenship for cross-border lending) |
| **URLA Section 1a** | Citizenship status captured | ✅ OK — Maps to `customers.citizenship_status` |

---

## 5. MoXi-Specific Customizations

| Feature | Description | Isolation Strategy |
|---|---|---|
| $550K Property Threshold | MoXi minimum property value gate; not a US regulatory requirement | Store in `customers.pre_qual_property_threshold`; gate logic lives in application layer, not DB constraint |
| "Financing in Mexico" Lead Source | Borrowers explicitly searching for Mexico cross-border financing | `lead_source` enum includes general values; MoXi-specific filtering handled in CRM/reporting layer |
| US Citizen Requirement | MoXi requires US citizenship for cross-border Mexico loans | `citizenship_status` field is URLA-standard; the business rule enforcement is application-layer |
