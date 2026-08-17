return {
	"stevearc/oil.nvim",
	lazy = false,
	config = function()
		require("oil").setup()
		vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Oil: Open parent directory" })
	end,
}
