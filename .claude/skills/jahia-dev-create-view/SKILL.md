---
name: jahia-dev-create-view
description: Implements a React view for a Jahia content type. Use when asked to create or update the rendering of a component, add a new view, or add styling.
allowed-tools: Bash, Read, Write, Edit
---

## Overview

A **view** tells Jahia how to render a content type. Views are React components (TypeScript/TSX) registered with the `jahiaComponent` function. They follow the **Single Directory Component (SDC)** pattern alongside the `definition.cnd`.

---

## File naming convention

| Filename | Meaning |
|---|---|
| `default.server.tsx` | Default server-side rendered view |
| `<name>.server.tsx` | Named view (e.g. `small.server.tsx`) |
| `<name>.client.tsx` | Client-side rendered (interactive) view |

A node type can have **multiple views**. When `name` is omitted in `jahiaComponent`, the view is the default.

---

## Step 1 — Create the view file

In the component folder (`src/components/<Category>/<Name>/`), create `default.server.tsx`:

```tsx
import { jahiaComponent, buildNodeUrl, RenderChildren, RenderChild } from "@jahia/javascript-modules-library";
import type { Props } from "./types.js";
import classes from "./component.module.css";

jahiaComponent(
  {
    componentType: "view",       // always "view" for a component (use "template" for page templates)
    nodeType: "namespace:typeName",
    displayName: "Human Readable Name",
    // name: "small",            // omit for default view; set for named views
  },
  ({ title, subtitle, background }: Props) => (
    <section className={classes.root}>
      <h2>{title}</h2>
      <p>{subtitle}</p>
    </section>
  ),
);
```

`jahiaComponent` **returns its second argument** (the React component). Export it to reuse the component directly in other views:

```tsx
// small.server.tsx — registered as a named view AND exported for direct reuse
export const SmallHero = jahiaComponent(
  { componentType: "view", nodeType: "ns:heroSection", name: "small" },
  ({ title, background }: Props) => <header style={{ backgroundImage: `url(${buildNodeUrl(background)})` }}><h1>{title}</h1></header>,
);

// fullPage.server.tsx — reuse the component directly without going through Jahia rendering
import { SmallHero } from "../Hero/Section/small.server.jsx";
<SmallHero title={title} background={cover} />
```

### When implementing a view from existing HTML

When you have a source HTML fragment to translate (e.g. from `/jahia-dev-import-from`), apply only **mechanical transformations**:

- `class=` → `className=`
- Void elements: `<img>`, `<input>`, `<br>` → self-close with ` />`
- `{placeholder}` text → `{propName}` matching `Props`

**Never** remove, rearrange, or simplify elements. Every `data-*`, `aria-*`, `role`, `id`, `<noscript>`, and `<source>` must appear in the TSX output. Carousel and slider wrapper `id`s in particular must be preserved verbatim — JS libraries use them for initialization.

**Self-check before finishing:** Count the attributes on 2–3 key elements in the source HTML. If the source `<div>` has 6 attributes and your TSX has 4, you dropped something — go back.

**CSS class names:** Rename source HTML class names to CSS Module keys (`hero__title` → `classes.heroTitle`). If the component also imports a vendor CSS file as a static asset (see `jahia-dev-import-from`), those vendor classes stay as plain strings in the JSX — they are not processed by CSS Modules.
```

---

## Step 1b — Accessibility and SEO rules (apply to every view)

Build these requirements in from the start — retrofitting them later is more expensive.

### Semantic HTML structure

| Element | Rule |
|---|---|
| `<section>`, `<article>` | Wrap every self-contained block of content |
| `<header>` / `<footer>` | Use for the page header and footer in page templates |
| `<nav>` | Wrap navigation menus; add `aria-label` when there are multiple navs |
| `<main>` | Exactly one per page, wrapping all page body content (already enforced by the Layout component for page templates) |
| Headings | Each page must have exactly one `<h1>`; section headings use `<h2>`; sub-section headings use `<h3>`. Never skip levels. |

### Images

Every `<img>` must have an `alt` attribute. Decorative images use `alt=""`. Informational images use a descriptive string from a CND property:

```tsx
// ❌ Missing alt
<img src={buildNodeUrl(props.image)} />

// ✅ Alt from the image node's title (no extra CND property needed)
<img src={buildNodeUrl(props.image)} alt={props.image?.getPropertyAsString("jcr:title") ?? ""} />
```

The image node already has `jcr:title` (from `mix:title`). **Do not add `imageAlt (string) i18n`** to the CND — it forces editors to enter duplicate data.

### Colour contrast

Use colours with a contrast ratio ≥ 4.5:1 for body text and ≥ 3:1 for large text (18px+ or bold 14px+) against the background. Avoid light grey on white. When in doubt, use near-black (`#333333` or `#1a1a1a`) for body text.

### Link and button names

Every `<a>` and `<button>` must have an accessible name — either visible text or `aria-label`. Icon-only buttons must have `aria-label`:

```tsx
// ❌ No accessible name
<button><svg>…</svg></button>

// ✅ Accessible name via aria-label
<button aria-label="Close menu"><svg aria-hidden="true">…</svg></button>
```

### Focus styles

Never suppress focus indicators globally. Use `:focus-visible` to style keyboard focus:

```css
/* ❌ Never do this */
* { outline: none; }

/* ✅ Style keyboard focus without affecting mouse users */
:focus-visible { outline: 2px solid #0969da; outline-offset: 2px; }
```

---

## Step 2 — Import Props from types.ts

Always import `Props` from `./types.js` (not `./types.ts` — use `.js` extension at import time):

```ts
import type { Props } from "./types.js";
```

If `types.ts` doesn't exist yet, create it first (see `jahia-cnd-author` skill).

---

## CMS rule — never hardcode links or URLs

> ⚠️ **This is a CMS. All links must come from contributed content — never from hardcoded strings in code.**

> 🚫 **NEVER use an external link (`j:linkType: "external"`) to point to an internal Jahia page.** Use `"internal"` with `j:linknode` instead. An external URL hardcoded to an internal path breaks on environment changes, language switches, workspace toggling (live/preview), and vanity URL rewrites.

```tsx
// ❌ Wrong — hardcoded URL
<a href="https://www.jahia.com">Jahia</a>
<a href="/en/documentation">Documentation</a>

// ❌ Wrong — external link used for an internal page
// j:linkType: "external", j:url: "/sites/mySite/documentation.html"

// ✅ Correct — internal link to a JCR node
switch (props["j:linkType"]) {
  case "internal": return <a href={buildNodeUrl(props["j:linknode"])}>{props.label}</a>;
  case "external": return <a href={props["j:url"]}>{props.label}</a>;  // only for truly external URLs
}

// ✅ Correct — URL resolved from a JCR node at render time
<a href={buildNodeUrl(currentNode)}>{title}</a>
```

This applies everywhere: `href`, `src`, `action`, `data-url`. If a link needs to appear on screen, it must have a corresponding contributed field (`j:linkType`, `weakreference`, or similar). The only exception is links within the CMS UI itself (edit mode chrome).

---

## Step 3 — Use library helpers as needed

### `buildNodeUrl(node)` — convert a JCR node to a URL

```tsx
import { buildNodeUrl } from "@jahia/javascript-modules-library";

<img src={buildNodeUrl(coverNode)} alt="Descriptive alt text" />
<header style={{ backgroundImage: `url(${buildNodeUrl(background)})` }}>
```

**Options** (second argument):

| Option | Default | Use |
|---|---|---|
| `extension` | `.html` | Change output extension, e.g. `extension: ".pdf"` |
| `language` | current language | Override language: `language: "fr"` |
| `mode` | current mode | Force workspace: `"edit"`, `"preview"`, or `"live"` |
| `parameters` | — | Append query params: `parameters: { page: "2" }` |

```tsx
// Link to the blog page in the current language
<a href={buildNodeUrl(renderContext.getSite().getNode("blog"))}>Blog</a>

// Same link forced to French
<a href={buildNodeUrl(blogNode, { language: "fr" })}>Blog (FR)</a>
```

> ⚠️ **Always guard optional nodes**: `buildNodeUrl(undefined)` throws `"Expected a node in buildNodeUrl, received undefined"`. If the prop is optional in the CND, guard it:
> ```tsx
> // ❌ Crashes when background is not set
> style={{ backgroundImage: `url(${buildNodeUrl(background)})` }}
>
> // ✅ Safe
> style={background ? { backgroundImage: `url(${buildNodeUrl(background)})` } : undefined}
> ```

> ⚠️ **Caching rule**: Never render properties of a **weakreference** node directly in the same view. Doing so will produce stale output because Jahia's cache is based on the referencing node, not the referenced one. Instead, render the referenced node using `<RenderChild>` (or a dedicated sub-view), or call `addCacheDependency` explicitly. Example:
>
> ```tsx
> // ❌ Don't do this — stale on referenced node change
> <img src={buildNodeUrl(background)} alt={background.getProperty('jcr:title').getString()} />
>
> // ✅ Do this — render the referenced node as its own view
> <RenderChild name="background" />
> ```

### `RenderChildren` — render child nodes with optional pagination and filtering

```tsx
import { RenderChildren } from "@jahia/javascript-modules-library";

// All children
<RenderChildren />

// Offset-based pagination
<RenderChildren pagination={{ count: 10, start: 0 }} />

// Page-based pagination (for paginator UI)
<RenderChildren pagination={{ count: 10, page: 0 }} />

// Filter by node type — string (single type) or function
<RenderChildren filter="ns:cardItem" />
<RenderChildren filter={(node) => node.isNodeType("ns:highlight")} />

// Combined
<RenderChildren pagination={{ count: 6, page: 0 }} filter="ns:blogPost" />
```

### `RenderChild` — render a specific named child node

```tsx
import { RenderChild } from "@jahia/javascript-modules-library";

<RenderChild name="hero" />                    // default view
<RenderChild name="hero" view="small" />       // named view
```

### `Render` — render any arbitrary JCR node or virtual node

```tsx
import { Render } from "@jahia/javascript-modules-library";

// Render a specific node by reference (also solves the weakreference cache issue)
<Render node={cityNode} view="name" />

// Render a virtual node — no JCR storage, no editor interaction needed
// Use for components that take no parameters and need no per-page configuration
<Render content={{ nodeType: "namespace:navBar" }} />
```

**Virtual nodes** (`content={{ nodeType }}`) render a component inline without creating a JCR node. This is the right pattern for parameterless structural components like a nav bar that is always the same on every page. Unlike `<AbsoluteArea>`, virtual nodes require zero editor interaction.

> **Why `<Render node={...} />` solves the cache issue**: When you render a weakreference node via `<Render>`, its fragment is cached separately. If the referenced node changes, its fragment is invalidated and Jahia propagates that invalidation upward to any parent fragment that included it.

### `linkTypeInitializer` — rendering links

When a CND type uses `choicelist[linkTypeInitializer]`, the `j:linkType` property is a discriminator, NOT a URL. Use a `switch` statement:

```tsx
import { buildNodeUrl, jahiaComponent } from "@jahia/javascript-modules-library";
import type { Props } from "./types.js";

jahiaComponent(
  { componentType: "view", nodeType: "namespace:callToAction" },
  (props: Props) => {
    switch (props["j:linkType"]) {
      case "internal":
        return <a href={buildNodeUrl(props["j:linknode"])}>{props.label}</a>;
      case "external":
        return <a href={props["j:url"]} title={props["j:linkTitle"]}>{props.label}</a>;
      default:
        return <span>{props.label}</span>;
    }
  },
);
```

The `Props` type must be a discriminated union (see `jahia-cnd-author` skill).

### Cache properties — controlling fragment caching

Add a `properties` key to `jahiaComponent` to tune caching:

```tsx
jahiaComponent(
  {
    componentType: "view",
    nodeType: "namespace:price",
    properties: {
      "cache.expiration": "60",   // re-render at most once per minute
    },
  },
  ({ price }: Props) => <span>{price}</span>,
);
```

```tsx
jahiaComponent(
  {
    componentType: "view",
    nodeType: "namespace:greeting",
    properties: {
      "cache.perUser": "true",    // different cache per logged-in user
    },
  },
  (_, { renderContext }) => (
    <div>Welcome, {renderContext.getUser().getUsername()}</div>
  ),
);
```

> Cache only applies in **live mode**. Edit and preview modes bypass the cache entirely.

### `buildModuleFileUrl` — URL to a static module asset

```tsx
import { buildModuleFileUrl, AddResources } from "@jahia/javascript-modules-library";

// Inject a vendor CSS file into the page head
<AddResources type="css" url={buildModuleFileUrl("css/vendor.min.css")} />

// Reference a bundled image
<img src={buildModuleFileUrl("images/placeholder.svg")} alt="" />
```

Never hardcode `/modules/<name>/javascript/apps/...` paths — use `buildModuleFileUrl` so the path resolves correctly across environments.

---

### `getChildNodes` — iterate over child nodes in code

```tsx
import { getChildNodes, buildNodeUrl, jahiaComponent } from "@jahia/javascript-modules-library";
import type { JCRNodeWrapper } from "org.jahia.services.content";

jahiaComponent(
  { componentType: "view", nodeType: "namespace:navBar" },
  (_, { renderContext, mainNode }) => {
    // Get all child pages of the site root
    const pages = getChildNodes(renderContext.getSite(), -1, 0,
      (node: JCRNodeWrapper) => node.isNodeType("jnt:page")
    );
    return (
      <nav>
        <ul>
          {pages.map(page => (
            <li key={page.getPath()}>
              <a
                href={buildNodeUrl(page)}
                aria-current={page.getPath() === mainNode.getPath() ? "page" : undefined}
              >
                {page.getProperty("jcr:title").getString()}
              </a>
            </li>
          ))}
        </ul>
      </nav>
    );
  },
);
```

`getChildNodes(node, limit, offset, filterFn)` — `limit: -1` means no limit.

Use `aria-current="page"` (not a CSS class) to mark the active page — it's the accessible standard and can be styled with `[aria-current="page"] { font-weight: bold }`. Compare against `mainNode.getPath()` since `===` identity comparison doesn't work across GraalJS polyglot contexts.

### `useServerContext` — access rendering context

The second argument to `jahiaComponent` is the `ServerContext`. You can also call `useServerContext()` explicitly in helper functions outside the component signature.

```tsx
jahiaComponent(
  { componentType: "view", nodeType: "ns:type" },
  ({ title }: Props, { renderContext, currentNode, mainNode, jcrSession, bundleKey }) => {
    const isEdit = renderContext.isEditMode();
    const siteKey = renderContext.getSite().getName();
    return <div data-edit={isEdit}>{title}</div>;
  },
);
```

| Context field | Type | What it is |
|---|---|---|
| `renderContext` | `RenderContext` | Full rendering context (site, workspace, edit mode, user) |
| `currentNode` | `JCRNodeWrapper` | The component's own JCR node |
| `mainNode` | `JCRNodeWrapper` | The page's main resource node |
| `currentResource` | `Resource` | The render resource |
| `jcrSession` | `JCRSessionWrapper` | Current JCR session — do NOT hold across requests |
| `bundleKey` | `string` | Module bundle key (e.g. `"my-module"`) |

> Use `mainNode` to navigate to the page or site from within a sub-component. Use `jcrSession` for JCR reads that can't go through props (e.g. loading a node by path in a computed listing).

---

### `Java.type()` — low-level Java interop

For accessing Java classes directly from JS (use only for well-known, stable APIs):

```js
const LogManager = Java.type("org.apache.logging.log4j.LogManager");
const logger = LogManager.getLogger("MyJSLogger");
logger.info("Hello from JS!");
```

Only use `Java.type()` with classes from Jahia's documented core. Undocumented classes may change without notice. Prefer `useServerContext()` for officially supported objects.

**Mixing JS and Java modules** is fully supported — content types and services from one type can be used by the other. What does NOT work:
- JSP files inside a JS module
- JSX views inside a Java module

---

### Render filters

Register a render filter from a JS module's init script to transform rendered output:

```js
registry.add("render-filter", "myFilter", renderFilterRef, {
  target: "render:50",           // phase + priority (lower = earlier)
  applyOnNodeTypes: "jnt:bigText",
  prepare: (renderContext, resource, chain) => { /* setup before render */ },
  execute: (previousOut, renderContext, resource, chain) => {
    return previousOut.replace("foo", "bar");
  },
});
```

The `target` string format is `"<phase>:<priority>"`. Filters with priority < 16 run on every request; priority > 16 only on cache miss.

---

### `useGQLQuery` — server-side GraphQL

Executes a GraphQL query **synchronously** using the current user's credentials. Returns the `data` portion of the response.

```tsx
import { useGQLQuery, jahiaComponent } from "@jahia/javascript-modules-library";
import { gql } from "graphql-tag";

const QUERY = gql`
  query ListNodes($path: String!) {
    jcr {
      nodeByPath(path: $path) {
        children { nodes { name displayName path } }
      }
    }
  }
`;

jahiaComponent(
  { componentType: "view", nodeType: "ns:listing" },
  (_, { renderContext }) => {
    const siteKey = renderContext.getSite().getName();
    const data = useGQLQuery(QUERY, { path: `/sites/${siteKey}/contents` });
    const nodes = data?.jcr?.nodeByPath?.children?.nodes ?? [];
    return <ul>{nodes.map((n: any) => <li key={n.path}>{n.displayName}</li>)}</ul>;
  },
);
```

Use `useGQLQuery` when you need field-level projection, joins across nodes, or complex filtering. Use `useJCRQuery` for simple node listings where you'll call Java methods on the results.

> **Edit mode pattern for interactive components**: Carousels, accordions, tabs, and sliders are hard for editors to work with in their interactive state. In edit mode, render them **flat** (all slides/tabs visible) and optionally show an editor hint:
>
> ```tsx
> ({ slides }: Props, { renderContext }) => {
>   const isEdit = renderContext.isEditMode();
>   return isEdit ? (
>     <div className={classes.editStack}>
>       {/* flat — all children visible for editing */}
>       <RenderChildren />
>       <p className={classes.hint}>🖊 Carousel — add or reorder slides here</p>
>     </div>
>   ) : (
>     <div className={classes.carousel}>
>       <RenderChildren />
>     </div>
>   );
> }
> ```

### `readOnly` prop for shared/structural nodes

Use `readOnly` when rendering a node that editors should not edit in-place (e.g. a shared footer, a system-level navigation area):

```tsx
<RenderChild name="footer" readOnly={true} />
```

For `AbsoluteArea`, use `readOnly="children"` to allow editing only from the owning page:

```tsx
// Fully read-only — editors cannot edit the footer from any page
<AbsoluteArea name="footer" parent={renderContext.getSite()} readOnly={true} />

// Read-only everywhere EXCEPT the designated "footer management" page
<AbsoluteArea name="footer" parent={renderContext.getSite()} readOnly="children" />
```

`readOnly="children"` is the recommended pattern: the footer is manageable from one page, but other page templates just include it without showing edit handles.

---

## Step 4 — Add CSS with CSS Modules

Create a `component.module.css` file in the same folder:

```css
.root {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 2rem;
}
```

Import and use in the view:

```tsx
import classes from "./component.module.css";

<section className={classes.root}>
```

Combine multiple classes:

```tsx
<section className={[classes.root, classes.small].join(" ")}>
```

### ⚠️ CSS grid: `auto-fit` vs `auto-fill`

When using `repeat(auto-fill, ...)`, CSS creates **phantom empty tracks** for remaining grid columns, leaving gaps when there are fewer items than columns. Use **`auto-fit`** instead — it collapses empty tracks so items stretch to fill the row:

```css
/* ❌ auto-fill — leaves gaps when items don't fill the row */
grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));

/* ✅ auto-fit — items stretch to fill the full row */
grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
```

### ⚠️ Full-card clickability

When only the title of a card is a link, make the entire card clickable using the CSS stretched-link technique:

```tsx
// In the card view
<article className={classes.card}>
  <h3 className={classes.cardTitle}>
    <a href={buildNodeUrl(currentNode)} className={classes.cardLink}>
      {title}
    </a>
  </h3>
  <p>{description}</p>
</article>
```

```css
/* In component.module.css */
.card {
  position: relative;  /* ← required for stretch to work */
}

.cardLink::after {
  content: "";
  position: absolute;
  inset: 0;  /* stretches to cover the entire card */
}
```

The `::after` pseudo-element on the link covers the entire `position: relative` card, making every pixel clickable while keeping the link semantically on the title.

---

## Step 5 — Creating a named (non-default) view

To create a second view (e.g. a compact version), create a new file `small.server.tsx` and add `name: "small"` to the `jahiaComponent` call:

```tsx
jahiaComponent(
  {
    componentType: "view",
    nodeType: "namespace:typeName",
    displayName: "Small View",
    name: "small",      // ← this registers a named view
  },
  ({ title }: Props) => <span className={classes.small}>{title}</span>,
);
```

Request a named view from a parent component with `<RenderChild name="child" view="small" />`.

---

## Step 5b — Creating a client-side interactive component (Island Architecture)

Jahia uses the **Island Architecture**: server components render static HTML; interactive islands are hydrated in the browser. Use this when you need React state, browser events, or browser-only APIs.

### When to use client vs server rendering

| Use `.server.tsx` for… | Use `.client.tsx` for… |
|---|---|
| Static HTML, CMS content, navigation | Buttons, toggles, counters, forms |
| Reading JCR/GQL data | `useState`, `useEffect`, browser events |
| SEO-important content | Animations, browser-only libraries |

### Step 1 — Create the client component

Create `MyComponent.client.tsx` **in the same folder** as the server view. This is a plain React component — no `jahiaComponent` call needed:

```tsx
// src/components/Counter/Counter.client.tsx
import { useState } from "react";
import classes from "./component.module.css";

interface Props {
  label: string;         // only serializable types allowed as Island props
  initialCount?: number;
}

export default function Counter({ label, initialCount = 0 }: Props) {
  const [count, setCount] = useState(initialCount);
  return (
    <div className={classes.counter}>
      <button type="button" onClick={() => setCount(c => c - 1)}>−</button>
      <span>{label}: {count}</span>
      <button type="button" onClick={() => setCount(c => c + 1)}>+</button>
    </div>
  );
}
```

> ⚠️ **Only the default export** of a `.client.tsx` file can be used as an island component. Named exports are bundled for the browser but cannot be registered as islands.

> ⚠️ **Props must be serializable**: only strings, numbers, booleans, plain objects, and arrays. You cannot pass `JCRNodeWrapper`, `renderContext`, or Java objects to a client component.

### Step 2 — Wrap it with `<Island>` in the server view

```tsx
// src/components/Counter/default.server.tsx
import { jahiaComponent, Island } from "@jahia/javascript-modules-library";
import Counter from "./Counter.client.jsx";     // .jsx at import time
import type { Props } from "./types.js";

jahiaComponent(
  { componentType: "view", nodeType: "namespace:counter" },
  ({ label, initialCount }: Props) => (
    <div>
      <Island component={Counter} props={{ label, initialCount }} />
    </div>
  ),
);
```

The `Island` component handles SSR + hydration automatically. The server view fetches the content from JCR; only serializable values flow into the client island.

### Step 3 — Browser-only rendering (skip SSR)

If the component cannot run on the server (e.g. uses `window`, `document`, or a browser-only library), use `clientOnly`:

```tsx
<Island component={MapWidget} props={{ lat, lng }} clientOnly>
  <p>Loading map…</p>   {/* shown until the component hydrates */}
</Island>
```

### Step 3b — Passing children to an island (accordion pattern)

In default mode (without `clientOnly`), children passed to `<Island>` are rendered on the server and inserted as static children of the island component. Use this for accordion or collapsible containers where the shell is interactive but the content is static:

```tsx
// Accordion.client.tsx
import type { ReactNode } from "react";
import { useState } from "react";

export default function Accordion({ children }: { children: ReactNode }) {
  const [isOpen, setIsOpen] = useState(false);
  return (
    <div>
      <button type="button" onClick={() => setIsOpen(o => !o)}>
        {isOpen ? "Close" : "Open"}
      </button>
      <div style={{ display: isOpen ? "block" : "none" }}>
        {children}
      </div>
    </div>
  );
}
```

```tsx
// default.server.tsx
<Island component={Accordion}>
  <p>Server-rendered static content</p>
</Island>
```

> ⚠️ The `{children}` insertion point must always be present in the client component. If you want to hide children, use CSS — a JS condition will cause them to be omitted from the page entirely.

> ⚠️ Children are wrapped in a `<jsm-children>` custom element. Avoid using the CSS `>` child combinator to target island children. Also do not target `jsm-island` or `jsm-children` in CSS — they are implementation details and may change.

In `clientOnly` mode, children act as a **loading placeholder** shown until the island hydrates (see Step 3 above).

### Step 4 — Dynamic import for heavy/browser-only libraries

For large libraries, import them dynamically inside `useEffect` to avoid SSR issues and reduce bundle size:

```tsx
// Counter.client.tsx
import { useEffect, useState } from "react";

export default function Confetti() {
  const [fire, setFire] = useState<(() => void) | null>(null);

  useEffect(() => {
    import("canvas-confetti").then(({ default: confetti }) => {
      setFire(() => () => confetti({ origin: { y: 1 } }));
    });
  }, []);

  return <button type="button" onClick={() => fire?.()} disabled={!fire}>🎉</button>;
}
```

### Edit mode caveat

Client components are hydrated even in Page Builder edit mode. If the interactive behaviour is disruptive in edit mode (e.g. a slider that auto-advances), guard it:

```tsx
// Pass isEditMode from the server view as a prop
<Island component={Slider} props={{ slides, isEditMode: renderContext.isEditMode() }} />
```

Then in the client component, skip the interactive behaviour when `isEditMode` is true.

---

## Step 5c — Add front-end UI labels (locales)

Any string that appears in the rendered HTML and is not a JCR property value must come from `settings/locales/`.
Do not hardcode button text, section headings, alt text templates, error messages, or form labels.

**File location:**
```
settings/locales/en.json   ← required
settings/locales/fr.json   ← required minimum
```

These files are auto-discovered by `@jahia/vite-plugin` — no registration needed.

**Usage in views:**

```tsx
import { useTranslation } from "react-i18next";

// Works in both .server.tsx and .client.tsx
const { t } = useTranslation();

// Simple
<button>{t("hero.cta.label")}</button>

// With interpolation
<img alt={t("alt.hero", { title })} />
```

**Add to both `en.json` and `fr.json` for every new string:**

```json
{
    "hero": {
        "cta": {
            "label": "Discover more"
        }
    },
    "alt": {
        "hero": "Hero image for {{title}}"
    }
}
```

**Best practices:**
- Use random/opaque keys (e.g. `"r3k2"`) or scoped semantic keys (e.g. `"hero.cta.label"`) — never bare English words as keys (`"read-more"`) which creates ambiguity across contexts and forces renaming.
- Never concatenate: always use interpolation (`{{author}}`) for dynamic data.
- For HTML inside translations, use the `<Trans>` component instead of `t()`:

```tsx
import { Trans } from "react-i18next";
// key value: "Written by <a>{{author}}</a>"
<Trans i18nKey="article.byline" values={{ author }} components={{ a: <a href={authorUrl} /> }} />
```

**IDE integration:** `npm init @jahia/module@latest` automatically configures the [i18n ally](https://github.com/lokalise/i18n-ally#readme) VS Code extension. When installed it shows translation values inline in the code, lets you edit them without opening JSON files, and provides an `Extract text into i18n messages` command that replaces a hardcoded string with a `t("...")` call. Install the recommended extensions in `.vscode/extensions.json` to get it.

> Front-end UI labels (`locales/*.json`) are separate from CND editor labels (`settings/resources/*.properties`). Both are required — locales for rendered UI strings, properties for the Jahia content editor.

---

## Step 5d — Language switcher

Use the following utilities from `@jahia/javascript-modules-library` to build a server-rendered language switcher:

```tsx
import { getSiteLocales, buildNodeUrl, jahiaComponent } from "@jahia/javascript-modules-library";

jahiaComponent(
  { componentType: "view", nodeType: "ns:languageSwitcher" },
  (_, { renderContext, currentNode }) => {
    const locales = getSiteLocales(renderContext.getSite());
    const invalidLanguages: string[] = currentNode.getPropertyAsString("j:invalidLanguages")?.split(" ") ?? [];

    return (
      <ul>
        {locales
          .filter(locale => !invalidLanguages.includes(locale))
          .filter(locale => currentNode.hasI18N(renderContext.getSite().getLocale(locale)))
          .map(locale => (
            <li key={locale}>
              <a href={buildNodeUrl(currentNode, { language: locale })}>{locale.toUpperCase()}</a>
            </li>
          ))}
      </ul>
    );
  },
);
```

`j:invalidLanguages` is a system property Jahia sets on nodes that haven't been translated to a given language. Filtering it out prevents dead links to untranslated pages. `node.hasI18N(locale)` provides an additional check — it returns false for nodes that have no translated properties at all for the given locale, catching cases `j:invalidLanguages` may not cover.

---

## Step 6 — Push to Jahia

Build and deploy the module to push all changes (existing or new files):

```bash
# Always use this — never use yarn dev from an agent (it's interactive-only)
yarn build && yarn jahia-deploy
```

---

## Validation checklist
- [ ] `jahiaComponent` registered with correct `nodeType` (matches CND)
- [ ] `Props` imported from `./types.js`
- [ ] `buildNodeUrl` used for any image or node URL
- [ ] Weakreference-backed content rendered via sub-view (`RenderChild`), not inline property access
- [ ] Interactive UI (carousels, tabs) flattened in edit mode with editor hints
- [ ] Structural/shared nodes rendered with `readOnly` prop
- [ ] Semantic HTML used (`<article>`, `<section>`, `<nav>`, `<header>`, `<footer>`)
- [ ] Images have meaningful `alt` text (not empty `alt=""` unless decorative) — use `t("alt.key", {...})` for translated alt text
- [ ] No hardcoded UI strings — all button labels, headings, messages use `t("key")` from `settings/locales/`
- [ ] `settings/locales/en.json` and `fr.json` both updated with any new keys
- [ ] CSS Module created and imported
- [ ] **If client-side**: component is in `.client.tsx`, wrapped with `<Island>` in the server view
- [ ] **If client-side**: all props passed to Island are serializable (no JCR objects)
- [ ] **If client-side**: browser-only libraries use dynamic `import()` inside `useEffect`
- [ ] `yarn build && yarn jahia-deploy` run after all changes
- [ ] Component renders without errors in Page Builder

## Troubleshooting
> https://academy.jahia.com/tutorials-get-started/front-end-developer/making-a-hero-section

### JSX vs HTML attribute differences

| Feature | HTML | JSX |
|---|---|---|
| CSS class | `class="..."` | `className="..."` |
| Inline style | `style="color:red"` | `style={{ color: 'red' }}` |
| Event handler | `onclick="fn()"` | `onClick={fn}` |
| Comments | `<!-- -->` | `{/* */}` |
| Boolean attributes | `disabled` | `disabled={true}` or just `disabled` |

## References

- JavaScript modules monorepo: https://github.com/Jahia/javascript-modules
- Preparing for i18n: https://academy.jahia.com/documentation/jahia-cms/jahia-8-2/developer/javascript-module-development/preparing-for-internationalization-i18n
