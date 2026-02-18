local M = {}

M.uv = vim.uv or vim.loop
M.is_windows = vim.fn.has("win32") == 1

function M.resolve_executable(candidates)
    for _, candidate in ipairs(candidates) do
        if candidate:find("[/\\]") then
            if vim.fn.executable(candidate) == 1 then
                return candidate
            end
        else
            local path = vim.fn.exepath(candidate)
            if path ~= "" then
                return path
            end
        end
    end
    return nil
end

return M
