# CND String & Selector Properties

## String type variants

| Type declaration | Editor widget | When to use |
|---|---|---|
| `(string)` | Single-line text input | Short labels, IDs, slugs |
| `(string, textarea)` | Multi-line text area | Paragraphs, descriptions |
| `(string, richtext)` | Rich text editor (TinyMCE) | Body content, formatted text |
| `(string) multiple` | Tag input / list | Lists of plain strings |
| `(string, tag[autocomplete=<n>,separator='<char>']) multiple` | Tag input with autocomplete | Tagging, keywords |
| `(string, color)` | Color picker | Color values |
| `(string, cron)` | Cron expression editor | Scheduling |

## Fixed-choice dropdowns

Use `(string, choicelist)` + `< 'val1', 'val2'` for a dropdown with a hard-coded list.
**Never use `choicelist[val1,val2]`** — the bracket syntax is for initializer keywords, not values.

```cnd
- difficulty (string, choicelist) i18n < 'beginner', 'intermediate', 'advanced'
- variant (string, choicelist) < 'primary', 'secondary', 'ghost'
```

## `choicelist[...]` initializer variants

| Initializer | What it renders |
|---|---|
| `choicelist` | Dropdown from constraints list |
| `choicelist[componentTypes='<types>']` | Component types/mixins dropdown |
| `choicelist[country]` | Countries list (ISO codes, localized labels) |
| `choicelist[menus]` | Site menus |
| `choicelist[nodes='<path>;<type>;<property>']` | Nodes from a JCR path; supports `$currentSiteTemplatesSet` |
| `choicelist[nodetypes='<type>']` | Node types inheriting from `<type>`; special values: `PRIMARY;fromDependencies;useName`, `MIXIN;fromDependencies;useName` |
| `choicelist[permissions]` | Permissions list |
| `choicelist[renderModes]` | Render modes |
| `choicelist[resourceBundle]` | Keys as constraints, labels from resource bundle |
| `choicelist[sortableFieldnames]` | Sortable field names |
| `choicelist[subnodetypes='<type>']` | Similar to nodetypes |
| `choicelist[templates]` | Site templates; variants: `mainresource`, `reference`, `subnodes`, `<type>`, with optional `, dependentProperties='<property>'` |
| `choicelist[templatesNode]` | Node templates; variant: `pageTemplate` |
| `choicelist[workflow]` | Available workflows |
| `choicelist[linkTypeInitializer]` | Internal/external/none link picker (see below) |

## `mix:title` instead of a title string property

**NEVER write `- title (string) i18n mandatory`.**
Extend `mix:title` instead — it adds `jcr:title`, which Jahia's UI, breadcrumbs, and search use natively.

```cnd
// ✅ Correct
[ns:heroSection] > jnt:content, nsmix:component, mix:title

// ❌ Wrong — duplicates what mix:title already provides
[ns:heroSection] > jnt:content, nsmix:component
 - title (string) i18n mandatory
```

Access in the view as `props["jcr:title"]`.

## Link picker — `choicelist[linkTypeInitializer]`

**NEVER use `(string)` for a link, URL, href, or path.**
Use `choicelist[linkTypeInitializer]` — it renders an internal/external/none picker in the editor.

**Declare ONLY `j:linkType` in the CND. Do NOT add `j:linknode` or `j:url` — Jahia injects them automatically.**

```cnd
// ✅ Correct — bare minimum
[ns:callToAction] > jnt:content, nsmix:component
 - label (string) i18n mandatory
 - j:linkType (string, choicelist[linkTypeInitializer]) mandatory

// ❌ Wrong — do not declare companion fields
 - j:linknode (weakreference)   // injected by Jahia — remove this
 - j:url (string)               // injected by Jahia — remove this
```

TypeScript discriminated union for the view:

```ts
import type { JCRNodeWrapper } from "org.jahia.services.content";
export type Props =
  | { label?: string; "j:linkType": "none" }
  | { label?: string; "j:linkType": "internal"; "j:linknode"?: JCRNodeWrapper }
  | { label?: string; "j:linkType": "external"; "j:url"?: string; "j:linkTitle"?: string };
```

In the view, switch on `props["j:linkType"]`.

## Weakreference picker variants

| Initializer | What it picks |
|---|---|
| `picker[type='image']` | Image from media library |
| `picker[type='editoriallink']` | Editorial content node |
| `picker[type='page']` | Page node |
| `picker[type='file']` | Any file asset |

## Regex constraints on strings

```cnd
- contactEmail (string) < '^$|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
- slug (string) < '^[a-z0-9-]+$'
- externalUrl (string) < '^https?://'
```

## Modifiers / keywords

| Keyword | Description |
|---|---|
| `i18n` | Translatable per language — **default to always on user-facing fields** |
| `mandatory` | Required |
| `multiple` | List of values |
| `primary` | Highlighted field in editor (one per type) |
| `autocreated` | Auto-created on node creation; requires `= 'value'` |
| `indexed=no` | Excludes from indexing |
| `nofulltext` | Excludes from full-text search |
| `boost=<float>` | Multiplies full-text search score |
| `facetable` | Enables faceted search on this property |
| `protected` | Cannot be set by external tools |
| `hidden` | Hidden in editor |

## Examples combining selectors and modifiers

```cnd
- tags (string, tag[autocomplete=5,separator=',']) multiple
- color (string, color) = '#000000' autocreated
- template (string, choicelist[templates]) i18n
- nodes (weakreference, choicelist[nodes='/sites/systemsite/categories;jnt:category',sort]) multiple
- image (weakreference, picker[type='image'])
- page (weakreference, picker[type='page'])
```
