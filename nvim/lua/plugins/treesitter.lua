return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		config = function()
			require("nvim-treesitter.config").setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})
		end,
	},
}
