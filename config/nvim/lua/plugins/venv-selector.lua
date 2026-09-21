return {
	"linux-cultist/venv-selector.nvim",
	dependencies = {
		{ "nvim-telescope/telescope.nvim", version = "*", dependencies = { "nvim-lua/plenary.nvim" } },
	},
	ft = "python", -- Load when opening Python files
	opts = {
		options = {}, -- plugin-wide options
		search = {}, -- custom search definitions
	},
}
