local utils = require "jeskape/utils"

--- @class Settings
local defaults = {
    mappings = {},
    timeout = vim.o.timeoutlen,
}

local mod = {
    settings = utils.invalid_table "Plugin is not set up",
}

local M = {}

function M.setup(settings)
    settings = vim.tbl_extend("force", defaults, settings or {})
    mod.settings = settings
end

-- @return Settings
function M.settings()
    return mod.settings
end

return M
