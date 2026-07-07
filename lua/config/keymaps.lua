-- General, plugin-agnostic keymaps. Plugin-specific maps live with their
-- plugin spec (telescope pickers in plugins/telescope.lua, LSP maps in
-- plugins/lsp.lua on attach, etc.).

-- Treesitter is auto-started per buffer (see plugins/treesitter.lua). This just
-- toggles it off/on for the current buffer when you want to compare or if a
-- parser mishighlights something.
vim.keymap.set("n", "<leader>t", function()
	local buf = vim.api.nvim_get_current_buf()
	if vim.treesitter.highlighter.active[buf] then
		vim.treesitter.stop(buf)
		vim.notify("treesitter off", vim.log.levels.INFO)
	else
		local ok = pcall(vim.treesitter.start, buf)
		vim.notify(ok and "treesitter on" or "no parser for this filetype", vim.log.levels.INFO)
	end
end, { desc = "Toggle treesitter" })

vim.keymap.set("n", "<leader>w", "<C-w>", { noremap = true, silent = true, desc = "Window command prefix" })
