# dotfiles

Personal macOS development environment for **Apple Silicon Macs (arm64)**.

Manage your shell, editor, terminal and tooling from one Git repository with a
one-command setup for a brand-new M1/M2/M3/M4 Mac.

## Layout

```
dotfiles/
├── install.sh              # one-command setup entrypoint
├── Brewfile                # system dependencies (Homebrew)
├── .gitignore
├── README.md
├── home/                   # shell dotfiles (symlinked to ~)
│   ├── .zshrc
│   ├── .zprofile
│   ├── .zshenv
│   └── .profile
├── config/
│   ├── nvim/               # Neovim config (lazy.nvim + lazy-lock.json)
│   └── kitty/              # Kitty terminal config
├── tmux/
│   ├── tmux.conf           # -> ~/.config/tmux/tmux.conf
│   └── sessionizer/        # tmux-sessionizer script + search-path config
├── git/
│   └── .gitconfig
└── scripts/
    ├── brew.sh             # brew bundle --file Brewfile
    ├── symlinks.sh         # create symlinks (+ timestamped backups)
    └── doctor.sh           # read-only health checks
```

## Installation (new Apple Silicon Mac)

```bash
git clone https://github.com/nikhilthapa07/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` performs, in order:

1. Checks it is macOS on `arm64` (refuses otherwise).
2. Ensures Xcode Command Line Tools (needed for `git`).
3. Installs Homebrew if missing (Apple Silicon path `/opt/homebrew`) and updates it.
4. Installs oh-my-zsh and the plugin clones (`zsh-nvm`, `zsh-autosuggestions`).
5. Installs all system dependencies from the `Brewfile` via `brew bundle`.
6. Installs kitty via the official installer (not Homebrew).
7. Installs opencode v2 via the official installer script (if not already present).
8. Creates directories and symlinks all configs into `~`.
9. Syncs Neovim plugins with lazy.nvim (first run downloads everything).
10. Runs `doctor.sh` and prints a summary.

It is fully idempotent — run it as many times as you like.

## Updating after config changes

```bash
cd ~/dotfiles
git add .
git commit -m "update config"
git push
```

On the Mac you edited, just add/commit/push; on other machines, `git pull` and
re-run `scripts/symlinks.sh` (the files you edit are inside the repo already,
so a pull is all that's needed to update them).

## Making changes

Everything in this repo is the source of truth; the live files in `~` are
symlinks, so you always edit the files inside `~/dotfiles`, then commit them.

### Installing / removing programs

Programs are declared in the `Brewfile` (single source of truth).

**Add a program:**

1. Edit `~/dotfiles/Brewfile` — add a line in the "Required" section, or
   uncomment an entry from the "Optional" section:

   ```brewfile
   brew "jq"          # a command-line tool
   cask "appname"     # a GUI app
   ```

2. Install it:

   ```bash
   cd ~/dotfiles
   bash scripts/brew.sh          # installs everything listed in the Brewfile
   ```

3. Commit and push. On other machines: `git pull` + `bash scripts/brew.sh`.

**Remove a program:**

1. Delete its line from the `Brewfile`.
2. Uninstall it manually (brew bundle never uninstalls on its own — deliberate,
   so nothing is removed without you asking):

   ```bash
   brew uninstall jq             # or: brew uninstall --cask appname
   ```

   To remove everything not listed in the Brewfile in one go (careful — this
   can remove tools you still want):

   ```bash
   brew bundle cleanup --force --file Brewfile
   ```

3. Commit and push.

`scripts/doctor.sh` reads the Brewfile directly, so the health check always
matches exactly what you require — no second list to keep in sync.

### Editing configs

Because the live paths are symlinks, your edits go directly into the repo —
most take effect immediately (after a reload):

| What | File(s) in repo | Reload |
|------|-----------------|--------|
| Shell | `home/.zshrc`, `home/.zprofile`, `home/.zshenv` | `exec zsh` (or new terminal) |
| Neovim config | `config/nvim/init.lua`, `config/nvim/lua/**` | restart nvim |
| Neovim plugins | `config/nvim/lua/plugins/*.lua` (+ `lazy-lock.json`) | `nvim +Lazy sync` |
| Kitty | `config/kitty/kitty.conf`, `config/kitty/current-theme.conf` | hot-reloads on save |
| tmux | `tmux/tmux.conf` | `tmux source-file ~/.config/tmux/tmux.conf` |
| Git identity | `git/.gitconfig` | applies on next git command |
| tmux-sessionizer paths | `tmux/sessionizer/tmux-sessionizer.conf` | next sessionizer run |
| opencode | `~/.config/opencode/` (untracked, machine-local) | auto-applies; `/connect` for keys |

Then commit and push. Other machines only need `git pull` — the configs are
already symlinked into place. Run `bash scripts/symlinks.sh` only if you added
a **brand-new** file path that needs its own symlink (and add it to the `LINKS`
list in `scripts/symlinks.sh`).

Neovim specifics:

- **Add a plugin**: create a file in `config/nvim/lua/plugins/` following the
  existing patterns, restart nvim (Lazy installs it), then commit
  `lazy-lock.json` too so plugin versions stay reproducible.
- **Change keymaps/options/autocommands**: edit the matching file under
  `config/nvim/lua/` and restart nvim.
- **LSP servers** are installed by Mason on first launch (`auto_install`) — not
  tracked in git, nothing to commit.

Validate any change with:

```bash
bash scripts/doctor.sh
```

## Dependencies

`Brewfile` declares *system-level* dependencies and is the single source of
truth for them. `brew bundle` (via `scripts/brew.sh`) installs exactly that,
and `doctor.sh` reads the same file to verify it. Edit the Brewfile and the
health check follows automatically.

Required tools include: `neovim`, `tmux`, `git`, `pnpm`, `uv`, `go`,
`python` (Homebrew's alias for the latest stable release — `install.sh`
installs it and `doctor.sh` enforces that `python3` on PATH is >= 3.12),
`tree-sitter(-cli)`, `fzf`, `fd`, `ripgrep`, `lazygit`, and
`zsh-autosuggestions`.

### kitty

`kitty` is **not** installed by Homebrew. It is installed via the official
installer (to `/Applications/kitty.app`) with:

```bash
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
```

Re-run that command to update kitty.

### Node.js and nvm

Node is **not** installed by Homebrew. It is managed by **nvm** through the
`zsh-nvm` oh-my-zsh plugin, which installs nvm itself on first shell.

After the first install, run once per machine:

```bash
nvm install --lts
```

### opencode

`opencode` is installed via the official v2 installer script to `~/.opencode/bin`
(not the Brewfile — keeps a single install method so `opencode upgrade` keeps
working).
`.zshrc` already adds it to `PATH`. Update it any time with:

```bash
opencode upgrade
```

On a fresh machine, run `opencode` and use `/connect` to add API keys for your
LLM provider.

### Go and Rust

- `go` is installed via Homebrew on a fresh machine. (On this machine a
  previous official install at `/usr/local/go` coexists — different PATH
  location, no conflict.)
- Rust (`~/.cargo`) is installed separately with rustup; `.zshenv`/`.profile`
  source `~/.cargo/env` only if it exists, so a machine without Rust works fine.

## Neovim

`config/nvim/` is a standard lazy.nvim setup. Plugins, treesitter parsers and
Mason LSP servers are all installed by Neovim itself (lazy.nvim auto-clones,
treesitter compiles parsers, `mason` with `auto_install` handles LSPs).

`lazy-lock.json` is committed so plugin versions stay reproducible.

## tmux

`tmux/tmux.conf` symlinks to `~/.config/tmux/tmux.conf` (the XDG location tmux
3.x reads). It binds `f` to `tmux-sessionizer` (in `tmux/sessionizer/`), which
requires `fzf` and `tmux`.

The sessionizer search paths live in
`tmux/sessionizer/tmux-sessionizer.conf` — machine-specific; edit there.

## Secrets

Nothing secret is committed. Machine-specific values should live outside this
repo:

- `.env` files, `*.local`, `*.secret`, keys/tokens -> ignored by `.gitignore`
- SSH keys stay in `~/.ssh` (never committed)
- The single Git identity lives in `git/.gitconfig` (name/email only, no
  credentials). To use a different identity on a machine, edit that file.

## Doctor

Run the read-only health check any time:

```bash
./scripts/doctor.sh
```

Shows `[OK]` / `[WARN]` / `[FAIL]` for architecture, Homebrew, required
formulas (derived from the `Brewfile`), required binaries, symlinks, Neovim,
tmux, Kitty, Zsh, Node, and opencode.
Exits non-zero if any check fails.

## Manual steps (can't be automated)

- `nvm install --lts` once per machine (as above).
- Install Rust with rustup if you need it: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`.
- Non-Homebrew GUI apps (Docker, Chrome, Slack, Postman, etc.).
- SSH keys: `ssh-keygen` / copy from another machine to `~/.ssh`.
- macOS System Settings, keyboard/trackpad preferences.
- First `nvim` launch may ask to install Mason LSP servers (auto).
