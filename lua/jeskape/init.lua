local config = require "jeskape/config"
local utils = require "jeskape/utils"

local mod = {
    -- The possible keys that are mapped
    state = nil,
    -- when the last key was pressed
    last = nil,
    -- how many keys have been pressed, so we can delete the characters that
    -- we've written
    keys = nil,
} or {}

local M = {}

-- Reset the module's state to start a fresh mapping
local function reset_state()
    mod.state = config.settings().mappings
    mod.keys = 0
    mod.last = vim.fn.reltime()
end

--- @return string
-- Finish the text returned by a mapping
local function finish_mapping(output)
    -- Remove the characters that we've written
    return string.rep("<C-h>", mod.keys) .. output
end

-- This function runs on every keypress registered in a mapping.
-- This is where most of the plugin's logic is.
local function _key_pressed(key)
    mod.last = mod.last or vim.fn.reltime()
    local now = vim.fn.reltime()
    -- reltime is in seconds but we need miliseconds
    local delta = vim.fn.reltimefloat(vim.fn.reltime(mod.last, now)) * 1000
    local timeout = config.settings().timeout

    mod.last = now
    mod.keys = mod.keys + 1

    -- Start a new key chain
    if delta > timeout then
        reset_state()
    end

    local state = mod.state[key]
    local type = type(state)

    -- There are no bindings for this combination
    if type == "nil" then
        reset_state()
        return key
        -- There are more branches
    elseif type == "table" then
        mod.state = state
        return key
        -- The combination maps to a string
    elseif type == "string" then
        return finish_mapping(state)
        -- The combination maps to a function
    elseif type == "function" then
        -- Try to gracefully handle errors
        local ok, res = pcall(state)
        if not ok then
            utils.print_error(res)
        end

        res = ok and res or ""
        return finish_mapping(state())
    end
end

-- This function runs on every keypress registered in a mapping
function M.key_pressed(key)
    local keys = _key_pressed(key)
    keys = vim.api.nvim_replace_termcodes(keys, true, true, true)
    return keys
end

-- Create mappings for configured bindings
local function create_mappings()
    local mappings = config.settings().mappings
    for key, _ in pairs(utils.all_keys(mappings)) do
        vim.api.nvim_set_keymap(
            "i",
            key,
            ([[luaeval('require("jeskape").key_pressed("%s")')]]):format(key),
            { expr = true, silent = true, noremap = true }
        )
    end
end

function M.setup(settings)
    config.setup(settings)
    reset_state()
    create_mappings()
end

return M
