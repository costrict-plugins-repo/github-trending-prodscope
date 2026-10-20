#!/usr/bin/env bash
set -euo pipefail

# Prodscope installer — copies plugin files into the current project.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/ashokdudhade/prodscope/main/install.sh | bash
#   or: git clone https://github.com/ashokdudhade/prodscope.git /tmp/prodscope && /tmp/prodscope/install.sh
#
# Flags:
#   --claude-only   Install only Claude Code files
#   --cursor-only   Install only Cursor files
#   --codex-only    Install only Codex files
#   --force         Overwrite existing files without prompting
#   --dry-run       Show what would be copied without doing it

REPO_URL="https://raw.githubusercontent.com/ashokdudhade/prodscope/main"
TARGET="${PRODSCOPE_TARGET:-.}"
FORCE=false
DRY_RUN=false
PLATFORM=""

for arg in "$@"; do
  case "$arg" in
    --claude-only) PLATFORM="claude" ;;
    --cursor-only) PLATFORM="cursor" ;;
    --codex-only)  PLATFORM="codex" ;;
    --force)       FORCE=true ;;
    --dry-run)     DRY_RUN=true ;;
    --help|-h)
      echo "Usage: install.sh [--claude-only|--cursor-only|--codex-only] [--force] [--dry-run]"
      echo ""
      echo "Claude Code users can also install natively:"
      echo "  /plugin marketplace add ashokdudhade/prodscope"
      echo "  /plugin install prodscope@prodscope-marketplace"
      exit 0
      ;;
    *) echo "Unknown option: $arg"; exit 1 ;;
  esac
done

info()  { echo "  [prodscope] $*"; }
warn()  { echo "  [prodscope] SKIP $* (already exists, use --force to overwrite)"; }

copy_file() {
  local src="$1" dest="$TARGET/$2"
  local dir
  dir=$(dirname "$dest")

  if [ -f "$dest" ] && [ "$FORCE" = false ]; then
    warn "$2"
    return
  fi

  if [ "$DRY_RUN" = true ]; then
    info "would copy → $2"
    return
  fi

  mkdir -p "$dir"

  if [ -d ".prodscope_src" ]; then
    cp ".prodscope_src/$src" "$dest"
  else
    curl -fsSL "$REPO_URL/$src" -o "$dest"
  fi
  info "copied → $2"
}

append_gitignore() {
  local entry="$1"
  local gi="$TARGET/.gitignore"
  if [ -f "$gi" ] && grep -qF "$entry" "$gi"; then
    return
  fi
  if [ "$DRY_RUN" = true ]; then
    info "would append '$entry' to .gitignore"
    return
  fi
  echo "$entry" >> "$gi"
  info "appended '$entry' to .gitignore"
}

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║   Prodscope — plugin installer       ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

# --- Shared files (all platforms) ---
SHARED_FILES=(
  "skills/builder/SKILL.md"
  "skills/breaker/SKILL.md"
  "skills/reliability/SKILL.md"
  "skills/verification/SKILL.md"
  "skills/using-prodscope/SKILL.md"
  "mcp-config.json"
)

for f in "${SHARED_FILES[@]}"; do
  copy_file "$f" "$f"
done

# --- Claude Code ---
if [ -z "$PLATFORM" ] || [ "$PLATFORM" = "claude" ]; then
  info "--- Claude Code ---"
  copy_file ".claude-plugin/plugin.json"       ".claude-plugin/plugin.json"
  copy_file ".claude-plugin/marketplace.json"  ".claude-plugin/marketplace.json"
  copy_file "commands/build.md"                "commands/build.md"
  copy_file "commands/verify.md"               "commands/verify.md"
  copy_file "hooks/hooks.json"                 "hooks/hooks.json"
  copy_file "hooks/pre-merge.js"               "hooks/pre-merge.js"
  copy_file "hooks/session-start"              "hooks/session-start"
fi

# --- Cursor ---
if [ -z "$PLATFORM" ] || [ "$PLATFORM" = "cursor" ]; then
  info "--- Cursor ---"
  copy_file ".cursor/rules/prodscope.md"              ".cursor/rules/prodscope.md"
  copy_file ".cursor/commands/prodscope-build.md"     ".cursor/commands/prodscope-build.md"
  copy_file ".cursor/commands/prodscope-verify.md"    ".cursor/commands/prodscope-verify.md"
  copy_file ".cursor-plugin/plugin.json"              ".cursor-plugin/plugin.json"
  copy_file ".cursor-plugin/marketplace.json"         ".cursor-plugin/marketplace.json"
  copy_file "rules/prodscope.mdc"                     "rules/prodscope.mdc"
  copy_file "hooks/hooks-cursor.json"                 "hooks/hooks-cursor.json"
  copy_file "hooks/session-start"                     "hooks/session-start"
fi

# --- Codex ---
if [ -z "$PLATFORM" ] || [ "$PLATFORM" = "codex" ]; then
  info "--- Codex ---"
  copy_file "AGENTS.md" "AGENTS.md"
  copy_file ".codex-plugin/plugin.json"              ".codex-plugin/plugin.json"
  copy_file ".agents/plugins/marketplace.json"       ".agents/plugins/marketplace.json"
fi

# --- Make hooks executable ---
if [ "$DRY_RUN" = false ] && [ -f "$TARGET/hooks/session-start" ]; then
  chmod +x "$TARGET/hooks/session-start"
fi

# --- .gitignore + logs dir ---
if [ "$DRY_RUN" = false ]; then
  mkdir -p "$TARGET/.prodscope/logs"
  touch "$TARGET/.prodscope/logs/.gitkeep"
fi
append_gitignore ".prodscope/logs/*.log"
append_gitignore "node_modules/"
append_gitignore ".env"

echo ""
info "Done! Next steps:"
if [ -z "$PLATFORM" ] || [ "$PLATFORM" = "claude" ]; then
  info "  Claude Code → open a session, type /prodscope:build <task>"
  info "               (or install natively: /plugin marketplace add ashokdudhade/prodscope)"
fi
if [ -z "$PLATFORM" ] || [ "$PLATFORM" = "cursor" ]; then
  info "  Cursor      → open workspace, Prodscope plugin loads automatically"
  info "               type /prodscope:build <task> in chat"
fi
if [ -z "$PLATFORM" ] || [ "$PLATFORM" = "codex" ]; then
  info "  Codex       → open this repo in Codex, it detects the plugin automatically"
  info "               (or install manually: copy .codex-plugin/ + .agents/ + skills/ into your project)"
fi
echo ""
