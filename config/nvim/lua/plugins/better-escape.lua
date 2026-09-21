return {
	"max397574/better-escape.nvim",
	opts = {
		timeout = vim.o.timeoutlen, -- after `timeout` passes, you can press the escape key and the plugin will ignore it
		default_mappings = false, -- setting this to false removes all the default mappings
		mappings = {
			-- i for insert
			i = {
				j = {
					-- These can all also be functions
					j = "<Esc>",
				},
			},
		},
	},
	config = function(_, opts)
		require("better_escape").setup(opts)
	end,
}
