local M = {}

function M.setup()
    local cmp = require("cmp")
    cmp.setup({
        completion = {
            completeopt = "menu,menuone,noinsert",
        },
        snippet = {
            expand = function(args)
                vim.fn["vsnip#anonymous"](args.body)
            end,
        },
        mapping = cmp.mapping.preset.insert({
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-k>"] = cmp.mapping.select_prev_item(),
            ["<C-j>"] = cmp.mapping.select_next_item(),
            ["<CR>"] = cmp.mapping({
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
                end,
            }),
            ["<TAB>"] = cmp.mapping({
                i = function(fallback)
                    if cmp.visible() then
                        cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
                    else
                        fallback()
                    end
                end,
            }),
        }),
        sources = {
            { name = "nvim_lsp" },
            { name = "vsnip" },
        },
    })

    cmp.setup.cmdline(":", {
        completion = {
            autocomplete = false,
        },
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = "path" }
        }, {
            {
                name = "cmdline",
                option = {
                    ignore_cmds = { "Man", "!" },
                }
            }
        })
    })
end

return M
