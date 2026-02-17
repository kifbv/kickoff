# Kickoff

A framework for going from "I have a project idea" to autonomous implementation using the Ralph loop pattern.

## What is this?

Kickoff guides you through a series of phases to take a greenfield project from idea to working code:

1. **Interview** - Structured conversation to define your project's vision, users, and scope
2. **Infra** *(optional)* - Design AWS SAM serverless infrastructure from your project overview
3. **Design Sync** *(optional)* - Import UI mockups from Stitch to generate design-driven feature specs
4. **Discover** - Automatically generate detailed feature specs from your project overview
5. **Plan** - Create an implementation plan with atomic, prioritized tasks
6. **Build** - Autonomous loop that implements one task per iteration until done

## Prerequisites

**Required:**

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) - the CLI that powers the Ralph loop
- `bash` - ralph.sh requires Bash (not sh/zsh/fish)
- `git` - version control
- `jq` - JSON processing (used by ralph.sh to track story progress)
- `bc` - arithmetic (used by ralph.sh for cost tracking)
- `curl` - for the one-liner install and `update` command

**Recommended:**

- [obra/superpowers](https://github.com/obra/superpowers) skills - TDD, debugging, brainstorming, and other structured workflows that improve build quality
- [agent-browser](https://github.com/anthropics/agent-browser) skill - used by the build phase to verify UI changes in a real browser

**Optional:**

- [AWS MCP server](https://awslabs.github.io/mcp/) + [`aws` CLI](https://aws.amazon.com/cli/) + [`sam` CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html) - enables the `/infra` skill and SAM deployments during build. The MCP server requires [`uvx`](https://docs.astral.sh/uv/) to run.
- [Stitch MCP server](https://stitch.withgoogle.com/) - enables the `/design-sync` skill for importing UI mockups (see step 4 below)

## Quick Start

### 1. Scaffold a new project

**Option A: One-liner (no clone needed)**

```bash
curl -sfL https://raw.githubusercontent.com/kifbv/kickoff/main/scripts/install.sh | bash -s ~/Projects/my-app "My App"
cd ~/Projects/my-app
```

**Option B: From a local clone**

```bash
git clone git@github.com:kifbv/kickoff.git
./kickoff/scripts/scaffold.sh ~/Projects/my-app "My App"
cd ~/Projects/my-app
```

### 2. Define your project

```bash
./ralph/ralph.sh interview
```

This starts an interactive session that asks about your project idea, identifies Jobs to Be Done, scopes v1, and writes `specs/project-overview.md`.

### 3. (Optional) Design infrastructure

If your project needs AWS infrastructure:

```bash
./ralph/ralph.sh infra
```

This analyzes your project overview and designs a serverless architecture using AWS SAM, producing `specs/infrastructure.md`, `infra/template.yaml`, and `infra/samconfig.toml`.

### 4. (Optional) Import UI designs

If you have mockups in a [Stitch](https://stitch.withgoogle.com/) project, you can import them before generating specs:

```bash
/design-sync
```

This connects to your Stitch project, maps screens to the JTBD from the interview, generates feature specs with design references, synthesizes a design system (`designs/DESIGN.md`), and saves screen HTML to `designs/` as layout/styling references for the build phase. Any JTBD covered by designs will be skipped during the next step.

> **Note:** This is a Claude Code skill, not a ralph.sh command. Run it interactively in Claude Code.

### 5. Generate feature specs

```bash
./ralph/ralph.sh discover
```

Creates a detailed feature spec (`specs/[topic].md`) for each JTBD identified in the interview. JTBD already covered by design sync are skipped.

### 6. Create implementation plan

```bash
./ralph/ralph.sh plan
```

Produces `IMPLEMENTATION_PLAN.md` and `prd.json` with atomic, dependency-ordered user stories.

### 7. Build it

```bash
./ralph/ralph.sh build
```

Starts the Ralph loop. Each iteration picks one story, implements it, runs quality checks, commits, and updates progress. Continues until all stories pass.

## Updating an Existing Project

To pull the latest ralph.sh and prompt files into a scaffolded project:

```bash
cd ~/Projects/my-app
./ralph/ralph.sh update
```

This fetches the current versions of `ralph.sh` and all `PROMPT_*.md` files from upstream. Your specs, prd.json, progress, and source code are untouched.

## Commands

```bash
./ralph/ralph.sh interview              # Interactive project interview
./ralph/ralph.sh infra                  # AWS SAM infrastructure design
./ralph/ralph.sh discover [max]         # Feature spec generation
./ralph/ralph.sh plan [max]             # Gap analysis + task list
./ralph/ralph.sh plan-work "desc" [max] # Scoped planning
./ralph/ralph.sh build [max]            # Implementation (default)
./ralph/ralph.sh update                 # Update ralph files from upstream
./ralph/ralph.sh [max]                  # Shorthand for build
```

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `RALPH_MODEL` | opus (plan) / sonnet (build) | Claude model to use |
| `RALPH_DELAY` | 3 | Seconds between iterations |
| `PUSH_AFTER_ITERATION` | false | Git push after each iteration |
| `RALPH_UPSTREAM` | auto-detected | Override upstream URL for `update` command |

## Project Structure

After scaffolding, your project looks like:

```
my-app/
├── .claude/skills/            # Claude Code skills (design-sync, interview, etc.)
├── CLAUDE.md                  # Build/test/lint commands + operational notes
├── IMPLEMENTATION_PLAN.md     # Living task list
├── progress.txt               # Append-only learning log
├── prd.json                   # User stories with pass/fail tracking
├── specs/                     # Requirement specs (one per feature)
│   └── project-overview.md    # From interview phase
├── ralph/                     # Loop files
│   ├── ralph.sh
│   └── PROMPT_*.md
├── designs/                   # UI design references (from Stitch)
│   ├── DESIGN.md              # Synthesized design system tokens
│   └── prompts/               # Stitch-optimized prompts for missing screens
├── infra/                     # AWS SAM infrastructure (template.yaml, samconfig.toml)
├── archive/                   # Previous runs
└── src/                       # Your code
```

## Philosophy

Based on the [Ralph loop pattern](https://ghuntley.com/ralph/) by Geoffrey Huntley:

- **Fresh context per session** - Each iteration starts clean, no context pollution
- **One task per loop** - Maximum utilization of the model's "smart zone"
- **State via files** - `prd.json`, `progress.txt`, and git provide memory between sessions
- **Backpressure** - Tests, typechecks, and lints force correctness
- **Let Ralph Ralph** - Trust the loop to self-correct through iteration

See [docs/philosophy.md](docs/philosophy.md) for more details.

## Skills

When working in this repo with Claude Code, these skills are available:

- `/interview` - Start a project discovery interview
- `/infra` - Design AWS SAM serverless infrastructure
- `/discover` - Generate a feature spec from JTBD
- `/prd` - Create a PRD for a feature
- `/prd-to-json` - Convert a PRD to prd.json format
- `/design-sync` - Import UI designs from Stitch into project specs
- `/scaffold` - Scaffold a new project

## Credits

Inspired by:
- [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/)
- [Anthropic's autonomous coding quickstart](https://github.com/anthropics/claude-quickstarts)
- [Snarktank's Ralph implementation](https://github.com/snarktank/ralph)
- [Clayton Farr's Ralph playbook](https://github.com/ClaytonFarr/ralph-playbook)
- [Anthropic: Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
