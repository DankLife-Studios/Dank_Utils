local GetResourceState = GetResourceState
local ipairs = ipairs
local print = print

local manualConfig = require 'config.manual'

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
    local selection = manualConfig[type] or 'AutoDetect'
    if selection == 'AutoDetect' then
        return getActiveResource(resourceNames)
    elseif GetResourceState(selection) == 'started' or GetResourceState(selection) == 'starting' then
        return selection
    else
        print('[Dank Utils] Manually selected ' .. type .. ' "' .. selection .. '" is not active.')
        return 'none'
    end
end

return {
    Framework = detectResource('Framework', { 'qbx_core', 'qb-core', 'es_extended', 'ND_Core', 'ox_core' }),
    Inventory = detectResource('Inventory', { 'ox_inventory', 'qb-inventory', 'ps-inventory', 'qs-inventory', 'esx_inventory', 'core_inventory', 'chezza-inventory', 'codem-inventory' }),
    Banking = detectResource('Banking', { 'pefcl', 'Renewed-Banking', 'okokBanking', 'qb-banking', 'qb-management', 'esx_jobbank', 'fd_banking' }),
    Target = detectResource('Target', { 'ox_target', 'qb-target', 'qtarget' }),
    Menu = detectResource('Menu', { 'ox_lib', 'qb-menu', 'esx_menu_default', 'nh-context', 'zf_context' }),
    Phone = detectResource('Phone', { 'lb-phone', 'qs-smartphone', 'qb-phone', 'gksphone', 'yseries' }),
    Debug = manualConfig.Debug or false
}
