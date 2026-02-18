local shared = require("lsp.shared")

local M = {}

local function get_als_settings()
    local als_settings = io.open(".als.json", "r")
    if als_settings then
        local content = als_settings:read("*a")
        io.close(als_settings)
        return {
            ada = vim.json.decode(content)
        }
    end

    local cwd = shared.uv.cwd()
    local gpr_files = vim.fn.globpath(cwd, "*.gpr", false, true)

    if vim.tbl_isempty(gpr_files) then
        gpr_files = vim.fn.globpath(cwd .. "/gnat", "*.gpr", false, true)
    end

    if not vim.tbl_isempty(gpr_files) then
        return {
            ada = {
                projectFile = gpr_files[1],
                scenarioVariables = {}
            }
        }
    end

    return {}
end

function M.setup()
    require("mason").setup({
        PATH = "append",
    })
    require("mason-lspconfig").setup({
        ensure_installed = {
            "lua_ls",
        },
        automatic_installation = false,
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = false
    vim.lsp.config("*", { capabilities = capabilities })

    vim.lsp.enable("lua_ls")

    local lspconfig_configs = require("lspconfig.configs")
    local ada_language_server = "ada_language_server"
    if shared.is_windows then
        ada_language_server = "ada_language_server.exe"
    end

    lspconfig_configs.ada_ls = {
        default_config = {
            cmd = { ada_language_server },
            filetypes = { "ada" },
            root_dir = function()
                return shared.uv.cwd()
            end
        }
    }

    vim.lsp.enable("ada_ls")
    vim.lsp.config("ada_ls", {
        settings = get_als_settings(),
    })

    vim.lsp.enable("rust_analyzer")
end

return M
