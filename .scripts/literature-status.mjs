#!/usr/bin/env node
import { existsSync, readFileSync } from "node:fs";

const catalogPath = "literature/catalog.jsonl";
const readingListPath = "literature/reading_list.md";
const limitArg = process.argv.find((arg) => arg.startsWith("--limit="));
const limit = limitArg ? Number(limitArg.split("=")[1]) : 8;

function readCatalog(path) {
  if (!existsSync(path)) return [];
  return readFileSync(path, "utf8")
    .split(/\n/)
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line, index) => {
      try {
        return JSON.parse(line);
      } catch (error) {
        throw new Error(`${path}:${index + 1}: ${error.message}`);
      }
    });
}

function countBy(records, getter) {
  const counts = new Map();
  records.forEach((record) => {
    const key = getter(record) || "unknown";
    counts.set(key, (counts.get(key) ?? 0) + 1);
  });
  return [...counts.entries()]
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([key, value]) => `${key}: ${value}`)
    .join(", ");
}

function paperLabel(record) {
  const authors = record.authors?.length ? record.authors[0] : "unknown author";
  const extra = record.authors?.length > 1 ? " et al." : "";
  return `${record.title} (${authors}${extra}, ${record.year ?? "n.d."})`;
}

const records = readCatalog(catalogPath);
const unread = records.filter((record) => record.status === "unread");
const read = records.filter((record) => record.status === "read");
const skipped = records.filter((record) => record.status === "skipped");
const failedFetch = records.filter((record) => record.fetch?.status === "failed");
const pendingFetch = records.filter((record) => record.fetch?.status === "pending");
const readMissingSourceNote = read.filter((record) => !record.source_note);

console.log("## Literature Status");
if (records.length === 0) {
  console.log(`- Catalog: no records found at \`${catalogPath}\`.`);
  process.exit(0);
}

console.log(`- Catalog: ${records.length} papers (${read.length} read, ${unread.length} unread, ${skipped.length} skipped).`);
console.log(`- Status breakdown: ${countBy(records, (record) => record.status)}.`);
console.log(`- Fetch breakdown: ${countBy(records, (record) => record.fetch?.status)}.`);
if (failedFetch.length || pendingFetch.length) {
  const blocked = [...pendingFetch, ...failedFetch].map(paperLabel).slice(0, limit);
  console.log(`- Acquisition attention: ${blocked.join("; ")}.`);
}
if (readMissingSourceNote.length) {
  const missing = readMissingSourceNote.map(paperLabel).slice(0, limit);
  console.log(`- Read papers missing durable source notes (${readMissingSourceNote.length}): ${missing.join("; ")}.`);
}
if (unread.length) {
  console.log(`- Unread queue (${unread.length}):`);
  unread.slice(0, limit).forEach((record) => {
    console.log(`  - ${paperLabel(record)}`);
  });
  if (unread.length > limit) {
    console.log(`  - ... ${unread.length - limit} more`);
  }
}
if (existsSync(readingListPath)) {
  console.log(`- Linked human view: \`${readingListPath}\`.`);
}
