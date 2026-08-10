local exports = exports
local print = print
local tostring = tostring

local sharedConfig = require 'config.shared'
local target = {}

if not IsDuplicityVersion() then
    -- CLIENT
    -- Abstracting adding a box zone
    -- options expects: { rotation = number, debugPoly = boolean, distance = number, options = table (standard ox/qb target options) }
    target.addBoxZone = function(name, coords, size, options)
        local targetType = sharedConfig.Target
        if targetType == 'ox_target' then
            exports.ox_target:addBoxZone({
                coords = coords,
                size = size,
                rotation = options.rotation or 0,
                debug = options.debugPoly or false,
                options = options.options
            })
        elseif targetType == 'qb-target' then
            exports['qb-target']:AddBoxZone(name, coords, size.x, size.y, {
                name = name,
                heading = options.rotation or 0,
                debugPoly = options.debugPoly or false,
                minZ = coords.z - 2.0,
                maxZ = coords.z + 2.0,
            }, {
                options = options.options,
                distance = options.distance or 2.5
            })
        elseif targetType == 'qtarget' then
            exports.qtarget:AddBoxZone(name, coords, size.x, size.y, {
                name = name,
                heading = options.rotation or 0,
                debugPoly = options.debugPoly or false,
                minZ = coords.z - 2.0,
                maxZ = coords.z + 2.0,
            }, {
                options = options.options,
                distance = options.distance or 2.5
            })
        else
            print('^3[Dank_Utils] Target: Unsupported target system ('..tostring(targetType)..') for addBoxZone.^0')
        end
    end

    -- Abstracting adding an entity
    -- options expects: a table of options (standard ox/qb target options)
    target.addEntity = function(entity, options)
        local targetType = sharedConfig.Target
        if targetType == 'ox_target' then
            exports.ox_target:addLocalEntity(entity, options)
        elseif targetType == 'qb-target' then
            exports['qb-target']:AddTargetEntity(entity, {
                options = options,
                distance = 2.5
            })
        elseif targetType == 'qtarget' then
            exports.qtarget:AddTargetEntity(entity, {
                options = options,
                distance = 2.5
            })
        else
            print('^3[Dank_Utils] Target: Unsupported target system ('..tostring(targetType)..') for addEntity.^0')
        end
    end
end

return target
