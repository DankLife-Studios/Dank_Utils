Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Commands = Framework.Commands or {}

local pendingCallbacks = {}

Framework.TriggerServerCallback = function(name, cb, ...)
    local requestId = "CB_" .. math.random(100000, 999999)
    pendingCallbacks[requestId] = cb
    TriggerServerEvent('Dank_Utils:ClientRequest', name, requestId, ...)
end

RegisterNetEvent('Dank_Utils:ClientResponse')
AddEventHandler('Dank_Utils:ClientResponse', function(requestId, ...)
    local cb = pendingCallbacks[requestId]
    if cb then
        cb(...)
        pendingCallbacks[requestId] = nil
    end
end)

local ox_inventory = exports.ox_inventory

Framework.GetPlayerData = function()
    if SharedConfig.Framework == 'qbx_core' then
        return QBX.PlayerData
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions.GetPlayerData()
    elseif SharedConfig.Framework == 'es_extended' then
        local ESX = exports['es_extended']:getSharedObject()
        return ESX.GetPlayerData()
    end
end

Framework.GetPlayerByCitizenId = function(citizenid)
    if SharedConfig.Framework == 'qbx_core' then
        return exports.qbx_core:GetPlayerByCitizenId(citizenid)
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions.GetPlayerByCitizenId(citizenid)
    elseif SharedConfig.Framework == 'es_extended' then
        local ESX = exports['es_extended']:getSharedObject()
        return ESX.GetPlayerFromIdentifier(citizenid)
    end
end

Framework.ServerNotify = function(message, type)
    if SharedConfig.Framework == 'qbx_core' then
        exports.qbx_core:Notify(message, type)
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.Notify(message, type)
    elseif SharedConfig.Framework == 'es_extended' then
        TriggerEvent('esx:showNotification', message)
    end
end

Framework.GetItemLabel = function(itemName)
    if SharedConfig.Framework == 'qbx_core' then
        local itemNames = {}

        -- Retrieve all items and their labels from ox_inventory
        for item, data in pairs(ox_inventory:Items()) do
            itemNames[item] = data.label
        end

        -- Check if the item exists and has a label
        if itemNames[itemName] then
            return itemNames[itemName]
        else
            return NetworkPlayerIsRockstarDev
        end
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local item = QBCore.Shared.Items[itemName]
        if item and item.label then
            return item.label
        else
            return nil
        end
    elseif SharedConfig.Framework == 'es_extended' then
        local ESX = exports['es_extended']:getSharedObject()
        local item = ESX.GetItems()[itemName]
        if item and item.label then
            return item.label
        else
            return nil
        end
    end
end

Framework.ToggleDuty = function()
    if SharedConfig.Framework == 'qbx_core' then
        TriggerServerEvent("QBCore:ToggleDuty")
    elseif SharedConfig.Framework == 'qb-core' then
        TriggerServerEvent("QBCore:ToggleDuty")
    elseif SharedConfig.Framework == 'es_extended' then
        TriggerServerEvent("esx:toggleDuty")
    end
end

Framework.ServerHasItem = function(item, amount)
    if SharedConfig.Framework == 'qbx_core' then
        local count = ox_inventory:Search('count', item)
        return count >= amount
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions.HasItem(item, amount)
    elseif SharedConfig.Framework == 'es_extended' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerData()
        local count = xPlayer.getInventoryItem(item).count
        return count >= amount
    end
end

Framework.Progressbar = function(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    if SharedConfig.Framework == 'qbx_core' then
        local options = {
            duration = duration,
            label = label,
            useWhileDead = useWhileDead or false,
            canCancel = canCancel or false,
            disable = {
                move = disableControls.disableMovement,
                car = disableControls.disableCarMovement,
                combat = disableControls.disableCombat,
                mouse = disableControls.disableMouse,
            },
            anim = {
                dict = animation.animDict,
                clip = animation.anim,
                flag = animation.flags,
                -- Add other animation options if needed, default values can be set here or left out if ox_lib provides defaults
            },
            prop = prop, -- Assuming prop structure matches ox_lib's expectations
            -- If you need propTwo, you might need to handle it differently or adjust ox_lib's expectations
        }

        -- Call the progress bar and handle the result
        if lib.progressBar(options) then
            onFinish() -- Success callback
        else
            onCancel() -- Cancellation callback
        end
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.Progressbar(name, label, duration, useWhileDead, canCancel, {
            disableMovement = disableControls.disableMovement,
            disableCarMovement = disableControls.disableCarMovement,
            disableMouse = disableControls.disableMouse,
            disableCombat = disableControls.disableCombat,
        }, animation, prop, propTwo, onFinish, onCancel)
    elseif SharedConfig.Framework == 'es_extended' then
        TriggerEvent('esx_progressbar:start', {
            name = name,
            label = label,
            duration = duration,
            useWhileDead = useWhileDead or false,
            canCancel = canCancel or false,
            disableControls = disableControls,
            animation = animation,
            prop = prop,
            propTwo = propTwo,
            onFinish = onFinish,
            onCancel = onCancel
        })
    end
end

if not SharedConfig.Framework == 'none' then
    Framework.Status.Commands = SharedConfig.Framework
    Framework.Status.Framework = SharedConfig.Framework
end

return Framework
