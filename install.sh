#!/bin/sh
set -e

REPO_URL="https://github.com/aquaxis/aiprj.git"
ARCHIVE_URL="https://github.com/aquaxis/aiprj/archive/main.tar.gz"

# 依存コマンドの確認
check_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "エラー: $1 が見つかりません。インストールしてください。"
    exit 1
  fi
}

check_command curl

# 一時ディレクトリの作成とクリーンアップ設定
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# curl + tar によるダウンロード（フォールバック用）
download_archive() {
  echo "curl + tar でダウンロードします..."
  check_command tar
  mkdir -p "$TMPDIR/aiprj"
  curl -sL "$ARCHIVE_URL" | tar xz --strip-components=1 -C "$TMPDIR/aiprj" || {
    echo "エラー: リポジトリのダウンロードに失敗しました。ネットワーク接続を確認してください。"
    exit 1
  }
}

# セットアップ先ディレクトリの決定
DIR="${1:-.}"
DIR="${DIR%/}"

echo "aiprj: プロジェクトをセットアップしています..."

# リポジトリの取得
if command -v git >/dev/null 2>&1; then
  echo "git clone でリポジトリを取得しています..."
  git clone --depth 1 "$REPO_URL" "$TMPDIR/aiprj" 2>/dev/null || {
    echo "git clone に失敗しました。"
    rm -rf "$TMPDIR/aiprj"
    download_archive
  }
else
  echo "git が見つかりません。"
  download_archive
fi

# セットアップ先ディレクトリの作成
if [ "$DIR" != "." ]; then
  if [ -d "$DIR" ]; then
    echo "既存のディレクトリをアップデートします。"
  else
    mkdir -p "$DIR"
  fi
fi

# テンプレートファイルのコピー
for dir in .aiprj .claude .gemini .codex; do
  if [ -d "$TMPDIR/aiprj/$dir" ]; then
    cp -r "$TMPDIR/aiprj/$dir" "$DIR/"
  fi
done

cp "$TMPDIR/aiprj/.mcp.json" "$DIR/"

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

# .gitignore の管理
if [ -f "$DIR/.gitignore" ]; then
  if ! grep -q "^\.aiprj$" "$DIR/.gitignore"; then
    cat "$DIR/.gitignore" > "$DIR/.gitignore.bak"
    cat "$TMPDIR/aiprj/.gitignore.org" "$DIR/.gitignore.bak" > "$DIR/.gitignore"
    rm "$DIR/.gitignore.bak"
  fi
else
  cat "$TMPDIR/aiprj/.gitignore.org" > "$DIR/.gitignore"
fi

echo ""
echo "aiprj のセットアップが完了しました: $DIR"
