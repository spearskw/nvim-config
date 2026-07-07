return {
	"nvim-telescope/telescope.nvim",
	tag = "v0.2.1",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	-- Lazy-load on first picker keypress or any :Telescope command (aerial's
	-- <leader>fa and the LSP pickers both go through :Telescope / builtin).
	cmd = "Telescope",
	keys = {
		{ "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Telescope find files" },
		{ "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Telescope live grep" },
		{ "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Telescope buffers" },
		{ "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Telescope help tags" },
	},
	config = function()
		require("telescope").setup({})
		-- Activate the native fzf sorter (the `build = "make"` above compiles it,
		-- but it does nothing until the extension is loaded).
		pcall(require("telescope").load_extension, "fzf")
	end,
}
