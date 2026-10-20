#!/usr/bin/env node
/**
 * Prodscope pre-merge hook — runs on TaskCompleted when loaded via plugin hooks/hooks.json.
 * Does not call Sentry MCP directly (MCP tools run inside Claude); this script logs a gate
 * and optionally records context. Graceful skip if Sentry is not configured.
 *
 * Usage: node hooks/pre-merge.js
 * Requires: Node 18+
 */

const fs = require("fs");
const path = require("path");

function logLine(msg) {
  process.stderr.write(`[prodscope/pre-merge] ${msg}\n`);
}

function projectRoot() {
  return process.env.CLAUDE_PROJECT_DIR || process.cwd();
}

function appendLog(line) {
  const dir = path.join(projectRoot(), ".prodscope", "logs");
  try {
    fs.mkdirSync(dir, { recursive: true });
    fs.appendFileSync(path.join(dir, "pre-merge.log"), line + "\n", "utf8");
  } catch (e) {
    logLine(`log append skipped: ${e.message}`);
  }
}

async function main() {
  if (process.env.PRODSCOPE_SKIP_PRE_MERGE === "1") {
    logLine("skipped (PRODSCOPE_SKIP_PRE_MERGE=1)");
    process.exit(0);
  }

  const iso = new Date().toISOString();
  const hasSentry = Boolean(
    process.env.SENTRY_AUTH_TOKEN || process.env.SENTRY_DSN
  );

  if (!hasSentry) {
    logLine(
      "Sentry not configured (set SENTRY_AUTH_TOKEN or SENTRY_DSN to enable checks). MCP tools should be used in-session for full verification."
    );
    appendLog(
      `${iso}\thook\tPRE_MERGE_SKIP\tno Sentry env; see mcp-config.json and /prodscope:verify`
    );
    process.exit(0);
  }

  logLine("Sentry env present — ensure Sentry MCP is connected in Claude for deep checks.");
  appendLog(`${iso}\thook\tPRE_MERGE_OK\tsentry env present`);
  process.exit(0);
}

main().catch((e) => {
  logLine(`error: ${e.message}`);
  appendLog(`${new Date().toISOString()}\thook\tPRE_MERGE_ERR\t${e.message}`);
  // Exit 1 on unexpected errors so the gate is visible; set
  // PRODSCOPE_SKIP_PRE_MERGE=1 to bypass in environments where
  // a hard gate is not desired.
  process.exit(1);
});
