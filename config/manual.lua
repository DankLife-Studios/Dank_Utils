return {
    Debug = false, -- Set to true to enable debug logging
    manualSelection = {
        Framework = 'AutoDetect', -- Options: 'qbx_core', 'qb-core', 'es_extended', 'AutoDetect'
        Inventory = 'AutoDetect', -- Options: 'ox_inventory', 'qb-inventory', 'ps-inventory', 'qs-inventory', 'esx_inventory', 'AutoDetect'
        Banking = 'AutoDetect',   -- Options: 'Renewed-Banking', 'okokBanking', 'qb-banking', 'esx_jobbank', 'AutoDetect'
        Target = 'AutoDetect',    -- Options: 'ox_target', 'qb-target', 'AutoDetect'
        Menu = 'AutoDetect',      -- Options: 'ox_lib', 'qb-menu', 'AutoDetect'
    },
    ForceQbMenu = false -- Override to force 'qb-menu' regardless of detection
}