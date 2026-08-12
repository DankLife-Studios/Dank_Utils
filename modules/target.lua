local exports = exports
local print = print
local tostring = tostring
local ipairs = ipairs
local pairs = pairs
local type = type
local math = math

local sharedConfig = require 'config.dankutils_shared'
local target = {}

if not IsDuplicityVersion() then
    -- CLIENT
    -- Abstracting adding a box zone
    target.addBoxZone = function(name, coords, size, options)
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

        local optionsList = zoneOpts.options or {}
        local rotation = zoneOpts.rotation or zoneOpts.heading or 0
        local debugPoly = zoneOpts.debug or zoneOpts.debugPoly or false
        local distance = zoneOpts.distance or 2.5

        local targetType = sharedConfig.Target
        if targetType == 'ox_target' then
            exports.ox_target:addBoxZone({
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
            exports['qb-target']:AddBoxZone(zoneName, zoneCoords, zoneSize.x, zoneSize.y, {
                name = zoneName,
                heading = rotation,
                debugPoly = debugPoly,
                minZ = zoneCoords.z - 2.0,
                maxZ = zoneCoords.z + 2.0,
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
            exports.qtarget:AddBoxZone(zoneName, zoneCoords, zoneSize.x, zoneSize.y, {
                name = zoneName,
                heading = rotation,
                debugPoly = debugPoly,
                minZ = zoneCoords.z - 2.0,
                maxZ = zoneCoords.z + 2.0,
            }, {
                options = qbOptions,
                distance = distance
            })
        else
            print('^3[Dank_Utils] Target: Unsupported or undetected target system (' .. tostring(targetType) .. ') for addBoxZone.^0')
        end
    end

    -- Abstracting adding an entity
    target.addEntity = function(entity, options)
        local targetType = sharedConfig.Target
        local opts = options or {}
        if targetType == 'ox_target' then
            exports.ox_target:addLocalEntity(entity, opts)
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
            exports['qb-target']:AddTargetEntity(entity, {
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
            exports.qtarget:AddTargetEntity(entity, {
                options = qbOptions,
                distance = 2.5
            })
        else
            print('^3[Dank_Utils] Target: Unsupported target system (' .. tostring(targetType) .. ') for addEntity.^0')
        end
    end

    -- Abstracting adding a model (NOW PROPERLY TOP-LEVEL, NOT NESTED!)
    target.addModel = function(model, options)
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
            exports.ox_target:addModel(models, opts)
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
            exports['qb-target']:AddTargetModel(models, {
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
            exports.qtarget:AddTargetModel(models, {
                options = qbOptions,
                distance = 2.5
            })
        else
            print('^3[Dank_Utils] Target: Unsupported target system (' .. tostring(targetType) .. ') for addModel.^0')
        end
    end

    target.addCircleZone = function(options)
        local targetType = sharedConfig.Target
        if targetType == 'ox_target' then
            return exports.ox_target:addSphereZone({
                coords = options.coords,
                radius = options.radius or 1.0,
                debug = options.debugPoly or false,
                options = { options.options }
            })
        elseif targetType == 'qb-target' then
            local qbOptions = {}
            local opt = options.options or {}
            qbOptions[1] = {}
            for k, v in pairs(opt) do qbOptions[1][k] = v end
            if not qbOptions[1].type then qbOptions[1].type = 'client' end
            exports['qb-target']:AddCircleZone(options.name, options.coords, options.radius or 1.0, {
                name = options.name,
                debugPoly = options.debugPoly or false,
                useZ = true
            }, {
                options = qbOptions,
                distance = opt.distance or 2.5
            })
            return options.name
        end
    end

    target.removeZone = function(zoneId)
        local targetType = sharedConfig.Target
        if targetType == 'ox_target' then
            exports.ox_target:removeZone(zoneId)
        elseif targetType == 'qb-target' then
            exports['qb-target']:RemoveZone(zoneId)
        end
    end

    target.addGlobalVehicle = function(options)
        local targetType = sharedConfig.Target
        if targetType == 'ox_target' then
            exports.ox_target:addGlobalVehicle(options)
        elseif targetType == 'qb-target' then
            local qbOptions = {}
            for i, opt in ipairs(options or {}) do
                qbOptions[i] = {}
                for k, v in pairs(opt) do qbOptions[i][k] = v end
                if not qbOptions[i].type then qbOptions[i].type = 'client' end
            end
            exports['qb-target']:AddGlobalVehicle({
                options = qbOptions,
                distance = 2.5
            })
        end
    end

    target.addGlobalOption = function(options)
        local targetType = sharedConfig.Target
        if targetType == 'ox_target' then
            exports.ox_target:addGlobalOption(options)
        elseif targetType == 'qb-target' then
            print('^3[Dank_Utils] addGlobalOption is not natively supported in qb-target.^0')
        end
    end

    target.removeLocalEntity = function(entity)
        local targetType = sharedConfig.Target
        if targetType == 'ox_target' then
            exports.ox_target:removeLocalEntity(entity)
        elseif targetType == 'qb-target' then
            exports['qb-target']:RemoveTargetEntity(entity)
        end
    end
end

return target