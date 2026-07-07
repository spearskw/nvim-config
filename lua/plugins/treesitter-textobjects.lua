-- Treesitter-powered motions + textobjects (main branch, matches your
-- main-branch nvim-treesitter). Works with LSP OFF — pure treesitter.
--
-- Motions (normal/visual/operator), repeat with ; and , :
--   ]f [f  next/prev function start      ]F [F  function end
--   ]] [[  next/prev class start         ][ []  class end
--   ]a [a  next/prev parameter
--
-- Textobjects (visual + operator-pending, e.g. `vif`, `daf`, `cia`):
--   af/if function   ac/ic class   aa/ia parameter (argument)
--   al/il loop       an/in conditional   am comment
--
-- Swap (normal):
--   <leader>sa swap parameter with next   <leader>sA with previous
return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	event = "VeryLazy", -- after UI; no startup cost
	config = function()
		require("nvim-treesitter-textobjects").setup({
			select = {
				lookahead = true, -- jump forward to the next textobject if not inside one
			},
			move = {
				set_jumps = true, -- record motions in the jumplist
			},
		})

		local select = require("nvim-treesitter-textobjects.select")
		local move = require("nvim-treesitter-textobjects.move")
		local rep = require("nvim-treesitter-textobjects.repeatable_move")

		-- ---- textobjects (visual + operator-pending) ----
		local objs = {
			af = "@function.outer",
			["if"] = "@function.inner",
			ac = "@class.outer",
			ic = "@class.inner",
			aa = "@parameter.outer",
			ia = "@parameter.inner",
			al = "@loop.outer",
			il = "@loop.inner",
			an = "@conditional.outer",
			["in"] = "@conditional.inner",
			am = "@comment.outer",
		}
		for lhs, query in pairs(objs) do
			vim.keymap.set({ "x", "o" }, lhs, function()
				select.select_textobject(query, "textobjects")
			end, { silent = true, desc = "TS textobject " .. query })
		end

		-- ---- motions (normal + visual + operator), all repeatable ----
		local map = function(lhs, fn, query, desc)
			vim.keymap.set({ "n", "x", "o" }, lhs, function()
				fn(query, "textobjects")
			end, { silent = true, desc = desc })
		end
		map("]f", move.goto_next_start, "@function.outer", "Next function start")
		map("[f", move.goto_previous_start, "@function.outer", "Prev function start")
		map("]F", move.goto_next_end, "@function.outer", "Next function end")
		map("[F", move.goto_previous_end, "@function.outer", "Prev function end")
		map("]]", move.goto_next_start, "@class.outer", "Next class start")
		map("[[", move.goto_previous_start, "@class.outer", "Prev class start")
		map("][", move.goto_next_end, "@class.outer", "Next class end")
		map("[]", move.goto_previous_end, "@class.outer", "Prev class end")
		map("]a", move.goto_next_start, "@parameter.inner", "Next parameter")
		map("[a", move.goto_previous_start, "@parameter.inner", "Prev parameter")

		-- ---- repeat last move with ; and , (also keeps f/F/t/T repeatable) ----
		vim.keymap.set({ "n", "x", "o" }, ";", rep.repeat_last_move_next, { desc = "Repeat move forward" })
		vim.keymap.set({ "n", "x", "o" }, ",", rep.repeat_last_move_previous, { desc = "Repeat move backward" })
		vim.keymap.set({ "n", "x", "o" }, "f", rep.builtin_f_expr, { expr = true })
		vim.keymap.set({ "n", "x", "o" }, "F", rep.builtin_F_expr, { expr = true })
		vim.keymap.set({ "n", "x", "o" }, "t", rep.builtin_t_expr, { expr = true })
		vim.keymap.set({ "n", "x", "o" }, "T", rep.builtin_T_expr, { expr = true })

		-- ---- swap parameters ----
		local swap = require("nvim-treesitter-textobjects.swap")
		vim.keymap.set("n", "<leader>sa", function()
			swap.swap_next("@parameter.inner")
		end, { silent = true, desc = "Swap parameter with next" })
		vim.keymap.set("n", "<leader>sA", function()
			swap.swap_previous("@parameter.inner")
		end, { silent = true, desc = "Swap parameter with previous" })
	end,
}
