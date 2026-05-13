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
