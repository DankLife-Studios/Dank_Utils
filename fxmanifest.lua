fx_version 'cerulean'
game 'gta5'

name 'Dank_Utils'
author 'Dankbudbaker'
description 'A Framework & Script Compatibility For DankLife Scripts'
version '0.7.3'

shared_scripts {
    '@ox_lib/init.lua',
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