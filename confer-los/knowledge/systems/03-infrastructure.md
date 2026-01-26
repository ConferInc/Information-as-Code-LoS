# Infrastructure Guide

## Overview

This document provides a comprehensive overview of the LOS infrastructure, covering database schema, local development environment, CI/CD pipelines, and secret management.

---

## 1. Database Schema Overview

The LOS uses **PostgreSQL 16** with **Drizzle ORM** for type-safe database access. The schema is organized into core entities, workflow tables, and URLA-compliant customer portal tables.

### Core Tables Location
All schema definitions are located in `confer-los/packages/database/src/schema/`.

### 1.1 Core Entity Tables

#### Organizations (`organizations.ts:3-17`)
Multi-tenant root entity for all data.

**Key Fields:**
- `id` - UUID primary key
- `name` - Organization name
- `slug` - Unique URL-friendly identifier
- `settings` - JSONB for flexible configuration
- `billingStatus` - Enum: `trial`, `active`, `suspended`, `cancelled`
- `stripeCustomerId` - Stripe integration for billing

#### Users (`users.ts:4-22`)
System users (loan officers, processors, underwriters, admins).

**Key Fields:**
- `id` - UUID (matches Supabase Auth ID)
- `organizationId` - FK to organizations
- `role` - Enum: `borrower`, `loan_officer`, `processor`, `underwriter`, `admin`
- `systemAdmin` - Boolean for super-admin access
- `email` - Unique email address

**Auth Integration:** User IDs match Supabase `auth.users` table for seamless authentication.

#### Customers (`customers.ts:14-69`)
Borrower/co-borrower personal information (URLA Section 1a compliant).

**Key Fields:**
- `id` - UUID primary key
- `organizationId` - FK to organizations
- `customerType` - Enum: `person`, `company`
- **Personal Info:** `firstName`, `middleName`, `lastName`, `suffix`
- **Contact:** `email`, `phoneHome`, `phoneCell`, `phoneWork`
- **URLA Fields:**
  - `citizenshipType` - Enum: `us_citizen`, `permanent_resident_alien`, `non_permanent_resident_alien`
  - `maritalStatus` - Enum: `married`, `separated`, `unmarried`
  - `dependentCount`, `dependentAges`
  - `alternateNames` - JSONB array for credit matching
- **Sensitive Data:**
  - `ssnEncrypted` - Encrypted SSN
  - `dateOfBirth` - Date field
- **Portal Access:**
  - `authUserId` - Links to Supabase auth.users (set at step 10 when anonymous converts to real user)
  - `portalUserId` - Legacy portal access field

#### Application-Customer Junction (`customers.ts:71-111`)
Many-to-many relationship between applications and customers.

**Key Fields:**
- `applicationId`, `customerId` - FKs
- `role` - Enum: `primary`, `co_borrower`, `guarantor`, `occupant`
- `sequence` - Ordering of borrowers
- `ownershipPercentage` - Percentage of property ownership
- **URLA Fields:**
  - `willOccupyProperty` - Boolean (default: true)
  - `willBeOnTitle` - Boolean (default: true)
  - `creditType` - Enum: `individual`, `joint`
- **Portal Invitation:**
  - `inviteStatus` - Enum: `pending`, `sent`, `accepted`, `declined`, `expired`
  - `invitedAt`, `acceptedAt` - Timestamps
- **Deprecated eConsent Fields** (Task 070 - use `consents` table instead)

#### Applications (`applications.ts:8-38`)
Core loan application entity.

**Key Fields:**
- `id` - UUID primary key
- `organizationId` - FK to organizations
- `propertyId` - FK to properties
- `loanProductId` - FK to loan_products (required)
- `primaryCustomerId` - FK to customers (set at step 10)
- `title` - Application title
- `loanAmount` - Numeric loan amount
- `occupancyType` - Enum: `primary_residence`, `second_home`, `investment`
- `status` - Enum: `draft`, `submitted`, `in_review`, `processing`, `underwriting`, `clear_to_close`, `closing_scheduled`, `funded`, `withdrawn`, `denied`, `cancelled`
- `stage` - Enum: `prequal`, `processing`, `underwriting`, `closing`, `post_closing`
- `assignedTo` - FK to users
- `applicationNumber` - Unique identifier
- `keyInformation` - JSONB for flexible data
- `decisionResult` - JSONB for underwriting decisions
- **Timestamps:** `createdAt`, `updatedAt`, `submittedAt`, `fundedAt`

#### Properties (`properties.ts:4-24`)
Subject property information.

**Key Fields:**
- `id` - UUID primary key
- `organizationId` - FK to organizations
- `address` - JSONB for flexible address structure
- `countryCode` - Country code
- `propertyType` - Enum: `single_family`, `condo`, `townhouse`, `multi_family`, `land`, `commercial`
- `yearBuilt`, `squareFeet`, `bedrooms`, `bathrooms`
- `appraisedValue`, `purchasePrice` - Numeric values
- `metadata` - JSONB for additional data

#### Loan Products (`loan-products.ts:4-20`)
Configurable loan product templates.

**Key Fields:**
- `id` - UUID primary key
- `organizationId` - FK to organizations
- `name` - Product name
- `productType` - Enum: `conventional`, `fha`, `va`, `usda`, `jumbo`, `bridge`, `construction`
- `countryCode` - Country code
- `customerType` - Enum: `person`, `company`
- `template` - JSONB for product configuration
- `isActive` - Boolean

### 1.2 Workflow & Communication Tables

#### Tasks (`tasks.ts:7-24`)
Task management for loan processing.

**Key Fields:**
- `id` - UUID primary key
- `organizationId`, `applicationId`, `customerId` - FKs
- `title`, `description`
- `status` - Enum: `open`, `in_progress`, `completed`, `cancelled`
- `priority` - Enum: `low`, `medium`, `high`, `urgent`
- `assigneeId` - FK to users
- `dueDate`, `completedAt` - Timestamps

#### Additional Tables
- **Communications** (`communications.ts`) - Email, SMS, and communication tracking
- **Notes** (`notes.ts`) - Internal notes on applications/customers
- **Application Events** (`application-events.ts`) - Audit trail of application changes

### 1.3 URLA/Customer Portal Tables (Task 054)

Supporting tables for the Uniform Residential Loan Application:

- **Residences** (`residences.ts`) - Current and previous addresses
- **Employments** (`employments.ts`) - Employment history
- **Incomes** (`incomes.ts`) - Income sources
- **Assets** (`assets.ts`) - Bank accounts, investments, etc.
- **Liabilities** (`liabilities.ts`) - Debts and obligations
- **Real Estate Owned** (`real-estate-owned.ts`) - Other properties owned
- **Declarations** (`declarations.ts`) - URLA Section X declarations
- **Demographics** (`demographics.ts`) - HMDA reporting data
- **Documents** (`documents.ts`) - Document upload tracking
- **Gift Funds** (`gift-funds.ts`) - Gift fund sources

### 1.4 Agent Architecture Support (Tasks 069, 070)

- **Consents** (`consents.ts`) - eConsent and consent tracking

### 1.5 Drizzle ORM Configuration

**Location:** `confer-los/packages/database/drizzle.config.ts`

```typescript
{
  schema: './src/schema/index.ts',
  out: './migrations',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL || 'postgresql://moxi:moxi_dev_password@localhost:5432/moxi_los'
  },
  verbose: true,
  strict: true
}
```

**Key Configuration:**
- **Schema Entry Point:** `src/schema/index.ts` (exports all tables)
- **Migrations Output:** `./migrations` directory
- **Dialect:** PostgreSQL
- **Default URL:** Uses `DATABASE_URL` env var or falls back to local dev credentials

**Available Scripts** (`package.json:7-12`):
- `db:generate` - Generate migration files from schema changes
- `db:migrate` - Run pending migrations
- `db:push` - Push schema changes directly (dev only)
- `db:studio` - Launch Drizzle Studio GUI

### 1.6 Migrations

**Location:** `confer-los/packages/database/migrations/`

**Key Migrations:**
- `0000_zippy_vanisher.sql` - Initial schema
- `0001_heavy_mandarin.sql` - Schema updates
- `0002_auth_trigger.sql` - Supabase auth integration
- `0003_add_organization_id.sql` - Multi-tenancy support
- `0004_make_fks_nullable.sql` - FK constraint adjustments
- `0006_add_system_admin_column.sql` - System admin role
- `0007_add_missing_fields.sql` - Additional fields
- `0010_make_org_id_nullable.sql` - Organization ID nullability

**Meta Directory:** Contains Drizzle Kit snapshots and journal for version tracking.

---

## 2. Local Development Environment Setup

### 2.1 Docker Compose Configuration

**Location:** `confer-los/docker-compose.yml`

The local environment uses Docker Compose to run PostgreSQL 16.

#### Services

**PostgreSQL Service:**
```yaml
services:
  postgres:
    image: postgres:16-alpine
    container_name: confer-los-db
    restart: unless-stopped
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: confer
      POSTGRES_PASSWORD: confer_dev_password
      POSTGRES_DB: confer_los
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U confer"]
      interval: 10s
      timeout: 5s
      retries: 5
```

**Key Features:**
- **Image:** PostgreSQL 16 Alpine (lightweight)
- **Port:** 5432 (standard PostgreSQL port)
- **Database:** `confer_los`
- **Credentials:**
  - User: `confer`
  - Password: `confer_dev_password`
- **Data Persistence:** Named volume `postgres_data`
- **Health Check:** Ensures DB is ready before accepting connections

**Volume:**
```yaml
volumes:
  postgres_data:
```

Data persists across container restarts.

### 2.2 Starting the Environment

**Step 1: Start Docker Services**
```bash
cd confer-los
docker-compose up -d
```

**Step 2: Verify Database is Running**
```bash
docker-compose ps
# Should show confer-los-db as "healthy"
```

**Step 3: Run Migrations**
```bash
cd packages/database
pnpm db:migrate
```

**Step 4: (Optional) Launch Drizzle Studio**
```bash
pnpm db:studio
```

### 2.3 Environment Variables

**Database Package** (`confer-los/.env.example:1-2`):
```env
DATABASE_URL=postgresql://moxi:moxi_dev_password@localhost:5432/moxi_los
```

**Note:** The `.env.example` still references legacy `moxi` credentials. For local development with Docker Compose, use:
```env
DATABASE_URL=postgresql://confer:confer_dev_password@localhost:5432/confer_los
```

---

## 3. CI/CD Build Pipeline

### 3.1 Workflow Overview

The repository uses GitHub Actions for CI/CD with AI-powered code review and automation.

**Location:** `.github/workflows/`

### 3.2 Claude Code Workflows

#### Claude Code Action (`claude.yml:1-51`)
**Trigger:** Issue comments, PR review comments, issues opened/assigned, PR reviews submitted

**Conditions:** Activates when `@claude` is mentioned in:
- Issue comments
- PR review comments
- PR review bodies
- Issue titles/bodies

**Permissions:**
- `contents: read`
- `pull-requests: read`
- `issues: read`
- `id-token: write`
- `actions: read` (for reading CI results on PRs)

**Key Steps:**
1. Checkout repository (depth: 1)
2. Run Claude Code Action with OAuth token
3. Optional: Custom prompt configuration
4. Optional: Custom CLI arguments

**Configuration:**
```yaml
uses: anthropics/claude-code-action@v1
with:
  claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
  additional_permissions: |
    actions: read
```

#### Claude Code Review (`claude-code-review.yml:1-44`)
**Trigger:** Pull request events (`opened`, `synchronize`, `ready_for_review`, `reopened`)

**Purpose:** Automated code review on every PR.

**Permissions:**
- `contents: read`
- `pull-requests: read`
- `issues: read`
- `id-token: write`

**Key Steps:**
1. Checkout repository (depth: 1)
2. Run Claude Code Review plugin
3. Post review comments on PR

**Configuration:**
```yaml
uses: anthropics/claude-code-action@v1
with:
  claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
  plugin_marketplaces: 'https://github.com/anthropics/claude-code.git'
  plugins: 'code-review@claude-code-plugins'
  prompt: '/code-review:code-review ${{ github.repository }}/pull/${{ github.event.pull_request.number }}'
```

### 3.3 Gemini Workflows

#### Gemini Dispatch (`gemini-dispatch.yml:1-205`)
**Trigger:** PR review comments, PR reviews, PRs opened, issues opened/reopened, issue comments

**Purpose:** Orchestrates Gemini-powered PR reviews and issue triage.

**Workflow Jobs:**

1. **Debugger Job** (Optional)
   - Runs if `DEBUG` or `ACTIONS_STEP_DEBUG` is enabled
   - Prints event context for troubleshooting

2. **Dispatch Job**
   - **Conditions:**
     - PRs: Only if not from a fork
     - Issues: Only on open/reopen
     - Comments: Only if user types `@gemini-cli` and is OWNER/MEMBER/COLLABORATOR
   - **Command Extraction:**
     - `/review` - Code review
     - `/triage` - Issue triage
     - Custom commands - Generic invocation
   - **Acknowledgment:** Posts comment confirming request received

3. **Review Job** (`needs: dispatch`)
   - Triggers `gemini-review.yml` workflow
   - Runs when command is `review`

4. **Triage Job** (`needs: dispatch`)
   - Triggers `gemini-triage.yml` workflow
   - Runs when command is `triage`

5. **Invoke Job** (`needs: dispatch`)
   - Triggers `gemini-invoke.yml` workflow
   - Runs for custom commands

6. **Fallthrough Job**
   - Runs on failure or unrecognized command
   - Posts error comment with logs link

**GitHub App Token Minting:**
Uses `actions/create-github-app-token@v2` for enhanced permissions when `APP_ID` is configured.

#### Additional Gemini Workflows
- **gemini-review.yml** - Performs detailed code review
- **gemini-triage.yml** - Triages and labels issues
- **gemini-invoke.yml** - Handles custom commands
- **gemini-scheduled-triage.yml** - Scheduled issue triage

### 3.4 What Happens When You Push Code?

**Scenario 1: Push to PR Branch**
1. **Trigger:** `pull_request.synchronize` event fires
2. **Claude Code Review** runs automatically:
   - Analyzes diff
   - Checks code quality
   - Posts review comments
3. **Optional:** Developer can comment `@claude <instructions>` for specific tasks

**Scenario 2: Open New PR**
1. **Trigger:** `pull_request.opened` event fires
2. **Claude Code Review** runs automatically
3. **Gemini Dispatch** detects PR opened (if from non-fork):
   - Routes to `gemini-review.yml`
   - Performs review
   - Posts findings

**Scenario 3: Comment on Issue/PR**
1. **Trigger:** `issue_comment.created` or `pull_request_review_comment.created`
2. **Claude Workflow:** If comment contains `@claude`, Claude responds
3. **Gemini Workflow:** If comment starts with `@gemini-cli`, Gemini processes command

**Scenario 4: Open New Issue**
1. **Trigger:** `issues.opened` event fires
2. **Gemini Dispatch** routes to triage workflow:
   - Analyzes issue content
   - Suggests labels
   - Assigns to team members

---

## 4. Secret Management

### 4.1 Required Secrets by Category

#### Supabase Secrets (`confer-los/apps/confer-web/.env.example:1-8`)

**Public Supabase Configuration:**
- `NEXT_PUBLIC_SUPABASE_URL`
  - **Type:** Public URL
  - **Purpose:** Supabase project URL for client-side auth and database access
  - **Example:** `https://supabase.confersolutions.ai`
  - **Exposure:** Can be exposed to client (hence `NEXT_PUBLIC_` prefix)

- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
  - **Type:** Public anonymous key
  - **Purpose:** Client-side authentication and RLS-protected queries
  - **Format:** JWT token (long string)
  - **Exposure:** Safe for client exposure (RLS enforces security)

**Server-Only Supabase Configuration:**
- `SUPABASE_SERVICE_ROLE_KEY`
  - **Type:** Secret service role key
  - **Purpose:** Server-side operations bypassing RLS (admin access)
  - **Format:** JWT token (long string)
  - **Security:** NEVER expose to client - server-side only

**Application URL:**
- `NEXT_PUBLIC_APP_URL`
  - **Type:** Public URL
  - **Purpose:** Application base URL for OAuth redirects and absolute links
  - **Example:** `https://mortgage-loan-origination-system.vercel.app`

#### Temporal Secrets

**Inferred from** `confer-los/temporal/requirements.txt`:
- Temporal connection strings
- Temporal namespace credentials
- Temporal mTLS certificates (if applicable)

**Typical Configuration:**
```env
TEMPORAL_ADDRESS=temporal.example.com:7233
TEMPORAL_NAMESPACE=default
TEMPORAL_TASK_QUEUE=loan-processing
# Optional: mTLS
TEMPORAL_CLIENT_CERT=...
TEMPORAL_CLIENT_KEY=...
```

#### AI Provider Secrets

**Inferred from** `confer-los/temporal/requirements.txt:7-10`:
- LangChain Anthropic integration requires:
  - `ANTHROPIC_API_KEY` - Claude API key for AI agents (Tasks 037-038)

**Additional AI Providers (Common):**
- `OPENAI_API_KEY` - If using OpenAI models
- `LANGCHAIN_API_KEY` - For LangSmith tracing (optional)

#### CI/CD Secrets

**Required in GitHub Actions:**
- `CLAUDE_CODE_OAUTH_TOKEN`
  - **Purpose:** Authenticates Claude Code Action
  - **Location:** Repository secrets
  - **Workflows:** `claude.yml`, `claude-code-review.yml`

**Gemini Workflows:**
- `APP_PRIVATE_KEY`
  - **Purpose:** GitHub App private key for token minting
  - **Location:** Repository secrets
  - **Workflows:** `gemini-dispatch.yml`, `gemini-review.yml`, etc.

**Repository Variables:**
- `APP_ID` - GitHub App ID
- `DEBUG` - Enable debug mode (optional)

#### Database Secrets

**Local Development:**
```env
DATABASE_URL=postgresql://confer:confer_dev_password@localhost:5432/confer_los
```

**Production:**
```env
DATABASE_URL=postgresql://<user>:<password>@<host>:<port>/<database>?sslmode=require
```

**Note:** Production credentials should use connection pooling (e.g., Supabase Pooler):
```env
DATABASE_URL=postgresql://<user>:<password>@<pooler-host>:6543/<database>
```

#### Billing/Payment Secrets

**Inferred from** `organizations.ts:11`:
- `STRIPE_SECRET_KEY` - Stripe API key for billing
- `STRIPE_WEBHOOK_SECRET` - Stripe webhook signing secret

### 4.2 Environment Variable Checklist

**Minimum Required for Local Development:**
```env
# Database
DATABASE_URL=postgresql://confer:confer_dev_password@localhost:5432/confer_los

# Supabase (can use Supabase local dev or cloud)
NEXT_PUBLIC_SUPABASE_URL=https://supabase.confersolutions.ai
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# Application
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

**Additional Production Requirements:**
```env
# Temporal
TEMPORAL_ADDRESS=temporal.example.com:7233
TEMPORAL_NAMESPACE=production
TEMPORAL_TASK_QUEUE=loan-processing

# AI Providers
ANTHROPIC_API_KEY=sk-ant-...

# Stripe
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

### 4.3 Secret Rotation Best Practices

1. **Supabase Keys:**
   - Rotate service role key quarterly
   - Anon key rotation triggers client redeployment

2. **API Keys:**
   - Rotate AI provider keys every 90 days
   - Use separate keys for dev/staging/production

3. **Database Credentials:**
   - Use managed database services (Supabase handles rotation)
   - For self-hosted: rotate every 90 days, use connection pooling

4. **GitHub Tokens:**
   - Claude Code OAuth tokens expire per session
   - GitHub App private keys should be rotated annually

---

## 5. Python Environment (Temporal Workers)

### 5.1 Requirements Overview

**Location:** `confer-los/temporal/requirements.txt`

**Core Dependencies:**
- `temporalio>=1.5.0` - Temporal Python SDK for workflow orchestration
- `httpx>=0.26.0` - Async HTTP client for external API calls
- `python-dotenv>=1.0.0` - Environment variable loading
- `typing-extensions>=4.9.0` - Enhanced type hints (Python 3.9+)

**AI Agent Dependencies (Tasks 037-038):**
- `langgraph>=0.0.20` - State-based AI agent orchestration
- `langchain>=0.1.0` - LLM application framework
- `langchain-anthropic>=0.1.0` - Anthropic/Claude integration

### 5.2 Setup Instructions

**Step 1: Create Virtual Environment**
```bash
cd confer-los/temporal
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
```

**Step 2: Install Dependencies**
```bash
pip install -r requirements.txt
```

**Step 3: Configure Environment**
```bash
cp .env.example .env
# Edit .env with Temporal and API credentials
```

**Step 4: Run Temporal Worker**
```bash
python worker.py  # Adjust to actual worker script name
```

### 5.3 AI Agent Architecture (Tasks 037-038)

**Purpose:** Use LangGraph and LangChain for AI-powered loan processing agents.

**Example Use Cases:**
- Document classification and extraction
- Credit decision explanations
- Customer communication drafting
- Compliance checking

**Key Components:**
- **LangGraph:** State machine for multi-step agent workflows
- **LangChain:** LLM orchestration and prompt management
- **Anthropic Integration:** Claude API for natural language understanding

---

## 6. Infrastructure Checklist

### 6.1 New Developer Onboarding

- [ ] Clone repository
- [ ] Install Docker Desktop
- [ ] Start PostgreSQL: `docker-compose up -d`
- [ ] Install pnpm dependencies: `pnpm install`
- [ ] Create `.env` files (copy from `.env.example`)
- [ ] Run database migrations: `pnpm --filter @confer/database db:migrate`
- [ ] Start development server: `pnpm dev`
- [ ] (Optional) Setup Python environment for Temporal

### 6.2 Production Deployment Checklist

- [ ] Configure Supabase project (or PostgreSQL instance)
- [ ] Set up connection pooling (Supabase Pooler recommended)
- [ ] Configure all environment variables (see Section 4.2)
- [ ] Run database migrations on production DB
- [ ] Deploy Temporal workers
- [ ] Configure GitHub Actions secrets
- [ ] Set up Stripe webhook endpoints
- [ ] Enable RLS policies in Supabase
- [ ] Configure domain and SSL
- [ ] Test end-to-end authentication flow

### 6.3 Monitoring & Observability

**Database:**
- Use Drizzle Studio for schema inspection
- Monitor connection pool usage
- Set up slow query logging

**Temporal:**
- Monitor workflow execution via Temporal UI
- Set up alerts for failed workflows
- Track workflow latency

**Application:**
- Use Vercel Analytics (if deployed on Vercel)
- Configure error tracking (e.g., Sentry)
- Monitor API latency

**AI Agents:**
- Track LangChain trace data (LangSmith optional)
- Monitor Anthropic API usage and costs
- Log agent decision paths for audit

---

## 7. Common Operations

### 7.1 Database Operations

**Generate Migration:**
```bash
cd confer-los/packages/database
# 1. Modify schema in src/schema/*.ts
# 2. Generate migration
pnpm db:generate
# 3. Review generated SQL in migrations/
# 4. Apply migration
pnpm db:migrate
```

**Push Schema (Dev Only - Skips Migrations):**
```bash
pnpm db:push
```

**Launch Database GUI:**
```bash
pnpm db:studio
# Opens Drizzle Studio at http://localhost:4983
```

### 7.2 Docker Operations

**Start Services:**
```bash
docker-compose up -d
```

**Stop Services:**
```bash
docker-compose down
```

**View Logs:**
```bash
docker-compose logs -f postgres
```

**Reset Database (WARNING: Destroys Data):**
```bash
docker-compose down -v  # Removes volumes
docker-compose up -d
pnpm --filter @confer/database db:migrate
```

### 7.3 CI/CD Operations

**Trigger Claude Review Manually:**
1. Comment on PR: `@claude review this code for security issues`
2. Wait for workflow to complete
3. Review Claude's comments

**Trigger Gemini Triage:**
1. Comment on issue: `@gemini-cli /triage`
2. Gemini analyzes issue and suggests labels

**Check Workflow Status:**
```bash
gh run list  # List recent workflow runs
gh run view <run-id>  # View specific run details
```

---

## 8. Troubleshooting

### 8.1 Database Connection Issues

**Symptom:** Cannot connect to database

**Solutions:**
1. Verify Docker is running: `docker-compose ps`
2. Check health status: `docker-compose logs postgres`
3. Verify `.env` DATABASE_URL matches Docker credentials
4. Restart containers: `docker-compose restart`

### 8.2 Migration Failures

**Symptom:** `pnpm db:migrate` fails

**Solutions:**
1. Check migration files for syntax errors
2. Verify database is accessible
3. Run migrations manually: `psql -U confer -d confer_los -f migrations/<file>.sql`
4. Check for conflicting schema changes

### 8.3 CI/CD Workflow Failures

**Symptom:** GitHub Actions workflows fail

**Solutions:**
1. Check workflow logs: `gh run view <run-id>`
2. Verify secrets are configured: Settings → Secrets and variables → Actions
3. Check workflow permissions
4. Ensure `CLAUDE_CODE_OAUTH_TOKEN` is valid

### 8.4 Temporal Worker Issues

**Symptom:** Workers not processing workflows

**Solutions:**
1. Verify `TEMPORAL_ADDRESS` is correct
2. Check network connectivity to Temporal server
3. Ensure worker is polling correct task queue
4. Check worker logs for errors

---

## 9. Architecture Diagrams

### 9.1 Database Entity Relationships

```
Organizations (1) ──┬──< Users (N)
                    ├──< Customers (N)
                    ├──< Applications (N)
                    ├──< Loan Products (N)
                    └──< Properties (N)

Applications (1) ──┬──< Application-Customer (N) ──< Customers (1)
                   ├──< Tasks (N)
                   ├──< Application Events (N)
                   └──< Communications (N)

Customers (1) ──┬──< Residences (N)
                ├──< Employments (N)
                ├──< Incomes (N)
                ├──< Assets (N)
                ├──< Liabilities (N)
                └──< Real Estate Owned (N)
```

### 9.2 Local Development Stack

```
┌─────────────────────────────────────┐
│     Developer Machine               │
│                                     │
│  ┌──────────────────────────────┐  │
│  │   Next.js App (Port 3000)    │  │
│  │   - Web UI                   │  │
│  │   - API Routes               │  │
│  └──────────┬───────────────────┘  │
│             │                       │
│             ↓                       │
│  ┌──────────────────────────────┐  │
│  │   Supabase Client            │  │
│  │   - Auth                     │  │
│  │   - RLS Queries              │  │
│  └──────────┬───────────────────┘  │
│             │                       │
└─────────────┼───────────────────────┘
              │
              ↓
   ┌──────────────────────────────┐
   │   Docker Compose             │
   │                              │
   │  ┌────────────────────────┐  │
   │  │  PostgreSQL 16         │  │
   │  │  Port: 5432            │  │
   │  │  DB: confer_los        │  │
   │  └────────────────────────┘  │
   └──────────────────────────────┘
```

### 9.3 CI/CD Pipeline Flow

```
Developer Push
      │
      ↓
┌──────────────────┐
│  GitHub Actions  │
│  (PR Events)     │
└────┬─────────────┘
     │
     ├─────────────────────────┬──────────────────────┐
     ↓                         ↓                      ↓
┌─────────────┐      ┌──────────────────┐   ┌─────────────────┐
│  Claude     │      │  Gemini Dispatch │   │  Build/Test     │
│  Code       │      │  - Review        │   │  (Future)       │
│  Review     │      │  - Triage        │   │                 │
└─────────────┘      └──────────────────┘   └─────────────────┘
     │                         │                      │
     ↓                         ↓                      ↓
┌──────────────────────────────────────────────────────────┐
│              Post Review Comments to PR/Issue            │
└──────────────────────────────────────────────────────────┘
```

---

## 10. Additional Resources

### 10.1 Related Documentation

- **Database Schema Details:** `docs/database/current_schema_architecture.md`
- **Database Access Guide:** `docs/database/DATABASE_ACCESS_GUIDE.md`
- **Supabase Setup:** `docs/architecture/Supabase_CREDENTIALS_COMPLETE.md`
- **Temporal Setup:** `docs/infrastructure/temporal_setup.md`
- **Database Setup Guide:** `docs/guides/database_setup_guide.md`

### 10.2 External Documentation

- **Drizzle ORM:** https://orm.drizzle.team/docs/overview
- **PostgreSQL 16:** https://www.postgresql.org/docs/16/
- **Temporal Python SDK:** https://docs.temporal.io/develop/python
- **LangChain:** https://python.langchain.com/docs/get_started/introduction
- **LangGraph:** https://langchain-ai.github.io/langgraph/
- **Supabase:** https://supabase.com/docs
- **Claude API:** https://docs.anthropic.com/claude/reference/getting-started-with-the-api

### 10.3 Support Channels

- **Internal Issues:** GitHub Issues in this repository
- **Claude Code Questions:** Tag `@claude` in PR/issue comments
- **Gemini Triage:** Tag `@gemini-cli` in issue comments
- **Database Schema Questions:** Ask DevOps team

---

## Appendix: Complete Schema Table List

**Core Entities:**
- organizations
- users
- customers
- application_customers
- properties
- loan_products
- applications
- application_events

**Workflow & Communication:**
- tasks
- communications
- notes

**URLA/Customer Portal (Task 054):**
- residences
- employments
- incomes
- assets
- liabilities
- real_estate_owned
- declarations
- demographics
- documents
- gift_funds

**Agent Architecture (Tasks 069, 070):**
- consents

**Total Tables:** 22

---

**Document Version:** 1.0
**Last Updated:** 2026-01-26
**Maintained By:** DevOps & Database Engineering Team
