# dotfiles-linux

Fedora + Hyprland (JaKooLit) dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Prerequisites

1. Fedora installed
2. [JaKooLit's Hyprland installer](https://github.com/JaKooLit/Fedora-Hyprland) run
3. `git` and `stow` available (`sudo dnf install git stow`)

## Bootstrap

```bash
git clone git@github.com:cfanch06/dotfiles-linux.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

The bootstrap script will:
1. Enable any COPRs in `packages/copr.txt`
2. Install packages from `packages/dnf.txt` (+ cargo, flatpaks if configured)
3. Run any `scripts/install-*.sh` helpers (Ghostty, etc.)
4. Back up conflicting configs to `~/.dotfiles-backup-<timestamp>`
5. Stow all packages (create symlinks into `$HOME`)
6. Set shell to zsh

## Packages

| Package | Configures |
|---------|-----------|
| `zsh` | `.zshrc`, `.zshenv`, `.fzf.zsh` |
| `nvim` | LazyVim-based Neovim |
| `git` | global gitignore |
| `ssh` | SSH client config |
| `ghostty` | Ghostty terminal — JARVIS theme |
| `starship` | Starship prompt |
| `zellij` | Zellij multiplexer + layouts |
| `claude` | Claude Code settings and commands |
| `hypr` | Hyprland `UserConfigs/` overrides (layered on JaKooLit) |
| `waybar` | Waybar — JARVIS HUD style |
| `wofi` | Wofi launcher |
| `mako` | Mako notification daemon |

## Login flow (Omarchy-style)

No display manager. Boot goes:

1. GRUB → Plymouth → tty1
2. systemd autologins via `getty@tty1.service.d/autologin.conf`
3. zsh's `.zprofile` exec's Hyprland on tty1 only
4. Desktop comes up directly

The "login screen" you see is **Hyprlock** (`hypr/.config/hypr/hyprlock.conf`), styled as a JARVIS HUD. It fires from:
- `Super+Esc` (manual)
- 10 min idle (via `hypridle`)
- Suspend/resume

`scripts/setup-autologin.sh` handles disabling SDDM, switching the default systemd target to `multi-user.target`, and dropping in the agetty override. It runs from `bootstrap.sh` and is idempotent.

### Wallpaper for the lock screen

Drop a `jarvis-lock.png` at `~/.config/hypr/wallpapers/`. Hyprlock blurs it 3 passes, so any reasonably dark image works.

### Fonts for the JARVIS HUD

`scripts/install-fonts.sh` fetches Orbitron + Rajdhani from the Google Fonts mirror and installs them to `~/.local/share/fonts`. Runs from `bootstrap.sh`.

## Hyprland config strategy

JaKooLit sources `~/.config/hypr/UserConfigs/*.conf` **after** its own configs, so our `hypr/` package wins at the config layer without touching JaKooLit's managed files. Each file in `UserConfigs/` has a single responsibility:

| File | Purpose |
|------|---------|
| `UserSettings.conf` | JARVIS theme — gaps, borders, animations |
| `UserKeybinds.conf` | Personal keybinds |
| `Startup_Apps.conf` | Autostart: waybar, mako, swww, boot-sequence |
| `ENVariables.conf` | Wayland env vars |
| `WindowRules.conf` | Per-app float/pin rules |

## Day-to-day

```bash
make stow              # link all packages
make unstow            # unlink all
make restow            # re-link (fix stale symlinks)
make restow-pkg PKG=hypr  # re-link a single package
```

## Secrets

Secrets are **not** tracked. Create `~/.zshenv.local` and put machine-specific exports there — it gets sourced automatically from `.zshenv`.

```bash
# ~/.zshenv.local
export GITHUB_TOKEN=...
export ANTHROPIC_API_KEY=...
```

Machine-specific git identity (e.g. work email) goes in `~/.gitconfig.local`.

## Structure

```
~/.dotfiles/
├── bootstrap.sh          # Fedora bootstrap
├── Makefile              # stow/unstow/restow
├── .stowrc               # --target=$HOME
├── packages/
│   ├── dnf.txt           # dnf package list
│   ├── copr.txt          # COPR repos
│   ├── cargo.txt         # cargo installs
│   └── flatpak.txt       # flatpak app IDs
├── scripts/
│   ├── install-ghostty.sh
│   └── boot-sequence.sh  # JARVIS startup notifications
└── <package>/            # each mirrors $HOME layout
    └── .config/<app>/
```
