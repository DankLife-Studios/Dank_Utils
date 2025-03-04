Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Commands = Framework.Commands or {}

Framework.GetPlayer = function(source)
    if SharedConfig.Framework == 'qbx_core' then
        return exports.qbx_core:GetPlayer(source)
    elseif SharedConfig.Framework == 'qb-core' then
        return exports['qb-core']:GetCoreObject().Functions.GetPlayer(source)
    elseif SharedConfig.Framework == 'es_extended' then
        return exports['es_extended']:getSharedObject().GetPlayerFromId(source)
    end
end

Framework.GetAllPlayers = function()
    if SharedConfig.Framework == 'qbx_core' then
        return exports.qbx_core:GetQBPlayers() or {}
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore and QBCore.Functions.GetQBPlayers() or {}
    elseif SharedConfig.Framework == 'es_extended' then
        local ESX = exports['es_extended']:getSharedObject()
        return ESX and ESX.GetPlayers() or {}
    end
    return {}
end

Framework.GetPlayerByCitizenId = function(citizenid)
    if SharedConfig.Framework == 'qbx_core' then
        return exports.qbx_core:GetPlayerByCitizenId(citizenid)
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore and QBCore.Functions.GetPlayerByCitizenId(citizenid)
    elseif SharedConfig.Framework == 'es_extended' then
        LogDebug('GetPlayerByCitizenId not natively supported for ESX.')
        return nil
    end
end

local function handleItemNotification(source, item, action, amount)
    if SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], action, amount)
    elseif SharedConfig.Framework == 'es_extended' then
        TriggerClientEvent('esx_inventoryhud:' .. action .. 'Item', source, item, amount)
    end
end

Framework.AddItem = function(source, item, amount)
    local Player = Framework.GetPlayer(source)
    if not Player then return false end
    if SharedConfig.Framework == 'qbx_core' then
        return exports.qbx_core:AddItem(source, item, amount)
    elseif SharedConfig.Framework == 'qb-core' then
        handleItemNotification(source, item, 'add', amount)
        return Player.Functions.AddItem(item, amount)
    elseif SharedConfig.Framework == 'es_extended' then
        handleItemNotification(source, item, 'add', amount)
        Player.addInventoryItem(item, amount)
        return true
    end
    return false
end

Framework.RemoveItem = function(source, item, amount)
    local Player = Framework.GetPlayer(source)
    if not Player then return false end
    if SharedConfig.Framework == 'qbx_core' then
        return exports.qbx_core:RemoveItem(source, item, amount)
    elseif SharedConfig.Framework == 'qb-core' then
        handleItemNotification(source, item, 'remove', amount)
        return Player.Functions.RemoveItem(item, amount)
    elseif SharedConfig.Framework == 'es_extended' then
        handleItemNotification(source, item, 'remove', amount)
        Player.removeInventoryItem(item, amount)
        return true
    end
    return false
end

Framework.AddMoney = function(source, moneyType, payment, message)
    local Player = Framework.GetPlayer(source)
    if not Player then return false end
    if SharedConfig.Framework == 'qbx_core' or SharedConfig.Framework == 'qb-core' then
        return Player.Functions.AddMoney(moneyType, payment, message)
    elseif SharedConfig.Framework == 'es_extended' then
        Player.addAccountMoney(moneyType, payment)
        return true
    end
    return false
end

Framework.RemoveMoney = function(source, moneyType, payment, message)
    local Player = Framework.GetPlayer(source)
    if not Player then return false end
    if SharedConfig.Framework == 'qbx_core' or SharedConfig.Framework == 'qb-core' then
        return Player.Functions.RemoveMoney(moneyType, payment, message)
    elseif SharedConfig.Framework == 'es_extended' then
        Player.removeAccountMoney(moneyType, payment)
        return true
    end
    return false
end

---@diagnostic disable-next-line: duplicate-set-field
Framework.Notify = function(source, message, messageType, timeLength)
    local time = timeLength or 5000
    if SharedConfig.Framework == 'qbx_core' then
        exports.qbx_core:Notify(source, message, messageType, time)
    elseif SharedConfig.Framework == 'qb-core' then
        TriggerClientEvent('QBCore:Notify', source, message, messageType, time)
    elseif SharedConfig.Framework == 'es_extended' then
        TriggerClientEvent('esx:showNotification', source, message, messageType, time)
    else
        TriggerClientEvent('chat:addMessage', source, { args = {message} })
    end
end

Framework.GetCoreJob = function(jobname)
    if SharedConfig.Framework == 'qbx_core' then
        return exports.qbx_core:GetJob(jobname)
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore and QBCore.Shared.Jobs[jobname]
    elseif SharedConfig.Framework == 'es_extended' then
        local ESX = exports['es_extended']:getSharedObject()
        return ESX and ESX.Jobs[jobname]
    end
end

Framework.GetAllJob = function()
    if SharedConfig.Framework == 'qbx_core' then
        return exports.qbx_core:GetJobs() or {}
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore and QBCore.Shared.Jobs or {}
    elseif SharedConfig.Framework == 'es_extended' then
        local ESX = exports['es_extended']:getSharedObject()
        return ESX and ESX.Jobs or {}
    end
    return {}
end

Framework.GetItemByName = function(source, item)
    local Player = Framework.GetPlayer(source)
    if not Player then return nil end
    if SharedConfig.Framework == 'qbx_core' or SharedConfig.Framework == 'qb-core' then
        return Player.Functions.GetItemByName(item)
    elseif SharedConfig.Framework == 'es_extended' then
        return Player.getInventoryItem(item)
    end
end

Framework.CreateUseableItem = function(item, callback)
    if SharedConfig.Framework == 'qbx_core' then
        exports.qbx_core:CreateUseableItem(item, function(source)
            callback(source, item)
        end)
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.CreateUseableItem(item, function(source, itemData)
            callback(source, itemData.name)
        end)
    elseif SharedConfig.Framework == 'es_extended' then
        local ESX = exports['es_extended']:getSharedObject()
        ESX.RegisterUsableItem(item, function(source)
            callback(source, item)
        end)
    end
end

---@diagnostic disable-next-line: duplicate-set-field
Framework.HasItem = function(source, item, amount)
    local Player = Framework.GetPlayer(source)
    if not Player then return false end
    if SharedConfig.Framework == 'qbx_core' then
        local inventory = exports.ox_inventory:GetInventory(source)
        return inventory and inventory[item] and inventory[item].count >= amount
    elseif SharedConfig.Framework == 'qb-core' then
        return Player.Functions.HasItem(item, amount)
    elseif SharedConfig.Framework == 'es_extended' then
        local itemData = Player.getInventoryItem(item)
        return itemData and itemData.count >= amount
    end
    return false
end

Framework.Commands.Add = function(name, description, args, restricted, callback, group)
    if SharedConfig.Framework == 'qbx_core' then
        if not lib then return end
        lib.addCommand(name, { help = description, params = args, permission = group or "user" }, callback)
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Commands.Add(name, description, args, restricted, callback, group)
    elseif SharedConfig.Framework == 'es_extended' then
        local ESX = exports['es_extended']:getSharedObject()
        ESX.RegisterCommand(name, group or 'user', callback, restricted, {help = description})
    end
    if SharedConfig.Framework ~= 'none' then
        Framework.Status.Commands = SharedConfig.Framework
    end
end

---@diagnostic disable-next-line: duplicate-set-field
Framework.Functions = function()
    if SharedConfig.Framework == 'qbx_core' then return exports.qbx_core
    elseif SharedConfig.Framework == 'qb-core' then return exports['qb-core']:GetCoreObject().Functions end
end

---@diagnostic disable-next-line: duplicate-set-field
Framework.SharedItems = function(item)
    if SharedConfig.Framework == 'qbx_core' then
        return exports.ox_inventory:Items()[item]
    elseif SharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore and QBCore.Shared.Items[item]
    end
end

if SharedConfig.Framework ~= 'none' then
    Framework.Status.Commands = SharedConfig.Framework
    Framework.Status.Framework = SharedConfig.Framework
end

return Framework