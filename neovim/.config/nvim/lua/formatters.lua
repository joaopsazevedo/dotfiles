-- LSP formatters

local function has_lsp_formatter(bufnr, filter)
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if client:supports_method("textDocument/formatting") and (not filter or filter(client)) then
            return true
        end
    end
    return false
end

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.json,*.rs,*.lua,*.py",
    callback = function(args)
        local bufnr = args.buf
        if vim.b[args.buf].skip_autoformat_once then
            return
        end

        if vim.bo[bufnr].filetype == "python" then
            local ruff_filter = function(client)
                return client.name == "ruff" or client.name == "ruff_lsp"
            end

            if not has_lsp_formatter(bufnr, ruff_filter) then
                return
            end

            vim.lsp.buf.format({
                bufnr = bufnr,
                filter = ruff_filter,
            })
            return
        end

        if not has_lsp_formatter(bufnr) then
            return
        end

        vim.lsp.buf.format({ bufnr = bufnr })
    end,
    group = vim.api.nvim_create_augroup("lsp_document_format", { clear = true })
})

-- Global trailing whitespace cleanup

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function(args)
        if vim.b[args.buf].skip_autoformat_once then
            return
        end
        local view = vim.fn.winsaveview()
        vim.cmd([[keeppatterns silent! %s/\s\+$//e]])
        vim.fn.winrestview(view)
    end,
    group = vim.api.nvim_create_augroup("trim_trailing_whitespace", { clear = true })
})

-- Write to disk without applying any formatting

vim.api.nvim_create_user_command("WriteNoFormat", function(opts)
    local buf = vim.api.nvim_get_current_buf()
    vim.b[buf].skip_autoformat_once = true

    local write_cmd = "write" .. (opts.bang and "!" or "")
    if opts.args ~= "" then
        write_cmd = write_cmd .. " " .. opts.args
    end

    local ok, err = pcall(vim.cmd, write_cmd)
    vim.b[buf].skip_autoformat_once = false
    if not ok then
        error(err)
    end
end, {
    bang = true,
    nargs = "?",
    complete = "file",
    desc = "Write current buffer once without auto-formatting",
})

vim.api.nvim_create_user_command("W", function(opts)
    local cmd = "WriteNoFormat" .. (opts.bang and "!" or "")
    if opts.args ~= "" then
        cmd = cmd .. " " .. opts.args
    end
    vim.cmd(cmd)
end, {
    bang = true,
    nargs = "?",
    complete = "file",
    desc = "Alias for WriteNoFormat",
})
