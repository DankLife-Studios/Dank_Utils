local TriggerClientEvent = TriggerClientEvent
local TriggerEvent = TriggerEvent
local TriggerServerEvent = TriggerServerEvent
local exports = exports
local print = print
local pairs = pairs
local tostring = tostring
local table = table

local sharedConfig = require 'config.shared'
local inventory = {}
local Dank = Dank or _G.Dank -- Reference the global Dank object if needed

if IsDuplicityVersion() then
    -- SERVER
    local function handleItemNotification(source, item, action, amount)
        if sharedConfig.Framework == 'qb-core' then
            local QBCore = exports['qb-core']:GetCoreObject()
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], action, amount)
        elseif sharedConfig.Framework == 'es_extended' then
            TriggerClientEvent('esx_inventoryhud:' .. action .. 'Item', source, item, amount)
        end
    end

    inventory.addItem = function(source, item, amount)
        local Player = Dank.player.get(source)
        if not Player then return false end
        if sharedConfig.Framework == 'qbx_core' then
            return exports.qbx_core:AddItem(source, item, amount)
        elseif sharedConfig.Framework == 'qb-core' then
            handleItemNotification(source, item, 'add', amount)
            return Player.Functions.AddItem(item, amount)
        elseif sharedConfig.Framework == 'es_extended' then
            handleItemNotification(source, item, 'add', amount)
            Player.addInventoryItem(item, amount)
            return true
        end
        return false
    end

    inventory.removeItem = function(source, item, amount)
        local Player = Dank.player.get(source)
        if not Player then return false end
        if sharedConfig.Framework == 'qbx_core' then
            return exports.qbx_core:RemoveItem(source, item, amount)
        elseif sharedConfig.Framework == 'qb-core' then
            handleItemNotification(source, item, 'remove', amount)
            return Player.Functions.RemoveItem(item, amount)
        elseif sharedConfig.Framework == 'es_extended' then
            handleItemNotification(source, item, 'remove', amount)
            Player.removeInventoryItem(item, amount)
            return true
        end
        return false
    end

    inventory.getItemByName = function(source, item)
        local Player = Dank.player.get(source)
        if not Player then return nil end
        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            return Player.Functions.GetItemByName(item)
        elseif sharedConfig.Framework == 'es_extended' then
            return Player.getInventoryItem(item)
        end
    end

    inventory.createUseableItem = function(item, callback)
        if sharedConfig.Framework == 'qbx_core' then
            exports.qbx_core:CreateUseableItem(item, function(source)
                callback(source, item)
            end)
        elseif sharedConfig.Framework == 'qb-core' then
            local QBCore = exports['qb-core']:GetCoreObject()
            QBCore.Functions.CreateUseableItem(item, function(source, itemData)
                callback(source, itemData.name)
            end)
        elseif sharedConfig.Framework == 'es_extended' then
            local ESX = exports['es_extended']:getSharedObject()
            ESX.RegisterUsableItem(item, function(source)
                callback(source, item)
            end)
        end
    end

    inventory.hasItem = function(source, item, amount)
        local Player = Dank.player.get(source)
        if not Player then return false end
        if sharedConfig.Framework == 'qbx_core' then
            if sharedConfig.Inventory == 'ox_inventory' then
                local count = exports.ox_inventory:Search(source, 'count', item) or 0
                return count >= amount
            end
            return Player.Functions.HasItem(item, amount)
        elseif sharedConfig.Framework == 'qb-core' then
            return Player.Functions.HasItem(item, amount)
        elseif sharedConfig.Framework == 'es_extended' then
            local itemData = Player.getInventoryItem(item)
            return itemData and itemData.count >= amount
        end
        return false
    end
else
    -- CLIENT
    inventory.openStash = function(stashName, maxweight, slots)
        if sharedConfig.Inventory == 'qb-inventory' then
            local data = { label = stashName, maxweight = maxweight, slots = slots }
            TriggerServerEvent('inventory:server:OpenInventory', 'stash', stashName, data)
            TriggerEvent('inventory:client:SetCurrentStash', stashName)
        elseif sharedConfig.Inventory == 'ps-inventory' then
            TriggerEvent('ps-inventory:client:SetCurrentStash', stashName)
            TriggerServerEvent('ps-inventory:server:OpenInventory', 'stash', stashName, {
                maxweight = maxweight,
                slots = slots,
            })
        elseif sharedConfig.Inventory == 'ox_inventory' then
            exports.ox_inventory:openInventory('stash', { id = stashName })
        elseif sharedConfig.Inventory == 'qs-inventory' then
            local other = { maxweight = maxweight, slots = slots }
            TriggerServerEvent("inventory:server:OpenInventory", "stash", stashName, other)
            TriggerEvent("inventory:client:SetCurrentStash", stashName)
        elseif sharedConfig.Inventory == 'esx_inventory' then
            TriggerServerEvent('esx_inventory:server:OpenStash', stashName, {
                maxweight = maxweight,
                slots = slots
            })
        elseif sharedConfig.Inventory == 'core_inventory' then
            TriggerServerEvent('core_inventory:server:openInventory', stashName, 'stash')
        elseif sharedConfig.Inventory == 'chezza-inventory' then
            TriggerEvent('inventory:openInventory', { type = 'stash', id = stashName })
        elseif sharedConfig.Inventory == 'codem-inventory' then
            TriggerServerEvent('codem-inventory:server:openStash', stashName)
        else
            print('^3[Dank_Utils] Unsupported inventory for OpenStash: ' .. tostring(sharedConfig.Inventory) .. '^0')
        end
    end

    inventory.getImageUrl = function()
        if sharedConfig.Inventory == 'qb-inventory' then
            return 'https://cfx-nui-qb-inventory/html/images/'
        elseif sharedConfig.Inventory == 'ps-inventory' then
            return 'https://cfx-nui-ps-inventory/html/images/'
        elseif sharedConfig.Inventory == 'ox_inventory' then
            return 'https://cfx-nui-ox_inventory/web/images/'
        elseif sharedConfig.Inventory == 'qs-inventory' then
            return 'https://cfx-nui-qs-inventory/html/images/'
        elseif sharedConfig.Inventory == 'esx_inventory' then
            return ''
        elseif sharedConfig.Inventory == 'core_inventory' then
            return 'https://cfx-nui-core_inventory/html/img/'
        elseif sharedConfig.Inventory == 'chezza-inventory' then
            return 'https://cfx-nui-inventory/html/images/'
        elseif sharedConfig.Inventory == 'codem-inventory' then
            return 'https://cfx-nui-codem-inventory/html/images/'
        else
            print('^3[Dank_Utils] Unsupported inventory for GetImageUrl: ' .. tostring(sharedConfig.Inventory) .. '^0')
            return ''
        end
    end

    inventory.hasItem = function(item, rAmount)
        local amount = rAmount or 1
        if sharedConfig.Framework == 'qbx_core' then
            local count = exports.ox_inventory:Search('count', item)
            return count and count >= amount
        elseif sharedConfig.Framework == 'qb-core' then
            local core = exports['qb-core']:GetCoreObject()
            return core and core.Functions.HasItem(item, amount) or false
        elseif sharedConfig.Framework == 'es_extended' then
            if sharedConfig.Inventory == 'ox_inventory' then
                local count = exports.ox_inventory:Search('count', item) or 0
                return count >= amount
            end
            local esx = exports['es_extended']:getSharedObject()
            local playerData = esx and esx.GetPlayerData() or {}
            for _, invItem in pairs(playerData.inventory or {}) do
                if invItem.name == item and (invItem.count or invItem.amount or 0) >= amount then
                    return true
                end
            end
            return false
        end
        return false
    end

    inventory.hasItems = function(requiredItems)
        local missingItems = {}
        if sharedConfig.Inventory == 'qs-inventory' then
            local items = exports['qs-inventory']:getUserInventory()
            for item, requiredAmount in pairs(requiredItems) do
                local found = false
                for _, invItem in pairs(items) do
                    if invItem.name == item and invItem.amount >= requiredAmount then
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(missingItems, {item = item, missingAmount = requiredAmount})
                end
            end
        elseif sharedConfig.Inventory == 'ps-inventory' or sharedConfig.Inventory == 'qb-inventory' or sharedConfig.Inventory == 'qb-old-inventory' then
            for item, requiredAmount in pairs(requiredItems) do
                if not inventory.hasItem(item, requiredAmount) then
                    table.insert(missingItems, {item = item, missingAmount = requiredAmount})
                end
            end
        elseif sharedConfig.Inventory == 'ox_inventory' then
            for item, requiredAmount in pairs(requiredItems) do
                local count = exports.ox_inventory:Search('count', item)
                if count < requiredAmount then
                    table.insert(missingItems, {item = item, missingAmount = requiredAmount - count})
                end
            end
        else
            print('^3[Dank_Utils] Unsupported inventory for HasItems: ' .. tostring(sharedConfig.Inventory) .. '^0')
            return false, {{item = 'unknown', missingAmount = 1}}
        end

        if #missingItems == 0 then
            return true, nil
        else
            return false, missingItems
        end
    end

    inventory.getItemLabel = function(itemName)
        if sharedConfig.Framework == 'qbx_core' then
            local items = exports.ox_inventory:Items()
            return items[itemName] and items[itemName].label or itemName
        elseif sharedConfig.Framework == 'qb-core' then
            local core = exports['qb-core']:GetCoreObject()
            return core and core.Shared.Items[itemName] and core.Shared.Items[itemName].label or itemName
        elseif sharedConfig.Framework == 'es_extended' then
            local esx = exports['es_extended']:getSharedObject()
            local items = esx and esx.GetItems()
            return items and items[itemName] and items[itemName].label or itemName
        end
        return itemName
    end
end

-- Shared
inventory.sharedItems = function(item)
    if sharedConfig.Framework == 'qbx_core' then
        return exports.ox_inventory:Items()[item]
    elseif sharedConfig.Framework == 'qb-core' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore and QBCore.Shared.Items[item]
    elseif sharedConfig.Framework == 'es_extended' then
        local ESX = exports['es_extended']:getSharedObject()
        local items = ESX and ESX.GetItems and ESX.GetItems()
        return items and items[item]
    end
end

return inventory
