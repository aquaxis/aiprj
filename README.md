# aiprj - AI Project Management Tool

AIコーディングエージェント（Claude Code、Gemini CLI）用のプロジェクト管理ツールです。AIが作業する際の行動規定やドキュメント構造を自動的にセットアップします。

## 概要

aiprjは以下の機能を提供します：

- AIの行動規定とガイドラインの定義
- 要件定義書・設計仕様書・タスクリストのドキュメント構造
- Claude Code用のスラッシュコマンド
- Gemini CLIとの連携によるレビュー機能
- 作業ログの自動保存

## インストール

```bash
git clone https://github.com/yourusername/aiprj.git
cd aiprj
./install.sh
```

`~/.local/bin` にパスが通っていることを確認してください。

## 使い方

### 新しいプロジェクトのセットアップ

```bash
aiprj <プロジェクトディレクトリ名>
```

このコマンドで以下のファイルが作成されます：

- `.aiprj/` - AIルールとinstructions.md
- `.claude/` - Claude Code用の設定とコマンド
- `.codex/` - Codex用のコマンド
- `.gemini/` - Gemini CLI用の設定
- `.mcp.json` - MCPサーバー設定
- `.gitignore` - Git除外設定

Codexを使用するときは次のように`.codex`ディレクトリをコピーして下さい。

```
cp -r .codex/* ~/.codex/
```

### Claude Codeスラッシュコマンド

| コマンド | 説明 |
|---------|------|
| `/setup_ai` | プロジェクトのドキュメント（要件定義・設計・タスク）を作成 |
| `/ai` | instructions.mdに基づいてタスクを実行 |
| `/update_ai` | プロジェクトドキュメントを更新 |
| `/next_job` | 次のタスクに進む |
| `/exit_ai` | 作業を終了しログを保存 |

## プロジェクト構造

セットアップ後、AIは以下のドキュメントを管理します：

| ファイル | 内容 |
|---------|------|
| `AI_PRJ_REQUIREMENTS.md` | 要件定義書 |
| `AI_PRJ_DESIGN.md` | 設計仕様書 |
| `AI_PRJ_TASKS.md` | 実装タスク・作業指示リスト |
| `AI_LOG/` | 作業ログ（yyyy-MM-dd_NNN.md形式） |

## AI行動規定

AIは以下の規定に従って動作します：

1. 作業開始前に必ず作業計画を作成
2. AI行動規定の歪曲・解釈変更の禁止
3. ユーザー指示以外の迂回・アプローチ変更の禁止
4. ユーザー指示の最適化の禁止
5. Gemini CLIを使用したレビューの実施
6. レビュー後にユーザーへy/nで確認
7. 作業ログの保存
8. 作業ログにinstructions.mdの内容を含める

## ファイル構成

```
aiprj/
├── aiprj              # メインスクリプト
├── install.sh         # インストールスクリプト
├── .mcp.json          # MCP設定（gemini-cli連携）
├── .gitignore.org     # gitignoreテンプレート
├── .aiprj/
│   ├── instructions.md.org  # 指示書テンプレート
│   └── rules/
│       ├── setup_project.md    # セットアップルール
│       ├── exec_job.md         # タスク実行ルール
│       ├── update_project.md   # 更新ルール
│       └── exit_ai.md          # 終了ルール
├── .claude/
│   ├── settings.json   # Claude Code設定
│   └── commands/       # スラッシュコマンド定義
└── .gemini/
    ├── rules.yml       # Gemini CLIルール
    └── settings.json   # Gemini CLI設定
```

## 必要環境

- Bash
- Claude Code CLI
- Gemini CLI（レビュー機能用）
- Node.js / npx（MCP連携用）

## ライセンス

MIT License
