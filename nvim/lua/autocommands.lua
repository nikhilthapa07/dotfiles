local autocmd = vim.api.nvim_create_autocmd

autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp", { clear = true }),
	callback = function(e)
		vim.keymap.set("n", "grd", vim.lsp.buf.definition, {
			buffer = e.buf,
			desc = "LSP: Go to Definition",
		})
	end,
})

-- Highlight on yank
autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})
