DOTFILES := $(HOME)/.dotfiles
PACKAGES := zsh git ssh ghostty nvim zellij starship claude hypr waybar wofi mako

.PHONY: stow unstow restow

stow:
	cd $(DOTFILES) && stow --no-folding -v $(PACKAGES)

unstow:
	cd $(DOTFILES) && stow -v -D $(PACKAGES)

restow:
	cd $(DOTFILES) && stow --no-folding -v --restow $(PACKAGES)

# Restow a single package: make restow-pkg PKG=hypr
restow-pkg:
	cd $(DOTFILES) && stow --no-folding -v --restow $(PKG)
