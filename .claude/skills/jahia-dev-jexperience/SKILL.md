---
name: jahia-dev-jexperience
description: Integrate a Jahia JavaScript module with jExperience and jCustomer — set up the local stack, push visitor events from client components, visualize data in Kibana, and package dashboards for deployment.
allowed-tools: Bash, Read, Write, Edit
---

## What is jExperience / jCustomer?

**jCustomer** (built on Apache Unomi) collects and processes visitor events to create personalized digital experiences. **jExperience** is the Jahia module that bridges Jahia with jCustomer — it injects the `window.wem` tracker into every page and exposes dashboards inside jContent.

Together they form Jahia's **DXP** (Digital Experience Platform). You only need this skill when you want to track interactions, build personalization, or visualize visitor data.

---

## Step 1 — Set up jCustomer locally

### 1a — Update `docker-compose.yml`

Give the `jahia` service a static IP, add three containers, and declare the subnet:

```yaml
services:
  jahia:
    # ... existing config ...
    networks:
      default:
        ipv4_address: 172.16.1.100

  elasticsearch:
    image: elasticsearch:7.17.28
    ports:
      - 9200:9200
    environment:
      discovery.type: single-node
      cluster.name: jahia-es-cluster

  kibana:
    image: kibana:7.17.28
    ports:
      - 5601:5601
    environment:
      discovery.type: single-node
      elasticsearch.hosts: http://elasticsearch:9200

  jcustomer:
    image: jahia/jcustomer:2.6
    depends_on:
      - elasticsearch
    ports:
      - 9443:9443
      - 8181:8181
      - 8102:8102
    environment:
      UNOMI_ELASTICSEARCH_ADDRESSES: elasticsearch:9200
      UNOMI_ELASTICSEARCH_CLUSTERNAME: jahia-es-cluster
      UNOMI_CLUSTER_PUBLIC_ADDRESS: http://localhost:8181
      UNOMI_CLUSTER_INTERNAL_ADDRESS: https://jcustomer:9443
      UNOMI_THIRDPARTY_PROVIDER1_IPADDRESSES: 172.16.1.100
      UNOMI_THIRDPARTY_PROVIDER1_ALLOWEDEVENTS: login,updateProperties
      UNOMI_ROOT_PASSWORD: karaf
      UNOMI_HAZELCAST_TCPIP_MEMBERS: jcustomer

networks:
  default:
    ipam:
      config:
        - subnet: 172.16.1.0/24
```

### 1b — Update `docker/provisioning.yml`

Append at the end of the file:

```yaml
# Install and start jExperience
- installModule:
    - "mvn:org.jahia.modules/jexperience/3.6.2"
    - "mvn:org.jahia.modules/jexperience-dashboards/1.0.0"
  autoStart: true
  uninstallPreviousVersion: true

# Connect jExperience to jCustomer
- editConfiguration: "org.jahia.modules.jexperience.settings"
  configIdentifier: "global"
  properties:
    jexperience.jCustomerURL: "https://jcustomer:9443"
    jexperience.jCustomerUsername: "karaf"
    jexperience.jCustomerPassword: "karaf"
    jexperience.jCustomerTrustAllCertificates: "true"
    jexperience.jCustomerUsePublicAddressesForAdmin: "false"
    jexperience.jCustomerKey: "670c26d1cc413346c3b2fd9ce65dab41"

# Configure Kibana dashboards proxy
- editConfiguration: "org.jahia.modules.kibana_dashboards_provider"
  properties:
    kibana_dashboards_provider.kibanaURL: "http://kibana:5601"
    kibana_dashboards_provider.kibanaUser: "elastic"
    kibana_dashboards_provider.kibanaPassword: "ELASTIC_PASSWORD"
    kibana_dashboards_provider.KibanaProxy.enable: "true"
    kibana_dashboards_provider.KibanaProxy.cloud: "true"
- installModule:
    - "mvn:org.jahia.modules/kibana-dashboards-provider/1.4.0"
  autoStart: true
  uninstallPreviousVersion: true
```

### 1c — Start the stack

```bash
docker compose down jahia && docker compose up --wait
```

### 1d — Enable jExperience on the site

1. Open **Administration → Modules → jExperience → Usage in sites**
2. Check the box next to your site. Repeat for **jExperience Dashboards**.
3. Open jContent — a new **jExperience** tab should appear in the vertical bar (refresh if needed).

---

## Step 2 — Push events from a client component

jExperience injects `window.wem` (Web Experience Manager) into every page. It is only available in the browser — use it inside `.client.tsx` files.

### Event model

Every event has two parts:

| Part | What it is | Helper |
|------|------------|--------|
| **source** | Where the event happened (usually the current page) | `wem.buildSourcePage()` |
| **target** | What happened (the action) | `wem.buildTarget(id, type, properties)` |

### Full example — feedback widget

```tsx
// src/components/FeedbackWidget/definition.cnd
// [hydrogen:feedbackWidget] > jnt:content, hydrogenmix:component
//  - question (string) = 'Was this helpful?'
```

```tsx
// Widget.client.tsx
import { useState } from "react";

export default function Widget({ question }: { question: string }) {
  const [sent, setSent] = useState(false);

  const handler = (happy: boolean) => () => {
    const source = wem.buildSourcePage();
    const target = wem.buildTarget("feedback", "click", { happy });
    const event = wem.buildEvent("click", target, source);
    wem.collectEvents({ events: [event] });
    setSent(true);
  };

  if (sent) return <aside>Thank you for your feedback!</aside>;

  return (
    <aside>
      {question}
      <button type="button" onClick={handler(true)}>Yes</button>
      <button type="button" onClick={handler(false)}>No</button>
    </aside>
  );
}
```

```tsx
// default.server.tsx
import { jahiaComponent, Island } from "@jahia/javascript-modules-library";
import Widget from "./Widget.client.jsx";

interface Props { question: string; }

jahiaComponent(
  { nodeType: "hydrogen:feedbackWidget", componentType: "view" },
  ({ question }: Props) => (
    <Island clientOnly component={Widget} props={{ question }}>
      Loading…
    </Island>
  ),
);
```

### `window.wem` API reference

| Method | Signature | Returns |
|--------|-----------|---------|
| `buildSourcePage` | `()` | Source object for the current page |
| `buildTarget` | `(id: string, type: string, properties?: object)` | Target object |
| `buildEvent` | `(eventType: string, target, source)` | Event object |
| `collectEvents` | `({ events: Event[] })` | Sends events to jCustomer |

`buildTarget` properties are free-form — pass any serializable data you want to analyse downstream (e.g. `{ happy: true }`, `{ productId: "p-123" }`).

> The `window.wem` object comes from the [apache/unomi-tracker](https://github.com/apache/unomi-tracker) package. Refer to its documentation for advanced event types.

### Google Tag Manager alternative

If your site uses GTM instead of jCustomer:

```tsx
dataLayer.push({ event: "feedback", happy });
```

---

## Step 3 — Verify events in Kibana

1. Open [localhost:5601](http://localhost:5601)
2. Go to **Discover**, select the `*-event` index, and expand the time range
3. Browse an event — confirm the `source.properties.pageInfo.pagePath` and `target.properties.happy` fields are present

---

## Step 4 — Create a Kibana dashboard

### Create a saved search

In **Discover**, add column filters for:
- `eventType` = `click`
- `itemType` = `event`
- `target.itemId` = `feedback`
- `target.itemType` = `click`

Add display columns: `source.properties.pageInfo.pagePath`, `target.properties.happy`. Save as e.g. **All Feedbacks**.

### Create the dashboard

1. **Dashboards → Create dashboard**
2. **Add from library** → add the saved search (table of all feedbacks)
3. **Create visualization** → paste this KQL filter into the search bar:
   ```
   eventType: click and itemType: event and target.itemId: feedback and target.itemType: click
   ```
4. Drop **Records** onto the panel, then in **Break down by** select `target.properties.happy`. Use the **Status** color palette for red/green.
5. **Save and return**, then **Save** the dashboard with a meaningful name — this name becomes the entry label inside Jahia's jExperience tab.

---

## Step 5 — Package the dashboard in the module

Dashboards exported from Kibana are automatically imported when the module is deployed.

1. In Kibana go to **Analytics → Overview → Manage → Saved Objects**
2. Select your dashboard, click **Export** — you get a `.ndjson` file
3. Save it to your module:
   ```
   settings/kibana-dashboard/dashboards/<dashboard-name>.ndjson
   ```
4. Deploy the module — the dashboard will appear in the jExperience tab on any Jahia instance running the module.

---

## Validation checklist
- [ ] `docker compose up --wait` completed with elasticsearch, kibana, jcustomer healthy
- [ ] jExperience and jExperience Dashboards enabled on the target site
- [ ] jExperience tab visible in jContent
- [ ] Client component uses `.client.tsx` extension and `Island clientOnly`
- [ ] `wem.collectEvents` called with a valid event (source + target)
- [ ] Events visible in Kibana Discover under `*-event` index
- [ ] Dashboard saved and visible under the jExperience tab in Jahia
- [ ] Dashboard `.ndjson` saved to `settings/kibana-dashboard/dashboards/` for packaging

## References
- Apache Unomi tracker: https://github.com/apache/unomi-tracker
- KQL query syntax: https://www.elastic.co/guide/en/kibana/current/kuery-query.html
- jExperience guide: https://github.com/Jahia/javascript-modules/blob/main/docs/2-guides/1-building-a-feedback-form/README.md
