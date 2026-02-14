# Kickoff

Greenfield project scaffolding framework using the Ralph loop pattern.

## Structure

- `scripts/` - Core scripts (ralph.sh loop, scaffold.sh)
- `prompts/` - Prompt templates for each phase (interview, discover, plan, build)
- `templates/` - Files copied into scaffolded projects
- `skills/` - Claude Code skills (interview, discover, prd, prd-to-json, scaffold, design-sync)
- `docs/` - Documentation

## How It Works

4-phase workflow: Interview -> Discover -> Plan -> Build

1. `scaffold.sh` creates a new project directory
2. `ralph.sh interview` interviews the user to produce `specs/project-overview.md`
3. `ralph.sh discover` creates feature specs from the JTBD in the overview
4. `ralph.sh plan` creates `IMPLEMENTATION_PLAN.md` + `prd.json` from specs
5. `ralph.sh build` implements stories from prd.json one per iteration

## Editing Prompts

Prompts in `prompts/` follow the Playbook structure:
- Phase 0 (0a, 0b, 0c): Orient - study specs, source, plan
- Phase 1-N: Main task instructions
- 999... numbering: Guardrails (higher number = more critical)

## Testing Changes

```bash
# Scaffold a test project
./scripts/scaffold.sh /tmp/test-project "Test Project"

# Verify structure
ls -la /tmp/test-project/

# Test interview mode (interactive)
cd /tmp/test-project && ./ralph/ralph.sh interview

# Test plan mode (1 iteration)
cd /tmp/test-project && ./ralph/ralph.sh plan 1
```
