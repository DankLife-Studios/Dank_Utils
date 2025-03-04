-- @module Menu
-- @desc Manages menu status for Dank Utils, supporting ox_lib and qb-menu.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Menu = Framework.Menu or {}

-- Valid menu options
local validMenus = {
    ['ox_lib'] = true,
    ['qb-menu'] = true
}

if SharedConfig.Menu and validMenus[SharedConfig.Menu] then
    local state = GetResourceState(SharedConfig.Menu)
    if state == 'started' or state == 'starting' then
        Framework.Status.Menu = SharedConfig.Menu
    else
        LogDebug('[Dank Utils] Menu resource "' .. SharedConfig.Menu .. '" is not active.')
    end
elseif SharedConfig.Menu ~= 'AutoDetect' then
    LogDebug('[Dank Utils] Unsupported Menu option: ' .. tostring(SharedConfig.Menu))
end

return Framework