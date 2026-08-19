# CND Syntax Reference

## Namespace declarations

| Pattern | Example |
|---|---|
| `<prefix = 'uri'>` | `<jnt = 'http://www.jahia.org/jahia/nt/1.0'>` |

Jahia built-in namespaces:

| Prefix | URI |
|---|---|
| `j` | `http://www.jahia.org/jahia/1.0` |
| `jnt` | `http://www.jahia.org/jahia/nt/1.0` |
| `jmix` | `http://www.jahia.org/jahia/mix/1.0` |

Module convention: declare two namespaces — one for node types (`ns`), one for mixins (`nsmix`). The prefix is read from the first `<…>` line in `settings/definitions.cnd`.

---

## Node type definition

```cnd
[ns:nodeType] > ns:baseType, nsmix:mixin1, nsmix:mixin2
 - property1 (type) = 'default' modifier1 modifier2
 + childNode1 (ns:childType)
```

Add `abstract` after supertypes to prevent direct instantiation:

```cnd
[ns:abstractType] > jnt:content abstract
```

All component node types must extend `nsmix:component`:

```cnd
[ns:myComponent] > jnt:content, nsmix:component
```

---

## Mixin definition

```cnd
[nsmix:myMixin] > jmix:templateMixin mixin
 - property1 (type) = 'default'
```

---

## Property anatomy

```
- propertyName (type, visualHint) = 'default' modifier1 modifier2 < constraint1, constraint2
```

| Part | Position | Example |
|---|---|---|
| Name | after `-` | `- title` |
| Type | first parens | `(string)` |
| Visual hint | after type, same parens | `(string, text)` |
| Default value | after `=` | `= 'Hello'` |
| Modifiers | after default | `i18n mandatory multiple autocreated primary` |
| Constraints | after `<` | `< 'en', 'fr', 'de'` |

### Property types

| Type | Notes |
|---|---|
| `string` | Plain text |
| `richtext` | HTML rich text |
| `boolean` | `true` / `false` |
| `long` | Integer |
| `double` | Floating point |
| `decimal` | Exact decimal |
| `date` | ISO date/time |
| `weakreference` | Node reference |
| `uri` | URI string |

### Common modifiers

| Modifier | Meaning |
|---|---|
| `i18n` | Translatable per language |
| `mandatory` | Must have a value |
| `multiple` | Multi-value property |
| `autocreated` | Created automatically |
| `primary` | Primary property of the node |
| `hidden` | Not shown in editor UI |
| `protected` | Not editable by users |

### Common visual hints

| Hint | Editor widget |
|---|---|
| `text` | Single-line text |
| `textarea` | Multi-line text |
| `richtext` | Rich text editor |
| `picker` | Content picker |
| `color` | Color picker |
| `checkbox` | Checkbox |
| `radio` | Radio buttons |
| `choicelist` | Drop-down list |

---

## Minimal working example

```cnd
<ns = 'http://www.example.org/ns/1.0'>
<nsmix = 'http://www.example.org/nsmix/1.0'>

[ns:card] > jnt:content, nsmix:component
 - title (string, text) = '' i18n
 - body (string, richtext) i18n
 - ctaLabel (string, text) i18n
 - ctaLink (weakreference, picker[type='page'])
```
