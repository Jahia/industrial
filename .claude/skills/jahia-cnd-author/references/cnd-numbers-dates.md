# CND Numeric, Date & Boolean Properties

## Types

| Type | Editor widget | Notes |
|---|---|---|
| `long` | Integer number input | Counts, limits, columns |
| `double` | Decimal number input | Coordinates, prices, ratios |
| `boolean` | Checkbox | Feature flags, toggles |
| `date` | Date picker | ISO 8601 stored, string in TypeScript |
| `date, datepicker` | Date-only picker | Same storage, date-only widget |
| `date, datetimepicker` | Date + time picker | Use when time precision is needed |

## Types to avoid

| Avoid | Use instead | Reason |
|---|---|---|
| `path` | `weakreference` | weakreference is the preferred reference type |
| `reference` | `weakreference` | Not properly implemented |
| `uri` | `string` | No added value |
| `decimal` | `double` | Use double for decimal numbers |
| `name` | `string` | JCR node type name; use string instead |
| `binary` | — | Binary data; rarely needed in practice |
| `undefined` | — | Unknown type; avoid |

## Default values with `autocreated`

Always combine `autocreated` with `= 'value'`:

```cnd
- columns (long) = '3' autocreated mandatory < '1', '2', '3', '4'
- isHighlighted (boolean) = 'false' autocreated
- country (string, choicelist[country]) = 'US' autocreated mandatory
```

### `date` default — `now()`

Use `now()` (no quotes) to default a date to the current time at node creation:

```cnd
- publishDate (date, datepicker) = now() autocreated
```

## Range constraints

```cnd
// Numeric range — inclusive brackets
- latitude (double) mandatory < "[-90,90]"
- longitude (double) mandatory < "[-180,180]"
- rating (long) mandatory < "[1,5]"
```

**Star ratings always need a range constraint.** Never write `rating (long)` without `< "[1,5]"`:

```cnd
// WRONG
- rating (long) = 5 indexed=no

// CORRECT
- rating (long) = '3' autocreated mandatory < "[1,5]"
```

## Date range constraints

Parentheses = exclusive bound, brackets = inclusive. Leave a side empty for open-ended:

```cnd
// Any date after 2020-01-01 (exclusive)
- eventDate (date, datepicker) < '(2020-01-01T00:00:00.000,)'

// Bounded campaign window
- campaignDate (date, datepicker) < '(2020-01-01T00:00:00.000,2030-12-31T00:00:00.000)'
```

## `datetimepicker` vs `datepicker`

```cnd
// Date only
- publishDate (date, datepicker) = now() autocreated

// Date + time
- eventDateTime (date, datetimepicker) i18n mandatory
```

## TypeScript mapping

| CND type | TypeScript |
|---|---|
| `long` | `number` |
| `double` | `number` |
| `boolean` | `boolean` |
| `date` | `string` (ISO 8601) |
