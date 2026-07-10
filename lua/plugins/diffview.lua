-- IntelliJ-style git history + diff browsing.
--   <leader>gh : repo-wide commit history (move over commits -> file panel -> diff)
--   <leader>gf : history for the current file only
--   <leader>gd : diff of the working tree against HEAD
--   <leader>gc : close the diffview tab
-- Loads only when one of these commands/keys is used.
return {
	"sindrets/diffview.nvim",
	cmd = {
		"DiffviewOpen",
		"DiffviewFileHistory",
		"DiffviewClose",
	},
	keys = {
		{ "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "Git repo history" },
		{ "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Git current-file history" },
		{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git diff (working tree)" },
		{ "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
	},
	opts = {
		enhanced_diff_hl = true, -- clearer added/removed highlighting
	},
}
