#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
PACKAGES=(zsh git ssh aerospace ghostty sketchybar nvim zellij starship claude)

info()  { printf '\033[1;34m==> %s\033[0m\n' "$*"; }
warn()  { printf '\033[1;33m==> %s\033[0m\n' "$*"; }
error() { printf '\033[1;31m==> %s\033[0m\n' "$*"; exit 1; }

# --- Xcode CLI tools ---
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode CLI tools..."
  xcode-select --install
  echo "Press Enter after Xcode CLI tools finish installing."
  read -r
fi

# --- Homebrew ---
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- Clone dotfiles ---
if [ ! -d "$DOTFILES" ]; then
  info "Cloning dotfiles..."
  git clone git@github.com:cfanch06/dotfiles.git "$DOTFILES"
fi

# --- Brew bundle ---
info "Installing Homebrew packages..."
brew bundle --file="$DOTFILES/Brewfile"

# --- Backup conflicting files ---
backup_if_exists() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mkdir -p "$BACKUP_DIR"
    local dest="$BACKUP_DIR/${target#$HOME/}"
    mkdir -p "$(dirname "$dest")"
    mv "$target" "$dest"
    warn "Backed up $target → $dest"
  elif [ -L "$target" ]; then
    rm "$target"
    warn "Removed old symlink $target"
  fi
}

info "Backing up conflicting files..."
backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.zshenv"
backup_if_exists "$HOME/.fzf.zsh"
backup_if_exists "$HOME/.gitconfig"
backup_if_exists "$HOME/.config/git/ignore"
backup_if_exists "$HOME/.ssh/config"
backup_if_exists "$HOME/.config/nvim"
backup_if_exists "$HOME/.config/ghostty"
backup_if_exists "$HOME/.config/zellij"
backup_if_exists "$HOME/.config/starship.toml"
backup_if_exists "$HOME/.config/aerospace"
backup_if_exists "$HOME/.config/sketchybar"
backup_if_exists "$HOME/.claude/settings.json"
backup_if_exists "$HOME/.claude/commands"
backup_if_exists "$HOME/.claude/skills"

# --- SSH directory ---
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"

# --- Stow all packages ---
info "Stowing packages..."
cd "$DOTFILES"
stow -v "${PACKAGES[@]}"

# --- Volta + Node ---
if ! command -v volta &>/dev/null; then
  info "Installing Volta..."
  curl https://get.volta.sh | bash
  export VOLTA_HOME="$HOME/.volta"
  export PATH="$VOLTA_HOME/bin:$PATH"
fi
if ! command -v node &>/dev/null; then
  info "Installing Node via Volta..."
  volta install node
fi

# --- Rustup ---
if ! command -v rustup &>/dev/null; then
  info "Installing Rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# --- jenv ---
if command -v jenv &>/dev/null; then
  info "Configuring jenv..."
  eval "$(jenv init -)"
fi

# --- Secrets ---
if [ ! -f "$HOME/.zshenv.local" ]; then
  warn "Create ~/.zshenv.local from the example:"
  warn "  cp $DOTFILES/secrets/.zshenv.local.example ~/.zshenv.local"
  warn "  Then fill in your values."
fi

info "Done! Open a new terminal to verify everything works."
