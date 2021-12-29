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
-- the `recurse` option is specified and no mapping could be found, try to
-- recursively match the key.
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
            return nil
        end
        -- There are more branches
    elseif type == "table" then
        mod.state = state
        return nil
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

-- This function runs on every keypress and is responsible for hadling
-- mappings.
function M.key_pressed()
    local key = vim.v.char

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
    -- If `resolve_key` returns nil, we leave v:char alone and let the key be
    -- inserted as is
    if keys then
        vim.v.char = ""
        keys = vim.api.nvim_replace_termcodes(keys, true, true, true)
        -- We can't use v:char because
        vim.api.nvim_feedkeys(keys, "n", true)
    end
end

-- Create mappings for configured bindings
local function create_mappings()
    vim.cmd [[augroup Jeskape
    autocmd!
    autocmd InsertCharPre * lua require("jeskape").key_pressed()
    augroup END]]
end

function M.setup(settings)
    config.setup(settings)
    reset_state()
    create_mappings()
end

return M
