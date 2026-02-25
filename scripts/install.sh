#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <project-dir>"
  exit 1
fi

PROJECT_DIR="$1"
TEMPLATE_REPO="https://github.com/tiltwind/.claude.git"
TEMPLATE_DIR="$HOME/.claude/claude-template"

# 1. Clone or update template
if [ -d "$TEMPLATE_DIR/.git" ]; then
  echo "Updating template in $TEMPLATE_DIR..."
  git -C "$TEMPLATE_DIR" pull --ff-only
else
  echo "Cloning template to $TEMPLATE_DIR..."
  mkdir -p "$(dirname "$TEMPLATE_DIR")"
  git clone "$TEMPLATE_REPO" "$TEMPLATE_DIR"
fi

# 2. Link individual files in agents/, rules/, commands/
for subdir in agents rules commands; do
  src_dir="$TEMPLATE_DIR/$subdir"
  dest_dir="$PROJECT_DIR/.claude/$subdir"
  [ -d "$src_dir" ] || continue
  mkdir -p "$dest_dir"
  for file in "$src_dir"/*.md; do
    [ -f "$file" ] || continue
    target="$dest_dir/$(basename "$file")"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "Warning: $target exists and is not a symlink, skipping"
      continue
    fi
    ln -sfn "$file" "$target"
  done
done

# 3. Link each skill directory as a whole
if [ -d "$TEMPLATE_DIR/skills" ]; then
  mkdir -p "$PROJECT_DIR/.claude/skills"
  for skill_dir in "$TEMPLATE_DIR/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    target="$PROJECT_DIR/.claude/skills/$skill_name"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "Warning: $target exists and is not a symlink, skipping"
      continue
    fi
    ln -sfn "${skill_dir%/}" "$target"
  done
fi

# 4. Link settings.local.json
if [ -f "$TEMPLATE_DIR/settings.local.json" ]; then
  target="$PROJECT_DIR/.claude/settings.local.json"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "Warning: $target exists and is not a symlink, skipping"
  else
    mkdir -p "$PROJECT_DIR/.claude"
    ln -sfn "$TEMPLATE_DIR/settings.local.json" "$target"
  fi
fi

echo "Done. Template linked into $PROJECT_DIR/.claude/"
