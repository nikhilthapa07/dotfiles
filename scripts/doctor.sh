#!/usr/bin/env bash
#
# doctor.sh — verify the environment WITHOUT modifying anything.
#
#   bash scripts/doctor.sh
#
# Exit status: 0 = no failures, 1 = one or more [FAIL] checks.

set -u

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_DIR="${HOME:-}"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
ok()    { printf "${GREEN}[OK]${NC} %s\n"   "$1"; }
warn()  { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
fail()  { printf "${RED}[FAIL]${NC} %s\n"   "$1"; }
info()  { printf "${CYAN}[INFO]${NC} %s\n"  "$1"; }

FAILED=0
FAIL() { fail "$1"; FAILED=1; }

info "=============================================="
info " dotfiles doctor"
info "=============================================="

# --- OS / architecture ----------------------------------------------------
info "> OS and architecture"
if [[ "$(uname -s)" == "Darwin" ]]; then ok "macOS $(sw_vers -productVersion 2>/dev/null)"; else FAIL "not macOS"; fi
if [[ "$(uname -m)" == "arm64" ]]; then ok "Apple Silicon (arm64)"; else FAIL "not arm64 — this setup is Apple Silicon only"; fi

# --- Homebrew --------------------------------------------------------------
info "> Homebrew"
if command -v brew >/dev/null 2>&1; then
	if [[ "$(brew --prefix)" == "/opt/homebrew" ]]; then
		ok "Homebrew at /opt/homebrew ($(brew --version | head -1))"
	else
		warn "Homebrew prefix is '$(brew --prefix)' — expected /opt/homebrew"
	fi
else
	FAIL "Homebrew not installed (or not in PATH)"
fi

# --- Required formulas -------------------------------------------------------
# Derived from the Brewfile (single source of truth): every uncommented
# `brew "name"` line is required. Only the pkg->binary alias map below is
# manual, for tools whose binary name differs from the formula name
# (or shares one with another formula). Falls back to a warning instead of a
# failure when the tool exists but was installed outside Homebrew.
BREWFILE="$DOTFILES_DIR/Brewfile"
PKG_ALIASES=(
	"neovim|nvim"
	"ripgrep|rg"
	"tree-sitter-cli|tree-sitter"
)
bin_for() { # $1 = formula name -> binary to check (or '' for none)
	local pkg="$1" entry
	for entry in "${PKG_ALIASES[@]}"; do
		[[ "${entry%%|*}" == "$pkg" ]] && { printf '%s' "${entry##*|}"; return; }
	done
	printf '%s' "$pkg"
}
required_pkgs=()
while IFS= read -r pkg; do
	required_pkgs+=("$pkg")
done < <(grep -E '^[[:space:]]*brew[[:space:]]+"[^"]+"' "$BREWFILE" | sed -E 's/^[[:space:]]*brew[[:space:]]+"([^"]+)".*/\1/')

info "> Required Homebrew formulas (from Brewfile)"
if command -v brew >/dev/null 2>&1; then
	if [[ "${#required_pkgs[@]}" -eq 0 ]]; then
		FAIL "no brew formulas found in $BREWFILE"
	fi
	for pkg in "${required_pkgs[@]}"; do
		bin="$(bin_for "$pkg")"
		if brew list --formula "$pkg" >/dev/null 2>&1; then
			ok "$pkg"
		elif [[ -n "$bin" ]] && command -v "$bin" >/dev/null 2>&1; then
			warn "$pkg not via Homebrew, but '$bin' exists at $(command -v "$bin")"
		else
			FAIL "$pkg (brew)"
		fi
	done
else
	FAIL "cannot check formulas without Homebrew"
fi

# --- Required binaries -----------------------------------------------------
info "> Required binaries"
for bin in git go nvim tmux fzf fd rg lazygit tree-sitter; do
	if command -v "$bin" >/dev/null 2>&1; then
		ok "$bin -> $(command -v "$bin")"
	else
		FAIL "$bin (not in PATH)"
	fi
done

# --- Symlinks ---------------------------------------------------------------
info "> Symlinks"
links_expected=(
	"$HOME_DIR/.zshrc|home/.zshrc"
	"$HOME_DIR/.zprofile|home/.zprofile"
	"$HOME_DIR/.zshenv|home/.zshenv"
	"$HOME_DIR/.profile|home/.profile"
	"$HOME_DIR/.config/nvim|config/nvim"
	"$HOME_DIR/.config/kitty|config/kitty"
	"$HOME_DIR/.config/tmux/tmux.conf|tmux/tmux.conf"
	"$HOME_DIR/.config/tmux-sessionizer|tmux/sessionizer"
	"$HOME_DIR/.gitconfig|git/.gitconfig"
)
for entry in "${links_expected[@]}"; do
	dest="${entry%%|*}"; src_rel="${entry##*|}"
	if [[ -L "$dest" ]]; then
		current="$(readlink "$dest" 2>/dev/null)"
		if [[ "$current" == "$DOTFILES_DIR/$src_rel" ]]; then
			ok "$dest -> $current"
		else
			warn "$dest is a symlink to '$current' (not this repo)"
		fi
	elif [[ -e "$dest" ]]; then
		warn "$dest exists but is not a symlink (created by symlinks.sh)"
	else
		FAIL "$dest missing (run scripts/symlinks.sh)"
	fi
done

# --- Neovim config ----------------------------------------------------------
info "> Neovim config"
if command -v nvim >/dev/null 2>&1; then
	if nvim --headless +qa 2>/dev/null; then
		ok "nvim loads config cleanly ($(nvim --version | head -1))"
	else
		FAIL "nvim failed to start with the current config"
	fi
else
	FAIL "nvim not installed"
fi

# --- tmux config ------------------------------------------------------------
info "> tmux config"
if command -v tmux >/dev/null 2>&1; then
	# Private socket (-L) so a running tmux server is never touched.
	CONF="$DOTFILES_DIR/tmux/tmux.conf"
	if output="$(tmux -L dotfiles-doctor -f "$CONF" start-server \; show -g prefix \; kill-server 2>&1)"; then
		prefix="$(printf '%s' "$output" | tr -s ' ')"
		ok "tmux config loads (prefix: $prefix)"
	else
		FAIL "tmux config failed to load"
	fi
else
	FAIL "tmux not installed"
fi

# --- Kitty config -----------------------------------------------------------
info "> Kitty config"
if [[ -f "$DOTFILES_DIR/config/kitty/kitty.conf" ]]; then
	ok "kitty.conf present"
	if [[ -f "$DOTFILES_DIR/config/kitty/current-theme.conf" ]]; then
		ok "kitty theme (current-theme.conf) present"
	else
		warn "kitty.conf includes current-theme.conf but the file is missing"
	fi
else
	FAIL "kitty.conf missing"
fi

# --- Zsh config -------------------------------------------------------------
info "> Zsh config"
if command -v zsh >/dev/null 2>&1 && zsh -n "$DOTFILES_DIR/home/.zshrc" >/dev/null 2>&1; then
	ok "zshrc parses without syntax errors"
else
	FAIL "zshrc has syntax errors (zsh -n failed)"
fi
if [[ -d "$HOME_DIR/.oh-my-zsh" ]]; then ok "oh-my-zsh installed"; else warn "oh-my-zsh missing (run install.sh)"; fi
for plg in zsh-nvm zsh-autosuggestions; do
	if [[ -d "$HOME_DIR/.oh-my-zsh/custom/plugins/$plg" ]]; then
		ok "omz plugin: $plg"
	else
		warn "omz plugin missing: $plg"
	fi
done

# --- Node / nvm ----------------------------------------------------------------
info "> Node / nvm"
if command -v node >/dev/null 2>&1; then
	ok "node $(node --version 2>/dev/null)"
elif [[ -d "$HOME_DIR/.nvm" ]]; then
	warn "nvm present but no node in PATH yet — run: nvm install --lts"
else
	warn "nvm not installed — zsh-nvm installs it on first shell"
fi

# --- opencode ------------------------------------------------------------------
info "> opencode"
if [[ -x "$HOME_DIR/.opencode/bin/opencode" ]]; then
	ok "opencode $("$HOME_DIR/.opencode/bin/opencode" --version 2>/dev/null)"
else
	FAIL "opencode missing (run install.sh to install it)"
fi

echo
if [[ "$FAILED" -eq 0 ]]; then
	info "$(printf '%s' 'All checks passed.')"
else
	printf "${RED}%s${NC}\n" "Some checks failed. Review the [FAIL] lines above."
fi
echo "Doctor complete."
exit "$FAILED"
