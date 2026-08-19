# Jahia Monitoring Reference

## Health endpoints

| Endpoint | Auth | Returns |
|----------|------|---------|
| `GET /healthcheck` | None | `{"status":"GREEN"}` or non-200 |
| `GET /healthcheck?includeDetails=true` | Basic (root) | Full JSON with per-probe status |
| `GET /modules/healthcheck` | Basic (root) | Module-level detail |
| `GET /live` | None | Kubernetes liveness (200 = alive) |
| `GET /ready` | None | Kubernetes readiness (200 = ready to serve) |

### Interpreting `/healthcheck?includeDetails=true`

```json
{
  "status": "GREEN",      // GREEN | YELLOW | RED
  "probes": {
    "DatabaseProbe":    { "status": "GREEN" },
    "ServerLoadProbe":  { "status": "YELLOW", "message": "Load: 3.4" },
    "JCRProbe":         { "status": "GREEN" }
  }
}
```

A `RED` status means the instance should not receive traffic. A `YELLOW` means
degraded but still functional. Common probe names: `DatabaseProbe`,
`JCRProbe`, `ServerLoadProbe`, `ModulesProbe`, `ClusterProbe`.

## Log files

| File | Content |
|------|---------|
| `/var/log/jahia/jahia.log` | Main application log (INFO+) |
| `/var/log/jahia/errors.log` | ERROR-only mirror of jahia.log |
| `/var/log/jahia/access.log` | HTTP access log (Combined format) |
| `/var/log/jahia/jahia_audit.log` | Security/audit events |
| `/var/log/jahia/gc.log*` | GC log (if `-Xlog:gc*` enabled) |

### Key log patterns to watch

```
# Module deployment failure
ERROR.*BundleException
ERROR.*Failed to deploy module

# JCR / Jackrabbit errors
ERROR.*RepositoryException
ERROR.*ItemExistsException

# DB connectivity
ERROR.*Cannot get a connection
ERROR.*Communications link failure

# Out of memory / GC pressure
java.lang.OutOfMemoryError
GC overhead limit exceeded

# Cluster split-brain
WARN.*Hazelcast.*member.*left
ERROR.*ClusterProbe

# Session leaks / thread pool exhaustion
WARN.*Maximum pool size reached
WARN.*No active session
```

### Useful log grep commands

```bash
# All ERRORs in the last hour (adjust tail count)
docker compose exec jahia grep "^[0-9].*ERROR" /var/log/jahia/jahia.log | tail -200

# Module-related events today
docker compose exec jahia grep -i "module\|bundle\|deploy" /var/log/jahia/jahia.log | grep "$(date +%Y-%m-%d)"

# Slow queries (threshold 1000 ms is default)
docker compose exec jahia grep "SlowQuery\|slow query" /var/log/jahia/jahia.log
```

## Karaf console

Connect via SSH (port 7770 by default):

```bash
ssh -p 7770 karaf@localhost
# Password = JAHIA_ROOT_PASSWORD
```

### Essential Karaf commands

```
# OSGi bundle state
bundle:list                         # List all bundles + state
bundle:list | grep -v Active        # Only non-Active bundles (problem candidates)
bundle:diag <bundle-id>             # Diagnose a specific bundle (missing imports etc.)
bundle:start <bundle-id>
bundle:stop  <bundle-id>
bundle:refresh <bundle-id>

# Module management
module:list                         # Jahia modules + version + state
jahia:deploy <path-to-jar>          # Deploy a module from local path

# Cluster
cluster:info                        # Show Hazelcast cluster members
cluster:manager-node                # Show which node is the manager

# System info
info                                # JVM / Karaf version summary
threads                             # Thread count snapshot
memory                              # Heap / non-heap usage

# Log level (temporary, reverts on restart)
log:set DEBUG org.jahia.services.content
log:set INFO  org.jahia.services.content   # reset

# Display live log tail inside Karaf
log:tail
```

## JVM tuning

### Heap sizing

Set `MAX_RAM_PERCENTAGE` env var (e.g. `75`) to let the JVM auto-size to a
percentage of container RAM. Alternatively set explicit flags via `EXTRA_JAVA_OPTS`:

```
EXTRA_JAVA_OPTS=-Xms2g -Xmx4g
```

Rule of thumb: 4 GB heap minimum for a single-node dev instance; 8–16 GB for
production with content-heavy sites.

### GC logging (add to EXTRA_JAVA_OPTS)

```
-Xlog:gc*:file=/var/log/jahia/gc.log:time,uptime,level,tags:filecount=5,filesize=20m
```

### Thread dump

```bash
# Get PID inside container
docker compose exec jahia bash -c 'jps | grep Jahia'
# Take dump (replace <PID>)
docker compose exec jahia bash -c 'kill -3 <PID>'
# Output goes to jahia.log
```

Or from Karaf: `threads --list` for a quick summary.

### Heap dump on OOM (add to EXTRA_JAVA_OPTS)

```
-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/log/jahia/heapdump.hprof
```

## jCustomer (Unomi) monitoring

```bash
# Health
curl http://localhost:8181/cxs/actuator/health

# Cluster nodes (REST)
curl -u karaf:karaf http://localhost:8181/cxs/cluster

# Karaf console (port 8101)
ssh -p 8101 karaf@localhost
```

## Elasticsearch monitoring

```bash
# Cluster health
curl http://localhost:9200/_cluster/health?pretty

# Index sizes
curl http://localhost:9200/_cat/indices?v&h=index,docs.count,store.size

# Pending tasks
curl http://localhost:9200/_cluster/pending_tasks
```

## Alerting thresholds (suggested)

| Metric | Warning | Critical |
|--------|---------|---------|
| Heap usage | 75 % | 90 % |
| Jahia healthcheck status | YELLOW | RED |
| DB connection pool | 80 % utilised | 95 % utilised |
| Error log rate | > 10/min | > 50/min |
| ES cluster health | YELLOW | RED |
| GC pause (G1GC stop-the-world) | > 500 ms | > 2 s |
