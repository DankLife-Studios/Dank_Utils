-- @module Inventory
-- @desc Manages inventory interactions for Dank Utils, supporting multiple inventory systems.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Inventory = Framework.Inventory or {}

local sharedConfig = require 'config.shared'

-- Opens a stash based on the selected inventory system
Framework.Inventory.OpenStash = function(stashName, maxweight, slots)
    if sharedConfig.Inventory == 'qb-inventory' then
        local data = { label = stashName, maxweight = maxweight, slots = slots }
        exports['qb-inventory']:OpenInventory(source, stashName, data)
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
    else
        LogDebug('[Dank Utils] Unsupported inventory for OpenStash: ' .. tostring(sharedConfig.Inventory))
    end
end

-- Returns the image URL prefix for the selected inventory system
Framework.Inventory.GetImageUrl = function()
    if sharedConfig.Inventory == 'qb-inventory' then
        return 'https://cfx-nui-qb-inventory/html/images/'
    elseif sharedConfig.Inventory == 'ps-inventory' then
        return 'https://cfx-nui-ps-inventory/html/images/'
    elseif sharedConfig.Inventory == 'ox_inventory' then
        return 'https://cfx-nui-ox_inventory/web/images/'
    elseif sharedConfig.Inventory == 'qs-inventory' then
        return 'https://cfx-nui-qs-inventory/html/images/'
    elseif sharedConfig.Inventory == 'esx_inventory' then
        return '' -- TODO: Requires ESX user input for accurate URL
    else
        LogDebug('[Dank Utils] Unsupported inventory for GetImageUrl: ' .. tostring(sharedConfig.Inventory))
        return ''
    end
end

-- Checks if the player has the required items in their inventory
-- @param requiredItems table Table of required items with item names as keys and required quantities as values (e.g., {['apple'] = 2, ['water'] = 1})
-- @return boolean, table Returns true if all items are present, false otherwise. If false, also returns a table of missing items with their missing amounts
Framework.Inventory.HasItems = function(requiredItems)
    local missingItems = {}
    if Framework.Status.Inventory == 'qs-inventory' then
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
    elseif Framework.Status.Inventory == 'ps-inventory' or Framework.Status.Inventory == 'qb-inventory' or Framework.Status.Inventory == 'qb-old-inventory' or Framework.Status.Inventory == 'esx_inventory' then
        for item, requiredAmount in pairs(requiredItems) do
            if not Framework.HasItem(item, requiredAmount) then
                table.insert(missingItems, {item = item, missingAmount = requiredAmount})
            end
        end
    elseif Framework.Status.Inventory == 'ox_inventory' then
        for item, requiredAmount in pairs(requiredItems) do
            local count = exports.ox_inventory:Search('count', item)
            if count < requiredAmount then
                table.insert(missingItems, {item = item, missingAmount = requiredAmount - count})
            end
        end
    else
        LogDebug('[Dank Utils] Unsupported inventory for HasItems: ' .. tostring(Framework.Status.Inventory))
        return false, {{item = 'unknown', missingAmount = 1}} -- Generic missing item for unsupported systems
    end
    if #missingItems == 0 then
        return true, nil
    else
        return false, missingItems
    end
end

-- Set inventory status if valid and active
local validInventories = {
    ['ox_inventory'] = true,
    ['qb-inventory'] = true,
    ['ps-inventory'] = true,
    ['qs-inventory'] = true,
    ['esx_inventory'] = true
}

if sharedConfig.Inventory and validInventories[sharedConfig.Inventory] then
    local state = GetResourceState(sharedConfig.Inventory)
    if state == 'started' or state == 'starting' then
        Framework.Status.Inventory = sharedConfig.Inventory
    else
        LogDebug('[Dank Utils] Inventory resource "' .. sharedConfig.Inventory .. '" is not active.')
    end
elseif sharedConfig.Inventory ~= 'AutoDetect' then
    LogDebug('[Dank Utils] Unsupported Inventory option: ' .. tostring(sharedConfig.Inventory))
end

return Framework