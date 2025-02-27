require("mason").setup()
require("mason-lspconfig").setup {
    ensure_installed = {
        "lua_ls",
        "pyright",
        "rust_analyzer",
    },
    automatic_installation = false
}

-- Setup language servers
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = false

-- Ada
local lspconfig = require('lspconfig')
local lspconfig_configs = require('lspconfig.configs')
local get_als_settings = function()
    -- First, check for .als.json
    local als_settings = io.open('.als.json', 'r')
    if als_settings then
        local content = als_settings:read("*a")
        io.close(als_settings)
        return {
            ada = vim.json.decode(content)
        }
    end

    -- If .als.json doesn't exist, search for GPR files
    local cwd = vim.loop.cwd()
    local gpr_files = vim.fn.globpath(cwd, "*.gpr", false, true)

    -- If no GPR files were found, search for GPR files in the 'gnat' directory
    if vim.tbl_isempty(gpr_files) then
        gpr_files = vim.fn.globpath(cwd .. "/gnat", "*.gpr", false, true)
    end

    -- If a GPR files were found, use the first one
    if not vim.tbl_isempty(gpr_files) then
        return {
            ada = {
                projectFile = gpr_files[1], -- Use the first .gpr file found
                scenarioVariables = {}
            }
        }
    end

    -- If no .als.json or GPR file was found, return an empty settings object
    return {}
end;
local ada_language_server = 'ada_language_server'
if vim.fn.has 'win32' == 1 then
    ada_language_server = 'ada_language_server.exe'
end
lspconfig_configs.ada_ls = {
    default_config = {
        cmd = { ada_language_server },
        filetypes = { 'ada' },
        root_dir = function()
            return vim.loop.cwd()
        end
    }
}
lspconfig.ada_ls.setup {
    settings = get_als_settings(),
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
lspconfig.ts_ls.setup {}

-- Go
--lspconfig.gopls.setup {}

-- yaml
lspconfig.yamlls.setup {}

vim.diagnostic.config({
    virtual_text = true
})

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Show diagnostics in location list" })

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Jump to the declaration" })
        vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions,
            { buffer = ev.buf, desc = "Jump to the definition" })
        vim.keymap.set('n', 'gt', require('telescope.builtin').lsp_type_definitions,
            { buffer = ev.buf, desc = "Jump to the type definition" })
        vim.keymap.set('n', 'gi', require('telescope.builtin').lsp_implementations,
            { buffer = ev.buf, desc = "List all the implementations" })
        vim.keymap.set('n', '<leader>ho', vim.lsp.buf.hover, { buffer = ev.buf, desc = "Lists all the implementations" })
        vim.keymap.set('n', '<leader>sh', vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "Signature help" })
        vim.keymap.set('n', '<leader>fr', require('telescope.builtin').lsp_references,
            { buffer = ev.buf, desc = "Lists all references" })
        vim.keymap.set('n', '<leader>re', vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename" })
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Code actions" })
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
