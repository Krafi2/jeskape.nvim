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
end

--- @return string
-- Finish the text returned by a mapping
local function finish_mapping(output)
    -- Remove the characters that we've written. We have to subtract 1,
    -- because the last key is a mapping and wont produce a character.
    local out = string.rep("<C-h>", mod.keys - 1) .. output
    reset_state()
    return out
end

-- @return string
-- @param key string
-- @param recurse bool
-- Try to resolve a key into a mapping, returning the string to be inserted. If
-- the `recurse` is specified, tries to recursively match the key if no mapping
-- could be found.
local function resolve_key(key, recurse)
    mod.keys = mod.keys + 1
    local state = mod.state[key]
    local type = type(state)

    -- There are no bindings for this combination
    if type == "nil" then
        reset_state()
        -- Try to start a new mapping
        if recurse then
            return resolve_key(key)
        else -- Don't recurse to avoid infinite recursion
            return key
        end
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
        -- In case the function returns nil
        res = res or ""
        return finish_mapping(res)
    end
end

-- This function runs on every keypress registered in a mapping. This is where
-- most of the plugin's logic is.
function M.key_pressed(key)
    mod.last = mod.last or vim.fn.reltime()
    local now = vim.fn.reltime()
    -- reltime is in seconds but we need miliseconds
    local delta = vim.fn.reltimefloat(vim.fn.reltime(mod.last, now)) * 1000
    local timeout = config.settings().timeout

    -- Start a new key chain
    if delta > timeout then
        reset_state()
    end

    mod.last = now

    local keys = resolve_key(key, true)
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
