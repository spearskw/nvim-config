local function config()
	-- kulala.nvim registers http -> kulala_http itself once it builds its parser.
	vim.treesitter.language.register("helm", "yaml")

	-- NOTE (main branch): config.setup() only reads `install_dir`. Highlighting is
	-- NOT enabled by a config key here — it is per-buffer via vim.treesitter.start().
	-- `auto_install`/`highlight`/`indent` config keys do nothing on this branch.
	require("nvim-treesitter.config").setup({})

	-- Turn treesitter ON automatically for every buffer that has a parser.
	-- Enables highlighting (colors) + smarter indentation. Neither ever rewrites
	-- existing lines: indentexpr only acts on lines you actively type or on an
	-- explicit `=` reindent. snacks.bigfile sets ft=bigfile on oversized files
	-- (no parser) so start() no-ops there and big files stay unparsed.
	vim.api.nvim_create_autocmd("FileType", {
		callback = function(ev)
			if pcall(vim.treesitter.start, ev.buf) then
				vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end
		end,
	})

	-- Manually install the parsers you want (since ensure_installed is gone in main)
	-- This command runs asynchronously. auto_install (above) also grabs parsers
	-- on-demand when you open a filetype, but installing the core set up front
	-- means highlighting/outline work the first time you open these.
	require("nvim-treesitter").install({
		-- editor internals
		"lua", "vim", "vimdoc", "query",
		-- your languages
		"zig", "go", "gomod", "gosum",
		"java",
		"javascript", "typescript", "tsx", "jsdoc",
		"html", "css", "scss",
		"python",
		-- common data/config formats you read
		"json", "yaml", "toml", "markdown", "markdown_inline",
		"bash", "dockerfile", "sql", "csv",
	})
end

return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	branch = "main", -- Forces the new rewritten version
	build = ":TSUpdate",
	config = config,
}
