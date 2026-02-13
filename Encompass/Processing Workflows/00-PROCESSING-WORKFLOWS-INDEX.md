---
type: technical-documentation
module: Processing Workflows - Complete Index
section: Overview & Navigation
last_updated: 2026-02-13
---

# Encompass Processing Workflows - Complete Documentation Index

## Overview

This folder contains **4 comprehensive MD files** documenting all Processing Workflows in Encompass, from the manual Processing Workbook to the 14-step UW submission nightmare to proposed Temporal automation workflows. Each file backed by SOP transcript evidence with exact timestamps.

---

## Module Structure

### 3.1 Processing Workbook
**File:** `encompass-processing-workbook.md` (17,744 chars)
**Coverage:** Workbook structure, 5-C narratives, manual checkbox verification, housing expense cross-reference
**Key Pain Points:** All manual verification, no auto-completion, stare-and-compare
**SOP Evidence:** [file:1][file:2][file:6][file:7]

### 3.2 UW Submission (14-Step Export)
**File:** `encompass-uw-submission.md` (16,603 chars)
**Coverage:** MISMO export, hidden 3-level menu, manual file upload to Evolve portal, 10-15 minute wait
**Key Pain Points:** 14 discrete steps, no pre-flight validation, no status tracking
**SOP Evidence:** [file:2][file:6]

### 3.3 Workflow Automation (Temporal)
**File:** `encompass-workflow-automation.md` (21,775 chars)
**Coverage:** 8 proposed Temporal workflows (AI extraction, credit import, fee gate, TRID timer, ECOA timer, condition matching, UW submission, notifications)
**Key Solutions:** Eliminate manual tasks, enforce compliance automatically
**Implementation Requirements:** [file:1]

### 3.4 Processing Workflows Index
**File:** `encompass-processing-workflows-index.md` (THIS FILE)
**Coverage:** Complete module navigation, pain point summary, implementation priorities

---

## Pain Points Summary

### Top 5 Processing Workflow Pain Points

1. **14-Step UW Submission Process** [file:2][file:6]
   - Evidence: 14 discrete steps documented with timestamps
   - Hidden 3-level right-click menu (Right-click → GSE Services → Export ILAD MISMO 3.4)
   - Manual file management + 10-15 minute wait with no status
   - Time cost: 5-10 minutes per submission + 15-minute processing wait

2. **All Manual Processing Workbook Verification** [file:1][file:2]
   - Evidence: Every section requires manual checkbox click
   - No auto-completion even when data validates
   - Example: "24-Month Address History" could auto-calculate, but processor must manually verify
   - Time cost: 5-10 minutes per loan (just checkbox clicking)

3. **Zero Document Parsing / AI Extraction** [file:1][file:2]
   - Evidence: "Processors spend entire sessions opening PDFs, reading values, and re-typing them"
   - Every W-2, pay stub, bank statement manually transcribed
   - Credit report: 15 trade lines typed one-by-one
   - Time cost: 10-15 minutes per document × 10 documents = 100-150 minutes per loan

4. **No Automated TRID / ECOA Compliance Timers** [file:1]
   - Evidence: "Processors manually track 3-day waiting periods"
   - TRID violations = thousands in fines
   - ECOA violations = $10K+ per missed 30-day deadline
   - Risk: High compliance exposure

5. **Stare-and-Compare Housing Expense Verification** [file:2]
   - Evidence: "One processor spent 14 minutes on a single document cross-reference cycle"
   - Document in File Viewer (window 1), form in Borrower window (window 2)
   - Alt-tab repeatedly to verify mortgage statement matches form field
   - Time cost: 14 minutes per verification

---

## SOP Evidence Distribution

| File | Primary SOP Files | Timestamp Examples | Pain Points Documented |
|------|------------------|-------------------|----------------------|
| **Processing Workbook** | [file:1][file:2][file:6][file:7] | [47:24-47:36], [76:30] | 7 |
| **UW Submission** | [file:2][file:6] | [37:28]-[44:28] | 6 |
| **Workflow Automation** | [file:1] | N/A (proposed solutions) | 8 workflows |

**Total:** 13 documented pain points + 8 proposed automation solutions

---

## Implementation Priority (Confer LOS)

### Sprint 2: Processing Workflow (from Feature Parity [file:1])

**Priority Order:**
5. **SplitPaneVerifier.tsx** - Document verification split pane (HIGH)
6. **ProcessingWorkbook.tsx** - Auto-completing checklist (MEDIUM)
7. **Document extraction workflow** - AI-powered extraction (HIGH)

### Sprint 3: Underwriting & Compliance (from Feature Parity [file:1])

**Priority Order:**
12. **Credit report import workflow** - Auto-create liabilities (HIGH)
13. **TRID timer workflow** - Auto-enforce 3-day waiting period (HIGH CRITICAL)
14. **ECOA timer workflow** - Auto-track 30-day adverse action deadline (HIGH CRITICAL)
15. **Fee gate workflow** - Block service orders until fee collected (HIGH)

### Sprint 4: Closing & Funding (from Feature Parity [file:1])

**Priority Order:**
18. **UW submission workflow** - Replace 14-step manual process with 1-click API call (MEDIUM)
19. **Notification router workflow** - Unified multi-channel notifications (MEDIUM)
20. **Condition matching workflow** - Auto-link uploaded docs to conditions (MEDIUM)

---

## Temporal Workflows Summary

| Workflow | Trigger | Activities | Priority | Time Saved |
|----------|---------|------------|----------|------------|
| **document-extraction.ts** | Document upload | Classify, Extract, Map, Suggest, Notify | HIGH | 10-15 min/doc |
| **credit-report-import.ts** | Credit report received | Parse, Create liabilities, Update scores, Flag derogatory | HIGH | 10-15 min/loan |
| **service-order-gate.ts** | Service order attempt | Check fee, Check auth, Gate | HIGH | Compliance risk |
| **trid-timer.ts** | LE/CD sent | Calculate date, Schedule gate, Remind, Release | HIGH CRITICAL | Compliance risk |
| **adverse-action-timer.ts** | UW denial | Start timer, Escalate (day 20), Alert (day 27), Generate notice | HIGH CRITICAL | Compliance risk |
| **condition-matcher.ts** | Borrower uploads doc | Classify, Match conditions, Suggest, Update, Check clear | MEDIUM | 5-10 min/condition |
| **uw-submission.ts** | Submit to UW clicked | Generate MISMO, Validate, Submit API, Track, Update | MEDIUM | 5-10 min/submission |
| **notification-router.ts** | Any application event | Determine recipients, Select channels, Render, Dispatch, Log | MEDIUM | 2-5 min/notification |

**Total Time Saved per Loan:** 150-200 minutes (2.5-3.3 hours)

---

## File Statistics

- **Total Files:** 4
- **Total Documentation:** 56,122 characters (~28,000 words)
- **SOP Files Analyzed:** 6 transcript files
- **Pain Points Documented:** 13 distinct issues
- **Proposed Solutions:** 8 Temporal workflows
- **Timestamped Workflows:** 14-step UW submission fully documented [file:6]
- **Field Specifications:** 40+ Processing Workbook fields, MISMO 3.4 schema
- **Tables & Examples:** 25+ comprehensive tables

---

## Related Documentation

**Cross-Module References:**
- **Core Module 1.4:** Forms & Data Entry (borrower info population for Processing Workbook)
- **Document Management 2.4:** Document Review & Verification (13-checkbox marathon feeds Processing Workbook)
- **Underwriting 4.1:** UW Decision Panel (receives 5-C narratives from Processing Workbook)
- **Underwriting 4.2:** Conditions Management (automated condition matching workflow)
- **Closing 5.1:** Closing Disclosure (TRID timer workflow enforcement)

---

**Created:** February 13, 2026, 5:25 PM EST

**Source:** MoXi Global SOP Analysis + Encompass Platform Research + Temporal Workflow Architecture

**Version:** 1.0