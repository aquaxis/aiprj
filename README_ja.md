# aiprj - AIプロジェクト管理ツール

Claude Code向けのプロジェクト管理ツールです。AI運用ガイドラインとドキュメント構造（要件、設計、タスク）を1つのコマンドで対象ディレクトリに展開します。

## 概要

aiprjは以下の機能を提供します：

- AI運用ガイドラインとルールの定義
- 要件定義、設計仕様、タスクリストのドキュメント構造
- Claude Code用スラッシュコマンド（`/setup_ai` `/ai` `/update_ai` `/next_ai` `/close_ai`）
- 作業ログの自動保存（`.aiprj/AI_LOG/yyyy-MM-dd_NNN.md`）

## セットアップ

### カレントディレクトリにセットアップ

```bash
curl -fsSL https://raw.githubusercontent.com/aquaxis/aiprj/main/install.sh | sh
```

### 指定ディレクトリにセットアップ

```bash
curl -fsSL https://raw.githubusercontent.com/aquaxis/aiprj/main/install.sh | sh -s -- <ディレクトリ名>
```

### 手動セットアップ

```bash
git clone https://github.com/aquaxis/aiprj.git
cd aiprj
./install.sh <対象ディレクトリ>
```

セットアップにより以下のファイルが作成されます：

- `.aiprj/` - AIルール、`instructions.md`、`README.md`
- `.claude/` - Claude Codeの設定とスラッシュコマンド
- `.mcp.json` - MCPサーバー設定
- `.gitignore` - Git ignore設定（既存ファイルがある場合は先頭に追加）

### Claude Codeスラッシュコマンド

| コマンド | 説明 |
|---------|------|
| `/setup_ai` | プロジェクトドキュメント（要件、設計、タスク）を作成 |
| `/ai` | `instructions.md`に基づいてタスクを実行 |
| `/update_ai` | プロジェクトドキュメントを更新 |
| `/next_ai` | 次のタスクに進む |
| `/close_ai` | 作業ログを保存して終了 |

## プロジェクト構成

セットアップ後、AIは以下のドキュメントを管理します：

| ファイル | 内容 |
|---------|------|
| `.aiprj/AI_PRJ_REQUIREMENTS.md` | 要件定義ドキュメント |
| `.aiprj/AI_PRJ_DESIGN.md` | 設計仕様ドキュメント |
| `.aiprj/AI_PRJ_TASKS.md` | 実装タスク・作業指示一覧 |
| `.aiprj/AI_LOG/` | 作業ログ（`yyyy-MM-dd_NNN.md`形式、連番、上書き不可） |

## AI運用ガイドライン

AIは以下のガイドラインに従って動作します：

1. いかなるタスクを開始する前に、必ず作業計画を立案すること
2. AI運用ガイドラインを歪曲または再解釈することを禁止する
3. ユーザーの指示を超えて、迂回や手法の変更を行うことを禁止する
4. ユーザーの指示を最適化・書き換え・再解釈することを禁止する
5. ユーザーの指示が完全に完了するまで停止してはならない
6. 作業ログは`.aiprj/AI_LOG/`に`yyyy-MM-dd_NNN.md`形式で保存すること（連番、上書き不可）
7. 作業ログには`.aiprj/instructions.md`の内容を含めること

## ファイル構成

```
aiprj/
├── install.sh               # セットアップスクリプト
├── .mcp.json                # MCP設定
├── .gitignore.aiprj         # gitignoreテンプレート
├── .aiprj/
│   ├── instructions.md.org  # インストラクションテンプレート
│   └── rules/
│       ├── setup_project.md  # セットアップルール
│       ├── exec_job.md       # タスク実行ルール
│       ├── update_project.md # 更新ルール
│       └── close_ai.md       # 終了ルール
└── .claude/
    ├── settings.json        # Claude Code設定
    └── commands/            # スラッシュコマンド定義
        ├── setup_ai.md
        ├── ai.md
        ├── update_ai.md
        ├── next_ai.md
        └── close_ai.md
```

## 動作要件

- `curl`（セットアップ用）
- `tar`（ワンライナーフォールバック用）、または `git`
- Claude Code CLI
- Node.js / `npx`（MCP統合用）

## ライセンス

[MIT License](./LICENSE.md)