return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		image = {
			enabled = true, -- Explicitly enable the image viewer
			doc = {
				enabled = true, -- Enable inline image previews for Markdown/HTML
			},
		},
	},
}
