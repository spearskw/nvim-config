return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons", -- optional, but recommended
	},
	lazy = false, -- neo-tree defers its own heavy loading; keep it eager so it can hijack netrw
	keys = {
		{ "<leader>n", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer (neo-tree)" },
	},
	opts = {
		filesystem = {
			filtered_items = {
				visible = false, -- hidden items stay hidden until you toggle with shift-h
				hide_dotfiles = true,
				hide_gitignored = false,
				-- hidden by default, but revealed when you toggle show-all (shift-h)
				hide_by_name = {
					"__pycache__",
				},
			},
		},
		window = {
			mappings = {
				-- neo-tree maps <space> to toggle_node by default, which shadows the
				-- <leader> key inside the tree. Free it up so which-key works here too.
				["<space>"] = "none",
				-- keep an easy way to expand/collapse folders
				["l"] = "toggle_node",
			},
		},
	},
}
