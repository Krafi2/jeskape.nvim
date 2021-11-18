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

-- Recursively collects all keys use in a table
function M.all_keys(table)
    local result = {}
    local function _all_keys(_t)
        for key, value in pairs(_t) do
            result[key] = true
            if type(value) == "table" then
                _all_keys(value)
            end
        end
    end
    _all_keys(table)
    return result
end

function M.print_error(message)
    vim.api.nvim_echo({ { message, "ErrorMsg" } }, true, {})
end

return M
