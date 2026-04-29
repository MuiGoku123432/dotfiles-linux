[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# uv
export PATH="$HOME/.local/bin:$PATH"

# Source local secrets (not tracked in git)
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
