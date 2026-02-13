---
type: marketing-strategy
title: Solving Encompass Pain Points — The Confer LOS Advantage
date: 2026-02-13
source_data: 6 MoXi SOP transcripts (69 documented friction events)
target_audience: Lenders, Brokers, and Ops Managers frustrated by legacy LOS platforms
---

# Solving Encompass Pain Points

> Every pain point below is extracted directly from real MoXi team training sessions recorded while using Encompass. These are not hypotheticals — they are documented, timestamped frustrations that your team is living through today.

---

## 1. The "Stare-and-Compare" Bottleneck

**User Frustration:** Processors spend hours manually comparing uploaded documents against data on separate screens. In one recorded session, a processor opened an uploaded mortgage statement PDF in one window, then navigated back to the Borrower Information form in a separate window to verify that the "Total Payment" figure matched the "Present Housing: Mortgage" field. When it didn't, they had to manually type the correction. Every document — tax returns, bank statements, pay stubs, credit reports — requires this same open-read-compare-correct cycle. In another session, a credit approval email from Evolve ("system updates needed") had to be opened, mentally parsed for required changes, closed, and then the updates were manually applied field-by-field back into the Borrower form.

**Evidence:** 6 documented stare-and-compare workflows across SOPs. One processor spent 14 minutes on a single document cross-reference cycle.

**The Confer LOS Advantage:** Our platform uses AI-powered document extraction to auto-parse uploaded PDFs and pre-fill form fields. When a borrower uploads a bank statement, our Temporal workflows extract account numbers, balances, and transaction histories and auto-populate the Assets section — no manual data entry, no second screen, no human error. Discrepancies are auto-flagged with side-by-side comparisons in a single pane, not across two windows.

---

## 2. UI Friction & Redundant Data Entry

**User Frustration:** The same borrower data is entered over and over across different Encompass forms. In one recorded session, a processor typed the borrower's SSN (123-456-789), address (123 Main St), city, state, and zip into the Borrower Information form — then had to re-type the exact same values into the Power of Attorney form minutes later. Encompass does not auto-populate downstream forms from upstream data entry. Another processor typed "STATE" into a Department field, then separately typed "DEPARTMENT OF STATE" into a License Issuing Authority field — the same concept, entered twice in slightly different formats, with zero auto-fill.

**Evidence:** 22+ fields of duplicate data entry documented in a single 15-minute segment. Borrower Information fields are re-entered in POA forms, co-borrower forms, and disclosure packages.

**The Confer LOS Advantage:** In Confer LOS, borrower data is entered once and flows everywhere. Our unified data model means that when a processor enters borrower info, every downstream form — POA, 1003, CD, disclosures — auto-populates from the single source of truth. Zero copy-paste. Zero re-typing.

---

## 3. The Multi-Window Nightmare

**User Frustration:** Encompass constantly spawns new windows. Opening UW-1A? New window. Viewing the credit report in File Viewer? New window. Checking the Cash to Close estimate? New window. Reviewing the Borrower form? New window. In a single workflow, users manage 3-5 overlapping windows, alt-tabbing between them while trying to remember which window has which data. One SOP captured a modal dialog that required clicking "Close" twice — 24 seconds apart — because the first click didn't dismiss it.

**Evidence:** 11 documented instances of "a new window appears" or "a new window opens" across the SOPs. Double-close bug documented at timestamps [60:35] and [60:59].

**The Confer LOS Advantage:** Confer LOS is a modern single-page application built in Next.js. Every workflow lives in one browser tab. Split-pane views let processors see documents and form fields side by side without window juggling. Modal dialogs are properly scoped and dismissible. The desktop stays clean.

---

## 4. The 14-Click Export (When 1 Button Would Do)

**User Frustration:** To get a loan file from Encompass to the Evolve underwriting portal, a processor must execute 14 discrete steps: open the Documents tab, right-click for a hidden context menu, navigate to GSE Services, select Export ILAD MISMO 3.4, type a filename, click OK, then switch to the Evolve portal, click Upload, click Add Files, navigate to the saved file, select it, click Open, wait 10-15 minutes for processing. The export function itself is buried behind a 3-level right-click menu that new users would never discover.

**Evidence:** 14 steps documented across two separate systems with manual file saving and re-uploading. Core export functionality hidden behind right-click > GSE Services > Export ILAD MISMO 3.4.

**The Confer LOS Advantage:** One click. Our platform has direct API integrations with underwriting engines (DU, LPA, and third-party portals). The processor clicks "Submit to Underwriting" and the system handles the MISMO export, secure transmission, and status tracking automatically. No file management. No alt-tabbing to a second portal. No right-click menus.

---

## 5. Death by a Thousand Checkboxes

**User Frustration:** Document review in Encompass is a tedious one-by-one checkbox marathon. In one recorded session, a processor clicked 13 individual checkboxes in sequence to mark documents as reviewed: Credit Report, Deed Restrictions, Final Truth-in-Lending, Good Faith Estimate, HUD-1 Settlement Statement, Notice of Right to Cancel, Property Tax Receipt, Seller's Disclosure, Survey, Termite Inspection, Title Commitment, URLA, WIR/COE. There is no "Select All," no bulk review, no smart grouping. Post-closing verification requires 4 separate checkbox/radio button clicks for items that could be a single confirmation.

**Evidence:** 13 checkboxes clicked one-by-one in a single session. 4 separate radio buttons for post-closing verification. Zero bulk-action capability.

**The Confer LOS Advantage:** Confer LOS groups documents by category with bulk-action capabilities. "Review All Income Documents" is one click. AI pre-reviews documents for completeness and legibility, flagging only the ones that need human attention. Processors review exceptions, not every single document.

---

## 6. The External Tool Tax (Gmail, Dropbox, Spreadsheets, Payment Portals)

**User Frustration:** Encompass cannot do half the job. MLOs compose borrower emails in Gmail because Encompass has no integrated email. Document sharing uses Dropbox because Encompass can't handle it. Fee reconciliation happens in external spreadsheets, with processors manually comparing deposit amounts against bank statements. Fee collection requires navigating to an entirely separate payment portal where the borrower's name, email, and loan number must be re-entered despite already existing in the LOS. In one session, a processor had a Salesforce CRM tab, a Gmail tab, an Encompass window, and a payment portal all open simultaneously.

**Evidence:** 6 external tools documented across SOPs: Gmail (email), Salesforce/Jungo (CRM), Dropbox (document sharing), external payment portal (fee collection), Point Services (fraud reports), Evolve portal (UW submission).

**The Confer LOS Advantage:** Confer LOS is the single pane of glass. Built-in email and SMS communication (no Gmail). Integrated payment processing (no external portal). Native CRM with lead tracking (no Salesforce tab). Secure document sharing (no Dropbox). Every external tool Encompass forces you to use is a feature we've built natively.

---

## 7. Forms That Fight You (No Pre-Validation)

**User Frustration:** Encompass lets you complete an entire multi-step workflow and only tells you something is wrong at the very last step. In one session, a processor selected forms, added them to a "Selected Forms" list, clicked "Print File" — and got an error because "Owned By" and "Property Used As" fields were not populated. The system happily accepted every prior step without warning, then failed at the finish line. The processor had to navigate back, find the missing fields, fill them in, and start over.

**Evidence:** Documented print-file failure at timestamp [76:30] after all preceding steps succeeded without validation.

**The Confer LOS Advantage:** Confer LOS validates in real-time. Missing required fields are flagged immediately with inline warnings. Before any generate/print/submit action, a pre-flight checklist shows exactly what's complete and what's missing. No wasted workflows. No surprise errors.

---

## 8. The 18-Step Appraisal Order

**User Frustration:** Ordering a commercial appraisal in Encompass requires 18 discrete steps: type the appraisal number, type the fee, click three separate calendar popups for estimated/received/approved dates (each requiring 2 clicks), select from two dropdowns for "Generated By" and "Approved By," then type notes in two separate text fields. None of this is pre-populated from the appraisal vendor or order system. A single appraisal order takes more clicks than some entire mortgage applications in a modern system.

**Evidence:** 18 steps, 6 calendar clicks, 2 dropdown selections, 4 text entries — all manual, all for a single service order.

**The Confer LOS Advantage:** Our vendor integration layer auto-populates appraisal orders from the loan file. Property address, borrower name, and loan details flow directly to the appraisal management company. Order updates flow back automatically. The processor's role shifts from data entry clerk to exception handler.

---

## 9. Dead Screens and Lost Users

**User Frustration:** Multiple SOP segments show users "primarily hovering over UI elements" without interacting — lost in the interface trying to find the right button or tab. Two full 15-minute segments recorded zero user interactions while the screen remained static, either because the UI was unresponsive or the team was discussing workarounds for things the software couldn't do. In the borrower portal, one user clicked the same upload button 8 consecutive times with "0 Documents Uploaded" each time — the UI either broke or was so confusing the user couldn't complete a basic file upload.

**Evidence:** Two 15-minute dead-screen segments. 8 consecutive failed upload clicks. Multiple "user primarily hovering" observations documented by SOP transcribers.

**The Confer LOS Advantage:** Confer LOS is built on modern React with clear visual hierarchy, contextual tooltips, and guided workflows. Upload zones are drag-and-drop with instant progress feedback. Every screen has a "What should I do next?" indicator. No dead ends. No mystery buttons.

---

## 10. No International Support

**User Frustration:** Encompass was built for US domestic mortgages. Period. The MoXi team, which processes cross-border Mexico loans, faces constant friction: Mexico property addresses don't fit US address formats, Escritura documents have no document type in the system, commercial appraisals for Mexico properties require workarounds, Power of Attorney for cross-border signings must be managed manually, and the team explicitly discusses "challenges of integrating legal processes in Mexico with the software system Encompass." One processor entered a random US state in a fraud report just to avoid MERS charges on a non-US property.

**Evidence:** 4 documented sessions discussing Mexico/international integration gaps. Explicit statement: "challenges of integrating legal processes in Mexico with the software system Encompass."

**The Confer LOS Advantage:** Confer LOS is built with international lending in its DNA. Multi-currency support, flexible address formats, configurable document types, and a legal process framework that adapts to any jurisdiction. Cross-border isn't an afterthought — it's a feature.

---

## Bottom Line

| Encompass Pain Category | Documented Instances | Confer LOS Eliminates It? |
|---|---|---|
| Stare-and-Compare / Manual Cross-Reference | 6 workflows | YES — AI document extraction |
| Redundant Data Entry | 22+ duplicate fields | YES — Single data model |
| Multi-Window Chaos | 11 new-window spawns | YES — Single-page app |
| Excessive Clicking / Deep Navigation | 14-18 clicks per task | YES — Streamlined workflows |
| No Bulk Actions | 13+ one-by-one checkboxes | YES — Bulk review + AI pre-review |
| External Tool Dependencies | 6 separate tools | YES — Integrated platform |
| No Pre-Validation | Errors at final step | YES — Real-time validation |
| Manual Service Ordering | 18 steps per order | YES — Vendor API integration |
| Broken/Confusing UI | 8 failed clicks, dead screens | YES — Modern React UX |
| No International Support | 4 documented gap sessions | YES — Multi-jurisdiction by design |
