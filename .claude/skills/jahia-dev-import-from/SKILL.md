---
name: jahia-dev-import-from
description: Builds a Jahia component inspired by a component on an external URL. Fetches the page, lets the developer target one section, extracts its HTML structure and CSS/JS dependencies, then creates a proper CND + view. Use when asked to "create a component like the one on this page".
allowed-tools: Bash, Read, Write, Edit, WebFetch
---

# Skill: jahia-dev-import-from

Turns a component on an external website into a Jahia component. This is a developer workflow — the result uses CSS Modules, proper Jahia architecture, and is maintainable code. It is not a wholesale site clone.

---

## Step 1 — Fetch and map the page

Fetch the URL with `WebFetch`. If WebFetch fails (403/503), fall back to:

```bash
wget --quiet --user-agent="Mozilla/5.0" -O /tmp/imported-page.html "<URL>"
```

Scan the HTML for semantic section boundaries (`<section>`, `<article>`, `<header>`, `<footer>`, `<main>`, or `<div>` with class names matching patterns like `hero`, `banner`, `card`, `grid`, `slider`, `features`).

Print a numbered text map:

```
[1] HEADER     — logo + nav + CTA button
[2] HERO       — animated text + background image + scroll indicator
[3] FEATURES   — 3-column icon grid
[4] CAROUSEL   — auto-sliding testimonials (Swiper)
[5] FOOTER     — 4-column links + social icons
```

Ask the developer: **"Which section do you want to implement?"**

---

## Step 2 — Extract the HTML fragment

Locate the target section in the fetched HTML. Extract the **complete HTML block** — every element, every attribute, every nesting level. Do not simplify, summarize, or rewrite any part of it.

**For repeating patterns** (card grid, carousel), copy the wrapper structure **plus one complete child item** with all its attributes.

**Replace only dynamic content** with typed placeholders:

| Source HTML | Replacement |
|---|---|
| Text inside an element | `{title}`, `{description}`, etc. |
| Image `src` / `data-bg` / `data-src` URL | `{image}` (will become a `weakreference` field) |
| Link `href` | `{href}` (will become `j:linkType` / `j:linknode`) |

**Keep verbatim:**
- All CSS classes
- All `data-*` attributes (animation libraries, carousel config, IDs)
- `aria-*` and `role` attributes
- `<noscript>` blocks and `<picture>/<source>` elements
- Carousel/slider wrapper `id`s — JS libraries use these for initialization

> ⚠️ Self-check: count the attributes on 2–3 key elements in the source HTML. If your extraction has fewer, you dropped something — re-extract.

---

## Step 3 — Identify content fields vs structural HTML

Show the developer a proposed split:

**Will become CND fields (editable in Jahia):**
- User-facing text: titles, subtitles, descriptions, button labels
- Images (→ `weakreference, picker[type='image']`)
- Links (→ `j:linkType / j:linknode / j:url`)
- Any value that should vary between instances

**Will be hardcoded in the view:**
- Layout wrapper divs
- Icon SVGs that are decorative / never change
- Animation class names and `data-*` config attributes
- ARIA labels that are structural (e.g. `aria-label="Main navigation"`)

Ask the developer to confirm or adjust. If they want something to be editable that wasn't identified, add it as a field.

---

## Step 4 — Identify CSS and JS dependencies

Scan the page `<head>` for resources that the target component depends on:

```bash
# From downloaded HTML, extract stylesheet and script references
grep -E '<link[^>]+stylesheet|<script[^>]+src' /tmp/imported-page.html | head -30
```

Categorize findings:

| Type | Examples | Action |
|---|---|---|
| **Animation library** | AOS, GSAP, ScrollReveal, Animate.css | Likely needed — check npm first |
| **Carousel/slider** | Swiper, Glide, Owl Carousel, Splide | Likely needed — check npm first |
| **Utility CSS** | Bootstrap, Tailwind | May already be in the module or can be imported |
| **Site-specific CSS** | `main.css`, `theme.css` | Targeted import only (see Step 5b) |
| **Fonts** | Google Fonts, custom woff2 | Import if not already in the module |

Report findings, then ask: **"Should I import any of these? (yes / no / specific ones)"**

---

## Step 5 — Create the Jahia component

### Step 5a — CND and view

Using the confirmed field split from Step 3, run the `jahia-cnd-author` and `jahia-dev-create-view` patterns to create:

- `src/components/<Category>/<Name>/definition.cnd`
- `src/components/<Category>/<Name>/types.ts`
- `src/components/<Category>/<Name>/default.server.tsx`
- `src/components/<Category>/<Name>/component.module.css`

**TSX conversion rules** (mechanical, not creative):

1. `class="foo bar"` → `className="foo bar"` — keep class strings as-is if vendor CSS is imported, OR map to `classes.fooBar` if authoring new CSS
2. Void elements: `<img>`, `<input>`, `<br>` → add ` />`
3. `{placeholder}` → `{propName}` matching `Props`
4. Every `data-*`, `aria-*`, `id`, `<noscript>`, `<source>` stays in the TSX

**CSS Modules:** Write new CSS in `component.module.css` that achieves the same visual result. Rename source class names to semantic camelCase keys (`hero__title` → `.heroTitle`). Exception: if you're importing the original CSS as a static asset, use the original class names as plain strings — CSS Modules would rename them and break the imported CSS.

**Interactive components** (animations, carousels, event handlers) → Island architecture:

```tsx
// default.server.tsx — passes config, initializes nothing
({ title, subtitle }: Props, { renderContext }) => (
  <Island component={MyComponentClient} props={{ title, subtitle }} />
)

// MyComponent.client.tsx — owns the browser-side lifecycle
import { useEffect } from "react";

export default function MyComponentClient({ title, subtitle }: Props) {
  useEffect(() => {
    import("aos").then(({ default: AOS }) => AOS.init({ duration: 800 }));
  }, []);

  return (
    <div data-aos="fade-up" className="hero">
      <h1>{title}</h1>
    </div>
  );
}
```

**Edit mode for carousels/sliders:** Render all items flat so editors can see and reorder them:

```tsx
({ slides }, { renderContext }) =>
  renderContext.isEditMode() ? (
    <div className={classes.editStack}>
      <RenderChildren />
      <p className={classes.hint}>Carousel — add or reorder slides above</p>
    </div>
  ) : (
    <Island component={CarouselClient} props={{ count: slides?.length }} />
  )
```

---

### Step 5b — Import static assets (if confirmed in Step 4)

For each confirmed CSS file:

```bash
mkdir -p static/css
curl -sL "<css-url>" -o "static/css/<filename>.css"
```

For JS libraries — prefer npm over manual download:

```bash
# Check if available on npm
npm info <library-name> version 2>/dev/null

# If available:
yarn add <library-name>
# Then import in the .client.tsx: import AOS from "aos";

# If not on npm, download to static:
mkdir -p static/js
curl -sL "<js-url>" -o "static/js/<filename>.js"
```

For fonts:

```bash
mkdir -p static/fonts
curl -sL "<font-url>" -o "static/fonts/<filename>.woff2"
```

Update the module's `Layout` template (`src/templates/Layout.server.tsx` or `src/templates/Layout.jsx`) to include the assets:

```tsx
import { AddResources, buildModuleFileUrl } from "@jahia/javascript-modules-library";

// In the <head> section:
<AddResources type="css" url={buildModuleFileUrl("static/css/vendor.css")} />
<AddResources type="javascript" url={buildModuleFileUrl("static/js/aos.js")} />
```

Update `package.json` → `jahia.static-resources` to expose the static directories:

```json
{
  "jahia": {
    "static-resources": "/dist/client,/dist/assets,/locales,/static/css,/static/js,/static/fonts"
  }
}
```

> **Never hardcode `/modules/<name>/...` paths** — use `buildModuleFileUrl` so the path resolves correctly across environments and module name changes.

---

## Step 6 — Build, deploy, and verify

```bash
yarn build && yarn jahia-deploy
```

Verify the component registered:

```bash
docker logs $(docker ps --format '{{.Names}}' | grep -i jahia | head -1) 2>&1 \
  | grep "Registered Jahia component" | grep "<ComponentName>"
```

Expected: one line per view. If absent, check the build output for TypeScript errors in the new view file.

---

## Rules that always apply

- **CSS Modules for authored styles** — use `classes.propertyName`, not plain string class names
- **Vendor class names stay as-is** — when importing external CSS, don't route those classes through CSS Modules
- **No hardcoded links** — `href` and `src` must come from JCR props or `buildModuleFileUrl`
- **Island for anything interactive** — animations, browser events, `useState`, third-party JS → `.client.tsx`
- **All props optional in `types.ts`** — even CND `mandatory` fields
- **Edit mode awareness** — carousels, sliders, and tabs should render flat in edit mode
