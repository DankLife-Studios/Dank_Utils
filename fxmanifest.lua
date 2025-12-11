fx_version 'cerulean'
game 'gta5'

name 'Dank_Utils'
author 'Dankbudbaker'
description 'A Framework & Script Compatibility For DankLife Scripts'
script_version '0.7.0'

-- **INSTRUCTIONS:**
-- If you DO NOT use the framework or library mentioned, add or keep `--` at the start of the line to disable it.
-- If you USE the framework, ensure there is no `--` at the beginning of the line.

shared_scripts {
    '@ox_lib/init.lua', -- Needed
    '@qbx_core/modules/lib.lua', -- DISABLE THIS LINE IF YOU DON'T USE qbx_core (Keep or add --)
    'shared/exports.lua'
}

client_scripts {
    '@qbx_core/modules/playerdata.lua', -- DISABLE THIS LINE IF YOU DON'T USE qbx_core (Keep or add --)
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

files {
    'config/manual.lua',
    'config/shared.lua',
}

escrow_ignore {
    'shared/**',
    'client/**',
    'server/**'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'