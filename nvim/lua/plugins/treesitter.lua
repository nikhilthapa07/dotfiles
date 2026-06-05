return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false,
		init = function()
			local parsers = {
				"lua",
				"vim",
				"vimdoc",
				"javascript",
				"typescript",
				"tsx",
				"html",
				"css",
				"scss",
				"vue",
				"python",
				"json",
				"gitignore",
			}

			local group = vim.api.nvim_create_augroup("ThePrimeagenTreesitter", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
				group = group,
				callback = function()
					if vim.bo.buftype ~= "" then
						return
					end

					pcall(vim.treesitter.start, 0)
				end,
			})

			vim.api.nvim_create_autocmd("User", {
				group = group,
				pattern = "VeryLazy",
				once = true,
				callback = function()
					require("nvim-treesitter").install(parsers)
				end,
			})
		end,
	},
}
