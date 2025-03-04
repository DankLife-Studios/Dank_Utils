-- @module Menu
-- @desc Manages menu status for Dank Utils, supporting ox_lib and qb-menu.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Menu = Framework.Menu or {}

local sharedConfig = require 'config.shared'

-- Valid menu options
local validMenus = {
    ['ox_lib'] = true,
    ['qb-menu'] = true
}

if sharedConfig.Menu and validMenus[sharedConfig.Menu] then
    local state = GetResourceState(sharedConfig.Menu)
    if state == 'started' or state == 'starting' then
        Framework.Status.Menu = sharedConfig.Menu
    else
        LogDebug('[Dank Utils] Menu resource "' .. sharedConfig.Menu .. '" is not active.')
    end
elseif sharedConfig.Menu ~= 'AutoDetect' then
    LogDebug('[Dank Utils] Unsupported Menu option: ' .. tostring(sharedConfig.Menu))
end

return Framework