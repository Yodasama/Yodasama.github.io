# Blog Homepage Rebuild Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the Hugo homepage as an Apple-style three-column knowledge dashboard with accordion navigation and in-place category filtering.

**Architecture:** Keep all implementation in site-level overrides. `layouts/index.html` renders the complete homepage data model and semantic controls, `assets/js/home-notes.js` handles accordion and in-place filtering, and `assets/css/custom.css` provides the responsive Apple-style visual system. `scripts/check_blog_redesign.sh` verifies generated HTML markers and client behavior contracts.

**Tech Stack:** Hugo, Go templates, static CSS, vanilla JavaScript, shell-based generated HTML checks.

---

### Task 1: Update Homepage Verification

**Files:**
- Modify: `scripts/check_blog_redesign.sh`

- [ ] **Step 1: Write the failing check**

Replace the homepage checks so the script verifies:

```bash
grep -q 'class="home-shell' "$HOME_HTML"
grep -q 'data-home-panel="all"' "$HOME_HTML"
grep -q 'data-home-panel="security"' "$HOME_HTML"
grep -q 'data-home-panel="agent"' "$HOME_HTML"
grep -q 'data-home-panel="algorithm"' "$HOME_HTML"
grep -q 'data-home-accordion="notes"' "$HOME_HTML"
grep -q 'data-home-filter="security"' "$HOME_HTML"
grep -q 'data-home-filter="agent"' "$HOME_HTML"
grep -q 'data-home-filter="algorithm"' "$HOME_HTML"
grep -q 'data-home-context-label' "$HOME_HTML"
grep -q 'data-home-context-count' "$HOME_HTML"
```

- [ ] **Step 2: Run the check to verify it fails**

Run: `bash scripts/check_blog_redesign.sh`

Expected: FAIL before the new homepage is implemented.

### Task 2: Render the Three-Column Homepage

**Files:**
- Modify: `layouts/index.html`

- [ ] **Step 1: Replace the homepage template**

Render a `.home-shell` containing:

- Left `.home-sidebar` with profile, accordion navigation, and social links.
- Center `.home-main` with signature and one panel per content state.
- Right `.home-about` with About content and current-state elements.

- [ ] **Step 2: Add filtering data attributes**

Each panel uses `data-home-panel` with values:

- `all`
- `security`
- `agent`
- `algorithm`

Each submenu button uses `data-home-filter` and `data-home-filter-label`.

- [ ] **Step 3: Keep content sourced from Markdown**

Use post front matter for title, date, summary, and tags. Use `content/about.md` through `.Site.GetPage "about"` for the right panel.

### Task 3: Implement Homepage Interactions

**Files:**
- Modify: `assets/js/home-notes.js`

- [ ] **Step 1: Add accordion behavior**

Clicking top-level accordion buttons toggles `aria-expanded` and the matching submenu's hidden state.

- [ ] **Step 2: Add in-place center filtering**

Clicking a submenu filter button:

- Prevents page navigation.
- Shows the matching `data-home-panel`.
- Hides other panels.
- Updates active item state.
- Updates right-side label and count.

- [ ] **Step 3: Preserve graceful behavior**

If the homepage shell is absent, the script exits without changing other pages.

### Task 4: Add Responsive Apple-Style Styling

**Files:**
- Modify: `assets/css/custom.css`

- [ ] **Step 1: Style desktop three-column layout**

Use compact side columns, center-focused layout, off-white background, white surfaces, neutral text, subtle borders, and restrained shadows.

- [ ] **Step 2: Style accordions and active filters**

Accordion buttons and submenu buttons have fixed dimensions, clear focus states, and no layout shift on hover.

- [ ] **Step 3: Style mobile stacking**

Below tablet widths, stack sidebar, main, and right panel vertically and keep article rows readable without horizontal overflow.

### Task 5: Verify Locally

**Files:**
- Test: `scripts/check_blog_redesign.sh`

- [ ] **Step 1: Run generated HTML check**

Run: `bash scripts/check_blog_redesign.sh`

Expected: PASS.

- [ ] **Step 2: Run a full Hugo build**

Run: `hugo --quiet`

Expected: exit code 0.

- [ ] **Step 3: Start local server and inspect**

Run: `hugo server --bind 127.0.0.1 --port 1313 --disableFastRender`

Open `http://localhost:1313/` and verify:

- Notes accordion opens in place.
- `Security`, `Agent`, and `题解` update the center list without a page reload.
- The right `Now Reading` state updates.
- The layout stays readable on desktop and mobile widths.
