local exports = exports
local print = print
local tonumber = tonumber
local type = type
local tostring = tostring

local sharedConfig = require 'config.dankutils_shared'
local LogDebug = LogDebug or function() end

---@class DankVehicle
local vehicle = {}

if IsDuplicityVersion() then
    if GetCurrentResourceName() == 'Dank_Utils' then
        lib.callback.register('Dank_Utils:server:SpawnVehicle', function(source, model, coords, platePrefix)
            local netId = nil
            local p = promise.new()

            vehicle.spawn(source, model, coords, platePrefix, function(veh)
                if veh and DoesEntityExist(veh) then
                    netId = NetworkGetNetworkIdFromEntity(veh)
                end
                p:resolve(netId)
            end)

            return Citizen.Await(p)
        end)

        exports('SpawnVehicleAwait', function(source, model, coords, platePrefix)
            local p = promise.new()
            vehicle.spawn(source, model, coords, platePrefix, function(veh)
                p:resolve(veh)
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
                if not veh or veh == 0 or not DoesEntityExist(veh) then
                    if cb then cb(nil) end
                    return
                end

                -- Apply custom plate if requested
                local plate = GetVehicleNumberPlateText(veh)
                if platePrefix and type(platePrefix) == 'string' then
                    plate = platePrefix .. tostring(math.random(1000, 9999))
                    SetVehicleNumberPlateText(veh, plate)
                end

                -- Automatically set fuel to 100 on spawn
                Dank.fuel.set(veh, 100.0)

                -- Automatically give keys if a source requested it
                local playerSource = tonumber(source)
                if playerSource and playerSource > 0 then
                    Dank.keys.give(playerSource, veh, plate)
                end

                if cb then cb(veh) end
            end

            local heading = coords.w or 0.0

            if sharedConfig.Framework == 'qbx_core' then
                -- Use the server native so Dank_Utils does not require Qbox's optional lib module.
                local modelHash = type(model) == 'number' and model or joaat(model)
                local veh = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, true)
                finalizeSpawn(veh)
            elseif sharedConfig.Framework == 'qb-core' then
                local QBCore = exports['qb-core']:GetCoreObject()
                if QBCore and QBCore.Functions and QBCore.Functions.SpawnVehicle then
                    QBCore.Functions.SpawnVehicle(model, function(veh)
                        finalizeSpawn(veh)
                    end, coords, true)
                else
                    finalizeSpawn(nil)
                end
            elseif sharedConfig.Framework == 'es_extended' then
                local ESX = exports['es_extended']:getSharedObject()
                if ESX and ESX.Game and ESX.Game.SpawnVehicle then
                    ESX.Game.SpawnVehicle(model, coords, heading, function(veh)
                        finalizeSpawn(veh)
                    end)
                else
                    local modelHash = type(model) == 'number' and model or joaat(model)
                    local veh = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, true)
                    finalizeSpawn(veh)
                end
            elseif sharedConfig.Framework == 'ox_core' then
                local veh = exports.ox_core:CreateVehicle({ model = model, position = coords, heading = heading })
                finalizeSpawn(veh)
            else
                -- Native Server Vehicle Spawn Fallback (ND_Core / Standalone)
                LogDebug('[vehicle] spawn: native fallback (ND_Core / standalone)')
                local modelHash = type(model) == 'number' and model or joaat(model)
                local veh = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, true)
                if veh and DoesEntityExist(veh) then
                    finalizeSpawn(veh)
                else
                    finalizeSpawn(nil)
                end
            end
        end
    else
        vehicle.spawn = function(source, model, coords, platePrefix, cb)
            local veh = exports.Dank_Utils:SpawnVehicleAwait(source, model, coords, platePrefix)
            if cb then cb(veh) end
            return veh
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
            elseif callback then
                callback(nil)
            end
        end, model, coords, platePrefix)
    end
end

return vehicle
