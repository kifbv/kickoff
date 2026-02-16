---
name: design-sync
description: "Import UI designs from Stitch into project specs. Connects to a Stitch design project, maps screens to JTBD, generates feature specs with design references, and saves HTML locally for the build loop. Triggers on: import designs, sync designs, design to spec, stitch import, mockup to spec, design sync."
user-invocable: true
---

# Design Sync

Import UI mockups from a Stitch design project into the specs and designs that drive the Ralph loop.

---

## The Job

1. Connect to a Stitch project and inventory its screens
2. Map screens to JTBD from `specs/project-overview.md`
3. Generate feature specs with design references
4. Save screen HTML locally to `designs/`
5. Update project-overview.md to mark JTBD as "spec created (from design)"

**Important:** Do NOT implement anything. Just create specs and save design references.

---

## Steps

### Step 1: Connect to Stitch

1. Call `mcp__stitch__list_projects` to show available design projects.
2. Present the list and ask the user to select one (or accept the default if only one exists).
3. Call `mcp__stitch__list_screens` for the selected project.
4. Call `mcp__stitch__get_project` to retrieve project-level design settings (color mode, fonts, roundness, custom colors). Hold this data for Step 6.

### Step 2: Screen Inventory

5. For each **visible** screen (skip hidden ones), call `mcp__stitch__get_screen` to get full details.
6. Present a summary table:

```
Screen                  | Device   | Size
----------------------- | -------- | ----------
Global Leaderboard      | Mobile   | 390x967
Player Statistics       | Mobile   | 390x908
Log Match Result        | Mobile   | 390x884
```

7. Ask the user to confirm which screens to import. All visible screens are selected by default.

### Step 3: Map Screens to JTBD

8. Read `specs/project-overview.md` if it exists.
9. Propose a mapping of screens to JTBD topics. Group related screens under the same topic.
   - If project-overview exists: map screens to existing JTBD.
   - If no project-overview: infer JTBD from the screen set and propose them.
10. Ask the user to confirm or adjust the mapping.

### Step 4: Generate Feature Specs

11. For each JTBD group, create `specs/[topic-name-kebab-case].md` with this structure:

```markdown
# [Feature Name]

## Overview
[Derived from screen analysis - what this feature does and the problem it solves]

## Design Reference
- **Stitch Project:** [project name] (`projects/[project-id]`)
- **Screens:**
  - [Screen Title] (`[screen-id]`, [device], [width]x[height])
- **Local HTML:** `designs/[screen-name].html`

## User Stories

### US-001: [Title]
**Description:** As a [user], I want [feature visible in mockup] so that [benefit].

**Acceptance Criteria:**
- [ ] [Specific criterion derived from mockup UI elements]
- [ ] UI matches design reference in `designs/[screen-name].html`
- [ ] Typecheck passes
- [ ] Verify in browser

## Functional Requirements
- FR-1: [Derived from visible UI elements and interactions]

## Non-Goals
- [What this feature will NOT include, inferred from what the mockup omits]

## Technical Considerations
- Design HTML in `designs/` is a layout/styling reference, not production code
- Adapt to the project's tech stack and component patterns

## Quality Gates
- Typecheck passes
- Verify in browser against design reference
```

**Story sizing:** Each user story must be completable in ONE Ralph iteration. If a screen is complex, split it into multiple stories (e.g., layout/structure, data display, interactions, polish).

### Step 5: Save Design HTML

12. Download the HTML code from each imported Stitch screen.
13. Save to `designs/[screen-title-kebab-case].html`.
14. These files serve as layout and styling references for the Build agent. They are NOT production code to copy verbatim.

### Step 6: Generate DESIGN.md

15. Parse each downloaded HTML file in `designs/` for:
    - Tailwind utility classes (colors, spacing, typography, borders, shadows)
    - CSS custom properties and variables
    - Recurring component patterns (cards, buttons, navs, forms, modals)

16. Use the project metadata from Step 1 (color mode, fonts, roundness, custom colors) to fill in project-level design tokens.

17. Synthesize findings into `designs/DESIGN.md` with these sections:

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

18. Present a summary of the extracted design system to the user:
    - Number of unique colors found
    - Font families detected
    - Number of component patterns identified
    - Overall vibe in one sentence

19. Ask: "Does this design system look right? Any adjustments before I save it?"

20. Save to `designs/DESIGN.md`.

### Step 8: Update Project Overview

21. If `specs/project-overview.md` exists, mark each covered JTBD as "Status: spec created (from design)".
22. The Discover phase will skip these and only create specs for JTBD without mockups.

### Step 9: Review

23. Present a summary of everything created:
    - Feature spec files in `specs/`
    - Design HTML files in `designs/`
    - Updated JTBD status in project-overview
24. Ask the user if any specs need adjustment.
25. Commit all files with message: `spec: Add design-synced specs from Stitch`

---

## Output

| Artifact | Location | Purpose |
|----------|----------|---------|
| Feature specs | `specs/[topic].md` | Same format as Discover output, drives Plan and Build |
| Design HTML | `designs/[screen].html` | Layout/styling reference for Build agent |
| Updated overview | `specs/project-overview.md` | Marks JTBD as covered so Discover skips them |

---

## After Design Sync

Suggest next steps based on project state:

- If JTBD remain without specs: "Run `./ralph/ralph.sh discover` to spec remaining features."
- If all JTBD have specs: "Run `./ralph/ralph.sh plan` to create the implementation plan."

---

## Style

- Let the user confirm screen selection and JTBD mapping before generating specs
- Use lettered options for quick answers
- Be opinionated about screen-to-JTBD grouping
- Flag screens that seem to span multiple features and ask how to handle them
