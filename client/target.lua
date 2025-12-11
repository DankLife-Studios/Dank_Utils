-- @module Target
-- @desc Provides a unified interface for target systems (qb-target, ox_target) in Dank Utils.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Target = Framework.Target or {}

local sharedConfig = require 'config.shared'

Framework.Target.AddBoxZone = function(params)
    if sharedConfig.Target == 'qb-target' then
        local options = params.options or {}
        exports['qb-target']:AddBoxZone(params.name, params.coords, params.size.x, params.size.y, {
            heading = params.heading,
            minZ = params.minZ,
            maxZ = params.maxZ,
            debugPoly = params.debugPoly or false,
        }, {
            options = {{
                type = options.type or "client",
                icon = options.icon or 'fas fa-hand-holding-water',
                label = options.label or "Interact",
                action = options.action or options.onSelect,
                canInteract = options.canInteract or nil,
                job = options.job or nil
            }},
            distance = options.distance or 2.5
        })
        return params.name
    elseif sharedConfig.Target == 'ox_target' then
        local zoneId = exports.ox_target:addBoxZone({
            coords = vec3(params.coords.x, params.coords.y, params.coords.z),
            size = vec3(params.size.x, params.size.y, params.size.z),
            rotation = params.heading,
            debug = params.debug or false,
            options = {{
                icon = params.options.icon or 'fas fa-hand-holding-water',
                label = params.options.label or "Interact",
                distance = params.options.distance or 2.5,
                onSelect = params.options.onSelect or params.options.action,
                canInteract = params.options.canInteract,
                groups = params.options.job
            }}
        })
        return zoneId
    else
        LogDebug('[Dank Utils] Unsupported target system for AddBoxZone: ' .. tostring(sharedConfig.Target))
    end
end

Framework.Target.AddCircleZone = function(params)
    if sharedConfig.Target == 'qb-target' then
        exports['qb-target']:AddCircleZone(params.name, params.coords, params.radius, {
            debugPoly = params.debugPoly or false,
        }, {
            options = {{
                type = params.options.type or "client",
                icon = params.options.icon or nil,
                label = params.options.label or "Interact",
                action = params.options.action or params.options.onSelect,
                canInteract = params.options.canInteract or nil,
                job = params.options.job or nil
            }},
            distance = params.options.distance or 2.5
        })
        return params.name
    elseif sharedConfig.Target == 'ox_target' then
        local zoneId = exports.ox_target:addSphereZone({
            coords = params.coords,
            radius = params.radius,
            debug = params.debug or false,
            options = {{
                icon = params.options.icon or nil,
                label = params.options.label or "Interact",
                distance = params.options.distance or 2.5,
                onSelect = params.options.onSelect or params.options.action,
                canInteract = params.options.canInteract,
                groups = params.options.job
            }}
        })
        return zoneId
    else
        LogDebug('[Dank Utils] Unsupported target system for AddCircleZone: ' .. tostring(sharedConfig.Target))
    end
end

Framework.Target.AddTargetModel = function(model, options)
    if sharedConfig.Target == 'qb-target' then
        exports['qb-target']:AddTargetModel(model, {
            options = {{
                type = "client",
                icon = options.icon or "fa-regular fa-comments",
                label = options.label or "Interact",
                action = options.action or options.onSelect,
                canInteract = options.canInteract,
            }},
            distance = options.distance or 3.0
        })
    elseif sharedConfig.Target == 'ox_target' then
        exports.ox_target:addModel(model, {
            label = options.label or "Interact",
            icon = options.icon or "fa-regular fa-comments",
            distance = options.distance or 3.0,
            onSelect = options.onSelect or options.action,
            canInteract = options.canInteract
        })
    else
        LogDebug('[Dank Utils] Unsupported target system for AddTargetModel: ' .. tostring(sharedConfig.Target))
    end
end

Framework.Target.RemoveZone = function(identifier)
    if sharedConfig.Target == 'qb-target' then
        exports['qb-target']:RemoveZone(identifier)
    elseif sharedConfig.Target == 'ox_target' then
        exports.ox_target:removeZone(identifier)
    else
        LogDebug('[Dank Utils] Unsupported target system for RemoveZone: ' .. tostring(sharedConfig.Target))
    end
end

-- Set target status if valid and active
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