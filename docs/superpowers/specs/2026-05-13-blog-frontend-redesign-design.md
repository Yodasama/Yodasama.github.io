# Blog Frontend Redesign Design

## Context

The site is a Hugo blog using the Anatole theme, with project-level layout overrides already present in `layouts/` and custom styling in `assets/css/custom.css`. The redesign should keep changes in the site layer instead of editing theme source files directly.

The current direction is a personal knowledge homepage plus a focused note-reading view.

## Goals

- Make the homepage feel like a personal blog homepage, not a generic post list.
- Keep the homepage left side dedicated to identity: avatar, name, signature, and social links.
- Make the homepage right side centered on `Latest Notes`.
- Keep `Projects` visible only as a low-key placeholder for now.
- Make note detail pages read like a lightweight book/documentation page.
- On note detail pages, use the left side for the current article's table of contents only.
- Avoid a full top navigation bar on note detail pages; use a single return button instead.

## Non-Goals

- Do not migrate the whole site to the Hugo Book theme.
- Do not build a full project portfolio section in this redesign.
- Do not add a global article-tree sidebar to note detail pages.
- Do not require JavaScript for the core reading layout.

## Homepage Design

The homepage uses a two-column layout on desktop.

Left column:

- Profile image from `params.profilePicture`.
- Site display name from `params.title`.
- Signature from `params.description`.
- Existing social icon links.

Right column:

- A concise notebook-oriented headline.
- A `Latest Notes` section showing the most recent posts.
- Topic chips derived from existing tags, such as `Security`, `Agent`, and `Algorithm`.
- Note cards that show title, summary, date, and tags.
- A `Projects` placeholder section below notes. It should be visually quiet, with copy indicating that project cards can be added later.

The right column should not include the earlier small side panels such as `Focus`, `By topic`, or `By type`.

Mobile behavior:

- The homepage stacks into one column.
- Profile content appears first.
- Latest notes and the projects placeholder appear below.
- Cards remain compact and readable without horizontal overflow.

## Note Detail Design

Note detail pages switch to a book-like reading layout.

Desktop layout:

- Left panel: return button plus current article table of contents.
- Right panel: article metadata, title, summary, tags, and markdown content.
- The left table of contents is generated from the current article's headings when `toc = true`.
- The left panel must not list other posts or other topics.

Return behavior:

- The return button should link to the homepage notes area, preferably `/#latest-notes`.
- Button text can be `返回首页`.

Navigation:

- Do not show the full site top navigation on note detail pages.
- Cross-article navigation can remain limited to the homepage latest-note cards and any existing previous/next support added later.

Mobile behavior:

- The table of contents moves above the article content.
- The return button remains at the top of the TOC block.
- TOC links can wrap or horizontally scroll if needed, but must not obscure the article.

## Content Model

Use the existing Hugo front matter as much as possible:

- `title` for note title.
- `summary` for note card excerpt.
- `date` for ordering and metadata.
- `tags` for topic chips and note metadata.
- `toc = true` to enable the article table of contents.

No new required front matter fields are needed for the first implementation. A future redesign can add a dedicated note type field if the notes need stronger distinction than tags provide.

## Implementation Boundaries

Expected files:

- `layouts/index.html` for the redesigned homepage structure.
- `layouts/_default/single.html` for the note detail layout.
- `assets/css/custom.css` for site-specific styling.

Implementation should avoid changing files under `themes/anatole/` unless a theme-level limitation makes it unavoidable.

## Verification

After implementation:

- Run a Hugo build.
- Start the local Hugo server.
- Check the homepage desktop and mobile layouts.
- Open at least one note with `toc = true` and verify the left panel shows only that article's headings.
- Verify the return button links back to the homepage notes section.
- Verify existing post content, code blocks, tags, and summaries remain readable.
