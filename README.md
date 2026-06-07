# mind

The Mindrealm CLI. This repo hosts the public `mind` binary releases; the source lives in Mindrealm's private repo. `mind` reviews your code from the terminal and wires into Claude
Code as a stop hook.

## Install

macOS / Linux:

```
curl -fsSL https://mindrealm.ai/install.sh | sh
```

Or download a binary for your platform from the [Releases](https://github.com/mindrealm-ai/mind/releases/latest) page, extract it, and put `mind` on your PATH.

## Use

```
mind login     # authenticate
mind review    # review your repository (add --diff-only for changed files)
mind install   # wire mind into Claude Code so it reviews on every agent stop
```

Full guide: https://mindrealm.ai/getting-started
