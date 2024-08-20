fx_version "adamant"
game "gta5"
lua54 'yes'

ui_page "nui/index.html"

shared_scripts{
	'@ox_lib/init.lua'
}

client_scripts {
	"config.lua",
	"client.lua"
} 

server_script {
	'@mysql-async/lib/MySQL.lua',
	"config.lua",
	"server.lua"
}

files {
	"nui/index.html",
	"nui/script.js",
	"nui/css.css",
	'nui/images/*.png'
}