# Ralph Loop Philosophy

## Core Principle: Context Is Everything

With ~176K truly usable tokens from a 200K+ context window, and 40-60% being the "smart zone," the strategy is:

- **One task per loop iteration** = 100% smart zone utilization
- **Fresh context each iteration** = no context pollution
- **Deterministic input loading** = same files loaded each time for known state

## Three Phases, One Loop

The same bash loop mechanism (`while :; do cat PROMPT.md | claude ; done`) handles both planning and building. The mode is determined by which prompt is fed:

| Mode | Purpose | Prompt |
|------|---------|--------|
| Interview | Understand the project | PROMPT_interview.md |
| Discover | Create feature specs | PROMPT_discover.md |
| Plan | Gap analysis, task list | PROMPT_plan.md |
| Build | Implement one story | PROMPT_build.md |

## Steering Ralph

### Upstream (Deterministic Setup)

Control what Ralph sees at the start of each iteration:
- `specs/*` - The requirements (what to build)
- `CLAUDE.md` - Operational guide (how to build/test)
- `prd.json` - The task contract (what's done, what's next)
- `progress.txt` - Learning log (patterns, gotchas)

If Ralph generates wrong patterns, add utilities and code patterns to steer toward correct ones.

### Downstream (Backpressure)

Control what Ralph must satisfy before committing:
- Tests must pass
- Typecheck must pass
- Lint must pass
- Browser verification for UI stories
- Custom quality gates in CLAUDE.md

## Key Patterns

### Let Ralph Ralph

Trust the loop to self-correct through iteration. Ralph's effectiveness depends on:
- Eventual consistency through iteration
- Self-identification and self-correction
- Learning from code patterns, utilities, and prior iterations

### Plans Are Disposable

A wrong or stale plan is cheap to regenerate. Throw it out and re-run the planning loop when:
- Ralph keeps implementing the wrong things
- The plan has too much clutter
- Specs changed significantly
- Confusion about what's done vs. what's not

### Start Empty, Tune Reactively

1. Start with an empty `CLAUDE.md` (no "best practices")
2. Watch initial loops, see where gaps occur
3. Add signs (prompt text, CLAUDE.md, code patterns) only as needed
4. Tune like a guitar: observe, adjust, repeat

### Feature Atomicity

Each user story must be completable in one context window. This prevents:
- Context exhaustion mid-implementation
- Half-completed code
- Broken state between sessions

**Rule of thumb:** If you can't describe the change in 2-3 sentences, it's too big.

## Safety: Sandbox Philosophy

Ralph requires `--dangerously-skip-permissions` to operate autonomously. The sandbox is your security boundary.

> "It's not if it gets popped, it's when. And what is the blast radius?"

Recommendations:
- Run in isolated environments (Docker, E2B, Fly Sprites)
- Minimum viable access: only needed API keys
- No access to private data beyond requirements
- Restrict network where possible

## State Files

| File | Role | Rules |
|------|------|-------|
| `specs/*.md` | Source of truth for requirements | Written in phases 1-2, rarely changed after |
| `prd.json` | Task contract | Only `passes` and `notes` fields change during build |
| `IMPLEMENTATION_PLAN.md` | Living task list | Updated every iteration, disposable |
| `progress.txt` | Learning log | Append-only. Codebase Patterns section at top |
| `CLAUDE.md` | Operational guide | Brief (~60 lines). Build/test commands + gotchas |
| Git history | Full audit trail | One commit per completed story |
