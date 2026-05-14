# Blog Homepage Rebuild Design

## Context

The site is a Hugo personal blog using the Anatole theme, with site-level overrides in `layouts/` and custom styling in `assets/css/custom.css`. The homepage should be rebuilt from the Markdown content under `content/`, especially posts, projects, and the About page.

The intended visual direction is Apple-style minimalism: clean off-white surfaces, restrained borders, generous whitespace, dark neutral text, subtle shadows, and smooth state changes. The layout should feel like a quiet personal knowledge dashboard rather than a generic landing page.

## Goals

- Build a three-column homepage inspired by a compact dashboard layout.
- Keep the left column narrow and navigation-focused.
- Keep the center column as the primary content area.
- Keep the right column narrow and supportive, centered on About information.
- Let left-side second-level menu clicks update the center content without a full page navigation.
- Keep the homepage simple: no tag-chip filter bar and no heavy visual decoration.
- Use existing Markdown front matter as the content source wherever possible.

## Non-Goals

- Do not migrate the site to another Hugo theme.
- Do not add a large marketing hero section.
- Do not build a full project portfolio system in this pass.
- Do not require a server-side request or page reload for category switching.
- Do not add search, pagination, or tag filtering to the homepage in this pass.

## Layout

The homepage uses a three-column desktop layout:

- Left navigation column: narrow, fixed-feeling sidebar.
- Center content column: main reading and list surface.
- Right auxiliary column: narrow About panel.

Desktop proportions should keep the side columns compact so the center article list has the most space. A practical starting point is approximately `150px / 1fr / 200px`, adjusted responsively.

On mobile and narrow screens, the layout stacks:

- Profile and navigation first.
- Main content second.
- About panel third.

The mobile layout must avoid horizontal scrolling. The expandable navigation still works, but it can occupy full width above the article list.

## Left Navigation

The left column has three zones.

Top:

- Small avatar from `params.profilePicture`.
- Name from `params.title` or `params.author`.

Middle:

- `Home` as a normal top-level entry.
- `Notes` as an expandable top-level button.
- `Projects` as an expandable top-level button.

The top-level `Notes` and `Projects` controls must behave like accordion buttons. Clicking them expands or collapses the submenu in place. It should not feel like a page jump or full navigation.

`Notes` submenu:

- `Security`
- `Agent`
- `题解`

`Projects` submenu:

- `HackAgent`
- `OnCallAgent`
- `安全面经`

Bottom:

- Social links from `params.socialIcons`, currently GitHub and Email.

## Center Content

The center column starts with a concise personal signature line. The source can be `content/_index.md` content or `params.description`; implementation should choose the cleaner result based on current Hugo data availability.

Below the signature, the center shows the article list.

Default state:

- Shows all posts from `params.mainSections`.
- Sorts by date descending.
- Uses each Markdown file's `title`, `date`, and `summary`.

Filtered state:

- Clicking `Security`, `Agent`, or `题解` in the left submenu updates the center list in place.
- The page does not reload and the URL does not need to change.
- The center heading changes to the selected category name.
- Only matching posts are visible.
- Matching is based on existing post `tags`, case-insensitive.

Article cards:

- Use a compact row card format.
- Show date on the left and title plus summary on the right.
- Clicking an article card navigates to that post's detail page.
- Cards use subtle borders, white or near-white surfaces, and restrained hover feedback.

## Right Auxiliary Column

The right column uses `content/about.md` as the source of truth.

Primary content:

- About heading.
- A concise excerpt from the About page.
- Optional small avatar or muted panel element if it improves balance without adding clutter.

Light contextual state:

- Keep About as the main content at all times.
- Add a small bottom section that reflects the current center state.
- For example: `Now Reading`, selected category name, visible note count, and latest visible update date.

This right-side state is supportive only. It should not become a second navigation system.

## Interaction Model

JavaScript may enhance the homepage, but the base content should still render as normal links/cards.

Required client-side behavior:

- Accordion state for `Notes` and `Projects`.
- Center list filtering for `Security`, `Agent`, and `题解`.
- Active state styling for the selected submenu item.
- Right-side current-state text update.

The interaction should use buttons for controls that change state without navigation. Links should be reserved for actions that actually navigate.

Accessibility requirements:

- Accordion buttons expose `aria-expanded`.
- The selected submenu item exposes `aria-current` or equivalent state.
- The center status update is available to assistive technology, such as with `aria-live="polite"`.
- Text contrast meets normal reading contrast on light backgrounds.

## Visual System

The homepage should use an Apple-style minimal visual language:

- Background: off-white or light gray, close to `#F5F5F7`.
- Surfaces: white or translucent white.
- Text: near-black, close to `#1D1D1F`.
- Muted text: neutral gray, close to `#6E6E73`.
- Borders: low-contrast light gray.
- Radius: moderate rounded corners for panels and cards.
- Shadows: subtle and sparse.

Typography should favor the system stack or Inter-like sans-serif behavior. Avoid decorative type, strong gradients, large hero typography, and saturated color palettes.

## Content Mapping

Posts are currently available under `content/posts/`.

Expected topic mapping:

- `Security`: posts tagged `security`, including security interview and hardening notes.
- `Agent`: posts tagged `agent`.
- `题解`: posts tagged `题解` or closely related code/problem-solving tags if needed.

Projects are currently represented by `content/projects.md`. The homepage submenu can link to anchors or in-page project entries when implementation creates them. For this pass, project submenu entries may navigate to the Projects page or update the center area with project summaries if the implementation can do so cleanly from existing Markdown.

## Implementation Boundaries

Expected files:

- `layouts/index.html` for the rebuilt homepage structure and data attributes.
- `assets/css/custom.css` for the Apple-style three-column visual system.
- `assets/js/home-notes.js` for accordion and in-place center filtering.

Avoid editing files under `themes/` unless a site-level override cannot solve the problem.

## Verification

After implementation:

- Run a Hugo build.
- Verify the homepage renders all notes by default in descending date order.
- Click `Notes` and confirm it expands without a page reload.
- Click `Security`, `Agent`, and `题解`; confirm the center list updates in place.
- Confirm the right About panel remains visible and its small current-state section updates.
- Confirm article cards still navigate to post detail pages.
- Check desktop and mobile widths for overflow, cramped sidebars, and readable text.
