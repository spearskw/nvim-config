return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		-- Label the leader prefixes so the popup shows "+window", "+find", etc.
		spec = {
			{ "<leader>w", group = "window" },
			{ "<leader>g", group = "git" },
			{ "<leader>f", group = "find" },
			{ "<leader>s", group = "swap" },
			{ "<leader>R", group = "rest (kulala)" },
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
