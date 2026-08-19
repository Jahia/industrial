---
name: jahia-review-site
description: Scores live pages for accessibility and SEO.
allowed-tools: Bash, Read, Write, Edit
---

# Skill: jahia-review-site

Reads URLs from `pages-to-review.json`, runs automated a11y and SEO checks, and — only if all checks pass — writes `pages.json`. Exits non-zero without writing `pages.json` if any violation is found.

**A11y:** axe-core full ruleset (WCAG + best-practice) — any violation fails.

**SEO:** Lighthouse SEO category — any failing audit fails. Violations reported by audit ID (e.g. `document-title`, `meta-description`, `hreflang`, `is-crawlable`, `link-text`, `image-alt`).

---

## Step 1 — Ensure tooling is installed

```bash
node -e "require('@axe-core/playwright'); require('playwright')" 2>/dev/null || \
  npm install --no-save @axe-core/playwright playwright && npx playwright install chromium --with-deps
```

---

## Step 2 — Run the review

```bash
SCRIPT=$(find .claude .agents -name "review-pages.mjs" 2>/dev/null | head -1)
node "$SCRIPT" 2>&1 | tee /tmp/site-review.txt
```

---

## Step 3 — Interpret and fix

The script exits 1 if any page has any a11y violation or any failing Lighthouse SEO audit.

After fixing, redeploy and re-run:

```bash
yarn build && yarn jahia-deploy
node "$SCRIPT"
```

Iterate until the script exits 0 and `pages.json` is written.

---

## Validation checklist
- [ ] Script exits 0 (zero a11y violations, zero failing SEO audits)
- [ ] `pages.json` exists (created by the script on pass)
