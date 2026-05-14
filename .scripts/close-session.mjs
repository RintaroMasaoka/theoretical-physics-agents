#!/usr/bin/env node
/**
 * Close an /auto or /steer session from a research-planner-authored packet.
 *
 * The planner owns the research synthesis inside the packet. This script owns
 * the deterministic boundary transaction: validate packet shape, write the
 * handoff files, delete the resume beacon, stage declared paths, commit, and
 * push.
 */

import { execFileSync } from "child_process";
import {
  appendFileSync,
  existsSync,
  mkdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "fs";
import path from "path";
import { fileURLToPath } from "url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

function usage() {
  console.error(
    "Usage: node .scripts/close-session.mjs --packet <path> --kind auto|steer [--stage-manifest <path>] [--no-push]",
  );
}

function parseArgs(argv) {
  const args = { push: true };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--packet") {
      args.packet = argv[++i];
    } else if (arg === "--kind") {
      args.kind = argv[++i];
    } else if (arg === "--stage-manifest") {
      args.stageManifest = argv[++i];
    } else if (arg === "--no-push") {
      args.push = false;
    } else if (arg === "--help" || arg === "-h") {
      args.help = true;
    } else {
      throw new Error(`unknown argument: ${arg}`);
    }
  }
  return args;
}

function insideRoot(inputPath) {
  const absolute = path.isAbsolute(inputPath) ? inputPath : path.resolve(ROOT, inputPath);
  const rel = path.relative(ROOT, absolute);
  if (!rel || rel.startsWith("..") || path.isAbsolute(rel)) {
    throw new Error(`path outside project: ${inputPath}`);
  }
  return rel.split(path.sep).join("/");
}

function readProjectFile(relPath) {
  return readFileSync(path.join(ROOT, relPath), "utf8");
}

function writeProjectFile(relPath, content) {
  const absolute = path.join(ROOT, relPath);
  mkdirSync(path.dirname(absolute), { recursive: true });
  writeFileSync(absolute, content);
}

function run(command, args, options = {}) {
  return execFileSync(command, args, {
    cwd: ROOT,
    encoding: "utf8",
    stdio: options.stdio ?? ["ignore", "pipe", "pipe"],
  });
}

function parseTopSections(content) {
  const allowed = ["Focus", "Last Session", "Session Log", "Backlog", "Agenda", "Commit"];
  const required = ["Focus", "Last Session", "Session Log", "Commit"];
  const matches = [...content.matchAll(/^## ([^\n]+)$/gm)].filter((match) => allowed.includes(match[1].trim()));
  const sections = new Map();

  for (let i = 0; i < matches.length; i += 1) {
    const title = matches[i][1].trim();
    if (sections.has(title)) {
      throw new Error(`duplicate top-level section: ${title}`);
    }
    const bodyStart = matches[i].index + matches[i][0].length;
    const bodyEnd = i + 1 < matches.length ? matches[i + 1].index : content.length;
    sections.set(title, content.slice(bodyStart, bodyEnd).replace(/^\n/, "").replace(/\s+$/, "\n"));
  }

  for (const title of required) {
    if (!sections.has(title)) {
      throw new Error(`missing required section: ## ${title}`);
    }
  }

  return sections;
}

function subsection(body, title) {
  const pattern = new RegExp(`^### ${title.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}\\n`, "m");
  const match = body.match(pattern);
  if (!match || match.index === undefined) {
    throw new Error(`missing Session Log subsection: ### ${title}`);
  }
  const start = match.index + match[0].length;
  const rest = body.slice(start);
  const next = rest.search(/^### /m);
  return (next === -1 ? rest : rest.slice(0, next)).replace(/\s+$/, "\n");
}

function parseBacklog(body) {
  const matches = [...body.matchAll(/^### (research\/[^\n]+\/backlog\.md|research\/backlog\.md)$/gm)];
  if (matches.length === 0) {
    throw new Error("Backlog section present but no backlog file subsections found");
  }

  const entries = [];
  for (let i = 0; i < matches.length; i += 1) {
    const relPath = insideRoot(matches[i][1]);
    if (!relPath.startsWith("research/") || !relPath.endsWith("/backlog.md")) {
      throw new Error(`invalid backlog path: ${matches[i][1]}`);
    }
    const nodeDir = relPath === "research/backlog.md" ? "research" : path.dirname(relPath);
    if (!existsSync(path.join(ROOT, nodeDir))) {
      throw new Error(`backlog parent node does not exist: ${nodeDir}`);
    }
    const start = matches[i].index + matches[i][0].length;
    const end = i + 1 < matches.length ? matches[i + 1].index : body.length;
    entries.push({ path: relPath, body: body.slice(start, end).replace(/^\n/, "").replace(/\s+$/, "\n") });
  }
  return entries;
}

function parseCommitMessage(body) {
  const match = body.match(/^message:\s*(.+)$/m);
  if (!match) {
    throw new Error("missing commit message line: message: ...");
  }
  return match[1].trim();
}

function sessionTimestampFromPath(relPath) {
  const base = path.basename(relPath);
  const match = base.match(/^(\d{2})(\d{2})(\d{2})_(\d{2})(\d{2})_/);
  if (!match) {
    return "20XX-XX-XX XX:XX";
  }
  return `20${match[1]}-${match[2]}-${match[3]} ${match[4]}:${match[5]}`;
}

function unique(items) {
  return [...new Set(items.filter(Boolean))];
}

function loadManifest(relPath) {
  if (!relPath) return [];
  return readProjectFile(relPath)
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line && !line.startsWith("#"))
    .map(insideRoot);
}

function ensureBeaconIgnored(touched) {
  const gitignorePath = ".gitignore";
  const line = ".logs/.auto-active";
  const current = existsSync(path.join(ROOT, gitignorePath)) ? readProjectFile(gitignorePath) : "";
  if (!current.split(/\r?\n/).includes(line)) {
    appendFileSync(path.join(ROOT, gitignorePath), `${current.endsWith("\n") || current === "" ? "" : "\n"}${line}\n`);
    touched.push(gitignorePath);
  }
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    usage();
    return;
  }
  if (!args.packet || !args.kind || !["auto", "steer"].includes(args.kind)) {
    usage();
    process.exit(1);
  }

  const packetPath = insideRoot(args.packet);
  const manifestPath = args.stageManifest ? insideRoot(args.stageManifest) : null;
  const packet = readProjectFile(packetPath);
  const sections = parseTopSections(packet);

  const sessionLog = sections.get("Session Log");
  const accomplished = subsection(sessionLog, "Accomplished");
  const nodeChanges = subsection(sessionLog, "Node Changes");
  const deliverables = subsection(sessionLog, "Deliverables");
  const commitMessage = parseCommitMessage(sections.get("Commit"));

  const touched = [packetPath];

  writeProjectFile("research/focus.md", sections.get("Focus"));
  touched.push("research/focus.md");

  writeProjectFile(".logs/last_session.md", sections.get("Last Session"));
  touched.push(".logs/last_session.md");

  const sessionLogPath = insideRoot(run("bash", [".scripts/log-path.sh", args.kind]).trim());
  const timestamp = sessionTimestampFromPath(sessionLogPath);
  writeProjectFile(
    sessionLogPath,
    `# Run ${timestamp}\n\n## Accomplished\n${accomplished}\n## Node Changes\n${nodeChanges}\n## Deliverables\n${deliverables}`,
  );
  touched.push(sessionLogPath);

  if (sections.has("Backlog")) {
    for (const entry of parseBacklog(sections.get("Backlog"))) {
      writeProjectFile(entry.path, entry.body);
      touched.push(entry.path);
    }
  }

  if (sections.has("Agenda")) {
    writeProjectFile("agenda.md", `# Meeting Agenda\n\n${sections.get("Agenda")}`);
    touched.push("agenda.md");
  }

  const beacon = path.join(ROOT, ".logs", ".auto-active");
  if (existsSync(beacon)) {
    rmSync(beacon);
  }
  ensureBeaconIgnored(touched);

  const stagePaths = unique([...touched, manifestPath, ...loadManifest(manifestPath)]);
  if (stagePaths.length > 0) {
    run("git", ["add", "--", ...stagePaths], { stdio: "pipe" });
  }

  try {
    run("git", ["commit", "-m", commitMessage], { stdio: "pipe" });
  } catch (error) {
    const output = `${error.stdout ?? ""}${error.stderr ?? ""}`;
    if (/nothing to commit|no changes added/i.test(output)) {
      console.log("DONE: no changes to commit");
      return;
    }
    throw error;
  }

  const hash = run("git", ["rev-parse", "--short", "HEAD"]).trim();

  if (!args.push) {
    console.log(`DONE: committed ${hash}; push skipped`);
    return;
  }

  try {
    run("git", ["push"], { stdio: "pipe" });
  } catch (error) {
    const output = `${error.stdout ?? ""}${error.stderr ?? ""}`.trim();
    console.log(`FAILED: push failed after commit ${hash} — ${output}`);
    process.exit(2);
  }

  console.log(`DONE: committed ${hash} and pushed`);
}

try {
  main();
} catch (error) {
  console.error(`FAILED: ${error.message}`);
  process.exit(1);
}
