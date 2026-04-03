DOTFILES := $(HOME)/.dotfiles
PACKAGES := zsh git ssh aerospace ghostty sketchybar nvim zellij starship claude

.PHONY: stow unstow restow brew-dump

stow:
	cd $(DOTFILES) && stow -v $(PACKAGES)

unstow:
	cd $(DOTFILES) && stow -v -D $(PACKAGES)

restow:
	cd $(DOTFILES) && stow -v --restow $(PACKAGES)

brew-dump:
	brew bundle dump --file=$(DOTFILES)/Brewfile --force
