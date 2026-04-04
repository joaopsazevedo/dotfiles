local flavour = "mocha"

require("catppuccin").setup({
    flavour = flavour,
    background = {
        dark = flavour,
    },
    transparent_background = true,
    term_colors = true
})

require("lualine").setup({
    options = {
        theme = "catppuccin-" .. flavour,
        icons_enabled = true,
    },
})

vim.cmd.colorscheme("catppuccin")
