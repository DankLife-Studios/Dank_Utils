local manualConfig = require 'config.manual'

-- Default manualSelection if not provided in config
local manualSelection = manualConfig.manualSelection or {
    Framework = 'AutoDetect',
    Inventory = 'AutoDetect',
    Banking = 'AutoDetect',
    Target = 'AutoDetect',
    Menu = 'AutoDetect',
    Phone = 'AutoDetect',
}

function LogDebug(message)
    if manualConfig.Debug then
        print('[Dank Utils DEBUG] ' .. message)
    end
end

local function getActiveResource(resourceNames)
    for _, resourceName in ipairs(resourceNames) do
        local state = GetResourceState(resourceName)
        if state == 'starting' or state == 'started' then
            LogDebug('[Dank Utils] Detected active resource: ' .. resourceName)
            return resourceName
        end
    end
    return 'none'
end

local function detectResource(type, resourceNames)
    local selection = manualSelection[type] or 'AutoDetect'
    if selection == 'AutoDetect' then
        return getActiveResource(resourceNames)
    elseif GetResourceState(selection) == 'starting' or GetResourceState(selection) == 'started' then
        return selection
    else
        print('[Dank Utils] Manually selected ' .. type .. ' "' .. selection .. '" is not active.')
        return 'none'
    end
end

return {
    Framework = detectResource('Framework', {'qbx_core', 'qb-core', 'es_extended'}),
    Inventory = detectResource('Inventory', {'ox_inventory', 'qb-inventory', 'ps-inventory', 'qs-inventory', 'esx_inventory'}),
    Banking = detectResource('Banking', {'Renewed-Banking', 'okokBanking', 'qb-banking', 'esx_jobbank'}),
    Target = detectResource('Target', {'ox_target', 'qb-target'}),
	Phone = detectResource('Phone', {'npwd', 'lb-phone'}),
    Menu = manualConfig.ForceQbMenu and 'qb-menu' or detectResource('Menu', {'ox_lib', 'qb-menu'}),
    Debug = manualConfig.Debug or false
}