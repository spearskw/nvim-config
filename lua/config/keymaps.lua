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

-- Fast window navigation (your common case: hop between neo-tree and the buffer).
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Discoverable window menu under <leader>w. These are real mappings (not a raw
-- <C-w> passthrough), so which-key pops up and lists them. The native <C-w>
-- prefix still works for anything not listed here.
local window_cmds = {
	h = { "<C-w>h", "Go to left window" },
	j = { "<C-w>j", "Go to lower window" },
	k = { "<C-w>k", "Go to upper window" },
	l = { "<C-w>l", "Go to right window" },
	w = { "<C-w>w", "Cycle to next window" },
	s = { "<C-w>s", "Split below" },
	v = { "<C-w>v", "Split right" },
	q = { "<C-w>q", "Close window" },
	o = { "<C-w>o", "Close other windows" },
	["="] = { "<C-w>=", "Equalize window sizes" },
}
for lhs, spec in pairs(window_cmds) do
	vim.keymap.set("n", "<leader>w" .. lhs, spec[1], { silent = true, desc = spec[2] })
end
