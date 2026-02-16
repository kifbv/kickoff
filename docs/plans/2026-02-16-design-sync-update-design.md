# Design Sync Update — Integrate design-md and enhance-prompt

**Date:** 2026-02-16
**Status:** Approved

## Context

The design-sync skill (`/design-sync`) imports UI mockups from Stitch into specs and HTML references that drive the Ralph build loop. Currently it produces feature specs and raw HTML, but the build agent must reverse-engineer design intent from those HTML dumps.

Two existing Stitch skills can improve this:
- **design-md** — analyzes Stitch screens to synthesize a semantic design system (`DESIGN.md`)
- **enhance-prompt** — transforms vague ideas into Stitch-optimized prompts using the design system

A third skill, **react-components**, stays separate — invoked independently after design-sync.

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Execution model | Interactive Claude Code skill | User confirms screen selection, JTBD mapping, and gap prompts |
| Architecture | Sequential integration (new steps in existing flow) | Simple mental model, one invocation |
| DESIGN.md location | `designs/DESIGN.md` | Co-located with HTML files; build agent already reads `designs/` |
| Gap prompts | Save to `designs/prompts/`, offer to generate in Stitch | User control without manual Stitch work |
| React conversion | Separate step | Clean separation of concerns; design-sync stays stack-agnostic |
| Default frontend stack | React + Vite + TypeScript + Tailwind | Best AI agent reliability, existing skills, ecosystem depth |

## Updated Flow

```
Phase 1: Import (existing)
  1. Connect to Stitch
  2. Screen Inventory
  3. Map Screens to JTBD

Phase 2: Generate (existing)
  4. Generate Feature Specs
  5. Save Design HTML

Phase 3: Synthesize (NEW)
  6. Generate DESIGN.md
  7. Fill Gaps (enhance-prompt + optional Stitch generation)

Phase 4: Wrap-up (existing, expanded)
  8. Update Project Overview
  9. Review & Commit
```

## Step 6: Generate DESIGN.md

Uses screen metadata and HTML already fetched in steps 1-2 and 5. One additional Stitch API call (`get_project`) for project-level settings.

**Process:**
1. Parse each downloaded HTML for Tailwind classes, CSS variables, component patterns
2. Read project-level settings from Stitch (color mode, fonts, roundness) via `get_project`
3. Synthesize into `designs/DESIGN.md` with sections:
   - Visual Theme & Atmosphere
   - Color Palette & Roles (hex values mapped to semantic roles)
   - Typography Rules (families, sizes, weights)
   - Component Patterns (recurring UI patterns with Tailwind class signatures)
   - Layout Principles (spacing scale, grid patterns, breakpoints)
4. Present summary to user, ask for adjustments before saving

**No redundant API calls.** Screen data from steps 1-2 is reused.

## Step 7: Fill Gaps

### 7a. Identify uncovered JTBD

Compare JTBD list against imported screens. Present a table of gaps. If no gaps, skip to step 8.

### 7b. Generate Stitch-optimized prompts

For each uncovered JTBD:
1. Read JTBD description from `specs/project-overview.md`
2. Read `designs/DESIGN.md` (just generated) to inject design system context
3. Produce a structured prompt: design system block, page type, component breakdown, color/typography references
4. Save to `designs/prompts/[jtbd-name-kebab-case].md`
5. Present prompts to user for review

### 7c. Offer to generate missing screens

Ask user: "Would you like me to generate these screens in Stitch now?"

Options:
- **Yes, all** — generate all gap screens
- **Pick which ones** — user selects
- **No, skip** — leave prompts for manual use

If user accepts:
1. Call `generate_screen_from_text` for each prompt (set expectations: ~1 min per screen)
2. For each new screen: `get_screen` → download HTML to `designs/` → generate feature spec in `specs/`
3. Present newly imported screens alongside originals
4. Device type: infer from existing screens (if uniform); ask user if mixed

**What does NOT happen:**
- No specs for JTBD the user declines to generate screens for — Discover handles those
- No re-run of DESIGN.md — new screens were generated FROM the design system, already consistent

## Steps 8-9: Wrap-up

### Step 8: Update Project Overview

JTBD status values:
- `spec created (from design)` — had matching Stitch screens
- `spec created (from generated design)` — screen was generated in step 7c
- `prompt saved (no spec)` — prompt saved, user declined generation; Discover will handle

### Step 9: Review & Commit

Present summary:

```
Created:
  specs/            N feature specs
  designs/          N HTML files
  designs/DESIGN.md
  designs/prompts/  N gap prompts

Updated:
  specs/project-overview.md

Next steps:
  → ./ralph/ralph.sh discover  (if uncovered JTBD remain)
  → ./ralph/ralph.sh plan      (if all JTBD have specs)
```

Commit message: `spec: Add design-synced specs from Stitch`

## Changes to Other Files

| File | Change |
|------|--------|
| `skills/design-sync/SKILL.md` | Main change — add steps 6-7, expand steps 8-9 |
| `prompts/PROMPT_build.md` | Add line 0f2: read `designs/DESIGN.md` for design tokens |
| `scripts/scaffold.sh` | Add `designs/prompts/` to mkdir list |
| `prompts/PROMPT_discover.md` | No changes — already skips "spec created" JTBD |
| `scripts/ralph.sh` | No changes — design-sync already in update skill list |

## What Is NOT In Scope

- react-components integration (separate skill, invoked independently)
- remotion integration (dropped)
- stitch-loop changes (unrelated workflow)
- Multi-stack support (settled on React)
- Changes to plan or build phases beyond the one PROMPT_build.md line
