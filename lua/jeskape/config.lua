local utils = require "jeskape/utils"

--- @class Settings
local defaults = {
    mappings = {},
    timeout = vim.o.timeoutlen,
}

local mod = {
    settings = utils.invalid_table "Plugin is not set up",
}

-- Normalize the maps into a tree-like structure
local function parse_maps(maps)
    local function _parse_map(key, map, result)
        local parent
        for i = 1, #key do
            local c = key:sub(i, i)
            parent = result
            if not result[c] then
                result[c] = {}
            end
            result = result[c]
        end

        if type(map) == "table" then
            for key, map in pairs(map) do
                _parse_map(key, map, result)
            end
        else
            local key = key:sub(#key, #key)
            parent[key] = map
        end
    end

    local result = {}
    for key, map in pairs(maps) do
        _parse_map(key, map, result)
    end
    return result
end

local M = {}

function M.setup(settings)
    settings.mappings = parse_maps(settings.mappings)
    settings = vim.tbl_extend("force", defaults, settings or {})
    mod.settings = settings
end

-- @return Settings
function M.settings()
    return mod.settings
end

return M
