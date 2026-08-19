-- Dank_Utils :: fuel.lua  (shared)
-- Provides: Dank.fuel.set(veh, level), Dank.fuel.get(veh)

---@class DankFuel
local fuel = {}

local sharedConfig = require 'config.dankutils_shared'
local LogDebug = LogDebug or function() end

-- Internal helper: resolve the active fuel script name
---@return string
local function getFuelScript()
    return sharedConfig.Fuel or 'none'
end

-- Dank.fuel.set(veh, level)
-- Sets the fuel level of a vehicle. level is 0.0 – 100.0.
---@param veh integer
---@param level number
fuel.set = function(veh, level)
    if not veh or not DoesEntityExist(veh) then
        LogDebug('[fuel] set: invalid vehicle entity')
        print('^3[Dank_Utils] fuel.set: invalid vehicle entity^0')
        return
    end

    level = math.max(0.0, math.min(100.0, tonumber(level) or 100.0))
    local script = getFuelScript()
    LogDebug(('[fuel] set(level=%s) script=%s side=%s'):format(tostring(level), tostring(script), IsDuplicityVersion() and 'server' or 'client'))

    if IsDuplicityVersion() then
        -- SERVER
        Entity(veh).state.fuel = level
        if script == 'ox_fuel' then
            return
        else
            local owner = NetworkGetEntityOwner(veh)
            local netId = NetworkGetNetworkIdFromEntity(veh)
            if owner and owner > 0 and netId > 0 then
                TriggerClientEvent('Dank_Utils:client:SetFuel', owner, netId, level)
            end
        end
    else
        -- CLIENT
        if script == 'ox_fuel' then
            Entity(veh).state.fuel = level
        elseif script == 'cdn-fuel' then
            exports['cdn-fuel']:SetFuel(veh, level)
        elseif script == 'ti_fuel' then
            TriggerEvent('ti_fuel:setFuel', veh, level)
        elseif script == 'LegacyFuel' then
            exports['LegacyFuel']:SetFuel(veh, level)
        elseif script == 'lj-fuel' then
            exports['lj-fuel']:SetFuel(veh, level)
        elseif script == 'ps-fuel' then
            exports['ps-fuel']:SetFuel(veh, level)
        else
            -- Native fallback (no fuel script detected)
            LogDebug('[fuel] set: native fallback (no fuel script detected)')
            SetVehicleFuelLevel(veh, level)
        end
    end
end

-- Dank.fuel.get(veh)
-- Returns the current fuel level of a vehicle (0.0 – 100.0).
---@param veh integer
---@return number
fuel.get = function(veh)
    if not veh or not DoesEntityExist(veh) then
        LogDebug('[fuel] get: invalid vehicle entity')
        print('^3[Dank_Utils] fuel.get: invalid vehicle entity^0')
        return 0.0
    end

    local script = getFuelScript()
    LogDebug(('[fuel] get script=%s side=%s'):format(tostring(script), IsDuplicityVersion() and 'server' or 'client'))

    if IsDuplicityVersion() then
        -- SERVER
        if script == 'ox_fuel' then
            return tonumber(Entity(veh).state.fuel) or 100.0
        else
            -- Synchronous fuel fetching on server for legacy scripts is unsupported natively
            -- Defaulting to state bags or 100.0
            return tonumber(Entity(veh).state.fuel) or 100.0
        end
    else
        -- CLIENT
        if script == 'ox_fuel' then
            return tonumber(Entity(veh).state.fuel) or GetVehicleFuelLevel(veh)
        elseif script == 'cdn-fuel' then
            return exports['cdn-fuel']:GetFuel(veh)
        elseif script == 'ti_fuel' then
            if DecorExistOn(veh, 'fuel_level') then
                return DecorGetFloat(veh, 'fuel_level')
            end
            return GetVehicleFuelLevel(veh)
        elseif script == 'LegacyFuel' then
            return exports['LegacyFuel']:GetFuel(veh)
        elseif script == 'lj-fuel' then
            return exports['lj-fuel']:GetFuel(veh)
        elseif script == 'ps-fuel' then
            return exports['ps-fuel']:GetFuel(veh)
        else
            LogDebug('[fuel] get: native fallback (no fuel script detected)')
            return GetVehicleFuelLevel(veh)
        end
    end
end

if not IsDuplicityVersion() then
    RegisterNetEvent('Dank_Utils:client:SetFuel', function(netId, level)
        if NetworkDoesNetworkIdExist(netId) then
            local veh = NetToVeh(netId)
            if DoesEntityExist(veh) then
                fuel.set(veh, level)
            end
        end
    end)
end

return fuel
