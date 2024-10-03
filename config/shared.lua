SharedConfig = SharedConfig or {}

local function getActiveResource(resourceNames)
    for _, resourceName in ipairs(resourceNames) do
        if GetResourceState(resourceName) == 'starting' or GetResourceState(resourceName) == 'started' then
            return resourceName
        end
    end
    return 'none'
end

local manualSelection = {--- Set to 'AutoDetect' for automatic detection or
    Framework = 'AutoDetect', --- Manually specify a framework ('qbx_core', 'qb-core', 'es_extended'). -- Note: 'es_extended' NEEDS ALOT OF TESTING
    Inventory = 'AutoDetect', --- Manually specify an inventory system ('ox_inventory', 'qb-old-inventory', 'qb-inventory', 'ps-inventory', 'qs-inventory', 'esx_inventory').
    Banking = 'AutoDetect', --- Manually specify a banking system ('Renewed-Banking', 'okokBanking', 'qb-banking', 'esx_jobbank').
    Target = 'AutoDetect', --- Manually specify a target system ('ox_target', 'qb-target').
    Menu = 'AutoDetect', --- Manually specify a target system ('ox_lib', 'qb-menu').
}

local detectedFramework = getActiveResource({'qbx_core', 'qb-core', 'es_extended'})
local detectedInventory = getActiveResource({'ox_inventory', 'qb-old-inventory', 'qb-inventory', 'ps-inventory', 'qs-inventory', 'esx_inventory'})
local detectedBanking = getActiveResource({'Renewed-Banking', 'okokBanking', 'qb-banking', 'esx_jobbank'})
local detectedTarget = getActiveResource({'ox_target', 'qb-target'})
local detectedMenu = getActiveResource({'ox_lib', 'qb-menu'})

SharedConfig = {
    Framework = (manualSelection.Framework == 'AutoDetect') and detectedFramework or manualSelection.Framework,
    Inventory = (manualSelection.Inventory == 'AutoDetect') and detectedInventory or manualSelection.Inventory,
    Banking = (manualSelection.Banking == 'AutoDetect') and detectedBanking or manualSelection.Banking,
    Target = (manualSelection.Target == 'AutoDetect') and detectedTarget or manualSelection.Target,
    Menu = (manualSelection.Menu == 'AutoDetect') and detectedMenu or manualSelection.Menu,
}

return SharedConfig