--[[
-- @author smuttoN
-- @website www.github.com/sutt0n
-- @date 5/22/2017
-- @version 0.0.1
--]]

-- source: https://wiki.fivem.net/wiki/Resource_manifest#resource_manifest_version
resource_manifest_version 'f15e72ec-3972-4fe4-9c7d-afc5394ae207'

-- original author: github.com/kanersps
-- note: you know, I wasn't going to mention it since there wasn't any GNU/MIT license, but fuck it
description 'EssentialMode ported to MySQL' -- since the author is being a hippie about it

ui_page 'ui.html'

-- NUI Files
files {
	'ui.html',
	'pdown.ttf'
}

-- Server
server_scripts {
	'conf.lua',
	'server/util.lua',
	'server/classes/player.lua',
	'server/classes/groups.lua',
	'server/player/login.lua',
	'server/main.lua'
}

-- Client
client_scripts {
	'client/main.lua',
	'client/player.lua'
}