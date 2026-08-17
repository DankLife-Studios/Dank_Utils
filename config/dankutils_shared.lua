local GetResourceState = GetResourceState
local ipairs = ipairs
local print = print

local manualConfig = require 'config.dankutils_manual'

-- Resource that owns this file (folder name taken from the chunk source).
-- When another resource includes Dank_Utils (e.g. '@Dank_Utils/init.lua'),
-- this file executes inside THAT resource's runtime, so GetCurrentResourceName()
-- differs and Dank Utils messages must stay silent there.
local chunkSource = debug.getinfo(1, 'S').source
local ownResource = chunkSource:match('@@([^/]+)/') or GetCurrentResourceName()

---Prints a debug message only inside Dank_Utils' own runtime when Debug is on.
---@param message string
local function LogDebug(message)
    if manualConfig.Debug and GetCurrentResourceName() == ownResource then
        print('[Dank Utils DEBUG] ' .. message)
    end
end

---Returns the first resource from the list that is started or starting.
---@param resourceNames string[]
---@return string
local function getActiveResource(resourceNames)
    for _, resourceName in ipairs(resourceNames) do
        local state = GetResourceState(resourceName)
        if state == 'starting' or state == 'started' then
            LogDebug('Detected active resource: ' .. resourceName)
            return resourceName
        end
    end
    return 'none'
end

---Resolves a config field to an active resource name or manual override.
---@param field string
---@param resourceNames string[]
---@return string
local function detectResource(field, resourceNames)
    local selection = manualConfig[field]

    -- Manual override only applies to real resource-name strings;
    -- anything else (nil, 'AutoDetect', invalid values) falls back to AutoDetect.
    if type(selection) == 'string' and selection ~= 'AutoDetect' then
        if GetResourceState(selection) == 'started' or GetResourceState(selection) == 'starting' then
            return selection
        end

        if GetCurrentResourceName() == ownResource then
            print('Manually selected ' .. field .. ' "' .. selection .. '" is not active.')
        end
        return 'none'
    end

    return getActiveResource(resourceNames)
end

---@class DankUtilsConfig
---@field Framework string
---@field Inventory string
---@field Banking string
---@field Target string
---@field Menu string
---@field Phone string
---@field Fuel string
---@field Keys string
---@field Garage string
---@field Debug boolean
---@field LogDebug fun(message: string)
return {
    Framework = detectResource('Framework', { 'qbx_core', 'qb-core', 'es_extended', 'ND_Core', 'ox_core' }),
    Inventory = detectResource('Inventory', { 'ox_inventory', 'qb-inventory', 'ps-inventory', 'qs-inventory', 'esx_inventory', 'core_inventory', 'chezza-inventory', 'codem-inventory', 'origen_inventory' }),
    Banking = detectResource('Banking', { 'pefcl', 'Renewed-Banking', 'okokBanking', 'qb-banking', 'qb-management', 'esx_jobbank', 'fd_banking', 'qs-banking' }),
    Target = detectResource('Target', { 'ox_target', 'qb-target', 'qtarget' }),
    Menu = detectResource('Menu', { 'ox_lib', 'qb-menu', 'esx_menu_default', 'nh-context', 'zf_context', 'esx_context' }),
    Phone = detectResource('Phone', { 'lb-phone', 'qs-smartphone-pro', 'qs-smartphone', 'qb-phone', 'gksphone', 'yseries', 'yphone', 'npwd' }),
    Fuel = detectResource('Fuel', { 'ox_fuel', 'cdn-fuel', 'ti_fuel', 'ps-fuel', 'lj-fuel', 'LegacyFuel' }),
    Keys = detectResource('Keys', { 'qbx_vehiclekeys', 'qb-vehiclekeys', 'wasabi_carlock', 'qs-vehiclekeys', 'mono_carlock', 'tupani_carlock' }),
    Garage = detectResource('Garage', { 'jg-advancedgarages', 'qb-garages', 'cd_garage', 'okokGarage', 'rcore_garage', 'qs-advancedgarages', 'esx_garage' }),
    Debug = manualConfig.Debug or false,
    LogDebug = LogDebug
}
