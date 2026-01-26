# Processes

This directory contains the business process documentation and workflow definitions for the Confer Loan Origination System.

## Architecture & Workflows

The core workflows are defined using **BPMN 2.0 models** structured in a four-level hierarchy (L0-L3). These models serve as the source of truth for how the system handles loan origination, from pre-qualification to funding.

**[➤ View Detailed BPMN Documentation](workflows/bpmn/README.md)**

### Hierarchy Overview

- **L0 - Executive Overview**: A single high-level diagram showing the entire lifecycle (Pre-Qual → Funding).
- **L1 - Process Overview**: Phase-specific diagrams (e.g., Application, Processing) showing major steps and handoffs.
- **L2 - Detailed Process**: Subprocesses for specific activities (e.g., "Document Upload", "Credit Review").
- **L3 - Operational Detail**: (Planned) Granular, click-by-click instructions and field-level logic.

### Agentic Architecture

The system utilizes an **AI-First Processing** model, moving away from linear workflows to an event-driven agentic architecture.

- **Orchestrating Agents (15)**: Drive processes and make high-level decisions (e.g., "Credit Agent", "Fraud Detection Agent").
- **Worker Agents (12)**: Execute specific tasks reliably (e.g., "Email Agent", "PDF Generator").

See the [BPMN README](workflows/bpmn/README.md#agentic-architecture-ai-first-processing) for a detailed catalog of agents and their interactions with the BPMN models.
