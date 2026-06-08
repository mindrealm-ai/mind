#!/bin/sh
# Mindrealm `mind` CLI installer.
#   curl -fsSL https://mindrealm.ai/install.sh | sh
# Detects your OS + architecture, downloads the matching release archive from the
# public CLI repo, and installs `mind` onto your PATH. Then run `mind login`.
set -eu

REPO="mindrealm-ai/mind"
BASE="https://github.com/${REPO}/releases/latest/download"
RELEASES="https://github.com/${REPO}/releases/latest"

command -v curl >/dev/null 2>&1 || { echo "mind: curl is required" >&2; exit 1; }
command -v tar  >/dev/null 2>&1 || { echo "mind: tar is required" >&2; exit 1; }

os=$(uname -s)
case "$os" in
  Linux) os=linux ;;
  Darwin) os=darwin ;;
  *) echo "mind: unsupported OS '$os'. Download a binary from ${RELEASES}" >&2; exit 1 ;;
esac

arch=$(uname -m)
case "$arch" in
  x86_64 | amd64) arch=amd64 ;;
  arm64 | aarch64) arch=arm64 ;;
  *) echo "mind: unsupported architecture '$arch'. Download a binary from ${RELEASES}" >&2; exit 1 ;;
esac

asset="mind-${os}-${arch}.tar.gz"

# Prefer a system bin dir if writable; otherwise install to ~/.local/bin.
if [ -w /usr/local/bin ] || [ "$(id -u)" = 0 ]; then
  dest=/usr/local/bin
else
  dest="${HOME}/.local/bin"
  mkdir -p "$dest"
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

echo "Downloading ${asset} ..."
curl -fsSL "${BASE}/${asset}" -o "${tmp}/mind.tar.gz"
tar -xzf "${tmp}/mind.tar.gz" -C "$tmp"
chmod +x "${tmp}/mind"
mv "${tmp}/mind" "${dest}/mind"

echo "Installed mind to ${dest}/mind"

# Make sure ${dest} is on PATH. /usr/local/bin already is; for ~/.local/bin we add
# it to the right shell rc (idempotent) so `mind` works in new shells.
case ":${PATH}:" in
  *":${dest}:"*)
    : # already on PATH (e.g. /usr/local/bin)
    ;;
  *)
    shell_name=$(basename "${SHELL:-sh}")
    case "$shell_name" in
      fish)
        rc="${HOME}/.config/fish/config.fish"
        mkdir -p "$(dirname "$rc")"
        grep -qs "$dest" "$rc" 2>/dev/null || \
          printf '\n# Added by the Mindrealm installer\nfish_add_path %s\n' "$dest" >> "$rc"
        ;;
      zsh)
        rc="${HOME}/.zshrc"
        grep -qsF "$dest" "$rc" 2>/dev/null || \
          printf '\n# Added by the Mindrealm installer\nexport PATH="%s:$PATH"\n' "$dest" >> "$rc"
        ;;
      *)
        rc="${HOME}/.bashrc"
        grep -qsF "$dest" "$rc" 2>/dev/null || \
          printf '\n# Added by the Mindrealm installer\nexport PATH="%s:$PATH"\n' "$dest" >> "$rc"
        ;;
    esac
    echo "Added ${dest} to your PATH in ${rc}."
    echo "Restart your shell or run: source ${rc}"
    ;;
esac
echo "Next: run 'mind login' to authenticate."
