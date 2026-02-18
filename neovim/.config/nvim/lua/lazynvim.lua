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
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {},
    },
    { "catppuccin/nvim",                  name = "catppuccin", priority = 1000 },
    { 'nvim-lualine/lualine.nvim' },
    { 'nvim-tree/nvim-web-devicons',      lazy = true },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "neovim/nvim-lspconfig" },
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        enabled = true,
        ---@type snacks.Config
        opts = {
            indent = { enabled = true },
            input = { enabled = true },
            dashboard = { enabled = true },
            notifier = {
                enabled = true,
                timeout = 3000,
            },
            picker = {
                enabled = true,
            },
            scope = { enabled = true },
            scroll = { enabled = true },
            statuscolumn = { enabled = true },
        },
        keys = {
            { "<leader>fb", function() Snacks.picker.buffers() end,               desc = "Buffers" },
            { "<leader>ff", function() Snacks.picker.files() end,                 desc = "Find Files" },
            { "<leader>rg", function() Snacks.picker.grep() end,                  desc = "Grep" },
            { "<leader>fg", function() Snacks.picker.git_status() end,            desc = "Git Status" },
            { "gd",         function() Snacks.picker.lsp_definitions() end,       desc = "Goto Definition" },
            { "gD",         function() Snacks.picker.lsp_declarations() end,      desc = "Goto Declaration" },
            { "gr",         function() Snacks.picker.lsp_references() end,        nowait = true,                  desc = "References" },
            { "gi",         function() Snacks.picker.lsp_implementations() end,   desc = "Goto Implementation" },
            { "gt",         function() Snacks.picker.lsp_type_definitions() end,  desc = "Goto T[y]pe Definition" },
            { "<leader>ss", function() Snacks.picker.lsp_symbols() end,           desc = "LSP Symbols" },
            { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
            { "<leader>sr", function() Snacks.picker.resume() end,                desc = "Resume" },
        }
    },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/nvim-cmp' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-cmdline' },
    { 'hrsh7th/cmp-vsnip' },
    { 'hrsh7th/vim-vsnip' },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    },
    { 'NMAC427/guess-indent.nvim' },
    { 'stevearc/dressing.nvim' }
}

require("lazy").setup(plugins)

require('guess-indent').setup {}
