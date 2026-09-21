return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPost", "BufNewFile" },
	keys = {
		{
			"[h",
			function()
				require("gitsigns").prev_hunk({ navigation_message = false })
			end,
			desc = "Prev Hunk",
		},
		{
			"]h",
			function()
				require("gitsigns").next_hunk({ navigation_message = false })
			end,
			desc = "Next Hunk",
		},
	},
	opts = {
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
	},
}
