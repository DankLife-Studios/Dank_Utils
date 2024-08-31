SharedConfig = SharedConfig or {}

--- Retrieves the name of the currently active resource from a list.
--- @param resourceNames table A table of resource names to check.
--- Each entry in the table is a string representing a resource name.
--- @return string resourceName The name of the first resource that is 'started', or 'none' if no resource is found.
local function getActiveResource(resourceNames)
    for _, resourceName in ipairs(resourceNames) do
        if GetResourceState(resourceName) == 'starting' or GetResourceState(resourceName) == 'started' then
            return resourceName
        end
    end
    return 'none'
end

-- Manual selection (edit this to choose your preferred script if auto-detection is not needed)
local manualSelection = {
    Framework = 'AutoDetect', --- Set to 'AutoDetect' for automatic detection, or specify a framework ('qbx_core', 'qb-core', 'es_extended'). Note: 'es_extended' NEEDS TESTING
    Inventory = 'AutoDetect', --- Set to 'AutoDetect' for automatic detection, or specify an inventory system ('ox_inventory', 'qb-old-inventory', 'qb-inventory', 'ps-inventory', 'qs-inventory', 'esx_inventory').
    Banking = 'AutoDetect', --- Set to 'AutoDetect' for automatic detection, or specify a banking system ('Renewed-Banking', 'qb-management', 'okokBanking', 'qb-banking', 'esx_jobbank').
    Target = 'AutoDetect', --- Set to 'AutoDetect' for automatic detection, or specify a target system ('ox_target', 'qb-target').
}

--- Automatically detects the framework, inventory, banking, target, and phone systems with retry logic.
--- @return table detectedConfig A table containing detected values for Framework, Inventory, Banking, Target, and Phone.
local detectedFramework = getActiveResource({'qbx_core', 'qb-core', 'es_extended'}) -- Note: 'es_extended' NEEDS TESTING
local detectedInventory = getActiveResource({'ox_inventory', 'qb-old-inventory', 'qb-inventory', 'ps-inventory', 'qs-inventory', 'esx_inventory'})
local detectedBanking = getActiveResource({'Renewed-Banking', 'qb-management', 'okokBanking', 'qb-banking', 'esx_jobbank'})
local detectedTarget = getActiveResource({'ox_target', 'qb-target'})

-- Determine the final selection between manual and automatic detection results.
SharedConfig = {
    Framework = (manualSelection.Framework == 'AutoDetect') and detectedFramework or manualSelection.Framework,
    Inventory = (manualSelection.Inventory == 'AutoDetect') and detectedInventory or manualSelection.Inventory,
    Banking = (manualSelection.Banking == 'AutoDetect') and detectedBanking or manualSelection.Banking,
    Target = (manualSelection.Target == 'AutoDetect') and detectedTarget or manualSelection.Target,
}

return SharedConfig