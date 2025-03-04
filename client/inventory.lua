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