## CND type → TypeScript mapping

| CND type | TypeScript type | Notes |
|---|---|---|
| `string` | `string` | |
| `string` + `multiple` | `string[]` | |
| `long` | `number` | 64-bit integer |
| `double` | `number` | 64-bit float |
| `boolean` | `boolean` | |
| `date` | `string` | ISO 8601 string |
| `weakreference` | `JCRNodeWrapper \| undefined` | Always optional |
| `weakreference` + `multiple` | `JCRNodeWrapper[]` | |

## Required import
```ts
import type { JCRNodeWrapper } from "org.jahia.services.content";
```

## mix:title
When a type extends `mix:title`, add `"jcr:title"?: string` to Props.

## linkTypeInitializer discriminated union
When CND has `j:linkType (string, choicelist[linkTypeInitializer])`, use a discriminated union:
```ts
export type Props =
  | { "j:linkType": "none" }
  | { "j:linkType": "internal"; "j:linknode"?: JCRNodeWrapper }
  | { "j:linkType": "external"; "j:url"?: string; "j:linkTitle"?: string };
```
Add other fields of the type to each union member.

## Choicelist (fixed values)
Use a string literal union:
```ts
variant?: "primary" | "secondary" | "ghost";
columns?: "1" | "2" | "3";   // long choicelist values come through as strings
```

## Full example
For a CND type:
```cnd
[ns:card] > jnt:content, nsmix:component, mix:title
 - subtitle (string) i18n
 - body (string, richtext) i18n
 - image (weakreference, picker[type='image']) < jmix:image
 - variant (string, choicelist) < 'primary', 'secondary'
 - j:linkType (string, choicelist[linkTypeInitializer]) mandatory
```

The `types.ts`:
```ts
import type { JCRNodeWrapper } from "org.jahia.services.content";

type CardBase = {
  "jcr:title"?: string;
  subtitle?: string;
  body?: string;
  image?: JCRNodeWrapper;
  variant?: "primary" | "secondary";
};

export type Props = CardBase & (
  | { "j:linkType": "none" }
  | { "j:linkType": "internal"; "j:linknode"?: JCRNodeWrapper }
  | { "j:linkType": "external"; "j:url"?: string; "j:linkTitle"?: string }
);
```

## Rules
- All properties are optional unless `mandatory` in CND (and even mandatory fields may be absent at runtime — always guard)
- `weakreference` is always `JCRNodeWrapper | undefined` regardless of `mandatory`
- Never add `j:linknode` or `j:url` to the CND — they appear in types.ts via the discriminated union because Jahia injects them
- `i18n` does not affect the TypeScript type
