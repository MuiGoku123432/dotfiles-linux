#!/usr/bin/env bash
# Install Ghostty terminal on Fedora.
# Tries the refi64/ghostty COPR first; falls back to build-from-source.
set -euo pipefail

if command -v ghostty >/dev/null 2>&1; then
  echo "ghostty already installed: $(ghostty --version)"
  exit 0
fi

echo "==> Installing Ghostty..."

# Option 1: COPR (fastest)
if sudo dnf copr enable -y refi64/ghostty 2>/dev/null && sudo dnf install -y ghostty; then
  echo "==> Ghostty installed via COPR."
  exit 0
fi

# Option 2: Build from source
echo "==> COPR failed — building Ghostty from source..."
command -v zig >/dev/null 2>&1 || {
  echo "ERROR: zig not found. Install zig first (https://ziglang.org/download/)." >&2
  exit 1
}
command -v git >/dev/null 2>&1 || sudo dnf install -y git

sudo dnf install -y gtk4-devel libadwaita-devel

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
git clone --depth 1 https://github.com/ghostty-org/ghostty.git "$TMP/ghostty"
cd "$TMP/ghostty"
zig build -p ~/.local -Doptimize=ReleaseFast
echo "==> Ghostty built and installed to ~/.local/bin/ghostty"
