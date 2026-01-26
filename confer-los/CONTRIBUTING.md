# Contributing to Confer LOS Documentation

## The Golden Rules

### 1. If It Was Discussed, It Gets Documented
Every meeting, call, or significant Slack conversation should result in a Markdown file. No exceptions.

### 2. Links Over Duplication
Do not commit large files (videos, PDFs, binaries) to this repository. Upload them to the shared Drive and create an entry in `assets/index.md` linking to them.

### 3. Use Templates
Always start with a template from the `templates/` directory. Do not invent your own format.

### 4. Commit Messages Matter
Write commit messages that explain *what knowledge was added*.

**Good:**
- `Add meeting notes from 2025-01-15 standup`
- `Document decision to use Temporal for workflows`

**Bad:**
- `Update`
- `Fix typos`

## Git Workflow

Follow this exact process to contribute code or documentation:

### 1. Pull & Version Check
Always start by ensuring you are on the latest version.
```bash
git checkout main
git pull origin main
```

### 2. Create Your Changes
- Create a new branch if the work is significant: `git checkout -b featured/your-feature-name`
- Make your changes using the templates provided.

### 3. Commit
Write a clear commit message explaining *what* changed.
```bash
git add .
git commit -m "feat: <description of changes>"
```

### 4. Push
```bash
git push origin <your-branch-name>
```

