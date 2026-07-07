vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.wrap = false

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- ── Search ──────────────────────────────────────────────────────────────
vim.opt.ignorecase = true -- case-insensitive search…
vim.opt.smartcase = true -- …unless the query has a capital letter
vim.opt.inccommand = "nosplit" -- live preview of :s/:substitute as you type

-- ── Reading / navigation ────────────────────────────────────────────────
vim.opt.number = true -- absolute number on the cursor line
vim.opt.relativenumber = true -- relative elsewhere → count-based motions (7j)
vim.opt.scrolloff = 8 -- keep 8 lines of context above/below the cursor
vim.opt.sidescrolloff = 8 -- same horizontally (wrap is off)
vim.opt.signcolumn = "yes" -- always reserve it → no text jitter when LSP attaches

-- ── Windows / editing QoL ───────────────────────────────────────────────
vim.opt.splitright = true
vim.opt.splitbelow = true -- pairs with splitright
vim.opt.confirm = true -- ask to save instead of erroring on :q with changes
vim.opt.undofile = true -- persistent undo (stored in ~/.local/state/nvim, not your repo)
vim.opt.updatetime = 250 -- snappier CursorHold (diagnostic floats, etc.)

-- ── Floating windows (nvim 0.11+) ─────────────────────────────────────────
vim.opt.winborder = "rounded" -- rounded borders on hover/rename — matches the diagnostic float
