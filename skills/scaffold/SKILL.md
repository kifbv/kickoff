---
name: scaffold
description: "Scaffold a new project for Ralph loop development. Creates directory structure, copies templates and prompts, initializes git. Triggers on: scaffold project, new project setup, create project, init ralph project."
user-invocable: true
---

# Project Scaffolding

Set up a new project directory with everything needed for Ralph loop development.

---

## The Job

1. Ask for the target directory and project name
2. Run the scaffold script to create the project structure
3. Guide the user on next steps

---

## Usage

Ask the user for:
- **Target directory:** Where to create the project (e.g., `~/Projects/movie-tracker`)
- **Project name:** Human-readable name (e.g., "Movie Tracker")

Then run:
```bash
./scripts/scaffold.sh <target-directory> "<project-name>"
```

---

## What Gets Created

```
target-project/
├── CLAUDE.md              # Operational guide (build/test/lint commands)
├── IMPLEMENTATION_PLAN.md # Living task list (populated by plan mode)
├── progress.txt           # Append-only learning log
├── specs/                 # Requirement specs (one per JTBD)
├── ralph/                 # Loop files
│   ├── ralph.sh           # The loop script
│   ├── PROMPT_plan.md     # Planning prompt
│   ├── PROMPT_build.md    # Building prompt
│   ├── PROMPT_plan_work.md # Scoped planning prompt
│   ├── PROMPT_discover.md # Feature discovery prompt
│   └── PROMPT_interview.md # Interview prompt
├── archive/               # Previous Ralph runs
└── src/                   # Application source code
```

---

## Next Steps After Scaffolding

Guide the user through:

1. `cd <target-directory>`
2. Edit `CLAUDE.md` to add project-specific build/test/lint commands
3. Run `./ralph/ralph.sh interview` to define the project
4. Run `./ralph/ralph.sh discover` to generate feature specs
5. Run `./ralph/ralph.sh plan` to create implementation plan
6. Run `./ralph/ralph.sh build` to start building
