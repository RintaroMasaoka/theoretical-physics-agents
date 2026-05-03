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
 *   Config values:  .config/config.yaml
 *   Prompt content: .templates/**\/*.src.md
 * Generated (do not edit directly — overwritten on each run):
 *   .claude/**\/*.md
 *   .codex/**\/*.md
 */

import { readFileSync, writeFileSync, mkdirSync, existsSync, readdirSync, statSync, chmodSync } from "fs";
import { join, dirname, relative } from "path";
import { fileURLToPath } from "url";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const SRC_DIR = join(ROOT, ".templates");
const DEFAULT_CONFIG_SOURCE_PATH = join(ROOT, ".config", "config.yaml");
const GIT_PRE_PUSH_GUARD_SOURCE = join(ROOT, ".scripts", "git-pre-push-guard.sh");
const GIT_PRE_PUSH_HOOK = join(ROOT, ".git", "hooks", "pre-push");

const TARGETS = {
  claude: {
    name: "claude",
    outputDir: join(ROOT, ".claude"),
    configSourcePath: DEFAULT_CONFIG_SOURCE_PATH,
    rootInstructionFileName: "CLAUDE.md",
    model: {
      strong: "opus",
      balanced: "sonnet",
    },
    tools: {
      askUserQuestion: "AskUserQuestion",
      updatePlan: "TodoWrite",
      agent: "Agent",
      agentTypeField: "subagent_type",
      taskWait: "TaskOutput",
      shell: "Bash",
      read: "Read",
      write: "Write",
      edit: "Edit",
      backgroundArg: ", run_in_background=true",
      backgroundPhrase: "run_in_background=true",
      noBackgroundClause: "without `run_in_background=true`",
      backgroundLaunchClause: "Launch with `run_in_background=true`",
      taskIdName: "task_id",
      taskWaitExample: "TaskOutput(task_id=task_id, block=true)",
    },
    forbiddenRenderedTerms: [".codex/"],
  },
  codex: {
    name: "codex",
    outputDir: join(ROOT, ".codex"),
    configSourcePath: DEFAULT_CONFIG_SOURCE_PATH,
    rootInstructionFileName: "AGENTS.md",
    model: {
      strong: "gpt-5.5",
      balanced: "gpt-5.4",
    },
    tools: {
      askUserQuestion: "request_user_input",
      updatePlan: "update_plan",
      agent: "spawn_agent",
      agentTypeField: "agent_type",
      taskWait: "wait_agent",
      shell: "exec_command",
      read: "read file",
      write: "apply_patch",
      edit: "apply_patch",
      backgroundArg: "",
      backgroundPhrase: "background dispatch",
      noBackgroundClause: "using the normal dispatch form",
      backgroundLaunchClause: "Launch normally and capture the returned agent id",
      taskIdName: "agent_id",
      taskWaitExample: "wait_agent(targets=[agent_id], timeout_ms=30000)",
    },
    forbiddenRenderedTerms: [
      ".claude/",
      "CLAUDE.md",
      "model: opus",
      "model: sonnet",
      "AskUserQuestion",
      "TodoWrite",
      "TaskOutput",
      "subagent_type",
      "run_in_background",
      "Agent(",
      "Bash(",
    ],
  },
};

function buildRuntimeConfig(target) {
  const rootDir = relative(ROOT, target.outputDir).replace(/\\/g, "/");
  const instructionFile = `${rootDir}/${target.rootInstructionFileName}`;
  const agentInvocation =
    target.name === "codex"
      ? `${target.tools.agent}(prompt="Read and follow \`${rootDir}/agents/{name}.md\` as your role definition. Treat the rest of this prompt as task-specific input.\\n\\n...")`
      : `${target.tools.agent}(${target.tools.agentTypeField}="{name}", prompt="...")`;

  return {
    runtime: {
      target: target.name,
      is_claude: target.name === "claude" ? "true" : "false",
      is_codex: target.name === "codex" ? "true" : "false",
      root_dir: rootDir,
      instruction_file: instructionFile,
      instruction_file_name: target.rootInstructionFileName,
      common_file: `${rootDir}/common.md`,
      notes_syntax_file: `${rootDir}/notes-syntax.md`,
      research_tree_file: `${rootDir}/research-tree.md`,
      agents_dir: `${rootDir}/agents`,
      skills_dir: `${rootDir}/skills`,
      config_source_file: relative(ROOT, target.configSourcePath).replace(/\\/g, "/"),
      resume_hook_reference:
        target.name === "claude"
          ? "the `SessionStart` hook in `.claude/settings.json`"
          : "the runtime's session-start hook (if configured)",
      model_strong: target.model.strong,
      model_balanced: target.model.balanced,
      tool_ask_user_question: target.tools.askUserQuestion,
      tool_update_plan: target.tools.updatePlan,
      tool_agent: target.tools.agent,
      tool_agent_type_field: target.tools.agentTypeField,
      tool_task_wait: target.tools.taskWait,
      tool_shell: target.tools.shell,
      tool_read: target.tools.read,
      tool_write: target.tools.write,
      tool_edit: target.tools.edit,
      agent_background_arg: target.tools.backgroundArg,
      agent_background_phrase: target.tools.backgroundPhrase,
      agent_no_background_clause: target.tools.noBackgroundClause,
      agent_background_launch_clause: target.tools.backgroundLaunchClause,
      agent_task_id_name: target.tools.taskIdName,
      agent_invocation: agentInvocation,
      agent_wait_example: target.tools.taskWaitExample,
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
    if (m[1] === "else") continue;
    keys.add(m[1]);
  }
  for (const m of cleaned.matchAll(/\{\{\s*#(?:if|unless)\s+([\w.]+)\s*\}\}/g)) {
    keys.add(m[1]);
  }
  return keys;
}

function isTruthy(value) {
  if (value === undefined || value === null) return false;
  const normalized = String(value).trim().toLowerCase();
  return normalized !== "" && normalized !== "false" && normalized !== "0" && normalized !== "no";
}

function renderConditionals(template, config) {
  const blockPattern = /\{\{\s*#(if|unless)\s+([\w.]+)\s*\}\}([\s\S]*?)\{\{\s*\/\1\s*\}\}/g;

  let rendered = template;
  let previous;

  do {
    previous = rendered;
    rendered = rendered.replace(blockPattern, (match, operator, key, body) => {
      if (!(key in config)) return match;

      const elseMatch = body.match(/([\s\S]*?)\{\{\s*else\s*\}\}([\s\S]*)/);
      const truthy = isTruthy(config[key]);
      const includePrimary = operator === "if" ? truthy : !truthy;

      if (elseMatch) {
        return includePrimary ? elseMatch[1] : elseMatch[2];
      }

      return includePrimary ? body : "";
    });
  } while (rendered !== previous);

  return rendered;
}

function render(template, config) {
  return renderConditionals(template, config).replace(/\{\{\s*([\w.]+)\s*\}\}/g, (match, key) => {
    return key in config ? config[key] : match;
  });
}

function validateConditionalStructure(content, relPath) {
  const warnings = [];
  const stack = [];
  const tokenPattern = /\{\{\s*(#(if|unless)\s+[\w.]+|else|\/(if|unless))\s*\}\}/g;

  for (const match of content.matchAll(tokenPattern)) {
    const token = match[1];
    const line = content.slice(0, match.index).split("\n").length;

    if (token.startsWith("#")) {
      if (stack.length > 0) {
        warnings.push(`Nested template conditional in ${relPath}:${line}; configure.mjs supports only non-nested {{#if}}/{{#unless}} blocks`);
      }
      stack.push({ kind: token.split(/\s+/)[0].slice(1), line, sawElse: false });
      continue;
    }

    if (token === "else") {
      const current = stack[stack.length - 1];
      if (!current) {
        warnings.push(`Template {{else}} without open conditional in ${relPath}:${line}`);
      } else if (current.sawElse) {
        warnings.push(`Duplicate template {{else}} for conditional opened at ${relPath}:${current.line}`);
      } else {
        current.sawElse = true;
      }
      continue;
    }

    const closingKind = token.slice(1);
    const current = stack.pop();
    if (!current) {
      warnings.push(`Template closing {{/${closingKind}}} without open conditional in ${relPath}:${line}`);
    } else if (current.kind !== closingKind) {
      warnings.push(`Template closing {{/${closingKind}}} in ${relPath}:${line} does not match {{#${current.kind}}} opened at line ${current.line}`);
    }
  }

  for (const current of stack) {
    warnings.push(`Unclosed template {{#${current.kind}}} in ${relPath}:${current.line}`);
  }

  return warnings;
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
  const forbiddenRenderedTerms = target.forbiddenRenderedTerms ?? [];

  for (const tmplPath of findTemplates(SRC_DIR)) {
    const rel = relative(ROOT, tmplPath);
    const content = readFileSync(tmplPath, "utf-8");
    const keys = findPlaceholders(content);
    templateKeys[rel] = keys;
    for (const key of keys) allPlaceholders.add(key);
    warnings.push(...validateConditionalStructure(content, rel));

    const rendered = render(content, config);
    for (const forbidden of forbiddenRenderedTerms) {
      if (rendered.includes(forbidden)) {
        warnings.push(`Forbidden target-specific term '${forbidden}' present after rendering ${rel}`);
      }
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

// ── Local Git safety guards ─────────────────────────────────────────

function installGitGuards(mode) {
  const relHook = relative(ROOT, GIT_PRE_PUSH_HOOK);

  if (!existsSync(join(ROOT, ".git"))) {
    console.log("Git guard: skipped (.git not found).");
    return;
  }

  if (!existsSync(GIT_PRE_PUSH_GUARD_SOURCE)) {
    console.log("Git guard: skipped (.scripts/git-pre-push-guard.sh not found).");
    return;
  }

  const hook = `#!/usr/bin/env sh
# Generated by .scripts/configure.mjs. Do not edit directly.
exec sh ".scripts/git-pre-push-guard.sh" "$@"
`;

  if (mode === "dry-run") {
    let marker = " (new)";
    if (existsSync(GIT_PRE_PUSH_HOOK)) {
      marker = readFileSync(GIT_PRE_PUSH_HOOK, "utf-8") === hook ? " (unchanged)" : " (changed)";
    }
    console.log(`Git guard: would install ${relHook}${marker}`);
    return;
  }

  mkdirSync(dirname(GIT_PRE_PUSH_HOOK), { recursive: true });
  if (existsSync(GIT_PRE_PUSH_HOOK) && readFileSync(GIT_PRE_PUSH_HOOK, "utf-8") === hook) {
    console.log(`Git guard: installed ${relHook} (unchanged)`);
    return;
  }
  writeFileSync(GIT_PRE_PUSH_HOOK, hook, { mode: 0o755 });
  chmodSync(GIT_PRE_PUSH_HOOK, 0o755);
  console.log(`Git guard: installed ${relHook}`);
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

if (options.mode !== "check") {
  installGitGuards(options.mode);
}

process.exit(hasFailure ? 1 : 0);
