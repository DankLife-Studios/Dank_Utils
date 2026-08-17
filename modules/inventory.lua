local TriggerClientEvent = TriggerClientEvent
local TriggerEvent = TriggerEvent
local TriggerServerEvent = TriggerServerEvent
local exports = exports
local print = print
local pairs = pairs
local tostring = tostring
local table = table

local sharedConfig = require 'config.dankutils_shared'
local LogDebug = LogDebug

---@class DankInventory
local inventory = {}
---@type Dank
local Dank = Dank or _G.Dank -- Reference the global Dank object if needed

if IsDuplicityVersion() then
    -- SERVER
    ---@param source integer
    ---@param item string
    ---@param action string
    ---@param amount number
    local function handleItemNotification(source, item, action, amount)
        if sharedConfig.Framework == 'qb-core' then
            local QBCore = exports['qb-core']:GetCoreObject()
            TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], action, amount)
        elseif sharedConfig.Framework == 'es_extended' then
            TriggerClientEvent('esx_inventoryhud:' .. action .. 'Item', source, item, amount)
        end
    end

    ---@param source integer
    ---@return table[]
    inventory.getInventoryItems = function(source)
        LogDebug(('[inventory] getInventoryItems(source=%s) system=%s'):format(tostring(source), tostring(sharedConfig.Inventory)))
        if sharedConfig.Inventory == 'ox_inventory' then
            return exports.ox_inventory:GetInventoryItems(source) or {}
        elseif sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            local Player = Dank.player.get(source)
            if not Player then return {} end
            return Player.PlayerData.items or {}
        elseif sharedConfig.Framework == 'es_extended' then
            local Player = Dank.player.get(source)
            if not Player then return {} end
            return Player.getInventory(false) or {}
        end
        return exports.ox_inventory:GetInventoryItems(source) or {}
    end

    ---@param source integer
    ---@param slot integer
    ---@param metadata table
    ---@return boolean
    inventory.setMetadata = function(source, slot, metadata)
        LogDebug(('[inventory] setMetadata(source=%s, slot=%s) system=%s'):format(tostring(source), tostring(slot), tostring(sharedConfig.Inventory)))
        if sharedConfig.Inventory == 'ox_inventory' then
            return exports.ox_inventory:SetMetadata(source, slot, metadata)
        elseif sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            local Player = Dank.player.get(source)
            if not Player or not Player.PlayerData.items[slot] then return false end
            Player.PlayerData.items[slot].info = metadata
            Player.PlayerData.items[slot].metadata = metadata
            Player.Functions.SetPlayerData("items", Player.PlayerData.items)
            return true
        end
        return exports.ox_inventory:SetMetadata(source, slot, metadata)
    end

    ---@param source integer
    ---@param item string
    ---@param amount number
    ---@param slot? integer
    ---@param metadata? table
    ---@return boolean
    inventory.addItem = function(source, item, amount, slot, metadata)
        LogDebug(('[inventory] addItem(source=%s, item=%s, amount=%s)'):format(tostring(source), tostring(item), tostring(amount)))
        local Player = Dank.player.get(source)
        if not Player then return false end
        amount = tonumber(amount) or 1

        if sharedConfig.Inventory == 'ox_inventory' then
            return exports.ox_inventory:AddItem(source, item, amount, metadata, slot)
        elseif sharedConfig.Inventory == 'origen_inventory' then
            return exports['origen_inventory']:AddItem(source, item, amount, slot, metadata)
        elseif sharedConfig.Inventory == 'qs-inventory' then
            return exports['qs-inventory']:AddItem(source, item, amount, slot, metadata)
        elseif sharedConfig.Framework == 'qbx_core' then
            return exports.qbx_core:AddItem(source, item, amount, slot, metadata)
        elseif sharedConfig.Framework == 'qb-core' then
            handleItemNotification(source, item, 'add', amount)
            return Player.Functions.AddItem(item, amount, slot, metadata)
        elseif sharedConfig.Framework == 'es_extended' then
            handleItemNotification(source, item, 'add', amount)
            Player.addInventoryItem(item, amount)
            return true
        end
        return false
    end

    ---@param source integer
    ---@param item string
    ---@param amount number
    ---@param slot? integer
    ---@param metadata? table
    ---@return boolean
    inventory.removeItem = function(source, item, amount, slot, metadata)
        LogDebug(('[inventory] removeItem(source=%s, item=%s, amount=%s)'):format(tostring(source), tostring(item), tostring(amount)))
        local Player = Dank.player.get(source)
        if not Player then return false end
        amount = tonumber(amount) or 1

        if sharedConfig.Inventory == 'ox_inventory' then
            return exports.ox_inventory:RemoveItem(source, item, amount, metadata, slot)
        elseif sharedConfig.Inventory == 'origen_inventory' then
            return exports['origen_inventory']:RemoveItem(source, item, amount, slot)
        elseif sharedConfig.Inventory == 'qs-inventory' then
            return exports['qs-inventory']:RemoveItem(source, item, amount, slot)
        elseif sharedConfig.Framework == 'qbx_core' then
            return exports.qbx_core:RemoveItem(source, item, amount, slot, metadata)
        elseif sharedConfig.Framework == 'qb-core' then
            handleItemNotification(source, item, 'remove', amount)
            return Player.Functions.RemoveItem(item, amount, slot)
        elseif sharedConfig.Framework == 'es_extended' then
            handleItemNotification(source, item, 'remove', amount)
            Player.removeInventoryItem(item, amount)
            return true
        end
        return false
    end

    ---@param source integer
    ---@param item string
    ---@return table|nil
    inventory.getItemByName = function(source, item)
        LogDebug(('[inventory] getItemByName(source=%s, item=%s)'):format(tostring(source), tostring(item)))
        local Player = Dank.player.get(source)
        if not Player then return nil end
        if sharedConfig.Framework == 'qbx_core' or sharedConfig.Framework == 'qb-core' then
            return Player.Functions.GetItemByName(item)
        elseif sharedConfig.Framework == 'es_extended' then
            return Player.getInventoryItem(item)
        end
    end

    ---@param item string
    ---@param callback function
    inventory.createUseableItem = function(item, callback)
        LogDebug(('[inventory] createUseableItem(item=%s) system=%s'):format(tostring(item), tostring(sharedConfig.Inventory)))
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

    ---@param source integer
    ---@param item string
    ---@param amount number
    ---@return boolean
    inventory.canCarryItem = function(source, item, amount)
        LogDebug(('[inventory] canCarryItem(source=%s, item=%s, amount=%s)'):format(tostring(source), tostring(item), tostring(amount)))
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


    ---@param source integer
    ---@param item string
    ---@return table[]
    inventory.getItemsByName = function(source, item)
        LogDebug(('[inventory] getItemsByName(source=%s, item=%s) system=%s'):format(tostring(source), tostring(item), tostring(sharedConfig.Inventory)))
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

    ---@param source integer
    ---@param item string
    ---@return number
    inventory.getItemCount = function(source, item)
        LogDebug(('[inventory] getItemCount(source=%s, item=%s) system=%s'):format(tostring(source), tostring(item), tostring(sharedConfig.Inventory)))
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

    ---@param source integer
    ---@param item string
    ---@param amount number
    ---@return boolean
    inventory.hasItem = function(source, item, amount)
        LogDebug(('[inventory] hasItem(source=%s, item=%s, amount=%s)'):format(tostring(source), tostring(item), tostring(amount)))
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

    ---@param stashId string
    ---@return table[]
    inventory.getStashItems = function(stashId)
        LogDebug(('[inventory] getStashItems(stash=%s) system=%s'):format(tostring(stashId), tostring(sharedConfig.Inventory)))
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

    ---@param id string
    ---@param label string
    ---@param slots integer
    ---@param weight number
    ---@param owner? string|number|boolean
    ---@param groups? table
    inventory.registerStash = function(id, label, slots, weight, owner, groups)
        LogDebug(('[inventory] registerStash(id=%s, label=%s) system=%s'):format(tostring(id), tostring(label), tostring(sharedConfig.Inventory)))
        if sharedConfig.Inventory == 'ox_inventory' then
            exports.ox_inventory:RegisterStash(id, label, slots, weight, owner, groups)
        elseif sharedConfig.Inventory == 'qs-inventory' then
            exports['qs-inventory']:RegisterStash(source, id, slots, weight)
        end
    end

    ---@param name string
    ---@param label string
    ---@param items table
    ---@param locations table
    ---@param groups? table
    inventory.registerShop = function(name, label, items, locations, groups)
        LogDebug(('[inventory] registerShop(name=%s, label=%s) system=%s'):format(tostring(name), tostring(label), tostring(sharedConfig.Inventory)))
        if sharedConfig.Inventory == 'ox_inventory' then
            exports.ox_inventory:RegisterShop(name, {
                name = label,
                inventory = items,
                locations = locations,
                groups = groups,
            })
        end
    end

    ---@param id string|number
    ---@param items table
    ---@param coords table
    inventory.customDrop = function(id, items, coords)
        LogDebug(('[inventory] customDrop(id=%s) system=%s'):format(tostring(id), tostring(sharedConfig.Inventory)))
        if sharedConfig.Inventory == 'ox_inventory' then
            exports.ox_inventory:CustomDrop(id, items, coords)
        end
    end
else
    -- CLIENT
    ---@param stashName string
    ---@param maxweight number
    ---@param slots integer
    inventory.openStash = function(stashName, maxweight, slots)
        LogDebug(('[inventory] openStash(stash=%s) system=%s [client]'):format(tostring(stashName), tostring(sharedConfig.Inventory)))
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
        elseif sharedConfig.Inventory == 'origen_inventory' then
            exports['origen_inventory']:OpenStash(stashName, maxweight, slots)
        else
            print('^3[Dank_Utils] Unsupported inventory for OpenStash: ' .. tostring(sharedConfig.Inventory) .. '^0')
        end
    end

    ---@param metadata table
    inventory.displayMetadata = function(metadata)
        LogDebug(('[inventory] displayMetadata system=%s [client]'):format(tostring(sharedConfig.Inventory)))
        if sharedConfig.Inventory == 'ox_inventory' then
            if GetResourceState('ox_inventory') == 'started' then
                exports.ox_inventory:displayMetadata(metadata)
            else
                CreateThread(function()
                    while GetResourceState('ox_inventory') ~= 'started' do Wait(200) end
                    exports.ox_inventory:displayMetadata(metadata)
                end)
            end
        end
    end

    ---@return string
    inventory.getImageUrl = function()
        local inv = sharedConfig.Inventory
        LogDebug(('[inventory] getImageUrl system=%s'):format(tostring(inv)))
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
        elseif inv == 'origen_inventory' then
            return 'nui://origen_inventory/html/images/'
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

    ---@param arg1? string|number
    ---@param arg2? string|number
    ---@return number
    inventory.getItemCount = function(arg1, arg2)
        local item = (type(arg1) == 'string' and arg1) or (type(arg2) == 'string' and arg2)
        LogDebug(('[inventory] getItemCount(item=%s) [client]'):format(tostring(item)))
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

    ---@param item string
    ---@return table[]
    inventory.getItemsByName = function(item)
        LogDebug(('[inventory] getItemsByName(item=%s) [client]'):format(tostring(item)))
        if not item then return {} end
        if sharedConfig.Inventory == 'ox_inventory' or sharedConfig.Framework == 'qbx_core' then
            return exports.ox_inventory:Search('slots', item) or {}
        elseif sharedConfig.Framework == 'qb-core' then
            local core = exports['qb-core']:GetCoreObject()
            local plyData = core and core.Functions.GetPlayerData()
            if not plyData then return {} end
            local items = {}
            for _, invItem in pairs(plyData.items or {}) do
                if invItem and invItem.name == item then
                    table.insert(items, invItem)
                end
            end
            return items
        elseif sharedConfig.Framework == 'es_extended' then
            local esx = exports['es_extended']:getSharedObject()
            local playerData = esx and esx.GetPlayerData() or {}
            local items = {}
            for _, invItem in pairs(playerData.inventory or {}) do
                if invItem and invItem.name == item then
                    table.insert(items, invItem)
                end
            end
            return items
        end
        return {}
    end

    ---@param item string
    ---@param rAmount? number
    ---@return boolean
    inventory.hasItem = function(item, rAmount)
        local amount = rAmount or 1
        LogDebug(('[inventory] hasItem(item=%s, amount=%s) [client]'):format(tostring(item), tostring(amount)))
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

    ---@param requiredItems table<string, number>
    ---@return boolean, table[]|nil
    inventory.hasItems = function(requiredItems)
        local missingItems = {}
        LogDebug('[inventory] hasItems [client]')
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

    ---@param itemName string
    ---@return string
    inventory.getItemLabel = function(itemName)
        LogDebug(('[inventory] getItemLabel(item=%s)'):format(tostring(itemName)))
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
---@param item string
---@return table|nil
inventory.sharedItems = function(item)
    LogDebug(('[inventory] sharedItems(item=%s)'):format(tostring(item)))
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
