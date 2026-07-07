-- Git blame in a side view. Loads only when you open it.
return {
	"FabijanZulj/blame.nvim",
	cmd = { "BlameToggle" },
	keys = {
		{ "<leader>gb", "<cmd>BlameToggle<cr>", desc = "Toggle git blame" },
	},
	opts = {},
}
