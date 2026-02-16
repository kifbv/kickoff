# Design Sync Update Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add DESIGN.md generation and gap-filling to the design-sync skill.

**Architecture:** Two new steps (6 and 7) are added to the existing linear flow in `skills/design-sync/SKILL.md`. Step 6 synthesizes `designs/DESIGN.md` from already-fetched screen data. Step 7 identifies uncovered JTBD, generates Stitch-optimized prompts via enhance-prompt logic, and offers to generate missing screens in Stitch. Three other files get small changes: `PROMPT_build.md` (one line), `scaffold.sh` (one mkdir arg), and the feature spec template inside SKILL.md (one reference line).

**Tech Stack:** Markdown (skill definition), Stitch MCP tools, Bash (scaffold script)

**Design doc:** `docs/plans/2026-02-16-design-sync-update-design.md`

---

### Task 1: Add `get_project` call to Step 1

**Files:**
- Modify: `skills/design-sync/SKILL.md:27-32` (Step 1: Connect to Stitch)

**Step 1: Read the current file**

Read `skills/design-sync/SKILL.md` to confirm exact line content.

**Step 2: Add `get_project` call**

In Step 1, after the `list_screens` call (line 31), add a call to `get_project` to retrieve project-level design settings. This data is needed later in Step 6 for DESIGN.md synthesis.

Change Step 1 to:

```markdown
### Step 1: Connect to Stitch

1. Call `mcp__stitch__list_projects` to show available design projects.
2. Present the list and ask the user to select one (or accept the default if only one exists).
3. Call `mcp__stitch__list_screens` for the selected project.
4. Call `mcp__stitch__get_project` to retrieve project-level design settings (color mode, fonts, roundness, custom colors). Hold this data for Step 6.
```

Note: The existing step numbering within other steps will shift. The step numbers inside steps are local to each step, not global — they continue sequentially across the whole skill. Update all subsequent numbered items to account for the new item 4.

**Step 3: Verify the edit**

Read the file again to confirm the change is correct and numbering is consistent.

**Step 4: Commit**

```bash
git add skills/design-sync/SKILL.md
git commit -m "feat: Add get_project call to design-sync Step 1"
```

---

### Task 2: Add Step 6 — Generate DESIGN.md

**Files:**
- Modify: `skills/design-sync/SKILL.md` (insert new Step 6 after current Step 5)

**Step 1: Read the current file**

Read `skills/design-sync/SKILL.md` to see the state after Task 1.

**Step 2: Insert Step 6 after "Save Design HTML"**

After the current Step 5 (Save Design HTML) and before the current Step 6 (Update Project Overview), insert the new Step 6. The old Steps 6 and 7 become Steps 8 and 9.

Insert this content:

```markdown
### Step 6: Generate DESIGN.md

N. Parse each downloaded HTML file in `designs/` for:
   - Tailwind utility classes (colors, spacing, typography, borders, shadows)
   - CSS custom properties and variables
   - Recurring component patterns (cards, buttons, navs, forms, modals)

N+1. Use the project metadata from Step 1 (color mode, fonts, roundness, custom colors) to fill in project-level design tokens.

N+2. Synthesize findings into `designs/DESIGN.md` with these sections:

```markdown
# Design System: [Project Title]
**Project ID:** [project-id]

## 1. Visual Theme & Atmosphere
(Evocative description of the mood, density, and aesthetic philosophy. E.g., "Airy Scandinavian minimal with warm cream tones and generous whitespace.")

## 2. Color Palette & Roles
(Each color as: Descriptive Name (#hexcode) — functional role. E.g., "Deep Muted Teal-Navy (#294056) — primary actions and CTAs.")

## 3. Typography Rules
(Font families, weight usage for headings vs body, letter-spacing character. E.g., "Manrope for all text. Bold 700 for headings, Regular 400 for body.")

## 4. Component Patterns
* **Buttons:** (Shape, color, hover states. E.g., "Pill-shaped, Deep Teal-Navy fill, white text, subtle hover darkening.")
* **Cards:** (Corners, background, shadow. E.g., "Generously rounded (rounded-2xl), white surface, whisper-soft shadow.")
* **Inputs:** (Border style, background, focus state.)
* **Navigation:** (Layout, active state styling.)

## 5. Layout Principles
(Whitespace strategy, spacing scale, grid patterns, responsive breakpoints observed.)
```

N+3. Present a summary of the extracted design system to the user:
   - Number of unique colors found
   - Font families detected
   - Number of component patterns identified
   - Overall vibe in one sentence

N+4. Ask: "Does this design system look right? Any adjustments before I save it?"

N+5. Save to `designs/DESIGN.md`.
```

Replace the `N` placeholders with the correct sequential numbers continuing from Step 5's last item.

**Step 3: Verify the edit**

Read the file to confirm:
- Step 6 is correctly placed between Step 5 (Save Design HTML) and the renamed Step 7 (which was previously Step 6)
- All item numbers flow sequentially across the entire skill
- The nested markdown code block is properly escaped (use 4-space indent or different fence characters)

**Step 4: Commit**

```bash
git add skills/design-sync/SKILL.md
git commit -m "feat: Add DESIGN.md generation step to design-sync"
```

---

### Task 3: Add Step 7 — Fill Gaps

**Files:**
- Modify: `skills/design-sync/SKILL.md` (insert new Step 7 after the Step 6 just added)

**Step 1: Read the current file**

Read `skills/design-sync/SKILL.md` to see the state after Task 2.

**Step 2: Insert Step 7 after "Generate DESIGN.md"**

Insert between Step 6 (Generate DESIGN.md) and the old Step 6 (now Step 8: Update Project Overview). This is the gap-filling step.

Insert this content:

```markdown
### Step 7: Fill Gaps

N. Compare the JTBD list from `specs/project-overview.md` against the screens imported in Steps 1-5. Identify JTBD with no matching Stitch screen.

N+1. If no gaps exist, tell the user "All JTBD have design coverage" and skip to Step 8.

N+2. Present a table of uncovered JTBD:

```
Uncovered JTBD              | Reason
--------------------------- | ------
User authentication         | No matching screen in Stitch
Settings & preferences      | No matching screen in Stitch
```

N+3. For each uncovered JTBD, generate a Stitch-optimized prompt:
   a. Read the JTBD description from `specs/project-overview.md` for context.
   b. Read `designs/DESIGN.md` (generated in Step 6) and include its design system as a "DESIGN SYSTEM (REQUIRED)" block.
   c. Structure the prompt with: one-line page description and vibe, design system block, numbered page structure with specific UI component keywords, color and typography references from DESIGN.md.
   d. Save to `designs/prompts/[jtbd-name-kebab-case].md`.

N+4. Present the generated prompts to the user for review.

N+5. Ask: "Would you like me to generate these screens in Stitch now?"
   - **a) Yes, all** — generate screens for all uncovered JTBD
   - **b) Pick which ones** — let the user select specific JTBD to generate
   - **c) No, skip** — leave prompts saved in `designs/prompts/` for manual use later

N+6. If the user chooses (a) or (b):
   a. Infer the device type from existing imported screens. If all are the same type, use that. If mixed, ask the user.
   b. For each selected JTBD, call `mcp__stitch__generate_screen_from_text` with the prompt content and inferred device type. Note: this can take ~1 minute per screen.
   c. For each newly generated screen:
      - Call `mcp__stitch__get_screen` for metadata
      - Download HTML to `designs/[screen-title-kebab-case].html`
      - Generate a feature spec in `specs/[topic-name-kebab-case].md` using the same template as Step 4
   d. Present the newly imported screens alongside the originals in the summary table.
```

Replace the `N` placeholders with correct sequential numbers.

**Step 3: Verify the edit**

Read the file to confirm:
- Step 7 is correctly placed between Step 6 (Generate DESIGN.md) and Step 8 (Update Project Overview)
- All item numbers flow sequentially
- The options in N+5 use the lettered format consistent with the skill's style guide ("Use lettered options for quick answers")

**Step 4: Commit**

```bash
git add skills/design-sync/SKILL.md
git commit -m "feat: Add gap-filling step to design-sync"
```

---

### Task 4: Update Steps 8-9 (formerly 6-7)

**Files:**
- Modify: `skills/design-sync/SKILL.md` (rename and expand old Steps 6-7)

**Step 1: Read the current file**

Read `skills/design-sync/SKILL.md` to see the state after Task 3.

**Step 2: Update Step 8 (Update Project Overview)**

The old Step 6 is now Step 8. Expand it to handle the three JTBD status values:

```markdown
### Step 8: Update Project Overview

N. If `specs/project-overview.md` exists, update each JTBD's status based on how it was handled:
   - **"Status: spec created (from design)"** — JTBD had matching Stitch screens imported in Steps 1-5
   - **"Status: spec created (from generated design)"** — screen was generated in Step 7 and imported
   - **"Status: prompt saved (no spec)"** — prompt saved to `designs/prompts/`, user declined generation; Discover phase will create a text-only spec

N+1. The Discover phase will skip JTBD marked "spec created" and handle the rest.
```

**Step 3: Update Step 9 (Review)**

The old Step 7 is now Step 9. Expand the summary to include the new artifacts:

```markdown
### Step 9: Review

N. Present a summary of everything created:

```
Created:
  specs/            N feature specs (N from design, N from generated design)
  designs/          N HTML files
  designs/DESIGN.md
  designs/prompts/  N gap prompts

Updated:
  specs/project-overview.md   N/N JTBD covered
```

N+1. Ask the user if any specs need adjustment.
N+2. Commit all files with message: `spec: Add design-synced specs from Stitch`
```

**Step 4: Verify the edit**

Read the file to confirm Steps 8 and 9 are correct, numbered properly, and the summary format includes all new artifact types.

**Step 5: Commit**

```bash
git add skills/design-sync/SKILL.md
git commit -m "feat: Update wrap-up steps for new design-sync artifacts"
```

---

### Task 5: Update Output table, After Design Sync, and Style sections

**Files:**
- Modify: `skills/design-sync/SKILL.md` (bottom sections)

**Step 1: Read the current file**

Read `skills/design-sync/SKILL.md` to see the state after Task 4.

**Step 2: Update the Output table**

Replace the existing Output table with:

```markdown
## Output

| Artifact | Location | Purpose |
|----------|----------|---------|
| Feature specs | `specs/[topic].md` | Same format as Discover output, drives Plan and Build |
| Design HTML | `designs/[screen].html` | Layout/styling reference for Build agent |
| Design system | `designs/DESIGN.md` | Design tokens (colors, typography, spacing, components) for consistent UI |
| Gap prompts | `designs/prompts/[jtbd].md` | Stitch-optimized prompts for screens that don't exist yet |
| Updated overview | `specs/project-overview.md` | Marks JTBD as covered so Discover skips them |
```

**Step 3: Update the "After Design Sync" section**

Replace the existing section with:

```markdown
## After Design Sync

Suggest next steps based on project state:

- If JTBD remain without specs: "Run `./ralph/ralph.sh discover` to spec remaining features."
- If all JTBD have specs: "Run `./ralph/ralph.sh plan` to create the implementation plan."
- To convert designs to React components: "Run `/react-components` on individual screens."
```

**Step 4: Verify the edit**

Read the file to confirm the Output table and After Design Sync section are updated.

**Step 5: Commit**

```bash
git add skills/design-sync/SKILL.md
git commit -m "feat: Update output table and next steps for design-sync"
```

---

### Task 6: Update The Job summary and description

**Files:**
- Modify: `skills/design-sync/SKILL.md` (frontmatter and "The Job" section)

**Step 1: Read the current file**

Read `skills/design-sync/SKILL.md` to see the state after Task 5.

**Step 2: Update the frontmatter description**

Change the description field to reflect the new capabilities:

```yaml
description: "Import UI designs from Stitch into project specs. Connects to a Stitch design project, maps screens to JTBD, generates feature specs with design references, synthesizes a design system (DESIGN.md), fills design gaps with Stitch-optimized prompts, and saves HTML locally for the build loop. Triggers on: import designs, sync designs, design to spec, stitch import, mockup to spec, design sync."
```

**Step 3: Update "The Job" section**

Replace with:

```markdown
## The Job

1. Connect to a Stitch project and inventory its screens
2. Map screens to JTBD from `specs/project-overview.md`
3. Generate feature specs with design references
4. Save screen HTML locally to `designs/`
5. Synthesize a design system into `designs/DESIGN.md`
6. Identify uncovered JTBD and generate Stitch-optimized prompts for missing screens
7. Offer to generate missing screens in Stitch and import them
8. Update project-overview.md to mark JTBD coverage status

**Important:** Do NOT implement anything. Just create specs, design references, and design system documentation.
```

**Step 4: Verify the edit**

Read the file to confirm frontmatter and The Job section are updated and consistent with the steps below.

**Step 5: Commit**

```bash
git add skills/design-sync/SKILL.md
git commit -m "feat: Update design-sync description and job summary"
```

---

### Task 7: Add feature spec template reference to DESIGN.md

**Files:**
- Modify: `skills/design-sync/SKILL.md` (Step 4: Generate Feature Specs, the spec template)

**Step 1: Read the current file**

Read `skills/design-sync/SKILL.md` and locate the feature spec markdown template in Step 4.

**Step 2: Add design system reference to spec template**

In the feature spec template (the markdown block inside Step 4), add a line under "Design Reference" pointing to `designs/DESIGN.md`:

Add after the `- **Local HTML:**` line:

```markdown
- **Design System:** `designs/DESIGN.md` (colors, typography, spacing, component patterns)
```

**Step 3: Verify the edit**

Read the file to confirm the spec template includes the new line.

**Step 4: Commit**

```bash
git add skills/design-sync/SKILL.md
git commit -m "feat: Add DESIGN.md reference to feature spec template"
```

---

### Task 8: Update PROMPT_build.md

**Files:**
- Modify: `prompts/PROMPT_build.md:12` (add one line after 0f)

**Step 1: Read the current file**

Read `prompts/PROMPT_build.md` to confirm the exact content of line 12.

**Step 2: Add line 0f2**

After line 12 (`0f. If designs/ contains HTML files...`), insert:

```markdown
0f2. If `designs/DESIGN.md` exists, read it for design system tokens (colors, typography, spacing, component patterns). Use these for consistency across all UI implementation.
```

**Step 3: Verify the edit**

Read the file to confirm 0f2 is correctly placed between 0f and 0g.

**Step 4: Commit**

```bash
git add prompts/PROMPT_build.md
git commit -m "feat: Add DESIGN.md reference to build prompt orient phase"
```

---

### Task 9: Update scaffold.sh

**Files:**
- Modify: `scripts/scaffold.sh:43`

**Step 1: Read the current file**

Read `scripts/scaffold.sh` to confirm the exact mkdir line.

**Step 2: Add designs/prompts to mkdir**

Change line 43 from:

```bash
mkdir -p "$TARGET_DIR"/{specs,ralph,archive,src,designs,infra}
```

to:

```bash
mkdir -p "$TARGET_DIR"/{specs,ralph,archive,src,designs,designs/prompts,infra}
```

**Step 3: Verify the edit**

Read the file to confirm the change.

**Step 4: Test the change**

```bash
bash -n scripts/scaffold.sh
```

This checks for syntax errors without executing.

**Step 5: Commit**

```bash
git add scripts/scaffold.sh
git commit -m "feat: Add designs/prompts/ to scaffold directory structure"
```

---

### Task 10: Final verification

**Step 1: Read the complete updated SKILL.md**

Read `skills/design-sync/SKILL.md` end-to-end. Verify:
- Frontmatter description mentions DESIGN.md and gap-filling
- The Job section lists all 8 jobs
- Steps 1-9 flow sequentially with correct numbering
- Step 1 includes `get_project` call
- Step 6 is DESIGN.md generation
- Step 7 is gap-filling with three sub-steps (identify, generate prompts, offer to create)
- Step 8 has three JTBD status values
- Step 9 summary includes all artifact types
- Output table has 5 rows
- After Design Sync mentions react-components
- No orphaned references to old step numbers

**Step 2: Read PROMPT_build.md**

Verify 0f2 line exists between 0f and 0g.

**Step 3: Read scaffold.sh**

Verify `designs/prompts` is in the mkdir line.

**Step 4: Run syntax check on scaffold.sh**

```bash
bash -n scripts/scaffold.sh
```

**Step 5: Commit any fixes found during verification**

If any issues are found, fix them and commit with: `fix: Correct [issue] in design-sync update`
