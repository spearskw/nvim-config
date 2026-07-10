-- Gutter markers for added/changed/removed lines, hunk navigation, and
-- per-hunk stage/reset/preview -- the inline "what changed" view.
--   ]h / [h        : next / prev hunk
--   <leader>gs / gr : stage / reset hunk
--   <leader>gp      : preview hunk in a floating window
--   <leader>gL      : toggle inline (virtual-text) line blame
return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		on_attach = function(bufnr)
			local gs = require("gitsigns")
			local function map(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
			end

			-- Hunk navigation.
			map("n", "]h", function()
				gs.nav_hunk("next")
			end, "Next git hunk")
			map("n", "[h", function()
				gs.nav_hunk("prev")
			end, "Prev git hunk")

			-- Stage / reset / preview.
			map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
			map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
			map("v", "<leader>gs", function()
				gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, "Stage selection")
			map("v", "<leader>gr", function()
				gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, "Reset selection")
			map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")

			-- Inline line blame toggle (distinct from blame.nvim's side view on <leader>gb).
			map("n", "<leader>gL", gs.toggle_current_line_blame, "Toggle inline line blame")
		end,
	},
}
