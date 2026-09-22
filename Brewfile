# System dependencies for the dotfiles setup (Apple Silicon only).
# Run with: brew bundle --file Brewfile   (or: bash scripts/brew.sh)
#
# Uncommented lines are required and are what doctor.sh verifies.
# (No 'tap "homebrew/cask"': on Homebrew >= 7 the cask tap is built in and an
# explicit tap causes 'brew bundle' to fail.)

# --- Required: referenced by the configs or needed at runtime ---

# editor
brew "neovim"
# terminal multiplexer (+ tmux-sessionizer dependency)
brew "tmux"
# git for everything (Homebrew git is fine on a fresh Mac)
brew "git"
# language toolchains used by the workflow / nvim LSPs
brew "pnpm"
brew "uv"
brew "go"
brew "python@3.12"
# node is intentionally NOT here: it is managed by nvm via the zsh-nvm plugin.
# LSP/format tooling trees:
brew "tree-sitter"
brew "tree-sitter-cli"
# finders / grep
brew "fzf"
brew "fd"
brew "ripgrep"
# git TUI
brew "lazygit"
# zsh autosuggestions (also installed as an oh-my-zsh custom plugin)
brew "zsh-autosuggestions"
