local exports = exports
local print = print

local sharedConfig = require 'config.shared'
local vehicle = {}

if IsDuplicityVersion() then
    -- SERVER
    vehicle.spawn = function(model, coords, heading, cb)
        if sharedConfig.Framework == 'qbx_core' then
            exports.qbx_core:SpawnVehicle(model, coords, heading, cb)
        elseif sharedConfig.Framework == 'qb-core' then
            local QBCore = exports['qb-core']:GetCoreObject()
            QBCore.Functions.SpawnVehicle(model, function(veh)
                if cb then cb(veh) end
            end, coords, heading)
        elseif sharedConfig.Framework == 'es_extended' then
            local ESX = exports['es_extended']:getSharedObject()
            ESX.Game.SpawnVehicle(model, coords, heading, cb)
        elseif sharedConfig.Framework == 'ox_core' then
            local veh = exports.ox_core:CreateVehicle({ model = model, position = coords, heading = heading })
            if cb then cb(veh) end
        elseif sharedConfig.Framework == 'ND_Core' then
            print('^3[Dank_Utils] SpawnVehicle: ND_Core does not natively support server-side vehicle spawning without native wrappers.^0')
        end
    end
else
    -- CLIENT
    vehicle.getData = function(model)
        if sharedConfig.Framework == 'qbx_core' then
            local vehicles = exports.qbx_core:GetVehiclesByName()
            return vehicles[model] or nil
        elseif sharedConfig.Framework == 'qb-core' then
            local core = exports['qb-core']:GetCoreObject()
            return core and core.Shared.Vehicles[model] or nil
        elseif sharedConfig.Framework == 'ox_core' then
            return exports.ox_core:GetVehicleData(model)
        end
        return nil
    end
end

return vehicle
