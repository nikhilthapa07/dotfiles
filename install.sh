#!/usr/bin/env bash
#
# install.sh — one-command setup for an Apple Silicon Mac (M1/M2/M3/M4).
#
#   git clone <repo> ~/dotfiles
#   cd ~/dotfiles
#   ./install.sh
#
# Idempotent: safe to run repeatedly.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREW_PREFIX="/opt/homebrew"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

ok()   { printf "${GREEN}[OK]${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
info() { printf "${CYAN}[INFO]${NC} %s\n" "$1"; }
fail() { printf "${RED}[FAIL]${NC} %s\n" "$1"; }

# ---------------------------------------------------------------------------
# 1. OS checks
# ---------------------------------------------------------------------------
info "Checking OS and architecture..."

if [[ "$(uname -s)" != "Darwin" ]]; then
	fail "This dotfiles setup is intended for macOS (Apple Silicon)."
	echo "Detected: $(uname -s) on $(uname -m)"
	exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
	fail "This dotfiles setup is intended for Apple Silicon Macs (arm64)."
	echo "Detected architecture: $(uname -m)"
	echo "Intel Macs and other platforms are not supported."
	exit 1
fi
ok "Apple Silicon detected (arm64)"

# ---------------------------------------------------------------------------
# 2. Xcode Command Line Tools (provides git on a fresh Mac)
# ---------------------------------------------------------------------------
info "Checking Xcode Command Line Tools..."
if ! xcode-select -p >/dev/null 2>&1; then
	warn "Command Line Tools not found. Installing (this opens a prompt)..."
	xcode-select --install
	echo "Press Enter once the Command Line Tools finish installing, then re-run ./install.sh"
	read -r _
	exit 1
fi
ok "Command Line Tools present"
command -v git >/dev/null 2>&1 || { fail "'git' not available"; exit 1; }

# ---------------------------------------------------------------------------
# 3. Homebrew
# ---------------------------------------------------------------------------
info "Checking Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
	info "Homebrew not found. Installing..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Homebrew on Apple Silicon lives in /opt/homebrew; refuse the wrong prefix.
if [[ ! -x "$BREW_PREFIX/bin/brew" ]]; then
	fail "Homebrew is not at $BREW_PREFIX/bin/brew."
	echo "This dotfiles setup requires Homebrew at the Apple Silicon path."
	exit 1
fi

eval "$("$BREW_PREFIX/bin/brew" shellenv)"
ok "Homebrew found at $BREW_PREFIX ($(brew --version 2>/dev/null | head -1))"

info "Updating Homebrew..."
brew update >/dev/null 2>&1 || warn "brew update had issues — continuing with what's installed"
ok "Homebrew updated"

# ---------------------------------------------------------------------------
# 4. oh-my-zsh + custom plugins
# ---------------------------------------------------------------------------
info "Ensuring oh-my-zsh and shell plugins..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
	info "Installing oh-my-zsh..."
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

install_omz_plugin() { # $1 = repo, $2 = plugin dir name
	local repo="$1" dir="$2" dest="$ZSH_CUSTOM/plugins/$2"
	if [[ ! -d "$dest" ]]; then
		info "Installing zsh plugin: $2"
		git clone --depth 1 "https://github.com/$repo.git" "$dest"
	else
		info "zsh plugin already present: $2"
	fi
}
install_omz_plugin "lukechilds/zsh-nvm" "zsh-nvm"
install_omz_plugin "zsh-users/zsh-autosuggestions" "zsh-autosuggestions"
ok "Shell plugins ready"

# ---------------------------------------------------------------------------
# 5. Homebrew dependencies (Brewfile)
# ---------------------------------------------------------------------------
info "Installing dependencies via Brewfile..."
"$DOTFILES_DIR/scripts/brew.sh"
ok "Dependencies installed"

# ---------------------------------------------------------------------------
# 5b. Python — latest stable, hard floor 3.12
# ---------------------------------------------------------------------------
# "Latest stable" is read from Homebrew's `python` alias (local brew data),
# so no version is hardcoded here. What matters is the python3 that PATH
# resolves to — Apple's /usr/bin/python3 (3.9.x) must not be the answer.
info "Checking Python (need >= 3.12, latest stable preferred)..."

PY_MIN="3.12"

py_mm() { # $1 = python binary -> "X.Y" ("" on failure)
	"$1" -c 'import sys; print("%d.%d" % sys.version_info[:2])' 2>/dev/null || true
}

py_ge() { # $1 = have "X.Y", $2 = want "X.Y" -> success if have >= want
	local hm="${1%%.*}" hv="${1##*.}" wm="${2%%.*}" wv="${2##*.}"
	(( hm > wm )) || { (( hm == wm )) && (( hv >= wv )); }
}

latest_stable_mm() { # brew's newest stable python as "X.Y" ("" on failure)
	brew info --json=v2 python 2>/dev/null |
		grep -m1 '"stable"' |
		sed -E 's/.*"([0-9]+\.[0-9]+)\.[0-9]+".*/\1/' || true
}

LATEST="$(latest_stable_mm)"
PY3="$(command -v python3 || true)"
CUR=""
if [[ -n "$PY3" ]]; then CUR="$(py_mm "$PY3")"; fi

needs_python=0
if [[ -z "$CUR" ]]; then
	needs_python=1 # python3 missing or unreadable
elif ! py_ge "$CUR" "$PY_MIN"; then
	needs_python=1 # below the floor (e.g. Apple's 3.9.x)
elif [[ -n "$LATEST" ]] && ! py_ge "$CUR" "$LATEST"; then
	needs_python=1 # usable, but older than Homebrew's latest stable
fi

if [[ "$needs_python" -eq 1 ]]; then
	info "Installing Homebrew's latest stable Python (brew install python)..."
	brew install python || warn "brew install python reported errors — verifying what we have..."
fi

# Repair the link if PATH still does not point at Homebrew's python3.
if [[ "$needs_python" -eq 1 && "$(command -v python3 || true)" != "$BREW_PREFIX/bin/python3" ]]; then
	brew link --overwrite python >/dev/null 2>&1 || true
fi

PY3="$(command -v python3 || true)"
CUR=""
if [[ -n "$PY3" ]]; then CUR="$(py_mm "$PY3")"; fi

if [[ -z "$PY3" || -z "$CUR" ]]; then
	fail "python3 not available after setup"
	exit 1
elif ! py_ge "$CUR" "$PY_MIN"; then
	fail "python3 is $CUR ($PY3) — need >= $PY_MIN"
	exit 1
fi

case "$PY3" in
	"$BREW_PREFIX"/*) ;;
	*) warn "python3 is $CUR at $PY3 — outside $BREW_PREFIX, so it can drift from brew's latest" ;;
esac

if [[ -n "$LATEST" ]] && ! py_ge "$CUR" "$LATEST"; then
	warn "python3 is $CUR — latest stable is $LATEST (run: brew upgrade python)"
else
	ok "python3 $CUR at $PY3${LATEST:+ (latest stable $LATEST)}"
fi

# ---------------------------------------------------------------------------
# 6. kitty (official installer — not Homebrew)
# ---------------------------------------------------------------------------
info "Ensuring kitty..."
if [[ -x /Applications/kitty.app/Contents/MacOS/kitty ]]; then
	info "kitty already present"
else
	info "Installing kitty (official installer)..."
	curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
fi
ok "kitty ready"

# ---------------------------------------------------------------------------
# 7. opencode
# ---------------------------------------------------------------------------
info "Ensuring opencode..."
if [[ ! -x "$HOME/.opencode/bin/opencode" ]]; then
	info "Installing opencode (official v2 curl installer)..."
	curl -fsSL https://opencode.ai/v2/install | bash -s -- --no-modify-path
else
	info "opencode already present: $("$HOME/.opencode/bin/opencode" --version 2>/dev/null)"
fi
ok "opencode ready"

# ---------------------------------------------------------------------------
# 8. Directories + symlinks
# ---------------------------------------------------------------------------
info "Creating required directories..."
mkdir -p "$HOME/.config"
ok "Directories ready"

info "Linking dotfiles..."
"$DOTFILES_DIR/scripts/symlinks.sh"

# ---------------------------------------------------------------------------
# 9. Neovim post-install (plugins + treesitter parsers)
# ---------------------------------------------------------------------------
if command -v nvim >/dev/null 2>&1; then
	info "Syncing Neovim plugins (first run downloads them)..."
	if nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1; then
		ok "Neovim plugins synced"
	else
		warn "Neovim plugin sync had issues — run 'nvim +Lazy sync' manually."
	fi
else
	warn "'nvim' not found in PATH — install it and re-run install.sh"
fi

# ---------------------------------------------------------------------------
# 10. Health checks
# ---------------------------------------------------------------------------
info "Running health checks..."
"$DOTFILES_DIR/scripts/doctor.sh" || DOCTOR_STATUS=$?

echo
if [[ "${DOCTOR_STATUS:-0}" -eq 0 ]]; then
	ok "Setup complete."
	echo "Open a new terminal window (or run: exec zsh) for changes to take effect."
	echo "On a fresh machine: nvm install --lts   (zsh-nvm only installs nvm itself)"
else
	fail "Setup finished with errors — review the [FAIL] lines above, fix them, then re-run ./install.sh"
	exit 1
fi