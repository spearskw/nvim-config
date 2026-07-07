-- Code outline / symbol navigation.
-- Uses the treesitter backend by default, so it works on any file with a
-- parser WITHOUT an LSP. If you toggle an LSP on, it automatically upgrades
-- to richer LSP symbols for that buffer.
return {
	"stevearc/aerial.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	cmd = { "AerialToggle", "AerialNavToggle" },
	keys = {
		{ "<leader>a", "<cmd>AerialToggle<cr>", desc = "Toggle code outline (aerial)" },
		{ "<leader>fa", "<cmd>Telescope aerial<cr>", desc = "Find symbol (aerial)" },
	},
	opts = {
		-- Prefer treesitter (no LSP needed); fall back / upgrade to LSP when attached.
		backends = { "treesitter", "lsp", "markdown", "man" },
		layout = { default_direction = "prefer_right", min_width = 30 },
		show_guides = true,
		-- Jump to symbol nearest the cursor when opening.
		attach_mode = "global",
	},
	config = function(_, opts)
		require("aerial").setup(opts)
		-- Register the telescope picker used by <leader>fa (no-op if telescope absent).
		pcall(require("telescope").load_extension, "aerial")
	end,
}
