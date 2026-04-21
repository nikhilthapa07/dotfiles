local set = vim.keymap.set

-- clear search highlights
set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- keybinds to make split navigation easier
set("n", "<M-h>", "<C-w>h", { desc = "Focus left split" })
set("n", "<M-j>", "<C-w>j", { desc = "Focus down split" })
set("n", "<M-k>", "<C-w>k", { desc = "Focus up split" })
set("n", "<M-l>", "<C-w>l", { desc = "Focus right split" })

-- center cursor line when moving half page up or down
set("n", "<C-u>", "<C-u>zz")
set("n", "<C-d>", "<C-d>zz")

-- move visual block vertically
set("v", "J", ":m '>+1<CR>gv=gv")
set("v", "K", ":m '<-2<CR>gv=gv")

-- paste over something without losing your yank(clipboard)
set("x", "<leader>p", [["_dP]])
-- Delete text without affecting your yank
set({ "n", "v" }, "<leader>d", '"_d')

-- press < multiple times to keep shifting left without losing your selection
set("v", "<", "<gv")
-- press > repeatedly to indent multiple times without having to reselect the text
set("v", ">", ">gv")

-- navigate buffers with arrow keys
set("n", "<Right>", ":bnext<CR>")
set("n", "<Left>", ":bprevious<CR>")

-- escape from insert mode on jj
-- use better escape plugin to avoid delay
-- set("i", "jj", "<ESC>")

-- save current buffer
set("n", "<leader>w", "<cmd>noautocmd write<CR>", {
	desc = "Save file without formatting",
})

-- Run current JavaScript file in a horizontal split terminal
set("n", "<leader>rj", function()
	vim.cmd("split | terminal node %")
end, { desc = "Run current JavaScript file" })

-- Run current Python file in a horizontal split terminal
set("n", "<leader>rp", function()
	vim.cmd("split | terminal python3 %")
end, { desc = "Run current python file" })

vim.keymap.set("n", "<leader>co", function()
	vim.lsp.buf.code_action({
		apply = true,
		context = {
			only = {
				"source.removeUnusedImports",
				"source.organizeImports",
			},
		},
	})
end, { desc = "Fix + Clean Imports" })
