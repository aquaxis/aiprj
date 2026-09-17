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

### ブランチを指定してセットアップ

インストーラは既定で`main`ブランチを取得します。`AIPRJ_BRANCH`で変更できます：

```bash
AIPRJ_BRANCH=develop curl -fsSL https://raw.githubusercontent.com/aquaxis/aiprj/main/install.sh | sh
```

### インストーラのオプション

| オプション | 説明 |
|-----------|------|
| `-u`, `--uninstall` | 対象ディレクトリからaiprjのファイルを削除 |
| `-f`, `--force` | 確認プロンプトを省略（アンインストール時のみ） |
| `-h`, `--help` | ヘルプを表示 |

セットアップにより以下のファイルが作成されます：

- `.aiprj/` - AIルール、`instructions.md`、`README.md`
- `.claude/` - Claude Codeの設定とスラッシュコマンド
- `.agent-cli/` - Claude Code以外のエージェントCLI向けの同等の設定とコマンド
- `.gitignore` - Git ignore設定（既存ファイルがある場合は先頭に追加。既に記載済みならスキップ）

### 再セットアップ時の動作

既存のインストールに対して再実行すると、ルールとコマンド定義は更新されますが、
**既存の`.aiprj/instructions.md`は上書きされません**。現在の内容がコンソールに表示され、
ファイルはそのまま保持されます。`instructions.md.org`から`instructions.md`へのリネームは、
`instructions.md`がまだ存在しない場合にのみ行われます。

## アンインストール

```bash
./install.sh -u <対象ディレクトリ>          # 確認プロンプトあり
./install.sh -u <対象ディレクトリ> --force  # 確認なし
```

| | 対象 |
|---|---|
| **削除される** | `.aiprj/`（ルール、instructions、作業ログ、プロジェクトドキュメント）、`.claude/commands/`と`.agent-cli/commands/`配下のaiprjスラッシュコマンド5点、`.gitignore`内のaiprj関連エントリ |
| **保持される** | `.claude/settings.json`、`.claude/settings.local.json`、`.mcp.json` - ユーザーのカスタマイズを含む可能性があるため |

aiprjのエントリを削除した結果`.gitignore`が空になった場合、ファイル自体が削除されます。

## 使い方

### Claude Codeスラッシュコマンド

| コマンド | 説明 |
|---------|------|
| `/setup_ai` | プロジェクトドキュメント（要件、設計、タスク）を作成 |
| `/ai` | `instructions.md`に基づいてタスクを実行 |
| `/update_ai` | プロジェクトドキュメントを更新 |
| `/next_ai` | 次のタスクに進む |
| `/close_ai` | 作業ログを保存して終了 |

各コマンド定義は`.aiprj/rules/`内の対応するルールを`@`参照するだけの薄いラッパーです。
例外が2つあり、`next_ai`はルール参照を持たず「次のジョブへ進む」というリテラルの指示のみ、
`close_ai`はルール参照に加えて`exit`を含むため、ログ保存後にセッション自体が終了します。

### コマンド別の適用ルールと書き込み範囲

各コマンドが読み込むルールによって、AIが書き込みを許可されるファイルの範囲が決まります。

| コマンド | ルールファイル | 適用ガイドライン | 書き込み許可範囲 |
|---------|--------------|----------------|----------------|
| `/setup_ai` | `rules/setup_project.md` | AI運用（第1〜8条）＋ AIプロジェクト仕様（第1〜4条） | 3つのプロジェクトドキュメントのみ。他ファイルの作成・変更は禁止 |
| `/ai` | `rules/exec_job.md` | AI運用（第1〜8条）＋ AIコーディング（第1〜3条） | 制限なし（実装作業）。タスク状態が変化するたびに`AI_PRJ_TASKS.md`の更新が必須 |
| `/update_ai` | `rules/update_project.md` | AI更新（第1〜4条） | 3つのプロジェクトドキュメント、および作業ログ |
| `/next_ai` | なし | - | 現在のセッションのコンテキストを引き継ぐ |
| `/close_ai` | `rules/close_ai.md` | 作業ログ規約（第1条） | 作業ログのみ。保存後に`exit` |

### ドキュメントの整合性

`AI_PRJ_REQUIREMENTS.md`、`AI_PRJ_DESIGN.md`、`AI_PRJ_TASKS.md`は一貫した1セットとして扱われます。
`/ai`と`/update_ai`はいずれも、3ドキュメント間の不整合を検出した場合、
**残りの作業を進める前に解消すること**をAIに要求します。

### ウォークスルー：セットアップから作業完了まで

以下の例では`~/work/todo-api`に小さなREST APIを構築します。

#### 1. プロジェクトディレクトリにインストール

```bash
mkdir -p ~/work/todo-api && cd ~/work/todo-api
curl -fsSL https://raw.githubusercontent.com/aquaxis/aiprj/main/install.sh | sh
```

```
aiprj: Setting up project...
Downloading via curl + tar...

aiprj setup complete: .
```

この時点で`.aiprj/instructions.md`は作成されていますが、中身は
`Write instructions here`というプレースホルダのみです。

#### 2. 作りたいものを`instructions.md`に記述

手で書くのはこのファイルだけです。書式は自由なので、同僚への作業依頼を書く要領で構いません。
制約を具体的に書くほど、AIが推測で補う余地が減ります。

```bash
$EDITOR .aiprj/instructions.md
```

```markdown
# TODO API

TODOアイテムを管理するREST APIを構築する。

## 機能要件
- TODOアイテムのCRUDエンドポイント（作成・一覧・更新・削除）
- 各アイテムの属性: id, title, 完了フラグ, created_at
- 一覧エンドポイントは完了状態でフィルタ可能

## 技術制約
- Node.js + TypeScript + Fastify
- 永続化はSQLite（better-sqlite3を使用）
- vitestによるユニットテスト、カバレッジ80%以上
- 初回イテレーションでは認証を実装しない
```

#### 3. `/setup_ai`でプロジェクトドキュメントを生成

```
claude
> /setup_ai
```

AIが`instructions.md`を読み込み、3つのドキュメントを作成します。このコマンドの実行中、AIは
**この3ファイルへの書き込みのみが許可**されており、ソースコードにはまだ一切手を付けません。

```
.aiprj/
├── instructions.md              # ステップ2で記述した内容
├── AI_PRJ_REQUIREMENTS.md       # 生成: 機能要件・非機能要件
├── AI_PRJ_DESIGN.md             # 生成: エンドポイント、スキーマ、モジュール構成
└── AI_PRJ_TASKS.md              # 生成: 順序付きタスクリスト
```

`AI_PRJ_TASKS.md`は概ね次のような形で出力されます：

```markdown
| # | タスク | 状態 |
|---|--------|------|
| 1 | プロジェクト初期化（package.json, tsconfig, vitest） | 未着手 |
| 2 | SQLiteスキーマとマイグレーションの定義 | 未着手 |
| 3 | TODOリポジトリ層の実装 | 未着手 |
| 4 | CRUDエンドポイントの実装 | 未着手 |
| 5 | 完了状態フィルタの追加 | 未着手 |
| 6 | カバレッジ80%までのユニットテスト作成 | 未着手 |
```

**次に進む前に、必ず3つのドキュメントをレビューしてください。** これ以降のすべてのコマンドは
このドキュメントを契約として動作します。認識のズレをここで直すコストは、実装後に直すコストより
はるかに小さく済みます。

#### 4. `/ai`でタスクを実行

```
> /ai
```

`/setup_ai`とは異なり、このコマンドはプロジェクト内のどこにでも書き込めます（実装フェーズのため）。
AIはまず作業計画を立案し（第1条）、タスクリストを順に処理しながら、状態が変化するたびに
`AI_PRJ_TASKS.md`の「状態」列を更新します：

```markdown
| 1 | プロジェクト初期化（package.json, tsconfig, vitest） | 完了 |
| 2 | SQLiteスキーマとマイグレーションの定義 | 進行中 |
```

#### 5. `/next_ai`で次のタスクへ

```
> /next_ai
```

「次のジョブへ進む」という一行の指示のみのコマンドです。コンテキストを再度説明することなく、
AIに次のタスクへ着手させます。繰り返し使ってタスクリストを消化していきます：

```
> /ai        # タスク1
> /next_ai   # タスク2
> /next_ai   # タスク3
```

#### 6. `/close_ai`でセッションを終了

```
> /close_ai
```

作業ログが`.aiprj/AI_LOG/`に書き出され、セッションが終了します。ファイル名は
`YYYY-MM-DD_NNN.md`形式で、`NNN`は`000`始まりのゼロ埋め連番です。ログごとにインクリメントされ、
**既存のログが上書きされることはありません**：

```
.aiprj/AI_LOG/
├── 2026-09-17_000.md   # その日の1回目のセッション
├── 2026-09-17_001.md   # 同じ日の2回目のセッション
└── 2026-09-18_000.md   # 日付が変わると連番はリセット
```

各ログには実行時点の`instructions.md`の全文が埋め込まれます（第7条）。そのため、
instructions.mdがその後更新されても、当時のログは単体で読める状態が保たれます。

### 途中で要件が変わった場合

`instructions.md`を編集し、`/update_ai`でドキュメント群を追従させます：

```bash
$EDITOR .aiprj/instructions.md   # 例: TODOアイテムに「期限」を追加
```

```
> /update_ai
```

`/update_ai`は`instructions.md`を再読込し、3つのドキュメントを現在の内容に合わせて書き直します。
その際、ドキュメント間に不整合があれば完了前に解消します。書き込みはこの3ドキュメントと作業ログに
限定されるため、ソースコードは変更されません。実装への反映は続けて`/ai`を実行します。

```
> /ai
```

方向性を変えたいときに`AI_PRJ_*.md`を直接手で編集するのは**避けてください**。`instructions.md`を
変更して`/update_ai`を実行することで、instructions.mdを唯一の情報源として維持できます。

### 典型的な1日の流れ

```bash
cd ~/work/todo-api
claude
```

```
> /update_ai    # instructions.mdを変更した場合のみ
> /ai           # 次のタスクを実行
> /next_ai      # さらに次のタスク
> /next_ai
> /close_ai     # 2026-09-17_000.mdを書き出して終了
```

### 注意：プロジェクトドキュメントは既定でgit管理外

同梱の`.gitignore`テンプレートは`.aiprj`に加えて`AI_LOG/`と3つの`AI_PRJ_*.md`を除外するため、
要件・設計・タスク・作業ログは**ローカルに留まりコミットされません**。個人の試行錯誤には
適した既定値ですが、チームで同じ契約を共有したい場合は`.gitignore`から`.aiprj`の行を削除して
ディレクトリをコミットしてください。

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
8. 生成・更新したファイルにAIが関与した痕跡を残さないこと

作業ログの`NNN`は`000`から始まるゼロ埋めの連番です。

## 権限・エージェント設定

コマンドと併せて`.claude/settings.json`（および同等の`.agent-cli/settings.json`）が同梱されます。

**禁止（deny）**: `rm -rf ~/**`と`rm -rf //**`、`git remote add` / `git remote set-url`（リモートの
差し替え防止）、`npm publish` / `pnpm publish`（誤公開の防止）、`tmp/**`・`node_modules/`・`*.log`・
`.env*`の読み取り（機密情報とノイズの除外）。

**許可（allow）**: `git`、`gh`、`node`、`pnpm`、および`touch` / `mkdir` / `cp` / `mv` / `rm` /
`find` / `grep` / `rg`、`Read(**)`、`Edit(**)`、`WebFetch`。編集モードの既定は`acceptEdits`です。

**その他の設定**: ステータスラインは`npx -y ccusage statusline --no-offline`でトークン使用量を表示し、
環境変数として`BASH_DEFAULT_TIMEOUT_MS=300000`、`BASH_MAX_TIMEOUT_MS=1200000`、
`DISABLE_AUTOUPDATER=0`が設定されます。

`.agent-cli/settings.json`は上記と同一で、`MultiEdit(**)`と`Write(**)`の許可のみが追加されています。

## ファイル構成

```
aiprj/
├── install.sh               # セットアップスクリプト
├── .gitignore.aiprj         # gitignoreテンプレート
├── .aiprj/
│   ├── instructions.md.org  # インストラクションテンプレート
│   └── rules/
│       ├── setup_project.md  # セットアップルール
│       ├── exec_job.md       # タスク実行ルール
│       ├── update_project.md # 更新ルール
│       └── close_ai.md       # 終了ルール
├── .claude/                 # Claude Code用
│   ├── settings.json        # Claude Code設定
│   └── commands/            # スラッシュコマンド定義
│       ├── setup_ai.md
│       ├── ai.md
│       ├── update_ai.md
│       ├── next_ai.md
│       └── close_ai.md
└── .agent-cli/              # Claude Code互換エージェントCLI用
    ├── settings.json        # .claude/settings.json＋Write/MultiEdit
    └── commands/            # .claude/commands/と同一内容
```

## 動作要件

- `curl`（セットアップ用）
- `tar`（ワンライナーフォールバック用）、または `git`
- Claude Code CLI、またはClaude Code互換のエージェントCLI
- Node.js / `npx`（任意。`ccusage`ステータスライン表示用）

## ライセンス

[MIT License](./LICENSE.md)