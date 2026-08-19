#!/usr/bin/env node
import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, resolve } from "node:path";

function findCndFiles(dir) {
  const results = [];
  function walk(current) {
    try {
      const stat = statSync(current);
      if (stat.isFile()) {
        if (current.endsWith(".cnd")) results.push(current);
        return;
      }
      for (const entry of readdirSync(current, { withFileTypes: true })) {
        if (entry.isDirectory() && entry.name !== "node_modules" && entry.name !== ".git") {
          walk(join(current, entry.name));
        } else if (entry.isFile() && entry.name.endsWith(".cnd")) {
          results.push(join(current, entry.name));
        }
      }
    } catch {
      // skip unreadable paths
    }
  }
  walk(dir);
  return results;
}

function checkFile(filePath, content) {
  const issues = [];
  const lines = content.split("\n");

  lines.forEach((line, i) => {
    const lineNum = i + 1;
    const trimmed = line.trim();
    if (trimmed.startsWith("//") || trimmed.startsWith("<")) return;

    // rawStringLink
    if (
      /^-\s+\w*(Url|Href|Link)\s+\(string[,)]/i.test(trimmed) &&
      !/choicelist\[linkTypeInitializer\]/.test(trimmed)
    ) {
      const propName = trimmed.match(/^-\s+(\w+)/)?.[1] ?? "unknown";
      issues.push({
        file: filePath, line: lineNum,
        pattern: "rawStringLink",
        message: `"${propName}" uses (string) for a link/url — use choicelist[linkTypeInitializer]`,
        fix: "Replace with: - j:linkType (string, choicelist[linkTypeInitializer]) mandatory",
      });
    }

    // rawTitleProp
    if (/^-\s+(title|heroTitle|pageTitle|sectionTitle)\s+\(string[,)]/i.test(trimmed)) {
      const propName = trimmed.match(/^-\s+(\w+)/)?.[1] ?? "unknown";
      issues.push({
        file: filePath, line: lineNum,
        pattern: "rawTitleProp",
        message: `"${propName}" is a plain string — extend mix:title instead`,
        fix: "Add mix:title to the type declaration and remove this property",
      });
    }

    // weakrefNoConstraint: (weakreference) with no < constraint on same line
    if (/\(weakreference[,)]/.test(trimmed) && !/<\s*\S/.test(trimmed)) {
      issues.push({
        file: filePath, line: lineNum,
        pattern: "weakrefNoConstraint",
        message: "Unconstrained weakreference — add a type constraint",
        fix: "Add e.g. (weakreference, picker[type='image']) < jmix:image",
      });
    }

    // weakrefWrongConstraint
    if (/< ['"]jnt:file['"]/.test(trimmed)) {
      issues.push({
        file: filePath, line: lineNum,
        pattern: "weakrefWrongConstraint",
        message: "< 'jnt:file' (quoted) does not enforce image type",
        fix: "Replace with < jmix:image for images",
      });
    }

    // missingI18n: user-visible string without i18n
    if (
      /^-\s+\w+\s+\(string(,\s*(textarea|richtext))?[,)]/.test(trimmed) &&
      !/ i18n/.test(trimmed) &&
      !/^-\s+j:/.test(trimmed) &&
      /(title|text|label|description|subtitle|caption|alt|heading|summary|excerpt|body)/i.test(trimmed)
    ) {
      issues.push({
        file: filePath, line: lineNum,
        pattern: "missingI18n",
        message: "User-visible string property missing i18n",
        fix: "Add i18n keyword after the type declaration",
      });
    }

    // directDroppable: concrete type (not mixin) extending jmix:droppableContent
    if (trimmed.startsWith("[") && /jmix:droppableContent/.test(trimmed) && !/\bmixin\b/.test(trimmed)) {
      issues.push({
        file: filePath, line: lineNum,
        pattern: "directDroppable",
        message: "Extends jmix:droppableContent directly — always extend the module component mixin",
        fix: "Replace jmix:droppableContent with nsmix:component (or your module's equivalent)",
      });
    }

    // studioOnly
    if (/jmix:studioOnly/.test(trimmed)) {
      issues.push({
        file: filePath, line: lineNum,
        pattern: "studioOnly",
        message: "jmix:studioOnly causes silent rendering issues",
        fix: "Replace with jmix:hiddenType",
      });
    }

    // redundantImageAlt: imageAlt as plain string — image node already has jcr:title
    if (/^-\s+imageAlt\s+\(string[,)]/i.test(trimmed)) {
      issues.push({
        file: filePath, line: lineNum,
        pattern: "redundantImageAlt",
        message: '"imageAlt" is redundant — the image node\'s jcr:title (mix:title) serves as alt text',
        fix: 'Remove imageAlt. In the view, use image.getPropertyAsString("jcr:title") for alt text',
      });
    }

    // missingRatingConstraint: rating (long) without a range constraint
    if (/^-\s+rating\s+\(long[,)]/i.test(trimmed) && !/<\s*"?\[/.test(trimmed)) {
      issues.push({
        file: filePath, line: lineNum,
        pattern: "missingRatingConstraint",
        message: '"rating" (long) has no range constraint — unconstrained ratings cause data integrity issues',
        fix: 'Add: < "[1,5]"',
      });
    }
  });

  // singleHardcodedCta: check whole-file type blocks
  const typeBlocks = content.split(/(?=^\[)/m);
  for (const block of typeBlocks) {
    if (!block.trim().startsWith("[")) continue;
    const hasCtaLabel = /^\s*-\s+cta(Text|Label|ButtonText|ButtonLabel)\s+\(/im.test(block);
    const hasCtaLink = /^\s*-\s+cta(Link|Url|Href|ButtonLink|ButtonUrl)\s+\(/im.test(block);
    const hasChildNodes = /^\s*\+\s+/.test(block);
    if (hasCtaLabel && hasCtaLink && !hasChildNodes) {
      const typeName = block.match(/^\[(\S+)\]/m)?.[1] ?? "unknown";
      const typeLineIdx = lines.findIndex((l) => l.includes(`[${typeName}]`));
      issues.push({
        file: filePath,
        ...(typeLineIdx >= 0 ? { line: typeLineIdx + 1 } : {}),
        pattern: "singleHardcodedCta",
        message: `${typeName}: flat ctaText+ctaLink forces a single CTA — model as child nodes`,
        fix: "Remove ctaText and ctaLink. Add: + * (ns:cta). Create a [ns:cta] type with label + j:linkType",
      });
    }
  }

  return issues;
}

export function checkCndFiles(projectDir) {
  const files = findCndFiles(projectDir);
  const allIssues = [];

  for (const file of files) {
    try {
      const content = readFileSync(file, "utf-8");
      allIssues.push(...checkFile(file, content));
    } catch {
      // skip unreadable files
    }
  }

  return { score: Math.exp(-allIssues.length * 0.5), issues: allIssues, filesChecked: files.length };
}

if (import.meta.main) {
  const targetPath = resolve(process.argv[2] ?? ".");
  const { score, issues, filesChecked } = checkCndFiles(targetPath);

  console.log(`\nCND Review: ${filesChecked} file${filesChecked !== 1 ? "s" : ""} checked\n`);

  if (issues.length > 0) {
    console.log(`ISSUES (${issues.length}):`);
    for (const issue of issues) {
      const loc = issue.line ? `${issue.file}:${issue.line}` : issue.file;
      console.log(`  [${issue.pattern}] ${loc}`);
      console.log(`    ${issue.message}`);
      console.log(`    Fix: ${issue.fix}`);
    }
    console.log();
  }

  const verdict = issues.length > 0 ? "FAIL" : "PASS";
  console.log(`Result: ${verdict} (score=${score.toFixed(2)})`);
  process.exit(issues.length > 0 ? 1 : 0);
}
