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

If a proxy or remote session prevents the automatic browser flow, keep the command running and open the printed URL
in your configured browser:

```bash
mind login --no-browser
```

The browser must use its internet proxy while bypassing that proxy for `localhost`, `127.0.0.1`, and `::1` so the
OAuth redirect can reach the CLI's waiting callback listener. Set `BROWSER` to an executable path when you want
`mind login` to use a specific browser or wrapper.

`mind setup` detects Claude Code and Codex, asks which to set up (you can pick either or both), and
asks whether to set up globally (the default) or just for the current project. Use flags to skip the
prompts, e.g. `mind setup --platform claude-code,codex --global --yes`.

To remove the hook again, run `mind setup --uninstall` (it takes the same `--platform`,
`--global`/`--local`, and `--yes` flags). It removes only what setup added, leaving your other
hooks and permissions intact, and is a no-op when nothing is installed.

Codex requires you to trust hooks once after setup before they run: start Codex and run `/hooks` to
review and trust the Mindrealm Stop hook so it goes Active. It re-prompts whenever the hook command
changes.

`mind review` reviews your changes by default (diff-only). To scan the whole repository:

```
mind review --full-scan
```

On a very large repository, `mind review --full-scan` can exceed the analysis time budget (10
minutes by default). When it does, the review returns a partial result: the findings produced
before the deadline, marked "Partial analysis", and it still blocks on any blocker or major finding rather than
failing with zero findings. Narrow the scope with `--diff-only`, or narrow the analyzer set with
`--analyzers a,b,c` (a comma-separated list of rule IDs) or `--profile <name>` (a named
rule set), for a faster review.

### `mind review` flags

| Flag | Effect |
|------|--------|
| `--full-scan` | Scan the entire repository, not just changed files (paid plan). |
| `--diff-only` | Only report findings in changed files (the default). |
| `--commit <sha>` | Review files changed in a specific commit. Implies diff-only. |
| `--staged` | Only staged changes. |
| `--unstaged` | Only unstaged changes. |
| `--analyzers <id,...>` | Run only these analyzers, comma-separated. |
| `--profile <name>` | Run only the analyzers in a named profile. Overrides the `mind.yaml` profile; `--analyzers` adds to it. |
| `--min-severity / --max-severity` | Bound the findings shown. One of `info`, `minor`, `major`, `blocker`. |
| `--show-suppressed` | Include suppressed findings in the output. |
| `--format text\|json` | Output format. |
| `--enable-go-test` | Run the go-test gate (off by default for speed). |
| `--enable-pytest` | Run the pytest gate (off by default for speed). |
| `--enable-js-test` | Run the JS test gate, jest or vitest (off by default for speed). |
| `--no-gates` | Disable all gates (linters, type checks). |

`mind analyze` is the hook entry point that `mind setup` configures: your agent calls it
automatically when it stops, so you won't run it by hand.

The hook runs every time your agent finishes, so the review (and the gates: your linters, type
checks, builds, and tests) always runs, instead of only when the agent remembers. When Mindrealm
finds an issue it blocks the agent from stopping and feeds the findings back as its next
instruction, so it fixes them in the loop before the work reaches you. This auto-fix loop works on
Claude Code and Codex.

## Continuous integration

`mind login` is interactive, so for CI generate a **CI token** from your dashboard and give it to
the CLI headless. The token is organization-scoped, review-only, and revocable, and it stays valid
for long runs, so a `--full-scan` never expires mid-review.

Provide it either as the `MIND_CI_TOKEN` environment variable:

```
MIND_CI_TOKEN=mind_ci_xxxxx mind review --full-scan
```

or store it once with `mind login --token` for repeated local headless use:

```
mind login --token mind_ci_xxxxx
mind review
```

The repository still needs the Mindrealm GitHub App installed; the token authenticates the caller,
the app authorizes the repo.

GitHub Actions example:

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0            # needed so mind can compute the diff against the base commit
- run: curl -fsSL https://mindrealm.ai/install.sh | sh
- run: mind review
  env:
    MIND_CI_TOKEN: ${{ secrets.MIND_CI_TOKEN }}
```

`mind review` exits `0` when the review passes, `1` on a blocker or major finding, `2` on a config or
credential problem (for example a revoked token), `3` on a network or service problem, and `4` on
invalid arguments, so a CI step fails the build on a blocker or major finding.

For machine-readable output use `mind review --format json` (default is `text`); each finding carries
`severity`, `file_path`, `start_line`, `description`, `remediation`, and `rule_id`. If your pipeline
already runs its own linters, type checks, and tests, `mind review --no-gates` skips Mindrealm's gate
checks while the rest of the review still runs and still blocks on a blocker or major finding.

## Configuration

`mind` reads config from `.mind/mind.yaml` (project) or `~/.config/mind/mind.yaml` (global). Common
keys:

| Key | Meaning |
|-----|---------|
| `diff_only` | Review only changed files (the default). |
| `full_scan` | Review the whole repository instead. |
| `min_severity` | Hide lower-severity findings. One of `info`, `minor`, `major`, `blocker` — only findings at or above it are shown (e.g. `minor` hides info findings). |
| `max_severity` | Hide higher-severity findings. Same scale as `min_severity` — only findings at or below it are shown (pair with `min_severity` to isolate one tier). |
| `disabled_analyzers` | A list of analyzers to turn off, by full ID, short name, or concern (e.g. `magic-string` or `hygiene`). |
| `profile` | Run only the analyzers in a named profile. A `--profile` flag overrides this; `--analyzers` adds to it. |

Precedence (highest first): a command-line flag (`--diff-only` / `--full-scan`, which are mutually
exclusive) > environment variables (`MIND_*`) > `.mind/mind.yaml` > `~/.config/mind/mind.yaml` >
built-in defaults.

## Security gates

Two extra gates run dedicated security scanners over your repo. They are **off by default** — unlike
the build, lint, and type gates (which key off the change in front of them), these scan the whole tree
for a deep, point-in-time security pass, so they stay dark until you ask for them.

| Security gate | Tool | Finds |
|---------------|------|-------|
| Secrets | `gitleaks` | Hardcoded API keys, tokens, and credentials across any language. |
| Dependency CVEs | `osv-scanner` | Known vulnerabilities in your dependencies (Go, npm, PyPI, Cargo lockfiles). |

Turn both on in config with `gates: { security: true }`, or for a single run with
`mind review --enable-security-gates`. The scanners are optional local tools: if `gitleaks` or
`osv-scanner` is not installed on the machine running the review, that gate simply skips — it never
fails the run.

## Custom rules

Encode your team's standards as rules in MindQL and Mindrealm runs them in every review, alongside
the built-in checks. One rule works across Go, Python, TypeScript, and Rust, with no build and no
database, and the same code produces the same findings on every run.

Rules live in `.mind/rules/*.mql` (project) or `~/.config/mind/rules/` (global). A rule matches
something, filters it with a condition, then emits a finding at a fixed severity:

```
rule api_no_db {
  match import i
  where i.file.path ~ "internal/api/" and i.imports_package("db*")
  emit blocker "api must not import a db package directly"
}
```

Drop the file in `.mind/rules/` and run `mind review`. Rules are checked in with your code, so the
whole team gets them. Commit `.mind/` as-is — the CLI keeps its throwaway runtime state in your OS temp
dir, not the repo, so there's nothing in `.mind/` to gitignore.

Full reference: https://mindrealm.ai/docs

Get started:   https://mindrealm.ai/getting-started
Documentation: https://mindrealm.ai/docs
