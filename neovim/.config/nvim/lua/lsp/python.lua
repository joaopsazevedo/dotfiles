local shared = require("lsp.shared")

local M = {}

local mypy_diagnostics_ns = vim.api.nvim_create_namespace("python_mypy")
local mypy_run_seq = {}

local function python_project_root(filename)
    local marker = vim.fs.find({ "pyproject.toml", "mypy.ini", "setup.cfg", ".git" }, {
        path = vim.fs.dirname(filename),
        upward = true,
    })[1]

    if marker then
        return vim.fs.dirname(marker)
    end

    return vim.fs.dirname(filename)
end

local function normalize_mypy_path(path, cwd)
    if vim.startswith(path, "/") or path:match("^%a:[/\\]") then
        return vim.fs.normalize(path)
    end
    return vim.fs.normalize(vim.fs.joinpath(cwd, path))
end

local function parse_mypy_line(line, filename, cwd)
    local path, lnum, col, kind, message = line:match("^(.+):(%d+):(%d+): (%a+): (.+)$")
    if not path then
        path, lnum, kind, message = line:match("^(.+):(%d+): (%a+): (.+)$")
        col = "1"
    end
    if not path then
        return nil
    end

    local normalized_path = normalize_mypy_path(path, cwd)
    if normalized_path ~= vim.fs.normalize(filename) then
        return nil
    end

    local severity = vim.diagnostic.severity.WARN
    if kind == "error" then
        severity = vim.diagnostic.severity.ERROR
    end

    return {
        lnum = math.max(tonumber(lnum) - 1, 0),
        col = math.max(tonumber(col) - 1, 0),
        severity = severity,
        source = "mypy",
        kind = kind,
        message = message,
    }
end

local function is_mypy_header_or_diagnostic_line(line)
    if line:match("^.+:%s+note:%s+") then
        return true
    end
    if line:match("^.+:%d+:%d+:%s+%a+:%s+") then
        return true
    end
    if line:match("^.+:%d+:%s+%a+:%s+") then
        return true
    end
    return false
end

local function is_mypy_source_excerpt_line(line)
    if line:match("^%s*[%^~]+%s*$") then
        return true
    end
    if line:match("^%s+$") then
        return true
    end
    if line:match("^%s+") and not line:match("^%s*%(") then
        return true
    end
    return false
end

local function mypy_executable_for_root(cwd)
    local candidates = { vim.fs.joinpath(cwd, ".venv", "bin", "mypy"), "mypy" }
    if shared.is_windows then
        candidates = {
            vim.fs.joinpath(cwd, ".venv", "Scripts", "mypy.exe"),
            vim.fs.joinpath(cwd, ".venv", "Scripts", "mypy"),
            "mypy",
        }
    end

    return shared.resolve_executable(candidates)
end

local function run_mypy(bufnr)
    local seq = (mypy_run_seq[bufnr] or 0) + 1
    mypy_run_seq[bufnr] = seq

    local filename = vim.api.nvim_buf_get_name(bufnr)
    if filename == "" then
        return
    end

    local cwd = python_project_root(filename)
    local mypy_exe = mypy_executable_for_root(cwd)
    if not mypy_exe then
        vim.diagnostic.reset(mypy_diagnostics_ns, bufnr)
        return
    end

    local target = filename
    local cwd_prefix = cwd .. "/"
    if vim.startswith(filename, cwd_prefix) then
        target = filename:sub(#cwd_prefix + 1)
    end

    local cmd = {
        mypy_exe,
        "--show-column-numbers",
        "--show-error-codes",
        "--hide-error-context",
        "--no-pretty",
        "--no-color-output",
        "--no-error-summary",
        target,
    }

    vim.system(cmd, { text = true, cwd = cwd }, function(result)
        local diagnostics = {}
        local output = table.concat({ result.stdout or "", result.stderr or "" }, "\n")
        local last_diagnostic = nil
        local last_primary_diagnostic = nil

        for line in output:gmatch("[^\r\n]+") do
            local diagnostic = parse_mypy_line(line, filename, cwd)
            if diagnostic then
                if diagnostic.kind == "note" and last_primary_diagnostic then
                    last_primary_diagnostic.message = last_primary_diagnostic.message .. " Note: " .. diagnostic.message
                    last_diagnostic = last_primary_diagnostic
                else
                    diagnostic.kind = nil
                    table.insert(diagnostics, diagnostic)
                    last_diagnostic = diagnostic
                    last_primary_diagnostic = diagnostic
                end
            elseif last_diagnostic
                and not is_mypy_header_or_diagnostic_line(line)
                and not is_mypy_source_excerpt_line(line) then
                last_diagnostic.message = last_diagnostic.message .. " " .. vim.trim(line)
            else
                last_diagnostic = nil
                last_primary_diagnostic = nil
            end
        end

        vim.schedule(function()
            if mypy_run_seq[bufnr] ~= seq then
                return
            end
            if not vim.api.nvim_buf_is_valid(bufnr) then
                return
            end
            vim.diagnostic.set(mypy_diagnostics_ns, bufnr, diagnostics)
        end)
    end)
end

function M.setup()
    local ruff_exe = shared.resolve_executable({ "ruff" })
    if ruff_exe then
        vim.lsp.config("ruff", {
            cmd = { ruff_exe, "server" },
        })
        vim.lsp.enable("ruff")
    elseif vim.fn.executable("ruff-lsp") == 1 then
        pcall(vim.lsp.enable, "ruff_lsp")
    end

    local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
    local basedpyright_exe = shared.resolve_executable({
        "basedpyright-langserver",
        mason_bin .. "/basedpyright-langserver",
    })
    if basedpyright_exe then
        vim.lsp.config("basedpyright", {
            cmd = { basedpyright_exe, "--stdio" },
            settings = {
                basedpyright = {
                    analysis = {
                        typeCheckingMode = "strict",
                    },
                },
                python = {
                    analysis = {
                        typeCheckingMode = "strict",
                    },
                },
            },
        })
        vim.lsp.enable("basedpyright")
    end

    local python_mypy_group = vim.api.nvim_create_augroup("python_mypy_check", { clear = true })
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
        pattern = "*.py",
        group = python_mypy_group,
        callback = function(args)
            run_mypy(args.buf)
        end,
    })

    vim.api.nvim_create_autocmd("InsertEnter", {
        pattern = "*.py",
        group = python_mypy_group,
        callback = function(args)
            mypy_run_seq[args.buf] = (mypy_run_seq[args.buf] or 0) + 1
            vim.diagnostic.reset(mypy_diagnostics_ns, args.buf)
        end,
    })

    vim.api.nvim_create_autocmd("InsertLeave", {
        pattern = "*.py",
        group = python_mypy_group,
        callback = function(args)
            run_mypy(args.buf)
        end,
    })
end

return M
