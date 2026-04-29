#!/usr/bin/env bash
# Quick orchestrator — skips package install (JaKooLit handles that).
# Run this after JaKooLit + git clone.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
cd "$DOTFILES"

info()  { printf '\033[1;34m==> %s\033[0m\n' "$*"; }
warn()  { printf '\033[1;33m==> %s\033[0m\n' "$*"; }

# Ensure ~/.ssh exists with correct permissions (required before stowing ssh pkg)
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"

# Stow all packages
info "Stowing packages..."
for pkg in zsh nvim git ssh ghostty starship claude hypr waybar wofi mako zellij fastfetch; do
  [[ -d "$pkg" ]] || continue
  stow --no-folding -v -t "$HOME" "$pkg" && info "$pkg stowed" || warn "SKIP $pkg (conflict)"
done

# Post-install scripts
info "Setting up autologin..."
bash "$DOTFILES/scripts/setup-autologin.sh"

info "Installing Ghostty..."
bash "$DOTFILES/scripts/install-ghostty.sh"

info "Installing fonts..."
bash "$DOTFILES/scripts/install-fonts.sh"

# Set default shell to zsh
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
  info "Setting shell to zsh..."
  chsh -s "$(command -v zsh)" "$USER" || warn "chsh failed — set shell manually."
fi

# Remind about machine-local secrets
if [[ ! -f "$HOME/.zshenv.local" ]]; then
  warn "Create ~/.zshenv.local for machine-specific secrets (API keys, etc.)."
fi

info "Done. Reboot to land in Hyprland."
