local exports = exports
local print = print
local tostring = tostring
local ipairs = ipairs
local pairs = pairs
local type = type
local math = math

local sharedConfig = require 'config.dankutils_shared'
local LogDebug = LogDebug or function() end

---@class DankTarget
local target = {}

if not IsDuplicityVersion() then
    -- CLIENT
    -- Abstracting adding a box zone
    ---@param name string|table
    ---@param coords? table
    ---@param size? table
    ---@param options? table
    target.addBoxZone = function(name, coords, size, options)
        LogDebug(('[target] addBoxZone system=%s'):format(tostring(sharedConfig.Target)))
        local zoneName, zoneCoords, zoneSize, zoneOpts
        if type(name) == 'table' then
            zoneOpts = name
            zoneName = zoneOpts.name or ('zone_' .. tostring(math.random(1000, 9999)))
            zoneCoords = zoneOpts.coords
            zoneSize = zoneOpts.size or vec3(1.0, 1.0, 1.0)
        else
            zoneName = name
            zoneCoords = coords
            zoneSize = size
            zoneOpts = options or {}
        end
        zoneSize = zoneSize or vec3(1.0, 1.0, 1.0)
        zoneCoords = zoneCoords or vec3(0.0, 0.0, 0.0)

        local optionsList = zoneOpts.options or {}
        local rotation = zoneOpts.rotation or zoneOpts.heading or 0
        local debugPoly = zoneOpts.debug or zoneOpts.debugPoly or false
        local distance = zoneOpts.distance or 2.5

        local targetType = sharedConfig.Target
        if targetType == 'ox_target' then
            return exports.ox_target:addBoxZone({
                name = zoneName,
                coords = zoneCoords,
                size = zoneSize,
                rotation = rotation,
                debug = debugPoly,
                options = optionsList
            })
        elseif targetType == 'qb-target' then
            local qbOptions = {}
            for i, opt in ipairs(optionsList) do
                qbOptions[i] = {}
                for k, v in pairs(opt) do qbOptions[i][k] = v end
                if qbOptions[i].groups and not qbOptions[i].job then
                    qbOptions[i].job = qbOptions[i].groups
                end
                if not qbOptions[i].type then
                    qbOptions[i].type = 'client'
                end
            end
            return exports['qb-target']:AddBoxZone(zoneName, zoneCoords, zoneSize.x, zoneSize.y, {
                name = zoneName,
                heading = rotation,
                debugPoly = debugPoly,
                minZ = zoneCoords.z - ((zoneSize.z or 4.0) / 2),
                maxZ = zoneCoords.z + ((zoneSize.z or 4.0) / 2),
            }, {
                options = qbOptions,
                distance = distance
            })
        elseif targetType == 'qtarget' then
            local qbOptions = {}
            for i, opt in ipairs(optionsList) do
                qbOptions[i] = {}
                for k, v in pairs(opt) do qbOptions[i][k] = v end
                if qbOptions[i].groups and not qbOptions[i].job then
                    qbOptions[i].job = qbOptions[i].groups
                end
                if not qbOptions[i].type then
                    qbOptions[i].type = 'client'
                end
            end
            return exports.qtarget:AddBoxZone(zoneName, zoneCoords, zoneSize.x, zoneSize.y, {
                name = zoneName,
                heading = rotation,
                debugPoly = debugPoly,
                minZ = zoneCoords.z - ((zoneSize.z or 4.0) / 2),
                maxZ = zoneCoords.z + ((zoneSize.z or 4.0) / 2),
            }, {
                options = qbOptions,
                distance = distance
            })
        else
            print('^3[Dank_Utils] Target: Unsupported or undetected target system (' .. tostring(targetType) .. ') for addBoxZone.^0')
        end
    end

    -- Abstracting adding an entity
    ---@param entity integer
    ---@param options table
    target.addEntity = function(entity, options)
        LogDebug(('[target] addEntity system=%s'):format(tostring(sharedConfig.Target)))
        local targetType = sharedConfig.Target
        local opts = options or {}
        if targetType == 'ox_target' then
            return exports.ox_target:addLocalEntity(entity, opts)
        elseif targetType == 'qb-target' then
            local qbOptions = {}
            for i, opt in ipairs(opts) do
                qbOptions[i] = {}
                for k, v in pairs(opt) do qbOptions[i][k] = v end
                if qbOptions[i].groups and not qbOptions[i].job then
                    qbOptions[i].job = qbOptions[i].groups
                end
                if not qbOptions[i].type then
                    qbOptions[i].type = 'client'
                end
            end
            return exports['qb-target']:AddTargetEntity(entity, {
                options = qbOptions,
                distance = 2.5
            })
        elseif targetType == 'qtarget' then
            local qbOptions = {}
            for i, opt in ipairs(opts) do
                qbOptions[i] = {}
                for k, v in pairs(opt) do qbOptions[i][k] = v end
                if qbOptions[i].groups and not qbOptions[i].job then
                    qbOptions[i].job = qbOptions[i].groups
                end
                if not qbOptions[i].type then
                    qbOptions[i].type = 'client'
                end
            end
            return exports.qtarget:AddTargetEntity(entity, {
                options = qbOptions,
                distance = 2.5
            })
        else
            print('^3[Dank_Utils] Target: Unsupported target system (' .. tostring(targetType) .. ') for addEntity.^0')
        end
    end

    -- Abstracting adding a model (NOW PROPERLY TOP-LEVEL, NOT NESTED!)
    ---@param model string|number|table
    ---@param options? table
    target.addModel = function(model, options)
        LogDebug(('[target] addModel(model=%s) system=%s'):format(tostring(model), tostring(sharedConfig.Target)))
        local models, opts
        if type(model) == 'table' and not model[1] and model.model then
            models = model.model
            opts = model.options
        else
            models = model
            opts = options
        end
        if type(opts) ~= 'table' then opts = {} end

        local targetType = sharedConfig.Target
        if targetType == 'ox_target' then
            return exports.ox_target:addModel(models, opts)
        elseif targetType == 'qb-target' then
            local qbOptions = {}
            for i, opt in ipairs(opts) do
                qbOptions[i] = {}
                for k, v in pairs(opt) do qbOptions[i][k] = v end
                if qbOptions[i].groups and not qbOptions[i].job then
                    qbOptions[i].job = qbOptions[i].groups
                end
                if not qbOptions[i].type then
                    qbOptions[i].type = 'client'
                end
            end
            return exports['qb-target']:AddTargetModel(models, {
                options = qbOptions,
                distance = 2.5
            })
        elseif targetType == 'qtarget' then
            local qbOptions = {}
            for i, opt in ipairs(opts) do
                qbOptions[i] = {}
                for k, v in pairs(opt) do qbOptions[i][k] = v end
                if qbOptions[i].groups and not qbOptions[i].job then
                    qbOptions[i].job = qbOptions[i].groups
                end
                if not qbOptions[i].type then
                    qbOptions[i].type = 'client'
                end
            end
            return exports.qtarget:AddTargetModel(models, {
                options = qbOptions,
                distance = 2.5
            })
        else
            print('^3[Dank_Utils] Target: Unsupported target system (' .. tostring(targetType) .. ') for addModel.^0')
        end
    end

    ---@param options table
    ---@return integer|string|nil
    target.addCircleZone = function(options)
        if type(options) ~= 'table' or not options.coords then return nil end
        LogDebug(('[target] addCircleZone system=%s'):format(tostring(sharedConfig.Target)))
        local targetType = sharedConfig.Target
        local targetOptions = options.options or {}
        if targetOptions.name or targetOptions.label or targetOptions.event or targetOptions.onSelect then
            targetOptions = { targetOptions }
        end
        if targetType == 'ox_target' then
            return exports.ox_target:addSphereZone({
                name = options.name,
                coords = options.coords,
                radius = options.radius or 1.0,
                debug = options.debugPoly or false,
                options = targetOptions
            })
        elseif targetType == 'qb-target' or targetType == 'qtarget' then
            local targetExport = targetType == 'qb-target' and exports['qb-target'] or exports.qtarget
            local qbOptions = {}
            for i, opt in ipairs(targetOptions) do
                qbOptions[i] = {}
                for k, v in pairs(opt) do qbOptions[i][k] = v end
                if qbOptions[i].groups and not qbOptions[i].job then
                    qbOptions[i].job = qbOptions[i].groups
                end
                if not qbOptions[i].type then qbOptions[i].type = 'client' end
            end
            return targetExport:AddCircleZone(options.name, options.coords, options.radius or 1.0, {
                name = options.name,
                debugPoly = options.debugPoly or false,
                useZ = true
            }, {
                options = qbOptions,
                distance = options.distance or 2.5
            })
        end
    end

    ---@param zoneId string
    target.removeZone = function(zoneId)
        LogDebug(('[target] removeZone(id=%s) system=%s'):format(tostring(zoneId), tostring(sharedConfig.Target)))
        local targetType = sharedConfig.Target
        if targetType == 'ox_target' then
            exports.ox_target:removeZone(zoneId)
        elseif targetType == 'qb-target' then
            exports['qb-target']:RemoveZone(zoneId)
        elseif targetType == 'qtarget' then
            exports.qtarget:RemoveZone(zoneId)
        end
    end

    ---@param options table
    target.addGlobalVehicle = function(options)
        LogDebug(('[target] addGlobalVehicle system=%s'):format(tostring(sharedConfig.Target)))
        local targetType = sharedConfig.Target
        if targetType == 'ox_target' then
            return exports.ox_target:addGlobalVehicle(options)
        elseif targetType == 'qb-target' or targetType == 'qtarget' then
            local targetExport = targetType == 'qb-target' and exports['qb-target'] or exports.qtarget
            local qbOptions = {}
            for i, opt in ipairs(options or {}) do
                qbOptions[i] = {}
                for k, v in pairs(opt) do qbOptions[i][k] = v end
                if not qbOptions[i].type then qbOptions[i].type = 'client' end
            end
            return targetExport:AddGlobalVehicle({
                options = qbOptions,
                distance = 2.5
            })
        end
    end

    ---@param options table
    target.addGlobalOption = function(options)
        LogDebug(('[target] addGlobalOption system=%s'):format(tostring(sharedConfig.Target)))
        local targetType = sharedConfig.Target
        if targetType == 'ox_target' then
            return exports.ox_target:addGlobalOption(options)
        elseif targetType == 'qb-target' or targetType == 'qtarget' then
            print('^3[Dank_Utils] addGlobalOption is not natively supported in qb-target/qtarget.^0')
        end
    end

    ---@param entity integer
    target.removeLocalEntity = function(entity)
        LogDebug(('[target] removeLocalEntity system=%s'):format(tostring(sharedConfig.Target)))
        local targetType = sharedConfig.Target
        if targetType == 'ox_target' then
            exports.ox_target:removeLocalEntity(entity)
        elseif targetType == 'qb-target' then
            exports['qb-target']:RemoveTargetEntity(entity)
        elseif targetType == 'qtarget' then
            exports.qtarget:RemoveTargetEntity(entity)
        end
    end

    -- Aliases for flexibility across target scripts
    target.addLocalEntity = target.addEntity
    target.removeEntity = target.removeLocalEntity
end

return target
