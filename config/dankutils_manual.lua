---@class DankUtilsManualConfig
---@field Debug boolean
---@field Framework string|nil
---@field Inventory string|nil
---@field Banking string|nil
---@field Target string|nil
---@field Menu string|nil
---@field Phone string|nil
---@field Fuel string|nil
---@field Keys string|nil
---@field Garage string|nil

return {
    Debug = false, -- Set to true to enable debug logging

    -- Uncomment ONE framework to force manual selection. Otherwise, leave commented for AutoDetect.
    -- Framework = 'qbx_core',
    -- Framework = 'qb-core',
    -- Framework = 'es_extended',
    -- Framework = 'ND_Core',
    -- Framework = 'ox_core',

    -- Uncomment ONE inventory to force manual selection. Otherwise, leave commented for AutoDetect.
    -- Inventory = 'ox_inventory',
    -- Inventory = 'qb-inventory',
    -- Inventory = 'ps-inventory',
    -- Inventory = 'qs-inventory',
    -- Inventory = 'esx_inventory',
    -- Inventory = 'core_inventory',
    -- Inventory = 'chezza-inventory',
    -- Inventory = 'codem-inventory',
    -- Inventory = 'origen_inventory',

    -- Uncomment ONE banking system to force manual selection. Otherwise, leave commented for AutoDetect.
    -- Banking = 'Renewed-Banking',
    -- Banking = 'okokBanking',
    -- Banking = 'qb-banking',
    -- Banking = 'qb-management',
    -- Banking = 'esx_jobbank',
    -- Banking = 'pefcl',
    -- Banking = 'fd_banking',
    -- Banking = 'qs-banking',

    -- Uncomment ONE target system to force manual selection. Otherwise, leave commented for AutoDetect.
    -- Target = 'ox_target',
    -- Target = 'qb-target',
    -- Target = 'qtarget',

    -- Uncomment ONE menu system to force manual selection. Otherwise, leave commented for AutoDetect.
    -- Menu = 'ox_lib',
    -- Menu = 'qb-menu',
    -- Menu = 'esx_menu_default',
    -- Menu = 'nh-context',
    -- Menu = 'zf_context',
    -- Menu = 'esx_context',

    -- Uncomment ONE phone system to force manual selection. Otherwise, leave commented for AutoDetect.
    -- Phone = 'lb-phone',
    -- Phone = 'qs-smartphone-pro',
    -- Phone = 'qs-smartphone',
    -- Phone = 'qb-phone',
    -- Phone = 'gksphone',
    -- Phone = 'yseries',
    -- Phone = 'yphone',
    -- Phone = 'npwd',

    -- Uncomment ONE fuel script to force manual selection. Otherwise, leave commented for AutoDetect.
    -- Fuel = 'ox_fuel',
    -- Fuel = 'cdn-fuel',
    -- Fuel = 'LegacyFuel',
    -- Fuel = 'lj-fuel',
    -- Fuel = 'ti_fuel',
    -- Fuel = 'ps-fuel',
    
    -- Uncomment ONE keys script to force manual selection. Otherwise, leave commented for AutoDetect.
    -- Keys = 'qbx_vehiclekeys',
    -- Keys = 'qb-vehiclekeys',
    -- Keys = 'wasabi_carlock',
    -- Keys = 'qs-vehiclekeys',
    -- Keys = 'mono_carlock',
    -- Keys = 'tupani_carlock',

    -- Uncomment ONE garage script to force manual selection. Otherwise, leave commented for AutoDetect.
    -- Garage = 'jg-advancedgarages',
    -- Garage = 'qb-garages',
    -- Garage = 'cd_garage',
    -- Garage = 'okokGarage',
    -- Garage = 'rcore_garage',
    -- Garage = 'qs-advancedgarages',
    -- Garage = 'esx_garage',
}