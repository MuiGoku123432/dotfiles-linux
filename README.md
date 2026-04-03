# dotfiles-macos

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). One repo, one command to bootstrap a fresh Mac.

## What's Included

| Package | What it configures |
|---------|--------------------|
| `zsh` | `.zshrc`, `.zshenv`, `.fzf.zsh` |
| `git` | `.gitconfig`, global gitignore |
| `ssh` | SSH client config |
| `nvim` | LazyVim-based Neovim setup |
| `ghostty` | Ghostty terminal (TokyoNight, JetBrainsMono Nerd Font) |
| `zellij` | Zellij multiplexer + layouts |
| `starship` | Starship prompt |
| `aerospace` | AeroSpace window manager |
| `sketchybar` | SketchyBar status bar |
| `claude` | Claude Code settings, commands, and skills |

## Quick Setup

### Fresh Mac

```bash
git clone git@github.com:MuiGoku123432/dotfiles-macos.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

The bootstrap script will:
1. Install Xcode CLI tools and Homebrew
2. Install all packages from the Brewfile
3. Back up any conflicting configs to `~/.dotfiles-backup-<timestamp>`
4. Stow all packages (create symlinks)
5. Install Volta + Node, Rustup, and configure jenv
6. Prompt you to set up `~/.zshenv.local` for secrets

### Existing Mac (just re-link)

```bash
cd ~/.dotfiles
make stow
```

### Secrets

Secrets are **not** tracked in git. After setup, copy the example and fill in your values:

```bash
cp ~/.dotfiles/secrets/.zshenv.local.example ~/.zshenv.local
```

Machine-specific git config (e.g. coderabbit machineId) goes in `~/.gitconfig.local`.

## Day-to-Day

```bash
make stow       # Link all packages
make unstow     # Unlink all packages
make restow     # Re-link (fix stale symlinks)
make brew-dump  # Update Brewfile from installed packages
```

## Structure

```
~/.dotfiles/
├── bootstrap.sh          # Fresh Mac setup script
├── Makefile               # stow/unstow/restow/brew-dump
├── Brewfile               # Homebrew packages
├── .stowrc                # Stow targets $HOME
├── secrets/               # Gitignored, has .example files
└── <package>/             # Each package mirrors $HOME layout
    └── .config/<app>/     # XDG configs nest under .config/
```

Stow creates symlinks from `$HOME` into `~/.dotfiles/<package>/`, so editing either location edits the same file.
