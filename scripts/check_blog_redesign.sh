#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${TMPDIR:-/tmp}/yida-blog-redesign-check"

rm -rf "$BUILD_DIR"
hugo --quiet --source "$ROOT_DIR" --destination "$BUILD_DIR"

HOME_HTML="$BUILD_DIR/index.html"
POST_HTML="$BUILD_DIR/posts/system-sec/index.html"
PROJECTS_HTML="$BUILD_DIR/projects/index.html"
SEARCH_HTML="$BUILD_DIR/search/index.html"

grep -q 'class="home-shell' "$HOME_HTML"
grep -q 'class="home-sidebar' "$HOME_HTML"
grep -q 'class="home-main' "$HOME_HTML"
grep -q 'class="home-about' "$HOME_HTML"
grep -q 'data-home-accordion="notes"' "$HOME_HTML"
grep -q 'data-home-filter="all"' "$HOME_HTML"
grep -q 'data-home-filter="security"' "$HOME_HTML"
grep -q 'data-home-filter="agent"' "$HOME_HTML"
grep -q 'data-home-filter="algorithm"' "$HOME_HTML"
grep -q 'data-home-panel="all"' "$HOME_HTML"
grep -q 'data-home-panel="security"' "$HOME_HTML"
grep -q 'data-home-panel="agent"' "$HOME_HTML"
grep -q 'data-home-panel="algorithm"' "$HOME_HTML"
grep -q 'class="home-about-search' "$HOME_HTML"
grep -q 'class="home-focus-list"' "$HOME_HTML"
grep -q '目前关注' "$HOME_HTML"
grep -q 'Security' "$HOME_HTML"
grep -q 'Agent' "$HOME_HTML"
grep -q '题解' "$HOME_HTML"
grep -q 'home-submenu__item--active' "$ROOT_DIR/assets/css/custom.css"
grep -q 'home-nav__item--open' "$ROOT_DIR/assets/css/custom.css"
grep -q 'href="/projects/"' "$HOME_HTML"

if grep -q 'data-home-menu="projects"' "$HOME_HTML"; then
  echo "homepage should not render a second-level projects menu" >&2
  exit 1
fi

if grep -q 'sidebar-search' "$HOME_HTML"; then
  echo "home sidebar should not render a search box" >&2
  exit 1
fi

if grep -q 'home-profile__role' "$HOME_HTML"; then
  echo "home profile should only show Yodasama, not the author role" >&2
  exit 1
fi

if grep -q 'Now Reading' "$HOME_HTML"; then
  echo "home about column should not render Now Reading" >&2
  exit 1
fi

if grep -q 'View Projects' "$HOME_HTML"; then
  echo "home about column should not render a View Projects button" >&2
  exit 1
fi

NOTE_CARD_COUNT="$(grep -o 'class="home-entry-card' "$HOME_HTML" | wc -l | tr -d ' ')"
if [ "$NOTE_CARD_COUNT" -lt "6" ]; then
  echo "homepage should render post cards across homepage panels, got $NOTE_CARD_COUNT" >&2
  exit 1
fi

grep -q 'home-notes.js' "$ROOT_DIR/hugo.toml"
grep -q 'function initHomeDashboard' "$ROOT_DIR/assets/js/home-notes.js"
grep -q 'aria-expanded' "$ROOT_DIR/assets/js/home-notes.js"
grep -q 'data-home-panel' "$ROOT_DIR/assets/js/home-notes.js"
grep -q '.home-shell' "$ROOT_DIR/assets/css/custom.css"
grep -q '.home-submenu\[hidden\]' "$ROOT_DIR/assets/css/custom.css"
grep -q '.home-panel\[hidden\]' "$ROOT_DIR/assets/css/custom.css"
grep -q 'grid-template-columns: clamp(140px, 13vw, 188px) minmax(320px, 1fr) clamp(180px, 19vw, 280px)' "$ROOT_DIR/assets/css/custom.css"
grep -q '.home-about-search' "$ROOT_DIR/assets/css/custom.css"
grep -q '.home-focus-list' "$ROOT_DIR/assets/css/custom.css"
grep -q 'class="home-shell content-shell' "$POST_HTML"
grep -q 'class="home-sidebar' "$POST_HTML"
grep -q 'class="content-main"' "$POST_HTML"
grep -q 'article-toc-panel' "$POST_HTML"
grep -q 'data-article-toc-panel' "$POST_HTML"
grep -q 'data-article-toc-content' "$POST_HTML"
grep -q 'class="article-inline-return"' "$POST_HTML"
grep -q 'href="/#latest-notes"' "$POST_HTML"
if grep -q 'data-home-menu="projects"' "$POST_HTML"; then
  echo "article page should not render a second-level projects menu" >&2
  exit 1
fi
if grep -q 'class="article-return-link"' "$POST_HTML"; then
  echo "article return link should live in the main article, not above the TOC" >&2
  exit 1
fi
grep -q 'class="home-shell content-shell' "$PROJECTS_HTML"
grep -q 'project-article' "$PROJECTS_HTML"
grep -q 'project-aside' "$PROJECTS_HTML"
grep -q 'class="project-card"' "$PROJECTS_HTML"
grep -q '目前已做' "$PROJECTS_HTML"
grep -q 'HackAgent' "$PROJECTS_HTML"
if grep -q 'data-home-menu="projects"' "$PROJECTS_HTML"; then
  echo "projects page should not render a second-level projects menu" >&2
  exit 1
fi
grep -q 'align-items: stretch' "$ROOT_DIR/assets/css/custom.css"
grep -q '.content-shell' "$ROOT_DIR/assets/css/custom.css"
grep -q '.content-main' "$ROOT_DIR/assets/css/custom.css"
grep -q '.content-aside' "$ROOT_DIR/assets/css/custom.css"
grep -q '.project-card-grid' "$ROOT_DIR/assets/css/custom.css"
grep -q 'function initArticleToc' "$ROOT_DIR/assets/js/home-notes.js"
grep -q 'article-toc-panel__item--has-children' "$ROOT_DIR/assets/js/home-notes.js"
grep -q 'article-toc-panel__item--open' "$ROOT_DIR/assets/css/custom.css"
if grep -q 'data-article-toc-toggle' "$POST_HTML"; then
  echo "article TOC should expand by heading items, not a separate collapse button" >&2
  exit 1
fi
grep -q 'class="home-shell content-shell search-shell' "$SEARCH_HTML"
grep -q 'class="home-sidebar' "$SEARCH_HTML"
grep -q 'class="content-main"' "$SEARCH_HTML"
grep -q 'class="content-aside search-aside"' "$SEARCH_HTML"
grep -q 'class="site-search"' "$SEARCH_HTML"
grep -q '.search-article .site-search__result' "$ROOT_DIR/assets/css/custom.css"
grep -q '.note-article__content pre code\[data-lang\]::before' "$ROOT_DIR/assets/css/custom.css"
grep -q 'noClasses = false' "$ROOT_DIR/hugo.toml"

if grep -q '<header class="header">' "$SEARCH_HTML"; then
  echo "search page should not render the global header" >&2
  exit 1
fi

if grep -q '<header class="header">' "$POST_HTML"; then
  echo "post detail page should not render the global header" >&2
  exit 1
fi

if grep -q '<header class="header">' "$HOME_HTML"; then
  echo "homepage should not render the global header" >&2
  exit 1
fi
