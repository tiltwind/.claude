#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_REPO="https://github.com/tiltwind/.claude.git"
TEMPLATE_DIR="$HOME/.claude/claude-template"

usage() {
  cat <<'USAGE'
Usage:
  install.sh <type> <name> [<type> <name> ...]

Types:
  agent <name>    Install agents/<name>.md
  command <name>  Install commands/<name>.md
  rule <name>     Install rules/<name>.md
  skill <name>    Install skills/<name>/ directory

Examples:
  # Install single item
  curl -fsSL https://raw.githubusercontent.com/tiltwind/.claude/main/scripts/install.sh | bash -s -- agent architect

  # Install multiple items
  curl -fsSL https://raw.githubusercontent.com/tiltwind/.claude/main/scripts/install.sh | bash -s -- agent architect agent go-developer command commitpush rule security

  # Install all items of a type
  curl -fsSL https://raw.githubusercontent.com/tiltwind/.claude/main/scripts/install.sh | bash -s -- agent all

  # Install everything
  curl -fsSL https://raw.githubusercontent.com/tiltwind/.claude/main/scripts/install.sh | bash -s -- all
USAGE
}

if [ $# -eq 0 ]; then
  usage
  exit 1
fi

PROJECT_DIR="$(pwd)"

# 1. Clone or update template
if [ -d "$TEMPLATE_DIR/.git" ]; then
  echo "Updating template in $TEMPLATE_DIR..."
  git -C "$TEMPLATE_DIR" pull --ff-only
else
  echo "Cloning template to $TEMPLATE_DIR..."
  mkdir -p "$(dirname "$TEMPLATE_DIR")"
  git clone "$TEMPLATE_REPO" "$TEMPLATE_DIR"
fi

# Helper: link a single file
link_file() {
  local src="$1"
  local dest="$2"
  if [ ! -f "$src" ]; then
    echo "Error: $src not found"
    return 1
  fi
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "Warning: $dest exists and is not a symlink, skipping"
    return 0
  fi
  ln -sfn "$src" "$dest"
  echo "Linked: $dest -> $src"
}

# Helper: link a directory (for skills)
link_dir() {
  local src="$1"
  local dest="$2"
  if [ ! -d "$src" ]; then
    echo "Error: $src not found"
    return 1
  fi
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "Warning: $dest exists and is not a symlink, skipping"
    return 0
  fi
  ln -sfn "$src" "$dest"
  echo "Linked: $dest -> $src"
}

# Helper: install all items of a type
install_all_of_type() {
  local type="$1"
  case "$type" in
    agent)
      for file in "$TEMPLATE_DIR/agents"/*.md; do
        [ -f "$file" ] || continue
        local name=$(basename "$file" .md)
        link_file "$file" "$PROJECT_DIR/.claude/agents/$name.md"
      done
      ;;
    command)
      for file in "$TEMPLATE_DIR/commands"/*.md; do
        [ -f "$file" ] || continue
        local name=$(basename "$file" .md)
        link_file "$file" "$PROJECT_DIR/.claude/commands/$name.md"
      done
      ;;
    rule)
      for file in "$TEMPLATE_DIR/rules"/*.md; do
        [ -f "$file" ] || continue
        local name=$(basename "$file" .md)
        link_file "$file" "$PROJECT_DIR/.claude/rules/$name.md"
      done
      ;;
    skill)
      for skill_dir in "$TEMPLATE_DIR/skills"/*/; do
        [ -d "$skill_dir" ] || continue
        local name=$(basename "$skill_dir")
        link_dir "${skill_dir%/}" "$PROJECT_DIR/.claude/skills/$name"
      done
      ;;
  esac
}

# Helper: install everything
install_all() {
  for type in agent command rule skill; do
    install_all_of_type "$type"
  done
  # Link settings.local.json if exists
  if [ -f "$TEMPLATE_DIR/settings.local.json" ]; then
    link_file "$TEMPLATE_DIR/settings.local.json" "$PROJECT_DIR/.claude/settings.local.json"
  fi
}

# Parse arguments: <type> <name> pairs, or "all"
if [ "$1" = "all" ]; then
  install_all
else
  while [ $# -ge 1 ]; do
    type="$1"

    # Handle "<type> all" — install all of that type
    if [ $# -ge 2 ] && [ "$2" = "all" ]; then
      install_all_of_type "$type"
      shift 2
      continue
    fi

    if [ $# -lt 2 ]; then
      echo "Error: missing name for type '$type'"
      usage
      exit 1
    fi
    name="$2"
    shift 2

    case "$type" in
      agent)
        link_file "$TEMPLATE_DIR/agents/$name.md" "$PROJECT_DIR/.claude/agents/$name.md"
        ;;
      command)
        link_file "$TEMPLATE_DIR/commands/$name.md" "$PROJECT_DIR/.claude/commands/$name.md"
        ;;
      rule)
        link_file "$TEMPLATE_DIR/rules/$name.md" "$PROJECT_DIR/.claude/rules/$name.md"
        ;;
      skill)
        link_dir "$TEMPLATE_DIR/skills/$name" "$PROJECT_DIR/.claude/skills/$name"
        ;;
      *)
        echo "Error: unknown type '$type' (valid: agent, command, rule, skill)"
        exit 1
        ;;
    esac
  done
fi

echo "Done. Template linked into $PROJECT_DIR/.claude/"
