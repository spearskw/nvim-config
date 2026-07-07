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
}
