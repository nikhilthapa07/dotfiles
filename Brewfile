# System dependencies for the dotfiles setup (Apple Silicon only).
# Run with: brew bundle --file Brewfile   (or: bash scripts/brew.sh)
#
# Essentials are uncommented. Optional tools are listed further down and are
# commented out so `brew bundle` skips them unless you uncomment.
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
brew "go"
brew "php@8.2"
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

# --- Required casks ---
# terminal emulator whose config lives in this repo
cask "kitty"

# ============================================================================
# Optional — present on this machine but not required by the configs.
# Uncomment the lines you want; `brew bundle` will skip everything commented.
# ============================================================================
# brew "jq"
# brew "composer"
# brew "pnpm"
# brew "deno"
# brew "uv"
# brew "zoxide"
# brew "wget"
# brew "ffmpeg"
# brew "imagemagick"
# brew "poppler"
# brew "resvg"
# brew "sevenzip"
# brew "unar"
# brew "yt-dlp"
# brew "ollama"
#
# cask "font-jetbrains-mono"          # kitty.conf uses JetBrains Mono
# cask "font-symbols-only-nerd-font"  # nerd font glyphs for nvim/tmux statuses
# cask "ngrok"