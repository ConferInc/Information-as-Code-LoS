# Confer LOS (Loan Origination System)

**Status**: Active Development
**Maintainers**: Confer LOS Team
**Last Updated**: 2026-02-13

## Overview

This repository contains the **Information as Code** for the Confer Loan Origination System. It serves as the single source of truth for architecture, decisions, database schemas, persona-driven screen specifications, compliance analysis, and standard operating procedures.

All documentation follows the [Information as Code (IaC)](Information%20as%20Code%20(IaC).md) philosophy: version-controlled, collaborative, searchable, and persistent.

## Quick Links

### Architecture & Systems
- [Architecture Map](confer-los/knowledge/systems/01-architecture-map.md)
- [Data Flow](confer-los/knowledge/systems/02-data-flow.md)
- [Infrastructure](confer-los/knowledge/systems/03-infrastructure.md)

### Database (Supabase)
- [Architecture Overview](confer-los/knowledge/supabase-docs/00-architecture-overview.md)
- [Schema Map (Full ER Diagram)](confer-los/knowledge/supabase-docs/01-schema-map.md)
- [Agent Context (AI Reference)](confer-los/knowledge/supabase-docs/agent-context.md)

### Persona Screen Schemas
- [01 Borrower](confer-los/knowledge/personas/01_Borrower/) — Lead Capture, Application (1003), Conditions Upload, Closing/Signing
- [02 Sales/MLO](confer-los/knowledge/personas/02_Sales_MLO/) — Lead Intake (CRM + LOS)
- [03 Processor](confer-los/knowledge/personas/03_Processor/) — File Setup, Third Party Orders, Submission to UW, Conditions Management
- [04 Underwriter](confer-los/knowledge/personas/04_Underwriter/) — Initial Review, Decisioning
- [05 Closer](confer-los/knowledge/personas/05_Closer/) — CD Preparation, Funding

### Reports
- [Compliance Gap Analysis (Feb 2026)](confer-los/reports/2026-02-compliance-gap-analysis.md)

## Repository Map

```
confer-los/
├── knowledge/
│   ├── systems/              # Architecture, data flow, infrastructure
│   ├── supabase-docs/        # Database schema documentation (27+ tables)
│   │   ├── tables/           # Individual table docs (auth, loans, assets, etc.)
│   │   ├── 00-architecture-overview.md
│   │   ├── 01-schema-map.md
│   │   └── agent-context.md
│   ├── personas/             # Screen schemas by persona (13 files)
│   │   ├── 01_Borrower/      # Lead Capture, 1003, Conditions, Closing
│   │   ├── 02_Sales_MLO/     # Lead Intake (Salesforce + Encompass)
│   │   ├── 03_Processor/     # File Setup, Orders, UW Submission, Conditions
│   │   ├── 04_Underwriter/   # Initial Review, Decisioning
│   │   └── 05_Closer/        # CD Preparation, Funding
│   ├── processes/            # Business logic & workflows (BPMN)
│   └── people/               # Team directory & domains
├── reports/                  # Compliance & audit reports
├── meetings/                 # Meeting notes (organized by YYYY-MM)
├── projects/                 # Active project documentation
├── sops/                     # Standard Operating Procedures
├── templates/                # Mandatory templates for all docs
├── assets/                   # Index of large media files (links only)
└── dev-logs/                 # Developer logs

Detailed SOP/                 # Raw MoXi SOP action logs (source material)
PERSONAS AND README FILE/     # Raw persona definitions & modular stubs (source material)
NOTEBOOK LM Sources/          # Regulatory documents & compliance references (source material)
```

## Persona Screen Schemas

Each screen schema in `knowledge/personas/` contains:

| Section | Content |
|---|---|
| **UI Component Map** | Every field, dropdown, button with data types and validation rules |
| **Database Mapping** | Direct mapping to Supabase tables/columns |
| **Schema Change Proposals** | Missing fields/tables with proposed SQL migrations |
| **Workflow & Triggers** | User actions and resulting system state changes |
| **Compliance Notes** | Regulatory status per field (URLA, TRID, ECOA, etc.) |
| **MoXi-Specific Customizations** | Cross-border items isolated from US base |

## Onboarding Checklist

1. [ ] **Read this README** entirely
2. [ ] **Clone the repo**: `git clone https://github.com/ConferInc/Information-as-Code-LoS.git`
3. [ ] **Read the IaC Guide**: [Information as Code (IaC).md](Information%20as%20Code%20(IaC).md)
4. [ ] **Review the Database Schema**: Start with [00-architecture-overview.md](confer-los/knowledge/supabase-docs/00-architecture-overview.md)
5. [ ] **Review Persona Schemas**: Start with [01_Borrower/01_Lead_Capture.md](confer-los/knowledge/personas/01_Borrower/01_Lead_Capture.md)
6. [ ] **Read the Compliance Report**: [2026-02-compliance-gap-analysis.md](confer-los/reports/2026-02-compliance-gap-analysis.md)
7. [ ] **Read the Contribution Guide**: [CONTRIBUTING.md](confer-los/CONTRIBUTING.md)

## "Information as Code" Philosophy

> If it isn't documented in Markdown, it doesn't exist.

- **Meetings**: Must be documented in `meetings/YYYY-MM/`
- **Decisions**: Must be recorded using the decision template
- **Assets**: Large files go to Drive; links go here
- **Schema Changes**: Proposed in persona screen schemas with SQL migration code
- **Compliance Gaps**: Tracked in `reports/` with severity ratings and priority roadmap
