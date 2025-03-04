-- @module Target
-- @desc Server-side target status for Dank Utils, supporting qb-target and ox_target.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Target = Framework.Target or {}

-- Valid target options
local validTargets = { ['qb-target'] = true, ['ox_target'] = true }
if SharedConfig.Target and validTargets[SharedConfig.Target] then
    local state = GetResourceState(SharedConfig.Target)
    if state == 'started' or state == 'starting' then
        Framework.Status.Target = SharedConfig.Target
    else
        LogDebug('[Dank Utils] Target resource "' .. SharedConfig.Target .. '" is not active.')
    end
elseif SharedConfig.Target ~= 'AutoDetect' then
    LogDebug('[Dank Utils] Unsupported Target option: ' .. tostring(SharedConfig.Target))
end

return Framework