-- Database client: browse tables and run queries from inside nvim.
--   <leader>D      → toggle the DBUI drawer
--   open a SQLite file (neo-tree, Telescope, fff, :e foo.db) → it's added as a
--   connection and expanded in DBUI instead of showing the raw binary.
-- In a query buffer, <leader>S (dadbod-ui default) runs the query, and
-- <C-x><C-o> completes table/column names.

-- SQLite files start with this 16-byte header. Empty/new files count too:
-- sqlite3 treats a 0-byte file as an empty database.
local function is_sqlite(path)
	local f = io.open(path, "rb")
	if not f then
		return true
	end
	local header = f:read(16)
	f:close()
	return header == nil or header == "SQLite format 3\0"
end

local function open_in_dbui(path, buf)
	require("lazy").load({ plugins = { "vim-dadbod-ui" } })

	local url = "sqlite:" .. path
	local name = vim.fn.fnamemodify(path, ":~:.")
	local dbs = vim.g.dbs or {}
	local known = vim.iter(dbs):any(function(db)
		return db.url == url
	end)
	if not known then
		table.insert(dbs, { name = name, url = url })
		vim.g.dbs = dbs
		-- DBUI only reads g:dbs when it starts, so close and rebuild it.
		vim.cmd("DBUIClose")
		vim.fn["db_ui#reset_state"]()
	end

	-- Drop the placeholder buffer :edit created, keeping its window on the
	-- previous buffer if there was one.
	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		vim.api.nvim_win_call(win, function()
			local alt = vim.fn.bufnr("#")
			if alt > 0 and alt ~= buf and vim.fn.buflisted(alt) == 1 then
				vim.api.nvim_win_set_buf(win, alt)
			end
		end)
	end
	pcall(vim.api.nvim_buf_delete, buf, { force = true })

	vim.cmd("DBUI") -- opens (or focuses) the drawer
	-- Put the cursor on this database and expand it if it's collapsed.
	local collapsed = vim.g.db_ui_icons.collapsed.db
	for lnum, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
		if line:find(name, 1, true) then
			vim.api.nvim_win_set_cursor(0, { lnum, 0 })
			if vim.startswith(vim.trim(line), collapsed) then
				vim.api.nvim_feedkeys(vim.keycode("<Plug>(DBUI_SelectLine)"), "m", false)
			end
			break
		end
	end
end

return {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod", lazy = true },
		{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
	},
	cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
	keys = {
		{ "<leader>D", "<cmd>DBUIToggle<cr>", desc = "Toggle database UI (dadbod)" },
	},
	init = function()
		vim.g.db_ui_use_nerd_fonts = 1

		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "sql", "mysql", "plsql" },
			callback = function()
				vim.bo.omnifunc = "vim_dadbod_completion#omni"
			end,
		})

		vim.api.nvim_create_autocmd("BufReadCmd", {
			pattern = { "*.db", "*.sqlite", "*.sqlite3", "*.db3" },
			callback = function(args)
				local path = vim.fn.fnamemodify(args.match, ":p")
				if not is_sqlite(path) then
					-- Some other kind of .db file: read it normally.
					vim.cmd("silent keepalt read ++edit " .. vim.fn.fnameescape(path))
					vim.cmd("silent 1delete _")
					vim.api.nvim_exec_autocmds("BufReadPost", { pattern = path })
					return
				end
				-- Defer until :edit (and neo-tree's own window handling) finishes.
				vim.schedule(function()
					open_in_dbui(path, args.buf)
				end)
			end,
		})
	end,
}
