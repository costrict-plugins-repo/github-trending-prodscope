# Prodscope

Operational-first agentic plugin: a **Builder** proposes changes with explicit verification plans, and a **Breaker** (senior SRE mindset) reviews for production risks before anything is treated as done.

## Why Prodscope?

AI coding assistants ship code fast but often ignore production realities — missing indexes, race conditions, silent error swallowing, no observability. Prodscope adds a structured Builder-Breaker loop that runs automatically, so every change is challenged before it lands.

## Install

### One-liner (all platforms)

```bash
curl -fsSL https://raw.githubusercontent.com/ashokdudhade/prodscope/main/install.sh | bash
```

This copies skills, commands, rules, and hooks into your current project. No global install, no dependencies.

### Platform-specific

Install only the files you need:

```bash
# Claude Code only
curl -fsSL https://raw.githubusercontent.com/ashokdudhade/prodscope/main/install.sh | bash -s -- --claude-only

# Cursor only
curl -fsSL https://raw.githubusercontent.com/ashokdudhade/prodscope/main/install.sh | bash -s -- --cursor-only

# OpenAI Codex only
curl -fsSL https://raw.githubusercontent.com/ashokdudhade/prodscope/main/install.sh | bash -s -- --codex-only
```

### Claude Code (native plugin install)

```
/plugin marketplace add ashokdudhade/prodscope
/plugin install prodscope@prodscope-marketplace
```

This is the recommended method for Claude Code — the plugin auto-updates and integrates with the plugin system.

### Other native installs

| Platform | Method |
|----------|--------|
| **Cursor** | Install from [Cursor Marketplace](https://cursor.com/marketplace), or Settings → Rules → Remote Rule → paste `ashokdudhade/prodscope` |
| **Codex** | Copy `.codex-plugin/`, `.agents/`, `AGENTS.md`, and `skills/` into your project root |

### Other options

```bash
# Preview what would be installed (no changes made)
curl -fsSL https://raw.githubusercontent.com/ashokdudhade/prodscope/main/install.sh | bash -s -- --dry-run

# Clone and install from local copy
git clone https://github.com/ashokdudhade/prodscope.git /tmp/prodscope
cd your-project && /tmp/prodscope/install.sh
```

## Usage

Type **`/prodscope:build <your task>`** in Claude Code or Cursor. Codex runs the loop automatically.

```
/prodscope:build "add rate limiting to the API"
  │
  ├─ Phase 1: Builder
  │   ├─ Implements smallest coherent diff
  │   └─ Attaches HEALTH_CHECK (smoke steps, signals, rollback)
  │
  ├─ Phase 2: Breaker
  │   ├─ SRE review: async races, DB indexes, memory, security
  │   ├─ REJECT → loops back to Builder with required fixes (max 3 cycles)
  │   └─ ACCEPT → proceeds to verification
  │
  ├─ Phase 3: Verification
  │   ├─ Runs HEALTH_CHECK smoke steps with evidence
  │   └─ Failure → loops back to Builder
  │
  └─ Phase 4: Reliability score
      ├─ Rates change 1–10 (tests, observability, errors, ops, security)
      └─ Logs outcome to .prodscope/logs/
```

The entire loop runs in a **single response** — no manual handoff between phases.

## Commands

| Command | Platform | What it does |
|---------|----------|--------------|
| `/prodscope:build <task>` | Claude Code, Cursor | Full Builder → Breaker → Verify → Score loop |
| `/prodscope:verify` | Claude Code, Cursor | Post-build verification with MCP telemetry (Sentry, Datadog) |

## MCP integration

`mcp-config.json` is a placeholder for Sentry, Datadog, or other MCP servers. Add entries per vendor docs and inject API keys via environment variables — never commit secrets. See `commands/verify.md` for the `/prodscope:verify` operator template.

## What gets installed

```
your-project/
├── skills/
│   ├── using-prodscope/SKILL.md     # Session bootstrap: when the loop runs
│   ├── builder/SKILL.md             # Phase 1: feature delivery + HEALTH_CHECK
│   ├── breaker/SKILL.md             # Phase 2: SRE review + REJECT loop
│   ├── verification/SKILL.md        # Phase 3: evidence that smoke steps pass
│   └── reliability/SKILL.md         # Phase 4: reliability scoring (1-10)
├── .claude-plugin/
│   ├── plugin.json                  # Claude Code manifest
│   └── marketplace.json             # Claude Code marketplace entry
├── .cursor-plugin/
│   ├── plugin.json                  # Cursor plugin manifest
│   └── marketplace.json             # Cursor marketplace entry
├── .cursor/
│   ├── rules/prodscope.md           # Cursor project-level rule
│   └── commands/
│       ├── prodscope-build.md       # Cursor /prodscope:build command
│       └── prodscope-verify.md      # Cursor /prodscope:verify command
├── rules/
│   └── prodscope.mdc                # Cursor plugin rule (.mdc format)
├── commands/
│   ├── build.md                     # Claude Code /prodscope:build command
│   └── verify.md                    # Claude Code /prodscope:verify command
├── hooks/
│   ├── hooks.json                   # Claude Code hook registration
│   ├── hooks-cursor.json            # Cursor hook registration
│   ├── session-start                # Session bootstrap hook (all platforms)
│   └── pre-merge.js                 # Pre-merge telemetry gate
├── .codex-plugin/plugin.json        # Codex plugin manifest
├── .agents/plugins/marketplace.json # Codex repo marketplace
├── AGENTS.md                        # Codex orchestration bridge
├── mcp-config.json                  # MCP server placeholder
└── .prodscope/logs/                 # Rejection/improvement logs (gitignored)
```

## Uninstall

Remove the installed files:

```bash
rm -rf skills/ rules/ commands/ hooks/ .claude-plugin/ .cursor-plugin/ .codex-plugin/ \
  .agents/ .cursor/rules/prodscope.md \
  .cursor/commands/prodscope-build.md .cursor/commands/prodscope-verify.md \
  AGENTS.md mcp-config.json .prodscope/
```

## License

[MIT](LICENSE)
