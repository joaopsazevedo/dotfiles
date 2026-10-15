local M = {}

function M.setup()
    require("mason").setup({
        PATH = "append",
    })
    require("mason-lspconfig").setup({
        ensure_installed = {
            "lua_ls",
        },
    })

    vim.lsp.config("ada_ls", {
        root_dir = function(bufnr, on_dir)
            on_dir(vim.fs.root(bufnr, function(name)
                return vim.list_contains({ ".als.json", "alire.toml", "gnat", "Makefile", ".git" }, name)
                    or name:match("%.gpr$") ~= nil
                    or name:match("%.adc$") ~= nil
            end))
        end,
        cmd = function(dispatchers, config)
            -- ALS loads .als.json from its process working directory.
            return vim.lsp.rpc.start({ "ada_language_server" }, dispatchers, { cwd = config.root_dir })
        end,
        before_init = function(params, config)
            local root = config.root_dir or vim.uv.cwd()
            -- ALS handles explicit settings and projects in the root directory itself.
            if vim.uv.fs_stat(root .. "/.als.json") or #vim.fn.globpath(root, "*.gpr", false, true) > 0 then
                return
            end

            local projects = vim.fn.globpath(root .. "/gnat", "*.gpr", false, true)
            if #projects == 1 then
                params.initializationOptions = { ada = { projectFile = projects[1] } }
            end
        end,
    })
    vim.lsp.enable("ada_ls")

    vim.lsp.enable("rust_analyzer")
end

return M
