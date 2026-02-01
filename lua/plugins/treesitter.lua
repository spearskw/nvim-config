local function config()
	vim.treesitter.language.register("kulala_http", "http")
	vim.treesitter.language.register("helm", "yaml")

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "http",
		callback = function()
			vim.treesitter.start()
		end,
	})

	local ts_config = require("nvim-treesitter.config")

	ts_config.setup({
		-- 'ensure_installed' is deprecated in main; use 'auto_install' or install manually
		auto_install = true,

		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},

		indent = {
			enable = true,
		},
	})

	-- Manually install the parsers you want (since ensure_installed is gone in main)
	-- This command runs asynchronously
	require("nvim-treesitter").install({
		"lua",
		"vim",
		"vimdoc",
		"query",
	})
end

return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	branch = "main", -- Forces the new rewritten version
	build = ":TSUpdate",
	config = config,
}
