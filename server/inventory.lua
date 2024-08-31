-- @module Framework
--- @desc A module that provides a unified interface for different frameworks like qbx_core, qb-core, and es_extended.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Inventory = Framework.Inventory or {}

if SharedConfig.Inventory == 'ox_inventory' then
    --- Function to register a stash with ox_inventory
    --- @param stashId string The unique identifier for the stash.
    --- @param stashData table The data associated with the stash.
    Framework.Inventory.RegisterStash = function(stashId, stashData)
        local stashLabel = stashData.label or 'Default Stash' -- Default label if not provided
        local stashSlots = stashData.slots or 50 -- Default slots if not provided
        local stashWeight = stashData.weight or 100000 -- Default weight if not provided

        -- Register stash with ox_inventory
        exports.ox_inventory:RegisterStash(stashId, stashLabel, stashSlots, stashWeight, false)
    end

    Framework.Status.Inventory = SharedConfig.Inventory
end

return Framework