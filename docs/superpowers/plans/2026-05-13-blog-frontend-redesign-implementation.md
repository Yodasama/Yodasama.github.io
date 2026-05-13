# Blog Frontend Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the approved homepage and note-reading redesign for the Hugo blog.

**Architecture:** Keep the implementation in site-level Hugo overrides. Use `layouts/index.html` for the homepage, add a site-level `layouts/_default/baseof.html` to hide the global sidebar/header on post detail pages, use `layouts/_default/single.html` for the current-article TOC reading layout, and keep visual styling in `assets/css/custom.css`.

**Tech Stack:** Hugo 0.161, Anatole theme, Go templates, static CSS, shell-based generated HTML checks.

---

### Task 1: Add Red-Green Verification Script

**Files:**
- Create: `scripts/check_blog_redesign.sh`

- [ ] **Step 1: Write the failing test**

Create `scripts/check_blog_redesign.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${TMPDIR:-/tmp}/yida-blog-redesign-check"

rm -rf "$BUILD_DIR"
hugo --quiet --source "$ROOT_DIR" --destination "$BUILD_DIR"

HOME_HTML="$BUILD_DIR/index.html"
POST_HTML="$BUILD_DIR/posts/system-sec/index.html"

grep -q 'id="latest-notes"' "$HOME_HTML"
grep -q 'class="home-note-card' "$HOME_HTML"
grep -q 'class="home-projects-placeholder"' "$HOME_HTML"

grep -q 'class="note-detail-layout' "$POST_HTML"
grep -q 'class="article-toc-panel"' "$POST_HTML"
grep -q 'href="/#latest-notes"' "$POST_HTML"

if grep -q '<header class="header">' "$POST_HTML"; then
  echo "post detail page should not render the global header" >&2
  exit 1
fi
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash scripts/check_blog_redesign.sh`

Expected: FAIL because the generated homepage and post pages do not yet contain the new layout markers.

### Task 2: Implement Site-Level Layout Overrides

**Files:**
- Create: `layouts/_default/baseof.html`
- Modify: `layouts/index.html`
- Modify: `layouts/_default/single.html`

- [ ] **Step 1: Add the base layout override**

Create `layouts/_default/baseof.html` by adapting the Anatole base layout. For `.Section == "posts"` detail pages, hide the global sidebar and header. For all other pages, preserve the existing theme structure.

- [ ] **Step 2: Replace the homepage template**

Update `layouts/index.html` so the main content contains:

- `id="latest-notes"` on the notes section.
- Topic chips generated from `.Site.Taxonomies.tags`.
- Note cards from posts in `.Site.Params.mainSections`.
- A low-key `home-projects-placeholder` section below Latest Notes.

- [ ] **Step 3: Replace the post detail template**

Update `layouts/_default/single.html` so post detail pages contain:

- A `note-detail-layout` wrapper.
- A left `article-toc-panel` with a `返回首页` link to `/#latest-notes`.
- The current article's `.TableOfContents` only when `toc = true`.
- A right article panel with metadata, title, summary, tags, and content.

Non-post single pages should keep the existing standard article layout.

### Task 3: Add Responsive Styling

**Files:**
- Modify: `assets/css/custom.css`

- [ ] **Step 1: Add homepage styles**

Add CSS for homepage headline, topic chips, note cards, and project placeholder. The homepage must stack cleanly below `960px`.

- [ ] **Step 2: Add note detail styles**

Add CSS for the book-like post detail layout: left TOC panel, sticky TOC on desktop, readable article width, hidden global post card styling collisions, and mobile stacking.

- [ ] **Step 3: Preserve existing markdown styles**

Keep existing code block, archive, search, and post content styles intact unless a selector needs to be narrowed for the new note detail layout.

### Task 4: Verify and Review

**Files:**
- Test: `scripts/check_blog_redesign.sh`

- [ ] **Step 1: Run the redesign verification**

Run: `bash scripts/check_blog_redesign.sh`

Expected: PASS.

- [ ] **Step 2: Run a full Hugo build**

Run: `hugo --quiet`

Expected: exit code 0.

- [ ] **Step 3: Start local Hugo server and inspect**

Run: `hugo server --bind 127.0.0.1 --port 1313 --disableFastRender`

Open `http://localhost:1313/` and `http://localhost:1313/posts/system-sec/` in the in-app browser. Check desktop and mobile widths for the homepage and note detail page.
