#!/usr/bin/env bash
# Install Orbitron + Rajdhani for the JARVIS Hyprlock theme.
# Pulls TTFs from the official google/fonts GitHub mirror.
set -euo pipefail

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

GFONTS_RAW="https://github.com/google/fonts/raw/main/ofl"

declare -A FONTS=(
  ["Orbitron-Bold.ttf"]="$GFONTS_RAW/orbitron/static/Orbitron-Bold.ttf"
  ["Orbitron-Regular.ttf"]="$GFONTS_RAW/orbitron/static/Orbitron-Regular.ttf"
  ["Rajdhani-Medium.ttf"]="$GFONTS_RAW/rajdhani/Rajdhani-Medium.ttf"
  ["Rajdhani-Regular.ttf"]="$GFONTS_RAW/rajdhani/Rajdhani-Regular.ttf"
)

installed=0
for filename in "${!FONTS[@]}"; do
  target="$FONT_DIR/$filename"
  if [[ -f "$target" ]]; then
    echo "==> $filename already present"
    continue
  fi
  echo "==> Downloading $filename..."
  if curl -fsSL "${FONTS[$filename]}" -o "$target"; then
    installed=$((installed + 1))
  else
    echo "WARN: failed to download $filename" >&2
    rm -f "$target"
  fi
done

if (( installed > 0 )); then
  fc-cache -f "$FONT_DIR"
  echo "==> Installed $installed font(s) and rebuilt cache"
else
  echo "==> Nothing to install"
fi
