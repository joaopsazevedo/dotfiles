local M = {}

function M.setup()
    vim.diagnostic.config({
        virtual_text = true,
        update_in_insert = false,
        float = {
            source = "if_many",
        },
    })

    local group = vim.api.nvim_create_augroup("lsp_diagnostics_insert_mode", { clear = true })
    vim.api.nvim_create_autocmd("InsertEnter", {
        group = group,
        callback = function(args)
            vim.diagnostic.hide(nil, args.buf)
        end,
    })

    vim.api.nvim_create_autocmd("InsertLeave", {
        group = group,
        callback = function(args)
            vim.diagnostic.show(nil, args.buf)
        end,
    })
end

return M
