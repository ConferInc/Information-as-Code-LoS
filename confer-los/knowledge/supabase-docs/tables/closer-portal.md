# Closer Portal Tables

**Category**: Closer Portal (Phase 8B)
**Tables**: `closing_packages`, `wire_requests`, `cd_revisions`, `closing_schedules`, `disbursements`, `post_closing_items`
**Last Updated**: 2026-02-13

---

## Table: `closing_packages`

**Purpose**: Manages the assembly and delivery of closing document packages. Tracks document checklist completeness and package delivery to title/escrow/closing agent.

### Key Columns
- `id` (uuid, PK)
- `organization_id` (uuid, FK → organizations)
- `application_id` (uuid, FK → applications, unique) - One package per application

### Status Tracking
- `status` (enum: `not_started`, `in_progress`, `complete`, `delivered`, default `not_started`)
- `completeness_percentage` (integer, default 0) - Calculated from checklist

### Document Checklist
- `document_checklist` (jsonb, default []) - Array of checklist items with structure:
  ```json
  {
    "documentType": "note",
    "documentName": "Promissory Note",
    "required": true,
    "status": "approved",
    "documentId": "uuid",
    "uploadedAt": "2026-02-13T10:00:00Z",
    "uploadedBy": "uuid",
    "notes": "Wet signature required"
  }
  ```
  - Status values: `not_uploaded`, `uploaded`, `reviewed`, `approved`

### Package Management
- `closing_instructions` (text) - Special instructions for closing agent
- `generated_package_document_id` (uuid, FK → documents) - Final merged PDF package

### Delivery Tracking
- `delivered_at` (timestamp)
- `delivered_by` (uuid, FK → users)
- `delivery_method` (enum: `email`, `portal_upload`, `sftp`, `physical_mail`, `courier`)

### Timestamps
- `created_at`, `updated_at`

### Indexes
1. `closing_packages_org_status_idx` on `organization_id`, `status`
2. `closing_packages_app_idx` on `application_id`

### Business Logic
- Each application has exactly one closing package (enforced by unique constraint)
- Completeness percentage auto-calculated from checklist item statuses
- Package cannot be delivered until all required items are approved
- Delivery triggers notification to closing agent

### Related Tables
- `applications` - Loan being packaged
- `documents` - Individual docs in checklist and final merged package
- `users` - Person who delivered package

---

## Table: `wire_requests`

**Purpose**: Wire transfer requests with fraud prevention measures. Manages wire instructions, dual approval workflow, phone verification, and confirmation tracking.

### Key Columns
- `id` (uuid, PK)
- `organization_id` (uuid, FK → organizations)
- `application_id` (uuid, FK → applications)

### Request Status
- `status` (enum, default `draft`)
  - `draft` - Being prepared
  - `submitted` - Submitted for approval
  - `pending_verification` - Awaiting phone verification
  - `approved` - Approved, ready to send
  - `rejected` - Rejected by approver
  - `sent` - Wire sent to bank
  - `confirmed` - Receipt confirmed
  - `cancelled` - Request cancelled

### Wire Details
- `recipient_type` (enum: `title_escrow`, `borrower`, `seller`, `other`)
- `amount` (numeric 12,2, required)
- `funding_date` (date, required)

### Banking Information
- `bank_name` (text, required)
- `routing_number` (text, required)
- `account_number` (text, required)
- `account_type` (enum: `checking`, `savings`, `escrow`, required)
- `beneficiary_name` (text, required)
- `beneficiary_address` (text, required)
- `wire_instructions_document_id` (uuid, FK → documents, required) - Scanned wire instructions from recipient

### Phone Verification (Anti-Fraud)
- `phone_verification_completed` (boolean, default false, required)
- `phone_verification_date` (timestamp)
- `phone_verification_by` (uuid, FK → users) - Who made verification call
- `phone_verification_bank_rep` (text) - Name of bank representative who confirmed account

### Approval Workflow
- `requested_by` (uuid, FK → users, required)
- `requested_at` (timestamp, default now)
- `approved_by` (uuid, FK → users) - First approver
- `approved_at` (timestamp)
- `second_approved_by` (uuid, FK → users) - Second approver (required for large amounts)
- `second_approved_at` (timestamp)
- `rejection_reason` (text)

### Wire Execution
- `sent_date` (timestamp) - When wire was sent
- `wire_reference_number` (text) - Bank reference/confirmation number
- `confirmed_date` (timestamp) - When receipt was confirmed
- `confirmation_document_id` (uuid, FK → documents) - Wire confirmation from bank

### Notes & Metadata
- `notes` (text)
- `metadata` (jsonb)
- `updated_at` (timestamp, default now)

### Indexes
1. `wire_requests_org_app_idx` on `organization_id`, `application_id`
2. `wire_requests_status_funding_idx` on `status`, `funding_date`

### Business Logic
- **Fraud Prevention**: Phone verification REQUIRED before wire can be sent
  - Closer must call the bank using independently verified phone number
  - Bank must confirm account details verbally
  - Name of bank rep must be documented
- **Dual Approval**: Wires above threshold require two approvals
- **Wire Instructions Document**: Scanned wire instructions must be uploaded
- **Confirmation Required**: Wire must be confirmed received before closing can complete
- Status progression: draft → submitted → pending_verification → approved → sent → confirmed

### Related Tables
- `applications` - Loan being funded
- `users` - Requester, approvers, verifier
- `documents` - Wire instructions and confirmation docs
- `disbursements` - Related fund disbursements

---

## Table: `cd_revisions`

**Purpose**: Version history of Closing Disclosures (CDs) including changed circumstances tracking, TRID tolerance monitoring, and three-day waiting period management.

### Key Columns
- `id` (uuid, PK)
- `organization_id` (uuid, FK → organizations)
- `application_id` (uuid, FK → applications)
- `version_number` (integer, required) - Incremental version (1, 2, 3...)

### Revision Status
- `status` (enum, default `draft`)
  - `draft` - Being prepared
  - `ready_to_issue` - Ready for delivery
  - `issued` - Delivered to borrower
  - `viewed` - Borrower viewed
  - `signed` - Borrower e-signed
  - `acknowledged` - Borrower acknowledged receipt
  - `superseded` - Replaced by newer version

### Issuance & Delivery
- `issued_date` (timestamp) - When CD was delivered
- `delivery_method` (enum: `esign`, `email`, `hand_delivered`, `mail`)
- `three_day_wait_expires_at` (timestamp) - TRID 3-day waiting period expiration
- `viewed_date` (timestamp)
- `signed_date` (timestamp)
- `acknowledged_date` (timestamp)

### Revision Tracking
- `revision_reason` (enum: `correction`, `changed_circumstance`, `borrower_request`, `other`)
- `revision_notes` (text)
- `resets_three_day_wait` (boolean, default false) - Whether revision resets waiting period

### TRID Tolerance Monitoring
- `tolerance_status` (enum: `pass`, `fail`, `changed_circumstance`)
  - `pass` - All costs within tolerance
  - `fail` - Costs exceed tolerance (lender must cure)
  - `changed_circumstance` - Tolerance waived due to documented changed circumstance

### Document Reference
- `cd_document_id` (uuid, FK → documents) - PDF of this CD version

### Changed Circumstances
- `changed_circumstances` (jsonb) - Array of changed circumstance documentation:
  ```json
  {
    "circumstanceType": "appraisal_higher_than_expected",
    "description": "Appraised value $50k higher, increased title insurance",
    "dateOccurred": "2026-02-10",
    "documentedBy": "uuid",
    "documentedAt": "2026-02-10T14:00:00Z",
    "affectedCosts": ["title_insurance", "recording_fees"]
  }
  ```

### Audit
- `created_by` (uuid, FK → users, required)
- `created_at`, `updated_at`

### Indexes
1. `cd_revisions_app_version_idx` on `application_id`, `version_number`
2. `cd_revisions_app_status_idx` on `application_id`, `status`

### Business Logic
- **TRID Compliance**: Initial CD starts 3-business-day waiting period before closing
- **Revision Triggers**: Certain changes require new CD and may reset waiting period
  - APR change > 0.125%: RESETS 3-day wait
  - Loan product change: RESETS 3-day wait
  - Prepayment penalty added: RESETS 3-day wait
  - Small cost increases: NO reset, but must re-disclose
- **Tolerance Monitoring**:
  - **Zero tolerance**: Fees that cannot increase (lender fees, transfer taxes)
  - **10% tolerance**: Fees that can increase up to 10% in aggregate (title, escrow, etc.)
  - **Unlimited tolerance**: Fees that can increase without limit (prepaid interest, per diem)
- **Version Control**: Each revision increments version_number
- **Superseded CDs**: When new CD issued, previous version marked `superseded`

### Related Tables
- `applications` - Loan being disclosed
- `documents` - PDF of each CD version
- `users` - Creator of revision
- `closing_schedules` - Closing date (must be after 3-day wait)

---

## Table: `closing_schedules`

**Purpose**: Closing appointment scheduling with participant tracking and rescheduling workflow. Coordinates in-person closings, remote online notarization (RON), and mobile closings.

### Key Columns
- `id` (uuid, PK)
- `organization_id` (uuid, FK → organizations)
- `application_id` (uuid, FK → applications, unique) - One schedule per application

### Appointment Details
- `scheduled_date` (date, required)
- `scheduled_time` (time, required)
- `duration_minutes` (integer, default 60)

### Location
- `location_type` (enum, required)
  - `title_office` - Title company office
  - `lender_office` - Lender office
  - `attorney_office` - Attorney office
  - `remote_ron` - Remote Online Notarization
  - `mobile_notary` - Mobile notary at borrower location
  - `other`
- `location_address` (text) - Physical address (not applicable for remote_ron)
- `closing_type` (enum, default `in_person`)
  - `in_person` - Traditional closing
  - `ron` - Remote Online Notarization
  - `mobile` - Mobile notary

### Participants
- `participants` (jsonb, default []) - Array of participant records:
  ```json
  {
    "role": "borrower",
    "name": "Jane Doe",
    "email": "jane@example.com",
    "phone": "555-0123",
    "willAttend": true,
    "confirmed": true
  }
  ```
  - Roles: borrower, co-borrower, seller, buyer_agent, listing_agent, closer, notary, attorney, lender_rep

### Agenda
- `agenda_notes` (text) - Special instructions or agenda items

### Rescheduling
- `rescheduled_from` (timestamp) - Previous appointment time (if rescheduled)
- `reschedule_reason` (enum)
  - `borrower_request`
  - `document_delay`
  - `funding_delay`
  - `title_issue`
  - `condition_not_cleared`
  - `other`
- `reschedule_reason_notes` (text)

### Completion
- `closing_completed_at` (timestamp) - When closing was completed

### Audit
- `created_by` (uuid, FK → users, required)
- `created_at`, `updated_at`

### Indexes
1. `closing_schedules_org_date_idx` on `organization_id`, `scheduled_date`
2. `closing_schedules_app_idx` on `application_id`

### Business Logic
- Each application has one active closing schedule (unique constraint)
- Rescheduling creates new record; old appointment time saved in `rescheduled_from`
- All participants receive calendar invites and confirmation emails
- RON closings require RON platform integration (vendor-specific)
- Closing cannot be scheduled until:
  - CD 3-day waiting period expired
  - All prior-to-funding conditions cleared
  - CTC issued

### Related Tables
- `applications` - Loan being closed
- `users` - Scheduler
- `ctc_clearances` - CTC must be issued before scheduling
- `cd_revisions` - CD waiting period must be satisfied

---

## Table: `disbursements`

**Purpose**: Tracks individual fund disbursements from loan proceeds. Records each payment from closing (purchase price, payoffs, commissions, cash to borrower, etc.).

### Key Columns
- `id` (uuid, PK)
- `organization_id` (uuid, FK → organizations)
- `application_id` (uuid, FK → applications)

### Disbursement Details
- `disbursement_type` (enum, required)
  - `purchase_price` - Payment to seller
  - `payoff_existing_loan` - Payoff of existing mortgage(s)
  - `closing_costs` - Payment of closing costs
  - `realtor_commission` - Real estate agent commission
  - `cash_to_borrower` - Cash back to borrower (cash-out refi)
  - `other`
- `recipient_name` (text, required)
- `amount` (numeric 12,2, required)

### Status Tracking
- `status` (enum, default `scheduled`)
  - `scheduled` - Planned disbursement
  - `sent` - Payment sent
  - `confirmed` - Receipt confirmed
  - `failed` - Payment failed

### Timing
- `scheduled_date` (timestamp, required) - When payment is scheduled
- `sent_date` (timestamp) - When payment was sent
- `confirmed_date` (timestamp) - When receipt was confirmed

### Notes
- `notes` (text) - Additional disbursement details

### Timestamps
- `created_at` (timestamp, default now)

### Indexes
1. `disbursements_app_type_idx` on `application_id`, `disbursement_type`

### Business Logic
- All disbursements scheduled before closing
- Total disbursements must equal loan amount + borrower funds to close
- Disbursements typically sent same day as funding (scheduled_date = funding_date)
- Payoffs must account for per diem interest to payoff date
- Cash-to-borrower limited by regulations (typically cannot exceed 2% of loan amount for purchase)

### Example Disbursement Breakdown
For a $400k purchase with $80k down:
- Purchase price to seller: $320k (after all closing costs deducted)
- Closing costs: $15k
- Realtor commission: $24k (6% of $400k)
- Title/escrow fees: $5k
- Other closing costs: $10k

### Related Tables
- `applications` - Loan being disbursed
- `wire_requests` - Wire transfers for disbursements
- `closing_schedules` - Closing when disbursements occur

---

## Table: `post_closing_items`

**Purpose**: Post-closing trailing documents and tasks checklist. Tracks items that must be received after closing but before loan can be delivered to investor or servicing.

### Key Columns
- `id` (uuid, PK)
- `organization_id` (uuid, FK → organizations)
- `application_id` (uuid, FK → applications)

### Item Details
- `item_type` (enum, required)
  - `recorded_deed` - Recorded deed from county
  - `wet_ink_note` - Original promissory note with wet signature
  - `title_policy` - Final title insurance policy
  - `trailing_condition` - Trailing UW condition
  - `qc_review` - Quality control review
  - `servicing_boarding` - Loan boarded to servicing system
  - `investor_delivery` - Loan delivered to investor
  - `other`
- `item_name` (text, required) - Short name
- `description` (text) - Detailed description
- `required` (boolean, default true) - Whether item is required

### Status
- `status` (enum, default `pending`)
  - `pending` - Not yet received
  - `received` - Received but not complete
  - `complete` - Fully complete

### Timing
- `due_date` (date) - When item is due
- `received_date` (date) - When item was received
- `received_by` (uuid, FK → users) - Who marked item received

### Document Reference
- `document_id` (uuid, FK → documents) - Supporting document (e.g., scanned recorded deed)

### Notes
- `notes` (text) - Additional notes

### Timestamps
- `created_at`, `updated_at`

### Indexes
1. `post_closing_items_app_status_idx` on `application_id`, `status`
2. `post_closing_items_due_date_idx` on `due_date`

### Business Logic
- All required items must be complete before final loan delivery
- Recorded deed typically received 30-60 days after closing
- Wet ink note required for non-eNote loans
- Title policy issued after recording
- Trailing conditions must be cleared per UW requirements
- QC review identifies post-closing deficiencies

### Typical Post-Closing Timeline
- Day 0: Closing occurs
- Day 1-3: Wet ink note received (if applicable)
- Day 5-10: QC review completed
- Day 30-60: Recorded deed received
- Day 45-75: Final title policy issued
- Day 60-90: Servicing boarding complete
- Day 90: Investor delivery (if selling loan)

### Related Tables
- `applications` - Loan with trailing items
- `documents` - Supporting documents
- `users` - Who marked items received
- `conditions` - Source of trailing conditions
