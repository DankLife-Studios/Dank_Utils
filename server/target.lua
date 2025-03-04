-- @module Target
-- @desc Server-side target status for Dank Utils, supporting qb-target and ox_target.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Target = Framework.Target or {}

local sharedConfig = require 'config.shared'

-- Valid target options
local validTargets = { ['qb-target'] = true, ['ox_target'] = true }
if sharedConfig.Target and validTargets[sharedConfig.Target] then
    local state = GetResourceState(sharedConfig.Target)
    if state == 'started' or state == 'starting' then
        Framework.Status.Target = sharedConfig.Target
    else
        LogDebug('[Dank Utils] Target resource "' .. sharedConfig.Target .. '" is not active.')
    end
elseif sharedConfig.Target ~= 'AutoDetect' then
    LogDebug('[Dank Utils] Unsupported Target option: ' .. tostring(sharedConfig.Target))
end

return Framework