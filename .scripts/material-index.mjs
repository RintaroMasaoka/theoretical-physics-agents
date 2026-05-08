#!/usr/bin/env node
import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import path from "node:path";

const args = process.argv.slice(2);
const formatArg = args.find((arg) => arg.startsWith("--format="));
const format = formatArg ? formatArg.split("=")[1] : "markdown";
const roots = args.filter((arg) => !arg.startsWith("--"));
const targets = roots.length ? roots : ["research"];

function usage() {
  console.log("Usage: node .scripts/material-index.mjs [--format=markdown|json] <node-or-material-dir> [...]");
  console.log("Summarizes research/**/_materials Markdown frontmatter/descriptions without printing material bodies.");
}

if (args.includes("--help") || args.includes("-h")) {
  usage();
  process.exit(0);
}

if (!["markdown", "json"].includes(format)) {
  throw new Error(`Unsupported format: ${format}`);
}

function isMaterialMarkdown(filePath) {
  return filePath.endsWith(".md") && filePath.split(path.sep).includes("_materials");
}

function walk(dirPath, files = []) {
  if (!existsSync(dirPath)) return files;
  const stat = statSync(dirPath);
  if (stat.isFile()) {
    if (isMaterialMarkdown(dirPath)) files.push(dirPath);
    return files;
  }
  if (!stat.isDirectory()) return files;
  for (const entry of readdirSync(dirPath, { withFileTypes: true })) {
    if (entry.name === "archive" || entry.name === "__pycache__" || entry.name === ".ipynb_checkpoints") continue;
    const child = path.join(dirPath, entry.name);
    if (entry.isDirectory()) {
      walk(child, files);
    } else if (isMaterialMarkdown(child)) {
      files.push(child);
    }
  }
  return files;
}

function parseFrontmatter(text) {
  if (!text.startsWith("---\n")) return { data: {}, raw: "", body: text };
  const end = text.indexOf("\n---", 4);
  if (end === -1) return { data: {}, raw: "", body: text };
  const raw = text.slice(4, end).trim();
  const body = text.slice(text.indexOf("\n", end + 1) + 1);
  const data = {};
  for (const line of raw.split(/\n/)) {
    const match = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
    if (!match) continue;
    const [, key, value] = match;
    data[key] = value.replace(/^["']|["']$/g, "");
  }
  return { data, raw, body };
}

function extractSection(body, names) {
  const lines = body.split(/\n/);
  for (let i = 0; i < lines.length; i += 1) {
    const heading = lines[i].match(/^#{1,3}\s+(.+?)\s*$/);
    if (!heading) continue;
    const normalized = heading[1].trim().toLowerCase();
    if (!names.includes(normalized)) continue;
    const collected = [];
    for (let j = i + 1; j < lines.length; j += 1) {
      if (/^#{1,3}\s+/.test(lines[j])) break;
      const trimmed = lines[j].trim();
      if (trimmed) collected.push(trimmed);
      if (collected.join(" ").length > 360) break;
    }
    if (collected.length) return collected.join(" ");
  }
  return "";
}

function firstParagraph(body) {
  const withoutTitle = body.replace(/^#\s+.+\n+/, "");
  const paragraph = withoutTitle
    .split(/\n\s*\n/)
    .map((part) => part.trim())
    .find((part) => part && !part.startsWith("#") && !part.startsWith("```"));
  return paragraph ? paragraph.replace(/\s+/g, " ").slice(0, 360) : "";
}

function classify(filePath, frontmatter) {
  if (frontmatter.material_kind) return frontmatter.material_kind;
  const parts = filePath.split(path.sep);
  if (parts.includes("analyses")) return "analysis";
  if (parts.includes("src")) return "script-companion";
  if (parts.includes("lib")) return "lib-note";
  return "material-note";
}

function summarize(filePath) {
  const text = readFileSync(filePath, "utf8");
  const { data, body } = parseFrontmatter(text);
  const description = data.description
    || data.summary
    || data.purpose
    || extractSection(body, ["description", "summary", "purpose"])
    || firstParagraph(body);
  return {
    path: filePath,
    material_kind: classify(filePath, data),
    description: description || "(no description found)",
    frontmatter: data,
  };
}

const files = [...new Set(targets.flatMap((target) => walk(target)))].sort((a, b) => a.localeCompare(b));
const summaries = files.map(summarize);

if (format === "json") {
  console.log(JSON.stringify(summaries, null, 2));
  process.exit(0);
}

console.log("## Material Index");
if (summaries.length === 0) {
  console.log("- No `_materials/**/*.md` files found for the requested path(s).");
  process.exit(0);
}

for (const item of summaries) {
  console.log(`- \`${item.path}\``);
  console.log(`  - kind: ${item.material_kind}`);
  console.log(`  - description: ${item.description}`);
  const keys = Object.keys(item.frontmatter).filter((key) => !["description", "summary", "purpose"].includes(key));
  if (keys.length) {
    console.log(`  - frontmatter: ${keys.map((key) => `${key}=${item.frontmatter[key]}`).join("; ")}`);
  }
}
