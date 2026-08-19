---
name: jahia-jcr-sql2
description: JCR-SQL2 reference for Jahia queries. Use when building, reviewing, or debugging SQL2 statements for content listings, full-text search, sorting, pagination, or Java back-end query code.
---

# Skill: jahia-jcr-sql2

Use this skill when you need the JCR-SQL2 language itself: selectors, path constraints, filters, ordering, full-text syntax, joins, pagination rules, and performance guardrails.

---

## When to use JCR-SQL2

JCR-SQL2 is the standard Jahia query language for:

- listing pages or content with filtering and sorting
- querying a folder subtree
- searching by property value, date, or reference
- full-text search across indexed content
- back-end Java code using `QueryManagerWrapper`
- template-set listings that use `useJCRQuery` or the Page Builder query component

---

## Basic syntax

### Select by node type

```sql
SELECT * FROM [jnt:page] AS page
SELECT * FROM [jnt:content] AS content
SELECT * FROM [jnt:file] AS file
```

The selector matches the named type and its subtypes.

### Common node types

| Type | Meaning |
|------|---------|
| `jnt:page` | pages |
| `jnt:content` | editorial content |
| `jnt:file` | files |
| `jnt:virtualsite` | sites |
| `jmix:searchable` | general searchable content |
| `nt:base` | all nodes — avoid unless paired with a strict path |

---

## Path constraints

### Recursive subtree

```sql
SELECT * FROM [jnt:page] AS page
WHERE ISDESCENDANTNODE(page, '/sites/luxe/home')
```

### Direct children only

```sql
SELECT * FROM [jnt:page] AS page
WHERE ISCHILDNODE(page, '/sites/luxe/home')
```

**Guardrail:** always constrain by path to avoid repository-wide scans.

---

## Property constraints

### Exact match

```sql
WHERE page.[j:templateName] = 'home'
WHERE node.[jcr:title] = 'My Title'
```

### Pattern match

```sql
WHERE node.[jcr:title] LIKE '%keyword%'
WHERE node.[j:nodename] LIKE '%.png'
```

### Null checks

```sql
WHERE page.[jcr:title] IS NOT NULL
```

### Boolean

```sql
WHERE node.[j:published] = CAST('true' AS BOOLEAN)
```

### Date comparison

```sql
WHERE page.[jcr:lastModified] > CAST('2026-01-01T00:00:00.000Z' AS DATE)
```

Use the millisecond form `yyyy-MM-dd'T'HH:mm:ss.SSSX` for SQL2 date casts.

### Multiple conditions

```sql
WHERE ISDESCENDANTNODE(page, '/sites/luxe')
  AND page.[jcr:lastModified] > CAST('2026-01-01T00:00:00.000Z' AS DATE)
```

### OR conditions

```sql
WHERE node.[jcr:primaryType] = 'jnt:bigText'
   OR node.[jcr:primaryType] = 'jnt:article'
```

---

## Ordering

```sql
ORDER BY page.[jcr:lastModified] DESC
ORDER BY page.[jcr:created] ASC
ORDER BY node.[jcr:title]
```

Multiple columns:

```sql
ORDER BY page.[j:templateName] ASC, page.[jcr:lastModified] DESC
```

---

## Full-text search

### Search indexed content

```sql
WHERE CONTAINS(node.*, 'digital')
```

### Search one property

```sql
WHERE CONTAINS(node.[jcr:title], 'welcome')
```

### Expression syntax

| Syntax | Meaning |
|--------|---------|
| `term` | must contain the term |
| `term1 term2` | implicit AND |
| `term1 OR term2` | either term |
| `"exact phrase"` | exact phrase |
| `-term` | exclude term |

### Relevance sort

```sql
SELECT * FROM [jnt:content] AS n
WHERE ISDESCENDANTNODE(n, '/sites/luxe')
  AND CONTAINS(n.*, 'digital')
ORDER BY SCORE(n) DESC
```

Combine full-text with path constraints for performance.

---

## Joins

```sql
SELECT * FROM [jnt:imageReferenceLink] AS img
INNER JOIN [jnt:file] AS file
ON img.[j:node] = file.[jcr:uuid]
WHERE img.[j:node] = 'UUID'
```

Jahia supports inner joins, but keep them focused and path-constrained whenever possible.

---

## Using SQL2 in Jahia code

### Template-set listing with `useJCRQuery`

```tsx
const posts = useJCRQuery({
  query: `SELECT * FROM [namespace:blogPost] AS post
          WHERE ISDESCENDANTNODE(post, '/sites/${siteKey}/contents/blog')
          ORDER BY post.[publicationDate] DESC`,
});
```

### Java back-end query execution

```java
QueryManagerWrapper qm = session.getWorkspace().getQueryManager();
QueryWrapper query = qm.createQuery(sql2Statement, Query.JCR_SQL2);
query.setLimit(limit);
query.setOffset(offset);
JCRNodeIteratorWrapper nodes = query.execute().getNodes();
```

**Guardrail:** never embed `LIMIT` or `OFFSET` inside the SQL2 string. Use `setLimit()` and `setOffset()`.

---

## Security and validation

### Escape user input

In Java back-end code, escape user-provided values with `JCRContentUtils.sqlEncode()` before interpolating them into a SQL2 string.

```java
String safeValue = JCRContentUtils.sqlEncode(userInput);
```

### Validate dynamic sort fields

If a user can choose the sort field, validate it against a whitelist before interpolating it into `ORDER BY`.

---

## Performance best practices

1. Always constrain by path.
2. Use the most specific node type possible.
3. Keep result sets small.
4. Prefer indexed equality filters over broad `LIKE '%...%'` patterns.
5. Use full-text sparingly on large trees.
6. Sort on common indexed fields such as `jcr:lastModified` or `jcr:created`.
7. Cap API result limits to a sane maximum.

---

## Quick checklist

- [ ] Query has a path constraint
- [ ] Node type is specific
- [ ] Sort field is intentional and safe
- [ ] Full-text is combined with a subtree path
- [ ] Dates use `yyyy-MM-dd'T'HH:mm:ss.SSSX`
- [ ] Java code uses `setLimit()` and `setOffset()` instead of inline SQL clauses

---

## Related skills

- `/jahia-dev-query-content` — apply SQL2 inside Page Builder queries and JS module views
- `/jahia-cnd-author` — define the content types you will query

