# CND Child Nodes

## Syntax

```cnd
+ childName (ns:type)            // named child — exactly one
+ childName (ns:type) multiple   // named child — list
+ * (ns:type)                    // any-name child of a specific type
+ * (jmix:droppableContent)      // open container — any droppable component
```

## When to use child nodes vs `weakreference multiple`

| Use child nodes when… | Use `weakreference multiple` when… |
|---|---|
| Each item has multiple properties (label + link) | Each item is just a reference (a page, an image) |
| Items have no life outside the parent | Items are managed elsewhere and reused |
| You always create them together | Editors need to pick from existing content |

## Repeatable CTA pattern

**NEVER put `ctaText + ctaLink/ctaUrl` on the parent type as flat properties.**
Model CTAs as child nodes — editors can then add multiple CTAs.

```cnd
// ✅ Correct — supports multiple CTAs
[ns:heroSection] > jnt:content, nsmix:component, mix:title
 - subtitle (string, richtext) i18n
 - backgroundImage (weakreference, picker[type='image']) < jmix:image
 + * (ns:heroCallToAction)

[ns:heroCallToAction] > jnt:content, nsmix:component
 - label (string) i18n mandatory
 - j:linkType (string, choicelist[linkTypeInitializer]) mandatory

// ❌ Wrong — forces exactly one CTA, editors can't add more
[ns:heroSection] > jnt:content, nsmix:component
 - ctaText (string) i18n
 - ctaLink (string) i18n       // also wrong type for links
```

## Ordering

Add `orderable` to the parent type when editors need to reorder children:

```cnd
[ns:featureList] > jnt:content, nsmix:component orderable
 + * (ns:featureItem)
```

## Hidden structural nodes

Child nodes that editors should never add manually (structural containers, auto-created nodes):

```cnd
[ns:heroSection] > jnt:content, nsmix:component, mix:title
 + ctaContainer (ns:ctaContainer) autocreated

[ns:ctaContainer] > jnt:content, jmix:hiddenType orderable
 + * (ns:callToAction)
```

`jmix:hiddenType` hides a type from the Page Builder component picker.
**Never use `jmix:studioOnly`** — it causes silent rendering issues.

## Open container (accept any droppable)

```cnd
[ns:gridRow] > jnt:content, nsmix:component
 - columns (long) = '3' autocreated mandatory < '1', '2', '3', '4'
 + * (jmix:droppableContent)
```

`+ * (jmix:droppableContent)` accepts any component the editor can drop.
