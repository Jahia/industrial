# CND Authoring Experience Reference

## .properties labels and icons

Required files for every content type:
- `settings/resources/<module>_en.properties`
- `settings/resources/<module>_fr.properties`

```ini
# Node type label
ns_heroSection.label=Hero Section

# Field labels
ns_heroSection.subtitle.label=Subtitle
ns_heroSection.backgroundImage.label=Background Image

# Field tooltip
ns_heroSection.subtitle.ui.tooltip=Optional subtitle text displayed below the heading.

# Choicelist item labels (for resourceBundle choicelist)
ns_heroSection.variant.primary=Primary
ns_heroSection.variant.secondary=Secondary
```

Icon file: `settings/content-types-icons/<ns>_<typeName>.png`
Free icons: https://www.flaticon.com/

**Rules:**
- Every node type must have a `.label` entry.
- Every field must have a `.label` entry.
- Choicelist options using `resourceBundle` must have a label per value.
- Replace special characters (e.g. `:`) with `_` in the `.properties` key.

---

## Editor hints in views

Use `renderContext.isEditMode()` to show a flat, non-interactive layout and hints in edit mode.

```tsx
({ slides }: Props, { renderContext }) => {
  const isEdit = renderContext.isEditMode();
  return isEdit ? (
    <div>
      <RenderChildren />
      <p className={classes.hint}>Carousel — add or reorder slides here</p>
    </div>
  ) : (
    <div className={classes.carousel}><RenderChildren /></div>
  );
};
```

Show inline validation hints:

```tsx
{renderContext.isEditMode() && value % 2 !== 0 && (
  <p className="editor-hint">Value should be even for best visual result.</p>
)}
```

---

## import.xml recommendations

Provide `import.xml` in every template set to pre-populate new sites:

- A homepage with `j:isHomePage="true"` — required for sitemap and nav generation.
- Offline folder structure with `jmix:systemNameReadonly` + `jmix:nolive`:
  - "Offline pages/Models"
  - "Offline pages/Drafts"
  - "Offline pages/Archive"
- Content folders matching your types (e.g. "Blog/Authors", "Blog/Posts").
- Content restrictions on folders:
  ```xml
  jcr:mixinTypes="jmix:contributeMode" j:contributeTypes="ns:blogPost"
  ```

> `import.xml` only applies at site creation — changes do NOT update existing sites.

---

## jmix:visibleInContentTree

Enables Page Builder visual editing inside content folders (not just list view).

```cnd
[ns:authorCollection] > jnt:content, jmix:visibleInContentTree
 + * (ns:author)
```

Use when editors benefit from visual layout while editing content folder items.
