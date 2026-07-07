-- ============================================================================
-- On-demand LSP. Nothing starts at nvim launch.
--
--   <leader>l  toggle the LSP for the CURRENT buffer's filetype (on/off)
--   <leader>L  stop all running LSP clients
--
-- Servers are installed centrally via Mason (~/.local/share/nvim/mason) so
-- nothing ever lands in your project folders. nvim-lspconfig only *provides*
-- the server definitions; it never auto-starts anything.
-- ============================================================================

local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

-- filetype -> nvim-lspconfig server name
local servers = {
	zig = "zls",
	go = "gopls",
	python = "basedpyright",
	javascript = "ts_ls",
	javascriptreact = "ts_ls",
	typescript = "ts_ls",
	typescriptreact = "ts_ls",
	html = "html",
	css = "cssls",
	scss = "cssls",
	less = "cssls",
	java = "jdtls",
}

-- Track which servers we've already enabled this session.
local enabled = {}

-- jdtls needs an explicit, per-project data dir so multiple Java projects
-- don't clobber each other's workspace — and so nothing is written into the
-- project itself. Everything lives under ~/.cache/nvim.
local function configure_jdtls()
	local root = vim.fs.root(0, { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "settings.gradle" })
		or vim.fn.getcwd()
	local project = vim.fn.fnamemodify(root, ":p:h:t")
	local data_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. project
	vim.lsp.config("jdtls", {
		cmd = { mason_bin .. "/jdtls", "-data", data_dir },
		root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "settings.gradle" },
	})
end

local function toggle_lsp()
	local ft = vim.bo.filetype
	local server = servers[ft]
	if not server then
		vim.notify("No LSP configured for filetype: " .. (ft == "" and "<none>" or ft), vim.log.levels.WARN)
		return
	end

	if enabled[server] then
		-- Turn it off: detach + stop all clients of this name.
		vim.lsp.enable(server, false)
		for _, client in ipairs(vim.lsp.get_clients({ name = server })) do
			client:stop(true)
		end
		enabled[server] = nil
		vim.notify("LSP off: " .. server, vim.log.levels.INFO)
		return
	end

	if server == "jdtls" then
		configure_jdtls()
	end

	-- vim.lsp.enable() attaches to this buffer (and future matching buffers).
	vim.lsp.enable(server)
	enabled[server] = true
	vim.notify("LSP on: " .. server, vim.log.levels.INFO)
end

local function stop_all()
	for _, client in ipairs(vim.lsp.get_clients()) do
		client:stop(true)
	end
	enabled = {}
	vim.notify("Stopped all LSP clients", vim.log.levels.INFO)
end

local function on_attach(ev)
	local buf = ev.buf
	local map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
	end

	local ok_tb, tb = pcall(require, "telescope.builtin")
	if ok_tb then
		map("n", "gd", tb.lsp_definitions, "Go to definition")
		map("n", "gr", tb.lsp_references, "References")
		map("n", "gi", tb.lsp_implementations, "Implementations")
		map("n", "gy", tb.lsp_type_definitions, "Type definition")
		map("n", "<leader>fs", tb.lsp_document_symbols, "Document symbols")
		map("n", "<leader>fS", tb.lsp_dynamic_workspace_symbols, "Workspace symbols")
		map("n", "<leader>fd", tb.diagnostics, "Diagnostics (all buffers)")
	else
		map("n", "gd", vim.lsp.buf.definition, "Go to definition")
		map("n", "gr", vim.lsp.buf.references, "References")
	end

	-- K (hover), grn (rename), gra (code action), <C-s> (signature) are nvim
	-- 0.11+ defaults; add the couple that aren't and a diagnostics jump.
	map("n", "<leader>e", vim.diagnostic.open_float, "Line diagnostics")
	map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
	map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
	map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
	map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
end

return {
	-- Mason: centralized installer. Loads only when you run :Mason.
	{
		"williamboman/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall" },
		opts = {},
	},

	-- nvim-lspconfig: provides server definitions for vim.lsp.enable().
	-- Loads on first <leader>l press; nothing runs before that.
	{
		"neovim/nvim-lspconfig",
		keys = {
			{ "<leader>l", toggle_lsp, desc = "Toggle LSP for this filetype" },
			{ "<leader>L", stop_all, desc = "Stop all LSP clients" },
		},
		config = function()
			-- Make Mason-installed servers resolvable by nvim-lspconfig's default cmds.
			vim.env.PATH = mason_bin .. ":" .. vim.env.PATH

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
				callback = on_attach,
			})

			-- Readable but quiet: signs + underline, virtual text only for the current line's worst.
			vim.diagnostic.config({
				virtual_text = false,
				underline = true,
				signs = true,
				severity_sort = true,
				float = { border = "rounded", source = true },
			})
		end,
	},
}
