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

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

vim.cmd("colorscheme tokyonight")


vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.keymap.set('n', '<leader>F', function()
      local view = vim.fn.winsaveview() -- Save your cursor position

      -- 1. Run the command
      -- '%' = whole file, '!' = run external command
      -- 'stylua -' tells stylua to read from standard input
      vim.cmd(":%!stylua -")

      -- 2. Error Handling
      if vim.v.shell_error ~= 0 then
        vim.cmd("undo") -- If stylua crashed, undo the replacement immediately
        print("Stylua formatting failed!")
      else
        vim.fn.winrestview(view) -- Restore cursor position
        print("Formatted with Stylua.")
      end
    end, { buffer = true, silent = true })
  end,
})


-- Warn before nvim slurps a huge file entirely into RAM. snacks.bigfile makes
-- large *text* usable (no parsing); this is the extra backstop for the
-- multi-GB binaries (.tar/.pbf) where opening in an editor is a mistake.
vim.api.nvim_create_autocmd("BufReadPre", {
  group = vim.api.nvim_create_augroup("user_hugefile_guard", { clear = true }),
  callback = function(ev)
    local ok, stat = pcall(vim.uv.fs_stat, ev.match)
    if not ok or not stat then return end
    local mb = stat.size / (1024 * 1024)
    if mb >= 1024 then
      vim.notify(
        string.format("This file is %.1f GB — nvim loads it fully into RAM. Prefer the shell (less/tar/osmium).", mb / 1024),
        vim.log.levels.WARN
      )
    elseif mb >= 200 then
      vim.notify(string.format("Large file: %.0f MB. bigfile mode active (no parsing).", mb), vim.log.levels.WARN)
    end
  end,
})

vim.api.nvim_create_user_command('DiffOrig', function()
  vim.cmd('vert new')
  vim.opt.buftype = 'nofile'
  vim.cmd('read ++edit #')
  vim.cmd('0d_')
  vim.cmd('diffthis')
  vim.cmd('wincmd p')
  vim.cmd('diffthis')
end, {})

