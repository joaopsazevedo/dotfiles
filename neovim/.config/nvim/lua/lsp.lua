require("mason").setup()

-- Setup language servers
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = false
-- Ada
local lspconfig = require('lspconfig')
local get_als_settings = function()
    local als_settings = io.open('.als-settings.json', 'r');
    if als_settings then
        local content = als_settings:read("*a")
        io.close(als_settings)
        return {
            ada = vim.json.decode(content)
        }
    end
    return {}
end;
lspconfig.als.setup {
    settings = get_als_settings(),
    root_dir = require("lspconfig.util").root_pattern('.als-settings.json', 'Makefile', '.git', '*.gpr')
}
-- Bash
lspconfig.bashls.setup {}
-- JavaScript/TypeScript
lspconfig.eslint.setup {}
-- Json
lspconfig.jsonls.setup {}
-- Lua
lspconfig.lua_ls.setup {
    capabilities = capabilities
}
-- Python
lspconfig.pyright.setup {}
-- Rust
lspconfig.rust_analyzer.setup {}
-- TypeScript
lspconfig.tsserver.setup {}

vim.diagnostic.config({
    virtual_text = true
})

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<leader>ho', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<leader>sh', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<leader>fr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>re', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    end,
})

-- Autocomplete
local cmp = require("cmp")
cmp.setup {
    completion = {
        completeopt = 'menu,menuone,noinsert'
    },
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-k>'] = cmp.mapping.select_prev_item(),
        ['<C-j>'] = cmp.mapping.select_next_item(),
        ['<CR>'] = cmp.mapping({
            i = function(fallback)
                if cmp.visible() then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
                else
                    fallback()
                end
            end,
            c = function(fallback)
                if cmp.visible() then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
                else
                    fallback()
                end
            end
        }),
        ['<TAB>'] = cmp.mapping({
            i = function(fallback)
                if cmp.visible() then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
                else
                    fallback()
                end
            end
        }) }),
    sources = {
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
    }
}
cmp.setup.cmdline(':', {
    completion = {
        autocomplete = false,
    },
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        {
            name = 'cmdline',
            option = {
                ignore_cmds = { 'Man', '!' },
            }
        }
    })
})
