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
			-- Don't nag that features are disabled — that's the point, just open
			-- the file. (Also stops the double warning on gzipped files, where the
			-- gzip plugin re-fires FileType and the notification would show twice.)
			notify = false,
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
