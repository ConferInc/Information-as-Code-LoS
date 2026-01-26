#!/bin/bash

# REPO NAME
REPO_NAME="confer-los"

echo "🚀 Initializing Information as Code structure for $REPO_NAME..."

# 1. Create Directories
mkdir -p "$REPO_NAME"
cd "$REPO_NAME"

# Standard IaC Structure
mkdir -p meetings/$(date +%Y-%m)
mkdir -p projects
mkdir -p knowledge
mkdir -p assets
mkdir -p sops

# Custom folders for your workflow
mkdir -p templates
mkdir -p dev-logs/$(date +%Y-%m)
mkdir -p reports

echo "✅ Created directory structure."

# 2. Populate Knowledge (From your uploaded files)
# We accept that these files are the "Holy Grail" of the system currently.

# Knowledge: Architecture
cat <<EOF > knowledge/01-architecture-map.md
[Content from 01-architecture-map.md would be pasted here. 
For now, this placeholder represents the file you provided.]
EOF

# Knowledge: Data Flow
cat <<EOF > knowledge/02-data-flow.md
[Content from 02-data-flow.md would be pasted here.]
EOF

# Knowledge: Infrastructure
cat <<EOF > knowledge/03-infrastructure.md
[Content from 03-infrastructure.md would be pasted here.]
EOF

echo "✅ Injected Knowledge Base (Architecture, Data Flow, Infra)."

# 3. Create Root README (The Dashboard)
cat <<EOF > README.md
---
type: project
project: Confer Loan Origination System (LOS)
status: active
maintainer: System Architect
stack: [Next.js 16, Python, Temporal, Supabase, LangGraph]
---

# Confer Loan Origination System (LOS)

## Overview
The Confer LOS is a **multi-tenant, platform-first monorepo** designed to power modern lending applications. It combines a Next.js frontend with a Python-based Temporal workflow engine.

## Quick Links
- **Architecture**: [[knowledge/01-architecture-map.md]]
- **Data Flow**: [[knowledge/02-data-flow.md]]
- **Infrastructure**: [[knowledge/03-infrastructure.md]]

## Active Development
- **Latest Dev Log**: [[dev-logs/$(date +%Y-%m)/$(date +%Y-%m-%d)-update.md]]
- **Current Sprint**: [Link to Jira/Linear]

## Repository Structure
- \`knowledge/\`: Immutable facts about the system.
- \`meetings/\`: Decision records and transcripts.
- \`dev-logs/\`: Daily dumps of code changes and thoughts.
- \`templates/\`: Standard formats for AI generation.

EOF
echo "✅ Created README.md."

# 4. Create .cursorrules (The Brain for AI)
cat <<EOF > .cursorrules
You are an expert software architect and technical writer working on the Confer LOS.

# Context
This is a sophisticated monorepo using:
- **Frontend**: Next.js 16, React 19, Tailwind v4
- **Backend**: Python 3.9+, Temporal (Workflows), LangGraph (AI Agents)
- **Database**: Supabase (PostgreSQL 16), Drizzle ORM

# Rules
1. **Knowledge First**: Before answering technical questions, ALWAYS check \`knowledge/01-architecture-map.md\` and \`knowledge/02-data-flow.md\`.
2. **Templates**: When asked to generate a document, strictly follow the formats in \`templates/\`.
3. **No Hallucinations**: If a specific table or API endpoint isn't in the knowledge folder, say "I don't see that in the docs" rather than guessing.
4. **Links**: Use wiki-style links [[filename]] when referencing other documents.

# Tone
Technical, precise, and structured.
EOF
echo "✅ Created .cursorrules."

echo "🎉 confer-los setup complete. Ready for template injection."