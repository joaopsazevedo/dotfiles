-- LSP formatters
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.json,*.rs,*.lua",
    callback = function() vim.lsp.buf.format() end,
    group = vim.api.nvim_create_augroup("lsp_document_format", { clear = true })
})

-- CLI formatters
local formatter_util = require("formatter.util")
require("formatter").setup({
    filetype = {
        -- python = {
        --     function()
        --         return {
        --             exe = vim.fn.stdpath("data") .. "/mason/packages/black/venv/bin/black",
        --             args = {
        --                 "--stdin-filename",
        --                 formatter_util.escape_path(formatter_util.get_current_buffer_file_path()),
        --                 "--",
        --                 "-",
        --             },
        --             stdin = true,
        --         }
        --     end,
        -- },
        -- javascript = {
        --     function()
        --         return {
        --             exe = vim.fn.stdpath("data") .. "/mason/packages/prettier/node_modules/prettier/bin/prettier.cjs",
        --             args = {
        --                 "--stdin-filepath",
        --                 formatter_util.escape_path(formatter_util.get_current_buffer_file_path())
        --             },
        --             stdin = true,
        --             try_node_modules = true,
        --         }
        --     end,
        -- },
        -- typescript = {
        --     function()
        --         return {
        --             exe = vim.fn.stdpath("data") .. "/mason/packages/prettier/node_modules/prettier/bin/prettier.cjs",
        --             args = {
        --                 "--stdin-filepath",
        --                 formatter_util.escape_path(formatter_util.get_current_buffer_file_path()),
        --                 "--parser",
        --                 "typescript",
        --             },
        --             stdin = true,
        --             try_node_modules = true,
        --         }
        --     end,
        -- },
        -- yaml = {
        --     function()
        --         return {
        --             exe = vim.fn.stdpath("data") .. "/mason/packages/prettier/node_modules/prettier/bin/prettier.cjs",
        --             args = {
        --                 "--stdin-filepath",
        --                 formatter_util.escape_path(formatter_util.get_current_buffer_file_path()),
        --                 "--parser",
        --                 "yaml",
        --             },
        --             stdin = true,
        --             try_node_modules = true,
        --         }
        --     end,
        -- },
        -- Use the special "*" filetype for defining formatter configurations on
        -- any filetype
        ["*"] = {
            -- "formatter.filetypes.any" defines default configurations for any
            -- filetype
            require("formatter.filetypes.any").remove_trailing_whitespace,
        },
    },
})
vim.api.nvim_create_augroup("__formatter__", { clear = true })
-- vim.api.nvim_create_autocmd("BufWritePre", {
--     group = "__formatter__",
--     pattern = "*.py",
--     command = ":FormatWrite",
-- })
vim.api.nvim_create_autocmd("BufWritePost", {
    group = "__formatter__",
    pattern = "*",
    command = ":FormatWrite",
})
