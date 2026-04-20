#!/bin/sh
set -e

REPO_URL="https://github.com/aquaxis/aiprj.git"
BRANCH="${AIPRJ_BRANCH:-main}"
ARCHIVE_URL="https://github.com/aquaxis/aiprj/archive/${BRANCH}.tar.gz"

check_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "エラー: $1 が見つかりません。インストールしてください。" >&2
    exit 1
  fi
}

check_command curl

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

download_archive() {
  echo "curl + tar でダウンロードします..."
  check_command tar
  mkdir -p "$TMPDIR/aiprj"
  curl -fsSL "$ARCHIVE_URL" | tar xz --strip-components=1 -C "$TMPDIR/aiprj" || {
    echo "エラー: リポジトリのダウンロードに失敗しました。ネットワーク接続を確認してください。" >&2
    exit 1
  }
}

DIR="${1:-.}"
DIR="${DIR%/}"

echo "aiprj: プロジェクトをセットアップしています..."

# ローカル実行（リポジトリ直下）ならダウンロードをスキップ
if [ -f "./install.sh" ] && [ -d "./.aiprj" ] && [ -d "./.claude" ] && [ -f "./README.md" ] && [ "$DIR" != "." ]; then
  SRC="$(pwd)"
else
  if command -v git >/dev/null 2>&1; then
    echo "git clone でリポジトリを取得しています..."
    git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMPDIR/aiprj" 2>/dev/null || {
      echo "git clone に失敗しました。"
      rm -rf "$TMPDIR/aiprj"
      download_archive
    }
  else
    echo "git が見つかりません。"
    download_archive
  fi
  SRC="$TMPDIR/aiprj"
fi

if [ "$DIR" != "." ]; then
  if [ -d "$DIR" ]; then
    echo "既存のディレクトリをアップデートします。"
  else
    mkdir -p "$DIR"
  fi
fi

# テンプレートファイルのコピー
for d in .aiprj .claude; do
  if [ -d "$SRC/$d" ]; then
    cp -r "$SRC/$d" "$DIR/"
  fi
done

cp "$SRC/.mcp.json" "$DIR/"
cp "$SRC/README.md" "$DIR/.aiprj/"

# instructions.md の管理
if [ -f "$DIR/.aiprj/instructions.md" ]; then
  echo "------------------------------"
  echo "現在のインストラクション"
  echo "------------------------------"
  cat "$DIR/.aiprj/instructions.md"
  echo ""
  echo "------------------------------"
  [ -f "$DIR/.aiprj/instructions.md.org" ] && rm "$DIR/.aiprj/instructions.md.org"
elif [ -f "$DIR/.aiprj/instructions.md.org" ]; then
  mv "$DIR/.aiprj/instructions.md.org" "$DIR/.aiprj/instructions.md"
fi

# .gitignore の管理（重複防止）
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
echo "aiprj のセットアップが完了しました: $DIR"
