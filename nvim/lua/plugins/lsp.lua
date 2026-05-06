return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		opts = {
			automatic_enable = false,
			auto_install = true,
		},
	},
	{
		"b0o/SchemaStore.nvim",
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = {
							-- Get the language server to recognize the `vim` global
							globals = { "vim" },
						},
					},
				},
			})
			vim.lsp.enable("lua_ls")

			vim.lsp.config("vue_ls", {})
			vim.lsp.enable("vue_ls")

			vim.lsp.config("vtsls", {
				settings = {
					vtsls = {
						tsserver = {
							globalPlugins = {
								{
									name = "@vue/typescript-plugin",
									location = vim.fn.stdpath("data")
										.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
									languages = { "vue" },
									configNamespace = "typescript",
								},
							},
						},
					},
				},
				filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
			})
			vim.lsp.enable("vtsls")

			vim.lsp.config("jsonls", {
				capabilities = capabilities,
				settings = {
					json = {
						schemas = require("schemastore").json.schemas(),
						validate = { enable = true },
						format = { enable = true },
					},
				},
			})
			vim.lsp.enable("jsonls")

			vim.lsp.config("html", {
				filetypes = { "html" },
				capabilities = capabilities,
			})
			vim.lsp.enable("html")

			vim.lsp.config("emmet_language_server", {
				filetypes = { "html", "css", "javascriptreact", "typescriptreact", "vue" },
				capabilities = capabilities,
			})
			vim.lsp.enable("emmet_language_server")

			vim.lsp.config("cssls", {
				filetypes = { "css", "scss", "less" },
				capabilities = capabilities,
			})
			vim.lsp.enable("cssls")

			vim.lsp.config("tailwindcss", {
				capabilities = capabilities,
			})
			vim.lsp.enable("tailwindcss")

			vim.lsp.config("pyright", {
				capabilities = capabilities,
			})
			vim.lsp.enable("pyright")

			vim.lsp.config("rust_analyzer", {
				settings = {
					["rust-analyzer"] = {
						files = {
							watcher = "server",
						},
						check = {
							command = "clippy",
						},
						diagnostics = {
							enable = false,
						},
					},
				},
				capabilities = capabilities,
			})
			vim.lsp.enable("rust_analyzer")
		end,
	},
}
