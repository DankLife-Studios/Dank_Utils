-- @module Inventory
--- @desc A module that provides a unified interface for different frameworks like qbx_core, qb-core, and es_extended.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Inventory = Framework.Inventory or {}

if SharedConfig.Inventory == 'qb-inventory' then

    --- Opens a stash using the qb-inventory system.
    --- @param stashName string The name or identifier of the stash to open.
    Framework.Inventory.OpenStash = function(stashName)
        local data = { label = stashName, maxweight = SharedConfig.InventorySpace.maxweight, slots = SharedConfig.InventorySpace.slots }
        exports['qb-inventory']:OpenInventory(source, stashName, data)
    end

    Framework.Status.Inventory = SharedConfig.Inventory

elseif SharedConfig.Inventory == 'ps-inventory' then

    --- Opens a stash using the ps-inventory system.
    --- @param stashName string The name or identifier of the stash to open.
    Framework.Inventory.OpenStash = function(stashName)
        TriggerEvent('ps-inventory:client:SetCurrentStash', stashName)
        TriggerServerEvent('ps-inventory:server:OpenInventory', 'stash', stashName, {
            maxweight = SharedConfig.InventorySpace.maxweight,
            slots = SharedConfig.InventorySpace.slots,
        })
    end

    Framework.Status.Inventory = SharedConfig.Inventory

elseif SharedConfig.Inventory == 'ox_inventory' then
    local ox_inventory = exports.ox_inventory
    --- Opens a stash using the ox_inventory system.
    --- @param stashName string The identifier for the stash to be opened.
    Framework.Inventory.OpenStash = function(stashName)
        ox_inventory:openInventory('stash', { id = stashName })
    end

    Framework.Status.Inventory = SharedConfig.Inventory

elseif SharedConfig.Inventory == 'qs-inventory' or SharedConfig.Inventory == 'qb-old-inventory' then
    --- Opens a stash for either qs-inventory or qb-old-inventory systems.
    --- @param stashName string The name of the stash to open.
    Framework.Inventory.OpenStash = function(stashName)
        local other = {}
        other.maxweight = SharedConfig.InventorySpace.maxweight
        other.slots = SharedConfig.InventorySpace.slots
        TriggerServerEvent("inventory:server:OpenInventory", "stash", stashName, other)
        TriggerEvent("inventory:client:SetCurrentStash", stashName)
    end

    Framework.Status.Inventory = SharedConfig.Inventory

elseif SharedConfig.Inventory == 'esx_inventory' or SharedConfig.Inventory == 'es_extended' then
    --- Opens a stash using the ESX inventory system.
    --- @param stashName string The name or identifier of the stash to be opened.
    Framework.Inventory.OpenStash = function(stashName)
        -- Trigger an event or server call specific to ESX inventory handling
        TriggerServerEvent('esx_inventory:server:OpenStash', stashName, {
            maxweight = SharedConfig.InventorySpace.maxweight,
            slots = SharedConfig.InventorySpace.slots
        })
    end

    Framework.Status.Inventory = SharedConfig.Inventory

else
    error("Unsupported inventory system: " .. (SharedConfig.Inventory or "nil"))
end

return Framework