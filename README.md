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

Re-run the same command any time to update. The installer places a single `mind` binary in one
location and touches nothing else: `/usr/local/bin` or `~/.local/bin` on macOS and Linux,
`%LOCALAPPDATA%\Programs\mind` on Windows.

Prefer to read before you run? The installers live in this repo:
[`install.sh`](install.sh) and [`install.ps1`](install.ps1).

### Install manually

Download the archive for your platform from the
[Releases](https://github.com/mindrealm-ai/mind/releases/latest) page, then:

- **macOS / Linux:** download `mind-<os>-<arch>.tar.gz`, extract it (`tar -xzf mind-<os>-<arch>.tar.gz`),
  make it executable (`chmod +x mind`), and move `mind` onto a directory on your `PATH` (e.g.
  `/usr/local/bin`).
- **Windows:** download `mind-windows-<arch>.zip`, extract `mind.exe`, and add its folder to your `PATH`.

Then run `mind login` to authenticate.

## Commands

```
mind login        # authenticate (opens your browser)
mind setup        # detect your agent(s) and set up the stop-hook auto-fix loop
mind review       # review your changed files
mind --help       # list every command and flag
```

`mind setup` detects Claude Code and Codex, asks which to set up (you can pick either or both),
and asks whether to set up globally (the default) or just for the current project. Use flags to
skip the prompts, e.g. `mind setup --platform claude-code,codex --global --yes`.

`mind review` reviews your changes by default (diff-only). To scan the whole repository:

```
mind review --full-scan
```

`mind analyze` is the hook entry point that `mind setup` configures: your agent calls it
automatically when it stops, so you won't run it by hand.

## Configuration

`mind` reads config from `.mind/mind.yaml` (project) or `~/.config/mind/mind.yaml` (global). Common
keys:

| Key | Meaning |
|-----|---------|
| `diff_only` | Review only changed files (the default). |
| `full_scan` | Review the whole repository instead. |
| `min_severity` | Hide lower-severity findings. One of `note`, `improve`, `must_fix`, `block` — only findings at or above it are shown (e.g. `improve` hides nitpicks). |
| `disabled_analyzers` | A list of analyzers to turn off, by full ID, short name, or concern (e.g. `magic-string` or `hygiene`). |

Precedence (highest first): a command-line flag (`--diff-only` / `--full-scan`, which are mutually
exclusive) > environment variables (`MIND_*`) > `.mind/mind.yaml` > `~/.config/mind/mind.yaml` >
built-in defaults.

Get started:   https://mindrealm.ai/getting-started
Documentation: https://mindrealm.ai/docs
