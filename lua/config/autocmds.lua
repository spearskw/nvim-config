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

-- ── Binary files: don't let text rules rewrite them ──────────────────────
-- Read with 'binary' off, nvim treats a binary file as text: 'fixendofline'
-- appends a newline on write (an .ico grows by a byte and stops being a valid
-- icon) and 'fileencoding' conversion can rewrite bytes outright — nvim says
-- "[converted]" when it does. Opening is harmless; it's the :w / :wq / ZZ
-- afterwards that writes the mangled buffer back over the file.
--
-- snacks.image intercepts writes (BufWriteCmd) for the formats it renders —
-- png jpg gif bmp webp tiff avif heic icns pdf — so those were already safe.
-- .ico is not on its list, which is the one that bites here.
local binary_globs = {
	"*.ico",
	"*.icns",
	"*.png",
	"*.jpg",
	"*.jpeg",
	"*.gif",
	"*.bmp",
	"*.webp",
	"*.tif",
	"*.tiff",
	"*.avif",
	"*.heic",
	"*.tga",
	"*.psd",
	"*.jxl",
}

local binary_guard = vim.api.nvim_create_augroup("user_binary_guard", { clear = true })

-- 'binary' has to be set *before* the read, so the bytes land in the buffer
-- exactly as they are on disk and go back out the same way.
vim.api.nvim_create_autocmd("BufReadPre", {
	group = binary_guard,
	pattern = binary_globs,
	callback = function(ev)
		vim.bo[ev.buf].binary = true
		vim.bo[ev.buf].swapfile = false -- no .swp next to a file you can't edit meaningfully
		vim.bo[ev.buf].undofile = false -- and no undo history for 18 KB of PNG
	end,
})

-- Second line of defence: 'readonly' makes a reflexive :w fail with E45
-- instead of silently rewriting the file. Deliberately *not* 'nomodifiable' —
-- snacks.image swaps the buffer contents for its render placeholder and needs
-- to be able to write to the buffer. Set after the read, which resets it.
vim.api.nvim_create_autocmd("BufReadPost", {
	group = binary_guard,
	pattern = binary_globs,
	callback = function(ev)
		vim.bo[ev.buf].readonly = true
	end,
})

-- An image buffer is never really "edited": snacks.image renders the picture by
-- replacing the buffer's lines with a placeholder. snacks/image/buf.lua clears
-- 'modified' after doing that, but snacks/image/placement.lua (M:progress and
-- the error path) rewrites the lines and forgets to — so the buffer lands dirty
-- and shows [+]. That path only runs in a terminal that can actually draw the
-- image, which is why it shows up in the real terminal and not under a pty.
--
-- Upstream bug; fixed here rather than in the plugin so a snacks update can't
-- undo it. Two hooks that look right and aren't:
--   * BufReadPost never fires for these buffers at all — snacks claims images
--     with a BufReadCmd, so it owns the read and BufReadPre/Post are skipped.
--     (They do still fire for formats snacks ignores, like .ico — that's what
--     the 'binary' guard above rides on.)
--   * BufModifiedSet never fires for a programmatic buf_set_lines — verified,
--     not even with pattern "*".
-- BufWinEnter does fire, and nvim_buf_attach sees the render write whenever it
-- lands (it's on a timer, so a one-shot check would just be too early).
vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter" }, {
	group = binary_guard,
	pattern = binary_globs,
	callback = function(ev)
		local function undirty()
			if vim.api.nvim_buf_is_valid(ev.buf) and vim.bo[ev.buf].modified then
				vim.bo[ev.buf].modified = false
			end
		end
		vim.schedule(undirty) -- catch a render that already landed
		if vim.b[ev.buf].image_clean_attached then
			return
		end
		vim.b[ev.buf].image_clean_attached = true
		vim.api.nvim_buf_attach(ev.buf, false, {
			-- options can't be set from inside the callback, so defer
			on_lines = function()
				vim.schedule(undirty)
			end,
		})
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
