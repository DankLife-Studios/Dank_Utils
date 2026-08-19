-- Dank_Utils :: debug.lua  (shared)
-- Provides:
--   Dank.debug.enable = true/false   -- SERVER-SIDE ONLY per-resource switch
--   Dank.debug.get()                 -- returns the current resource's debug state
--   Dank.debug.print(message, level) -- 'info' | 'warning' | 'error'
--
-- Resource debug is intentionally separate from Dank_Utils internal debug:
--   * config/dankutils_manual.lua -> Debug controls ONLY Dank_Utils internal LogDebug output.
--   * Dank.debug.enable controls ONLY the resource that is using Dank_Utils.
--
-- Example in another resource's SERVER code:
--   Dank.debug.enable = Config.Debug
--
-- That one server-side assignment controls Dank.debug.print on BOTH the server
-- and client for that resource. Each resource gets its own replicated state key,
-- so one resource can no longer enable/disable another resource's debug output.

local print = print
local type = type
local tostring = tostring
local rawset = rawset
local IsDuplicityVersion = IsDuplicityVersion
local GetCurrentResourceName = GetCurrentResourceName
local GlobalState = GlobalState
local LogDebug = LogDebug or function() end

-- This is the resource runtime consuming Dank_Utils, not necessarily Dank_Utils itself.
-- Capturing it once guarantees the server and client use the exact same key and label.
local resourceName = GetCurrentResourceName()
local STATE_KEY = ('dankutils:debug:%s'):format(resourceName)
local serverEnabled = false

---@class DankDebug
---@field enable boolean
local debug = {}

---@return boolean
local function getClientState()
    return GlobalState[STATE_KEY] == true
end

---@param enabled boolean
local function publishServerState(enabled)
    -- GlobalState assignment is server-replicated automatically.
    -- A per-resource key prevents resources from overwriting each other.
    GlobalState[STATE_KEY] = enabled == true
end

-- Reset only this resource's replicated flag when its server runtime loads.
-- This prevents a stale true value from surviving a resource restart before
-- the resource reapplies `Dank.debug.enable = Config.Debug`.
if IsDuplicityVersion() then
    publishServerState(false)
end

setmetatable(debug, {
    __index = function(_, key)
        if key ~= 'enable' then return nil end

        if IsDuplicityVersion() then
            return serverEnabled
        end

        return getClientState()
    end,

    __newindex = function(t, key, value)
        if key ~= 'enable' then
            rawset(t, key, value)
            return
        end

        -- Client code cannot enable or disable resource debug. The server is
        -- the single source of truth for both server and client printing.
        if not IsDuplicityVersion() then
            LogDebug(('[debug] Ignored client write to Dank.debug.enable for %s'):format(resourceName))
            return
        end

        serverEnabled = value == true
        publishServerState(serverEnabled)
    end,
})

---@return boolean
local function isEnabled()
    if IsDuplicityVersion() then
        return serverEnabled
    end

    return getClientState()
end

local LEVELS = {
    info    = { tag = 'INFO',    color = '^5' },
    warning = { tag = 'WARNING', color = '^3' },
    error   = { tag = 'ERROR',   color = '^1' },
}

---@param level string|nil
---@return string
local function normalizeLevel(level)
    level = type(level) == 'string' and level:lower() or 'info'
    if level == 'warn' then return 'warning' end
    if not LEVELS[level] then return 'info' end
    return level
end

-- Dank.debug.get()
-- Returns the current resource's effective debug state on this side.
---@return boolean
debug.get = function()
    return isEnabled()
end

-- Dank.debug.print(message, level)
-- Prints only when THIS resource's server-side Dank.debug.enable is true.
---@param message any
---@param level? string
debug.print = function(message, level)
    if not isEnabled() then return end

    local lvl = LEVELS[normalizeLevel(level)]
    print(('^2[%s]^7 %s[%s]^7 %s'):format(
        resourceName,
        lvl.color,
        lvl.tag,
        tostring(message)
    ))
end

LogDebug(('[debug] module loaded for %s (resource debug=%s)'):format(
    resourceName,
    tostring(debug.enable)
))

return debug