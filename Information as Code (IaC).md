# Information as Code (IaC)

## A New Way of Working at Confer

***

## What is Information as Code?

**Information as Code**is how we manage knowledge at Confer. The core idea is simple:

> Every discussion, decision, and discovery gets documented in Markdown files, stored in Git repositories, just like code.

Think about how developers treat code: it's version-controlled, collaborative, searchable, and never lost. We're applying that same discipline to*everything else*— meeting notes, client knowledge, project decisions, and process documentation.

**Why "as Code"?**

* **Version controlled**— We can see who added what, when, and why
* **Collaborative**— Multiple people can contribute and review
* **Searchable**— AI agents can query and reason over the content
* **Persistent**— Knowledge doesn't leave when people leave

***

## Why Are We Doing This?

In most companies, critical knowledge lives in people's heads, scattered Slack messages, or random documents nobody can find. When someone leaves or takes time off, that knowledge often disappears.

At Confer, we're building differently from day one.

**The Problem We're Solving:**

* Team Member A has a call with a client on Monday
* Team Member A is off on Tuesday
* Team Member B needs to continue the work
* Without documentation, B has to guess, ask around, or wait

**The IaC Solution:**

* Team Member A's call gets documented in a Markdown file
* The file is committed to the client's repository
* Team Member B pulls the repo and has full context immediately
* Any AI agent (Claude Code, Cursor, Anti-Gravity) can also read and help

**This means:**

* No knowledge lives only in someone's head
* Anyone can pick up any project at any time
* AI agents become genuinely useful because they have context
* We build institutional memory that grows over time

***

## Our Repositories

We have**one repository per client/project**, plus one for internal Confer operations.

| Repository        | Purpose                                          | Who Uses It          |
| ----------------- | ------------------------------------------------ | -------------------- |
| `confer-moxi`     | MoXi client work (mortgage platform)             | MoXi team members    |
| `confer-temple`   | Temple (JKYog) client work                       | Temple team members  |
| `confer-odyssey`  | Odyssey client work                              | Odyssey team members |
| `confer-flexton`  | Flexton client work                              | Flexton team members |
| `confer-los`      | Confer's own Loan Origination System product     | LOS team members     |
| `confer-internal` | Internal processes, templates, company knowledge | Everyone             |

**Important:**`confer-internal`contains templates, processes, and guidelines that apply across all projects. Always check there first when you're unsure how to do something.

***

## Repository Structure

Every client repository follows the same structure. Once you learn one, you know them all.

```
confer-[client]/
│
├── README.md                 ← Start here! Client overview and current status
├── CONTRIBUTING.md           ← How to add content to this repo
├── .cursorrules              ← Instructions for AI agents
│
├── meetings/                 ← All meeting documentation
│   ├── 2025-01/
│   │   ├── 2025-01-15-standup.md
│   │   └── 2025-01-16-planning.md
│   └── 2025-02/
│
├── projects/                 ← Active project documentation
│   ├── project-alpha/
│   │   ├── README.md         ← Project overview and status
│   │   ├── requirements/
│   │   ├── decisions/
│   │   └── deliverables/
│   └── project-beta/
│
├── knowledge/                ← Persistent knowledge about the client
│   ├── systems/              ← Their tech stack, configurations
│   ├── processes/            ← Their business processes
│   └── people/               ← Org chart, key contacts
│
├── assets/                   ← Index of large files (videos, PDFs)
│   └── index.md              ← Links and descriptions, not the files themselves
│
└── sops/                     ← Standard Operating Procedures we've created

```

***

## The Golden Rules

### Rule 1: If It Was Discussed, It Gets Documented

Every meeting, call, or significant Slack conversation should result in a Markdown file. No exceptions.

* Client standup? → Meeting note
* Architecture discussion? → Meeting note + decision record
* Quick call to clarify something? → At minimum, update the relevant project README

### Rule 2: Links Over Duplication

Large files (videos, PDFs, design files) live in Google Drive or other storage. The repository contains**links and context**, not the files themselves.

**Good:**

```
## Training Video
- **Location**: [Google Drive - MoXi Folder](https://drive.google.com/...)
- **Duration**: 45 minutes
- **Topics Covered**: Encompass loan submission workflow
- **Key Timestamps**:
  - 05:30 - Borrower information screen
  - 22:15 - Document upload process

```

**Bad:**&#x55;ploading a 2GB video file to the Git repository.

### Rule 3: Structure Enables AI

We use consistent formatting so AI agents can parse and understand our documentation. This means:

* Always include YAML frontmatter (the stuff between`---`at the top)
* Use clear headings (`##`,`###`)
* Follow the templates in`confer-internal/templates/`

### Rule 4: Commit Messages Matter

Write commit messages that explain*what knowledge was added*:

**Good:**

* `Add meeting notes from 2025-01-15 client standup`
* `Document decision to use Webflow for website redesign`
* `Update Encompass knowledge with loan limit fields`

**Bad:**

* `Update`
* `Changes`
* `Fixed stuff`

***

## Meeting Documentation Workflow

This is the most common workflow you'll follow.

### Step 1: Meeting Happens

Someone from Confer attends a meeting with a client or internal team.

### Step 2: Raw Material Gets Saved

The meeting host (or designated person) saves the raw transcript or recording:

* **Dialpad calls**: Transcript is automatically available
* **Zoom calls**: Request recording/transcript from host, or take notes
* **In-person/other**: Take notes during the meeting

Save raw materials to the appropriate Google Drive folder.

### Step 3: Create the Markdown File

Using the transcript/notes, create a properly formatted Markdown file.

You can (and should) use AI to help:

1. Open Claude Code, Cursor, or Anti-Gravity
2. Provide the transcript and our meeting template
3. Ask it to generate the structured meeting note
4. Review and edit for accuracy

### Step 4: Commit and Push

```
git add meetings/2025-01/2025-01-15-standup.md
git commit -m "Add meeting notes from 2025-01-15 client standup"
git push

```

### Step 5: Knowledge Is Now Live

Anyone on the team can now:

* Read the meeting notes directly
* Ask an AI agent "What was decided in the January 15th standup?"
* Continue work without needing to ask the original attendee

***

## File Templates

Always use these templates. They're available in`confer-internal/templates/`.

### Meeting Note Template

```
---
type: meeting
date: YYYY-MM-DD
attendees:
  - Name (Confer)
  - Name (Client)
client: [Client Name]
project: [Project Name or "general"]
recording: [Link if available]
transcript_source: [dialpad/zoom/manual]
tags: [topic1, topic2, topic3]
---

# [Meeting Title]

## Summary
[2-3 sentence executive summary of what was discussed and decided]

## Key Decisions
- **Decision 1**: [What was decided]
  - Rationale: [Why]
  - Owner: [Who is responsible]
  - Deadline: [If applicable]

## Action Items
- [ ] @person - Task description - Due date
- [ ] @person - Task description - Due date

## Discussion Notes
### [Topic 1]
[Notes organized by topic]

### [Topic 2]
[Notes organized by topic]

## Open Questions
- [Questions that weren't resolved]

## Related Documents
- [[Link to related meeting or document]]

```

### Decision Record Template

Use this when a significant decision is made that affects the project direction.

```
---
type: decision
date: YYYY-MM-DD
status: [proposed/accepted/superseded/deprecated]
client: [Client Name]
project: [Project Name]
decision_makers:
  - Name
  - Name
tags: [topic1, topic2]
---

# [Decision Title]

## Context
[What situation or problem led to this decision?]

## Options Considered
1. **Option A** - [Brief description]
2. **Option B** - [Brief description]
3. **Option C** - [Brief description]

## Decision
We will [clearly state the decision].

## Rationale
[Why did we choose this option over others?]

## Consequences
[What are the implications of this decision? What do we gain? What do we accept?]

## Related
- [[Link to meeting where this was discussed]]

```

### Project README Template

Every project folder should have a README.md:

```
---
type: project
client: [Client Name]
project: [Project Name]
status: [active/on-hold/completed]
start_date: YYYY-MM-DD
team:
  - Name (Role)
  - Name (Role)
---

# [Project Name]

## Overview
[What is this project? What are we trying to accomplish?]

## Current Status
[What's happening right now? What's the next milestone?]

**Last Updated**: YYYY-MM-DD

## Goals
1. [Goal 1]
2. [Goal 2]
3. [Goal 3]

## Key Decisions
- [[decisions/decision-name.md]] - [Brief description]

## Important Links
- [Link to Figma/Design]
- [Link to Staging Environment]
- [Link to Client Documents]

## Team & Responsibilities
| Person | Role | Responsibilities |
|--------|------|------------------|
| Name | Lead | Overall delivery |
| Name | Dev | Implementation |

## Timeline
| Milestone | Target Date | Status |
|-----------|-------------|--------|
| Milestone 1 | YYYY-MM-DD | ✅ Complete |
| Milestone 2 | YYYY-MM-DD | 🔄 In Progress |
| Milestone 3 | YYYY-MM-DD | ⏳ Upcoming |

```

***

## Working with AI Agents

One of the biggest benefits of IaC is that AI agents become*actually useful*because they have context.

### Using Claude Code / Cursor

When you start working on a client project:

1. Open the repository in your editor
2. The AI agent automatically has access to all documentation
3. You can ask questions like:
   * "What was decided about the authentication approach?"
   * "Summarize the last three standup meetings"
   * "What do we know about their Encompass configuration?"

### Using Anti-Gravity

Point Anti-Gravity at a repository and it can:

* Generate summaries across multiple documents
* Answer questions about project history
* Help create new documentation from transcripts

### The .cursorrules File

Each repository contains a`.cursorrules`file that instructs AI agents how to navigate the repo. You don't need to modify this, but understand it exists to help AI tools work better.

***

## Your Responsibilities

### If You Attend a Meeting

1. Ensure the recording/transcript gets saved to Google Drive
2. Either create the meeting note yourself, OR
3. Hand off to a teammate to create it (with clear context)
4. Verify the meeting note is committed within 24 hours

### If You're Assigned to Process Documentation

1. Check the Google Drive folder for raw materials
2. Use AI tools + templates to create structured Markdown
3. Review for accuracy (AI can miss things or hallucinate)
4. Commit with a clear commit message
5. If anything is unclear, ask rather than guess

### If You're Picking Up Work on a Project

1. Pull the latest from the repository
2. Read the project README for current status
3. Check recent meeting notes for context
4. Use AI to help summarize if there's a lot to catch up on
5. You should be able to start working without asking "what's going on?"

***

## Common Questions

### "What if the meeting was really short/informal?"

Still document it. Even a 5-minute call can contain a decision that matters later. The note can be brief:

```
---
type: meeting
date: 2025-01-15
attendees: [Yatin, Jane]
client: Temple
tags: [quick-sync]
---

# Quick Sync - Domain Configuration

## Summary
Quick call to confirm DNS settings for new subdomain.

## Decisions
- Will use blog.temple.org for the new content section
- Jane to update DNS by EOD Friday

```

### "What if I don't have time to create the documentation?"

Hand off the raw materials (transcript, recording link) to someone who can process it. The key is that*someone*does it. Knowledge delayed is better than knowledge lost.

### "What if the AI generates something incorrect?"

Always review AI-generated content before committing. AI is a tool to speed up the process, not a replacement for human verification. You are responsible for the accuracy of what you commit.

### "What if I'm not sure which project a meeting relates to?"

* If it's clearly about a specific project → that project's folder
* If it's a general client standup → meetings folder at root level
* If it touches multiple projects → meetings folder, with links to relevant projects

When in doubt, ask in Slack.

### "Where do I put internal Confer discussions?"

In`confer-internal`. This includes:

* Team process discussions
* Tool evaluations
* Company-wide decisions
* Anything not specific to a client

***

## Getting Started Checklist

* \[ ] Get access to the repositories you'll be working with
* \[ ] Clone`confer-internal`and read through the templates
* \[ ] Clone your assigned client repository and read the README
* \[ ] Review recent meeting notes to understand the format
* \[ ] Set up your AI tools (Claude Code, Cursor, etc.) with repo access
* \[ ] Process your first meeting note using the template
* \[ ] Ask questions if anything is unclear

***

## Remember

> **The goal is not perfect documentation. The goal is that no knowledge lives only in someone's head.**

A rough meeting note committed today is infinitely more valuable than a perfect meeting note that never gets written.

When in doubt: document it, commit it, move on.

***

*This document lives in**`confer-internal/processes/information-as-code-guide.md`**. If you have suggestions for improvements, submit a PR.*
