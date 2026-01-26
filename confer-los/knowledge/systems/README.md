# Systems

The `systems` directory contains technical reference documentation for the Confer LOS.

## Contents

### [01-architecture-map.md](01-architecture-map.md)
**High-Level Overview**
- **Frontend**: Next.js 16, React 19, Tailwind v4
- **Backend**: Python 3.9+ running Temporal Workflows
- **Package Architecture**: Monorepo with shared packages (`@confer/auth`, `@confer/database`, etc.)
- **AI**: LangGraph agents powered by Anthropic Claude 3.5 Sonnet
- **Data**: Supabase (PostgreSQL 16) self-hosted on Coolify

### [02-data-flow.md](02-data-flow.md)
**Critical User Flows**
1.  **Borrower Apply Flow**: 39-step URLA-compliant wizard. Handles anonymous-to-authenticated transitions.
2.  **Underwriting Workflow**: Durable Temporal workflow executing parallel document collection (Credit, Appraisal, Title) and AI decisioning.
3.  **AI Integration**: LangGraph agent performing Credit, Collateral, and Capacity analysis.

### [03-infrastructure.md](03-infrastructure.md)
**DevOps & Schema**
- **Database**: 10 essential tables including `applications`, `customers`, and `loan_products`.
- **Infrastructure**: Docker Compose for local dev, GitHub Actions for CI/CD (Claude Code reviews, Gemini triage).
- **Secrets**: Management of Supabase keys, Stripe secrets, and Temporal credentials.
