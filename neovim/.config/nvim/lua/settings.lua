vim.g.mapleader = " "
vim.g.have_nerd_font = true

local local_bin = vim.fs.normalize(vim.fn.expand("~/.local/bin"))
if vim.fn.isdirectory(local_bin) == 1 then
    vim.env.PATH = local_bin .. ":" .. vim.env.PATH
end

vim.opt.backup = false
vim.opt.swapfile = false

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.signcolumn = "yes"

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

vim.opt.mouse = "a"

vim.opt.wrap = true
vim.opt.breakindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.list = true
vim.opt.listchars = "tab:>.,trail:.,extends:#,nbsp:."

vim.opt.history = 1000
vim.opt.undolevels = 1000

vim.opt.wildignore = "*.swp,*.bak,*.pyc,*.class"

vim.opt.title = true

-- With no native clipboard (e.g. in the dev container), copy through OSC 52
-- but paste from what Neovim copied last: OSC 52 reads get no reply through
-- herdr. The "OSC 52" name also stops which-key from reading "+ on `"`.
local has_native_clipboard = vim.fn.has("mac") == 1
    or vim.fn.has("wsl") == 1
    or vim.env.DISPLAY ~= nil
    or vim.env.WAYLAND_DISPLAY ~= nil
    or vim.env.TMUX ~= nil
if not has_native_clipboard then
    local osc52 = require("vim.ui.clipboard.osc52")
    local copied = {}
    local function copy(reg)
        local send = osc52.copy(reg)
        return function(lines, regtype)
            copied[reg] = { lines, regtype }
            send(lines)
        end
    end
    local function paste(reg)
        return function()
            return copied[reg] or {}
        end
    end
    vim.g.clipboard = {
        name = "OSC 52",
        copy = { ["+"] = copy("+"), ["*"] = copy("*") },
        paste = { ["+"] = paste("+"), ["*"] = paste("*") },
    }
end

vim.opt.termguicolors = true
vim.opt.background = "dark"

vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

vim.keymap.set("n", "gn", ":bn<cr>")
vim.keymap.set("n", "gp", ":bp<cr>")

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { noremap = true })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { noremap = true })
vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { noremap = true })
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { noremap = true })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { noremap = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { noremap = true })

vim.api.nvim_create_autocmd("Filetype", {
    pattern = "ada",
    command = "setlocal ts=3 sw=3 sts=0 expandtab",
})
