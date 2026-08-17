local exports = exports
local print = print

local sharedConfig = require 'config.dankutils_shared'
local LogDebug = LogDebug

---@class DankVehicle
local vehicle = {}

if IsDuplicityVersion() then
    lib.callback.register('Dank_Utils:server:SpawnVehicle', function(source, model, coords, platePrefix)
        local netId = nil
        local p = promise.new()

        vehicle.spawn(source, model, coords, platePrefix, function(veh)
            netId = NetworkGetNetworkIdFromEntity(veh)
            p:resolve(netId)
        end)

        return Citizen.Await(p)
    end)

    ---@param source integer|nil
    ---@param model string|number
    ---@param coords table
    ---@param platePrefix? string
    ---@param cb? fun(veh: integer)
    vehicle.spawn = function(source, model, coords, platePrefix, cb)
        LogDebug(('[vehicle] spawn(source=%s, model=%s, platePrefix=%s) framework=%s'):format(tostring(source), tostring(model), tostring(platePrefix), tostring(sharedConfig.Framework)))
        local function finalizeSpawn(veh)
            -- Apply custom plate if requested
            local plate = GetVehicleNumberPlateText(veh)
            if platePrefix and type(platePrefix) == 'string' then
                plate = platePrefix .. tostring(math.random(1000, 9999))
                SetVehicleNumberPlateText(veh, plate)
            end

            -- Automatically set fuel to 100 on spawn
            Dank.fuel.set(veh, 100.0)

            -- Automatically give keys if a source requested it
            if source and source > 0 then
                Dank.keys.give(source, veh, plate)
            end

            if cb then cb(veh) end
        end

        local heading = coords.w or 0.0

        if sharedConfig.Framework == 'qbx_core' then
            local modelHash = type(model) == 'number' and model or joaat(model)
            local netId, veh = qbx.spawnVehicle({
                model = modelHash,
                spawnSource = coords
            })
            if veh then finalizeSpawn(veh) end
        elseif sharedConfig.Framework == 'qb-core' then
            local QBCore = exports['qb-core']:GetCoreObject()
            QBCore.Functions.SpawnVehicle(model, function(veh)
                finalizeSpawn(veh)
            end, coords, true)
        elseif sharedConfig.Framework == 'es_extended' then
            local ESX = exports['es_extended']:getSharedObject()
            if ESX and ESX.Game and ESX.Game.SpawnVehicle then
                ESX.Game.SpawnVehicle(model, coords, heading, function(veh)
                    finalizeSpawn(veh)
                end)
            else
                local modelHash = type(model) == 'number' and model or joaat(model)
                local veh = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, true)
                if veh and DoesEntityExist(veh) then finalizeSpawn(veh) end
            end
        elseif sharedConfig.Framework == 'ox_core' then
            local veh = exports.ox_core:CreateVehicle({ model = model, position = coords, heading = heading })
            if veh then finalizeSpawn(veh) end
        else
            -- Native Server Vehicle Spawn Fallback (ND_Core / Standalone)
            LogDebug('[vehicle] spawn: native fallback (ND_Core / standalone)')
            local modelHash = type(model) == 'number' and model or joaat(model)
            local veh = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, true)
            if veh and DoesEntityExist(veh) then
                finalizeSpawn(veh)
            end
        end
    end
else
    -- CLIENT
    ---@param model string
    ---@return table|nil
    vehicle.getData = function(model)
        LogDebug(('[vehicle] getData(model=%s) framework=%s'):format(tostring(model), tostring(sharedConfig.Framework)))
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

    ---@param model string|number
    ---@param coords table
    ---@param platePrefix? string
    ---@param callback? fun(veh: integer)
    vehicle.spawn = function(model, coords, platePrefix, callback)
        LogDebug(('[vehicle] spawn(model=%s, platePrefix=%s) via callback'):format(tostring(model), tostring(platePrefix)))
        lib.callback('Dank_Utils:server:SpawnVehicle', false, function(netId)
            if netId and NetworkDoesEntityExistWithNetworkId(netId) then
                local veh = NetToVeh(netId)
                SetVehicleEngineOn(veh, true, true, true)
                
                if callback then callback(veh) end
            end
        end, model, coords, platePrefix)
    end
end

return vehicle
