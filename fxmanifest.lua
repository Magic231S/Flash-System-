fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'CFW - لوحة تحكم FiveM المتكاملة'
version '1.0.0'

shared_scripts {
    'config.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua',
    'client/panels/*.lua',
    'client/panels/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
    'server/panels/*.lua',
    'server/database.lua',
    'server/main.lua'
}

dependencies {
    'oxmysql',
    'es_extended'
}

ui_page 'client/panels/html/login.html'

files {
    'client/panels/html/index.html',
    'client/panels/html/login.html',
    'client/panels/html/register.html',
    'client/panels/html/style.css',
    'client/panels/html/script.js'
} 