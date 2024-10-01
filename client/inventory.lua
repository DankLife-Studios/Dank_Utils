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

if SharedConfig.Inventory then
    Framework.Status.Inventory = SharedConfig.Inventory
end

return Framework