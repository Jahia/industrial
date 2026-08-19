# Jahia Native Mixins & Types

Source: https://github.com/Jahia/jahia/tree/master/war/src/main/webapp/WEB-INF/etc/repository/nodetypes
Fetch this URL to verify before using any mixin not listed here.

## Base types — always extend these

| Type | Purpose |
|---|---|
| `jnt:content` | Base for all user content nodes — **always include** |
| `jnt:page` | Page node — only for `jmix:mainResource` full-page types |
| `jnt:file` | File node — for file references |

---

## Component system mixins — define these in your module first

### Two-tier component mixin pattern

Define these in `settings/definitions.cnd` before all other types:

```cnd
[nsmix:component]     > jmix:droppableContent, jmix:accessControllableContent mixin
[nsmix:pageComponent] > nsmix:component mixin
```

| Component will be… | Extend |
|---|---|
| Dropped in page areas | `nsmix:pageComponent` |
| Child of another component | `nsmix:component` |
| Listed programmatically | `nsmix:component` |

### `jmix:droppableContent` — base for droppable types

Extends `mix:referenceable`. Never extend directly — always wrap in a module mixin.

### `jmix:accessControllableContent` — per-component access control

Extends `mix:referenceable`. Include in your base module mixin so all components support it.

---

## Title & metadata mixins

### `mix:title` — preferred over a raw title property

Adds `jcr:title` (string). Jahia's UI, breadcrumbs, SEO, and sitemap generation all read `jcr:title`.
**Extend this instead of declaring `- title (string) i18n mandatory`.**

```cnd
[ns:article] > jnt:content, nsmix:component, mix:title
```

Access in view: `props["jcr:title"]`

### `jmix:description` — description metadata

Marker/metadata mixin for content descriptions.

### `jmix:tagged` — free-form tagging

Adds `j:tagList` (string, multiple) with autocomplete and `j:tags` (weakreference, multiple, hidden/deprecated).

```cnd
[ns:article] > jnt:content, nsmix:component, mix:title, jmix:tagged
```

CND definition:
```cnd
[jmix:tagged] mixin
  extends = nt:hierarchyNode, jnt:content, jnt:page
  itemtype = metadata
  - j:tagList (string, tag[autocomplete=10, separator=',']) facetable nofulltext multiple
  - j:tags (weakreference) multiple hidden
```

### `jmix:categorized` — category classification

Adds `j:defaultCategory` (weakreference, multiple) pointing to taxonomy categories.

```cnd
[ns:article] > jnt:content, nsmix:component, mix:title, jmix:categorized
```

CND definition:
```cnd
[jmix:categorized] mixin
  extends = nt:hierarchyNode, jnt:content, jnt:page
  itemtype = classification
  - j:defaultCategory (weakreference, category[autoSelectParent=false]) facetable hierarchical multiple
```

### `jmix:keywords` — keyword metadata

Marker mixin for keyword support.

### `jmix:thumbnail` — thumbnail support

Marker mixin for thumbnail images.

### `jmix:basemetadata` — standard metadata with versioning

Extends `jmix:unversionedBasemetadata`. Adds standard authoring metadata (author, dates, etc.) with versioning support.

### `jmix:unversionedBasemetadata` — standard metadata without versioning

Includes i18n support. Use `jmix:basemetadata` unless versioning must be excluded.

---

## Publication & workflow mixins

### `jmix:autoPublish` — automatic live publication

Extends `jmix:observable`. Any change to the node is immediately published to the live workspace without going through a workflow.

```cnd
[ns:config] > jnt:content, jmix:hiddenType, jmix:autoPublish
```

### `jmix:publication` — independent publication

Marker mixin. Enables a node to be published independently of its parent.

### `jmix:nolive` — prevent live publication

Marker mixin. Node is never published to the live workspace (e.g. draft-only content).

### `jmix:workflow` — workflow tracking

Adds `j:processId` (string, multiple, protected, hidden). Tracks active workflow processes. Do not extend manually — Jahia applies it during workflow execution.

### `jmix:noImportExport` — exclude from import/export

Marker mixin. Node is skipped during content import/export operations.

### `jmix:lastPublished` — publication timestamp tracking

Marker mixin for tracking last publication date.

---

## Access control & visibility mixins

### `jmix:accessControlled` — node-level ACL

Adds a `j:acl` child node (jnt:acl, mandatory, autocreated). Enables fine-grained ACL management on a specific node. Usually inherited via `jmix:accessControllableContent` — do not add directly unless you need ACL on a non-content node.

### `jmix:requiredPermissions` — permission-based rendering

Controls whether a component renders based on the visitor's login state or role.

```cnd
[ns:memberOnly] > jnt:content, nsmix:component, jmix:requiredPermissions
```

Properties:
```cnd
[jmix:requiredPermissions] mixin
  extends = jnt:content, jnt:area, jnt:mainResourceDisplay
  itemtype = permissions
  - j:requireLoggedUser (boolean)
  - j:requirePrivilegedUser (boolean)
  - j:requiredMode (string, choicelist[renderModes]) nofulltext
```

### `jmix:lockable` — node locking

Marker mixin. Enables JCR locking on a node.

### `jmix:conditionalVisibility` — conditional visibility rules

Marker mixin. Enables conditional visibility configuration (by date range, segment, etc.) in Page Builder.

---

## Rendering & template mixins

### `jmix:mainResource` — full-page content types only

Makes a node accessible at its own URL. Use **only** for content that needs both a listing card AND a detail page (e.g. blog posts, team members, events). Do not add to navigation or visual composition types.

```cnd
[ns:blogPost] > jnt:content, mix:title, jmix:mainResource, nsmix:component
```

### `jmix:renderableMainResource` — specify main resource view

Adds `j:mainResourceView` (string) to select which view template renders the detail page.

```cnd
[jmix:renderableMainResource] mixin
  - j:mainResourceView (string, choicelist[templates=mainresource, resourceBundle, image]) nofulltext
```

### `jmix:renderable` — renderable content

Marker mixin for content that can be rendered.

### `jmix:hasTemplateNode` — template node association

Marker mixin. Associates a node with a specific template node.

### `jmix:canBeUseAsTemplateModel` — template model

Marker mixin. Enables the node type to be used as a template model.

### `jmix:createdFromPageModel` — page model origin

Marker mixin. Tracks that a page was created from a page model.

### `jmix:templateMixin` — template property inheritance

Marker mixin. Enables template-specific property inheritance.

### `jmix:dynamicFieldset` — dynamic fieldsets

Extends `jmix:templateMixin`. Enables dynamic fieldsets (properties that appear/disappear based on other selections) in the edit UI.

### `jmix:theme` — theme support

Marker mixin for theming.

### `jmix:useUILocale` — UI locale

Marker mixin. Renders content using the UI locale rather than the site locale.

### `jmix:rbTitle` — resource bundle title

Marker mixin. Title comes from a resource bundle key rather than a stored string.

---

## Content organisation & type mixins

### `jmix:hiddenType` — hide from Page Builder picker

Structural/container types editors should not add manually:

```cnd
[ns:ctaContainer] > jnt:content, jmix:hiddenType orderable
```

**Never use `jmix:studioOnly`** — it causes silent rendering issues.

### `jmix:hiddenNode` — hide node from UI

Marker mixin. Hides a specific node instance from all UI displays (not the type — the node itself).

### `jmix:studioOnly` — studio-only content

**Avoid.** Can cause silent rendering issues. Use `jmix:hiddenType` instead.

### `jmix:listContent` — list content type

Extends `jmix:droppableContent, jmix:accessControllableContent`. Use for droppable list containers.

### `jmix:basicContent` — basic content type

Extends `jmix:droppableContent, jmix:accessControllableContent`. Base for simple droppable components.

### `jmix:structuredContent` — structured content

Marker mixin for structured data content types.

### `jmix:editorialContent` — editorial content

Marker mixin. Identifies content managed editorially.

### `jmix:siteContent` — site content

Marker mixin. Content scoped to a specific site.

### `jmix:socialComponent` — social component

Marker mixin for social feature components.

### `jmix:multimediaContent` — multimedia content

Marker mixin for audio/video content types.

### `jmix:layoutComponentContent` — layout component

Marker mixin for layout/structural components.

### `jmix:siteComponent` — site component

Marker mixin for site-level components.

### `jmix:formContent` — form content

Marker mixin for form-related components.

### `jmix:queryContent` — query content

Marker mixin for content that runs JCR queries.

### `jmix:userProfileComponents` — user profile components

Marker mixin for user profile display components.

### `jmix:browsableInEditorialPicker` — editorial picker navigation

Marker mixin. Makes nodes of this type appear as navigable folders in the editorial content picker UI.

---

## Ordering mixins

### `jmix:manuallyOrderable` — manual child ordering

Marker mixin. Enables editors to manually reorder child nodes via drag-and-drop.

```cnd
[ns:gallery] > jnt:content, nsmix:component, jmix:manuallyOrderable
```

### `jmix:automaticallyOrderable` — automatic ordering base

Marker mixin. Base for types that support automatic ordering.

### `jmix:orderedList` — field-based automatic ordering

Extends `jmix:automaticallyOrderable`. Adds sort field/direction configuration to a content list.

```cnd
[jmix:orderedList] mixin
  itemtype = listOrdering
  extends = jnt:contentList, jnt:area, jmix:automaticallyOrderable
  - ignoreCase (boolean) = true autocreated
  - firstField (string, choicelist[sortableFieldnames]) indexed=no
  - firstDirection (string, choicelist[resourceBundle]) = 'asc' autocreated indexed=no < 'asc','desc'
```

---

## Internationalisation & search

### `jmix:i18n` — multilingual node support

Adds `j:invalidLanguages` (string, multiple) and child `jnt:translation` nodes. Jahia automatically applies this when a property is declared `i18n` — you do not extend it manually.

```cnd
[jmix:i18n] mixin
  - j:invalidLanguages (string) multiple nofulltext hidden
  + * (jnt:translation)
```

### `jmix:searchable` — search indexing

Marker mixin. Identifies nodes that should be discoverable via search.

---

## File & document mixins

### `jmix:image` — image type constraint

Use as a constraint on image weakreference properties:

```cnd
- backgroundImage (weakreference, picker[type='image']) < jmix:image
```

**Never use `< 'jnt:file'`** — it does not enforce image type correctly.

**Never declare `imageAlt (string) i18n`** alongside an image weakreference. Use the image node's `jcr:title` as alt text:

```tsx
const imageAlt = props.image?.getPropertyAsString("jcr:title") ?? "";
```

### `jmix:document` — document metadata

Metadata mixin for documents (page count, word count, etc.).

### `jmix:exif` — EXIF image data

Adds EXIF metadata properties to image file nodes.

### `jmix:photo` — photo properties

Photo-specific metadata mixin.

### `jmix:size` — width/height properties

Adds height and width properties.

### `jmix:extension` — file extension marker

Marker mixin for file type extension tracking.

---

## Link & reference mixins

### `jmix:link` — built-in link type

Provides `j:linkType`, `j:linknode`, `j:url`, `j:linkTitle`. Extend this mixin for types that need link behaviour without declaring `j:linkType` directly.

### `jmix:nodeReference` — node reference support

Marker mixin for types that reference other nodes.

### `jmix:referencesInField` — field-level references

Marker mixin. Enables reference tracking at the field level.

### `jmix:bindedComponent` — component binding

Marker mixin for components bound to other components.

### `jmix:externalReference` — external references

Marker mixin for types referencing external (non-JCR) resources.

---

## Navigation mixins

### `jmix:navMenu` — navigation menu

Marker mixin for navigation menu containers.

### `jmix:navMenuItem` — navigation menu item

Marker mixin for individual navigation menu entries.

### `jmix:visibleInPagesTree` — pages tree visibility

Marker mixin. Makes nodes visible in the pages tree navigation.

### `jmix:visibleInContentTree` — content tree visibility

Marker mixin. Makes nodes visible in the content tree navigation.

---

## Caching & performance mixins

### `jmix:cache` — cache configuration

Marker mixin for configuring component-level caching behaviour.

---

## System & structural mixins (do not extend unless building infrastructure)

| Mixin | Purpose |
|---|---|
| `jmix:nodenameInfo` | System node identification marker |
| `jmix:systemNode` | System node marker |
| `jmix:observable` | Event-based monitoring (observable pattern) |
| `jmix:list` | Identifies container/collection nodes |
| `jmix:isAreaList` | Area list marker |
| `jmix:shareable` | Shareable content (shared nodes across paths) |
| `jmix:unstructured` | Unstructured content (accepts any child) |
| `jmix:hasIcon` | Icon support |
| `jmix:systemNameReadonly` | Prevents renaming via UI |
| `jmix:blockUiMove` | Prevents drag-move in UI |
| `jmix:skipConstraintCheck` | Bypasses node type constraint checks |
| `jmix:contributeMode` | Contribute mode support |
| `jmix:listRestrictions` | List restrictions configuration |
| `jmix:studioLayout` | Studio layout marker |
| `jmix:listedInRestrictions` | Listed-in-restrictions marker |
| `jmix:markedForDeletion` | Deletion marker (internal) |
| `jmix:markedForDeletionRoot` | Deletion root marker (internal) |
| `jmix:autoSplitFolders` | Auto-splits folders when child count is high |
| `jmix:hideDeleteAction` | Hides delete action in UI |
| `jmix:htmlSettings` | HTML settings |
| `jmix:viewProperties` | View properties |
| `jmix:mockupStyle` | Mockup styling |
| `jmix:requireLicense` | License requirement marker |
| `jmix:hasExternalProviderExtension` | External provider extension support |
| `jmix:sourceControl` | Source control integration |
| `jmix:moduleImportFile` | Module import file marker |
| `jmix:originWS` | Workspace origin tracking |
| `jmix:liveProperties` | Live workspace properties |
| `jmix:deletedChildren` | Deleted children tracking |

---

## Legacy/compatibility mixins (do not use in new modules)

| Mixin | Notes |
|---|---|
| `jmix:filemetadata` | Replaced by `jmix:basemetadata` |
| `jmix:hierarchyNode` | Legacy hierarchy marker |
| `jmix:collection` | Legacy collection marker |
| `jmix:usersFolder` | Legacy users folder (extends `nt:base`) |
| `jmix:groupsFolder` | Legacy groups folder |
| `jmix:virtualsitesFolder` | Legacy virtual sites folder |
| `jmix:mountPointFactory` | Mount point factory |
| `jmix:legacyContent` | Legacy content marker |
| `jmix:legacyPage` | Legacy page marker |
| `jmix:legacyFile` | Legacy file marker |

---

## picker[] selector

| Selector | Use |
|---|---|
| `picker[type='image']` | Image assets only |
| `picker[type='file']` | Any file asset |

```cnd
- backgroundImage (weakreference, picker[type='image']) < jmix:image
- attachment (weakreference, picker[type='file']) < jnt:file
```
