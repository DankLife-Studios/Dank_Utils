Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Commands = Framework.Commands or {}

local function getCoreObject()
    if SharedConfig.Framework == 'none' then return nil end
    return exports[SharedConfig.Framework]:GetCoreObject()
end

Framework.GetPlayerData = function()
    if SharedConfig.Framework == 'qbx_core' then
        return QBX.PlayerData or {}
    elseif SharedConfig.Framework == 'qb-core' then
        local core = getCoreObject()
        return core and core.Functions.GetPlayerData() or {}
    elseif SharedConfig.Framework == 'es_extended' then
        local esx = exports['es_extended']:getSharedObject()
        return esx and esx.GetPlayerData() or {}
    end
    LogDebug('GetPlayerData: No framework detected.')
    return {}
end

---@diagnostic disable-next-line: duplicate-set-field
Framework.Notify = function(message, type, timeLength)
    local time = timeLength or 5000
    if SharedConfig.Framework == 'qbx_core' then
        exports.qbx_core:Notify(message, type, time)
    elseif SharedConfig.Framework == 'qb-core' then
        local core = getCoreObject()
        if core then core.Functions.Notify(message, type, time) end
    elseif SharedConfig.Framework == 'es_extended' then
        TriggerEvent('esx:showNotification', message, type, time)
    else
        LogDebug('Notify: No framework detected, falling back to chat.')
        TriggerEvent('chat:addMessage', { args = {message} })
    end
end

Framework.GetItemLabel = function(itemName)
    if SharedConfig.Framework == 'qbx_core' then
        local items = exports.ox_inventory:Items()
        return items[itemName] and items[itemName].label or itemName
    elseif SharedConfig.Framework == 'qb-core' then
        local core = getCoreObject()
        return core and core.Shared.Items[itemName] and core.Shared.Items[itemName].label or itemName
    elseif SharedConfig.Framework == 'es_extended' then
        local esx = exports['es_extended']:getSharedObject()
        local items = esx and esx.GetItems()
        return items and items[itemName] and items[itemName].label or itemName
    end
    return itemName
end

Framework.ToggleDuty = function()
    if SharedConfig.Framework == 'qbx_core' or SharedConfig.Framework == 'qb-core' then
        TriggerServerEvent("QBCore:ToggleDuty")
    elseif SharedConfig.Framework == 'es_extended' then
        TriggerServerEvent("esx:toggleDuty")
    end
end

---@diagnostic disable-next-line: duplicate-set-field
Framework.HasItem = function(item, rAmount)
    local amount = rAmount or 1
    if SharedConfig.Framework == 'qbx_core' then
        local count = exports.ox_inventory:Search('count', item)
        return count and count >= amount
    elseif SharedConfig.Framework == 'qb-core' then
        local core = getCoreObject()
        return core and core.Functions.HasItem(item, amount) or false
    elseif SharedConfig.Framework == 'es_extended' then
        local esx = exports['es_extended']:getSharedObject()
        local xPlayer = esx and esx.GetPlayerData()
        local itemData = xPlayer and xPlayer.getInventoryItem(item)
        return itemData and itemData.count >= amount or false
    end
    return false
end

Framework.Progressbar = function(params)
    local framework = SharedConfig.Framework
    local name = params.name or 'progress'
    local label = params.label or 'Action'
    local duration = params.duration or 5000
    local useWhileDead = params.useWhileDead or false
    local canCancel = params.canCancel or false
    local disableControls = params.disableControls or {}
    local animation = params.animation or {}
    local prop = params.prop or {}
    local onFinish = params.onFinish or function() end
    local onCancel = params.onCancel or function() end

    if framework == 'qbx_core' then
        if not lib then LogDebug('Progressbar: ox_lib not found for qbx_core.') return end
        local options = {
            duration = duration,
            label = label,
            useWhileDead = useWhileDead,
            canCancel = canCancel,
            disable = disableControls,
            anim = animation,
            prop = prop,
        }
        if lib.progressBar(options) then onFinish() else onCancel() end
    elseif framework == 'qb-core' then
        local core = getCoreObject()
        if core then
            core.Functions.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, nil, onFinish, onCancel)
        end
    elseif framework == 'es_extended' then
        -- Fallback to a basic implementation if no progress bar event exists
        LogDebug('Progressbar: ESX progress bar not natively supported, using chat fallback.')
        Framework.Notify(label .. ' in progress...', 'info', duration)
        Wait(duration)
        onFinish()
    else
        LogDebug('Progressbar: No framework detected.')
    end
end

Framework.GetCarData = function(vehicle)
    if SharedConfig.Framework == 'qbx_core' then
        local vehicles = exports.qbx_core:GetVehiclesByName()
        return vehicles[vehicle] or nil
    elseif SharedConfig.Framework == 'qb-core' then
        local core = getCoreObject()
        return core and core.Shared.Vehicles[vehicle] or nil
    end
    return nil
end

---@diagnostic disable-next-line: duplicate-set-field
Framework.Functions = function()
    if SharedConfig.Framework == 'qbx_core' then return exports.qbx_core
    elseif SharedConfig.Framework == 'qb-core' then return getCoreObject() and getCoreObject().Functions end
end

---@diagnostic disable-next-line: duplicate-set-field
Framework.SharedItems = function(item)
    if SharedConfig.Framework == 'qbx_core' then
        return exports.ox_inventory:Items()[item]
    elseif SharedConfig.Framework == 'qb-core' then
        local core = getCoreObject()
        return core and core.Shared.Items[item]
    end
end

if SharedConfig.Framework ~= 'none' then
    Framework.Status.Commands = SharedConfig.Framework
    Framework.Status.Framework = SharedConfig.Framework
end

return Framework