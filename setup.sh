#!/bin/bash

if [ -z "$1" ]; then
  echo "引数がありません。"
  echo "[Usage] "$0" 作成するディレクトリ名"
  exit 1
fi

echo "Setup AI Project: "$1

if [ -d ディレクトリ名 ]; then
  echo "既存のディレクトリをアップデートします。"
else
  mkdir $1
fi

cp -r .claude $1/
cp -r .gemini $1/

cp .mcp.json $1/
cp AI_* $1/

if [ -f $1/.gitignore ]; then
  cat $1/.gitignore $1/.gitignore.org
  cat .gitignore.org $1/.gitignore.org > $1/.gitignore
else
  cat .gitignore.org > $1/.gitignore
fi
