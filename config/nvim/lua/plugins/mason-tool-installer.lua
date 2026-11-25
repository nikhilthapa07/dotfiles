return {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	lazy = false,
	config = function()
		require("mason-tool-installer").setup({
            ensure_installed = {
                -- LSP servers (Mason package names)
                "pyright",
                "vtsls",
                "clangd",
                "gopls",
                "lua-language-server", -- lua_ls
                "vue-language-server", -- vue_ls (+ @vue/typescript-plugin used by vtsls)
                "json-lsp", -- jsonls
                "html-lsp", -- html
                "css-lsp", -- cssls
                "tailwindcss-language-server", -- tailwindcss
                "emmet-language-server", -- emmet_language_server
                "vim-language-server", -- vimls

                -- formatters used by conform
                "stylua",
                "prettier",
                "isort"
            },
            run_on_start = true,
            start_delay = 0,
            -- update manually with :MasonToolsUpdate
            auto_update = false,
    })
	end,
}