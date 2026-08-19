-- Dank_Utils :: garage.lua  (shared)
-- Provides:
--   Dank.garage.registerOutside(plate, netId, model, garageId)
--   Dank.garage.deleteOutside(plate)
--   Dank.garage.storeVehicle(sourceOrVeh, vehicleEntity, garageId)
--   Dank.garage.impoundVehicle(plate, impoundName, reason, fee)
--   Dank.garage.getVehicleState(plate, cb)

---@class DankGarage
local garage = {}
local sharedConfig = require 'config.dankutils_shared'
local LogDebug = LogDebug or function() end

---@return string
local function getGarageScript()
    return sharedConfig.Garage or 'none'
end

---@param fn function
---@return boolean
local function safeCall(fn)
    local ok, err = pcall(fn)
    if not ok and err then
        LogDebug('Garage operation exception: ' .. tostring(err))
    end
    return ok
end

if IsDuplicityVersion() then
    -- SERVER SIDE LOGIC

    --- Register a vehicle as being outside of the garage
    ---@param plate string
    ---@param netId number
    ---@param model string|number|nil
    ---@param garageId string|nil
    garage.registerOutside = function(plate, netId, model, garageId)
        if not plate then return end
        LogDebug(('[garage] registerOutside(plate=%s, netId=%s) system=%s [server]'):format(tostring(plate), tostring(netId), tostring(getGarageScript())))
        local script = getGarageScript()

        safeCall(function()
            if script == 'jg-advancedgarages' then
                if exports['jg-advancedgarages'] and exports['jg-advancedgarages'].registerVehicleOutside then
                    exports['jg-advancedgarages']:registerVehicleOutside(plate, netId, model, garageId)
                end
            elseif script == 'qs-advancedgarages' or script == 'qs-garage' then
                if exports[script] and exports[script].registerVehicleOutside then
                    exports[script]:registerVehicleOutside(plate, netId)
                end
            elseif script == 'okokGarage' then
                if exports['okokGarage'] and exports['okokGarage'].SetVehicleOut then
                    exports['okokGarage']:SetVehicleOut(plate)
                end
            elseif script == 'rcore_garage' then
                if exports['rcore_garage'] and exports['rcore_garage'].SetVehicleOutside then
                    exports['rcore_garage']:SetVehicleOutside(plate, netId)
                end
            elseif script == 'qb-garages' or sharedConfig.Framework == 'qb-core' or sharedConfig.Framework == 'qbx_core' then
                if MySQL then
                    MySQL.update('UPDATE player_vehicles SET state = 0 WHERE plate = ?', { plate })
                end
            elseif script == 'esx_garage' or sharedConfig.Framework == 'es_extended' then
                if MySQL then
                    MySQL.update('UPDATE owned_vehicles SET stored = 0 WHERE plate = ?', { plate })
                end
            end
        end)
    end

    --- Remove / despawn outside status for a vehicle plate
    ---@param plate string
    garage.deleteOutside = function(plate)
        if not plate then return end
        LogDebug(('[garage] deleteOutside(plate=%s) system=%s [server]'):format(tostring(plate), tostring(getGarageScript())))
        local script = getGarageScript()

        safeCall(function()
            if script == 'jg-advancedgarages' then
                if exports['jg-advancedgarages'] and exports['jg-advancedgarages'].deleteOutsideVehicle then
                    exports['jg-advancedgarages']:deleteOutsideVehicle(plate)
                end
            elseif script == 'qs-advancedgarages' or script == 'qs-garage' then
                if exports[script] and exports[script].deleteOutsideVehicle then
                    exports[script]:deleteOutsideVehicle(plate)
                end
            elseif script == 'okokGarage' then
                if exports['okokGarage'] and exports['okokGarage'].SetVehicleIn then
                    exports['okokGarage']:SetVehicleIn(plate)
                end
            elseif script == 'rcore_garage' then
                if exports['rcore_garage'] and exports['rcore_garage'].SetVehicleInside then
                    exports['rcore_garage']:SetVehicleInside(plate)
                end
            elseif script == 'qb-garages' or sharedConfig.Framework == 'qb-core' or sharedConfig.Framework == 'qbx_core' then
                if MySQL then
                    MySQL.update('UPDATE player_vehicles SET state = 1 WHERE plate = ?', { plate })
                end
            elseif script == 'esx_garage' or sharedConfig.Framework == 'es_extended' then
                if MySQL then
                    MySQL.update('UPDATE owned_vehicles SET stored = 1 WHERE plate = ?', { plate })
                end
            end
        end)
    end

    --- Store a vehicle into garage
    ---@param source number
    ---@param vehicleEntity number
    ---@param garageId string|nil
    garage.storeVehicle = function(source, vehicleEntity, garageId)
        LogDebug(('[garage] storeVehicle(source=%s, veh=%s, garage=%s) system=%s [server]'):format(tostring(source), tostring(vehicleEntity), tostring(garageId), tostring(getGarageScript())))
        local script = getGarageScript()

        safeCall(function()
            if script == 'jg-advancedgarages' then
                if exports['jg-advancedgarages'] and exports['jg-advancedgarages'].storeVehicle then
                    exports['jg-advancedgarages']:storeVehicle(vehicleEntity)
                end
            elseif script == 'qb-garages' then
                if source and source > 0 then
                    TriggerClientEvent('qb-garages:client:storeVehicle', source)
                end
            elseif script == 'cd_garage' then
                if source and source > 0 then
                    TriggerClientEvent('cd_garage:StoreVehicle', source)
                end
            elseif script == 'okokGarage' then
                if vehicleEntity and DoesEntityExist(vehicleEntity) then
                    local plate = GetVehicleNumberPlateText(vehicleEntity)
                    if exports['okokGarage'] and exports['okokGarage'].StoreVehicle then
                        exports['okokGarage']:StoreVehicle(plate, garageId)
                    end
                end
            elseif script == 'rcore_garage' then
                if exports['rcore_garage'] and exports['rcore_garage'].StoreVehicle then
                    exports['rcore_garage']:StoreVehicle(vehicleEntity)
                end
            elseif script == 'qs-advancedgarages' or script == 'qs-garage' then
                if exports[script] and exports[script].StoreVehicle then
                    exports[script]:StoreVehicle(source, vehicleEntity)
                end
            end
        end)
    end

    --- Impound a vehicle by plate
    ---@param plate string
    ---@param impoundName string|nil
    ---@param reason string|nil
    ---@param fee number|nil
    garage.impoundVehicle = function(plate, impoundName, reason, fee)
        if not plate then return end
        LogDebug(('[garage] impoundVehicle(plate=%s, impound=%s, fee=%s) system=%s'):format(tostring(plate), tostring(impoundName), tostring(fee), tostring(getGarageScript())))
        local script = getGarageScript()

        safeCall(function()
            if script == 'jg-advancedgarages' then
                if exports['jg-advancedgarages'] and exports['jg-advancedgarages'].impoundVehicle then
                    exports['jg-advancedgarages']:impoundVehicle(plate, impoundName, reason, fee or 0)
                end
            elseif script == 'qb-garages' or sharedConfig.Framework == 'qb-core' or sharedConfig.Framework == 'qbx_core' then
                if MySQL then
                    MySQL.update('UPDATE player_vehicles SET state = 2, depotprice = ? WHERE plate = ?', { fee or 0, plate })
                end
            elseif script == 'cd_garage' then
                TriggerEvent('cd_garage:ImpoundVehicle', plate)
            elseif script == 'okokGarage' then
                if exports['okokGarage'] and exports['okokGarage'].ImpoundVehicle then
                    exports['okokGarage']:ImpoundVehicle(plate, impoundName, fee or 0)
                end
            elseif script == 'rcore_garage' then
                if exports['rcore_garage'] and exports['rcore_garage'].ImpoundVehicle then
                    exports['rcore_garage']:ImpoundVehicle(plate)
                end
            elseif script == 'esx_garage' or sharedConfig.Framework == 'es_extended' then
                if MySQL then
                    MySQL.update('UPDATE owned_vehicles SET stored = 2 WHERE plate = ?', { plate })
                end
            end
        end)
    end

    --- Query the state of a vehicle (0 = Out, 1 = Stored, 2 = Impounded)
    ---@param plate string
    ---@param cb fun(state: number)
    garage.getVehicleState = function(plate, cb)
        if not plate or not cb then return end
        LogDebug(('[garage] getVehicleState(plate=%s) framework=%s'):format(tostring(plate), tostring(sharedConfig.Framework)))

        safeCall(function()
            if sharedConfig.Framework == 'qb-core' or sharedConfig.Framework == 'qbx_core' then
                if MySQL then
                    MySQL.scalar('SELECT state FROM player_vehicles WHERE plate = ?', { plate }, function(state)
                        cb(state or 0)
                    end)
                else
                    cb(0)
                end
            elseif sharedConfig.Framework == 'es_extended' then
                if MySQL then
                    MySQL.scalar('SELECT stored FROM owned_vehicles WHERE plate = ?', { plate }, function(stored)
                        cb(stored or 0)
                    end)
                else
                    cb(0)
                end
            else
                cb(0)
            end
        end)
    end

    --- Returns information on all registered garages (Server only)
    ---@return table[]
    garage.getAllGarages = function()
        LogDebug(('[garage] getAllGarages system=%s'):format(tostring(getGarageScript())))
        local script = getGarageScript()
        local result = nil

        safeCall(function()
            if script == 'jg-advancedgarages' then
                if exports['jg-advancedgarages'] and exports['jg-advancedgarages'].getAllGarages then
                    result = exports['jg-advancedgarages']:getAllGarages()
                end
            elseif script == 'qb-garages' or sharedConfig.Framework == 'qb-core' or sharedConfig.Framework == 'qbx_core' then
                if exports['qb-garages'] and exports['qb-garages'].getAllGarages then
                    result = exports['qb-garages']:getAllGarages()
                end
            elseif script == 'cd_garage' then
                if exports['cd_garage'] and exports['cd_garage'].GetGarages then
                    result = exports['cd_garage']:GetGarages()
                end
            elseif script == 'okokGarage' then
                if exports['okokGarage'] and exports['okokGarage'].GetGarages then
                    result = exports['okokGarage']:GetGarages()
                end
            elseif script == 'qs-advancedgarages' or script == 'qs-garage' then
                if exports[script] and exports[script].getAllGarages then
                    result = exports[script]:getAllGarages()
                end
            end
        end)

        return result or {}
    end

else
    -- CLIENT SIDE LOGIC

    --- Register a vehicle as outside (Client)
    ---@param plate string
    ---@param netId number
    ---@param model string|number|nil
    ---@param garageId string|nil
    garage.registerOutside = function(plate, netId, model, garageId)
        if not plate then return end
        LogDebug(('[garage] registerOutside(plate=%s, netId=%s) system=%s [client]'):format(tostring(plate), tostring(netId), tostring(getGarageScript())))
        local script = getGarageScript()

        safeCall(function()
            if script == 'jg-advancedgarages' then
                if exports['jg-advancedgarages'] and exports['jg-advancedgarages'].registerVehicleOutside then
                    exports['jg-advancedgarages']:registerVehicleOutside(plate, netId, model, garageId)
                end
            elseif script == 'qs-advancedgarages' or script == 'qs-garage' then
                if exports[script] and exports[script].registerVehicleOutside then
                    exports[script]:registerVehicleOutside(plate, netId)
                end
            end
        end)
    end

    --- Remove / despawn outside vehicle record (Client)
    ---@param plate string
    garage.deleteOutside = function(plate)
        if not plate then return end
        LogDebug(('[garage] deleteOutside(plate=%s) system=%s [client]'):format(tostring(plate), tostring(getGarageScript())))
        local script = getGarageScript()

        safeCall(function()
            if script == 'jg-advancedgarages' then
                if exports['jg-advancedgarages'] and exports['jg-advancedgarages'].deleteOutsideVehicle then
                    exports['jg-advancedgarages']:deleteOutsideVehicle(plate)
                end
            elseif script == 'qs-advancedgarages' or script == 'qs-garage' then
                if exports[script] and exports[script].deleteOutsideVehicle then
                    exports[script]:deleteOutsideVehicle(plate)
                end
            end
        end)
    end

    --- Store vehicle into garage (Client)
    ---@param vehicleEntity number|nil
    ---@param garageId string|nil
    garage.storeVehicle = function(vehicleEntity, garageId)
        LogDebug(('[garage] storeVehicle(veh=%s, garage=%s) system=%s [client]'):format(tostring(vehicleEntity), tostring(garageId), tostring(getGarageScript())))
        local script = getGarageScript()
        local veh = vehicleEntity or GetVehiclePedIsIn(PlayerPedId(), false)

        safeCall(function()
            if script == 'jg-advancedgarages' then
                if exports['jg-advancedgarages'] and exports['jg-advancedgarages'].storeVehicle then
                    exports['jg-advancedgarages']:storeVehicle(veh)
                end
            elseif script == 'qb-garages' then
                TriggerEvent('qb-garages:client:storeVehicle')
            elseif script == 'cd_garage' then
                TriggerEvent('cd_garage:StoreVehicle')
            elseif script == 'okokGarage' then
                if veh and DoesEntityExist(veh) and exports['okokGarage'] and exports['okokGarage'].StoreVehicle then
                    local plate = GetVehicleNumberPlateText(veh)
                    exports['okokGarage']:StoreVehicle(plate, garageId)
                end
            elseif script == 'rcore_garage' then
                if exports['rcore_garage'] and exports['rcore_garage'].StoreVehicle then
                    exports['rcore_garage']:StoreVehicle(veh)
                end
            elseif script == 'qs-advancedgarages' or script == 'qs-garage' then
                if exports[script] and exports[script].StoreVehicle then
                    exports[script]:StoreVehicle(veh)
                end
            end
        end)
    end

    --- Trigger impound prompt / function (Client)
    ---@param plate string
    ---@param impoundName string|nil
    ---@param reason string|nil
    ---@param fee number|nil
    garage.impoundVehicle = function(plate, impoundName, reason, fee)
        local script = getGarageScript()
        LogDebug(('[garage] impoundVehicle(plate=%s, impound=%s, fee=%s) system=%s [client]'):format(tostring(plate), tostring(impoundName), tostring(fee), tostring(script)))

        safeCall(function()
            if script == 'jg-advancedgarages' then
                TriggerEvent('jg-advancedgarages:client:show-impound-form')
            elseif script == 'cd_garage' then
                TriggerEvent('cd_garage:ImpoundVehicle')
            end
        end)
    end
end

return garage
