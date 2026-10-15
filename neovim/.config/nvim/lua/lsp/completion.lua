local M = {}

function M.setup()
    vim.o.autocomplete = false
    vim.o.complete = ".^5,w^5,b^5,u^5,o"
    vim.o.completeopt = "menuone,noselect,popup,fuzzy"
    vim.o.pumborder = "rounded"

    local group = vim.api.nvim_create_augroup("lsp_completion", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "InsertEnter" }, {
        group = group,
        callback = function(ev)
            -- Picker prompts and other special buffers handle their own input.
            vim.bo[ev.buf].autocomplete = vim.bo[ev.buf].buftype == ""
        end,
    })

    vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            if not client or not client:supports_method("textDocument/completion") then
                return
            end

            vim.lsp.completion.enable(true, client.id, ev.buf)
        end,
    })
end

return M
