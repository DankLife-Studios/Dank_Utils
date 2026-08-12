local sharedConfig = require 'config.dankutils_shared'

local function formatLine(title, value)
    if value == 'none' then
        return string.format('^7| ^4%-12s ^7| ^1%-18s ^7|', title, 'Not Found')
    else
        return string.format('^7| ^4%-12s ^7| ^2%-18s ^7|', title, value)
    end
end

-- Force load modules that contain critical server callbacks
local _ = Dank.vehicle

CreateThread(function()
    Wait(5000) -- Wait a brief moment to ensure all state bags are resolved

    local banner = {
        '^5=====================================',
        '^5|        ^6DankLife Utilities^5         |',
        '^5=====================================',
        formatLine('Framework', sharedConfig.Framework),
        formatLine('Inventory', sharedConfig.Inventory),
        formatLine('Banking', sharedConfig.Banking),
        formatLine('Target', sharedConfig.Target),
        formatLine('Menu', sharedConfig.Menu),
        formatLine('Phone', sharedConfig.Phone),
        formatLine('Fuel', sharedConfig.Fuel),
        formatLine('Keys', sharedConfig.Keys),
        formatLine('Debug', sharedConfig.Debug),
        '^5====================================='
    }

    print('^7')
    for _, line in ipairs(banner) do
        print(line)
    end
    print('^7')
end)
