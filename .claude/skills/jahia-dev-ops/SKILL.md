---
name: jahia-dev-ops
description: >
  Operational guidance for running Jahia in production: Docker Compose and
  Kubernetes deployments, environment configuration, health monitoring,
  log analysis, and provisioning via the Jahia Provisioning API. Use when
  the user is deploying, maintaining, debugging, or scaling a Jahia instance
  (DX, jCustomer, Augmented Search / Elasticsearch, Kibana, Unomi).
allowed-tools: Read
---

# Jahia DevOps Skill

This skill covers day-to-day operations of a Jahia platform environment.
Detailed reference sheets are in `references/`.

## Reference files

| File | Content |
|------|---------|
| `references/docker.md` | Docker Compose stacks, environment variables, volume layout, networking, common run-commands |
| `references/monitoring.md` | Health endpoints, log locations, JVM/GC tuning, Karaf console, alert patterns |
| `references/provisioning.md` | Jahia Provisioning API (YAML scripts), module lifecycle, site import/export, JCR operations |

## Quick orientation

### Core components

- **Jahia DX** (`jahia/jahia-ee` or `jahia/jahia`) — the main CMS node
- **jCustomer / Apache Unomi** (`jahia/jcustomer`) — customer data platform
- **Augmented Search** (`jahia/elasticsearch` wrapper) — search back-end
- **Kibana** — Unomi analytics dashboard (optional)
- **MariaDB / MySQL** — relational database for JCR metadata and Jackrabbit bundles

### Typical task flow

1. **Deploy** — pick the right Docker Compose file or Helm chart (see `references/docker.md`)
2. **Configure** — set env vars for DB, cluster, mail, LDAP (see `references/docker.md`)
3. **Provision** — push modules, create sites, seed content (see `references/provisioning.md`)
4. **Monitor** — watch `/healthcheck`, logs, Karaf console (see `references/monitoring.md`)
5. **Troubleshoot** — collect thread dump, heap dump, or GC log; check OSGi bundle state

### Support escalation checklist

When filing a Jahia Support ticket always attach:
- `docker-compose.yml` (redact passwords)
- `jahia.log` (last 500 lines minimum)
- Output of `/healthcheck?includeDetails=true`
- Output of `bundle:list` from Karaf console
- JVM version: `java -version` inside the container
