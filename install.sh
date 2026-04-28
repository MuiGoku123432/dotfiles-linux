#!/usr/bin/env bash
# Quick orchestrator — skips package install (JaKooLit handles that).
# Run this after JaKooLit + git clone.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
cd "$DOTFILES"

info()  { printf '\033[1;34m==> %s\033[0m\n' "$*"; }

# Stow all packages
info "Stowing packages..."
for pkg in zsh nvim git ssh ghostty starship claude hypr waybar wofi mako; do
  [[ -d "$pkg" ]] || continue
  stow --no-folding -v -t "$HOME" "$pkg" && info "$pkg stowed" || info "SKIP $pkg (conflict)"
done

# Post-install scripts
info "Setting up autologin..."
bash "$DOTFILES/scripts/setup-autologin.sh"

info "Installing fonts..."
bash "$DOTFILES/scripts/install-fonts.sh"

info "Done. Reboot to land in Hyprland."
