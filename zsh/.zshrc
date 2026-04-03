########################################
# .zshrc — clean, safe, and fast
########################################

# ---------- 0) Foundations (early PATH + env) ----------
# Homebrew (universal; works on Apple Silicon, Intel, Linuxbrew)
if command -v brew >/dev/null 2>&1; then
  eval "$(/usr/bin/env brew shellenv)"
fi

# Volta (after Homebrew so volta-managed node/npm/npx take priority over Homebrew's)
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Zig
export PATH="$HOME/devDeps/zig:$PATH"

# XDG base dir
export XDG_CONFIG_HOME="$HOME/.config"

# jenv (early so JAVA_HOME/PATH are ready)
if command -v jenv >/dev/null 2>&1; then
  eval "$(jenv init -)"
fi

# ---------- 1) Multiplexer / Terminal integration ----------
# Zellij autostart: attach-or-create "default" session in Ghostty,
# then exit the wrapper shell so you never land in a bare shell.
# Set ZELLIJ_AUTO_START=0 to skip (e.g. for debugging).
if [[ -z "$ZSHRC_SOURCED" ]] && [[ -z "$ZELLIJ" ]] && [[ $- == *i* ]] \
   && [[ "$ZELLIJ_AUTO_START" != "0" ]]; then
  if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
    zellij delete-session default 2>/dev/null
    zellij attach --create default
    exit
  fi
fi

# Ghostty shell integration (harmless if Ghostty isn't running)
if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
  builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration" 2>/dev/null
fi

# ---------- 2) Cloud SDK (before compinit so completion can register cleanly) ----------
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]; then
  . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'
fi
# Only load completion on fresh shell startup (it runs bashcompinit which can interfere)
if [[ -z "$ZSHRC_SOURCED" ]] && [ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]; then
  . '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'
fi

# ---------- 3) fzf + completion ----------
# fzf adds keybindings/completion; then run compinit so everything is indexed once
# Only initialize fzf and completion on fresh shell startup (fzf disables aliases!)
if [[ -z "$ZSHRC_SOURCED" ]]; then
  [ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

  # bun completions
  [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

  autoload -Uz compinit && compinit -C   # -C trusts cached .zcompdump for speed
fi

# ---------- 4) Quality-of-life shell options ----------
HISTFILE=$HOME/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
setopt HIST_IGNORE_DUPS HIST_FIND_NO_DUPS HIST_REDUCE_BLANKS INC_APPEND_HISTORY
# setopt SHARE_HISTORY             # enable if you want history shared across terminals
# setopt AUTO_CD                   # 'cd' by typing a dir name (optional)

# ---------- 5) Prompt (Starship) with preexec guard ----------
autoload -Uz add-zsh-hook

# Guard: (re)define Starship's helper if some script nukes it
starship_preexec_guard() {
  if ! typeset -f __starship_get_time >/dev/null; then
    zmodload zsh/datetime 2>/dev/null
    zmodload zsh/mathfunc 2>/dev/null
    __starship_get_time() { (( STARSHIP_CAPTURED_TIME = int(rint(EPOCHREALTIME * 1000)) )); }
  fi
}
# Clean hook management: remove existing hook before adding
if add-zsh-hook -L preexec | grep -q 'starship_preexec_guard'; then
  add-zsh-hook -d preexec starship_preexec_guard
fi
add-zsh-hook preexec starship_preexec_guard

# Initialize Starship (only if not already initialized)
if [[ $- == *i* ]] && [[ $TERM != dumb ]] && command -v starship >/dev/null 2>&1; then
  if [[ -z "$STARSHIP_SHELL" ]] && [[ -z "$ZSHRC_SOURCED" ]]; then
    eval "$(starship init zsh)"
  fi
fi

# ---------- 6) One-time per-shell banners ----------
# Show fastfetch once per shell (exported so zellij panes inherit & skip it)
if [[ $- == *i* && -z "$FASTFETCH_PRINTED" ]]; then
  # If the logo truncates on startup, a tiny delay can help:
  # sleep 0.05
  command -v fastfetch >/dev/null 2>&1 && fastfetch
  export FASTFETCH_PRINTED=1
fi

# ---------- 7) Optional plugins (auto-detect Homebrew paths) ----------
# zsh-autosuggestions (only load if not already loaded)
if [ -r "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && [[ -z "$ZSH_AUTOSUGGEST_STRATEGY" ]]; then
  source "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
# zsh-syntax-highlighting (recommended last, only load if not already loaded)
if [ -r "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && [[ -z "$ZSH_HIGHLIGHT_HIGHLIGHTERS" ]]; then
  source "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# ---------- 8) Aliases & functions (after all initialization) ----------
# Function to ensure critical aliases are always available
_restore_critical_aliases() {
  alias s='source ~/.zshrc'
  alias eb='nvim ~/.zshrc'
}

# Always-available reloader (non-leaky)
_restore_critical_aliases

# Files/dirs
alias ll='ls -lah'
alias path='print -l $path'
alias ports='lsof -i -P -n | grep LISTEN'
alias updatebrew='brew update && brew upgrade && brew cleanup'
alias weather='curl wttr.in'
alias nv='nvim'

# Search history helper
alias hist='history | grep'

# Dev navigation
alias mine='cd ~/repos/mine'
alias elser='cd ~/repos/else'
alias etc='cd ~/repos/etc'
alias gdev='cd ~/repos/mine/GoApps'
alias rdev='cd ~/repos/mine/RustApps'
alias wdev='cd ~/repos/mine/WebApps'
alias jdev='cd ~/repos/mine/JavaApps'
alias pdev='cd ~/repos/mine/PythonApps'
alias ddev='cd ~/repos/mine/DevOps/'
alias apw='cd ~/Documents/curseforge/minecraft/Instances/Alaskan\ Perfect\ World'
alias ~='cd ~/'
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'

# Zellij launcher that gracefully falls back if layout missing
devTerm() {
  if ! command -v zellij >/dev/null 2>&1; then
    echo "zellij not installed" >&2; return 1
  fi
  local layout_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zellij/layouts"
  if [ -f "$layout_dir/dev.kdl" ]; then
    zellij --layout dev
  else
    echo "(hint) No dev.kdl found in $layout_dir — launching default zellij." >&2
    zellij
  fi
}

# Zellij session helpers
zj-fresh() {
  # Kill "default" session for a clean start.
  # Inside zellij: session dies, Ghostty closes. Reopen for fresh session.
  # Outside zellij: kills old session and creates new one.
  if [[ -n "$ZELLIJ" ]]; then
    zellij kill-session default
  else
    zellij kill-session default 2>/dev/null
    zellij delete-session default 2>/dev/null
    zellij attach --create default
  fi
}

zj-new() {
  # Start a new session with a random name (useful for second windows)
  zellij
}

zj-clean() {
  # Delete all dead/exited sessions
  zellij delete-all-sessions -y 2>/dev/null
  echo "Dead sessions cleaned."
}

# Git helpers
gbr() { git rev-parse --abbrev-ref HEAD 2>/dev/null; }
gc()  { git commit -m "$*"; }               # preserves spaces in message
alias gs='git status'
alias ga='git add -u'
alias gaa='git add .'
alias gco='git checkout'
alias gcb='git checkout -b'
alias glog='git log --oneline --graph --decorate --all'
alias gpl='git pull --ff-only'
alias gpo='git pull origin "$(gbr)"'
alias gp='git push -u origin "$(gbr)"'
alias gsync='git fetch origin && git pull origin "$(gbr)"'

# ---------- 9) Prompt (fallback if you ever disable starship) ----------
# PROMPT='%F{cyan}%n@%m%f:%F{yellow}%~%f$ '

# Mark that .zshrc has been fully sourced (not exported, stays in current shell only)
ZSHRC_SOURCED=1
