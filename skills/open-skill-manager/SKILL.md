---
name: open-skill-manager
description: Manages open-source Claude Code skills — install repos to a global cache, symlink individual skills into projects, and keep them updated.
---

# Open Skill Manager

Install, cache, and link open-source Claude Code skills across projects. Skills are git repos cloned to a global cache (`~/.skill/repos/`) and symlinked into project `skills/` directories.

## When to Activate

- User wants to install a skill from a GitHub repo
- User wants to link/unlink skills in the current project
- User wants to update cached skill repos
- User wants to browse available skills
- User mentions "open skill", "skill manager", or "install skill"

## Global Cache Structure

```
~/.skill/
  repos/
    anthropics--skills/          # owner--repo (double-dash separator)
      skills/
        pdf/SKILL.md
        xlsx/SKILL.md
        ...
    obra--superpowers/
      skills/
        tdd/SKILL.md
        ...
```

The `owner--repo` double-dash naming avoids ambiguity with hyphenated repo/owner names (e.g., `my-org--my-repo`).

## Operations

### install

Clone a GitHub repo into the global cache.

```bash
# Ensure cache directory exists
mkdir -p ~/.skill/repos

# Derive cache dir name: replace "/" with "--"
# e.g., "anthropics/skills" -> "anthropics--skills"
REPO="anthropics/skills"
CACHE_NAME="${REPO//\//__}"  # Won't work in all shells
# Portable:
CACHE_NAME="$(echo "$REPO" | sed 's|/|--|')"
CACHE_DIR="$HOME/.skill/repos/$CACHE_NAME"

# Clone if not already cached
if [ -d "$CACHE_DIR" ]; then
  echo "Already installed: $REPO"
  echo "Run update to fetch latest changes."
else
  git clone "https://github.com/$REPO.git" "$CACHE_DIR"
  echo "Installed: $REPO -> $CACHE_DIR"
fi
```

**Error handling:**
- If `git clone` fails (network error, repo not found), print the error and exit
- If the directory already exists, suggest `update` instead
- Validate that `REPO` matches `owner/repo` format before cloning

### link

Symlink a skill from the cache into the current project's `skills/` directory. Auto-fetches latest before linking.

```bash
REPO="anthropics/skills"
SKILL_NAME="pdf"
CACHE_NAME="$(echo "$REPO" | sed 's|/|--|')"
CACHE_DIR="$HOME/.skill/repos/$CACHE_NAME"

# Verify repo is installed
if [ ! -d "$CACHE_DIR" ]; then
  echo "Repo not installed. Installing first..."
  git clone "https://github.com/$REPO.git" "$CACHE_DIR"
fi

# Fetch latest
cd "$CACHE_DIR" && git pull --ff-only && cd -

# Find the skill directory (look for SKILL.md)
SKILL_SRC="$CACHE_DIR/skills/$SKILL_NAME"
if [ ! -f "$SKILL_SRC/SKILL.md" ]; then
  echo "Error: Skill '$SKILL_NAME' not found in $REPO"
  echo "Available skills:"
  find "$CACHE_DIR" -name "SKILL.md" -exec dirname {} \; | xargs -I{} basename {}
  exit 1
fi

# Detect project skills directory
SKILLS_DIR="./skills"
if [ -f ".claude/settings.json" ]; then
  # Check for custom skills_path in settings
  CUSTOM_PATH=$(grep -o '"skills_path"[[:space:]]*:[[:space:]]*"[^"]*"' .claude/settings.json 2>/dev/null | sed 's/.*"skills_path"[[:space:]]*:[[:space:]]*"//' | sed 's/"//')
  if [ -n "$CUSTOM_PATH" ]; then
    SKILLS_DIR="$CUSTOM_PATH"
  fi
fi
mkdir -p "$SKILLS_DIR"

# Create symlink (refuse if non-symlink dir exists)
LINK_TARGET="$SKILLS_DIR/$SKILL_NAME"
if [ -e "$LINK_TARGET" ] && [ ! -L "$LINK_TARGET" ]; then
  echo "Error: '$LINK_TARGET' exists and is not a symlink. Refusing to overwrite."
  echo "Remove or rename it manually if you want to link."
  exit 1
fi

ln -sfn "$SKILL_SRC" "$LINK_TARGET"
echo "Linked: $SKILL_NAME -> $SKILL_SRC"
```

**Error handling:**
- If the repo is not cached, auto-install it first
- If `git pull --ff-only` fails (diverged history), warn and skip update but still link
- Never overwrite a non-symlink directory (data safety)
- Verify `SKILL.md` exists in the skill directory

### update

Pull latest changes for cached repos.

```bash
# Update a single repo
REPO="anthropics/skills"
CACHE_NAME="$(echo "$REPO" | sed 's|/|--|')"
CACHE_DIR="$HOME/.skill/repos/$CACHE_NAME"

if [ ! -d "$CACHE_DIR" ]; then
  echo "Error: $REPO is not installed"
  exit 1
fi

cd "$CACHE_DIR"
git fetch origin
git pull --ff-only
echo "Updated: $REPO"
```

```bash
# Update ALL cached repos
for dir in ~/.skill/repos/*/; do
  if [ -d "$dir/.git" ]; then
    REPO_NAME=$(basename "$dir" | sed 's|--|/|')
    echo "Updating $REPO_NAME..."
    cd "$dir"
    git pull --ff-only || echo "Warning: Failed to update $REPO_NAME (may have diverged)"
    cd -
  fi
done
echo "All repos updated."
```

**Notes:**
- `--ff-only` prevents merge commits in the cache
- If pull fails, warn but continue to next repo (don't abort the whole update)
- Symlinked skills automatically get updates since they point to the cache

### list

Show installed repos, available skills, and linked skills in the current project.

```bash
# List all cached repos
echo "=== Cached Repos ==="
if [ -d ~/.skill/repos ]; then
  for dir in ~/.skill/repos/*/; do
    if [ -d "$dir" ]; then
      REPO_NAME=$(basename "$dir" | sed 's|--|/|')
      SKILL_COUNT=$(find "$dir" -name "SKILL.md" | wc -l | tr -d ' ')
      echo "  $REPO_NAME ($SKILL_COUNT skills)"
    fi
  done
else
  echo "  (none)"
fi

# List available skills in each repo
echo ""
echo "=== Available Skills ==="
if [ -d ~/.skill/repos ]; then
  for dir in ~/.skill/repos/*/; do
    if [ -d "$dir" ]; then
      REPO_NAME=$(basename "$dir" | sed 's|--|/|')
      find "$dir" -name "SKILL.md" -exec dirname {} \; | while read skill_dir; do
        echo "  $REPO_NAME/$(basename "$skill_dir")"
      done
    fi
  done
fi

# List linked skills in current project
echo ""
echo "=== Linked Skills (this project) ==="
SKILLS_DIR="./skills"
if [ -d "$SKILLS_DIR" ]; then
  for item in "$SKILLS_DIR"/*/; do
    if [ -L "${item%/}" ]; then
      TARGET=$(readlink "${item%/}")
      echo "  $(basename "${item%/}") -> $TARGET"
    fi
  done
fi
```

### unlink

Remove a symlink from the project's `skills/` directory. Refuses to delete non-symlink directories.

```bash
SKILL_NAME="pdf"
SKILLS_DIR="./skills"
LINK_TARGET="$SKILLS_DIR/$SKILL_NAME"

if [ ! -e "$LINK_TARGET" ] && [ ! -L "$LINK_TARGET" ]; then
  echo "Error: '$LINK_TARGET' does not exist"
  exit 1
fi

if [ ! -L "$LINK_TARGET" ]; then
  echo "Error: '$LINK_TARGET' is not a symlink. Refusing to delete."
  echo "This appears to be a local skill directory. Remove manually if intended."
  exit 1
fi

rm "$LINK_TARGET"
echo "Unlinked: $SKILL_NAME"
```

**Safety:** Never removes non-symlink directories. This prevents accidental deletion of local skills.

### search

Search installed repos and the popular registry by keyword.

```bash
KEYWORD="testing"

# Search cached repos for matching skill names and descriptions
echo "=== Cached Skills Matching '$KEYWORD' ==="
if [ -d ~/.skill/repos ]; then
  find ~/.skill/repos -name "SKILL.md" | while read f; do
    if grep -qil "$KEYWORD" "$f"; then
      SKILL_DIR=$(dirname "$f")
      SKILL_NAME=$(basename "$SKILL_DIR")
      REPO_DIR=$(echo "$SKILL_DIR" | sed "s|$HOME/.skill/repos/||" | cut -d'/' -f1)
      REPO_NAME=$(echo "$REPO_DIR" | sed 's|--|/|')
      DESC=$(grep -m1 '^description:' "$f" | sed 's/^description:[[:space:]]*//')
      echo "  $REPO_NAME/$SKILL_NAME - $DESC"
    fi
  done
fi

# Show matching entries from the popular registry
echo ""
echo "=== Popular Registry Matches ==="
# (Search the registry table below by keyword)
```

Then consult the Popular Skills Registry section below and print any matching entries.

## Composite Operations

### Install + Link (one command)

When the user says "install and link skill X from repo Y":

1. Run **install** for the repo (skip if already cached)
2. Run **link** for the specific skill

```bash
# Example: install and link the "pdf" skill from anthropics/skills
REPO="anthropics/skills"
SKILL_NAME="pdf"

# Step 1: Install
CACHE_NAME="$(echo "$REPO" | sed 's|/|--|')"
CACHE_DIR="$HOME/.skill/repos/$CACHE_NAME"
if [ ! -d "$CACHE_DIR" ]; then
  mkdir -p ~/.skill/repos
  git clone "https://github.com/$REPO.git" "$CACHE_DIR"
fi

# Step 2: Link
cd "$CACHE_DIR" && git pull --ff-only && cd -
SKILL_SRC="$CACHE_DIR/skills/$SKILL_NAME"
mkdir -p ./skills
ln -sfn "$SKILL_SRC" "./skills/$SKILL_NAME"
echo "Installed and linked: $REPO/$SKILL_NAME"
```

### Bulk Link

When the user wants multiple skills from the same repo:

```bash
REPO="anthropics/skills"
SKILLS="pdf xlsx pptx docx"

CACHE_NAME="$(echo "$REPO" | sed 's|/|--|')"
CACHE_DIR="$HOME/.skill/repos/$CACHE_NAME"

# Install if needed
if [ ! -d "$CACHE_DIR" ]; then
  mkdir -p ~/.skill/repos
  git clone "https://github.com/$REPO.git" "$CACHE_DIR"
fi

cd "$CACHE_DIR" && git pull --ff-only && cd -
mkdir -p ./skills

for SKILL_NAME in $SKILLS; do
  SKILL_SRC="$CACHE_DIR/skills/$SKILL_NAME"
  if [ -f "$SKILL_SRC/SKILL.md" ]; then
    ln -sfn "$SKILL_SRC" "./skills/$SKILL_NAME"
    echo "Linked: $SKILL_NAME"
  else
    echo "Warning: Skill '$SKILL_NAME' not found in $REPO"
  fi
done
```

## Popular Skills Registry

| Repo | Description | Skills |
|------|-------------|--------|
| `anthropics/skills` | Official Anthropic skills | pdf, xlsx, pptx, docx, mcp-builder, webapp-testing |
| `obra/superpowers` | TDD, brainstorming, debugging, verification patterns | tdd, brainstorm, debug, verify |
| `levnikolaevich/claude-code-skills` | Full delivery workflow skills | delivery, review, planning |
| `alirezarezvani/claude-skills` | Engineering, project management, docs | engineering, project-mgmt, documentation |
| `anthropics/prompt-eng` | Prompt engineering patterns | prompt-patterns, evaluation |

Use this registry for **search** results and to suggest skills when the user asks "what skills are available?"

Note: This registry is a starting point. Actual skill names inside each repo may differ — always verify by checking the cloned repo's directory structure.

## Edge Cases

### Repo Already Cloned
If `~/.skill/repos/owner--repo/` exists, skip clone and suggest `update` instead.

### Local Skill Conflicts
If `./skills/pdf/` exists as a regular directory (not a symlink), refuse to overwrite. Print an error and suggest the user rename or remove it manually.

### Broken Symlinks
When listing, check for broken symlinks (target removed from cache) and warn the user:
```bash
if [ -L "$link" ] && [ ! -e "$link" ]; then
  echo "  WARNING: $link is a broken symlink (target missing)"
fi
```

### Network Errors
If `git clone` or `git pull` fails due to network issues, print the git error message. Don't leave partial clones — if clone fails, clean up the directory:
```bash
git clone "https://github.com/$REPO.git" "$CACHE_DIR" || {
  rm -rf "$CACHE_DIR"
  echo "Error: Failed to clone $REPO. Cleaned up partial clone."
  exit 1
}
```

### skills_path Auto-Detection
Check `.claude/settings.json` for a custom `skills_path` before defaulting to `./skills/`. Also check for a `skills/` directory in the project root. If neither exists, create `./skills/`.

### Repo Has No skills/ Directory
Some repos may store skills at the root level or in a different structure. When a skill isn't found under `skills/`, also search the repo root for `SKILL.md` files:
```bash
find "$CACHE_DIR" -name "SKILL.md" -maxdepth 3
```

## Team Recommendations

### Gitignore Guidance

Symlinks use absolute paths pointing to `~/.skill/repos/...`, which are machine-specific. For team projects:

1. Add linked skill names to `.gitignore`:
   ```gitignore
   # Linked skills (install via open-skill-manager)
   skills/pdf
   skills/xlsx
   skills/tdd
   ```

2. Document required skills in `README.md` or `CLAUDE.md`:
   ```markdown
   ## Required Skills
   Install these skills using open-skill-manager:
   - `anthropics/skills`: pdf, xlsx, docx
   - `obra/superpowers`: tdd
   ```

3. Or provide a setup command in the project docs:
   ```bash
   # Install and link all required skills
   # (Run these via Claude Code's open-skill-manager)
   # install anthropics/skills, link pdf xlsx docx
   # install obra/superpowers, link tdd
   ```

### Why Symlinks Over Copies

- **Auto-updates**: Running `update` on a cached repo immediately updates all projects linking to it
- **Disk space**: One copy per repo, shared across all projects
- **Consistency**: All projects use the same version of a skill (after update)
- **Clean separation**: Easy to distinguish local skills (directories) from external skills (symlinks)
