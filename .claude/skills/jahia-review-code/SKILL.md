---
name: jahia-review-code
description: Reviews a Jahia JavaScript module for generic and Jahia-specific best practices. Scans CND definitions, TypeScript views, and page templates. Reports issues in order of importance with fix suggestions. Covers 8 critical checks, 9 warnings, and 10 suggestions.
allowed-tools: Bash, Read
---

# Skill: jahia-review-code

Reviews a Jahia JavaScript module for correctness and best practices. Scans real files, reports issues in order of severity (🔴 Critical → 🟡 Warning → 🔵 Suggestion), and proposes fixes.

---

## Step 1 — Locate the module

Find the module root: look for `package.json` with `@jahia/javascript-modules-library`. Determine the `src/` directory.

```bash
find . -name "package.json" -not -path "*/node_modules/*" | xargs grep -l "javascript-modules-library" 2>/dev/null | head -1
```

---

## Step 2 — Collect files to review

```bash
find src/ -name "definition.cnd" | sort
find src/ -name "*.server.tsx" | sort
find src/ -name "*.client.tsx" | sort
find src/ -name "types.ts" | sort
find src/templates/ -name "*.server.tsx" | sort
cat settings/definitions.cnd
```

Read ALL collected files before starting the review.

---

## Step 3 — Run checks in order of severity

### 🔴 CRITICAL — Will cause broken editor UX, broken pages, or security issues

**C1 — `jmix:droppableContent` used directly**
Check: any CND type (not mixin declarations in settings/definitions.cnd) extending `jmix:droppableContent` directly.
Fix: extend the module's custom component mixin (e.g. `namespacemix:component`) instead.

**C2 — `fullPage` view uses `componentType: "template"`**
Check: any `name: "fullPage"` view that also has `componentType: "template"`.
Fix: change to `componentType: "view"`. The `src/templates/MainResource/default.server.tsx` template already routes `jmix:mainResource` nodes to the `fullPage` view.

**C3 — `j:linknode` or `j:url` explicitly declared in CND**
Check: any CND type that explicitly declares `j:linknode` or `j:url` fields alongside `choicelist[linkTypeInitializer]`.
Fix: remove those two fields from the CND. They are injected automatically by Jahia's mixins at runtime. Only declare `- j:linkType (string, choicelist[linkTypeInitializer])`. The fields remain available in `types.ts` and in the view.

**C4 — `j:linkType` used as a URL in a view**
Check: any `.server.tsx` or `.client.tsx` file that uses `props["j:linkType"]` or `j:linkType` directly as an `href`.
Fix: use a `switch (props["j:linkType"])` with `buildNodeUrl(props["j:linknode"])` for internal and `props["j:url"]` for external.

**C5 — Weakreference node properties read directly in a view (cache issue)**
Check: views that access `.getPropertyAsString()`, `.getProperty(...)`, or property destructuring from a weakreference prop (other than `buildNodeUrl`).
Fix: render the referenced node via `<Render node={refNode} view="..." />` to get proper cache invalidation.

**C6 — Client component imports server-only APIs**
Check: any `.client.tsx` file that imports from `@jahia/javascript-modules-library` (except `Island` which is re-exported).
Fix: move server-side logic to the `.server.tsx` wrapper and pass results as serializable props to the Island.

**C7 — Cache explicitly disabled (`cache.expiration="0"`)**
Check: any `jahiaComponent` call with `properties: { "cache.expiration": "0" }`.
Fix: never set expiration to 0. If truly fresh data is needed, use a small value like `"5"` (5 seconds) to still protect under load.

**C8 — Generic area type used for every Area**
Check: page templates where every `<Area>` uses the same generic area type (e.g. `nodeType="namespace:pageArea"` everywhere). This means editors see ALL `pageComponent` types as droppable options in every area — a hero section will appear as an option in a feature card grid.
Fix: create **one typed area node per section** in `settings/definitions.cnd`, each with a tight child constraint:
```cnd
[namespace:heroArea] > jnt:content, jmix:list, jmix:hiddenType orderable
 + * (namespace:heroSection)

[namespace:featuresArea] > jnt:content, jmix:list, jmix:hiddenType orderable
 + * (namespace:featureCard)
```
Only use a generic `pageArea` for flexible areas (e.g. footer) where any component is valid.

---

### 🟡 WARNING — Will likely cause editor confusion, stale content, or runtime errors

**W1 — User-facing string fields without `i18n`**
Check: CND string/textarea/richtext properties that don't have `i18n` (exclude system properties like `j:linkType`, `j:url`, non-user-facing fields).
Fix: add `i18n` to all user-visible text properties.

**W2 — `jmix:mainResource` on non-content types**
Check: CND types that have `jmix:mainResource` but no richtext body or no obvious "detail page" use case (e.g. a visual composition type like a card or hero).
Fix: only use `jmix:mainResource` for content that genuinely needs both a listing card AND a full-page detail view.

**W3 — Structural container types missing `jmix:hiddenType`**
Check: CND types that have no `namespacemix:component` mixin (so they can't be dropped as components) but also don't have `jmix:hiddenType` — editors would never see them but they don't show up with a clear "hidden" intent.
Fix: add `jmix:hiddenType` to structural/container types. Do NOT use `jmix:studioOnly` — it can interfere with area rendering.

**W4 — Props not typed as optional (`?:`) / not guarded in views**
Check: (a) `types.ts` props typed as required (`title: string`) — all props must use `?:` because Jahia does not guarantee values are present at render time. (b) Views that use props without null/undefined guards, especially `buildNodeUrl(prop)` — passing `undefined` throws `"Expected a node in buildNodeUrl, received undefined"`.
Fix: use `?:` for all props in `types.ts`. Add conditional rendering (`{prop && <span>{prop}</span>}`) and guard node URLs (`prop ? { backgroundImage: \`url(${buildNodeUrl(prop)})\` } : undefined`).

**W5 — `weakreference multiple` not null-filtered before `.map()`**
Check: views mapping over a `weakreference multiple` prop without `.filter(x => x !== null)`.
Fix: `items?.filter(item => item !== null).map(...)`.

**W6 — Cache not configured for views using external/dynamic data**
Check: views that call external functions, use `Date.now()`, or fetch data, without `properties: { "cache.expiration": "..." }`.
Fix: add `cache.expiration` to the `jahiaComponent` properties.

**W7 — Missing `import.xml` or no homepage defined**
Check: look for `import.xml` at the module root. If absent or if it doesn't contain `j:isHomePage="true"`, editors won't have a default homepage.
Fix: add an `import.xml` with a homepage node (`j:isHomePage="true"`). Also add "Offline pages/Models", "Offline pages/Drafts", "Offline pages/Archive" folders with `jmix:systemNameReadonly` and `jmix:nolive` mixins. Add content folders with `jmix:contributeMode` restrictions where appropriate.

**W8 — Node type extends something other than `jnt:content`**
Check: CND types that extend anything other than `jnt:content`, `jnt:page`, `jmix:*`, or standard Jahia base types.
Fix: extend only `jnt:content` (or `jnt:page` for page types). To add fields to a type you don't control, use a mixin with `extends=<targetType>`. Unusual inheritance chains break edition interfaces in unpredictable ways.

**W9 — Hardcoded link URLs in views**
Check: any `.server.tsx`, `.client.tsx`, or template file containing a literal `href="http`, `href="/"`, or `href="/en/` (except in edit-mode chrome helpers). Also flag plain string `src="http` for non-bundled assets. Also flag any content data with `j:linkType: "external"` pointing to a path that looks like an internal Jahia URL (e.g. `/sites/`, `/cms/`, `/en/`).
Fix: **All navigable URLs must come from contributed content.** Use `j:linkType`/`j:linknode`/`j:url` props for editorial links, `buildNodeUrl(node)` for JCR node links.
🚫 **NEVER use `j:linkType: "external"` to link to an internal Jahia page** — use `"internal"` + `j:linknode`. An external URL pointing internally breaks on environment changes, language switches, live/preview workspace toggling, and vanity URL rewrites. If no target page exists yet, omit the link; do not substitute an external workaround.

---

### 🔵 SUGGESTION — Quality improvements

**S1 — Non-semantic HTML**
Check: views that use `<div>` where `<article>`, `<section>`, `<nav>`, `<header>`, or `<footer>` would be more appropriate.
Fix: use semantic HTML for better accessibility and SEO.

**S2 — Images without meaningful alt text**
Check: `<img>` tags with `alt=""` or no `alt` attribute (unless there's a comment saying it's decorative).
Fix: add descriptive alt text. Decorative images should have `alt=""` with a comment.

**S3 — Accessibility violations (axe-core audit)**
Check: run `/jahia-dev-accessibility` against all live pages. A clean module has zero `critical` or `serious` violations.
Common issues in Jahia modules:
- `color-contrast`: hardcoded colours with insufficient contrast ratio — check with https://webaim.org/resources/contrastchecker/
- `image-alt`: `<img>` missing a meaningful `alt` prop sourced from CND
- `button-name`: icon-only `<button>` or `<a>` without `aria-label`
- `landmark-one-main`: page template missing a `<main>` wrapper
- `page-has-heading-one`: no `<h1>` rendered on any page
- `heading-order`: skipped heading levels between components (e.g. h1 → h3)
- `html-has-lang`: template not setting `lang` via `useServerContext().currentLanguage`
- `focus-visible` suppressed: global `* { outline: none }` in CSS kills keyboard navigation

Fix: identify each violating component by matching the axe target selector to a `.server.tsx` file, apply the fix, rebuild, and re-run the audit.

**S4 — Types using `any`**
Check: `types.ts` files or view files using TypeScript `any`.
Fix: use `JCRNodeWrapper` for node references, `string` / `number` / `boolean` for primitives.

**S5 — Bare `<Area>` without a `nodeType`**
Check: page templates using `<Area name="..." />` without a `nodeType` prop.
Fix: create a custom area type with `jmix:list`, `jmix:hiddenType`, and `orderable`, and reference it with `nodeType="namespace:areaType"`.

**S6 — `mix:title` inherited but `jcr:title` not in `types.ts`**
Check: CND types that extend `mix:title` but whose `types.ts` doesn't include `"jcr:title": string`.
Fix: add `"jcr:title"?: string` to the Props type.

**S7 — Missing `.properties` file entries or icon for new content types**
Check: for each node type found in `definition.cnd` files, verify that `settings/resources/<module>.properties` has a label (`cndNamespace_typeName=...`) and a corresponding icon exists at `settings/content-types-icons/<cndNamespace>_<typeName>.png`. The prefix must be the CND namespace (e.g. `ns_heroSection.png`), **not** the module name with hyphens (e.g. `my-module_heroSection.png` is wrong — the archetype generates wrong names that must be manually corrected).
Fix: add labels (and optionally `ui.tooltip` for fields) to the properties files. Rename any icons that use the module name with hyphens to use the CND namespace. Create a 32×32 PNG icon (free source: [flaticon.com](https://www.flaticon.com/)). Without these, editors see raw technical names and blank icon squares in the content picker.

**S8 — Hardcoded user-visible strings in views**
Check: `.server.tsx` / `.client.tsx` files with JSX string literals that are not coming from props or i18n functions (e.g. `<p>Learn more</p>`, `<button>Submit</button>`).
Fix: move UI labels to `settings/locales/en.json` and `fr.json` and resolve them with `useTranslation()`. Hardcoded strings break multilingual sites.

**S9 — Content list queries not using `ISDESCENDANTNODE` (non-recursive)**
Check: JCR-SQL2 queries using `jcr:path LIKE '/sites/.../content/%'` or a fixed path to limit results, instead of `ISDESCENDANTNODE(node, '/sites/.../content')`.
Fix: use `ISDESCENDANTNODE` to ensure queries work correctly even if editors reorganize content into sub-folders.

**S10 — No escape hatch when using a custom component mixin**
Check: a custom section type that restricts children to a custom mixin (e.g. `+ * (namespacemix:component)`) but the module provides no "content stack" escape hatch type that itself accepts `jmix:droppableContent`.
Fix: add a `namespace:contentStack > jnt:content, namespacemix:component + * (jmix:droppableContent)` type so power editors can still add arbitrary content when needed.

**S11 — Scaffold/boilerplate components still present**
Check: components under `src/components/Hello/` (or any other archetype-generated boilerplate) that are no longer referenced in `settings/import.xml` and no longer used by any view or page template.
```bash
# Check if Hello components are still referenced anywhere
grep -r "helloWorld\|helloCard\|Hello/" src/templates/ settings/ --include="*.tsx" --include="*.xml" --include="*.cnd"
```
Fix: once `import.xml` no longer provisions Hello World content and no template uses them, delete the entire `src/components/Hello/` directory, remove their entries from `.properties` files, and delete their icons from `settings/content-types-icons/`. Keeping dead components inflates the content picker and confuses editors.

---

## Step 4 — Report results

Format the output as:

```
## Jahia Module Review — <module name>

### 🔴 Critical (N issues)
[C1] src/components/Hero/Section/definition.cnd — `jmix:droppableContent` used directly
     Fix: extend `namespacemix:component` instead

### 🟡 Warnings (N issues)
...

### 🔵 Suggestions (N issues)
...

### ✅ Summary
- N critical issues (must fix before shipping)
- N warnings (fix before sharing with editors)
- N suggestions (improve when time allows)
```

If no issues found in a category, print `✅ None`.

---

## Step 5 — Ask to fix

After the report, ask: **"Would you like me to fix any of these issues?"**

If yes, fix them — use the guidance from the relevant skill (`jahia-cnd-author`, `jahia-dev-create-view`) and run `yarn build && yarn jahia-deploy` to push changes.

---

## References

- Native Jahia mixins & node types: https://github.com/Jahia/jahia/tree/master/war/src/main/webapp/WEB-INF/etc/repository/nodetypes
- Integration best practices: https://github.com/Jahia/gautier-braindump/blob/main/articles/integration-best-practices/README.md
- Developer training: https://github.com/Jahia/developer-training/blob/main/js-training/slides.md

> If a check result is uncertain (e.g. "does this mixin exist?"), fetch the nodetypes directory above before reporting.
