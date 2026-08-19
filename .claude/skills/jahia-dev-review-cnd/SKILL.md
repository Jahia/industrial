---
name: jahia-dev-review-cnd
description: Use after writing any CND file to validate it against Jahia best practices. Runs the deterministic cnd-checker script and reports PASS / FAIL with file:line citations and fixes. Run /jahia-dev-review-cnd <path> to check a specific file or directory, or without arguments to check all CND files in the current module.
allowed-tools: Bash
---

## Step 1 — Run the checker

```bash
CND_SCRIPT=$(find .claude .agents -name "check-cnd.mjs" 2>/dev/null | head -1)
node "$CND_SCRIPT" <path-to-file-or-directory>
# or, to check all CND files in the module:
node "$CND_SCRIPT" src/
```

The script exits with code 0 for PASS and code 1 for FAIL.

## Step 2 — Fix and repeat until clean

This is a loop. Run the checker, fix every issue reported, run it again. Repeat until the result is `PASS`.

- **FAIL** — fix every issue, re-run. Do not proceed until exit code is 0.
- **PASS** — clean. Continue.

---

## Antipattern reference

The checker enforces these patterns. Use this as a guide when interpreting output or fixing issues manually.

### `rawStringLink`
Property whose name contains `link`, `url`, `href`, or `path` declared as `(string)`.
**Fix**: Use the link picker:
```cnd
- j:linkType (string, choicelist[linkTypeInitializer]) mandatory
```

### `singleHardcodedCta`
A type with both a CTA label (`ctaText`, `ctaLabel`, `buttonText`, `buttonLabel`) and a CTA link (`ctaLink`, `ctaUrl`, `ctaHref`, `buttonLink`) as flat properties, with no child node.
**Fix**: Replace with a child node:
```cnd
+ * (ns:cta)

[ns:cta] > jnt:content, nsmix:component
 - label (string) i18n mandatory
 - j:linkType (string, choicelist[linkTypeInitializer]) mandatory
```

### `directDroppable`
A concrete type extending `jmix:droppableContent` directly.
**Fix**: Extend the module mixin: `[ns:hero] > jnt:content, nsmix:component`

### `missingRatingConstraint`
`rating (long)` without a range constraint — unconstrained ratings cause data integrity issues.
**Fix**: Add `< "[1,5]"`

### `redundantImageAlt`
`imageAlt (string)` alongside an image weakreference. The image node already has `jcr:title`.
**Fix**: Remove `imageAlt`. In the view: `image.getPropertyAsString("jcr:title") ?? ""`

### `rawTitleProp`
Property named `title`, `heroTitle`, `pageTitle`, or `sectionTitle` typed as `(string)`.
**Fix**: Remove it, extend `mix:title`. Access as `props["jcr:title"]`.

### `weakrefNoConstraint`
`(weakreference)` with no `< ` type constraint.
**Fix**: Add constraint — `< jmix:image` for images, `< jnt:file` for files.

### `weakrefWrongConstraint`
`< 'jnt:file'` (quoted form).
**Fix**: `< jmix:image` (unquoted).

### `missingI18n`
User-visible string (`title`, `text`, `label`, `description`, `subtitle`, `caption`, `alt`, `heading`, `summary`, `excerpt`, `body`) without `i18n`.
**Fix**: Add `i18n` after the type declaration.

### `studioOnly`
Any use of `jmix:studioOnly`.
**Fix**: Replace with `jmix:hiddenType`.
