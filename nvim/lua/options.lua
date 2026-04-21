local o = vim.o

-- show line numbers default
o.number = true
-- line numbers on the left are shown relative to the current cursor line.
o.relativenumber = true

-- minimum scroll space/lines above and below the cursor in Neovim
o.scrolloff = 4

-- Sync clipboard between OS and Neovim.
-- Schedule the setting after `UiEnter` because it can increase startup-time.
-- Remove this option if you want your OS clipboard to remain independent.
-- see `:help 'clipboard'`
vim.schedule(function()
	o.clipboard = "unnamedplus"
end)

-- swap files are temporary files that Neovim creates to store changes made to a file.
-- helps in recovering unsaved changes in case of a crash or unexpected shutdown.
o.swapfile = false
-- when this option is enabled, Neovim creates a backup copy of a file before overwriting it.
o.backup = false
-- sets the directory for storing undo files.
-- undo files allow you to undo changes even after closing and reopening a file.
o.undodir = os.getenv("HOME") .. "/.vim/undodir"
-- enables persistent undo.
-- when this option is set to true, changes made to files can be undone even after closing and reopening them
o.undofile = true

-- makes searches case-insensitive by default
-- searching for hello will match Hello, HELLO, hello, etc.
o.ignorecase = true

-- makes searches case-sensitive only when you type uppercase letters
-- works in conjunction with ignorecase
-- examples: Search hello → matches all cases (case-insensitive due to ignorecase) o.smartcase = true

-- the sign column is a narrow vertical strip on the left side of the editor
-- withtout this, the sign column appears and disappears dynamically, when diagnostics are added or removed.
-- values: yes, no, auto, auto:1-9 (auto-show, but reserve space for up to 9 signs)
o.signcolumn = "yes:1"

-- The delay before certain plugins (like git decorations,  refresh their display
-- Lower values = more responsive, but higher CPU usage.
-- Higher values = less responsive, but more efficient.
o.updatetime = 250

-- if you're typing a leader-key combination (<Leader>w), this is how long it waits for the second key
-- Higher values = more forgiving, but feels sluggish.
o.timeoutlen = 300

-- When you open a vertical split (:vsplit), the new window appears to the right of the current window.
-- Default in Vim is to open on the left.
o.splitright = true
-- When you open a horizontal split (:split), the new window appears below the current window.
-- Default in Vim is to open above.
o.splitbelow = true

-- Enables incremental preview for commands like :s/foo/bar/.
-- "split" means Vim shows the replacement results in a live preview in a split window as you type the command.
o.inccommand = "split"

-- Vim will ask for confirmation instead of throwing errors when closing files with unsaved changes.
o.confirm = true

-- Sets window borders to be rounded instead of square.
-- Only visible in Neovim UI elements (like :help, floating windows, LSP windows).
-- o.winborder = "rounded"

-- Enables true color support in the terminal.
-- Necessary if you use modern color schemes with 24-bit colors.
o.termguicolors = true
