# aiprj - AI Project Management Tool

A project management tool for Claude Code. It deploys AI operation guidelines and document structure (requirements, design, tasks) to a target directory with a single command.

## Overview

aiprj provides the following features:

- Definition of AI operation guidelines and rules
- Document structure for requirements, design specifications, and task lists
- Slash commands for Claude Code (`/setup_ai` `/ai` `/update_ai` `/next_ai` `/close_ai`)
- Automatic work log saving (`.aiprj/AI_LOG/yyyy-MM-dd_NNN.md`)

## Setup

### Setup in current directory

```bash
curl -fsSL https://raw.githubusercontent.com/aquaxis/aiprj/main/install.sh | sh
```

### Setup in a specified directory

```bash
curl -fsSL https://raw.githubusercontent.com/aquaxis/aiprj/main/install.sh | sh -s -- <directory_name>
```

### Manual setup

```bash
git clone https://github.com/aquaxis/aiprj.git
cd aiprj
./install.sh <target_directory>
```

### Installing from a different branch

The installer fetches the `main` branch by default. Set `AIPRJ_BRANCH` to use another one:

```bash
AIPRJ_BRANCH=develop curl -fsSL https://raw.githubusercontent.com/aquaxis/aiprj/main/install.sh | sh
```

### Installer options

| Option | Description |
|--------|-------------|
| `-u`, `--uninstall` | Remove aiprj files from the target directory |
| `-f`, `--force` | Skip the confirmation prompt (uninstall only) |
| `-h`, `--help` | Show the help message |

The following files are created by setup:

- `.aiprj/` - AI rules, `instructions.md`, `README.md`
- `.claude/` - Claude Code settings and slash commands
- `.agent-cli/` - Equivalent settings and commands for agent CLIs other than Claude Code
- `.gitignore` - Git ignore configuration (prepended to existing file if present, skipped if the entries already exist)

### Re-running the installer

Re-running the installer over an existing installation refreshes the rules and command
definitions, but **an existing `.aiprj/instructions.md` is never overwritten** - its current
contents are printed to the console and left in place. The `instructions.md.org` template is
only renamed to `instructions.md` when no `instructions.md` exists yet.

## Uninstall

```bash
./install.sh -u <target_directory>          # asks for confirmation
./install.sh -u <target_directory> --force  # no prompt
```

| | Items |
|---|---|
| **Removed** | `.aiprj/` (rules, instructions, work logs, project documents), the five aiprj slash commands under `.claude/commands/` and `.agent-cli/commands/`, and aiprj entries in `.gitignore` |
| **Preserved** | `.claude/settings.json`, `.claude/settings.local.json`, `.mcp.json` - these may contain your own customizations |

If `.gitignore` becomes empty after the aiprj entries are removed, the file itself is deleted.

## Usage

### Claude Code Slash Commands

| Command | Description |
|---------|-------------|
| `/setup_ai` | Create project documents (requirements, design, tasks) |
| `/ai` | Execute tasks based on `instructions.md` |
| `/update_ai` | Update project documents |
| `/next_ai` | Proceed to next task |
| `/close_ai` | Save work log and exit |

Each command file is a thin wrapper that `@`-references its rule under `.aiprj/rules/`.
Two exceptions: `next_ai` carries no rule reference (it is just the literal instruction
"Go next job"), and `close_ai` appends `exit` so the session itself ends after the log is saved.

### Rules and write scope per command

The rule loaded by each command determines which files the AI is permitted to write.

| Command | Rule file | Guidelines applied | Write scope |
|---------|-----------|--------------------|-------------|
| `/setup_ai` | `rules/setup_project.md` | Operation (Art. 1-8) + Project Specifications (Art. 1-4) | The three project documents only - creating or modifying any other file is prohibited |
| `/ai` | `rules/exec_job.md` | Operation (Art. 1-8) + Coding (Art. 1-3) | Unrestricted (implementation work); `AI_PRJ_TASKS.md` must be updated on every task status change |
| `/update_ai` | `rules/update_project.md` | Update (Art. 1-4) | The three project documents, plus work logs |
| `/next_ai` | none | - | Inherits the current session context |
| `/close_ai` | `rules/close_ai.md` | Work-log rule (Art. 1) | Work logs only, then `exit` |

### Document consistency

`AI_PRJ_REQUIREMENTS.md`, `AI_PRJ_DESIGN.md`, and `AI_PRJ_TASKS.md` are treated as a single
consistent set. Both `/ai` and `/update_ai` require the AI to detect any inconsistency among the
three documents and **resolve it before proceeding** with the rest of the work.

### Walkthrough: from installation to a finished task

The example below builds a small REST API in `~/work/todo-api`.

#### 1. Install into the project directory

```bash
mkdir -p ~/work/todo-api && cd ~/work/todo-api
curl -fsSL https://raw.githubusercontent.com/aquaxis/aiprj/main/install.sh | sh
```

```
aiprj: Setting up project...
Downloading via curl + tar...

aiprj setup complete: .
```

At this point `.aiprj/instructions.md` exists but only contains the placeholder text
`Write instructions here`.

#### 2. Write what you want built into `instructions.md`

This is the only file you author by hand. It is free-form - write it as you would a brief for a
colleague. The more concrete the constraints, the less the AI has to guess.

```bash
$EDITOR .aiprj/instructions.md
```

```markdown
# TODO API

Build a REST API for managing TODO items.

## Functional requirements
- CRUD endpoints for TODO items (create, list, update, delete)
- Each item has: id, title, completed flag, created_at
- Filter the list endpoint by completion state

## Technical constraints
- Node.js + TypeScript + Fastify
- SQLite for persistence (via better-sqlite3)
- Unit tests with vitest, minimum 80% coverage
- No authentication in the first iteration
```

#### 3. Generate the project documents with `/setup_ai`

```
claude
> /setup_ai
```

The AI reads `instructions.md` and creates three documents. During this command it is **only
allowed to write those three files** - it will not touch your source tree yet.

```
.aiprj/
├── instructions.md              # what you wrote in step 2
├── AI_PRJ_REQUIREMENTS.md       # created: functional / non-functional requirements
├── AI_PRJ_DESIGN.md             # created: endpoints, schema, module layout
└── AI_PRJ_TASKS.md              # created: the ordered task list
```

`AI_PRJ_TASKS.md` typically comes out looking like this:

```markdown
| # | Task | Status |
|---|------|--------|
| 1 | Set up the project (package.json, tsconfig, vitest) | Not started |
| 2 | Define the SQLite schema and migrations | Not started |
| 3 | Implement the TODO repository layer | Not started |
| 4 | Implement the CRUD endpoints | Not started |
| 5 | Add the completion-state filter | Not started |
| 6 | Write unit tests to 80% coverage | Not started |
```

**Review the three documents before continuing.** They are the contract every later command works
from - correcting a misunderstanding here is far cheaper than correcting it after implementation.

#### 4. Execute tasks with `/ai`

```
> /ai
```

Unlike `/setup_ai`, this command may write anywhere in the project - it is the implementation
step. The AI plans first (Article 1), works through the task list, and updates the `Status`
column in `AI_PRJ_TASKS.md` as each task changes state:

```markdown
| 1 | Set up the project (package.json, tsconfig, vitest) | Done |
| 2 | Define the SQLite schema and migrations | In progress |
```

#### 5. Move on with `/next_ai`

```
> /next_ai
```

A one-line nudge ("Go next job") that tells the AI to pick up the next task without re-stating
the context. Use it repeatedly to work down the list:

```
> /ai        # task 1
> /next_ai   # task 2
> /next_ai   # task 3
```

#### 6. Close the session with `/close_ai`

```
> /close_ai
```

The work log is written to `.aiprj/AI_LOG/` and the session exits. The filename is
`YYYY-MM-DD_NNN.md`, where `NNN` is a zero-padded counter starting at `000` that increments per
log - **existing logs are never overwritten**:

```
.aiprj/AI_LOG/
├── 2026-09-17_000.md   # first session of the day
├── 2026-09-17_001.md   # second session of the same day
└── 2026-09-18_000.md   # counter restarts the next day
```

Each log embeds the full contents of `instructions.md` as it was at execution time (Article 7),
so a log stays readable even after the instructions have moved on.

### Changing the requirements mid-project

Edit `instructions.md`, then reconcile the documents with `/update_ai`:

```bash
$EDITOR .aiprj/instructions.md   # e.g. add "due date" to each TODO item
```

```
> /update_ai
```

`/update_ai` re-reads `instructions.md` and rewrites all three documents to match, resolving any
inconsistency between them before it finishes. It may only write those three documents plus the
work log, so your source tree is untouched - run `/ai` afterwards to implement the change.

```
> /ai
```

Do **not** hand-edit `AI_PRJ_*.md` to change direction. Change `instructions.md` and re-run
`/update_ai`, so that the instructions remain the single source of truth.

### A typical day

```bash
cd ~/work/todo-api
claude
```

```
> /update_ai    # only if instructions.md changed since last time
> /ai           # work the next task
> /next_ai      # and the one after
> /next_ai
> /close_ai     # writes 2026-09-17_000.md and exits
```

### Note: the project documents are git-ignored by default

The bundled `.gitignore` template ignores `.aiprj` along with `AI_LOG/` and the three
`AI_PRJ_*.md` files, so requirements, design, tasks, and work logs stay **local and uncommitted**.
That is the right default for scratch work, but if you want the team to share the same contract,
remove the `.aiprj` line from `.gitignore` and commit the directory.

## Project Structure

After setup, the AI manages the following documents:

| File | Content |
|------|---------|
| `.aiprj/AI_PRJ_REQUIREMENTS.md` | Requirements document |
| `.aiprj/AI_PRJ_DESIGN.md` | Design specification document |
| `.aiprj/AI_PRJ_TASKS.md` | Implementation tasks and work instruction list |
| `.aiprj/AI_LOG/` | Work logs (`yyyy-MM-dd_NNN.md` format, sequential, no overwriting) |

## AI Operation Guidelines

The AI operates according to the following guidelines:

1. Must formulate a work plan before starting any task
2. Distorting or reinterpreting the AI Operation Guidelines is prohibited
3. Taking detours or modifying the approach beyond user instructions is prohibited
4. Optimizing, rewriting, or reinterpreting user instructions is prohibited
5. Must not stop until the user's instructions are fully completed
6. Work logs must be saved to `.aiprj/AI_LOG/` in `yyyy-MM-dd_NNN.md` format (sequential, no overwriting)
7. Work logs must include the contents of `.aiprj/instructions.md`
8. Must not leave any trace of its involvement in generated or updated files

The `NNN` suffix of a work log is a zero-padded sequential number starting at `000`.

## Permissions & Agent Settings

A `.claude/settings.json` (mirrored as `.agent-cli/settings.json`) is installed alongside the commands.

**Denied**: `rm -rf ~/**` and `rm -rf //**`, `git remote add` / `git remote set-url` (so the remote
cannot be swapped), `npm publish` / `pnpm publish` (so nothing is published by accident), and reads
of `tmp/**`, `node_modules/`, `*.log`, and `.env*` (secrets and noise).

**Allowed**: `git`, `gh`, `node`, `pnpm`, the `touch` / `mkdir` / `cp` / `mv` / `rm` / `find` /
`grep` / `rg` utilities, `Read(**)`, `Edit(**)`, and `WebFetch`. The edit mode defaults to
`acceptEdits`.

**Other settings**: the status line runs `npx -y ccusage statusline --no-offline` to display token
usage, and the environment sets `BASH_DEFAULT_TIMEOUT_MS=300000`, `BASH_MAX_TIMEOUT_MS=1200000`,
and `DISABLE_AUTOUPDATER=0`.

`.agent-cli/settings.json` is identical except that it additionally allows `MultiEdit(**)` and
`Write(**)`.

## File Structure

```
aiprj/
├── install.sh               # Setup script
├── .gitignore.aiprj         # gitignore template
├── .aiprj/
│   ├── instructions.md.org  # Instructions template
│   └── rules/
│       ├── setup_project.md  # Setup rules
│       ├── exec_job.md       # Task execution rules
│       ├── update_project.md # Update rules
│       └── close_ai.md       # Exit rules
├── .claude/                 # For Claude Code
│   ├── settings.json        # Claude Code settings
│   └── commands/            # Slash command definitions
│       ├── setup_ai.md
│       ├── ai.md
│       ├── update_ai.md
│       ├── next_ai.md
│       └── close_ai.md
└── .agent-cli/              # For Claude Code compatible agent CLIs
    ├── settings.json        # Same as .claude/settings.json, plus Write/MultiEdit
    └── commands/            # Identical to .claude/commands/
```

## Requirements

- `curl` (for setup)
- `tar` (for one-liner fallback), or `git`
- Claude Code CLI, or a Claude Code compatible agent CLI
- Node.js / `npx` (optional - only for the `ccusage` status line)

## License

[MIT License](./LICENSE.md)
