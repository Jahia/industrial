---
name: jahia-dev-properties
description: |
  Reference and guidance for configuring Jahia 8.2 via jahia.properties,
  jahia.node.properties, and OSGi .cfg files. Use when: setting operating mode
  (dev/production), configuring clustering, changing authentication (CAS, SPNEGO,
  cookie), tuning JCR/search index settings, adjusting URL rewriting, changing
  disk paths, or looking up any specific Jahia property key and its default value.
allowed-tools: Read
---

## Configuration Files

| File | Location | Purpose |
|---|---|---|
| `jahia.properties` | `digital-factory-config/jahia/` | Main Jahia configuration |
| `jahia.node.properties` | `digital-factory-config/jahia/` | Cluster / node-specific settings |
| OSGi `.cfg` files | `digital-factory-data/karaf/etc/` | Module and subsystem settings |

`jahia.properties` is read at startup. Changes require a restart unless overridden via OSGi config at runtime.

## Variable Interpolation

Jahia resolves these variables in property values:

| Variable | Resolves to |
|---|---|
| `${jahiaWebAppRoot}` | Webapp root (e.g. `.../webapps/ROOT`) |
| `${jahia.data.dir}` | Same as `jahiaVarDiskPath` once resolved |
| `${jahia.jackrabbit.home}` | JCR repository home |

Default data layout:
```
digital-factory-data/          ← jahiaVarDiskPath
  modules/                     ← jahiaModulesDiskPath
  imports/                     ← jahiaImportsDiskPath
  repository/                  ← jahia.jackrabbit.home
  repository/datastore/        ← jahia.jackrabbit.datastore.path
  generated-resources/         ← must be shared in cluster
```

## Common Production Setup

Properties to change when going to production:

```properties
# jahia.properties
operatingMode = production

# Disable development-only endpoints
jahia.find.disabled = true
repositoryDirectoryListingDisabled = false

# URL rewriting (already on by default)
urlRewriteSeoRulesEnabled = true
urlRewriteRemoveCmsPrefix = true
permanentMoveForVanityURL = true

# Protect against semicolon injection
shiro.blockSemicolon = true
```

## Cluster Setup (jahia.node.properties)

```properties
cluster.activated = true
cluster.node.serverId = my-node-1        # unique per node
processingServer = true                  # only ONE node should be true
cluster.tcp.bindAddress =                # leave empty to auto-detect, or set IP
cluster.tcp.bindPort = 7870              # JGroups
cluster.hazelcast.bindPort = 7860        # Hazelcast

# In jahia.properties — must be on shared filesystem
jahiaGeneratedResourcesDiskPath = /shared-nfs/generated-resources/
```

## Authentication Quick Reference

| Auth method | Enable property |
|---|---|
| Cookie (default) | `auth.cookie.enabled = true` |
| CAS | `auth.cas.enabled = true` + set `auth.cas.serverUrlPrefix` |
| SPNEGO (Windows) | `auth.spnego.enabled = true` |
| Container | `auth.container.enabled = true` |

CAS minimum config:
```properties
auth.cas.enabled = true
auth.cas.serverUrlPrefix = https://cas.example.com/cas
auth.cas.loginUrl = ${auth.cas.serverUrlPrefix}/login
auth.cas.logoutUrl = ${auth.cas.serverUrlPrefix}/logout
```

## JCR / Search Tuning

```properties
# Check + auto-repair search index on startup (costly — use for one-time fixes)
jahia.jackrabbit.searchIndex.enableConsistencyCheck = true
jahia.jackrabbit.searchIndex.autoRepair = true

# Full reindex on startup (very slow on large repos — use only when needed)
jahia.jackrabbit.reindexOnStartup = true

# Workspace consistency check
jahia.jackrabbit.consistencyCheck = true
jahia.jackrabbit.consistencyFix = true

# Query stats (useful for diagnosing slow queries)
jahia.jackrabbit.queryStatsEnabled = true
```

## Performance Tuning

```properties
# Reduce parallel module generation threads if CPU-bound
maxModulesToGenerateInParallel = 50

# Increase LRU caches for large sites
accessManagerPathPermissionCacheMaxSize = 100
jahia.jcr.nodesCachePerSessionMaxSize = 100

# Limit max request render time (ms); -1 = no limit
maxRequestRenderTime = 60000

# Mass import: expand to disk first for very large imports
expandImportedFilesOnDisk = true
expandImportedFilesOnDiskPath = /tmp
importMaxBatch = 500
```

## OSGi / Karaf Shell

```properties
karaf.remoteShell.port = 8101        # SSH into Karaf; set negative to disable
karaf.remoteShell.host = 127.0.0.1  # bind address; restrict to localhost in prod
```

Connect: `ssh -p 8101 karaf@localhost`

## Full Property Reference

See [references/all-properties.md](references/all-properties.md) for all ~90 properties grouped by category with keys, defaults, and descriptions.

Search tip:
```bash
grep -i "keyword" $(find .claude .agents -name "all-properties.md" 2>/dev/null | head -1)
```
