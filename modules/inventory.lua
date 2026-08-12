local TriggerClientEvent = TriggerClientEvent
local TriggerEvent = TriggerEvent
local TriggerServerEvent = TriggerServerEvent
local exports = exports
local print = print
local pairs = pairs
local tostring = tostring
local table = table

local sharedConfig = require 'config.dankutils_shared'
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
        if sharedConfig.Inventory == 'ox_inventory' then
            return exports.ox_inventory:AddItem(source, item, amount)
        elseif sharedConfig.Framework == 'qbx_core' then
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
        if sharedConfig.Inventory == 'ox_inventory' then
            return exports.ox_inventory:RemoveItem(source, item, amount)
        elseif sharedConfig.Framework == 'qbx_core' then
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
        if sharedConfig.Inventory == 'ox_inventory' then
            exports(item, function(event, itemData, inv, slot, data)
                if event == 'usingItem' then
                    return callback(inv.id, itemData, 'usingItem')
                elseif event == 'usedItem' then
                    return callback(inv.id, itemData, 'usedItem')
                end
            end)
        elseif sharedConfig.Framework == 'qbx_core' then
            exports.qbx_core:CreateUseableItem(item, function(source, itemData)
                callback(source, itemData)
            end)
        elseif sharedConfig.Framework == 'qb-core' then
            local QBCore = exports['qb-core']:GetCoreObject()
            QBCore.Functions.CreateUseableItem(item, function(source, itemData)
                callback(source, itemData)
            end)
        elseif sharedConfig.Framework == 'es_extended' then
            local ESX = exports['es_extended']:getSharedObject()
            ESX.RegisterUsableItem(item, function(source, itemData)
                callback(source, itemData)
            end)
        end
    end

    inventory.canCarryItem = function(source, item, amount)
        if sharedConfig.Inventory == 'ox_inventory' then
            return exports.ox_inventory:CanCarryItem(source, item, amount)
        elseif sharedConfig.Framework == 'qbx_core' then
            return exports.qbx_core:CanCarryItem(source, item, amount)
        elseif sharedConfig.Framework == 'qb-core' then
            local QBCore = exports['qb-core']:GetCoreObject()
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player then return false end
            
            local itemData = QBCore.Shared.Items[item:lower()]
            if not itemData then return false end
            
            local currentTotalWeight = 0
            for _, iData in pairs(Player.PlayerData.items) do
                currentTotalWeight = currentTotalWeight + (iData.weight * iData.amount)
            end
            
            local itemWeight = itemData.weight * amount
            local maxWeight = QBCore.Config.Player.MaxWeight
            
            return (currentTotalWeight + itemWeight) <= maxWeight
        elseif sharedConfig.Framework == 'es_extended' then
            local Player = Dank.player.get(source)
            if not Player then return false end
            return Player.canCarryItem(item, amount)
        end
        return true
    end


    inventory.getItemsByName = function(source, item)
        if sharedConfig.Inventory == 'ox_inventory' then
            return exports.ox_inventory:Search(source, 'slots', item) or {}
        elseif sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            local core = sharedConfig.Framework == 'qbx_core' and exports.qbx_core:GetCoreObject() or exports['qb-core']:GetCoreObject()
            local ply = core.Functions.GetPlayer(source)
            if not ply then return {} end
            local items = {}
            for _, invItem in pairs(ply.PlayerData.items or {}) do
                if invItem.name == item then
                    table.insert(items, invItem)
                end
            end
            return items
        elseif sharedConfig.Framework == 'es_extended' then
            local esx = exports['es_extended']:getSharedObject()
            local ply = esx.GetPlayerFromId(source)
            if not ply then return {} end
            local items = {}
            for _, invItem in pairs(ply.getInventory(false) or {}) do
                if invItem.name == item then
                    table.insert(items, invItem)
                end
            end
            return items
        end
        return {}
    end

    inventory.getItemCount = function(source, item)
        if sharedConfig.Inventory == 'ox_inventory' then
            return exports.ox_inventory:Search(source, 'count', item) or 0
        elseif sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            local core = sharedConfig.Framework == 'qbx_core' and exports.qbx_core:GetCoreObject() or exports['qb-core']:GetCoreObject()
            local ply = core.Functions.GetPlayer(source)
            if not ply then return 0 end
            local count = 0
            for _, invItem in pairs(ply.PlayerData.items or {}) do
                if invItem.name == item then
                    count = count + (invItem.amount or invItem.count or 0)
                end
            end
            return count
        elseif sharedConfig.Framework == 'es_extended' then
            local esx = exports['es_extended']:getSharedObject()
            local ply = esx.GetPlayerFromId(source)
            if not ply then return 0 end
            local count = 0
            for _, invItem in pairs(ply.getInventory(false) or {}) do
                if invItem.name == item then
                    count = count + (invItem.count or invItem.amount or 0)
                end
            end
            return count
        end
        return 0
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

    inventory.getStashItems = function(stashId)
        if sharedConfig.Inventory == 'ox_inventory' then
            return exports.ox_inventory:GetInventoryItems(stashId) or {}
        elseif sharedConfig.Inventory == 'qb-inventory' or sharedConfig.Inventory == 'ps-inventory' or sharedConfig.Inventory == 'qs-inventory' then
            -- Note: QBCore/PS/QS typically fetch stash from DB if not loaded. This is a simplified wrapper.
            if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
                local result = MySQL.Sync.fetchAll('SELECT items FROM stashitems WHERE stash = ?', {stashId})
                if result[1] ~= nil then
                    return json.decode(result[1].items) or {}
                end
            end
            return {}
        end
        return {}
    end

    inventory.registerStash = function(id, label, slots, weight, owner, groups)
        if sharedConfig.Inventory == 'ox_inventory' then
            exports.ox_inventory:RegisterStash(id, label, slots, weight, owner, groups)
        elseif sharedConfig.Inventory == 'qs-inventory' then
            exports['qs-inventory']:RegisterStash(source, id, slots, weight)
        end
    end

    inventory.registerShop = function(name, label, items, locations, groups)
        if sharedConfig.Inventory == 'ox_inventory' then
            exports.ox_inventory:RegisterShop(name, {
                name = label,
                inventory = items,
                locations = locations,
                groups = groups,
            })
        end
    end

    inventory.customDrop = function(id, items, coords)
        if sharedConfig.Inventory == 'ox_inventory' then
            exports.ox_inventory:CustomDrop(id, items, coords)
        end
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
        local inv = sharedConfig.Inventory
        if inv == 'qb-inventory' then
            return 'nui://qb-inventory/html/images/'
        elseif inv == 'ps-inventory' then
            return 'nui://ps-inventory/html/images/'
        elseif inv == 'ox_inventory' then
            return 'nui://ox_inventory/web/images/'
        elseif inv == 'qs-inventory' then
            return 'nui://qs-inventory/html/images/'
        elseif inv == 'core_inventory' then
            return 'nui://core_inventory/html/img/'
        elseif inv == 'chezza-inventory' then
            return 'nui://inventory/html/images/'
        elseif inv == 'codem-inventory' then
            return 'nui://codem-inventory/html/images/'
        end

        -- Automatic fallback check if sharedConfig.Inventory is 'none' or nil
        if GetResourceState('ox_inventory') == 'started' or GetResourceState('ox_inventory') == 'starting' then
            return 'nui://ox_inventory/web/images/'
        elseif GetResourceState('qb-inventory') == 'started' or GetResourceState('qb-inventory') == 'starting' then
            return 'nui://qb-inventory/html/images/'
        elseif GetResourceState('ps-inventory') == 'started' or GetResourceState('ps-inventory') == 'starting' then
            return 'nui://ps-inventory/html/images/'
        elseif GetResourceState('qs-inventory') == 'started' or GetResourceState('qs-inventory') == 'starting' then
            return 'nui://qs-inventory/html/images/'
        end

        LogDebug('[Dank_Utils] GetImageUrl fallback applied for: ' .. tostring(inv))
        return 'nui://ox_inventory/web/images/'
    end

    inventory.getItemCount = function(arg1, arg2)
        local item = (type(arg1) == 'string' and arg1) or (type(arg2) == 'string' and arg2)
        if not item then return 0 end
        if sharedConfig.Inventory == 'ox_inventory' or sharedConfig.Framework == 'qbx_core' then
            local count = exports.ox_inventory:Search('count', item)
            return count or 0
        elseif sharedConfig.Framework == 'qb-core' then
            local core = exports['qb-core']:GetCoreObject()
            local plyData = core and core.Functions.GetPlayerData()
            if not plyData then return 0 end
            local count = 0
            for _, invItem in pairs(plyData.items or {}) do
                if invItem and invItem.name == item then
                    count = count + (invItem.amount or invItem.count or 0)
                end
            end
            return count
        elseif sharedConfig.Framework == 'es_extended' then
            if sharedConfig.Inventory == 'ox_inventory' then
                local count = exports.ox_inventory:Search('count', item)
                return count or 0
            end
            local esx = exports['es_extended']:getSharedObject()
            local playerData = esx and esx.GetPlayerData() or {}
            for _, invItem in pairs(playerData.inventory or {}) do
                if invItem and invItem.name == item then
                    return invItem.count or invItem.amount or 0
                end
            end
        end
        return 0
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
