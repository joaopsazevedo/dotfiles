local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

local plugins = {
    { "folke/neodev.nvim",                opts = {} },
    { "catppuccin/nvim",                  name = "catppuccin", priority = 1000 },
    { 'nvim-lualine/lualine.nvim' },
    { 'nvim-tree/nvim-web-devicons',      lazy = true },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "neovim/nvim-lspconfig" },
    {
        'junegunn/fzf.vim',
        dependencies = { 'junegunn/fzf', build = ':call fzf#install()' }
    },
    { 'mhartington/formatter.nvim' }
}

require("lazy").setup(plugins)
