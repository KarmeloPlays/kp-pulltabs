fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'KarmeloPlays'
description 'QBCore Pull Tab Gambling'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/images/*.png',
    'html/images/*.jpg',
    'html/images/*.jpeg',
    'html/images/*.webp'
}

shared_script 'config.lua'

client_script 'client.lua'
server_script 'server.lua'

dependencies {
    'qb-core'
}
