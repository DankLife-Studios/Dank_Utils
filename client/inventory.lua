Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Inventory = Framework.Inventory or {}

Framework.Inventory.OpenStash = function(stashName, maxweight, slots)
    if SharedConfig.Inventory == 'qb-inventory' then
        local data = { label = stashName, maxweight = maxweight, slots = slots }
        exports['qb-inventory']:OpenInventory(source, stashName, data)
    elseif SharedConfig.Inventory == 'ps-inventory' then
        TriggerEvent('ps-inventory:client:SetCurrentStash', stashName)
        TriggerServerEvent('ps-inventory:server:OpenInventory', 'stash', stashName, {
            maxweight = maxweight,
            slots = slots,
        })
    elseif SharedConfig.Inventory == 'ox_inventory' then
        local ox_inventory = exports.ox_inventory
        ox_inventory:openInventory('stash', { id = stashName })
    elseif SharedConfig.Inventory == 'qs-inventory' or SharedConfig.Inventory == 'qb-old-inventory' then
        local other = {}
        other.maxweight = maxweight
        other.slots = slots
        TriggerServerEvent("inventory:server:OpenInventory", "stash", stashName, other)
        TriggerEvent("inventory:client:SetCurrentStash", stashName)
    elseif SharedConfig.Inventory == 'esx_inventory' or SharedConfig.Inventory == 'es_extended' then
        TriggerServerEvent('esx_inventory:server:OpenStash', stashName, {
            maxweight = maxweight,
            slots = slots
        })
    end
end

Framework.Inventory.GetImageUrl = function()
    if SharedConfig.Inventory == 'qb-inventory' then
        return 'https://cfx-nui-qb-inventory/html/images/'
    elseif SharedConfig.Inventory == 'ps-inventory' then
        return 'https://cfx-nui-ps-inventory/html/images/'
    elseif SharedConfig.Inventory == 'ox_inventory' then
        return 'https://cfx-nui-ox_inventory/web/images/'
    elseif SharedConfig.Inventory == 'qs-inventory' then
        return 'https://cfx-nui-qs-inventory/html/images/'
    elseif SharedConfig.Inventory == 'qb-old-inventory' then
        return 'https://cfx-nui-qb-inventory/html/images/'
    elseif SharedConfig.Inventory == 'esx_inventory' then
        return '' -- Needs a esx user to test and help complete this
    end
end

if SharedConfig.Inventory then
    Framework.Status.Inventory = SharedConfig.Inventory
end

return Framework