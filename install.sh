#!/bin/sh
set -e

REPO_URL="https://github.com/aquaxis/aiprj.git"
BRANCH="${AIPRJ_BRANCH:-main}"
ARCHIVE_URL="https://github.com/aquaxis/aiprj/archive/${BRANCH}.tar.gz"

ACTION="install"
DIR=""
FORCE=0

usage() {
  cat <<'EOF'
Usage:
  install.sh [DIR]                              Install aiprj into DIR (default: current directory)
  install.sh -u|--uninstall [DIR] [-f|--force]  Uninstall aiprj from DIR
  install.sh -h|--help                          Show this help

Options:
  -u, --uninstall   Remove aiprj files from the target directory
  -f, --force       Skip confirmation prompt (uninstall only)
  -h, --help        Show this help message
EOF
}

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    -u|--uninstall) ACTION="uninstall" ;;
    -f|--force) FORCE=1 ;;
    -h|--help) usage; exit 0 ;;
    --) shift; [ $# -gt 0 ] && DIR="$1"; break ;;
    -*) echo "Error: Unknown option: $1" >&2; usage >&2; exit 1 ;;
    *)
      if [ -z "$DIR" ]; then
        DIR="$1"
      else
        echo "Error: Too many arguments" >&2; usage >&2; exit 1
      fi
      ;;
  esac
  shift
done

DIR="${DIR:-.}"
DIR="${DIR%/}"

check_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: $1 not found. Please install it." >&2
    exit 1
  fi
}

uninstall_aiprj() {
  echo "aiprj: Uninstalling from $DIR..."

  HAS_AIPRJ=0
  [ -d "$DIR/.aiprj" ] && HAS_AIPRJ=1
  for cmd in setup_ai ai update_ai next_ai close_ai; do
    [ -f "$DIR/.claude/commands/$cmd.md" ] && HAS_AIPRJ=1
    [ -f "$DIR/.agent-cli/commands/$cmd.md" ] && HAS_AIPRJ=1
  done

  if [ "$HAS_AIPRJ" -eq 0 ]; then
    echo "aiprj does not appear to be installed in $DIR."
    exit 0
  fi

  if [ "$FORCE" -ne 1 ]; then
    echo "The following will be removed:"
    [ -d "$DIR/.aiprj" ] && echo "  - $DIR/.aiprj/ (rules, instructions, work logs, project docs)"
    for cmd in setup_ai ai update_ai next_ai close_ai; do
      [ -f "$DIR/.claude/commands/$cmd.md" ] && echo "  - $DIR/.claude/commands/$cmd.md"
      [ -f "$DIR/.agent-cli/commands/$cmd.md" ] && echo "  - $DIR/.agent-cli/commands/$cmd.md"
    done
    [ -f "$DIR/.gitignore" ] && echo "  - aiprj entries in $DIR/.gitignore"
    echo "The following will be preserved (may contain user customizations):"
    [ -f "$DIR/.claude/settings.json" ] && echo "  - $DIR/.claude/settings.json"
    [ -f "$DIR/.claude/settings.local.json" ] && echo "  - $DIR/.claude/settings.local.json"
    [ -f "$DIR/.mcp.json" ] && echo "  - $DIR/.mcp.json"
    printf "Continue? [y/N] "
    read -r ans
    case "$ans" in
      y|Y|yes|YES) ;;
      *) echo "Aborted."; exit 0 ;;
    esac
  fi

  if [ -d "$DIR/.aiprj" ]; then
    rm -rf "$DIR/.aiprj"
    echo "Removed: $DIR/.aiprj/"
  fi

  for cmd in setup_ai ai update_ai next_ai close_ai; do
    if [ -f "$DIR/.claude/commands/$cmd.md" ]; then
      rm -f "$DIR/.claude/commands/$cmd.md"
      echo "Removed: $DIR/.claude/commands/$cmd.md"
    fi
    if [ -f "$DIR/.agent-cli/commands/$cmd.md" ]; then
      rm -f "$DIR/.agent-cli/commands/$cmd.md"
      echo "Removed: $DIR/.agent-cli/commands/$cmd.md"
    fi
  done

  if [ -d "$DIR/.claude/commands" ] && [ -z "$(ls -A "$DIR/.claude/commands")" ]; then
    rmdir "$DIR/.claude/commands"
  fi

  if [ -d "$DIR/.agent-cli/commands" ] && [ -z "$(ls -A "$DIR/.agent-cli/commands")" ]; then
    rmdir "$DIR/.agent-cli/commands"
  fi

  if [ -f "$DIR/.gitignore" ]; then
    TMP_GI="$(mktemp)"
    grep -vxF -e ".aiprj" -e "AI_LOG/" -e "AI_PRJ_REQUIREMENTS.md" -e "AI_PRJ_DESIGN.md" -e "AI_PRJ_TASKS.md" "$DIR/.gitignore" > "$TMP_GI" || true
    if [ -s "$TMP_GI" ]; then
      mv "$TMP_GI" "$DIR/.gitignore"
      echo "Cleaned: $DIR/.gitignore"
    else
      rm -f "$TMP_GI" "$DIR/.gitignore"
      echo "Removed: $DIR/.gitignore (empty after cleanup)"
    fi
  fi

  echo ""
  echo "aiprj uninstall complete: $DIR"
}

if [ "$ACTION" = "uninstall" ]; then
  uninstall_aiprj
  exit 0
fi

check_command curl

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

download_archive() {
  echo "Downloading via curl + tar..."
  check_command tar
  rm -rf "$TMPDIR/aiprj"
  mkdir -p "$TMPDIR/aiprj"
  # Download to a file (do NOT pipe): a pipe would consume the script's stdin
  # when this installer itself is run via `curl ... | sh`.
  if ! curl -fsSL "$ARCHIVE_URL" -o "$TMPDIR/aiprj.tar.gz"; then
    echo "Error: Failed to download repository. Please check your network connection." >&2
    exit 1
  fi
  if ! tar xzf "$TMPDIR/aiprj.tar.gz" --strip-components=1 -C "$TMPDIR/aiprj"; then
    echo "Error: Failed to extract repository archive." >&2
    exit 1
  fi
}

echo "aiprj: Setting up project..."

# Determine the directory containing this script (for local execution)
case "$0" in
  */*) SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd) ;;
  *) SCRIPT_DIR=$(pwd) ;;
esac

# Use the local checkout if this script is run from one; otherwise fetch the repo
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/install.sh" ] && [ -d "$SCRIPT_DIR/.aiprj" ] && [ -d "$SCRIPT_DIR/.claude" ] && [ -f "$SCRIPT_DIR/README.md" ]; then
  echo "Using local repository at $SCRIPT_DIR"
  SRC="$SCRIPT_DIR"
else
  # Prefer the tarball: it works for any public repo, needs no auth, and does
  # not read stdin -- important when this installer is run via `curl ... | sh`,
  # where an auth-prompting `git clone` would swallow the rest of the script.
  if command -v tar >/dev/null 2>&1; then
    download_archive
  elif command -v git >/dev/null 2>&1; then
    echo "Fetching repository via git clone..."
    GIT_TERMINAL_PROMPT=0 git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMPDIR/aiprj" </dev/null 2>/dev/null || {
      echo "Error: Failed to clone repository. Please check your network connection." >&2
      exit 1
    }
  else
    echo "Error: need either tar or git to fetch the repository." >&2
    exit 1
  fi
  SRC="$TMPDIR/aiprj"
fi

# Create target directory if needed
if [ -d "$DIR" ]; then
  [ "$DIR" != "." ] && echo "Updating existing directory."
else
  mkdir -p "$DIR"
fi

# Guard against copying the repository onto itself
SRC_ABS=$(CDPATH= cd -- "$SRC" 2>/dev/null && pwd)
DIR_ABS=$(CDPATH= cd -- "$DIR" 2>/dev/null && pwd)
if [ -n "$SRC_ABS" ] && [ "$SRC_ABS" = "$DIR_ABS" ]; then
  echo "Error: Source and target are the same directory ($SRC_ABS)." >&2
  echo "Run the installer from the aiprj checkout and specify a different target directory." >&2
  exit 1
fi

# Copy template files
for d in .aiprj .claude .agent-cli; do
  if [ -d "$SRC/$d" ]; then
    cp -r "$SRC/$d" "$DIR/"
  fi
done

cp "$SRC/README.md" "$DIR/.aiprj/"

# Manage instructions.md
if [ -f "$DIR/.aiprj/instructions.md" ]; then
  echo "------------------------------"
  echo "Current instructions"
  echo "------------------------------"
  cat "$DIR/.aiprj/instructions.md"
  echo ""
  echo "------------------------------"
  [ -f "$DIR/.aiprj/instructions.md.org" ] && rm "$DIR/.aiprj/instructions.md.org"
elif [ -f "$DIR/.aiprj/instructions.md.org" ]; then
  mv "$DIR/.aiprj/instructions.md.org" "$DIR/.aiprj/instructions.md"
fi

# Manage .gitignore (prevent duplicates)
if [ -f "$DIR/.gitignore" ]; then
  if ! grep -qxF ".aiprj" "$DIR/.gitignore"; then
    TMP_GI="$(mktemp)"
    cat "$SRC/.gitignore.aiprj" "$DIR/.gitignore" > "$TMP_GI"
    mv "$TMP_GI" "$DIR/.gitignore"
  fi
else
  cp "$SRC/.gitignore.aiprj" "$DIR/.gitignore"
fi

echo ""
echo "aiprj setup complete: $DIR"
