---
name: jahia-dev-create-page-template
description: Creates a Jahia page template with Areas and AbsoluteAreas. Use when asked to add a new page layout, create a page template, or set up a shared area like a header or footer.
allowed-tools: Bash, Read, Write, Edit
---

## Overview

A **page template** defines the full layout of a page. It is registered with `componentType: "template"` and always targets `jnt:page`. Templates contain **Areas** (per-page content) and **AbsoluteAreas** (shared across all pages, e.g. footer, navbar).

---

> ⚠️ **CMS rule — never hardcode links in templates.** Navigation links, logo hrefs, footer links — all must come from contributed content (via props, `buildNodeUrl`, or `j:linkType`). Do not put literal URLs in template code.

## Step 1 — Create the template file

Page templates live in `src/templates/<ModuleName>Template/`. Name the file `default.server.tsx`.

```tsx
import React from "react";
import { Area, AbsoluteArea, getChildNodes, buildNodeUrl, jahiaComponent } from "@jahia/javascript-modules-library";
import styles from "./template.module.css";

jahiaComponent(
  {
    componentType: "template",   // "template" for full pages, not "view"
    nodeType: "jnt:page",        // always jnt:page for page templates
    displayName: "Default Template",
    name: "default",
  },
  ({ "jcr:title": title }, { renderContext, mainNode }) => {
    // Pages live under /sites/<key>/home — not directly under the site node
    const siteHome = renderContext.getSite().getNode("home");
    const navPages = getChildNodes(siteHome, -1, 0, n => n.isNodeType("jnt:page"));
    const siteName = renderContext.getSite().getPropertyAsString("j:siteTitle") ?? renderContext.getSite().getName();
    return (
      <html lang="en">
        <head>
          <meta charSet="UTF-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1" />
          {/* jcr:title is the short page name — template appends site name for SEO */}
          <title>{title}{siteName ? ` | ${siteName}` : ""}</title>
        </head>
        <body>
          <a href="#main-content" className={styles.skipLink}>Skip to main content</a>
          <header className={styles.header}>
            <nav aria-label="Main navigation">
              <ul className={styles.navList}>
                <li key={siteHome.getPath()}>
                  <a href={buildNodeUrl(siteHome)} aria-current={siteHome.getPath() === mainNode.getPath() ? "page" : undefined}>
                    {siteHome.getPropertyAsString("jcr:title") ?? siteHome.getName()}
                  </a>
                </li>
                {navPages.map(page => (
                  <li key={page.getPath()}>
                    <a
                      href={buildNodeUrl(page)}
                      aria-current={page.getPath() === mainNode.getPath() ? "page" : undefined}
                    >
                      {page.getPropertyAsString("jcr:title") ?? page.getName()}
                    </a>
                  </li>
                ))}
              </ul>
            </nav>
          </header>
          <main id="main-content">
            <h1 className={styles.pageTitle}>{title}</h1>
            <Area name="pagecontent" />
          </main>
          <footer className={styles.footer}>
            <AbsoluteArea name="footer" parent={renderContext.getSite()} />
            <p className={styles.copyright}>{"© "}{renderContext.getSite().getName()}</p>
          </footer>
        </body>
      </html>
    );
  },
);
```


---

## Step 2 — Choose: Area vs AbsoluteArea

| | `<Area>` | `<AbsoluteArea>` |
|---|---|---|
| Content | Per-page (each page has its own) | Shared across all pages |
| Use for | Page body, hero, sections | Footer, navbar, sidebar |
| `parent` prop | Not needed | Set to `renderContext.getSite()` for site-wide |

---

## Step 3 — Use typed area nodes (required for good editorial UX)

Instead of a single generic area type, define **one area type per section** with a tight child constraint. This ensures editors only see relevant content types in each area's "New content" menu.

```cnd
// settings/definitions.cnd

[namespacemix:pageComponent] > namespacemix:component mixin

// ✅ Typed areas — editors only see the right types per area
// Use jmix:hiddenType (NOT jmix:studioOnly) — hides from picker while keeping rendering intact
[namespace:heroArea] > jnt:content, jmix:list, jmix:hiddenType orderable
 + * (namespace:heroSection)

[namespace:featuresArea] > jnt:content, jmix:list, jmix:hiddenType orderable
 + * (namespace:featureCard)

// Generic fallback — use only when no tighter constraint makes sense
[namespace:pageArea] > jnt:content, jmix:list, jmix:hiddenType orderable
 + * (namespacemix:pageComponent)
```

Then in the template:

```tsx
<Area name="hero"     nodeType="namespace:heroArea" />
<Area name="features" nodeType="namespace:featuresArea" />
<Area name="footer"   nodeType="namespace:pageArea" />   // generic ok for footer
```

> ⚠️ **Never use a generic `pageArea` for every area.** If all areas accept all `pageComponent` types, editors will see "New Hero Section" as an option in a feature card area, which is confusing and error-prone.

> **Sections driven by content folders** (e.g. a tutorials listing that queries `/contents/tutorials/`) should NOT use an Area at all — the template renders them via a server-side query component. Exposing an Area there invites editors to manually add duplicates of auto-queried content.

> ⚠️ **CSS gotcha — `Area` renders children directly, no wrapper div.** When wrapping an `<Area>` in a container div and styling children with `.container > div { display: grid }`, the grid won't apply because there is no intermediate `div` — the area's child components are rendered as direct children of `.container`. Always apply grid/flex layout **on the container itself** when its only content is an Area:
> ```css
> /* ✅ correct — grid on the container that wraps the Area */
> .featuresSection .container { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 1.5rem; }
> /* ❌ wrong — no div is inserted between container and the card articles */
> .container > div { display: grid; }
> ```

### ⚠️ After defining `pageComponent` — update existing components

**This is the most common mistake:** if the module already has content types, they all extend `namespacemix:component`. After introducing the custom area type, **editors will not be able to drop anything** until you update the page-level components to extend `namespacemix:pageComponent` instead.

Scan all `definition.cnd` files and update every component that should be droppable in page areas:

```cnd
// Before (editors can't drop in pageArea):
[namespace:heroSection] > jnt:content, namespacemix:component

// After (editors can drop in pageArea):
[namespace:heroSection] > jnt:content, namespacemix:pageComponent
```

**Which components need `pageComponent`?**
- Standalone page sections (hero, feature cards, text blocks, etc.) → `namespacemix:pageComponent`
- Child-only types (CTA inside hero, card inside list) → keep `namespacemix:component`
- `jmix:mainResource` types stored in content folders → keep `namespacemix:component`

---

## Step 4 — Page template vs sectioning component

Before creating a new page template, ask:

| Is this… | Use a… |
|---|---|
| A new top-level page layout (different column structure, hero slot) | **New page template** |
| A layout variation that could be reused as a section on any page | **Sectioning component** (use the build-component skill) |
| A minor style difference on an existing template | **Named view** of the existing template |

**Guideline**: keep page templates small (1–4). Use sectioning components for compositional differences.

---

## Step 5 — Define structural (non-selectable) container nodes

Some nodes are purely structural — they hold child nodes but shouldn't appear in the component picker. Omit `namespacemix:component` and add `jmix:hiddenType`:

```cnd
[namespace:header] > jnt:content, jmix:hiddenType
 + hero (namespace:heroSection)
```

Render it with `RenderChild`:

```tsx
// src/components/Header/default.server.tsx
import { jahiaComponent, RenderChild } from "@jahia/javascript-modules-library";

jahiaComponent(
  { componentType: "view", nodeType: "namespace:header" },
  () => <RenderChild name="hero" />,
);
```

---

## Step 6 — Bootstrap site structure with import.xml

`import.xml` provisions every new site created from this template set. **Always update it** — editors cannot contribute if there's no page structure to start from.

**Minimum required:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<content xmlns:j="http://www.jahia.org/jahia/1.0" xmlns:jcr="http://www.jcp.org/jcr/1.0">
  <modules jcr:primaryType="jnt:modules">
    <your-module-name>

      <!-- Homepage — MUST use your actual template name, not "basic" -->
      <home j:isHomePage="true" j:templateName="homepage" jcr:primaryType="jnt:page">
        <j:translation_en jcr:language="en" jcr:mixinTypes="mix:title"
          jcr:primaryType="jnt:translation" jcr:title="Home"/>

        <!-- Pre-create area nodes so editors can start dropping content immediately -->
        <hero jcr:primaryType="namespace:pageArea"/>
        <main jcr:primaryType="namespace:pageArea"/>
      </home>

      <!-- Add sub-pages for each template you created -->
      <documentation j:templateName="documentation" jcr:primaryType="jnt:page">
        <j:translation_en jcr:language="en" jcr:mixinTypes="mix:title"
          jcr:primaryType="jnt:translation" jcr:title="Documentation"/>
        <hero jcr:primaryType="namespace:pageArea"/>
      </documentation>

      <!-- Offline management pages — never published, system-name locked -->
      <drafts jcr:primaryType="jnt:page" j:templateName="basic"
        jcr:mixinTypes="jmix:systemNameReadonly jmix:nolive">
        <j:translation_en jcr:language="en" jcr:mixinTypes="mix:title"
          jcr:primaryType="jnt:translation" jcr:title="Drafts"/>
      </drafts>

      <!-- Content folders — store jmix:mainResource content here, not in pages -->
      <contents jcr:primaryType="jnt:contentFolder">
        <articles jcr:primaryType="jnt:contentFolder"
          jcr:mixinTypes="jmix:contributeMode" j:contributeTypes="namespace:docArticle">
          <j:translation_en jcr:language="en" jcr:primaryType="jnt:translation" jcr:title="Articles"/>
        </articles>
      </contents>

    </your-module-name>
  </modules>
</content>
```

**Rules:**
- `j:templateName` must match the `name:` in your `jahiaComponent` call — if it's wrong, editors get a blank page
- Pre-create area nodes (`jcr:primaryType="namespace:pageArea"`) so editors don't face empty containers on first open
- Add a starter component in the hero area so the page isn't visually blank (optional but strongly recommended)
- Content folders with `jmix:contributeMode` + `j:contributeTypes` restrict what editors can create in them
- `jmix:systemNameReadonly` prevents editors from renaming or moving management pages; `jmix:nolive` prevents accidental publishing

---

## Step 7 — Build and deploy

```bash
yarn build && yarn jahia-deploy
```

> ⚠️ **Do not use `yarn dev`** — it is a continuous file watcher that should only be started manually when needed for rapid iteration. For agentic workflows, always use `yarn build && yarn jahia-deploy` for explicit, one-shot deploys.

After deploying, the new template will appear in the **template selection** step when creating a new page (right-click on a page in the sidebar → **+ New Page**).

---

## Common patterns

### Single column with shared footer

```tsx
<Layout title={title}>
  <Area name="main" />
  <AbsoluteArea name="footer" parent={renderContext.getSite()} nodeType="namespace:footer" />
</Layout>
```

### Two-column layout

```tsx
<Layout title={title}>
  <div style={{ display: "grid", gridTemplateColumns: "1fr 2fr", gap: "2rem" }}>
    <Area name="sidebar" />
    <Area name="main" />
  </div>
</Layout>
```

### Edit mode-aware rendering

```tsx
({ "jcr:title": title }, { renderContext }) => {
  const isEdit = renderContext.isEditMode();
  return (
    <Layout title={title}>
      <Area name="main" />
      <nav style={{ flexDirection: isEdit ? "column" : "row" }}>
        <AbsoluteArea name="footer" parent={renderContext.getSite()} />
      </nav>
    </Layout>
  );
}
```

---

## Validation checklist
- [ ] `componentType: "template"` and `nodeType: "jnt:page"`
- [ ] `name` is set (used in Jahia UI template picker)
- [ ] Skip link present: `<a href="#main-content">Skip to main content</a>`
- [ ] Nav built from `getChildNodes(site.getNode('home'), ...)` — pages are children of `home`, not of the site node
- [ ] `<h1>{title}</h1>` in the template — no `<h1>` in any component
- [ ] `<footer>` landmark always has visible content (never empty)
- [ ] Areas use a custom area node type (not bare `<Area name="..."/>`)
- [ ] Custom area type has `jmix:list`, `jmix:hiddenType`, and `orderable`
- [ ] Decision made: page template vs sectioning component (see Step 4)
- [ ] `yarn build && yarn jahia-deploy` run and template appears in Jahia UI

## Troubleshooting

### 🚨 Area renders blank — content invisible

**Symptom:** An Area in your template produces no HTML output at all, even though you can see children in jContent.

**Root cause:** Jahia's `Area` component auto-creates the JCR area node using its declared `nodeType` on first page load. If that node was subsequently **deleted and recreated manually** (e.g. via GraphQL) with a *different* type, the declared type and the actual JCR type no longer match — and Jahia silently renders nothing.

**Fix:** Delete the mistyped node and let Jahia recreate it automatically:

```graphql
mutation {
  jcr {
    mutateNode(pathOrId: "/sites/mySite/home/hero") {
      delete
    }
  }
}
```

Visit the page — Jahia recreates the node with the correct type and children render again.

**Prevention:** Never manually create area nodes via GraphQL with a type that differs from the `nodeType` declared in the template. Always let Jahia auto-create area nodes on first render.

> https://academy.jahia.com/tutorials-get-started/front-end-developer/the-about-us-page
