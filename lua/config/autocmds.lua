-- Format the current Lua buffer with stylua, preserving cursor/scroll position.
-- Buffer-local so <leader>F only exists where it makes sense.
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("user_stylua_map", { clear = true }),
	pattern = "lua",
	callback = function(ev)
		vim.keymap.set("n", "<leader>F", function()
			local view = vim.fn.winsaveview() -- save cursor/scroll position

			-- '%' = whole file, '!' = filter through an external command.
			-- 'stylua -' reads from stdin and writes to stdout.
			vim.cmd(":%!stylua -")

			if vim.v.shell_error ~= 0 then
				vim.cmd("undo") -- stylua failed (or isn't installed); revert the filter
				vim.notify("stylua formatting failed", vim.log.levels.ERROR)
			else
				vim.fn.winrestview(view)
				vim.notify("formatted with stylua", vim.log.levels.INFO)
			end
		end, { buffer = ev.buf, silent = true, desc = "Format buffer with stylua" })
	end,
})

-- Warn before nvim slurps a huge file entirely into RAM. snacks.bigfile makes
-- large *text* usable (no parsing); this is the extra backstop for the
-- multi-GB binaries (.tar/.pbf) where opening in an editor is a mistake.
vim.api.nvim_create_autocmd("BufReadPre", {
	group = vim.api.nvim_create_augroup("user_hugefile_guard", { clear = true }),
	callback = function(ev)
		local ok, stat = pcall(vim.uv.fs_stat, ev.match)
		if not ok or not stat then
			return
		end
		local mb = stat.size / (1024 * 1024)
		if mb >= 1024 then
			vim.notify(
				string.format(
					"This file is %.1f GB — nvim loads it fully into RAM. Prefer the shell (less/tar/osmium).",
					mb / 1024
				),
				vim.log.levels.WARN
			)
		elseif mb >= 200 then
			vim.notify(string.format("Large file: %.0f MB. bigfile mode active (no parsing).", mb), vim.log.levels.WARN)
		end
	end,
})

-- :DiffOrig — diff the buffer against the on-disk version of the file.
vim.api.nvim_create_user_command("DiffOrig", function()
	vim.cmd("vert new")
	vim.bo.buftype = "nofile"
	vim.cmd("read ++edit #")
	vim.cmd("0d_")
	vim.cmd("diffthis")
	vim.cmd("wincmd p")
	vim.cmd("diffthis")
end, { desc = "Diff buffer against the saved file" })
