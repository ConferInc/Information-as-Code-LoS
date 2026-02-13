# Supabase Database Schema Map

**Visual Entity Relationship Diagram**
**Last Updated**: 2026-02-13

---

## Complete ER Diagram

This diagram shows all tables in the `public` schema and their relationships. For better readability, the diagram is split into logical sections below.

```mermaid
erDiagram
    %% Core System
    organizations ||--o{ users : "has"
    organizations ||--o{ customers : "has"
    organizations ||--o{ loan_products : "has"
    organizations ||--o{ properties : "has"
    organizations ||--o{ applications : "has"

    %% Application Core
    loan_products ||--o{ applications : "defines product for"
    properties ||--o| applications : "subject property for"
    customers ||--o| applications : "primary customer for"
    users ||--o{ applications : "assigned to"

    applications ||--o{ application_customers : "has borrowers"
    customers ||--o{ application_customers : "linked to applications"
    application_customers ||--o{ invitation_tokens : "has invites"

    %% Employment & Income
    customers ||--o{ employments : "has employment history"
    applications ||--o{ employments : "documented in"
    employments ||--o{ incomes : "generates income"
    customers ||--o{ incomes : "earns"
    applications ||--o{ incomes : "documented in"

    %% Assets
    applications ||--o{ assets : "has assets"
    assets ||--o{ asset_ownership : "owned by"
    customers ||--o{ asset_ownership : "owns assets"
    applications ||--o{ gift_funds : "has gifts"
    customers ||--o{ gift_funds : "receives gifts"
    documents ||--o| gift_funds : "documented by letter"

    %% Liabilities
    applications ||--o{ liabilities : "has debts"
    liabilities ||--o{ liability_ownership : "owned by"
    customers ||--o{ liability_ownership : "owes debts"

    %% Real Estate
    customers ||--o{ real_estate_owned : "owns properties"
    applications ||--o{ real_estate_owned : "documented in"
    customers ||--o{ residences : "lived at"
    applications ||--o{ residences : "documented in"

    %% Declarations & Demographics
    customers ||--o{ declarations : "made declarations"
    applications ||--o{ declarations : "documented in"
    customers ||--o{ demographics : "has demographics"
    applications ||--o{ demographics : "documented in"

    %% Documents & Communication
    applications ||--o{ documents : "has documents"
    customers ||--o{ documents : "uploaded by"
    users ||--o{ documents : "uploaded by staff"
    users ||--o{ documents : "reviewed by"

    applications ||--o{ communications : "has communications"
    customers ||--o{ communications : "communicated with"
    users ||--o{ communications : "initiated by"

    %% Workflow
    applications ||--o{ tasks : "has tasks"
    customers ||--o{ tasks : "relates to"
    users ||--o{ tasks : "assigned to"
    users ||--o{ tasks : "created by"

    applications ||--o{ notes : "has notes"
    customers ||--o{ notes : "relates to"
    users ||--o{ notes : "authored by"

    applications ||--o{ application_events : "has events"
    users ||--o{ application_events : "triggered by"

    %% Sales & Lead Management (Phase 5B)
    organizations ||--o{ leads : "has"
    organizations ||--o{ pipeline_stages : "has"
    organizations ||--o{ lead_sources : "has"
    organizations ||--o{ communication_templates : "has"
    users ||--o{ leads : "assigned to"
    users ||--o{ notification_preferences : "has"
    leads ||--o{ lead_activities : "has"
    leads ||--o{ quick_quotes : "has"
    leads ||--o| applications : "converts to"
    leads ||--o| customers : "converts to"
    applications ||--o{ quick_quotes : "has"
    applications ||--o| pipeline_stages : "in stage"
    communications ||--o| communication_templates : "uses"

    %% Underwriter Portal (Phase 7B)
    organizations ||--o{ uw_decisions : "has"
    organizations ||--o{ risk_assessments : "has"
    organizations ||--o{ exception_requests : "has"
    organizations ||--o{ condition_templates : "has"
    organizations ||--o{ ctc_clearances : "has"
    applications ||--o{ uw_decisions : "has decisions"
    applications ||--o{ risk_assessments : "has assessments"
    applications ||--o{ exception_requests : "has exceptions"
    applications ||--o| ctc_clearances : "has clearance"
    users ||--o{ uw_decisions : "decided by"
    users ||--o{ risk_assessments : "assessed by"
    users ||--o{ exception_requests : "requested by"
    users ||--o{ exception_requests : "reviewed by"
    users ||--o{ condition_templates : "created by"
    users ||--o{ ctc_clearances : "issued by"

    %% Closer Portal (Phase 8B)
    organizations ||--o{ closing_packages : "has"
    organizations ||--o{ wire_requests : "has"
    organizations ||--o{ cd_revisions : "has"
    organizations ||--o{ closing_schedules : "has"
    organizations ||--o{ disbursements : "has"
    organizations ||--o{ post_closing_items : "has"
    applications ||--o| closing_packages : "has package"
    applications ||--o{ wire_requests : "has wires"
    applications ||--o{ cd_revisions : "has CDs"
    applications ||--o| closing_schedules : "has schedule"
    applications ||--o{ disbursements : "has disbursements"
    applications ||--o{ post_closing_items : "has trailing items"
    users ||--o{ closing_packages : "delivered by"
    users ||--o{ wire_requests : "requested by"
    users ||--o{ wire_requests : "approved by"
    users ||--o{ cd_revisions : "created by"
    users ||--o{ closing_schedules : "created by"
    users ||--o{ post_closing_items : "received by"
    documents ||--o| closing_packages : "generated package"
    documents ||--o| wire_requests : "wire instructions"
    documents ||--o| wire_requests : "confirmation"
    documents ||--o| cd_revisions : "CD document"
    documents ||--o| post_closing_items : "supporting doc"

    %% Table Definitions

    organizations {
        uuid id PK
        text name
        text slug UK
        jsonb settings
        text billing_status
        text stripe_customer_id
        timestamp created_at
        timestamp updated_at
    }

    users {
        uuid id PK "FK to auth.users"
        uuid organization_id FK
        text role
        text first_name
        text last_name
        text email
        text phone
        text avatar_url
        jsonb metadata
        boolean system_admin
        text nmls_number
        text bio
        boolean is_manager
        jsonb working_hours
        timestamp last_lead_assigned_at
        timestamp created_at
        timestamp updated_at
    }

    customers {
        uuid id PK
        uuid organization_id FK
        uuid auth_user_id FK "FK to auth.users"
        uuid portal_user_id
        text customer_type
        text first_name
        text last_name
        text middle_name
        text suffix
        text company_name
        text email
        text phone
        text phone_home
        text phone_cell
        text phone_work
        text phone_work_ext
        jsonb addresses
        text ssn_encrypted
        date date_of_birth
        text citizenship_type
        text marital_status
        integer dependent_count
        text dependent_ages
        jsonb alternate_names
        jsonb key_information
        timestamp created_at
        timestamp updated_at
    }

    loan_products {
        uuid id PK
        uuid organization_id FK
        text name
        text product_type
        text country_code
        text customer_type
        jsonb template
        boolean is_active
        timestamp created_at
        timestamp updated_at
    }

    properties {
        uuid id PK
        uuid organization_id FK
        jsonb address
        text country_code
        text property_type
        integer year_built
        integer square_feet
        integer bedrooms
        numeric bathrooms
        numeric appraised_value
        numeric purchase_price
        jsonb metadata
        timestamp created_at
        timestamp updated_at
    }

    applications {
        uuid id PK
        uuid organization_id FK
        uuid property_id FK
        uuid loan_product_id FK
        uuid primary_customer_id FK
        uuid assigned_to FK
        text title
        text application_number UK
        numeric loan_amount
        text occupancy_type
        text status
        text stage
        jsonb key_information
        jsonb decision_result
        uuid pipeline_stage_id FK
        timestamp stage_entered_at
        uuid lead_id FK
        timestamp estimated_closing_date
        uuid loan_officer_id FK
        uuid processor_id FK
        text source
        text processing_status
        timestamp processing_started_at
        timestamp submitted_to_uw_at
        uuid submitted_to_uw_by FK
        integer credit_score_experian
        integer credit_score_equifax
        integer credit_score_transunion
        integer representative_credit_score
        timestamp credit_pulled_at
        numeric appraisal_value
        timestamp appraisal_date
        text uw_decision
        timestamp uw_decision_date
        uuid uw_decision_by FK
        text rate_lock_status
        timestamp rate_lock_expiration
        numeric rate_lock_rate
        timestamp rate_lock_date
        text aus_recommendation
        jsonb aus_findings
        text aus_type
        timestamp aus_run_at
        numeric ltv
        numeric dti
        timestamp target_closing_date
        text submission_notes
        timestamp created_at
        timestamp updated_at
        timestamp submitted_at
        timestamp funded_at
    }

    application_customers {
        uuid id PK
        uuid application_id FK
        uuid customer_id FK
        uuid organization_id FK
        uuid created_by FK
        text role
        integer sequence
        numeric ownership_percentage
        boolean will_occupy_property
        boolean will_be_on_title
        text credit_type
        text invite_status
        timestamp invited_at
        timestamp accepted_at
        boolean econsent_given
        timestamp econsent_given_at
        text econsent_ip_address
        timestamp created_at
    }

    invitation_tokens {
        uuid id PK
        uuid application_customer_id FK
        text token UK
        timestamp expires_at
        timestamp used_at
        timestamp created_at
        timestamp updated_at
    }

    employments {
        uuid id PK
        uuid organization_id FK
        uuid customer_id FK
        uuid application_id FK
        text employment_type
        boolean is_current
        text employer_name
        text employer_phone
        text employer_street_address
        text employer_unit
        text employer_city
        text employer_state
        text employer_zip_code
        text position_title
        date start_date
        date end_date
        integer years_in_profession
        integer months_in_profession
        boolean is_self_employed
        text ownership_percentage
        numeric self_employed_monthly_income
        boolean is_employed_by_family
        boolean is_party_to_transaction
        timestamp created_at
        timestamp updated_at
    }

    incomes {
        uuid id PK
        uuid organization_id FK
        uuid customer_id FK
        uuid application_id FK
        uuid employment_id FK
        text income_source
        text income_type
        numeric monthly_amount
        boolean include_in_qualification
        text verification_status
        numeric verified_amount
        text description
        timestamp created_at
        timestamp updated_at
    }

    assets {
        uuid id PK
        uuid organization_id FK
        uuid application_id FK
        text asset_category
        text asset_type
        text institution_name
        text account_number
        numeric cash_or_market_value
        boolean is_gift_or_grant
        text gift_type
        text gift_source
        text gift_deposited_status
        text verification_status
        numeric verified_value
        text description
        timestamp created_at
        timestamp updated_at
    }

    asset_ownership {
        uuid asset_id FK
        uuid customer_id FK
        numeric ownership_percentage
        text ownership_role
    }

    gift_funds {
        uuid id PK
        uuid organization_id FK
        uuid application_id FK
        uuid customer_id FK
        uuid gift_letter_document_id FK
        text donor_name
        text donor_relationship
        numeric gift_amount
        date gift_date
        boolean gift_letter_received
        boolean deposited
        date deposit_date
        text deposit_account
        timestamp created_at
        timestamp updated_at
    }

    liabilities {
        uuid id PK
        uuid organization_id FK
        uuid application_id FK
        text liability_type
        text creditor_name
        text account_number
        numeric unpaid_balance
        numeric monthly_payment
        integer months_remaining
        boolean to_be_paid_off_at_closing
        boolean will_be_subordinated
        boolean exclude_from_dti
        text exclusion_reason
        text description
        timestamp created_at
        timestamp updated_at
    }

    liability_ownership {
        uuid liability_id FK
        uuid customer_id FK
        text ownership_role
        boolean is_excluded
        text exclusion_reason
    }

    real_estate_owned {
        uuid id PK
        uuid organization_id FK
        uuid customer_id FK
        uuid application_id FK
        text property_street_address
        text property_unit
        text property_city
        text property_state
        text property_zip_code
        text property_country
        text property_type
        numeric property_value
        text property_status
        text intended_occupancy
        numeric monthly_insurance_taxes_hoa
        boolean has_mortgage
        text mortgage_creditor_name
        text mortgage_account_number
        numeric mortgage_monthly_payment
        numeric mortgage_unpaid_balance
        boolean mortgage_to_be_paid_off
        text mortgage_type
        boolean has_heloc
        numeric heloc_credit_limit
        numeric heloc_balance
        boolean is_rental
        numeric monthly_rental_income
        numeric net_rental_income
        timestamp created_at
        timestamp updated_at
    }

    residences {
        uuid id PK
        uuid organization_id FK
        uuid customer_id FK
        uuid application_id FK
        text residence_type
        text street_address
        text unit_number
        text city
        text state
        text zip_code
        text country
        date move_in_date
        date move_out_date
        integer years_at_address
        integer months_at_address
        text housing_type
        numeric monthly_rent
        boolean is_mailing_address
        timestamp created_at
        timestamp updated_at
    }

    declarations {
        uuid id PK
        uuid organization_id FK
        uuid customer_id FK
        uuid application_id FK
        boolean will_occupy_as_primary
        boolean have_ownership_interest_last_3_years
        text property_type_if_owned
        text title_holding_method
        boolean is_family_relationship_with_seller
        boolean have_undisclosed_borrowed_funds
        numeric undisclosed_borrowed_amount
        boolean have_undisclosed_mortgage_application
        boolean have_undisclosed_credit_application
        boolean have_priority_liens
        boolean have_cosigned_obligations
        boolean have_outstanding_judgments
        boolean are_delinquent_on_federal_debt
        boolean is_party_to_lawsuit
        boolean have_deed_in_lieu
        boolean have_short_sale
        boolean have_foreclosure
        boolean have_bankruptcy
        jsonb bankruptcy_chapter
        jsonb explanations
        timestamp created_at
        timestamp updated_at
    }

    demographics {
        uuid id PK
        uuid organization_id FK
        uuid customer_id FK
        uuid application_id FK
        text collection_method
        boolean declined_to_provide
        jsonb ethnicity
        text ethnicity_other_description
        jsonb race
        text race_tribe_name
        text race_other_asian
        text race_other_pacific_islander
        text sex
        jsonb observed_ethnicity
        jsonb observed_race
        text observed_sex
        timestamp created_at
        timestamp updated_at
    }

    documents {
        uuid id PK
        uuid organization_id FK
        uuid application_id FK
        uuid customer_id FK
        uuid uploaded_by FK
        uuid reviewed_by FK
        text document_type
        text file_name
        text file_path
        integer file_size
        text mime_type
        text status
        timestamp reviewed_at
        text rejection_reason
        date period_start
        date period_end
        integer year
        timestamp created_at
        timestamp updated_at
    }

    communications {
        uuid id PK
        uuid organization_id FK
        uuid application_id FK
        uuid customer_id FK
        uuid initiated_by FK
        text communication_type
        text direction
        text channel
        text subject
        text content
        text external_id
        jsonb metadata
        uuid lead_id FK
        uuid template_id FK
        timestamp read_at
        uuid thread_id
        text sender_role
        text recipient_role
        text visibility
        text processing_comm_type
        timestamp created_at
    }

    tasks {
        uuid id PK
        uuid organization_id FK
        uuid application_id FK
        uuid customer_id FK
        uuid assignee_id FK
        uuid created_by FK
        text title
        text description
        text status
        text priority
        timestamp due_date
        timestamp completed_at
        uuid lead_id FK
        text task_type
        boolean auto_generated
        text task_category
        text source_type
        text related_entity_type
        uuid related_entity_id
        timestamp reminder_sent_at
        timestamp created_at
    }

    notes {
        uuid id PK
        uuid organization_id FK
        uuid application_id FK
        uuid customer_id FK
        uuid author_id FK
        text content
        timestamp created_at
    }

    application_events {
        uuid id PK
        uuid application_id FK
        uuid organization_id FK
        uuid user_id FK
        text event_type
        text from_status
        text to_status
        text from_stage
        text to_stage
        text source
        jsonb metadata
        timestamp created_at
    }

    leads {
        uuid id PK
        uuid organization_id FK
        text first_name
        text middle_name
        text last_name
        text email
        text phone
        text phone_secondary
        text status
        text source
        text source_detail
        uuid assigned_to FK
        integer score
        text loan_purpose
        numeric estimated_loan_amount
        numeric estimated_purchase_price
        numeric estimated_down_payment
        text property_type
        text property_state
        text property_city
        text occupancy_type
        text credit_score_range
        numeric annual_income
        boolean is_self_employed
        boolean is_first_time_buyer
        boolean is_veteran
        boolean has_realtor
        text realtor_name
        text realtor_phone
        text realtor_email
        text preferred_contact_method
        text preferred_contact_time
        text disposition_reason
        text disposition_notes
        uuid converted_application_id FK
        uuid converted_customer_id FK
        timestamp last_contacted_at
        timestamp next_follow_up_at
        text notes
        jsonb metadata
        timestamp created_at
        timestamp updated_at
        uuid created_by FK
    }

    lead_activities {
        uuid id PK
        uuid organization_id FK
        uuid lead_id FK
        text activity_type
        text description
        text from_status
        text to_status
        jsonb metadata
        uuid created_by FK
        timestamp created_at
    }

    pipeline_stages {
        uuid id PK
        uuid organization_id FK
        text name
        text slug UK
        text description
        integer sort_order
        text color
        integer sla_days
        boolean is_terminal
        boolean is_active
        jsonb prerequisites
        timestamp created_at
        timestamp updated_at
    }

    lead_sources {
        uuid id PK
        uuid organization_id FK
        text name
        text category
        boolean is_active
        numeric cost_per_lead
        jsonb metadata
        timestamp created_at
    }

    quick_quotes {
        uuid id PK
        uuid organization_id FK
        uuid lead_id FK
        uuid application_id FK
        uuid created_by FK
        text loan_purpose
        numeric purchase_price
        numeric loan_amount
        numeric down_payment
        numeric down_payment_pct
        text property_type
        text occupancy_type
        text credit_score_range
        text property_state
        integer loan_term_months
        numeric interest_rate
        numeric monthly_pi
        numeric monthly_taxes
        numeric monthly_insurance
        numeric monthly_mi
        numeric monthly_hoa
        numeric monthly_total
        numeric ltv
        numeric dti
        numeric borrower_annual_income
        numeric borrower_monthly_debts
        text scenario_name
        uuid loan_product_id FK
        boolean prequal_letter_generated
        jsonb metadata
        timestamp created_at
        timestamp updated_at
    }

    notification_preferences {
        uuid id PK
        uuid user_id FK UK
        jsonb preferences
        timestamp updated_at
    }

    communication_templates {
        uuid id PK
        uuid organization_id FK
        text name
        text category
        text subject
        text body
        jsonb merge_fields
        boolean is_active
        uuid created_by FK
        timestamp created_at
        timestamp updated_at
    }

    uw_decisions {
        uuid id PK
        uuid organization_id FK
        uuid application_id FK
        text decision_type
        timestamp decision_date
        uuid decided_by FK
        jsonb rationale_factors
        text rationale_notes
        text approval_conditions_summary
        text suspension_reason
        text suspension_notes
        text denial_reason_primary
        text denial_reason_detail
        boolean denial_adverse_action_required
        numeric counter_offer_loan_amount
        text counter_offer_terms
        text counter_offer_explanation
        jsonb decision_result
        text uw_signature
        timestamp created_at
        timestamp updated_at
    }

    risk_assessments {
        uuid id PK
        uuid organization_id FK
        uuid application_id FK
        uuid assessed_by FK
        numeric gross_monthly_income
        numeric proposed_total_piti
        numeric recurring_debts_monthly
        numeric front_end_dti
        numeric back_end_dti
        numeric dti_guideline
        numeric dti_override
        text dti_override_reason
        numeric loan_amount
        numeric purchase_price
        numeric appraised_value
        numeric value_used_for_ltv
        numeric subordinate_financing
        numeric ltv
        numeric cltv
        numeric down_payment_amount
        numeric down_payment_percent
        numeric ltv_guideline
        numeric ltv_override
        text ltv_override_reason
        numeric total_verified_liquid_assets
        numeric retirement_assets
        numeric retirement_assets_discounted
        numeric total_assets_for_reserves
        numeric funds_to_close
        numeric remaining_assets
        numeric reserves_months
        numeric reserves_guideline
        numeric reserves_override
        text reserves_override_reason
        integer credit_score_used
        integer credit_score_guideline
        timestamp credit_pulled_at
        timestamp credit_expires_at
        integer credit_score_override
        text credit_score_override_reason
        numeric loan_to_income_ratio
        boolean compensating_factor_reserves
        boolean compensating_factor_housing_increase
        boolean compensating_factor_down_payment
        boolean compensating_factor_credit
        boolean compensating_factor_employment
        boolean compensating_factor_earnings_potential
        boolean compensating_factor_tax_benefits
        boolean compensating_factor_homeownership_education
        text compensating_factor_notes
        integer compensating_factor_count
        integer total_tradelines
        integer open_tradelines
        integer total_inquiries_90d
        integer unmatched_inquiries
        integer total_derogatory_items
        numeric payment_history_ontime_pct
        integer late_30d_12mo
        integer late_60d_24mo
        integer late_90plus_24mo
        integer collections_unpaid_count
        numeric collections_unpaid_total
        integer chargeoffs_count
        integer public_records_count
        jsonb assessment_data
        timestamp created_at
        timestamp updated_at
    }

    exception_requests {
        uuid id PK
        uuid organization_id FK
        uuid application_id FK
        text guideline_exceeded
        numeric standard_limit
        numeric actual_value
        numeric variance_amount
        numeric variance_percent
        text justification
        jsonb compensating_factors
        uuid requested_by FK
        timestamp requested_at
        text status
        uuid reviewed_by FK
        timestamp reviewed_at
        text approval_notes
        text denial_reason
        jsonb metadata
        timestamp created_at
        timestamp updated_at
    }

    condition_templates {
        uuid id PK
        uuid organization_id FK
        text title
        text description
        text condition_type
        text category
        text priority
        integer default_due_date_days
        boolean is_active
        integer usage_count
        uuid created_by FK
        timestamp created_at
        timestamp updated_at
    }

    ctc_clearances {
        uuid id PK
        uuid organization_id FK
        uuid application_id FK UK
        boolean ptd_conditions_cleared
        boolean ptf_conditions_cleared
        boolean credit_current
        boolean voe_final_completed
        boolean appraisal_current
        boolean title_received
        boolean insurance_binder
        boolean cd_prepared
        boolean no_adverse_changes
        boolean closing_scheduled
        boolean funds_verified
        boolean all_items_checked
        timestamp ctc_issued_at
        uuid ctc_issued_by FK
        text ctc_final_notes
        jsonb checklist_data
        timestamp created_at
        timestamp updated_at
    }

    closing_packages {
        uuid id PK
        uuid organization_id FK
        uuid application_id FK UK
        text status
        integer completeness_percentage
        jsonb document_checklist
        text closing_instructions
        uuid generated_package_document_id FK
        timestamp delivered_at
        uuid delivered_by FK
        text delivery_method
        timestamp created_at
        timestamp updated_at
    }

    wire_requests {
        uuid id PK
        uuid organization_id FK
        uuid application_id FK
        text status
        text recipient_type
        numeric amount
        date funding_date
        text bank_name
        text routing_number
        text account_number
        text account_type
        text beneficiary_name
        text beneficiary_address
        uuid wire_instructions_document_id FK
        boolean phone_verification_completed
        timestamp phone_verification_date
        uuid phone_verification_by FK
        text phone_verification_bank_rep
        uuid requested_by FK
        timestamp requested_at
        uuid approved_by FK
        timestamp approved_at
        uuid second_approved_by FK
        timestamp second_approved_at
        text rejection_reason
        timestamp sent_date
        text wire_reference_number
        timestamp confirmed_date
        uuid confirmation_document_id FK
        text notes
        jsonb metadata
        timestamp updated_at
    }

    cd_revisions {
        uuid id PK
        uuid organization_id FK
        uuid application_id FK
        integer version_number
        text status
        timestamp issued_date
        text delivery_method
        timestamp three_day_wait_expires_at
        timestamp viewed_date
        timestamp signed_date
        timestamp acknowledged_date
        text revision_reason
        text revision_notes
        boolean resets_three_day_wait
        text tolerance_status
        uuid cd_document_id FK
        jsonb changed_circumstances
        uuid created_by FK
        timestamp created_at
        timestamp updated_at
    }

    closing_schedules {
        uuid id PK
        uuid organization_id FK
        uuid application_id FK UK
        date scheduled_date
        time scheduled_time
        integer duration_minutes
        text location_type
        text location_address
        text closing_type
        jsonb participants
        text agenda_notes
        timestamp rescheduled_from
        text reschedule_reason
        text reschedule_reason_notes
        timestamp closing_completed_at
        uuid created_by FK
        timestamp created_at
        timestamp updated_at
    }

    disbursements {
        uuid id PK
        uuid organization_id FK
        uuid application_id FK
        text disbursement_type
        text recipient_name
        numeric amount
        text status
        timestamp scheduled_date
        timestamp sent_date
        timestamp confirmed_date
        text notes
        timestamp created_at
    }

    post_closing_items {
        uuid id PK
        uuid organization_id FK
        uuid application_id FK
        text item_type
        text item_name
        text description
        boolean required
        text status
        date due_date
        date received_date
        uuid received_by FK
        uuid document_id FK
        text notes
        timestamp created_at
        timestamp updated_at
    }
```

---

## Diagram Legend

- **PK**: Primary Key
- **FK**: Foreign Key
- **UK**: Unique Key
- **||--o{**: One-to-many relationship
- **||--o|**: One-to-zero-or-one relationship
- **||--||**: One-to-one relationship

---

## Table Categories

### 🏢 Core System (2 tables)
- `organizations` - Multi-tenant organizations
- `users` - Internal staff users

### 👥 Customer Management (3 tables)
- `customers` - Borrower profiles
- `application_customers` - Application-borrower junction
- `invitation_tokens` - Co-borrower invitations

### 🏠 Loan Application Core (4 tables)
- `loan_products` - Product definitions
- `properties` - Subject properties
- `applications` - Loan applications
- `application_events` - Audit trail

### 💼 Employment & Income (2 tables)
- `employments` - Employment history
- `incomes` - Income sources

### 💰 Assets & Liabilities (5 tables)
- `assets` - Financial assets
- `asset_ownership` - Asset ownership junction
- `gift_funds` - Gift tracking
- `liabilities` - Debts
- `liability_ownership` - Liability ownership junction

### 🏡 Real Estate (2 tables)
- `real_estate_owned` - Borrower-owned properties
- `residences` - Residence history

### 📋 Compliance (2 tables)
- `declarations` - URLA declarations
- `demographics` - HMDA demographics

### 📄 Documents & Communication (2 tables)
- `documents` - Document management
- `communications` - Communication log

### ✅ Workflow Management (2 tables)
- `tasks` - Task tracking
- `notes` - Notes and comments

### 🎯 Sales & Lead Management - Phase 5B (7 tables)
- `leads` - Pre-application lead tracking
- `lead_activities` - Lead interaction audit trail
- `pipeline_stages` - Customizable workflow stages
- `lead_sources` - Lead source tracking for ROI
- `quick_quotes` - Scenario modeling and pre-quals
- `notification_preferences` - User notification settings
- `communication_templates` - Reusable templates

### 🔍 Underwriter Portal - Phase 7B (5 tables)
- `uw_decisions` - Underwriting decisions (approve/deny/suspend/counter-offer)
- `risk_assessments` - DTI, LTV, reserves, credit analysis, compensating factors
- `exception_requests` - Guideline exception requests with approval workflow
- `condition_templates` - Reusable condition templates
- `ctc_clearances` - Clear-to-close checklists

### 🏁 Closer Portal - Phase 8B (6 tables)
- `closing_packages` - Closing document package management
- `wire_requests` - Wire transfer management with fraud prevention
- `cd_revisions` - Closing Disclosure version history
- `closing_schedules` - Closing appointment scheduling
- `disbursements` - Fund disbursement tracking
- `post_closing_items` - Post-closing trailing document checklist

---

## Common Query Patterns

### Get all borrowers for an application
```sql
SELECT c.*
FROM customers c
JOIN application_customers ac ON c.id = ac.customer_id
WHERE ac.application_id = 'app-uuid-here'
ORDER BY ac.sequence;
```

### Get total monthly income for a customer
```sql
SELECT
  customer_id,
  SUM(monthly_amount) as total_income
FROM incomes
WHERE customer_id = 'cust-uuid-here'
  AND application_id = 'app-uuid-here'
  AND include_in_qualification = true
GROUP BY customer_id;
```

### Get all assets owned by a customer
```sql
SELECT a.*, ao.ownership_percentage
FROM assets a
JOIN asset_ownership ao ON a.id = ao.asset_id
WHERE ao.customer_id = 'cust-uuid-here'
  AND a.application_id = 'app-uuid-here';
```

### Get application timeline
```sql
SELECT
  event_type,
  from_status,
  to_status,
  u.first_name || ' ' || u.last_name as changed_by,
  created_at
FROM application_events ae
LEFT JOIN users u ON ae.user_id = u.id
WHERE ae.application_id = 'app-uuid-here'
ORDER BY created_at DESC;
```

---

## Next Steps

For detailed table specifications and business logic, see:
- [Table Documentation](./tables/) - Individual table documentation by category
- [Agent Context](./agent-context.md) - Token-optimized AI reference

---

*This diagram is auto-generated from the schema. Last updated: 2026-02-13*
