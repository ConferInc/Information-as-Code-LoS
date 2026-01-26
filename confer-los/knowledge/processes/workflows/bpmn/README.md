# BPMN Workflow Models

**Purpose:** Hierarchical BPMN 2.0 models for the Confer Loan Origination System, compatible with Camunda Modeler 5.42.0 / Camunda 8.

**Structure:** Four levels of detail (L0-L3) for different audiences and use cases.

**Last Updated:** 2025-12-14
**Status:** L0 complete, L1-01 (Pre-Qualification) complete, L1-02 (Application) complete, L1-03 (Processing) complete, L2 Application Wizard complete, **Agentic Architecture defined (27 agents)**

---

## Quick Reference

| Level        | Scope                   | Files        | Audience                          |
| ------------ | ----------------------- | ------------ | --------------------------------- |
| **L0** | Entire lifecycle        | 1 file       | Executives, training              |
| **L1** | One phase               | 6 files      | Business analysts, process owners |
| **L2** | Subprocess within phase | ~15-20 files | Process designers, UI designers   |
| **L3** | Task-level detail       | ~30-40 files | Developers, operations            |

---

## L0 - Executive Overview (COMPLETED)

**Status:** ✅ Complete
**File:** `l0/loan-origination-system-l0.bpmn`

### What We Built

A professional, color-coded executive overview showing the complete mortgage loan origination lifecycle:

```
[Start] → [Pre-Qualification] → [Application] → [Processing] → [Underwriting] → ◇ → [Closing] → [Funding] → [End]
                                                                                 ↓
                                                                           [Denied]
```

### Design Decisions (L0)

1. **Color Coding by Task Type:**

   - 🔵 Blue = Customer-facing (User Tasks) - Pre-Qualification, Application
   - 🟠 Orange = Staff/Back-office (Manual Tasks) - Processing, Underwriting, Closing
   - 🟢 Green = Automated (Service Tasks) - Funding, Loan Funded
   - 🔴 Red = Negative outcome - Loan Denied
2. **BPMN Task Types with Icons:**

   - `userTask` (person icon) = Customer actions
   - `manualTask` (hand icon) = Staff manual tasks
   - `serviceTask` (gear icon) = Automated/system tasks
3. **Visual Groups:**

   - "CUSTOMER-FACING PHASES (Borrower Portal)" - Pre-Qual + Application
   - "BACK-OFFICE PHASES (Internal LOS Portal)" - Processing through Funding
4. **Phase-Specific Annotations:**

   - **ROLE** annotation above each task (who does this)
   - **SYSTEM** annotation below each task (what system is used)
   - **Duration** annotation (how long it takes)
5. **Summary Annotations (bottom of diagram):**

   - Conversion Funnel (100% → 20% funded)
   - Timeline (30-45 days total)
   - Task Type Legend
6. **Rich Documentation:**

   - Each element has detailed `<documentation>` for properties panel
   - Suitable for training and onboarding

### L0 Audience & Use Cases

- C-Suite executives and board presentations
- Client demos and sales presentations
- New employee onboarding
- UI/UX designers understanding customer journey
- Regulatory/compliance overview

---

## L1 - Process Overview Level (IN PROGRESS)

**Status:** 🚧 In Progress (3 of 6 complete + Agentic Architecture)
**Files:** 6 files (one per L0 phase)

### Strategy: One File Per Phase

Each L0 task box expands into its own L1 diagram. This provides:

- Clear separation of concerns
- Different teams can own different phases
- Natural boundaries (customer-facing vs back-office)
- Easier maintenance and updates

### L1 Files

| # | File                                | L0 Phase          | Primary System  | Primary Roles         | Status                        |
| - | ----------------------------------- | ----------------- | --------------- | --------------------- | ----------------------------- |
| 1 | `l1/l1-01-pre-qualification.bpmn` | Pre-Qualification | Borrower Portal | Borrower              | ✅ Complete                   |
| 2 | `l1/l1-02-application.bpmn`       | Application       | Borrower Portal | Borrower, Co-Borrower | ✅ Complete                   |
| 3 | `l1/l1-03-processing.bpmn`        | Processing        | Internal LOS    | Processor             | ✅ Complete                   |
| 4 | `l1/l1-04-underwriting.bpmn`      | Underwriting      | Internal LOS    | Underwriter, AI Agent | ⏸️ Blocked (needs research) |
| 5 | `l1/l1-05-closing.bpmn`           | Closing           | Internal LOS    | Closer, Title Agent   | ⏸️ Blocked (needs research) |
| 6 | `l1/l1-06-funding.bpmn`           | Funding           | Internal LOS    | Funder (automated)    | ⏸️ Blocked (needs research) |

> **Note on L1-02 (Application):** The L1 Application diagram uses a collapsed subprocess
> (callActivity) to reference the detailed L2 Application Wizard. The L1 shows the
> high-level flow with ~7 elements including co-borrower decision branch:
> `[Start] → [Complete Wizard] → [Add Co-Borrower?] → [Review & Submit] → [End]`

### What L1 Contains

- **Major sub-steps** within each phase (5-10 tasks per diagram)
- **Key decision points** (but not every micro-decision)
- **Handoffs between roles** within the phase
- **System touchpoints** at high level
- **Call Activities** pointing to L2 subprocesses
- **Swimlanes** separating different actors

### What L1 Does NOT Contain

- Individual UI clicks or field validations (that's L3)
- Detailed error handling (that's L2/L3)
- API calls or technical implementation details
- Every possible edge case

### L1 Design Approach

1. **Swimlanes by Role:** Each L1 diagram will use horizontal pools/lanes to show which role performs each task
2. **Call Activities:** Complex sub-steps will be represented as collapsed subprocesses linking to L2
3. **Consistent Styling:** Same color scheme as L0 (blue=customer, orange=staff, green=automated)
4. **Entry/Exit Points:** Clear start/end events that connect to adjacent phases

---

## L2 - Detailed Process Level (IN PROGRESS)

**Status:** 🚧 In Progress (1 of ~18 complete)
**Files:** ~15-20 files (subprocesses within each L1)

### Strategy: Subprocesses Within Each Phase

L2 breaks down the L1 tasks into detailed subprocesses. Each L1 call activity expands into a full L2 diagram.

### L2 Master Checklist

This is the **authoritative list** of all L2 diagrams. Each entry links to:

- **Spec Reference:** The workflow definition in `docs/specs/`
- **Research:** Supporting research in `docs/research/`
- **Task File:** The task tracker in `tasks/`

#### Pre-Qualification Phase (`l2/pre-qualification/`)

| # | File                                | Description                 | Spec Reference | Status         | Task |
| - | ----------------------------------- | --------------------------- | -------------- | -------------- | ---- |
| 1 | `l2-prequal-rate-calculator.bpmn` | Rate quote calculation flow | WF-08          | ☐ Not Started | -    |
| 2 | `l2-prequal-lead-capture.bpmn`    | Anonymous lead capture      | WF-08          | ✅ Complete    | -    |

#### Application Phase (`l2/application/`)

| # | File                                 | Description                      | Spec Reference | Status         | Task |
| - | ------------------------------------ | -------------------------------- | -------------- | -------------- | ---- |
| 3 | `l2-application-wizard.bpmn`       | 9-step URLA 1003 wizard + submit | WF-03          | ✅ Complete    | 058  |
| 4 | `l2-app-registration.bpmn`         | New user registration            | WF-01          | ✅ Complete    | -    |
| 5 | `l2-app-resume.bpmn`               | Resume saved application         | WF-02          | ☐ Not Started | -    |
| 6 | `l2-app-co-borrower-invite.bpmn`   | Primary invites co-borrower      | WF-04          | ✅ Complete    | 058b |
| 7 | `l2-app-co-borrower-complete.bpmn` | Co-borrower completes section    | WF-05          | ✅ Complete    | 058b |
| 8 | `l2-app-document-upload.bpmn`      | Document upload flow             | WF-06          | ✅ Complete    | 058b |
| 9 | `l2-app-status-check.bpmn`         | Application status checking      | WF-07          | ☐ Not Started | -    |

#### Processing Phase (`l2/processing/`) - ⏸️ BLOCKED

> **Blocked:** Requires back-office research. See tasks 059.

| #    | File                                 | Description                | Spec Reference | Status              | Task |
| ---- | ------------------------------------ | -------------------------- | -------------- | ------------------- | ---- |
| 10   | `l2-proc-document-collection.bpmn` | Collect & verify documents | TBD            | ✅**Created** | 059  |
| 11   | `l2-proc-income-verification.bpmn` | VOE, VOI processes         | TBD            | ✅**Created** | 059  |
| 12   | `l2-proc-third-party-orders.bpmn`  | Appraisal, title, flood    | TBD            | ✅**Created** | 059  |
| 12.1 | l2-proc-credit-review.bpmn           | Split for clarity.         | TBD            | ✅**Created** |      |
| 12.2 | l2-proc-property-appraisal.bpm       | Split for clarity.         | TBD            | ✅**Created** |      |

#### Underwriting Phase (`l2/underwriting/`) - ⏸️ BLOCKED

> **Blocked:** Requires underwriting workflow research. See task 060.

| #  | File                                 | Description                   | Spec Reference | Status              | Task |
| -- | ------------------------------------ | ----------------------------- | -------------- | ------------------- | ---- |
| 13 | `l2-uw-aus-submission.bpmn`        | AUS (DU/LP) submission        | TBD            | ✅**Created** | 060  |
| 14 | `l2-uw-conditions-management.bpmn` | Condition tracking & clearing | TBD            | ✅**Created** | 060  |
| 15 | `l2-uw-decision-rendering.bpmn`    | Approve/deny/suspend          | TBD            | ⏸️ Blocked        | 060  |

#### Closing Phase (`l2/closing/`) - ⏸️ BLOCKED

> **Blocked:** Requires closing workflow research. See task 061.

| #  | File                             | Description                       | Spec Reference | Status              | Task |
| -- | -------------------------------- | --------------------------------- | -------------- | ------------------- | ---- |
| 16 | `l2-close-clear-to-close.bpmn` | CTC milestone process             | TBD            | ✅**Created** | 061  |
| 17 | `l2-close-document-prep.bpmn`  | CD, note, deed preparation        | TBD            | ⏸️ Blocked        | 061  |
| 18 | `l2-close-signing.bpmn`        | Signing ceremony (wet/hybrid/RON) | TBD            | ⏸️ Blocked        | 061  |

#### Funding Phase (`l2/funding/`) - ⏸️ BLOCKED

> **Blocked:** Requires funding workflow research. See task 062.

| #  | File                           | Description                    | Spec Reference | Status              | Task |
| -- | ------------------------------ | ------------------------------ | -------------- | ------------------- | ---- |
| 19 | `l2-fund-wire-transfer.bpmn` | Wire initiation & confirmation | TBD            | ✅**Created** | 062  |
| 20 | `l2-fund-recording.bpmn`     | County recording process       | TBD            | ⏸️ Blocked        | 062  |

### L2 Summary

| Phase             | Total        | Complete     | In Progress | Not Started | Blocked |
| ----------------- | ------------ | ------------ | ----------- | ----------- | ------- |
| Pre-Qualification | 2            | 1            | 0           | 1           | 0       |
| Application       | 7            | 5            | 0           | 2           | 0       |
| Processing        | 3            | 3            | 0           | 0           | 0       |
| Underwriting      | 3            | 2            | 0           | 0           | 1       |
| Closing           | 3            | 1            | 0           | 0           | 2       |
| Funding           | 2            | 1            | 0           | 0           | 1       |
| **Total**   | **20** | **13** | **0** | 3           | 4       |

### What L2 Contains

- **All major tasks** within a subprocess
- **Error handling paths** and exception flows
- **Parallel activities** (e.g., ordering credit + appraisal + title simultaneously)
- **Timer events** for escalations and reminders
- **Intermediate events** for signals and messages
- **Business rules** at decision points

### L2 Audience

- Process designers
- Loan officers and processors (operational reference)
- UI/UX designers (screen flow design)
- Business analysts (detailed requirements)

---

## L3 - Operational Detail Level (PLANNED)

**Status:** 🗓️ Planned
**Files:** ~30-40 files (task-level detail)

### Strategy: Every Click, Every Field

L3 is the most granular level - it documents exactly what happens at the UI/interaction level.

### What L3 Contains

- **Exact user actions:** "User clicks Submit button"
- **Field-level validations:** "SSN must be 9 digits"
- **API calls and integrations:** "System calls credit bureau API"
- **Conditional logic:** "If income > $100k, skip additional docs"
- **Edge cases and exception handling**
- **Micro-decisions within a task**

### Planned L3 Structure

```
l3/
├── pre-qualification/
│   ├── l3-prequal-enter-loan-purpose.bpmn
│   ├── l3-prequal-enter-property-info.bpmn
│   ├── l3-prequal-calculate-rate.bpmn
│   └── l3-prequal-display-results.bpmn
├── application/
│   ├── l3-app-create-account.bpmn
│   ├── l3-app-enter-personal-info.bpmn
│   ├── l3-app-enter-ssn.bpmn
│   ├── l3-app-add-coborrower.bpmn
│   ├── l3-app-enter-employer.bpmn
│   ├── l3-app-upload-paystub.bpmn
│   ├── l3-app-sign-disclosures.bpmn
│   └── l3-app-submit-application.bpmn
├── processing/
│   ├── l3-proc-order-credit-report.bpmn
│   ├── l3-proc-receive-credit-report.bpmn
│   ├── l3-proc-order-appraisal.bpmn
│   ├── l3-proc-schedule-appraiser.bpmn
│   ├── l3-proc-verify-employment.bpmn
│   └── l3-proc-request-missing-docs.bpmn
├── underwriting/
│   ├── l3-uw-run-aus.bpmn
│   ├── l3-uw-calculate-dti.bpmn
│   ├── l3-uw-review-credit.bpmn
│   ├── l3-uw-add-condition.bpmn
│   ├── l3-uw-clear-condition.bpmn
│   └── l3-uw-render-decision.bpmn
├── closing/
│   ├── l3-close-generate-cd.bpmn
│   ├── l3-close-schedule-signing.bpmn
│   ├── l3-close-esign-documents.bpmn
│   └── l3-close-notarize.bpmn
└── funding/
    ├── l3-fund-initiate-wire.bpmn
    ├── l3-fund-confirm-receipt.bpmn
    └── l3-fund-record-mortgage.bpmn
```

### L3 Audience

- Developers (implementation reference)
- QA testers (test case design)
- Operations staff (step-by-step procedures)
- Training (detailed how-to guides)

---

## Agentic Architecture (AI-First Processing)

**Status:** ✅ Architecture Defined (2025-12-14)
**Documentation:**

- Task 059a: Orchestrating Agents (15) - `tasks/059a_bpmn_l1_processing_agentic.md`
- Task 059b: Worker Agents (12) - `tasks/059b_worker_agent_catalog.md`
- Architecture Overview: `docs/architecture/agentic-architecture.md`

### Two-Tier Agent Model

The Processing phase (and future phases) uses an **event-driven, agent-based architecture** instead of traditional sequential workflows:

| Agent Type                     | Count        | Purpose                                       | Examples                                                 |
| ------------------------------ | ------------ | --------------------------------------------- | -------------------------------------------------------- |
| **Orchestrating Agents** | 15           | Drive processes, make decisions, trigger work | Credit Agent, Fraud Detection Agent, UW Confidence Agent |
| **Worker Agents**        | 12           | Do one task reliably when triggered           | Email Agent, PDF Generator, Pricing Agent                |
| **Total**                | **27** |                                               |                                                          |

### How Agents Relate to BPMN

```
Traditional BPMN (L1-L3):           Agentic Overlay:
┌──────────────────────┐           ┌──────────────────────┐
│ L1: High-level flow  │           │ Events trigger       │
│ Task → Task → Task   │    +      │ parallel agents      │
└──────────────────────┘           └──────────────────────┘
        ↓                                   ↓
┌──────────────────────┐           ┌──────────────────────┐
│ L2: Subprocesses     │           │ Orchestrating agents │
│ Sequential steps     │    →      │ coordinate work      │
└──────────────────────┘           └──────────────────────┘
        ↓                                   ↓
┌──────────────────────┐           ┌──────────────────────┐
│ L3: User actions     │           │ Worker agents        │
│ Click by click       │    →      │ execute tasks        │
└──────────────────────┘           └──────────────────────┘
```

### Key Concepts

1. **Event-Driven:** Agents react to events (`document.uploaded`, `credit.received`) not human commands
2. **Parallel Processing:** Multiple agents work simultaneously (Credit + Title + Appraisal)
3. **Progressive Underwriting:** Confidence score (0-100) increases as data arrives, not binary complete/incomplete
4. **Human Fallback:** AI makes recommendations, humans decide when confidence < 100%
5. **Technology Stack:** Temporal (durable workflows) + LangGraph (AI reasoning)

### L1 BPMNs with Agent References

All L1 BPMNs now include documentation referencing which agents are used:

| BPMN                             | Orchestrating Agents                                      | Worker Agents                                                     |
| -------------------------------- | --------------------------------------------------------- | ----------------------------------------------------------------- |
| `l1-01-pre-qualification.bpmn` | None (user-driven)                                        | Pricing, Property Validation, Email, Audit                        |
| `l1-02-application.bpmn`       | None (user-driven)                                        | Email, SMS, Notification, Account, Audit                          |
| `l1-03-processing.bpmn`        | All 15 (Credit, Title, Appraisal, Doc Class, Fraud, etc.) | 7 (Email, SMS, Notification, PDF, MISMO, Audit, Compliance Timer) |

### Related Documentation

| Document                                      | Purpose                                       |
| --------------------------------------------- | --------------------------------------------- |
| `tasks/059a_bpmn_l1_processing_agentic.md`  | Full orchestrating agent catalog with schemas |
| `tasks/059b_worker_agent_catalog.md`        | Full worker agent catalog with schemas        |
| `docs/architecture/agentic-architecture.md` | Two-tier model overview                       |

---

## File Naming Convention

**Format:** `l{level}-{phase-abbrev}-{process-name}.bpmn`

**Examples:**

- L0: `loan-origination-system-l0.bpmn`
- L1: `l1-01-pre-qualification.bpmn`
- L2: `l2-proc-document-collection.bpmn`
- L3: `l3-app-enter-ssn.bpmn`

**Phase Abbreviations:**

- `prequal` - Pre-Qualification
- `app` - Application
- `proc` - Processing
- `uw` - Underwriting
- `close` - Closing
- `fund` - Funding

**Rules:**

- Use kebab-case (lowercase with hyphens)
- Include level indicator (`l0`, `l1`, `l2`, `l3`)
- Include phase abbreviation for L2/L3
- Be descriptive but concise

---

## Directory Structure

```
/docs/workflows/bpmn/
├── README.md                              # This file (master checklist & traceability)
├── l0/
│   └── loan-origination-system-l0.bpmn   # ✅ Complete
├── l1/
│   ├── l1-01-pre-qualification.bpmn      # ✅ Complete (Task 057a)
│   ├── l1-02-application.bpmn            # ✅ Complete (Task 057b)
│   ├── l1-03-processing.bpmn             # ✅ Complete (Task 059) + Agentic (059a)
│   ├── l1-04-underwriting.bpmn           # ⏸️ Blocked (needs research)
│   ├── l1-05-closing.bpmn                # ⏸️ Blocked (needs research)
│   └── l1-06-funding.bpmn                # ⏸️ Blocked (needs research)
├── l2/
│   ├── pre-qualification/                 # (empty - 2 diagrams pending)
│   ├── application/
│   │   └── l2-application-wizard.bpmn    # ✅ Complete (Task 058)
│   ├── processing/                        # (empty - blocked)
│   ├── underwriting/                      # (empty - blocked)
│   ├── closing/                           # (empty - blocked)
│   └── funding/                           # (empty - blocked)
└── l3/
    ├── pre-qualification/                 # (planned)
    ├── application/                       # (planned)
    ├── processing/                        # (planned)
    ├── underwriting/                      # (planned)
    ├── closing/                           # (planned)
    └── funding/                           # (planned)
```

---

## Estimated File Counts

| Level           | Files            | Status                                                   |
| --------------- | ---------------- | -------------------------------------------------------- |
| L0              | 1                | ✅ Complete                                              |
| L1              | 6                | 🚧 3/6 Complete (Pre-Qual, Application, Processing done) |
| L2              | 15-20            | 🚧 1/~18 Complete (Application Wizard done)              |
| L3              | 30-40            | 🗓️ Planned                                             |
| **Total** | **~50-67** |                                                          |

---

## Design Principles

### 1. Progressive Detail

- Each level adds more detail without repeating information
- L0 → L1 = expand phases into sub-steps
- L1 → L2 = expand sub-steps into detailed workflows
- L2 → L3 = expand to individual user actions

### 2. Consistent Visual Language

- Same color scheme across all levels
- Same task type conventions (userTask, manualTask, serviceTask)
- Same annotation style (ROLE above, SYSTEM below, Duration inline)

### 3. Traceability

- Each L1 task can be traced to one L0 phase
- Each L2 subprocess can be traced to one L1 task
- Each L3 action can be traced to one L2 task
- Use Call Activities to link between levels

### 4. Audience-Appropriate Detail

- L0: "What are the major phases?" (executives)
- L1: "What happens in each phase?" (analysts)
- L2: "How does each subprocess work?" (designers)
- L3: "What exactly does the user do?" (developers)

### 5. Documentation in BPMN

- Use `<documentation>` elements for detailed descriptions
- Visible in Camunda Modeler properties panel
- Serves as inline training material

---

## Camunda Modeler Compatibility

**Tool:** Camunda Modeler 5.42.0
**Platform:** Camunda 8.5.0
**Format:** BPMN 2.0 XML

### Important Notes

1. **isExecutable="false":** Our diagrams are documentation-only, not meant for Camunda engine execution. The "One Process must be Executable" warning can be ignored.
2. **Color Extensions:** We use `bioc:` and `color:` namespaces for visual styling. These are Camunda Modeler extensions and render correctly in the modeler.
3. **Task Types:** Using semantic task types (userTask, manualTask, serviceTask) adds icons that convey meaning even without color.

---

## Traceability & Source-of-Truth

### How BPMN Relates to Other Documentation

BPMN diagrams are **derived from** and **must stay in sync with** these source documents:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SOURCE OF TRUTH HIERARCHY                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   docs/specs/                     ──────►  BPMN Diagrams                    │
│   ├── borrower-portal-workflows.md         ├── l1/*.bpmn                    │
│   │   (WF-01 through WF-16)               ├── l2/**/*.bpmn                  │
│   ├── borrower-portal-wireframes.md       └── l3/**/*.bpmn                  │
│   │   (B-01 through B-xx screens)                                           │
│   └── borrower-portal-features.md                                           │
│                                                                             │
│   docs/research/                                                            │
│   ├── synthesized/                                                          │
│   │   ├── urla-1003-field-analysis.md                                       │
│   │   ├── multi-borrower-analysis.md                                        │
│   │   └── mismo-compliance-requirements.md                                  │
│   └── raw/                                                                  │
│       └── (industry research, competitor analysis)                          │
│                                                                             │
│   docs/decisions/                                                           │
│   └── glossary-mortgage-terms.md                                            │
│       (Pre-Qualification vs Pre-Approval, etc.)                             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Spec-to-BPMN Mapping

| Spec Workflow                | L1 Diagram                 | L2 Diagram(s)               |
| ---------------------------- | -------------------------- | --------------------------- |
| WF-01: Registration          | l1-02-application          | l2-app-registration         |
| WF-02: Resume Application    | l1-02-application          | l2-app-resume               |
| WF-03: Complete Application  | l1-02-application          | l2-application-wizard ✅    |
| WF-04: Add Co-Borrower       | l1-02-application          | l2-app-co-borrower-invite   |
| WF-05: Co-Borrower Completes | l1-02-application          | l2-app-co-borrower-complete |
| WF-06: Document Upload       | l1-02-application          | l2-app-document-upload      |
| WF-07: Status Checking       | l1-02-application          | l2-app-status-check         |
| WF-08: Pre-Qualification     | l1-01-pre-qualification ✅ | l2-prequal-*                |
| WF-09: Password Reset        | (utility flow)             | -                           |
| WF-10: Update Personal Info  | (utility flow)             | -                           |
| WF-11: Withdraw Application  | l1-02-application          | -                           |
| WF-12: Re-apply After Denial | l1-02-application          | -                           |
| WF-13: Validation Error      | (embedded in L2)           | -                           |
| WF-14: Session Timeout       | (embedded in L2)           | -                           |
| WF-15: Co-Borrower Declines  | l1-02-application          | l2-app-co-borrower-invite   |
| WF-16: Document Rejection    | l1-03-processing           | l2-proc-document-collection |

### Keeping BPMN in Sync

#### When Specs Change

If a workflow spec (`docs/specs/borrower-portal-workflows.md`) is updated:

1. **Identify affected BPMN diagrams** using the mapping table above
2. **Update the L2 diagram first** (most detailed)
3. **Propagate changes up** to L1 if the high-level flow changed
4. **Update this README** if new diagrams are needed or status changes
5. **Update the task file** if work is in progress

#### When UI/Wireframes Change

If wireframes (`docs/specs/borrower-portal-wireframes.md`) change:

1. **Check if the flow changed** or just visual design
2. **If flow changed:** Update the corresponding L2 BPMN
3. **Cross-reference:** Each L2 diagram's `<documentation>` should reference wireframe IDs (e.g., "UI: B-01 through B-10")

#### When Code Changes

If frontend/backend code changes the actual flow:

1. **Update the spec first** (`docs/specs/`)
2. **Then update BPMN** per the spec change process above
3. **Never** update BPMN directly without updating specs

#### When Research Changes

If new research (`docs/research/synthesized/`) affects requirements:

1. **Update decisions** in `docs/decisions/` if needed
2. **Update specs** to reflect new understanding
3. **Update BPMN** per the spec change process

### Sync Checklist (For New Sessions)

When starting a new session to work on BPMN diagrams:

1. **Read this README** - Understand what exists and what's pending
2. **Check the L2 Master Checklist** - See status of all diagrams
3. **Read the relevant spec** - `docs/specs/borrower-portal-workflows.md` for the workflow you're implementing
4. **Read the task file** - `tasks/0XX_*.md` for context and requirements
5. **Check for recent changes** - Look at `git log` for specs/research changes since last BPMN update

### File Location Reference

| Content Type               | Location                                                       | Purpose                               |
| -------------------------- | -------------------------------------------------------------- | ------------------------------------- |
| **Workflow Specs**   | `docs/specs/borrower-portal-workflows.md`                    | WF-01 through WF-16 definitions       |
| **Wireframe Specs**  | `docs/specs/borrower-portal-wireframes.md`                   | Screen definitions (B-01, W-01, etc.) |
| **Feature Specs**    | `docs/specs/borrower-portal-features.md`                     | Feature requirements                  |
| **URLA Research**    | `docs/research/synthesized/urla-1003-field-analysis.md`      | Form field requirements               |
| **Multi-Borrower**   | `docs/research/synthesized/multi-borrower-analysis.md`       | Co-borrower rules                     |
| **MISMO Compliance** | `docs/research/synthesized/mismo-compliance-requirements.md` | Data standards                        |
| **Terminology**      | `docs/decisions/glossary-mortgage-terms.md`                  | Pre-qual vs pre-approval, etc.        |
| **Task Files**       | `tasks/0XX_bpmn_*.md`                                        | Task definitions and status           |
| **BPMN Diagrams**    | `docs/workflows/bpmn/l*/`                                    | The diagrams themselves               |

---

## Related Documentation

- **System Architecture:** `/docs/architecture/system_overview.md`
- **Workflow Orchestration:** `/docs/architecture/workflow_orchestration.md`
- **Temporal Workflows:** `/confer-los/temporal/workflows/`
- **Borrower Portal Specs:** `/docs/specs/borrower-portal-workflows.md`

---

## Changelog

| Date       | Change                                                                        | Author |
| ---------- | ----------------------------------------------------------------------------- | ------ |
| 2025-12-14 | L1-02 Application complete (Task 063) - ~7 elements with collapsed subprocess | Claude |
| 2025-12-14 | Added L2 Master Checklist, Traceability section, Spec-to-BPMN mapping         | Claude |
| 2025-12-14 | Updated namespace URLs to `https://confersolutions.ai/bpmn/`                | Claude |
| 2025-12-14 | L2 Application Wizard complete; reclassified from L1 (too detailed for L1)    | Claude |
| 2025-12-14 | L1-01 Pre-Qualification complete with enterprise service architecture         | Claude |
| 2025-12-14 | L0 diagram completed with colors, icons, role/system annotations              | Claude |
| 2025-12-14 | Updated README with L0-L3 strategy and file counts                            | Claude |
| 2025-12-06 | Initial README structure created                                              | Claude |
