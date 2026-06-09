# mind

The Mindrealm CLI. This repo hosts the public `mind` binary releases; the source lives in
Mindrealm's private repo. `mind` reviews your code from the terminal and wires Mindrealm into your
agent (Claude Code, Codex, or Gemini) as a stop hook, so findings get fixed in the loop before you see them.

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

`mind setup` detects Claude Code, Codex, and Gemini, asks which to set up (you can pick any of
them), and asks whether to set up globally (the default) or just for the current project. Use flags
to skip the prompts, e.g. `mind setup --platform claude-code,codex,gemini --global --yes`.

To remove the hook again, run `mind setup --uninstall` (it takes the same `--platform`,
`--global`/`--local`, and `--yes` flags). It removes only what setup added, leaving your other
hooks and permissions intact, and is a no-op when nothing is installed.

Gemini and Codex require you to trust hooks once after setup before they run:

- **Gemini:** start Gemini and run `/hooks enable-all` (or `/hooks enable mindrealm-review`).
- **Codex:** start Codex and run `/hooks` to review and trust the Mindrealm Stop hook.

Both re-prompt whenever the hook command changes.

`mind review` reviews your changes by default (diff-only). To scan the whole repository:

```
mind review --full-scan
```

On a very large repository, `mind review --full-scan` can exceed the analysis time budget (10
minutes by default). When it does, the review returns a partial result: the findings produced
before the deadline, marked "Partial analysis", and it still blocks on any must-fix rather than
failing with zero findings. Narrow the scope with `--diff-only` or `--analyzer` for a faster review.

`mind analyze` is the hook entry point that `mind setup` configures: your agent calls it
automatically when it stops, so you won't run it by hand.

The hook runs every time your agent finishes, so the review (and the gates: your linters, type
checks, builds, and tests) always runs, instead of only when the agent remembers. When Mindrealm
finds an issue it blocks the agent from stopping and feeds the findings back as its next
instruction, so it fixes them in the loop before the work reaches you. This auto-fix loop works on
Claude Code, Codex, and Gemini.

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
