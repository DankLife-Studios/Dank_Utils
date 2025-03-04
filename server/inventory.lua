-- @module Inventory
-- @desc Server-side inventory management for Dank Utils, supporting stash registration.
Framework = Framework or {}
Framework.Status = Framework.Status or {}
Framework.Inventory = Framework.Inventory or {}

local sharedConfig = require 'config.shared'

Framework.Inventory.RegisterStash = function(stashId, stashData)
    if sharedConfig.Inventory == 'ox_inventory' then
        local stashLabel = stashData.label or 'Default Stash'
        local stashSlots = stashData.slots or 50
        local stashWeight = stashData.weight or 100000
        exports.ox_inventory:RegisterStash(stashId, stashLabel, stashSlots, stashWeight, false)
    elseif sharedConfig.Inventory == 'qb-inventory' then
        -- QB inventory typically registers stashes via SQL or client-side; no direct export available
        LogDebug('[Dank Utils] QB inventory stash registration may require custom implementation.')
    elseif sharedConfig.Inventory == 'esx_inventory' then
        -- ESX may use shared object registration; placeholder for implementation
        LogDebug('[Dank Utils] ESX inventory stash registration requires ESX-specific implementation.')
    else
        LogDebug('[Dank Utils] Unsupported inventory for RegisterStash: ' .. tostring(sharedConfig.Inventory))
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