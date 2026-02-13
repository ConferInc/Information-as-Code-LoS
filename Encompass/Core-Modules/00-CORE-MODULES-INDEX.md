---
type: technical-documentation
module: Core Modules - Complete Index
section: Overview & Navigation
last_updated: 2026-02-13
---

# Encompass Core Modules - Complete Documentation Index

## Overview

This folder contains **10 comprehensive MD files** documenting every Core Module in Encompass, the loan origination system (LOS) used by MoXi Global and mortgage lenders worldwide. Each file is backed by **6 SOP transcripts** with timestamped evidence, **69 documented pain points**, and complete field specifications.

---

## Module Structure

### 1.1 Pipeline Management
**File:** `encompass-pipeline-view.md`
**Coverage:** Pipeline grid, search/filter, loan opening workflows, milestone badges
**Key Pain Points:** Multi-window chaos (11 instances), no real-time updates
**SOP Evidence:** [file:7][file:8]

### 1.2 Borrower Information Management
**File:** `encompass-borrower-form.md`
**Coverage:** Personal info, address history (24-month), contact info, ID documents, credit authorization
**Key Pain Points:** Stare-and-compare bottleneck (14-min cycles), 22+ duplicate field entries
**SOP Evidence:** [file:2][file:6][file:7]

### 1.3 Employment & Income
**File:** `encompass-employment-income.md`
**Coverage:** Current/previous employment, income sources, self-employed calculations, DTI formulas
**Key Pain Points:** Manual pay stub cross-reference, redundant address entry
**SOP Evidence:** [file:4][file:7][file:8]

### 1.4 Property Information
**File:** `encompass-property-information.md`
**Coverage:** Property address, type, purchase/refinance details, LTV calculation, HOA
**Key Pain Points:** Form validation failure at end, international address format issues
**SOP Evidence:** [file:2][file:4][file:5][file:6]

### 1.5 Assets Management
**File:** `encompass-assets-management.md`
**Coverage:** Bank accounts, retirement accounts, investments, gifts, reserve requirements
**Key Pain Points:** Manual bank statement cross-reference, large deposit explanations
**SOP Evidence:** [file:2][file:3][file:4][file:6]

### 1.6 Liabilities Management
**File:** `encompass-liabilities-management.md`
**Coverage:** Credit cards, auto/student loans, mortgages, DTI calculation, 5% rule
**Key Pain Points:** Credit report manual entry (10-15 min), DTI calculation errors
**SOP Evidence:** [file:1][file:2][file:8]

### 1.7 Expenses Tracking
**File:** `encompass-expenses-tracking.md`
**Coverage:** Monthly housing expenses (rent, tax, insurance, HOA), PITI calculation
**Key Pain Points:** Annual vs monthly confusion, HOA verification delays
**SOP Evidence:** [file:3][file:4]

### 1.8 Co-Borrower Management
**File:** `encompass-coborrower-management.md`
**Coverage:** Adding co-borrowers, income aggregation, credit score treatment (lowest middle score)
**Key Pain Points:** Redundant data entry for same address, separate windows per borrower
**SOP Evidence:** [file:2][file:7][file:8]

### 1.9 Real Estate Owned (REO)
**File:** `encompass-real-estate-owned.md`
**Coverage:** Rental properties, rental income calculation (75% rule), negative cash flow
**Key Pain Points:** Manual PITIA calculation, Schedule E complexity, 75% rule misapplication
**SOP Evidence:** [file:1][file:8]

### 1.10 Loan Folders & Organization
**File:** `encompass-loan-folders.md`
**Coverage:** Loan folder structure, loan number format, stage progression, folder permissions
**Key Pain Points:** Multi-window chaos, no bulk actions, search performance
**SOP Evidence:** [file:2][file:7][file:8]

---

## Documentation Statistics

- **Total Files:** 10
- **Total Characters:** ~85,000
- **SOP Files Analyzed:** 6 (8 transcript parts)
- **Pain Points Documented:** 69
- **Timestamped Workflows:** 40+
- **Field Specifications:** 200+ fields with data types, validation, evidence

---

## Key Findings Summary

### Top 5 Pain Points (Cross-Module)
1. **Redundant data entry** - 22+ fields typed multiple times [file:2][file:7]
2. **Multi-window chaos** - 11 "new window" spawns [file:2]
3. **Manual document cross-reference** - 14-minute cycles [file:2]
4. **No real-time validation** - Errors only at final step [file:2][file:6]
5. **International limitations** - Mexico properties don't fit US formats [file:2][file:5]

### Most Common Workflows
1. Pipeline search → Loan open (3 steps) [file:7]
2. Borrower data entry (27 actions) [file:7]
3. Property purchase ($1M example) [file:4]
4. Asset account entry ($100K) [file:6]
5. Monthly housing expenses ($1,600 total) [file:3]

---

## Usage Guide

### For Developers
- **Field Specifications:** Each MD file includes complete field tables with data types, validation rules, and Field IDs for API integration
- **API Endpoints:** Full API documentation per module (`/encompass/v3/loans/{loanId}/...`)
- **Integration Points:** Inbound data sources and outbound dependencies clearly mapped

### For Product Managers
- **Pain Point Analysis:** Every issue backed by SOP evidence with timestamps and impact analysis
- **Workflow Documentation:** Step-by-step user actions with system responses
- **Best Practices:** Role-specific recommendations for LOs, Processors, and Underwriters

### For QA/Training
- **SOP Cross-References:** Direct citations to source material (e.g., [file:7], timestamp [15:05])
- **Real Examples:** Actual data from SOPs ($1M purchase, "Laylene Jeune", $100K checking account)
- **Verification Checklists:** Processing Workbook integration with auto-completion rules

---

**Created:** February 13, 2026

**Source:** MoXi Global SOP Analysis + Encompass Platform Research

**Version:** 1.0