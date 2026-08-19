-- Dank_Utils :: keys.lua  (shared)
-- Provides: Dank.keys.give(source, veh, plate), Dank.keys.remove(source, veh, plate)

---@class DankKeys
local keys = {}

local sharedConfig = require 'config.dankutils_shared'
local LogDebug = LogDebug or function() end

---@return string
local function getKeysScript()
    return sharedConfig.Keys or 'none'
end

---@param source integer|nil
---@param veh integer|nil
---@param plate string|nil
keys.give = function(source, veh, plate)
    if not source or not veh then
        LogDebug('[keys] give skipped (missing source or vehicle)')
        return
    end

    if not plate and DoesEntityExist(veh) then
        plate = GetVehicleNumberPlateText(veh)
    end

    local script = getKeysScript()
    LogDebug(('[keys] give(source=%s, plate=%s) system=%s'):format(tostring(source), tostring(plate), tostring(script)))

    if IsDuplicityVersion() then
        -- SERVER
        if script == 'qbx_vehiclekeys' then
            exports.qbx_vehiclekeys:GiveKeys(source, veh, false)
        elseif script == 'qb-vehiclekeys' then
            TriggerClientEvent('vehiclekeys:client:SetOwner', source, plate)
        elseif script == 'wasabi_carlock' then
            exports.wasabi_carlock:GiveKey(source, plate)
        elseif script == 'qs-vehiclekeys' then
            exports['qs-vehiclekeys']:GiveKeys(source, plate)
        elseif script == 'mono_carlock' then
            TriggerClientEvent('mono_carlock:GiveKeys', source, plate)
        elseif script == 'tupani_carlock' then
            exports['tupani_carlock']:GiveKeys(source, plate)
        else
            -- Default fallback to qb-vehiclekeys style if framework is qb-core
            if sharedConfig.Framework == 'qb-core' then
                TriggerClientEvent('vehiclekeys:client:SetOwner', source, plate)
            end
        end
    else
        -- CLIENT (Client side giving keys usually relies on server side exports anyway, but we can trigger server events if needed)
        -- Usually we don't give keys from client, but if we do:
        if script == 'qb-vehiclekeys' then
            TriggerEvent('vehiclekeys:client:SetOwner', plate)
        end
    end
end

---@param source integer|nil
---@param veh integer|nil
---@param plate string|nil
keys.remove = function(source, veh, plate)
    if not source or not veh then
        LogDebug('[keys] remove skipped (missing source or vehicle)')
        return
    end

    if not plate and DoesEntityExist(veh) then
        plate = GetVehicleNumberPlateText(veh)
    end

    local script = getKeysScript()
    LogDebug(('[keys] remove(source=%s, plate=%s) system=%s'):format(tostring(source), tostring(plate), tostring(script)))

    if IsDuplicityVersion() then
        -- SERVER
        if script == 'qbx_vehiclekeys' then
            exports.qbx_vehiclekeys:RemoveKeys(source, veh)
        elseif script == 'qb-vehiclekeys' then
            TriggerClientEvent('vehiclekeys:client:RemoveKeys', source, plate)
        elseif script == 'wasabi_carlock' then
            exports.wasabi_carlock:RemoveKey(source, plate)
        elseif script == 'qs-vehiclekeys' then
            exports['qs-vehiclekeys']:RemoveKeys(source, plate)
        elseif script == 'tupani_carlock' then
            exports['tupani_carlock']:RemoveKeys(source, plate)
        end
    else
        -- CLIENT
        if script == 'qb-vehiclekeys' then
            TriggerEvent('vehiclekeys:client:RemoveKeys', plate)
        end
    end
end

return keys
