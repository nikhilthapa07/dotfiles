return {
	"stevearc/oil.nvim",
	lazy = false,
	config = function()
		require("oil").setup({
			keymaps = {
				["<C-h>"] = false,
			},
		})
		vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Oil: Open parent directory" })
	end,
}
