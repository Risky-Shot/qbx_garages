fx_version 'cerulean'
game 'gta5'

name 'qbx_garages'
description 'Garage system for Qbox'
repository 'https://github.com/Qbox-project/qbx_garages'
version '1.1.4'

ox_lib 'locale'

ui_page 'web/build/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'shared/*',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/nui.lua',
    'client/main.lua',
    'client/parking.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/spawn-vehicle.lua'
}

files {
    'web/build/index.html',
    'web/build/**/*',
    'config/client.lua',
    'config/parking.lua',
    'locales/*.json',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'