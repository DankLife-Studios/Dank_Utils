Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Commands = Framework.Commands or {}

local callbacks = {}

Framework.CreateCallback = function(name, cb)
    callbacks[name] = cb
end

RegisterServerEvent('Dank_Utils:ClientRequest')
AddEventHandler('Dank_Utils:ClientRequest', function(name, requestId, ...)
    local src = source
    if callbacks[name] then
        local result = callbacks[name](src, ...)
        TriggerClientEvent('Dank_Utils:ClientResponse', src, requestId, result)
    else
        TriggerClientEvent('Dank_Utils:ClientResponse', src, requestId, nil, "Unknown callback")
    end
end)

Framework.GetPlayer = function(source)
    if SharedConfig.Framework == 'qbx_core' then
        return exports.qbx_core:GetPlayer(source)
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions.GetPlayer(source)
    elseif SharedConfig.Framework == 'es_extended' then
        local ESX = exports['es_extended']:getSharedObject()
        return ESX.GetPlayerFromId(source)
    end
end

Framework.GetAllPlayers = function()
    if SharedConfig.Framework == 'qbx_core' then
        return exports.qbx_core:GetQBPlayers()
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions.GetQBPlayers()
    elseif SharedConfig.Framework == 'es_extended' then
        local ESX = exports['es_extended']:getSharedObject()
        return ESX.GetPlayers()
    end
end

Framework.AddItem = function(source, item, amount)
    if SharedConfig.Framework == 'qbx_core' then
        exports.qbx_core:AddItem(item, amount)
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'add')
        QBCore.Functions.AddItem(item, amount)
    elseif SharedConfig.Framework == 'es_extended' then
        local ESX = exports['es_extended']:getSharedObject()
        local Player = Framework.GetPlayer(source)
        if not Player then return end
        TriggerClientEvent('esx_inventoryhud:removeItem', source, ESX.GetItems()[item], amount)
        Player.addInventoryItem(item, amount)
    end
end

Framework.RemoveItem = function(source, item, amount)
    if SharedConfig.Framework == 'qbx_core' then
        exports.qbx_core:RemoveItem(item, amount)
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'remove')
        QBCore.Functions.RemoveItem(item, amount)
    elseif SharedConfig.Framework == 'es_extended' then
        local ESX = exports['es_extended']:getSharedObject()
        local Player = Framework.GetPlayer(source)
        if not Player then return end
        TriggerClientEvent('esx_inventoryhud:removeItem', source, ESX.GetItems()[item], amount)
        Player.removeInventoryItem(item, amount)
    end
end

Framework.AddMoney = function(source, moneyType, payment, message)
    if SharedConfig.Framework == 'qbx_core' or SharedConfig.Framework == 'qb-core' then
        local Player = Framework.GetPlayer(source)
        if not Player then return end
        Player.Functions.AddMoney(moneyType, payment, message)
    elseif SharedConfig.Framework == 'es_extended' then
        local Player = Framework.GetPlayer(source)
        if not Player then return end
        Player.addAccountMoney(moneyType, payment)
    end
end

Framework.RemoveMoney = function(source, moneyType, payment, message)
    if SharedConfig.Framework == 'qbx_core' or SharedConfig.Framework == 'qb-core' then
        local Player = Framework.GetPlayer(source)
        if not Player then return end
        Player.Functions.RemoveMoney(moneyType, payment, message)
    elseif SharedConfig.Framework == 'es_extended' then
        local Player = Framework.GetPlayer(source)
        if not Player then return end
        Player.removeAccountMoney(moneyType, payment)
    end
end

Framework.ClientNotify = function(source, message, messageType)
    if SharedConfig.Framework == 'qbx_core' then
        exports.qbx_core:Notify(source, message, messageType)
    elseif SharedConfig.Framework == 'qb-core' then
        TriggerClientEvent('QBCore:Notify', source, message, messageType)
    elseif SharedConfig.Framework == 'es_extended' then
        TriggerClientEvent('esx:showNotification', source, message, messageType)
    end
end

Framework.GetAllJobs = function()
    if SharedConfig.Framework == 'qbx_core' then
        return exports.qbx_core:GetJobs()
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Shared.Jobs
    elseif SharedConfig.Framework == 'es_extended' then
        local ESX = exports['es_extended']:getSharedObject()
        return ESX.Jobs
    end
end

Framework.GetItemByName = function(source, item)
    if SharedConfig.Framework == 'qbx_core' or SharedConfig.Framework == 'qb-core' then
        local Player = Framework.GetPlayer(source)
        if not Player then return end
        return Player.Functions.GetItemByName(item)
    elseif SharedConfig.Framework == 'es_extended' then
        local Player = Framework.GetPlayer(source)
        if not Player then return end
        return Player.getInventoryItem(item)
    end
end

Framework.CreateUseableItem = function(item, callback)
    if SharedConfig.Framework == 'qbx_core' then
        exports.qbx_core:CreateUseableItem(item, function(source)
            callback(source)
        end)
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.CreateUseableItem(item, function(source)
            callback(source)
        end)
    elseif SharedConfig.Framework == 'es_extended' then
        local ESX = exports['es_extended']:getSharedObject()
        ESX.RegisterUsableItem(item, function(source)
            callback(source)
        end)
    end
end

Framework.ClientHasItem = function(source, item, amount)
    if SharedConfig.Framework == 'qbx_core' then
        local inventory = exports.ox_inventory:GetInventory(source)
        if inventory and inventory[item] and inventory[item].count >= amount then
            return true
        end
        return false
    elseif SharedConfig.Framework == 'qb-core' then
        local Player = Framework.GetPlayer(source)
        if Player then
            return Player.Functions.HasItem(item, amount)
        else
            return false
        end
    elseif SharedConfig.Framework == 'es_extended' then
        local xPlayer = Framework.GetPlayer(source)
        if xPlayer then
            return xPlayer.getInventoryItem(item).count >= amount
        else
            return false
        end
    end
end

Framework.Commands.Add = function(name, description, args, restricted, callback, group)
    if SharedConfig.Framework == 'qbx_core' then
        lib.addCommand(name, {
            help = description,
            params = args,
            permission = group or "user",
        }, function(source, args)
            callback(source, args)
        end)
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Commands.Add(name, description, args, restricted, function(source, _)
            callback(source, _)
        end, group)
    elseif SharedConfig.Framework == 'es_extended' then
        local ESX = exports['es_extended']:getSharedObject()
        ESX.RegisterCommand(name, restricted or {}, function(source, args, user)
            callback(source, args)
        end, {help = description, args = args, group = group or 'user'})
    end
    if not SharedConfig.Framework == 'none' then
        Framework.Status.Commands = SharedConfig.Framework
    end
end


if not SharedConfig.Framework == 'none' then
    Framework.Status.Commands = SharedConfig.Framework
    Framework.Status.Framework = SharedConfig.Framework
end

return Framework