# Jahia 8.2 — All Properties Reference

## Jahia Modes

| Property | Default | Description |
|---|---|---|
| `operatingMode` | `development` | `development`, `production`, or `distantPublicationServer` |
| `maintenanceMode` | `false` | Serve requests only to `/tools/` |
| `readOnlyMode` | `false` | Disable Page Composer, Content Editor, Studio |
| `sessionExpiryTime` | `60` | Session lifetime in minutes |

## Disk Paths

| Property | Default | Description |
|---|---|---|
| `jahiaVarDiskPath` | `${jahiaWebAppRoot}/../../../digital-factory-data` | Runtime data root |
| `tmpContentDiskPath` | `${jahia.data.dir}/content/tmp/` | Temporary files |
| `jahiaModulesDiskPath` | `${jahia.data.dir}/modules/` | Deployed modules |
| `jahiaImportsDiskPath` | `${jahia.data.dir}/imports/` | Import files |
| `modulesSourcesDiskPath` | `${jahia.data.dir}/sources/` | Module sources |
| `jahiaGeneratedResourcesDiskPath` | `${jahia.data.dir}/generated-resources/` | **Must be shared across cluster nodes** |
| `jahia.jackrabbit.home` | `${jahia.data.dir}/repository` | JCR repository home |
| `jahia.jackrabbit.datastore.path` | `${jahia.jackrabbit.home}/datastore` | JCR file datastore |

## URL Settings

| Property | Default | Description |
|---|---|---|
| `jahiaWebAppsDeployerBaseURL` | `http://127.0.0.1:8080/manager/html/` | WAR deployer URL |
| `permanentMoveForVanityURL` | `true` | HTTP 301 for vanity URLs |
| `urlRewriteSeoRulesEnabled` | `true` | Shorten content URLs in live mode |
| `urlRewriteRemoveCmsPrefix` | `true` | Remove `/cms` prefix when SEO rewriting active |
| `urlRewriteUseAbsoluteUrls` | `true` | Generate absolute URLs for cross-site links |
| `siteURLPortOverride` | `0` | Force port in generated URLs (0 = disabled) |
| `disableJsessionIdParameter` | `true` | Disable jsessionid URL tracking |
| `shiro.blockSemicolon` | `true` | Block requests with semicolon in URI |

## Authentication

| Property | Default | Description |
|---|---|---|
| `auth.container.enabled` | `false` | Container authentication valve |
| `auth.cookie.enabled` | `true` | Cookie-based authentication |
| `auth.cas.enabled` | `false` | CAS SSO authentication |
| `auth.cas.serverUrlPrefix` | `https://localhost:8443/cas` | CAS server base URL |
| `auth.cas.loginUrl` | `${auth.cas.serverUrlPrefix}/login` | CAS login redirect |
| `auth.cas.logoutUrl` | `${auth.cas.serverUrlPrefix}/logout` | CAS logout redirect |
| `auth.spnego.enabled` | `false` | SPNEGO (Windows-integrated auth) |

## Database

| Property | Default | Description |
|---|---|---|
| `db_script` | `derby_embedded.script` | Database initialization script |
| `hibernate.dialect` | `org.hibernate.dialect.DerbyTenSevenDialect` | Hibernate dialect |
| `org.quartz.driverDelegateClass` | `org.quartz.impl.jdbcjobstore.StdJDBCDelegate` | Quartz JDBC delegate |

## Search Index Consistency

| Property | Default | Description |
|---|---|---|
| `jahia.jackrabbit.searchIndex.enableConsistencyCheck` | `false` | Check index on startup |
| `jahia.jackrabbit.searchIndex.forceConsistencyCheck` | `false` | Check on every startup |
| `jahia.jackrabbit.searchIndex.autoRepair` | `true` | Auto-repair index errors |
| `jahia.jackrabbit.searchIndex.spellChecker.distanceImplementation` | `org.apache.lucene.search.spell.LevensteinDistance` | Spell checker algorithm |
| `jahia.jackrabbit.searchIndex.spellChecker.minimumScore` | `0.7` | Min similarity for suggestions |
| `jahia.jackrabbit.reindexOnStartup` | `false` | Full reindex on every startup |
| `queryApproxCountLimit` | `100` | Results before switching to approximate count |
| `jahia.jackrabbit.queryStatsEnabled` | `true` | Collect JCR query statistics |

## Workspace / JCR

| Property | Default | Description |
|---|---|---|
| `jahia.jackrabbit.consistencyCheck` | `false` | JCR workspace consistency check on startup |
| `jahia.jackrabbit.consistencyFix` | `false` | Auto-fix workspace issues |
| `repositoryDirectoryListingDisabled` | `false` | Disable `/repository` WebDAV listing |
| `repositoryAllowedNodeTypes` | `rep:root,jnt:virtualsitesFolder,jnt:virtualsite,jnt:folder,jnt:file` | Node types exposed via WebDAV |
| `jahia.publication.versionedTypes` | `jmix:editorialContent,jnt:file` | Types versioned on publish |
| `jahia.publication.excludedVersionedTypes` | _(empty)_ | Types excluded from versioning |
| `jahia.fileServlet.statisticsEnabled` | `false` | File access statistics |
| `jahia.jcr.maxNameSize` | `32` | Maximum node name length |
| `jahia.ui.contentTab.defaultSynchronizeNameWithTitle` | `true` | Auto-sync system name with title |
| `accessManagerPathPermissionCacheMaxSize` | `100` | JCR ACL cache size (LRU entries) |
| `jahia.jcr.nodesCachePerSessionMaxSize` | `100` | JCRNodeWrapper instance cache per session |

## Concurrent Processing / Performance

| Property | Default | Description |
|---|---|---|
| `maxModulesToGenerateInParallel` | `50` | Max threads for module generation |
| `moduleGenerationWaitTime` | `10000` | Wait before generation starts (ms) |
| `moduleGenerationThreadDumpToSystemOut` | `true` | Thread dump to stdout on timeout |
| `moduleGenerationTthreadDumpToFile` | `true` | Thread dump to file on timeout |
| `minimumIntervalAfterLastAutoThreadDump` | `60000` | Minimum interval between auto dumps (-1 = disabled) |
| `maxRequestRenderTime` | `60000` | Max render time per request in ms (-1/0 = no limit) |

## Error Handling

| Property | Default | Description |
|---|---|---|
| `dumpErrorsToFiles` | `true` | Write error dumps to files |
| `fileDumpMaxRegroupingOfPreviousException` | `500` | Max recurrences before new dump file |
| `useJstackForThreadDumps` | `false` | Use external `jstack` for thread dumps |
| `mail_maxRegroupingOfPreviousException` | `500` | Max recurrences before sending error email |
| `site.error.enabled` | `true` | Site-specific error document pages |

## Mass Imports

| Property | Default | Description |
|---|---|---|
| `expandImportedFilesOnDisk` | `false` | Expand binary files to disk before import |
| `expandImportedFilesOnDiskPath` | `/tmp` | Expansion target path |
| `importMaxBatch` | `500` | Node save rate during mass import |

## Publication

| Property | Default | Description |
|---|---|---|
| `jahia.publication.batchSize` | `100` | Publication batch size |
| `jahia.publicationManagerNodeTypes` | `jmix:publication,jmix:workflowRulesable,jnt:navMenuText` | Types shown in Publication Manager |
| `jahia.ui.pickers.suppressPublicationInfo` | `false` | Hide publication status in pickers |
| `area.auto.activated` | `true` | Auto-activate areas on first Page Composer display |

## User & Group Management

| Property | Default | Description |
|---|---|---|
| `userManagementUserNamePattern` | `[0-9a-z_A-Z\\-\\{\\}\\.@]+` | Username validation regex |
| `userManagementGroupNamePattern` | `[0-9a-z_A-Z\\-\\{\\}]+` | Group name validation regex |
| `jahiaJCRUserCountLimit` | `100` | Max JCR users loaded on Users page |
| `jahia.settings.userDisplayLimit` | `100` | Default user display count |
| `jahia.settings.memberDisplayLimit` | `100` | Default group member display count |
| `external.users.properties.readonly` | `j:firstName,j:lastName,j:organization,j:email` | Read-only properties for external users |
| `considerPreferredLanguageAfterLogin` | `false` | Switch to user's preferred language after login |

## Multilingual

| Property | Default | Description |
|---|---|---|
| `characterEncoding` | `UTF-8` | Response and email charset |
| `org.jahia.multilang.default_language_code` | `en` | Fallback language code |

## Image & Video

| Property | Default | Description |
|---|---|---|
| `imageService` | `ImageJAndJava2DImageService` | `ImageJAndJava2DImageService` or ImageMagick service |
| `imageMagickPath` | _(empty)_ | Path to ImageMagick and exiftools |
| `jahia.dm.thumbnails.video.enabled` | `false` | Auto video thumbnail generation |
| `jahia.dm.thumbnails.video.ffmpeg` | `ffmpeg` | Path to ffmpeg executable |

## Source Control & Build Tools

| Property | Default | Description |
|---|---|---|
| `gitPath` | `git` | Git executable |
| `svnPath` | `svn` | SVN executable |
| `mvnPath` | `mvn` | Maven executable |

## REST API

| Property | Default | Description |
|---|---|---|
| `jahia.find.disabled` | `true` | Disable the `/find` JCR REST API |
| `jahia.find.nodeTypesToSkip` | `jnt:passwordHistory,jnt:passwordHistoryEntry` | Node types excluded from find API |

## OSGi / Karaf

| Property | Default | Description |
|---|---|---|
| `karaf.remoteShell.port` | `8101` | Karaf SSH shell port (negative = disabled) |
| `karaf.remoteShell.host` | `127.0.0.1` | SSH shell bind address |

## UI / Contribution

| Property | Default | Description |
|---|---|---|
| `jahia.ui.dragAndDrop` | `DRAG_ZONE_IN_EDIT_AREA` | `ENABLED`, `DRAG_ZONE_IN_EDIT_AREA`, or `DISABLED` |
| `jahia.ui.createChildrenDirectButtons.limit` | `5` | Content type button threshold |
| `jahia.jquery.version` | `3.6.0` | jQuery version (`1.12.4`, `3.4.1`, `3.6.0`) |
| `jahia.jquery.plugins` | `jquery-migrate-3.0.1.min.js` | jQuery plugin mappings |
| `wip.checkbox.checked` | `false` | WIP checkbox state on Content Editor open |
| `loadJahiaContext` | `true` | Inject `initJahiaContext.js` in live mode |
| `protectedResourceAccessStrategy` | `silent` | `silent` (404) or `authorizationError` (401/403) |
| `useNewAggregateAndCacheImplementation` | `false` | Render chain V2 (true) vs V1 (false) |

## Tagging & Search

| Property | Default | Description |
|---|---|---|
| `tag.suggester.faceted` | `false` | Use faceted query for tag suggestions |

## Misc

| Property | Default | Description |
|---|---|---|
| `default_templates_set` | `sample-bootstrap-templates` | Default template set module |
| `jahiaFileUploadMaxSize` | `104857600` | Max file upload size in bytes (100 MB) |
| `jahia.atmosphere.heartbeat` | `60` | Session validity check interval (seconds) |
| `jahia.site.import.scanner.interval` | `30000` | Site import file watcher interval (ms) |
| `documentation.link` | `https://academy.jahia.com/...` | Documentation URL shown in admin UI |

---

## Cluster Settings — jahia.node.properties

| Property | Default | Description |
|---|---|---|
| `cluster.activated` | `false` | Enable cluster communication |
| `cluster.node.serverId` | `dx-<uuid>` | Unique node identifier |
| `processingServer` | `true` | Run background jobs (only ONE node) |
| `cluster.tcp.bindAddress` | _(empty)_ | JGroups bind address (empty = auto-detect) |
| `cluster.tcp.bindPort` | `7870` | JGroups communication port |
| `cluster.hazelcast.bindPort` | `7860` | Hazelcast bundle deployment port |

---

## OSGi Module Config Files

### jContent — `org.jahia.modules.jcontent.cfg`

| Property | Default | Description |
|---|---|---|
| `showPageComposer` | `false` | Show Page Composer inside jContent |

### Content Editor — `org.jahia.modules.contentEditor.cfg`

| Property | Default | Description |
|---|---|---|
| `createChildrenDirectButtons.limit` | `5` | Content type button threshold |
