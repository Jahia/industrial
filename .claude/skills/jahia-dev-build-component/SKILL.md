---
name: jahia-dev-build-component
description: Builds a complete Jahia component (content type + view + CSS) from a description. Meta-skill that orchestrates jahia-cnd-author and jahia-dev-create-view. Use when asked to build a new UI component or section.
---

## Overview

This meta-skill builds a complete **Single Directory Component (SDC)** — the standard Jahia component pattern — by sequencing two atomic skills:

1. `jahia-cnd-author` → create the CND definition and `types.ts`
2. `jahia-dev-create-view` → implement the React view and CSS Module

Run these steps in order. Do not skip to the view before the content type is defined.

**Scale of thumbs**: a well-scoped module has 1–4 page templates, 5–10 content types, 2–5 mixins, 1–4 views per type. If a request exceeds this, split it into multiple work sessions.

---

## Step 0 — Optional: capture reference screenshot (interactive sessions only)

If the user provides a reference URL (or mentions a site to model after), invoke `/jahia-dev-screenshot` **before writing any code** to capture the visual spec.

> Skip this step in automated / autopilot contexts — screenshot comparison requires human review and adds significant time.

---

## Step 1 — Write the content spec

Before writing any code, draft this spec internally. In an interactive session, confirm with the user; in autopilot mode, proceed with your best judgement and document what you chose:

```
Name: <ComponentName>
Description: <What is this for? What does an editor fill in?>
Fields:
  - fieldName: type / i18n? / mandatory?
  (repeat for each field)
Views:
  - default: <describe layout>
  - small (optional): <compact variant>
Used where: <Area on page / nested in <Parent> / listing item>
Has children: <yes: ChildType / no>
```

---

## Step 2 — REQUIRED: Invoke `@jahia-cnd-author`

**Do not write CND manually.** Jahia-specific patterns (`choicelist[linkTypeInitializer]`, `mix:title`, child nodes for CTAs) are not in LLM training data — writing from memory produces broken output.

Invoke `@jahia-cnd-author` as a sub-agent with the complete spec:

```
Component: <PascalCase name>
Namespace prefix: <ns>
Module path: <absolute path to module root>
Fields:
  - <fieldName>: <type description> [mandatory] [i18n] [multiple]
Children: <repeatable sub-items, e.g. "CTA buttons with label + link">
Usage: <where this component appears, e.g. "dropped in page areas">
```

Wait for **PASS** before continuing. If it returns **FAIL**, send the issues back to `@jahia-cnd-author` to fix.

---

## Step 3 — Invoke `jahia-dev-create-view`

Use the instructions from the `jahia-dev-create-view` skill to:

1. Create `src/components/<Category>/<Name>/default.server.tsx`
2. Create `src/components/<Category>/<Name>/component.module.css`
3. Import `Props` from `./types.js`
4. Use `buildNodeUrl`, `RenderChildren`, `RenderChild` as needed
5. Run `yarn build && yarn jahia-deploy` to push all changes

---

## Step 4 — Validate

1. In Jahia Page Builder, click **New content** and select the new type
2. Fill in the content form and click **Save**
3. Verify the component renders correctly on the page
4. Check for the error `No rendering set for node: <type>` — if seen, re-run `yarn build && yarn jahia-deploy`

---

## SDC structure summary

After following this skill, the component should look like:

```
src/components/<Category>/<Name>/
├── definition.cnd        # Content type definition
├── types.ts              # TypeScript Props interface
├── default.server.tsx    # Default React view
└── component.module.css  # CSS Module styles
```

Optional additions:
- `small.server.tsx` — named view (compact/alternate rendering)
- `<name>.client.tsx` — client-side interactive component

---

## Nested components

If the component has child nodes (e.g. a hero with CTA buttons), repeat Steps 2–4 for each child type, then:

1. Add `+ * (namespace:childType)` to the parent's `definition.cnd`
2. Add `<RenderChildren />` to the parent's view where children should appear

---

## Troubleshooting
> https://academy.jahia.com/tutorials-get-started/front-end-developer/making-a-hero-section

## References

- Preparing for i18n: https://academy.jahia.com/documentation/jahia-cms/jahia-8-2/developer/javascript-module-development/preparing-for-internationalization-i18n

---

## Validation checklist
- [ ] Spec written before any code
- [ ] Component count within scale of thumbs (1–4 templates, 5–10 types, 2–5 mixins, 1–4 views/type)
- [ ] `definition.cnd` created with correct namespace and mixins
- [ ] `types.ts` reflects all CND properties
- [ ] `default.server.tsx` renders without errors
- [ ] Views handle null/missing fields gracefully (mandatory does not guarantee a value at runtime)
- [ ] `component.module.css` applied and visible
- [ ] Semantic HTML used: correct heading level, `alt` text on images, sufficient colour contrast
- [ ] Component appears in Page Builder content picker
- [ ] Content can be created and renders on the page
