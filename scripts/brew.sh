#!/usr/bin/env bash
#
# brew.sh — install system dependencies from the Brewfile via `brew bundle`.
#
#   bash scripts/brew.sh
#
# Idempotent: Homebrew skips already-installed formulas/casks.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BREWFILE="$DOTFILES_DIR/Brewfile"

if ! command -v brew >/dev/null 2>&1; then
	echo "Homebrew is not installed. Run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
	exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
	echo "This Brewfile targets Apple Silicon (arm64) Macs."
	exit 1
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

echo "==> Running brew bundle (this may take a while)..."
brew bundle --file "$BREWFILE"
echo "==> Brew bundle finished."