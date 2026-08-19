#!/usr/bin/env node
// Reads URLs from pages-to-review.json, runs a11y (axe-core) + SEO (Lighthouse) checks.
// On pass: writes pages.json and exits 0. On fail: exits 1 without writing pages.json.
import { chromium } from "playwright";
import { AxeBuilder } from "@axe-core/playwright";
import lighthouse from "lighthouse";
import { readFileSync, writeFileSync } from "fs";

const SCORED_MODES = new Set(["binary", "numeric"]);

const draft = readFileSync("pages-to-review.json", "utf-8");
const urls = JSON.parse(draft);
const port = 9222;
const browser = await chromium.launch({
  args: ["--no-sandbox", `--remote-debugging-port=${port}`],
});
const context = await browser.newContext();
const page = await context.newPage();

const results = [];

for (const url of urls) {
  process.stdout.write(`\nChecking ${url} … `);
  await page.goto(url, { waitUntil: "networkidle", timeout: 30_000 });

  // A11y
  const axe = await new AxeBuilder({ page }).analyze();

  // SEO — Lighthouse reuses the already-open browser via the debug port
  const lhr = (await lighthouse(url, { port, output: "json", onlyCategories: ["seo"] }))?.lhr;
  const seoViolations = lhr
    ? Object.values(lhr.audits).filter(
        a => SCORED_MODES.has(a.scoreDisplayMode) && a.score !== null && a.score < 1,
      )
    : [];

  process.stdout.write(`a11y=${axe.violations.length} violation(s) seo=${seoViolations.length} violation(s)\n`);
  results.push({ url, violations: axe.violations, seoViolations });
}

await browser.close();

// ── Report ──────────────────────────────────────────────────────────────────
let failed = false;

for (const r of results) {
  const pageOk = r.violations.length === 0 && r.seoViolations.length === 0;
  if (!pageOk) failed = true;

  console.log(`\n${"─".repeat(70)}`);
  console.log(`${pageOk ? "✅" : "❌"} ${r.url}`);

  for (const v of r.violations) {
    console.log(`   ❌ A11y [${v.id}] — ${v.description} (${v.nodes.length} node${v.nodes.length !== 1 ? "s" : ""})`);
    for (const node of v.nodes.slice(0, 3)) {
      console.log(`        ${node.html.slice(0, 100)}`);
    }
  }

  for (const a of r.seoViolations) {
    console.log(`   ❌ SEO  [${a.id}] — ${a.title}`);
    if (a.description) console.log(`        ${a.description.slice(0, 120)}`);
  }
}

console.log(`\n${"═".repeat(70)}`);
if (failed) {
  console.log("\n❌ FAIL — fix the issues above, redeploy, and re-run.");
  process.exit(1);
} else {
  writeFileSync("pages.json", draft);
  console.log("\n✅ PASS — pages.json written.");
  process.exit(0);
}
