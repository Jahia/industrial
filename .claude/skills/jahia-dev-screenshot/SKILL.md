---
name: jahia-dev-screenshot
description: Takes screenshots of a reference URL and the local Jahia render for visual comparison. Use before building a view (inspiration) and after (validation).
---

# Skill: jahia-dev-screenshot

Takes screenshots for two purposes:
1. **Reference** — capture an existing site as a visual spec before building
2. **Result** — capture the local Jahia render after building to compare

---

## Step 1 — Detect screenshot tool

Check what is available:

```bash
# Playwright (preferred)
npx playwright --version 2>/dev/null

# Puppeteer
node -e "require('puppeteer'); console.log('ok')" 2>/dev/null

# System Chrome/Chromium
which google-chrome || which chromium || which chromium-browser 2>/dev/null
```

Use the first one that works. If none is available, ask the user:

> No screenshot tool found. Which would you like to install?
> - `npm install -g playwright` then `npx playwright install chromium`
> - `npm install puppeteer` (downloads Chromium automatically)
> - I'll take the screenshots manually and paste them in

If the user chooses manual, skip to Step 4 and ask them to paste the screenshots.

---

## Step 2 — Take reference screenshot

Ask the user for the reference URL if not already provided.

Create the output directory:
```bash
mkdir -p /tmp/jahia-screenshots
```

### With Playwright:
```bash
npx playwright screenshot \
  --browser chromium \
  --full-page \
  "<REFERENCE_URL>" \
  /tmp/jahia-screenshots/reference.png
```

### With Puppeteer (Node.js one-liner):
```bash
node -e "
const puppeteer = require('puppeteer');
(async () => {
  const browser = await puppeteer.launch({ args: ['--no-sandbox'] });
  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 900 });
  await page.goto('<REFERENCE_URL>', { waitUntil: 'networkidle2' });
  await page.screenshot({ path: '/tmp/jahia-screenshots/reference.png', fullPage: true });
  await browser.close();
})();
"
```

After capturing, **view the screenshot** to use it as visual context:

```
view /tmp/jahia-screenshots/reference.png
```

Describe the key design elements you observe:
- Layout structure (hero, grid, sidebar, etc.)
- Color palette (dominant, accent, background)
- Typography (heading sizes, font weight)
- Component anatomy (what sub-elements make it up)

Share this description with the user before proceeding to build.

---

## Step 3 — Take result screenshot (after building)

Once the view is built and deployed (`yarn build` + `yarn jahia-deploy`), capture the Jahia render.

Ask the user for the Jahia page URL, or construct it:
- Default: `http://localhost:8080/cms/render/default/en/sites/<siteName>/home.html`
- Or ask: "What is the URL of the page where the component is placed?"

Jahia requires authentication. Use the `--auth` header or log in first:

### With Playwright:
```bash
npx playwright screenshot \
  --browser chromium \
  --full-page \
  "http://localhost:8080/cms/render/default/en/sites/<siteName>/home.html" \
  /tmp/jahia-screenshots/result.png
```

> Note: if the page requires login, authenticate first:
> ```bash
> node -e "
> const puppeteer = require('puppeteer');
> (async () => {
>   const browser = await puppeteer.launch({ args: ['--no-sandbox'] });
>   const page = await browser.newPage();
>   await page.setViewport({ width: 1440, height: 900 });
>   await page.goto('http://localhost:8080/cms/login', { waitUntil: 'networkidle2' });
>   await page.type('#username', 'root');
>   await page.type('#password', 'root1234');
>   await Promise.all([page.waitForNavigation(), page.keyboard.press('Enter')]);
>   await page.goto('<PAGE_URL>', { waitUntil: 'networkidle2' });
>   await page.screenshot({ path: '/tmp/jahia-screenshots/result.png', fullPage: true });
>   await browser.close();
> })();
> "
> ```

After capturing, **view the screenshot**:

```
view /tmp/jahia-screenshots/result.png
```

---

## Step 4 — Compare and report gaps

View both screenshots and compare them side by side (or sequentially).

Report gaps to the user:

```
## Visual Comparison

### Reference: <URL>
[description of reference]

### Result: http://localhost:8080/...
[description of result]

### Gaps
- [ ] Background color differs (reference: dark navy, result: white)
- [ ] Hero text not centered
- [ ] CTA button missing border-radius
- [ ] Font size smaller than reference

### Suggested fixes
...
```

Ask: **"Would you like me to fix these gaps?"**

If yes, update the view's `.tsx` and `.module.css` files using `/jahia-dev-create-view` guidance, rebuild, and re-screenshot to verify.

---

## Integration points

This skill is called from:
- `/jahia-dev-build-component` — Step 0 (optional reference) and Step 4 (result check)
- `/jahia-dev-create-view` — Step 0 (optional reference) and after deploy

---

## References

- Playwright CLI: https://playwright.dev/docs/cli
- Puppeteer: https://pptr.dev
