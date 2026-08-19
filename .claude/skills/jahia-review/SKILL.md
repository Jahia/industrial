---
name: jahia-review
description: Full quality review of a Jahia JavaScript module — runs code review and live site review in parallel via subagents. Use after deploying to get a complete pass/fail signal before finalizing work.
allowed-tools: Agent, Bash, Read
---

# Skill: jahia-review

Runs both `/jahia-review-code` and `/jahia-review-site` in parallel via independent subagents, then consolidates their findings. Use this before writing `pages.json` or marking work complete.

---

## Step 1 — Collect live URLs

Read `pages.json` to get the list of live page URLs:

```bash
cat pages.json
```

---

## Step 2 — Spawn review subagents in parallel

Invoke two subagents simultaneously:

**Subagent A — code review:**
> Invoke `/jahia-review-code` on this module. Scan all CND files, TypeScript views, and page templates. Report every issue found (critical, warning, suggestion) with file locations and fix guidance.

**Subagent B — site review:**
> Invoke `/jahia-review-site` against the URLs in `pages.json`. Run the review script and report every a11y and SEO violation found.

---

## Step 3 — Consolidate and report

Combine findings from both subagents into a single report:

```
## Review Results

### Code (jahia-review-code)
[findings from subagent A]

### Site (jahia-review-site)
[findings from subagent B]

### Verdict
✅ PASS — no violations found.
❌ FAIL — N issue(s) must be fixed before finalizing.
```

---

## Step 4 — Fix and iterate

If any violations were found:

1. Fix every reported issue
2. Redeploy: `yarn build && yarn jahia-deploy`
3. Re-run `/jahia-review` until the verdict is ✅ PASS

Only proceed (write `pages.json`, mark work complete) once the review passes.
