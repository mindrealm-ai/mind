# mind

The Mindrealm CLI. This repo hosts the public `mind` binary releases; the source lives in
Mindrealm's private repo. `mind` reviews your code from the terminal and wires Mindrealm into your
agent (Claude Code or Codex) as a stop hook, so findings get fixed in the loop before you see them.

## Install

macOS / Linux:

```
curl -fsSL https://mindrealm.ai/install.sh | sh
```

Windows (PowerShell):

```
iwr -useb https://mindrealm.ai/install.ps1 | iex
```

Or download a binary for your platform from the
[Releases](https://github.com/mindrealm-ai/mind/releases/latest) page, extract it, and put `mind`
(or `mind.exe`) on your PATH.

## Commands

```
mind login                       # authenticate (opens your browser)
mind install                     # wire mind into Claude Code's stop hook (the auto-fix loop)
mind install --platform codex    # ...or into Codex
mind review                      # review your changed files
```

`mind review` reviews your changes by default (diff-only). To scan the whole repository:

```
mind review --full-scan
```

`mind analyze` is the hook entry point that `mind install` configures: your agent calls it
automatically when it stops, so you rarely run it by hand.

## Configuration

`mind` reads config from `.mind/mind.yaml` (project) or `~/.config/mind/mind.yaml` (global). Common
keys:

| Key | Meaning |
|-----|---------|
| `diff_only` | Review only changed files (the default). |
| `full_scan` | Review the whole repository instead. |
| `grpc_url`  | Mindrealm server endpoint (default `api.mindrealm.ai:443`). |
| `debug`     | Verbose logging. |

Precedence (highest first): a command-line flag (`--diff-only` / `--full-scan`, which are mutually
exclusive) > environment variables (`MIND_*`) > `.mind/mind.yaml` > `~/.config/mind/mind.yaml` >
built-in defaults.

Full guide: https://mindrealm.ai/getting-started
