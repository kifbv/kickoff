---
name: design-create
description: "Create UI designs in Stitch from scratch after the interview phase. Reads project-overview.md, infers visual style, collaboratively plans screens with the user, then generates them in Stitch. Triggers on: create designs, design from scratch, generate mockups, stitch create, new design, design create, make screens."
user-invocable: true
---

# Design Create

Generate a Stitch design project from scratch using the JTBD and context in `specs/project-overview.md`.

---

## The Job

1. Read project context from `specs/project-overview.md`
2. Infer a visual style from the project type and confirm with the user
3. Collaboratively plan the screen inventory with the user
4. Create a Stitch project and generate all screens
5. Suggest reviewing in Stitch, then running `/design-sync` to import

**Important:** This skill creates designs in Stitch only. It does NOT create local specs, HTML files, or DESIGN.md — that's `/design-sync`'s job.

---

## Prerequisites

- Access to the Stitch MCP Server
- `specs/project-overview.md` must exist (run `./ralph/ralph.sh interview` first)

---

## Steps

### Step 1: Read Project Context

1. Read `specs/project-overview.md`.
2. If the file does not exist, tell the user: "Run `./ralph/ralph.sh interview` first to define your project." Stop here.
3. Extract:
   - **Project name** (title)
   - **Problem statement** and **target users** (for style inference)
   - **JTBD list** (for screen planning)
   - **Platform** from Technical Constraints (for device type — defaults to MOBILE if unspecified)
   - **v1 scope** (to stay within bounds)

### Step 2: Infer Visual Style

4. Analyze the project type, problem statement, and target users to propose a design direction. Cover:

   - **Mood/vibe** — evocative descriptors (e.g., "clean and minimal with a professional feel", "vibrant and playful with bold colors")
   - **Theme** — light or dark
   - **Color direction** — descriptive language, no hex codes (e.g., "deep blue tones for trust", "warm earth tones for approachability"). Let Stitch interpret.
   - **Corner style** — sharp, subtly rounded, generously rounded, pill-shaped
   - **Density** — spacious with generous whitespace, or compact and information-dense

5. Present the proposal:

   > **Inferred style:** Clean and minimal with a professional feel. Light theme, generous whitespace, subtly rounded corners. Primary accent in deep blue tones suggesting trust and reliability.
   > **Device:** Mobile
   >
   > Does this feel right, or would you adjust anything?

6. Accept freeform adjustments ("make it darker", "more playful", "like Linear", "like the Stripe dashboard"). Iterate until the user confirms.

### Step 3: Collaborative Screen Planning

JTBD are functional goals, not screens. A single JTBD might need multiple screens, or several JTBD might live on one screen. This step is a conversation to align on the screen inventory.

**3a. Ask the user first:**

7. "What screens do you have in mind for your app?" Let them describe their mental model. They may have a clear picture ("a home feed, a profile page, and a settings screen") or be vague ("maybe 3-4 screens?"). Either is fine.

**3b. Compare to JTBD:**

8. Present a mapping of the user's screens against the JTBD list:

    ```
    Your screens              | Covers JTBD
    ------------------------- | -----------
    Home Feed                 | Browse content, Discover new items
    Profile Page              | Track personal stats
    ???                       | Record game results (no screen yet)
    Settings                  | (structural — no JTBD)
    ```

   - Flag JTBD with no matching screen
   - Flag screens that don't map to any JTBD (structural screens are fine — just label them)
   - Flag JTBD that seem too complex for a single screen and suggest splitting

**3c. Iterate:**

9. Ask follow-up questions **one at a time**:
   - "JTBD X doesn't have a screen yet — should it be its own screen, or part of [existing screen]?"
   - "Screen Y covers two big JTBD — should we split it?"
   - "You mentioned a settings screen — what would go in there?"

**3d. Converge:**

10. Once aligned, present the final screen plan:

    ```
    Screen                  | Purpose                           | Device
    ----------------------- | --------------------------------- | ------
    Home Feed               | Browse + discover content          | Mobile
    Log Match               | Record game results (form)         | Mobile
    Leaderboard             | Compare player rankings            | Mobile
    Profile                 | Track personal stats               | Mobile
    Settings                | Preferences (structural)           | Mobile
    ```

11. Ask: "Happy with this screen list, or want to adjust?"

### Step 4: Create Stitch Project

12. Call `mcp__stitch__create_project` with the project title from `specs/project-overview.md`.
13. Store the project ID for subsequent calls.

### Step 5: Assemble Prompts & Generate Screens

14. Warn the user: "Generating N screens — this takes about 1 minute per screen."

15. For each screen in the confirmed plan, assemble a Stitch-optimized prompt:

    **a. Assess what's needed:** Check the screen purpose against this checklist:

    | Element | Check for | If missing... |
    |---------|-----------|---------------|
    | **Platform** | "web", "mobile", "desktop" | Use platform from project-overview |
    | **Page type** | "dashboard", "form", "list", "detail" | Infer from screen purpose |
    | **Structure** | Numbered sections/components | Create logical page structure |
    | **Visual style** | Mood descriptors | Use confirmed style from Step 2 |
    | **Components** | UI-specific terms | Translate to proper keywords (see below) |

    **b. Enhance with UI/UX keywords:** Replace vague terms with specific component names:

    | Vague | Enhanced |
    |-------|----------|
    | "menu at the top" | "navigation bar with logo and menu items" |
    | "button" | "primary call-to-action button" |
    | "list of items" | "card grid layout" or "vertical list with thumbnails" |
    | "form" | "form with labeled input fields and submit button" |
    | "picture area" | "hero section with full-width image" |

    **c. Amplify the vibe:** Translate generic adjectives into rich descriptive language:

    | Basic | Enhanced |
    |-------|----------|
    | "modern" | "clean, minimal, with generous whitespace" |
    | "professional" | "sophisticated, trustworthy, with subtle shadows" |
    | "fun" | "vibrant, playful, with rounded corners and bold colors" |
    | "dark mode" | "dark theme with high-contrast accents on deep backgrounds" |

    **d. Structure the page:** Organize content into numbered sections:

    ```markdown
    **Page Structure:**
    1. **Header:** Navigation with logo and menu items
    2. **Hero Section:** Headline, subtext, and primary CTA
    3. **Content Area:** [Describe the main content for this screen]
    4. **Footer:** Links, social icons, copyright
    ```

    **e. Assemble the prompt** using this template:

    ```markdown
    [One-line description of the page purpose and vibe]

    **DESIGN SYSTEM (REQUIRED):**
    - Platform: [Web/Mobile], [Desktop/Mobile]-first
    - Theme: [Light/Dark], [style descriptors from confirmed style]
    - Color Direction: [Descriptive color language from Step 2]
    - Typography: [Clean sans-serif / warm serif / etc.]
    - Buttons: [Shape description]
    - Cards: [Corner style], [shadow description]
    - Spacing: [Density description]

    **Page Structure:**
    1. **[Section]:** [Description with specific UI component keywords]
    2. **[Section]:** [Description with specific UI component keywords]
    ...
    ```

    **Reference:** Consult the Stitch Effective Prompting Guide for latest best practices: https://stitch.withgoogle.com/docs/learn/prompting/

16. For each screen, call `mcp__stitch__generate_screen_from_text` with:
    - `projectId`: the project ID from Step 4
    - `prompt`: the assembled prompt
    - `deviceType`: inferred from platform (MOBILE, DESKTOP, or TABLET)

17. If `output_components` in the response contains suggestions, present them to the user. If the user accepts a suggestion, call `generate_screen_from_text` again with the suggestion as the prompt.

### Step 6: Present Summary

18. Show a table of all generated screens:

    ```
    Generated screens:

    Screen                  | Device   | Status
    ----------------------- | -------- | ------
    Home Feed               | Mobile   | Created
    Log Match               | Mobile   | Created
    Leaderboard             | Mobile   | Created
    Profile                 | Mobile   | Created
    Settings                | Mobile   | Created
    ```

19. Provide the Stitch project link for the user to open.

### Step 7: Suggest Next Steps

20. Present clearly:

    > **Next steps:**
    >
    > a) **Review and refine in Stitch** — Open your project in Stitch and use its conversational editing to polish layouts, adjust colors, tweak content, and iterate on each screen until you're happy.
    >
    > b) **Import into your project** — When the designs look good, run `/design-sync` to import them. This will create feature specs, download HTML references, and generate a design system (DESIGN.md).

---

## Output

| Artifact | Location | Purpose |
|----------|----------|---------|
| Stitch project | Stitch (cloud) | Design project with generated screens |

No local files are created. The `/design-sync` skill handles importing designs into the project.

---

## Style

- One question at a time during screen planning
- Use lettered options for quick answers where appropriate
- Be opinionated about screen structure — propose concrete page layouts
- Flag screens that seem to span too many JTBD
- Keep the conversation moving — don't over-discuss, converge quickly
