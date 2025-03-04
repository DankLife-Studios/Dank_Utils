-- @module Inventory
-- @desc Manages inventory interactions for Dank Utils, supporting multiple inventory systems.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Inventory = Framework.Inventory or {}

-- Opens a stash based on the selected inventory system
Framework.Inventory.OpenStash = function(stashName, maxweight, slots)
    if SharedConfig.Inventory == 'qb-inventory' or SharedConfig.Inventory == 'qb-old-inventory' then
        local data = { label = stashName, maxweight = maxweight, slots = slots }
        exports['qb-inventory']:OpenInventory(source, stashName, data)
    elseif SharedConfig.Inventory == 'ps-inventory' then
        TriggerEvent('ps-inventory:client:SetCurrentStash', stashName)
        TriggerServerEvent('ps-inventory:server:OpenInventory', 'stash', stashName, {
            maxweight = maxweight,
            slots = slots,
        })
    elseif SharedConfig.Inventory == 'ox_inventory' then
        exports.ox_inventory:openInventory('stash', { id = stashName })
    elseif SharedConfig.Inventory == 'qs-inventory' then
        local other = { maxweight = maxweight, slots = slots }
        TriggerServerEvent("inventory:server:OpenInventory", "stash", stashName, other)
        TriggerEvent("inventory:client:SetCurrentStash", stashName)
    elseif SharedConfig.Inventory == 'esx_inventory' then
        TriggerServerEvent('esx_inventory:server:OpenStash', stashName, {
            maxweight = maxweight,
            slots = slots
        })
    else
        LogDebug('[Dank Utils] Unsupported inventory for OpenStash: ' .. tostring(SharedConfig.Inventory))
    end
end

-- Returns the image URL prefix for the selected inventory system
Framework.Inventory.GetImageUrl = function()
    if SharedConfig.Inventory == 'qb-inventory' or SharedConfig.Inventory == 'qb-old-inventory' then
        return 'https://cfx-nui-qb-inventory/html/images/'
    elseif SharedConfig.Inventory == 'ps-inventory' then
        return 'https://cfx-nui-ps-inventory/html/images/'
    elseif SharedConfig.Inventory == 'ox_inventory' then
        return 'https://cfx-nui-ox_inventory/web/images/'
    elseif SharedConfig.Inventory == 'qs-inventory' then
        return 'https://cfx-nui-qs-inventory/html/images/'
    elseif SharedConfig.Inventory == 'esx_inventory' then
        return '' -- TODO: Requires ESX user input for accurate URL
    else
        LogDebug('[Dank Utils] Unsupported inventory for GetImageUrl: ' .. tostring(SharedConfig.Inventory))
        return ''
    end
end

-- Set inventory status if valid and active
local validInventories = {
    ['ox_inventory'] = true,
    ['qb-old-inventory'] = true,
    ['qb-inventory'] = true,
    ['ps-inventory'] = true,
    ['qs-inventory'] = true,
    ['esx_inventory'] = true
}
if SharedConfig.Inventory and validInventories[SharedConfig.Inventory] then
    local state = GetResourceState(SharedConfig.Inventory)
    if state == 'started' or state == 'starting' then
        Framework.Status.Inventory = SharedConfig.Inventory
    else
        LogDebug('[Dank Utils] Inventory resource "' .. SharedConfig.Inventory .. '" is not active.')
    end
elseif SharedConfig.Inventory ~= 'AutoDetect' then
    LogDebug('[Dank Utils] Unsupported Inventory option: ' .. tostring(SharedConfig.Inventory))
end

return Framework