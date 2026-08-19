# Jahia Docker Reference

## Image tags

| Image | Stable tag pattern | Notes |
|-------|--------------------|-------|
| `jahia/jahia-ee` | `8.2.x.x` | Enterprise Edition (most deployments) |
| `jahia/jahia` | `8.2.x.x` | Community Edition |
| `jahia/jcustomer` | `2.6.x` | Apache Unomi-based CDP |
| `jahia/elasticsearch` | `7.17.x-jahia` | Patched ES image for Augmented Search |

Always pin to an exact version in production. Avoid `latest`.

## Minimal single-node docker-compose.yml

```yaml
version: "3.8"
services:
  jahia:
    image: jahia/jahia-ee:8.2.4.0
    ports:
      - "8080:8080"
      - "7770:7770"   # Karaf SSH
    environment:
      JAHIA_ROOT_PASSWORD: changeme
      DB_HOST: mariadb
      DB_NAME: jahia
      DB_USER: jahia
      DB_PASS: jahia
      PROCESSING_SERVER: "true"
    volumes:
      - jahia-data:/var/jahia
      - jahia-logs:/var/log/jahia
    depends_on:
      mariadb:
        condition: service_healthy

  mariadb:
    image: mariadb:10.11
    environment:
      MYSQL_DATABASE: jahia
      MYSQL_USER: jahia
      MYSQL_PASSWORD: jahia
      MYSQL_ROOT_PASSWORD: root
    volumes:
      - mariadb-data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 10s
      timeout: 5s
      retries: 10

volumes:
  jahia-data:
  jahia-logs:
  mariadb-data:
```

## Key environment variables

### Jahia DX

| Variable | Default | Purpose |
|----------|---------|---------|
| `JAHIA_ROOT_PASSWORD` | *(required)* | `root` user password |
| `DB_HOST` | `mariadb` | Database hostname |
| `DB_PORT` | `3306` | Database port |
| `DB_NAME` | `jahia` | Database name |
| `DB_USER` | `jahia` | Database user |
| `DB_PASS` | *(required)* | Database password |
| `PROCESSING_SERVER` | `true` | Enable background processing (set false on non-primary cluster nodes) |
| `CLUSTER_ENABLED` | `false` | Enable Hazelcast clustering |
| `CLUSTER_NODES` | | Comma-separated `host:port` list of cluster peers |
| `MAX_RAM_PERCENTAGE` | `70` | Heap ceiling as % of container RAM |
| `EXTRA_JAVA_OPTS` | | Append arbitrary JVM flags |
| `JAHIA_DEPLOY_ON_STARTUP` | | Comma-separated module JAR paths to deploy at first boot |
| `OPERATING_MODE` | `development` | `development` or `production` |
| `MAIL_SERVER` | | SMTP URI e.g. `smtp://mail.example.com:25` |
| `MAIL_FROM` | | Sender address for system mail |
| `MAIL_ADMIN` | | Admin notification address |

### jCustomer / Unomi

| Variable | Default | Purpose |
|----------|---------|---------|
| `UNOMI_ROOT_PASSWORD` | *(required)* | Admin password |
| `UNOMI_ELASTICSEARCH_ADDRESSES` | `elasticsearch:9200` | ES cluster addresses |
| `UNOMI_CLUSTER_KUBERNETES` | `false` | Enable K8s cluster discovery |
| `UNOMI_THIRDPARTY_PROVIDER1_IPADDRESSES` | | Trusted IP ranges (for Jahia → Unomi calls) |
| `EXTRA_JAVA_OPTS` | | Append JVM flags |

### Elasticsearch (jahia image)

| Variable | Default | Purpose |
|----------|---------|---------|
| `discovery.type` | `single-node` | Use `zen` for multi-node |
| `ES_JAVA_OPTS` | `-Xms512m -Xmx512m` | Heap; set both to the same value |
| `xpack.security.enabled` | `false` | Enable TLS/auth |

## Volume layout inside the Jahia container

```
/var/jahia/           ← JAHIA_DATA_DIR (repo, bundles, configuration)
  jackrabbit/         ← JCR workspace
  modules/            ← Hot-deploy OSGi bundles (.jar)
  patches/            ← groovy/cfg/spring patches applied at startup
  digital-factory-config/  ← override jahia.properties / OSGi .cfg
/var/log/jahia/       ← log4j output files
  jahia.log
  access.log
  errors.log
```

## Useful run-time commands

```bash
# Tail combined Jahia logs
docker compose logs -f jahia

# Enter the container
docker compose exec jahia bash

# Karaf SSH console (password = same as JAHIA_ROOT_PASSWORD)
ssh -p 7770 karaf@localhost

# Force redeploy a module (drop the jar into hot-deploy)
docker compose cp my-module-1.0.jar jahia:/var/jahia/modules/

# Check resource usage
docker stats jahia mariadb

# One-shot health check
curl -u root:changeme http://localhost:8080/healthcheck?includeDetails=true
```

## Cluster (Hazelcast) quick checklist

1. Set `CLUSTER_ENABLED=true` on all nodes.
2. All nodes must share the same `DB_*` credentials pointing at the same DB.
3. `PROCESSING_SERVER=true` on exactly **one** node (the processing node).
4. Expose port `5900` between containers/pods for Hazelcast.
5. Mount a shared NFS or object-store volume for `/var/jahia/jackrabbit/repository/datastore`.
6. Verify membership: Karaf console → `cluster:info`.

## Kubernetes notes

- Use the official Jahia Helm chart (`jahia/jahia`) from `https://charts.jahia.com`.
- Set `jahia.processingServer.replicas=1` and `jahia.browsing.replicas=N`.
- Use a `ReadWriteMany` PVC (e.g. EFS / NFS) for the datastore.
- Liveness probe: `GET /healthcheck` — expect HTTP 200.
- Readiness probe: `GET /healthcheck?includeDetails=true` — parse `"status":"GREEN"`.
