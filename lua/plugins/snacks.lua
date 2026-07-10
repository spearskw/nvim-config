return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		image = {
			enabled = true, -- Explicitly enable the image viewer
			doc = {
				enabled = true, -- Enable inline image previews for Markdown/HTML
			},
		},
		bigfile = {
			enabled = true,
			-- Any file larger than this: no treesitter, no LSP, no syntax,
			-- so giant CSVs / logs open instantly instead of being parsed.
			size = 1 * 1024 * 1024, -- 1 MB
			line_length = 5000, -- also trip on very long single lines (minified/one-line data)
		},
		-- Interactive git TUI (branches, commits, files, staging). Needs the
		-- `lazygit` binary on PATH: `brew install lazygit`.
		lazygit = { enabled = true },
	},
	keys = {
		{
			"<leader>gg",
			function()
				Snacks.lazygit()
			end,
			desc = "Lazygit",
		},
	},
}
