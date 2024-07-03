require("lualine").setup({
    options = {
        theme = "catppuccin",
        icons_enabled = true,
    },
})
require("catppuccin").setup({
    flavour = "macchiato",
    background = {
        dark = "macchiato",
    },
    transparent_background = true,
    term_colors = true
})
vim.cmd.colorscheme("catppuccin")
