-- Dank_Utils :: debug.lua  (shared)
-- Provides:
--   Dank.debug.enable = true/false   -- SERVER-SIDE ONLY master switch
--   Dank.debug.get()                 -- returns the current state
--   Dank.debug.print(message, level) -- 'info' | 'warning' | 'error'
--
-- Server-side only:
--   `Dank.debug.enable` can ONLY be set from the server. The server
--   replicates the flag to all clients through the `dankutils:debug`
--   state bag, so one server-side line enables BOTH server and client
--   debug prints. Client-side writes are ignored.

local print = print
local type = type
local tostring = tostring
local LogDebug = LogDebug or function() end

local STATE_KEY = 'dankutils:debug'

---@class DankDebug
---@field enable boolean
local debug = {}

setmetatable(debug, {
    __index = function(t, k)
        if k == 'enable' then
            if IsDuplicityVersion() then
                return rawget(t, 'enable') == true
            end
            -- Clients only ever see the server-replicated flag
            return GlobalState[STATE_KEY] == true
        end
        return nil
    end,
    __newindex = function(t, k, v)
        -- Server-side only: ignore writes from clients
        if k == 'enable' and not IsDuplicityVersion() then
            LogDebug('[debug] Dank.debug.enable ignored on client — server-side only')
            return
        end
        rawset(t, k, v)
        -- Writing the flag on the server pushes it to every client
        -- so a single server-side opt-in enables both sides.
        if k == 'enable' and IsDuplicityVersion() then
            GlobalState:set(STATE_KEY, v == true, true)
        end
    end
})

-- True when prints should fire on this side.
---@return boolean
local function isEnabled()
    if IsDuplicityVersion() then
        return debug.enable
    end
    return GlobalState[STATE_KEY] == true
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
-- Returns whether debug is enabled for the calling script on this side
-- (includes the server-side replicated flag on clients).
---@return boolean
debug.get = function()
    return isEnabled()
end

-- Dank.debug.print(message, level)
-- Prints a debug message to the console with the calling script's name.
-- level: 'info' | 'warning' | 'error' (default 'info')
---@param message string
---@param level? string
debug.print = function(message, level)
    if not isEnabled() then return end

    local lvl = LEVELS[normalizeLevel(level)]
    local scriptName = GetCurrentResourceName()

    print(('^2[%s]^7 %s[%s]^7 %s'):format(scriptName, lvl.color, lvl.tag, tostring(message)))
end

LogDebug(('[debug] module loaded (enable=%s)'):format(tostring(debug.enable)))

return debug
