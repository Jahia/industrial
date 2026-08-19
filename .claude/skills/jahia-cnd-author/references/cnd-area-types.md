# CND Area Types — Quick Reference

## Two-tier mixin system

Define in `settings/definitions.cnd`:

```cnd
[nsmix:component]     > jmix:droppableContent, jmix:accessControllableContent mixin
[nsmix:pageComponent] > nsmix:component mixin
```

| Component placement | Extend |
|---|---|
| Dropped in page areas (top-level) | `nsmix:pageComponent` |
| Child of another component | `nsmix:component` |

A component extending only `nsmix:component` cannot be dropped in areas that restrict to `nsmix:pageComponent`.

## Custom area type

Restricts what editors can drop into a given area:

```cnd
[nsnt:pageArea] > jnt:content, jmix:list, jmix:studioOnly orderable
 + * (nsmix:pageComponent)
```

Use in a page template view:

```tsx
<Area name="main" nodeType="nsnt:pageArea" />
```

`jmix:studioOnly` on the area type prevents it from appearing in the content picker. Use `jmix:hiddenType` for regular component types that should be hidden.

## Escape hatch component

One component that accepts any droppable content, for advanced editors:

```cnd
[nsnt:contentStack] > jnt:content, nsmix:pageComponent
 + * (jmix:droppableContent)
```

Editors add this to a page area, then drop any content type inside it.

## Page templates vs sectioning components

| Page templates | Sectioning components |
|---|---|
| Fixed vertical sections per template | Editor builds sections freely |
| Simpler for less experienced editors | More flexible, preferred for evolving integrations |
| Use when mockups define clear distinct layouts | Use for a single free-form template |

Reuse area names across templates (e.g. always `main` and `sidebar`) so content is not lost when editors switch templates.
