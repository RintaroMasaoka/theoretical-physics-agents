#!/usr/bin/env node
/**
 * Render .md files from templates + config.yaml.
 *
 * Usage:
 *   node .scripts/configure.mjs                         Apply templates for all targets (default)
 *   node .scripts/configure.mjs --target claude        Apply templates for Claude
 *   node .scripts/configure.mjs --target codex         Apply templates for Codex
 *   node .scripts/configure.mjs --target all           Apply templates for all targets
 *   node .scripts/configure.mjs --dry-run              Show what would change without writing files
 *   node .scripts/configure.mjs --check                Validate config and templates (no writes)
 *
 * Source of truth:
 *   Config values:  target-defined config path (shared today via .claude/config/config.yaml)
 *   Prompt content: .templates/**\/*.src.md
 * Generated (do not edit directly — overwritten on each run):
 *   .claude/**\/*.md
 *   .codex/**\/*.md
 */

import { readFileSync, writeFileSync, mkdirSync, existsSync, readdirSync, statSync } from "fs";
import { join, dirname, relative } from "path";
import { fileURLToPath } from "url";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const SRC_DIR = join(ROOT, ".templates");
const DEFAULT_CONFIG_PATH = join(ROOT, ".claude", "config", "config.yaml");

const TARGETS = {
  claude: {
    name: "claude",
    outputDir: join(ROOT, ".claude"),
    configSourcePath: DEFAULT_CONFIG_PATH,
    configOutputPath: DEFAULT_CONFIG_PATH,
    rootInstructionFileName: "CLAUDE.md",
  },
  codex: {
    name: "codex",
    outputDir: join(ROOT, ".codex"),
    configSourcePath: DEFAULT_CONFIG_PATH,
    configOutputPath: join(ROOT, ".codex", "config", "config.yaml"),
    rootInstructionFileName: "AGENTS.md",
  },
};

function buildRuntimeConfig(target) {
  const rootDir = relative(ROOT, target.outputDir).replace(/\\/g, "/");
  const instructionFile = `${rootDir}/${target.rootInstructionFileName}`;

  return {
    runtime: {
      target: target.name,
      root_dir: rootDir,
      instruction_file: instructionFile,
      instruction_file_name: target.rootInstructionFileName,
      common_file: `${rootDir}/common.md`,
      notes_syntax_file: `${rootDir}/notes-syntax.md`,
      research_tree_file: `${rootDir}/research-tree.md`,
      agents_dir: `${rootDir}/agents`,
      skills_dir: `${rootDir}/skills`,
      config_file: relative(ROOT, target.configOutputPath).replace(/\\/g, "/"),
      resume_hook_reference:
        target.name === "claude"
          ? "the `SessionStart` hook in `.claude/settings.json`"
          : "the runtime's session-start hook (if configured)",
    },
  };
}

// ── CLI parsing ──────────────────────────────────────────────────────

function parseArgs(argv) {
  const options = {
    mode: "apply",
    target: "all",
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];

    if (arg === "--help") {
      options.help = true;
      continue;
    }

    if (arg === "--dry-run") {
      options.mode = "dry-run";
      continue;
    }

    if (arg === "--check") {
      options.mode = "check";
      continue;
    }

    if (arg === "--target") {
      const value = argv[i + 1];
      if (!value) {
        throw new Error("Missing value for --target");
      }
      options.target = value;
      i += 1;
      continue;
    }

    if (arg.startsWith("--target=")) {
      options.target = arg.slice("--target=".length);
      continue;
    }

    throw new Error(`Unknown argument: ${arg}`);
  }

  return options;
}

function printHelp() {
  console.log("Usage: node .scripts/configure.mjs [--target claude|codex|all] [--dry-run | --check]");
}

function resolveTargets(targetName) {
  if (targetName === "all") {
    return Object.values(TARGETS);
  }

  if (!(targetName in TARGETS)) {
    throw new Error(`Unknown target: ${targetName}`);
  }

  return [TARGETS[targetName]];
}

// ── YAML parsing ─────────────────────────────────────────────────────

function parseConfig(path) {
  const lines = readFileSync(path, "utf-8").split("\n");
  const config = {};
  const stack = []; // [{indent, key}]

  for (const raw of lines) {
    const stripped = raw.replace(/\n$/, "");
    if (/^\s*#/.test(stripped) || !stripped.trim()) continue;

    const indent = stripped.length - stripped.trimStart().length;

    while (stack.length > 0 && stack[stack.length - 1].indent >= indent) {
      stack.pop();
    }

    const prefix = stack.map((s) => s.key).join(".") + (stack.length ? "." : "");
    const line = stripped.trim();
    const colon = line.indexOf(":");
    if (colon === -1) continue;

    const key = line.slice(0, colon);
    if (!/^[a-zA-Z_][\w-]*$/.test(key)) continue;

    const rest = line.slice(colon + 1).trim();

    if (rest === "") {
      stack.push({ indent, key });
      continue;
    }

    let val = rest.replace(/\s+#.*$/, "");
    if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
      val = val.slice(1, -1);
    }
    config[prefix + key] = val;
  }

  return config;
}

function flattenObject(input, prefix = "") {
  const flat = {};

  for (const [key, value] of Object.entries(input)) {
    const nextKey = prefix ? `${prefix}.${key}` : key;
    if (value && typeof value === "object" && !Array.isArray(value)) {
      Object.assign(flat, flattenObject(value, nextKey));
    } else {
      flat[nextKey] = String(value);
    }
  }

  return flat;
}

function buildRenderConfig(target) {
  const config = parseConfig(target.configSourcePath);
  const runtime = flattenObject(buildRuntimeConfig(target));
  return { ...config, ...runtime };
}

// ── Template rendering ───────────────────────────────────────────────

function findPlaceholders(template) {
  const cleaned = template.replace(/`[^`]*`/g, "");
  const keys = new Set();
  for (const m of cleaned.matchAll(/\{\{\s*([\w.]+)\s*\}\}/g)) {
    keys.add(m[1]);
  }
  return keys;
}

function render(template, config) {
  return template.replace(/\{\{\s*([\w.]+)\s*\}\}/g, (match, key) => {
    return key in config ? config[key] : match;
  });
}

// ── Recursive glob for .src.md files ────────────────────────────────

function findTemplates(dir) {
  const results = [];
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) {
      results.push(...findTemplates(full));
    } else if (entry.endsWith(".src.md")) {
      results.push(full);
    }
  }
  return results.sort();
}

function resolveOutputPath(target, templatePath) {
  const rel = relative(SRC_DIR, templatePath);
  const outRel = rel.replace(/\.src\.md$/, ".md");

  if (outRel === "AGENTS.md" || outRel === "CLAUDE.md") {
    return join(target.outputDir, target.rootInstructionFileName);
  }

  return join(target.outputDir, outRel);
}

function syncConfigMirror(target, mode) {
  const src = target.configSourcePath;
  const dst = target.configOutputPath;

  if (src === dst) {
    return;
  }

  const content = readFileSync(src, "utf-8");

  if (mode === "dry-run") {
    let marker = " (new)";
    if (existsSync(dst)) {
      marker = readFileSync(dst, "utf-8") === content ? " (unchanged)" : " (changed)";
    }
    console.log(`  ${relative(ROOT, dst)}${marker}`);
    return;
  }

  mkdirSync(dirname(dst), { recursive: true });
  writeFileSync(dst, content);
  console.log(`  ${relative(ROOT, dst)}`);
}

function printConfig(config) {
  console.log("Config:");
  for (const key of Object.keys(config).sort()) {
    console.log(`  ${key} = ${config[key]}`);
  }
  console.log();
}

function runCheck(target, config) {
  const warnings = [];
  const allPlaceholders = new Set();
  const templateKeys = {};
  const forbiddenRef = target.name === "claude" ? ".codex/" : ".claude/";

  for (const tmplPath of findTemplates(SRC_DIR)) {
    const rel = relative(ROOT, tmplPath);
    const content = readFileSync(tmplPath, "utf-8");
    const keys = findPlaceholders(content);
    templateKeys[rel] = keys;
    for (const key of keys) allPlaceholders.add(key);

    const rendered = render(content, config);
    if (rendered.includes(forbiddenRef)) {
      warnings.push(`Cross-target reference '${forbiddenRef}' present after rendering ${rel}`);
    }
  }

  for (const key of Object.keys(config).sort()) {
    if (key.startsWith("runtime.")) {
      continue;
    }
    if (!allPlaceholders.has(key)) {
      warnings.push(`Unused config key: '${key}' (not referenced in any template)`);
    }
  }

  for (const [path, keys] of Object.entries(templateKeys).sort()) {
    for (const key of [...keys].sort()) {
      if (!(key in config)) {
        warnings.push(`Unresolved placeholder: '{{ ${key} }}' in ${path}`);
      }
    }
  }

  if (warnings.length > 0) {
    console.log("Warnings:");
    for (const warning of warnings) console.log(`  ⚠ ${warning}`);
    return false;
  }

  console.log(`✓ ${target.name}: all config keys are used, all placeholders are resolved.`);
  return true;
}

function runRender(target, config, mode) {
  console.log(mode === "dry-run" ? "Would generate:" : "Generated:");

  syncConfigMirror(target, mode);

  for (const tmplPath of findTemplates(SRC_DIR)) {
    const dst = resolveOutputPath(target, tmplPath);
    const content = readFileSync(tmplPath, "utf-8");
    const rendered = render(content, config);

    if (mode === "dry-run") {
      let marker = " (new)";
      if (existsSync(dst)) {
        marker = readFileSync(dst, "utf-8") === rendered ? " (unchanged)" : " (changed)";
      }
      console.log(`  ${relative(ROOT, dst)}${marker}`);
    } else {
      mkdirSync(dirname(dst), { recursive: true });
      writeFileSync(dst, rendered);
      console.log(`  ${relative(ROOT, dst)}`);
    }
  }

  console.log();
  console.log(mode === "dry-run" ? "Dry run complete (no files written)." : "Done.");
}

// ── Main ─────────────────────────────────────────────────────────────

let options;

try {
  options = parseArgs(process.argv.slice(2));
} catch (error) {
  console.error(`Error: ${error.message}`);
  printHelp();
  process.exit(1);
}

if (options.help) {
  printHelp();
  process.exit(0);
}

let targets;

try {
  targets = resolveTargets(options.target);
} catch (error) {
  console.error(`Error: ${error.message}`);
  printHelp();
  process.exit(1);
}

for (const target of targets) {
  if (!existsSync(target.configSourcePath)) {
    console.error(`Error: ${target.configSourcePath} not found for target '${target.name}'`);
    process.exit(1);
  }
}

let hasFailure = false;

for (const target of targets) {
  const config = buildRenderConfig(target);

  console.log(`Target: ${target.name}`);
  console.log(`Output: ${relative(ROOT, target.outputDir)}`);
  console.log(`Config source: ${relative(ROOT, target.configSourcePath)}`);
  console.log(`Config output: ${relative(ROOT, target.configOutputPath)}`);
  printConfig(config);

  if (options.mode === "check") {
    if (!runCheck(target, config)) {
      hasFailure = true;
    }
    console.log();
    continue;
  }

  runRender(target, config, options.mode);
  console.log();
}

process.exit(hasFailure ? 1 : 0);
