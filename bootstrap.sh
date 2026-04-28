#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
PACKAGES=(zsh nvim git ssh ghostty starship zellij claude hypr waybar wofi mako)

info()  { printf '\033[1;34m==> %s\033[0m\n' "$*"; }
warn()  { printf '\033[1;33m==> %s\033[0m\n' "$*"; }
error() { printf '\033[1;31m==> %s\033[0m\n' "$*"; exit 1; }

[[ "$(uname)" == "Linux" ]] || error "This script is for Linux only."
command -v dnf >/dev/null 2>&1 || error "dnf not found — Fedora/RHEL only."

# --- Clone dotfiles if needed ---
if [[ ! -d "$DOTFILES" ]]; then
  info "Cloning dotfiles..."
  git clone git@github.com:cfanch06/dotfiles-linux.git "$DOTFILES"
fi
cd "$DOTFILES"

# --- Enable COPRs ---
if [[ -s packages/copr.txt ]]; then
  info "Enabling COPRs..."
  while IFS= read -r repo; do
    [[ -z "$repo" || "$repo" =~ ^# ]] && continue
    sudo dnf copr enable -y "$repo"
  done < packages/copr.txt
fi

# --- Install dnf packages ---
if [[ -s packages/dnf.txt ]]; then
  info "Installing dnf packages..."
  mapfile -t pkgs < <(grep -vE '^(#|[[:space:]]*$)' packages/dnf.txt)
  sudo dnf install -y --skip-broken "${pkgs[@]}"
fi

# --- Cargo packages ---
if command -v cargo >/dev/null 2>&1 && [[ -s packages/cargo.txt ]]; then
  info "Installing cargo packages..."
  while IFS= read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    cargo install --locked "$pkg"
  done < packages/cargo.txt
fi

# --- Flatpaks ---
if command -v flatpak >/dev/null 2>&1 && [[ -s packages/flatpak.txt ]]; then
  info "Installing flatpaks..."
  mapfile -t fpkgs < <(grep -vE '^(#|[[:space:]]*$)' packages/flatpak.txt)
  flatpak install -y flathub "${fpkgs[@]}"
fi

# --- Helper scripts (install-*.sh and setup-*.sh) ---
for script in scripts/install-*.sh scripts/setup-*.sh; do
  [[ -x "$script" ]] && { info "Running $script..."; bash "$script"; }
done

# --- Backup conflicting files, then stow ---
info "Stowing packages..."
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"

for pkg in "${PACKAGES[@]}"; do
  [[ -d "$DOTFILES/$pkg" ]] || { warn "Package '$pkg' not found, skipping."; continue; }
  if ! stow --no-folding -t "$HOME" --simulate "$pkg" 2>/dev/null; then
    warn "Conflicts in '$pkg' — backing up to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    stow --no-folding -t "$HOME" --adopt "$pkg" 2>/dev/null || true
    mv "$DOTFILES/$pkg" "$BACKUP_DIR/$pkg" || true
    git checkout -- "$pkg" 2>/dev/null || true
  fi
  stow --no-folding -v -t "$HOME" "$pkg"
done

# --- Set shell ---
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
  info "Setting shell to zsh..."
  chsh -s "$(command -v zsh)" "$USER" || warn "chsh failed — set shell manually."
fi

# --- Secrets reminder ---
if [[ ! -f "$HOME/.zshenv.local" ]]; then
  warn "Create ~/.zshenv.local for machine-specific secrets (API keys, etc.)."
fi

info "Done! Open a new terminal (or relogin) to apply everything."
