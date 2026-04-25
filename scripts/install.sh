#!/usr/bin/env bash
#
# jonathan-stack direct-copy installer
#
# Copies persona and command files from this repo into ~/.claude/agents/
# and ~/.claude/commands/, backing up anything that would be overwritten.
#
# Idempotent — safe to re-run. Each run creates a fresh timestamped backup
# directory only if files would actually be overwritten.
#
# Usage:
#   chmod +x scripts/install.sh
#   ./scripts/install.sh

set -euo pipefail

# ------------------------------------------------------------------------------
# Setup
# ------------------------------------------------------------------------------

# Resolve repo root regardless of where the script is invoked from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SOURCE_AGENTS="$REPO_ROOT/plugins/jonathan-stack/agents"
SOURCE_COMMANDS="$REPO_ROOT/plugins/jonathan-stack/commands"

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
DEST_AGENTS="$CLAUDE_HOME/agents"
DEST_COMMANDS="$CLAUDE_HOME/commands"
BACKUP_ROOT="$CLAUDE_HOME/backups"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

# Color output (disabled if not a TTY)
if [ -t 1 ]; then
  C_RED=$'\033[0;31m'
  C_GREEN=$'\033[0;32m'
  C_YELLOW=$'\033[0;33m'
  C_BLUE=$'\033[0;34m'
  C_RESET=$'\033[0m'
else
  C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_RESET=""
fi

info()  { echo "${C_BLUE}[info]${C_RESET}  $*"; }
ok()    { echo "${C_GREEN}[ok]${C_RESET}    $*"; }
warn()  { echo "${C_YELLOW}[warn]${C_RESET}  $*"; }
fail()  { echo "${C_RED}[fail]${C_RESET}  $*" >&2; }

# ------------------------------------------------------------------------------
# Pre-flight
# ------------------------------------------------------------------------------

info "jonathan-stack installer"
info "Repo root:     $REPO_ROOT"
info "Claude home:   $CLAUDE_HOME"
echo ""

# Verify source files exist
if [ ! -d "$SOURCE_AGENTS" ]; then
  fail "Agent source directory not found: $SOURCE_AGENTS"
  fail "Are you running this from inside the jonathan-stack repo?"
  exit 1
fi

if [ ! -d "$SOURCE_COMMANDS" ]; then
  fail "Commands source directory not found: $SOURCE_COMMANDS"
  exit 1
fi

# Count source files
AGENT_COUNT="$(find "$SOURCE_AGENTS" -maxdepth 1 -name '*.md' -type f | wc -l | tr -d ' ')"
COMMAND_COUNT="$(find "$SOURCE_COMMANDS" -maxdepth 1 -name '*.md' -type f | wc -l | tr -d ' ')"

info "Found $AGENT_COUNT agent files and $COMMAND_COUNT command files in source."

if [ "$AGENT_COUNT" -eq 0 ] || [ "$COMMAND_COUNT" -eq 0 ]; then
  fail "Source directories appear empty. Aborting."
  exit 1
fi

# Verify Claude home exists or can be created
if [ ! -d "$CLAUDE_HOME" ]; then
  warn "$CLAUDE_HOME does not exist. Creating it."
  mkdir -p "$CLAUDE_HOME"
fi

# Create destination directories if needed
mkdir -p "$DEST_AGENTS"
mkdir -p "$DEST_COMMANDS"

# ------------------------------------------------------------------------------
# Backup phase — only back up files that will actually be overwritten
# ------------------------------------------------------------------------------

backup_if_needed() {
  local src_file="$1"
  local dest_dir="$2"
  local backup_subdir="$3"

  local filename
  filename="$(basename "$src_file")"
  local dest_file="$dest_dir/$filename"

  if [ -f "$dest_file" ]; then
    # Compare contents — if identical, no backup needed
    if cmp -s "$src_file" "$dest_file"; then
      return 0
    fi

    # File exists and differs — back it up
    mkdir -p "$BACKUP_DIR/$backup_subdir"
    cp "$dest_file" "$BACKUP_DIR/$backup_subdir/$filename"
    return 1
  fi

  return 0
}

BACKUP_HAPPENED=false

info "Checking for files that need backup..."

for src in "$SOURCE_AGENTS"/*.md; do
  [ -e "$src" ] || continue
  if ! backup_if_needed "$src" "$DEST_AGENTS" "agents"; then
    BACKUP_HAPPENED=true
    warn "Backed up existing $(basename "$src") (different from incoming)"
  fi
done

for src in "$SOURCE_COMMANDS"/*.md; do
  [ -e "$src" ] || continue
  if ! backup_if_needed "$src" "$DEST_COMMANDS" "commands"; then
    BACKUP_HAPPENED=true
    warn "Backed up existing $(basename "$src") (different from incoming)"
  fi
done

if [ "$BACKUP_HAPPENED" = true ]; then
  ok "Backups stored in: $BACKUP_DIR"
else
  info "No conflicting files needed backup."
fi

echo ""

# ------------------------------------------------------------------------------
# Copy phase
# ------------------------------------------------------------------------------

info "Copying agents..."
COPIED_AGENTS=0
for src in "$SOURCE_AGENTS"/*.md; do
  [ -e "$src" ] || continue
  cp "$src" "$DEST_AGENTS/$(basename "$src")"
  COPIED_AGENTS=$((COPIED_AGENTS + 1))
done
ok "Copied $COPIED_AGENTS agent files to $DEST_AGENTS"

info "Copying commands..."
COPIED_COMMANDS=0
for src in "$SOURCE_COMMANDS"/*.md; do
  [ -e "$src" ] || continue
  cp "$src" "$DEST_COMMANDS/$(basename "$src")"
  COPIED_COMMANDS=$((COPIED_COMMANDS + 1))
done
ok "Copied $COPIED_COMMANDS command files to $DEST_COMMANDS"

echo ""

# ------------------------------------------------------------------------------
# Verification
# ------------------------------------------------------------------------------

info "Verifying install..."

VERIFY_FAIL=false

for src in "$SOURCE_AGENTS"/*.md; do
  [ -e "$src" ] || continue
  filename="$(basename "$src")"
  if [ ! -f "$DEST_AGENTS/$filename" ]; then
    fail "Missing after copy: $DEST_AGENTS/$filename"
    VERIFY_FAIL=true
  fi
done

for src in "$SOURCE_COMMANDS"/*.md; do
  [ -e "$src" ] || continue
  filename="$(basename "$src")"
  if [ ! -f "$DEST_COMMANDS/$filename" ]; then
    fail "Missing after copy: $DEST_COMMANDS/$filename"
    VERIFY_FAIL=true
  fi
done

if [ "$VERIFY_FAIL" = true ]; then
  fail "Verification failed. Check the messages above."
  exit 1
fi

ok "All files verified in place."

echo ""

# ------------------------------------------------------------------------------
# Companion plugin check (informational only)
# ------------------------------------------------------------------------------

info "Checking for companion plugins (informational)..."

if [ -d "$CLAUDE_HOME/plugins" ]; then
  if find "$CLAUDE_HOME/plugins" -maxdepth 3 -name 'superpowers*' 2>/dev/null | grep -q .; then
    ok "superpowers appears to be installed"
  else
    warn "superpowers does NOT appear to be installed."
    warn "  Several personas in this stack reference superpowers skills in their"
    warn "  Delegated Skills tables. Without superpowers, those references will"
    warn "  be dead links and the personas will be partially functional."
    warn ""
    warn "  Install via:"
    warn "    /plugin marketplace add obra/superpowers-marketplace"
    warn "    /plugin install superpowers@superpowers-marketplace"
  fi

  if find "$CLAUDE_HOME/plugins" -maxdepth 3 -name 'tech-snacks*' 2>/dev/null | grep -q .; then
    ok "tech-snacks appears to be installed"
  else
    info "tech-snacks not detected (optional — provides alternative design paths)."
  fi
else
  warn "No $CLAUDE_HOME/plugins directory found. If you haven't installed any"
  warn "Claude Code plugins yet, you should at least install superpowers before"
  warn "using this stack — otherwise the engineer personas will reference skills"
  warn "that don't exist."
fi

echo ""

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------

cat <<EOF
${C_GREEN}╭─────────────────────────────────────────────────────────────╮${C_RESET}
${C_GREEN}│ Install complete                                            │${C_RESET}
${C_GREEN}╰─────────────────────────────────────────────────────────────╯${C_RESET}

  Agents installed:    $COPIED_AGENTS  →  $DEST_AGENTS
  Commands installed:  $COPIED_COMMANDS   →  $DEST_COMMANDS
EOF

if [ "$BACKUP_HAPPENED" = true ]; then
  echo "  Backups:             $BACKUP_DIR"
fi

cat <<EOF

  Next steps:

  1. RESTART Claude Code (fully quit, then relaunch). Live change detection
     does not pick up new top-level skills/agents directories that didn't
     exist when Claude Code started.

  2. In a new session, type \`/help\` and confirm you see:
       /jonathan-spec
       /jonathan-ship
       /quickspike

  3. Smoke test:
       "Use the product-manager subagent to draft a one-paragraph PRD for
        a hello-world feature."

  4. Read MAINTENANCE.md when you have 15 minutes. Schedule a quarterly
     review reminder.

EOF
