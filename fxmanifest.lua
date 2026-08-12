fx_version 'cerulean'
game 'gta5'

name 'Dank_Utils'
author 'Dankbudbaker'
description 'A Framework & Script Compatibility For DankLife Scripts'
version '0.6.0'

-- **INSTRUCTIONS:**
-- If you DO NOT use the framework or library mentioned, add or keep `--` at the start of the line to disable it.
-- If you USE the framework, ensure there is no `--` at the beginning of the line.
shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'init.lua',
}

files {
    'init.lua',
    'modules/*.lua',
    'config/dankutils_manual.lua',
    'config/dankutils_shared.lua',
}

server_scripts {
    'server.lua'
}

dependencies {
    'ox_lib',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'