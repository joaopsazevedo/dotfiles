require("mason").setup()

-- Setup language servers
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
    settings = get_als_settings()
}
-- Bash
lspconfig.bashls.setup {}
-- JavaScript/TypeScript
lspconfig.eslint.setup {}
-- Json
lspconfig.jsonls.setup {}
-- Lua
lspconfig.lua_ls.setup {}
-- Python
lspconfig.pyright.setup {}
-- Rust
lspconfig.rust_analyzer.setup {}

vim.diagnostic.config({
    virtual_text = true
})

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', '<space>gt', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<space>ho', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<space>sh', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>fr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<space>re', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<space>co', vim.lsp.buf.completion, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    end,
})
