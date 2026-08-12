-- ──────────────────────────────────────────────────────────────
-- Dank_Utils :: keys.lua  (shared)
-- Provides: Dank.keys.give(source, veh, plate), Dank.keys.remove(source, veh, plate)
-- ──────────────────────────────────────────────────────────────

local keys = {}

local sharedConfig = require 'config.dankutils_shared'

local function getKeysScript()
    return sharedConfig.Keys or 'none'
end

keys.give = function(source, veh, plate)
    if not source or not veh then return end
    
    local script = getKeysScript()

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
        elseif script == 'jg-advancedgarages' then
            TriggerClientEvent('jg-advancedgarages:client:giveKey', source, plate)
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

keys.remove = function(source, veh, plate)
    if not source or not veh then return end
    
    local script = getKeysScript()

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
        end
    else
        -- CLIENT
        if script == 'qb-vehiclekeys' then
            TriggerEvent('vehiclekeys:client:RemoveKeys', plate)
        end
    end
end

return keys
