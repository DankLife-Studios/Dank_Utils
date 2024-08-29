--- Retrieves the name of the currently active resource from a list.
--- @param resourceNames table A table of resource names to check.
--- Each entry in the table is a string representing a resource name.
--- @return string resourceName The name of the first resource that is 'started', or 'none' if no resource is found.
local function getActiveResource(resourceNames)
    for _, resourceName in ipairs(resourceNames) do
        if GetResourceState(resourceName) == 'started' then
            return resourceName
        end
    end
    return 'none'
end

-- Manual selection (edit this to choose your preferred script if auto-detection is not needed)
-- @type table
-- @field Framework string Set to 'AutoDetect' or specific framework names ('qbx-core', 'qb-core', 'es_extended').
-- @field Inventory string Set to 'AutoDetect' or specific inventory system names ('ox_inventory', 'qb-old-inventory', 'qb-inventory', 'ps-inventory', 'qs-inventory', 'esx_inventory').
-- @field Banking string Set to 'AutoDetect' or specific banking system names ('Renewed-Banking', 'qb-management', 'okokBanking', 'qb-banking', 'esx_jobbank').
local manualSelection = {
    Framework = 'AutoDetect',
    Inventory = 'AutoDetect',
    Banking = 'AutoDetect'
}

-- Automatic detection
-- @type table
-- @field detectedFramework string The detected framework from the list or 'none'.
-- @field detectedInventory string The detected inventory system from the list or 'none'.
-- @field detectedBanking string The detected banking system from the list or 'none'.
local detectedFramework = getActiveResource({'qbx-core', 'qb-core', 'es_extended'})
local detectedInventory = getActiveResource({'ox_inventory', 'qb-old-inventory', 'qb-inventory', 'ps-inventory', 'qs-inventory', 'esx_inventory'})
local detectedBanking = getActiveResource({'Renewed-Banking', 'qb-management', 'okokBanking', 'qb-banking', 'esx_jobbank'})

-- Determine the final selection
-- @type table
-- @field Framework string The final selected framework.
-- @field Inventory string The final selected inventory system.
-- @field Banking string The final selected banking system.
local finalSelection = {
    Framework = (manualSelection.Framework == 'AutoDetect') and detectedFramework or manualSelection.Framework,
    Inventory = (manualSelection.Inventory == 'AutoDetect') and detectedInventory or manualSelection.Inventory,
    Banking = (manualSelection.Banking == 'AutoDetect') and detectedBanking or manualSelection.Banking
}

-- Print status messages
CreateThread(function()
    Wait(500) -- Delay to ensure all components are properly initialized

    local missingComponents = {}

    -- Check for missing framework
    if finalSelection.Framework == 'none' and manualSelection.Framework == 'AutoDetect' then
        table.insert(missingComponents, 'frameworks')
    end

    -- Check for missing inventory system
    if finalSelection.Inventory == 'none' and manualSelection.Inventory == 'AutoDetect' then
        table.insert(missingComponents, 'inventory systems')
    end

    -- Check for missing banking system
    if finalSelection.Banking == 'none' and manualSelection.Banking == 'AutoDetect' then
        table.insert(missingComponents, 'banking systems')
    end

    -- Print a professional message if any components are missing
    if #missingComponents > 0 then
        local componentList = table.concat(missingComponents, ', ')
        print("^2[^6DankLife Gaming ^2- ^0" .. GetCurrentResourceName() .. "^2] ^1The following supported components are missing: " .. componentList .. ". ^0Please submit a pull request with the necessary support or open a ticket on our Discord server, and we will work to add the support promptly.^0")
    end
end)

return finalSelection
