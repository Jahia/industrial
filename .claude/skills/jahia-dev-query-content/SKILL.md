---
name: jahia-dev-query-content
description: Designs JCR-SQL2 content queries for Jahia page-builder listings and JS module views. Use when asked to list content from folders, filter items, sort results, or wire `useJCRQuery` into a template-set component.
---

# Skill: jahia-dev-query-content

Use this skill when building content listings in Jahia template sets.
For pure JCR-SQL2 language rules, full-text syntax, joins, pagination, and performance guardrails, also use `/jahia-jcr-sql2`.

---

## Overview

Jahia stores editorial content in the JCR. In template sets, you usually query it in one of three ways:

1. **Page Builder query component** — no-code listing using a JCR query string
2. **Server-side view** — `useJCRQuery` inside a `.server.tsx` component
3. **Client-driven experience** — use a dedicated API strategy only when a server-side query is not enough

---

## Step 1 — Understand where content lives

Reusable content usually lives under `/sites/<siteKey>/contents/...` instead of directly under pages.
Create and manage those folders in jContent.

If editors need the folder visible in the Page Builder content tree, add `jmix:visibleInContentTree` to the folder type:

```cnd
[namespace:blogFolder] > jnt:contentFolder, jmix:visibleInContentTree
```

---

## Step 2 — Start with the right SQL2 shape

### List all items of a type under a folder

```sql
SELECT *
FROM [namespace:typeName] AS item
WHERE ISDESCENDANTNODE(item, '/sites/<siteKey>/contents/<folderName>')
```

### Only direct children of a folder

```sql
SELECT *
FROM [namespace:blogPost] AS post
WHERE ISCHILDNODE(post, '/sites/<siteKey>/contents/blog')
```

### Filter drafts and sort newest first

```sql
SELECT *
FROM [namespace:blogPost] AS post
WHERE ISDESCENDANTNODE(post, '/sites/<siteKey>/contents/blog')
  AND post.[publicationDate] IS NOT NULL
ORDER BY post.[publicationDate] DESC
```

---

## Step 3 — Use the right SQL2 clauses

| Need | Pattern |
|------|---------|
| Recursive subtree | `ISDESCENDANTNODE(alias, '/path')` |
| Direct children only | `ISCHILDNODE(alias, '/path')` |
| Property equality | `alias.[prop] = 'value'` |
| Pattern match | `alias.[prop] LIKE '%keyword%'` |
| Exclude empty values | `alias.[prop] IS NOT NULL` |
| Sort | `ORDER BY alias.[prop] DESC` |
| Full-text | `CONTAINS(alias.*, 'term')` |
| Relevance sort | `ORDER BY SCORE(alias) DESC` |

**Performance rule:** always constrain queries by path.

---

## Step 4 — Add full-text and filtering when needed

### Phrase search sorted by relevance

```sql
SELECT *
FROM [namespace:blogPost] AS post
WHERE ISDESCENDANTNODE(post, '/sites/<siteKey>/contents/blog')
  AND CONTAINS(post.*, '"annual report"')
ORDER BY SCORE(post) DESC
```

### Search one property only

```sql
SELECT *
FROM [namespace:blogPost] AS post
WHERE ISDESCENDANTNODE(post, '/sites/<siteKey>/contents/blog')
  AND CONTAINS(post.[jcr:title], 'welcome')
ORDER BY post.[publicationDate] DESC
```

### Filter by date

```sql
SELECT *
FROM [namespace:blogPost] AS post
WHERE ISDESCENDANTNODE(post, '/sites/<siteKey>/contents/blog')
  AND post.[publicationDate] > CAST('2026-01-01T00:00:00.000Z' AS DATE)
ORDER BY post.[publicationDate] DESC
```

Use the millisecond form `yyyy-MM-dd'T'HH:mm:ss.SSSX` for SQL2 date casts.

---

## Step 5 — Use queries in Jahia UI or code

### Page Builder query component

For a simple listing, use **Jahia - Queries > Content items using JCR Query** and paste the SQL2 query there.

### `useJCRQuery` in a `.server.tsx` view

```tsx
import { jahiaComponent, useJCRQuery, Render } from '@jahia/javascript-modules-library';
import type { JCRNodeWrapper } from 'org.jahia.services.content';

jahiaComponent(
  { componentType: 'view', nodeType: 'namespace:blogListing' },
  (_, { renderContext }) => {
    const siteKey = renderContext.getSite().getName();
    const posts = useJCRQuery({
      query: `SELECT * FROM [namespace:blogPost] AS post
              WHERE ISDESCENDANTNODE(post, '/sites/${siteKey}/contents/blog')
                AND post.[publicationDate] IS NOT NULL
              ORDER BY post.[publicationDate] DESC`,
    });

    return (
      <section>
        {posts.map((post: JCRNodeWrapper) => (
          <Render key={post.getPath()} node={post} />
        ))}
      </section>
    );
  },
);
```

---

## Step 6 — Patterns commonly needed in template sets

### Make a content type renderable at its own URL

Use `jmix:mainResource` only for content that needs both a listing card and a full detail page.

```cnd
[namespace:blogPost] > jnt:content, mix:title, jmix:mainResource, namespacemix:component
```

Then add a `fullPage.server.tsx` view and link to the node with `buildNodeUrl(currentNode)`.

### Draft gate with `publicationDate`

A common pattern is:

```cnd
- publicationDate (date)
```

and the query:

```sql
AND post.[publicationDate] IS NOT NULL
ORDER BY post.[publicationDate] DESC
```

### Nested content folders

Use `ISDESCENDANTNODE` to cover nested folder trees automatically. Switch to `ISCHILDNODE` only when you intentionally want one level.

---

## Query checklist

- [ ] Query is constrained to `/sites/<siteKey>/contents/...` or another specific subtree
- [ ] Node type is specific, not overly broad
- [ ] Sort order matches the UX need
- [ ] Draft or publish filtering is explicit
- [ ] Detail-page types use `jmix:mainResource` only when needed
- [ ] The query has been validated against `/jahia-jcr-sql2` guardrails

---

## Related skills

- `/jahia-jcr-sql2` — SQL2 syntax, full-text, joins, pagination, and performance
- `/jahia-dev-build-component` — build the listing component that renders query results
- `/jahia-cnd-author` — create the queried content type and folder types

