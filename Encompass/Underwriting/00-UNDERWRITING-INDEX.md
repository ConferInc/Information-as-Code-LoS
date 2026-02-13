---
type: technical-documentation
module: Underwriting - Complete Index
section: Overview & Navigation
last_updated: 2026-02-13
---

# Encompass Underwriting - Complete Documentation Index

## Overview

This folder contains **4 comprehensive MD files** documenting all Underwriting workflows in Encompass, from the UW-1A decision panel to conditions management to credit analysis. Each file backed by SOP transcript evidence with exact timestamps.

---

## Module Structure

### 4.1 UW Decision Panel (UW-1A Form)
**File:** `encompass-uw-decision-panel.md` (21,909 chars)
**Coverage:** UW-1A form, loan summary header, credit/income/assets tabs, 5-C narratives, approve/suspend/deny decisions, approval letter generation
**Key Pain Points:** Multi-window chaos, manual condition creation, no ECOA timer
**SOP Evidence:** [file:1][file:2][file:8]

### 4.2 Conditions Management
**File:** `encompass-conditions-management.md` (21,352 chars)
**Coverage:** 4-step manual condition workflow, borrower notification, document linking, auto-creation from UW decisions, Kanban-style board proposal
**Key Pain Points:** 4 clicks per condition, no auto-creation, manual email composition, no document matching
**SOP Evidence:** [file:1][file:7]

### 4.3 Credit Report Analysis
**File:** `encompass-credit-analysis.md` (14,780 chars)
**Coverage:** Credit scoring, mid-score calculation, trade lines, derogatory items, credit utilization, automated credit import
**Key Pain Points:** Manual trade line entry (15-30 min), separate File Viewer window, no auto-flagging
**SOP Evidence:** [file:1][file:8]

### 4.4 Underwriting Index
**File:** `00-UNDERWRITING-INDEX.md` (THIS FILE)
**Coverage:** Complete module navigation, pain point summary, implementation priorities

---

## Pain Points Summary

### Top 5 Underwriting Pain Points

1. **Multi-Window Chaos** [file:2][file:8]
   - UW-1A opens in new window [file:8]
   - Credit report opens in another window (File Viewer) [file:8]
   - Fraud report opens in yet another window
   - Underwriter manages 3-4 windows, constant alt-tabbing

2. **4-Step Manual Condition Creation** [file:1][file:7]
   - Evidence: Complete workflow at [60:32]-[60:50] [file:7]
   - Modal → dropdown → text field → apply = 4 clicks per condition
   - No auto-creation from UW suspension reason
   - Time cost: 1-2 minutes per condition × 5-10 conditions = 5-20 min/loan

3. **Manual Trade Line Entry** [file:1]
   - Processor reads 15 trade lines from credit report PDF
   - Manually types each into Liabilities section (1-2 min each)
   - Total time: 15-30 minutes per credit report
   - No automated credit import workflow

4. **No ECOA Adverse Action Timer** [file:1]
   - Compliance officer manually tracks 30-day deadline
   - Missed deadline = $10K+ fine per violation
   - No automated escalation alerts at day 20 and day 27

5. **Manual Borrower Condition Notifications** [file:1][file:7]
   - Processor manually composes email listing conditions [file:7]
   - No upload links → Borrower must navigate to portal separately
   - Time cost: 10-15 minutes per notification

---

## SOP Evidence Distribution

| File | Primary SOP Files | Timestamp Examples | Pain Points Documented |
|------|------------------|-------------------|----------------------|
| **UW Decision Panel** | [file:1][file:2][file:8] | [09:46], [10:13], [12:10] | 5 |
| **Conditions Management** | [file:1][file:7] | [60:32]-[60:50], [53:26]-[53:45] | 5 |
| **Credit Analysis** | [file:1][file:8] | [12:10] | 4 |

**Total:** 14 documented pain points + 3 proposed Temporal workflows

---

## Implementation Priority (Confer LOS)

### Sprint 3: Underwriting & Compliance (from Feature Parity [file:1])

**Priority Order:**
10. **DecisionPanel.tsx** - Unified UW review interface (HIGH)
11. **ConditionsBoard.tsx** - Kanban-style conditions management (HIGH)
12. **Credit report import workflow** - Auto-create liabilities from credit data (HIGH)
13. **TRID timer workflow** - Auto-enforce 3-day waiting period (HIGH CRITICAL)
14. **ECOA timer workflow** - Auto-track 30-day adverse action deadline (HIGH CRITICAL)
15. **Fee gate workflow** - Block service orders until fee collected (HIGH)

---

## Temporal Workflows Summary

| Workflow | Trigger | Activities | Priority | Time Saved |
|----------|---------|------------|----------|------------|
| **credit-report-import.ts** | Credit report received | Parse, Create liabilities, Update scores, Flag derogatory, Generate summary | HIGH | 15-30 min/loan |
| **adverse-action-timer.ts** | UW denial | Start timer, Escalate (day 20), Alert (day 27), Generate notice | HIGH CRITICAL | Compliance risk eliminated |
| **condition-matcher.ts** | Borrower uploads doc | Classify, Match conditions, Suggest, Update, Check clear | MEDIUM | 5-10 min/condition |

**Total Time Saved per Loan:** 20-40 minutes + compliance risk elimination

---

## File Statistics

- **Total Files:** 4
- **Total Documentation:** 58,041 characters (~29,000 words)
- **SOP Files Analyzed:** 6 transcript files
- **Pain Points Documented:** 14 distinct issues
- **Proposed Solutions:** 3 Temporal workflows + 2 UI components
- **Timestamped Workflows:** 4-step condition creation [file:7], UW-1A window spawn [file:8]
- **Tables & Examples:** 30+ comprehensive tables

---

## Related Documentation

**Cross-Module References:**
- **Processing Workflows 3.1:** Processing Workbook (5-C narratives flow to UW-1A)
- **Processing Workflows 3.3:** Workflow Automation (ECOA timer, credit import, condition matching)
- **Document Management 2.4:** Document Review (credit report viewing)
- **Core Modules 1.2:** Borrower Information (liabilities section populated from credit report)
- **Closing 5.1:** Closing Disclosure (conditions must be cleared before closing)

---


**Created:** February 13, 2026, 5:34 PM EST

**Source:** MoXi Global SOP Analysis + Encompass Platform Research + Temporal Workflow Architecture

**Version:** 1.0