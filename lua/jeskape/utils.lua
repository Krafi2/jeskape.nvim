local M = {}

function M.invalid_table(err)
    local function throw()
        error(err)
    end

    local meta = {
        __index = throw,
        __newindex = throw,
        __tostring = throw,
    }

    return setmetatable({}, meta)
end

function M.print_error(message)
    vim.api.nvim_echo({ { message, "ErrorMsg" } }, true, {})
end

return M
