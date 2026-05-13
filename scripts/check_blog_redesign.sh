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
grep -q "Hello,It's My Blog" "$HOME_HTML"
grep -q '>Notes</h2>' "$HOME_HTML"
grep -q 'data-topic="agent"' "$HOME_HTML"
grep -q 'data-topic="security"' "$HOME_HTML"
grep -q 'data-topic="面经"' "$HOME_HTML"
grep -q 'data-topic="题解"' "$HOME_HTML"

if grep -q 'class="home-topic home-topic--active' "$HOME_HTML"; then
  echo "homepage should not select a topic by default" >&2
  exit 1
fi

if grep -q 'sidebar-search' "$HOME_HTML"; then
  echo "home sidebar should not render a search box" >&2
  exit 1
fi

NOTE_CARD_COUNT="$(grep -o 'data-note-card' "$HOME_HTML" | wc -l | tr -d ' ')"
if [ "$NOTE_CARD_COUNT" -lt "6" ]; then
  echo "homepage should render enough note cards for the fixed grid, got $NOTE_CARD_COUNT" >&2
  exit 1
fi

grep -q 'home-notes.js' "$ROOT_DIR/hugo.toml"
grep -q 'maxVisibleCards = 6' "$ROOT_DIR/assets/js/home-notes.js"
grep -q 'function initHomeNotes' "$HOME_HTML"
grep -q '.home-note-card\[hidden\]' "$ROOT_DIR/assets/css/custom.css"
grep -q 'grid-template-rows: repeat(3, minmax(0, 1fr))' "$ROOT_DIR/assets/css/custom.css"
grep -q 'class="note-detail-layout' "$POST_HTML"
grep -q 'class="article-toc-panel"' "$POST_HTML"
grep -q 'href="/#latest-notes"' "$POST_HTML"
grep -q 'height: calc(100vh - 88px)' "$ROOT_DIR/assets/css/custom.css"
grep -q '.body:has(.home-panel)' "$ROOT_DIR/assets/css/custom.css"
grep -q 'grid-template-columns: clamp(210px, 22vw, 320px)' "$ROOT_DIR/assets/css/custom.css"
grep -q 'max-height: calc(100vh - 2.4rem)' "$ROOT_DIR/assets/css/custom.css"

if grep -q '<header class="header">' "$POST_HTML"; then
  echo "post detail page should not render the global header" >&2
  exit 1
fi
