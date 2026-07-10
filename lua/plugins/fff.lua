-- Fast in-memory fuzzy file finder + live grep (Rust core, frecency-ranked).
-- Complements Telescope rather than replacing it: Telescope keeps owning the
-- lowercase <leader>f* pickers (ff/fg/fb/fh/fa); fff gets the capitalized
-- siblings in the same "find" group, so nothing clashes.
--   <leader>fF → fff find files   (cf. <leader>ff Telescope)
--   <leader>fG → fff live grep    (cf. <leader>fg Telescope)
return {
	"dmtrKovalenko/fff.nvim",
	-- Downloads a prebuilt binary (falls back to a cargo build if needed).
	build = function()
		require("fff.download").download_or_build_binary()
	end,
	-- Load on first use of either key rather than at startup.
	keys = {
		{ "<leader>fF", function() require("fff").find_files() end, desc = "Find files (fff)" },
		{ "<leader>fG", function() require("fff").live_grep() end, desc = "Live grep (fff)" },
	},
	-- lazy.nvim runs require("fff").setup(opts) with this table.
	opts = {},
}
