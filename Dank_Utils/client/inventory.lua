-- @module Inventory
--- @desc A module that provides a unified interface for different frameworks like qbx_core, qb-core, and es_extended.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Inventory = Framework.Inventory or {}


--- Opens a stash using the qb-inventory system.
--- @param stashName string The name or identifier of the stash to open.
Framework.Inventory.OpenStash = function(stashName)
    if SharedConfig.Inventory == 'qb-inventory' then
        local data = { label = stashName, maxweight = SharedConfig.InventorySpace.maxweight, slots = SharedConfig.InventorySpace.slots }
        exports['qb-inventory']:OpenInventory(source, stashName, data)
    elseif SharedConfig.Inventory == 'ps-inventory' then
        TriggerEvent('ps-inventory:client:SetCurrentStash', stashName)
        TriggerServerEvent('ps-inventory:server:OpenInventory', 'stash', stashName, {
            maxweight = SharedConfig.InventorySpace.maxweight,
            slots = SharedConfig.InventorySpace.slots,
        })
    elseif SharedConfig.Inventory == 'ox_inventory' then
        local ox_inventory = exports.ox_inventory
        ox_inventory:openInventory('stash', { id = stashName })
    elseif SharedConfig.Inventory == 'qs-inventory' or SharedConfig.Inventory == 'qb-old-inventory' then
        local other = {}
        other.maxweight = SharedConfig.InventorySpace.maxweight
        other.slots = SharedConfig.InventorySpace.slots
        TriggerServerEvent("inventory:server:OpenInventory", "stash", stashName, other)
        TriggerEvent("inventory:client:SetCurrentStash", stashName)
    elseif SharedConfig.Inventory == 'esx_inventory' or SharedConfig.Inventory == 'es_extended' then
        TriggerServerEvent('esx_inventory:server:OpenStash', stashName, {
            maxweight = SharedConfig.InventorySpace.maxweight,
            slots = SharedConfig.InventorySpace.slots
        })
    end
end


if not SharedConfig.Inventory == 'none' then
    Framework.Status.Inventory = SharedConfig.Inventory
end

return Framework