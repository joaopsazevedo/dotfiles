local M = {}

function M.setup()
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
    vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Show diagnostics in location list" })

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
            vim.keymap.set("n", "<leader>ho", vim.lsp.buf.hover,
                { buffer = ev.buf, desc = "Hover documentation" })
            vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "Signature help" })
            vim.keymap.set("n", "<leader>re", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename" })
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Code actions" })
            vim.keymap.set("n", "<leader>fo", vim.lsp.buf.format, { buffer = ev.buf, desc = "Format with LSP" })
        end,
    })
end

return M
