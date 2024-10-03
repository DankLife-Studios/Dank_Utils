Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Commands = Framework.Commands or {}

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

Framework.ClientNotify = function(message, type)
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
        for item, data in pairs(exports.ox_inventory:Items()) do
            itemNames[item] = data.label
        end
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

Framework.ClientHasItem = function(item, amount)
    if SharedConfig.Framework == 'qbx_core' then
        local count = exports.ox_inventory:Search('count', item)
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

Framework.GetCarData = function(vehicle)
    if SharedConfig.Framework == 'qbx_core' then
        local vehicleData = exports.qbx_core:GetVehiclesByName()[vehicle]
        if not vehicleData then
            return print('You need to add the vehicles to your qbox core shared vehicles')
        end
        return vehicleData
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local vehicleData = QBCore.Shared.Vehicles[vehicle]
        if not vehicleData then
            return print('You need to add the vehicles to your qbcore core shared vehicles')
        end
        return vehicleData
    end
    return print('please let me know how to do this in esx')
end

Framework.ClientFunctions = function()
    if SharedConfig.Framework == 'qbx_core' then
        return exports.qbx_core -- Return the qbx_core export
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions -- Use QBCore.Functions for qb-core
    end
end

if SharedConfig.Framework then
    Framework.Status.Commands = SharedConfig.Framework
    Framework.Status.Framework = SharedConfig.Framework
end

return Framework
