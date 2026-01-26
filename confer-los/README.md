# Confer LOS (Loan Origination System)

**Status**: Active Development
**Maintainers**: Confer LOS Team

## Overview
This repository contains the "Information as Code" for the Confer Loan Origination System. It serves as the single source of truth for architecture, decisions, meetings, and standard operating procedures.

## Quick Links
- [Architecture Map](knowledge/01-architecture-map.md)
- [Data Flow](knowledge/02-data-flow.md)
- [Infrastructure](knowledge/03-infrastructure.md)

## Onboarding Checklist
1.  [ ] **Read this README** entirely.
2.  [ ] **Clone the repo**: `git clone <repo-url>`
3.  [ ] **Install dependencies**: Follow instructions in `03-infrastructure.md`.
4.  [ ] **Review the Project Map** below.
5.  [ ] **Read the Contribution Guide**: [CONTRIBUTING.md](CONTRIBUTING.md).

## Repository Map
```
confer-los/
├── meetings/         # Meeting notes (organized by Year-Month)
├── projects/         # Active project documentation
├── knowledge/        # Persistent source of truth (Arch, Data, Infra)
│   ├── systems/      # Tech stack & configurations
│   ├── processes/    # Business logic & workflows
│   └── people/       # Team directory & domains
├── sops/             # Standard Operating Procedures
├── templates/        # Mandatory templates for all docs
├── assets/           # Index of large media files (Links only!)
└── dev-logs/         # Wispr flow developer logs
```

## "Information as Code" Philosophy
If it isn't documented in Markdown, it doesn't exist.
- **Meetings**: Must be documented in `meetings/YYYY-MM/`.
- **Decisions**: Must be recorded using the decision template.
- **Assets**: Large files go to Drive; links go here.
