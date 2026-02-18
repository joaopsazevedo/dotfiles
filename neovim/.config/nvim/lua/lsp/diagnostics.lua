local M = {}

local function lsp_diagnostic_namespaces(bufnr)
    local namespaces = {}
    local seen = {}

    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        local push_ns = vim.lsp.diagnostic.get_namespace(client.id, false)
        if not seen[push_ns] then
            seen[push_ns] = true
            table.insert(namespaces, push_ns)
        end

        local pull_ns = vim.lsp.diagnostic.get_namespace(client.id, true)
        if not seen[pull_ns] then
            seen[pull_ns] = true
            table.insert(namespaces, pull_ns)
        end
    end

    return namespaces
end

function M.setup()
    vim.diagnostic.config({
        virtual_text = true,
        update_in_insert = false,
        float = {
            source = "always",
        },
    })

    local group = vim.api.nvim_create_augroup("lsp_diagnostics_insert_mode", { clear = true })
    vim.api.nvim_create_autocmd("InsertEnter", {
        group = group,
        callback = function(args)
            for _, namespace in ipairs(lsp_diagnostic_namespaces(args.buf)) do
                vim.diagnostic.hide(namespace, args.buf)
            end
        end,
    })

    vim.api.nvim_create_autocmd("InsertLeave", {
        group = group,
        callback = function(args)
            for _, namespace in ipairs(lsp_diagnostic_namespaces(args.buf)) do
                vim.diagnostic.show(namespace, args.buf)
            end
        end,
    })
end

return M
