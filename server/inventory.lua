Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Inventory = Framework.Inventory or {}

Framework.Inventory.RegisterStash = function(stashId, stashData)
    if SharedConfig.Inventory == 'ox_inventory' then
        local stashLabel = stashData.label or 'Default Stash' -- Default label if not provided
        local stashSlots = stashData.slots or 50 -- Default slots if not provided
        local stashWeight = stashData.weight or 100000 -- Default weight if not provided
        exports.ox_inventory:RegisterStash(stashId, stashLabel, stashSlots, stashWeight, false)
    end
end

if SharedConfig.Inventory then
    Framework.Status.Inventory = SharedConfig.Inventory
end

return Framework