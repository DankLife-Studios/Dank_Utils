fx_version 'cerulean'
game 'gta5'

name 'Doii_Utils'
author 'Dankbudbaker'
description 'Dank_Utils Framework & Script Compatibility'
version '1.0.0'

-- **INSTRUCTIONS:**
-- If you DO NOT use the framework or library mentioned, add or keep `--` at the start of the line to disable it.
-- If you USE the framework, ensure there is no `--` at the beginning of the line.

client_scripts {
    '@qbx_core/modules/playerdata.lua', -- DISABLE THIS LINE IF YOU DON'T USE QBX-CORE (Keep or add --)
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}

shared_scripts {
    '@ox_lib/init.lua', -- DISABLE THIS LINE IF YOU DON'T USE OX_LIB (Keep or add --)
    '@qbx_core/modules/lib.lua', -- DISABLE THIS LINE IF YOU DON'T USE QBX-CORE (Keep or add --)
    'shared/exports.lua',
}

escrow_ignore {
    'shared/**',
    'client/**',
    'server/**'
}

files {
   'config/shared.lua',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'