#!/usr/bin/env bash
#
# symlinks.sh — create symlinks from ~ into the dotfiles repo.
#
# Safe to run multiple times:
#   * if the target already points into this repo → skipped ([OK])
#   * if the target exists but is not one of our symlinks → timestamped backup, then link
#   * never deletes user data

set -u

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_DIR="${HOME:-}"

if [[ -z "$HOME_DIR" ]]; then
	echo "[FAIL] \$HOME is not set"; exit 1
fi

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok()   { printf "${GREEN}[OK]${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
fail() { printf "${RED}[FAIL]${NC} %s\n" "$1"; }

# source → destination pairs (source is relative to DOTFILES_DIR)
LINKS=(
	"home/.zshrc|$HOME_DIR/.zshrc"
	"home/.zprofile|$HOME_DIR/.zprofile"
	"home/.zshenv|$HOME_DIR/.zshenv"
	"home/.profile|$HOME_DIR/.profile"
	"config/nvim|$HOME_DIR/.config/nvim"
	"config/kitty|$HOME_DIR/.config/kitty"
	"tmux/tmux.conf|$HOME_DIR/.config/tmux/tmux.conf"
	"tmux/sessionizer|$HOME_DIR/.config/tmux-sessionizer"
	"git/.gitconfig|$HOME_DIR/.gitconfig"
)

STAMP="$(date +%Y%m%d-%H%M%S)"
FAILED=0

for entry in "${LINKS[@]}"; do
	src_rel="${entry%%|*}"
	dest="${entry##*|}"
	src="$DOTFILES_DIR/$src_rel"

	dest_dir="$(dirname "$dest")"
	if [[ "$dest_dir" != "$HOME_DIR" && ! -d "$dest_dir" ]]; then
		mkdir -p "$dest_dir"
	fi

	if [[ -L "$dest" ]]; then
		current="$(readlink "$dest" 2>/dev/null || true)"
		if [[ "$current" == "$src" ]]; then
			ok "$dest"
		else
			cp -Rp "$dest" "$dest.backup-$STAMP" 2>/dev/null
			warn "replaced existing symlink -> backup: $dest.backup-$STAMP"
			ln -sfn "$src" "$dest"
			ok "$dest"
		fi
	elif [[ -e "$dest" || -d "$dest" ]]; then
		cp -Rp "$dest" "$dest.backup-$STAMP" 2>/dev/null || { fail "cannot back up $dest"; FAILED=1; continue; }
		warn "backed up existing file -> $dest.backup-$STAMP"
		ln -sfn "$src" "$dest"
		ok "$dest"
	else
		ln -sfn "$src" "$dest"
		ok "$dest"
	fi
done

exit $FAILED