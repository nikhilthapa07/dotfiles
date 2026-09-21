return {
	-- override the comment string for a given treesitter language
	{
		"folke/ts-comments.nvim",
		opts = {},
		event = "VeryLazy",
		enabled = vim.fn.has("nvim-0.10.0") == 1,
	},
	-- Autotags
	{
		"windwp/nvim-ts-autotag",
		ft = { "html", "vue", "javascriptreact", "typescriptreact" },
		dependencies = { "nvim-treesitter/nvim-treesitter" }, -- explicitly depend on Treesitter and load on filetypes
		opts = {},
	},
	-- auto pairs brackets
	{
		"windwp/nvim-autopairs",
		ft = { "javascript", "typescirpt", "javascriptreact", "typescriptreact", "vue" },
		event = "InsertEnter",
		config = true,
	},
}
