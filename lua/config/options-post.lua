vim.keymap.set("n", "<leader>t", function()
	vim.treesitter.start()
end, { desc = "start treesitter" })
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


vim.api.nvim_create_user_command('DiffOrig', function()
  vim.cmd('vert new')
  vim.opt.buftype = 'nofile'
  vim.cmd('read ++edit #')
  vim.cmd('0d_')
  vim.cmd('diffthis')
  vim.cmd('wincmd p')
  vim.cmd('diffthis')
end, {})

