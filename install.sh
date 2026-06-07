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
case ":${PATH}:" in
  *":${dest}:"*) : ;;
  *) echo "Note: ${dest} is not on your PATH. Add it with: export PATH=\"${dest}:\$PATH\"" ;;
esac
echo "Next: run 'mind login' to authenticate."
