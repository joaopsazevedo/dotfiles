require("lualine").setup({
    options = {
        theme = "catppuccin",
        icons_enabled = true,
    },
})
require("catppuccin").setup({
    flavour = "mocha",
    background = {
        dark = "mocha",
    },
    transparent_background = true,
    term_colors = true
})
vim.cmd.colorscheme("catppuccin")
