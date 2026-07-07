-- JetBrains / VS Code .http client for Neovim.
-- Reads http-client.env.json + http-client.private.env.json and {{variables}}.
--
-- Keys (prefix <leader>R), active in .http buffers once opened:
--   <leader>Rs  send request under cursor   (also <CR> in an .http buffer)
--   <leader>Ra  send all requests
--   <leader>Re  select environment
--   <leader>Rt  toggle headers/body view    <leader>Rn / <leader>Rp  next/prev request
--   <leader>Ro  open kulala UI              <leader>Rq  close UI
--   <leader>Rc  copy request as cURL        <leader>Rr  replay last request
--   <leader>Rb  open scratchpad
return {
	"mistweaverco/kulala.nvim",
	ft = { "http", "rest" },
	opts = {
		-- Let kulala create its own keymaps (this is the fix — was false before,
		-- so nothing was bound and requests couldn't be sent).
		global_keymaps = true,
		global_keymaps_prefix = "<leader>R",
		-- Your env files (http-client.env.json / .private.env.json) define "dev".
		-- Without this, {{place_url}} / {{ibauth}} never resolve.
		default_env = "dev",
		-- treesitter.enable defaults to true: kulala fetches + builds its own
		-- kulala_http parser via the tree-sitter CLI. No workspace pollution.
	},
}
